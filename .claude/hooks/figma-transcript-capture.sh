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
cd "${CLAUDE_PROJECT_DIR:-.}" || exit 0
mkdir -p .claude/tmp

node -e '
let s = "";
process.stdin.on("data", d => (s += d)).on("end", () => {
  try {
    const j = JSON.parse(s);
    const name = j.tool_name || "";
    if (!/^mcp__figma__(get_design_context|download_assets|get_variable_defs)$/.test(name)) {
      process.exit(0);
    }
    const ti = j.tool_input || {};
    const resp = j.tool_response;
    const text = Array.isArray(resp)
      ? resp.map(b => (b && typeof b.text === "string" ? b.text : JSON.stringify(b))).join("\n")
      : (typeof resp === "string" ? resp : JSON.stringify(resp));
    const header = "=== " + name + " tool_input=" + JSON.stringify(ti) + " ===";
    process.stdout.write(header + "\n" + text + "\n\n");
  } catch (e) {
    // Parse failure: write nothing rather than a partial/garbled block — a gate
    // seeing LESS raw text than actually happened is the same class of defect
    // this hook exists to close, so silence is safer than corrupting the file.
  }
});
' >> .claude/tmp/baseline-raw-transcript.txt

exit 0
