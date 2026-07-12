#!/usr/bin/env bash
# FlowForge PostToolUse hook: verbatim Figma raw-transcript capture for /baseline's
# mechanical gates (design-extraction skill S14). Removes the model's opportunity to
# paraphrase or omit a tool response before logging it.
# Appends the harness's OWN tool_response (ground truth per code.claude.com/docs/en/hooks'
# PostToolUse stdin schema) for exactly the three tools skill S14 names:
# get_design_context, download_assets, get_variable_defs. get_metadata/get_screenshot/
# get_motion_context are deliberately NOT captured — neither Gate 2 (completeness) nor
# Gate 3 (deep-read) scans for anything those three tools' output shape can produce.
#
# /baseline truncates the target file at the start of each run (see baseline.md) — this
# hook only ever APPENDS, never resets. Known limitation, not solved here: two
# concurrent /baseline runs against the same repo (different sessions) would interleave
# into the same fixed path; accepted as a v1 single-session assumption.
#
# v3.83 addition — SVG-body auto-fetch (closes a real gap found in session review): for
# download_assets specifically, the tool's own response is only a JSON wrapper (nodeId,
# export URL, format, sizeBytes) — the actual SVG bytes previously only ever existed
# transiently in whatever ad-hoc `curl`/`grep` the agent ran afterward, so Gate 2
# (completeness) had no ground truth to check a fetched export against (a real value —
# an opacity baked into a downloaded SVG — was missed this way and no gate could have
# caught it, since the gate never saw the body). This hook now fetches the `export.url`
# itself, independent of the agent's own follow-up commands, and appends the raw SVG
# text to the SAME transcript file so Gate 2's existing color/opacity patterns have real
# bytes to scan. Size-capped (see MAX_AUTO_FETCH_BYTES below) so the multi-MB
# raster-embedding photo exports already established as out-of-scope for token
# extraction don't bloat the transcript. Only `format: "svg"` exports are fetched — PNG/
# JPG/PDF raster exports are binary, not text-greppable by the gates, and are already the
# established "this is real photography, not a token" resolution path.
#
# v3.83 addition — ancestor-leakage call-time nudge: a distinct, narrower fix for the
# parent/child trap already documented in skill §9 (a child node's SVG export can
# incidentally contain an ancestor's own geometry, because Figma's export carries the
# full local paint context, not just the queried node's own path). This hook now checks
# every auto-fetched SVG body for that signature — its own declared <svg width/height>
# vastly exceeded by coordinates found inside it — and if found, surfaces a genuine
# call-time advisory back into the model's context via PostToolUse's
# hookSpecificOutput.additionalContext (per code.claude.com/docs/en/hooks — this is the
# ONLY mechanism PostToolUse supports for injecting context; plain stdout text does NOT
# reach the model, so all file-logging in this script now goes through
# fs.appendFileSync, keeping process.stdout reserved exclusively for this one JSON
# object when it fires). This is a preventive nudge at the moment of the call — it
# cannot retroactively detect a value that was already folded into vague, untagged prose
# in a checkpoint draft (see skill §14's closing note on that residual, human-only gap).
cd "${CLAUDE_PROJECT_DIR:-.}" || exit 0
mkdir -p .claude/tmp

node -e '
const fs = require("fs");
const https = require("https");

const LOG_PATH = ".claude/tmp/baseline-raw-transcript.txt";
// ~1MB: comfortably above every icon/gradient/border SVG seen in practice (a few KB
// each), comfortably below the multi-MB exports that embed a raster photo fill (tens of
// MB) — those are already out of scope for token extraction, so skipping their body
// fetch loses nothing a gate would have used.
const MAX_AUTO_FETCH_BYTES = 1000000;

function appendLog(text) {
  fs.appendFileSync(LOG_PATH, text);
}

function fetchUrl(url) {
  return new Promise((resolve) => {
    try {
      https
        .get(url, (res) => {
          const chunks = [];
          res.on("data", (d) => chunks.push(d));
          res.on("end", () => resolve(Buffer.concat(chunks).toString("utf8")));
        })
        .on("error", () => resolve(null));
    } catch (e) {
      resolve(null);
    }
  });
}

// Ancestor-leakage signature: the SVGs own declared canvas is far smaller than
// coordinate values found inside it. Scans ALL x/y/width/height/x1/y1/x2/y2 attribute
// values in the body, not strictly top-level shapes only (a full XML parse is not worth
// the added dependency for this check) — a self-contained export never has an internal
// coordinate wildly exceeding its own declared canvas, regardless of nesting depth, so
// this simplification does not weaken detection of the real failure mode it targets.
function detectAncestorLeakage(svgText) {
  const svgTagMatch = svgText.match(/<svg[^>]*\swidth="([0-9.]+)"[^>]*\sheight="([0-9.]+)"/);
  if (!svgTagMatch) return null;
  const declaredW = parseFloat(svgTagMatch[1]);
  const declaredH = parseFloat(svgTagMatch[2]);
  if (!declaredW || !declaredH) return null;
  const declaredMax = Math.max(declaredW, declaredH);

  let maxExtent = 0;
  const coordRe = /\s(?:x|y|width|height|x1|y1|x2|y2)="(-?[0-9.]+)"/g;
  let m;
  while ((m = coordRe.exec(svgText))) {
    const v = Math.abs(parseFloat(m[1]));
    if (v > maxExtent) maxExtent = v;
  }

  if (maxExtent > declaredMax * 2 && maxExtent - declaredMax > 50) {
    return { declaredW, declaredH, maxExtent };
  }
  return null;
}

let s = "";
process.stdin.on("data", (d) => (s += d)).on("end", async () => {
  let nudge = null;
  try {
    const j = JSON.parse(s);
    const name = j.tool_name || "";
    if (!/^mcp__figma__(get_design_context|download_assets|get_variable_defs)$/.test(name)) {
      process.exit(0);
    }
    const ti = j.tool_input || {};
    const resp = j.tool_response;
    const text = Array.isArray(resp)
      ? resp.map((b) => (b && typeof b.text === "string" ? b.text : JSON.stringify(b))).join("\n")
      : typeof resp === "string"
      ? resp
      : JSON.stringify(resp);
    const header = "=== " + name + " tool_input=" + JSON.stringify(ti) + " ===";
    appendLog(header + "\n" + text + "\n\n");

    if (name === "mcp__figma__download_assets") {
      const exportMatch = text.match(/"export"\s*:\s*\{([^}]*)\}/);
      if (exportMatch) {
        const exportBlock = exportMatch[1];
        const urlMatch = exportBlock.match(/"url"\s*:\s*"([^"]+)"/);
        const formatMatch = exportBlock.match(/"format"\s*:\s*"([^"]+)"/);
        const sizeMatch = exportBlock.match(/"sizeBytes"\s*:\s*(\d+)/);
        const nodeId = ti.nodeId || "unknown";
        const format = formatMatch ? formatMatch[1] : "";
        const sizeBytes = sizeMatch ? parseInt(sizeMatch[1], 10) : null;

        if (format !== "svg") {
          appendLog("--- AUTO-FETCH SKIPPED (nodeId=" + nodeId + "): format=" + format + ", not svg ---\n\n");
        } else if (sizeBytes !== null && sizeBytes > MAX_AUTO_FETCH_BYTES) {
          appendLog(
            "--- AUTO-FETCH SKIPPED (nodeId=" + nodeId + "): sizeBytes=" + sizeBytes +
              " exceeds " + MAX_AUTO_FETCH_BYTES + " byte cap (treated as raster/photo, already out of scope) ---\n\n"
          );
        } else if (urlMatch) {
          const body = await fetchUrl(urlMatch[1]);
          if (body === null) {
            appendLog("--- AUTO-FETCH FAILED (nodeId=" + nodeId + "): could not fetch " + urlMatch[1] + " ---\n\n");
          } else {
            appendLog(
              "--- AUTO-FETCHED SVG BODY (nodeId=" + nodeId + ") ---\n" + body + "\n--- END AUTO-FETCHED SVG BODY ---\n\n"
            );
            const leak = detectAncestorLeakage(body);
            if (leak) {
              nudge =
                "[ancestor-leakage-nudge] node " + nodeId + " exported a " +
                leak.declaredW + "x" + leak.declaredH +
                " SVG whose internal geometry extends to ~" + Math.round(leak.maxExtent) +
                " — far beyond its own declared canvas. This is the skill §9 parent/child " +
                "trap: the export likely leaked an ANCESTORs geometry, not evidence about node " +
                nodeId + " itself. If you use any color/value from this export to describe an " +
                "ancestor (parent/grandparent) node, call download_assets/get_variable_defs " +
                "DIRECTLY on that ancestor and cite it with its own [Verify-node:] tag — do not " +
                "cite node " + nodeId + " for a value that belongs to an ancestor.";
            }
          }
        }
      }
    }
  } catch (e) {
    // Parse failure: write nothing rather than a partial/garbled block — a gate
    // seeing LESS raw text than actually happened is the same class of defect
    // this hook exists to close, so silence is safer than corrupting the file.
  }

  // stdout is reserved EXCLUSIVELY for this optional JSON object (PostToolUse only
  // injects additionalContext this way — mixing any other text into stdout breaks the
  // parse). All logging above goes through fs.appendFileSync, never process.stdout.
  if (nudge) {
    process.stdout.write(JSON.stringify({ hookSpecificOutput: { hookEventName: "PostToolUse", additionalContext: nudge } }));
  }
})
'

exit 0
