#!/usr/bin/env bash
# Mechanical check, TWO-TIER: (a) WARN (as before) — groups node-ids that share the same
# `data-name="X"` in get_design_context output (placed instances of the same component)
# and flags any group where SOME members were never individually passed as `nodeId` to a
# download_assets/get_variable_defs call. (b) BLOCK (new) — for any such group, if the
# draft asserts a "no variation" claim (e.g. "single-tone", "plain", "no per-instance
# override") about that named glyph/value while FEWER THAN TWO of its instances were
# individually deep-read, and the draft carries no explicit "only one instance exists"
# escape note — that specific claim fails the gate. A structural sibling-coverage gap by
# itself stays WARN (per the original rationale below); asserting universal non-variation
# from insufficient evidence is a stronger, narrower claim that this escalation blocks.
#
# Why this exists (original WARN rationale, unchanged): structural repetition of a
# component (the same icon/button placed N times) says nothing about whether an
# INDEPENDENTLY OVERRIDABLE property — opacity, color, blend-mode — is actually shared
# across those instances (skill §9's widened "coincidental match" rule). A real incident:
# three placed instances of the same Instagram icon carried opacity 40% / 100% / 80%
# respectively, and the flattened get_design_context markup for the 100%-and-80% pair was
# textually IDENTICAL (neither showed an opacity class) — so diffing the flattened
# classes would not have caught it either. Only an independent deep-read per instance can.
#
# Why the escalation (new): a bare sibling-coverage gap doesn't by itself claim anything
# false — it just flags "not everything was checked," which may be a deliberate, correctly
# documented assumption (§5 dedup). But when the DRAFT ITSELF asserts "this glyph has no
# variation" from reading only one placement, that is a specific, falsifiable claim with
# insufficient evidence — the same class of defect as an unbacked [Verify-node:] tag
# (gate 5), just for a different claim-shape. A real incident (session 18): glyphs
# classified "single-tone" in one /spec draft were reclassified "gradient + hardcoded
# accent" in a later draft after checking more than one placement.
#
# Deliberately BLUNT for the base WARN tier still: forcing every sibling instance of
# every repeated component to get its own download_assets/get_variable_defs call would
# explode call volume against the Figma MCP's rate limit (skill §13) and defeat §5's
# whole point (dedup genuinely-identical repeats). This gate cannot tell a state-varying
# sibling group (Normal/Hover/Press columns) from a purely decorative repeat — that
# distinction is the same reasoning-based, non-formulaic judgment skill §10.7 already
# declines to reduce to a fixed rule. So the WARN tier over-flags on purpose; the BLOCK
# escalation only fires on the narrower, explicit "no variation" claim-shape.
#
# Usage: validate-checkpoint-sibling-coverage.sh <raw-transcript-file> <draft-file>
# Exit 0 = no BLOCKING violations (WARN-tier flags may still have printed, non-fatal).
# Exit 1 = one or more "no variation" claims are backed by fewer than two individually
# deep-read instances and carry no explicit single-instance escape note.

set -euo pipefail

RAW="$1"
DRAFT="$2"
NODE_ID_PATTERN='[0-9]+:[0-9]+'

# Case-insensitive trigger phrases for a "no variation" claim-shape. Deliberately a
# fixed list, not a formula — matching this codebase's other gates' honest documentation
# of pattern-matching limits (see the data-name-order note below): a claim phrased
# entirely differently from every listed trigger will not be caught, a silent miss
# rather than a crash.
TRIGGER_PATTERN='single-tone|plain white|plain(,| and)? no variation|no variation|no per-instance|identical across|same across all instances|uniform across|no per-instance override'
ESCAPE_PATTERN='only one instance|only reachable instance|only .* instance (exists|found|reachable)'

# (node-id, name) pairs: matches the exact attribute order seen in every
# get_design_context flattened-JSX response observed so far (`data-node-id="X:Y"
# data-name="Z"`, single space between). If a future MCP response ever emits the
# reverse order, this simply finds zero pairs for that block — a silent miss, not a
# crash; documented here rather than hidden, since fixing it would need PCRE-style
# lookaround this codebase's other gates already avoid for BSD-grep portability.
PAIRS=$(grep -oE 'data-node-id="'"$NODE_ID_PATTERN"'" data-name="[^"]*"' "$RAW" \
  | sed -E 's/data-node-id="([0-9]+:[0-9]+)" data-name="([^"]*)"/\1\t\2/' \
  | sort -u || true)

# Node-ids that were passed to get_variable_defs or download_assets anywhere in the
# transcript — same extraction as gate 5 (validate-checkpoint-verify-node-tags.sh).
BACKED_NODES=$(grep -oE '=== mcp__figma__(get_variable_defs|download_assets) tool_input=\{[^}]*\}' "$RAW" \
  | grep -oE '"nodeId"[[:space:]]*:[[:space:]]*"[0-9]+:[0-9]+"' \
  | grep -oE "$NODE_ID_PATTERN" | sort -u || true)

if [[ -z "$PAIRS" ]]; then
  echo "OK: no named sibling instances found in this transcript (nothing to group)."
  exit 0
fi

# Unique component names present in this transcript.
NAMES=$(printf '%s\n' "$PAIRS" | cut -f2 | sort -u)

FLAGGED_GROUPS=0
BLOCK_VIOLATIONS=0

while IFS= read -r name; do
  [[ -z "$name" ]] && continue

  # All distinct node-ids sharing this name.
  ids=()
  while IFS= read -r id; do
    [[ -n "$id" ]] && ids+=("$id")
  done < <(printf '%s\n' "$PAIRS" | awk -F'\t' -v n="$name" '$2==n{print $1}' | sort -u)

  [[ "${#ids[@]}" -lt 2 ]] && continue

  covered=()
  uncovered=()
  for id in "${ids[@]}"; do
    if grep -qxF "$id" <<< "$BACKED_NODES"; then
      covered+=("$id")
    else
      uncovered+=("$id")
    fi
  done

  if [[ "${#uncovered[@]}" -gt 0 ]]; then
    FLAGGED_GROUPS=$((FLAGGED_GROUPS+1))
    echo "WARN: sibling group \"$name\" has ${#ids[@]} placed instance(s) (${ids[*]});" >&2
    if [[ "${#covered[@]}" -gt 0 ]]; then
      echo "  individually deep-read: ${covered[*]}" >&2
    else
      echo "  individually deep-read: none" >&2
    fi
    echo "  NOT individually deep-read: ${uncovered[*]}" >&2
  fi

  # --- BLOCK escalation: does the draft assert "no variation" for this exact name,
  # with fewer than two individually deep-read instances, and no escape note? ---
  if [[ "${#covered[@]}" -lt 2 ]]; then
    name_lines=$(grep -F -- "$name" "$DRAFT" || true)
    if [[ -n "$name_lines" ]]; then
      claim_lines=$(grep -iE "$TRIGGER_PATTERN" <<< "$name_lines" || true)
      if [[ -n "$claim_lines" ]]; then
        escaped_lines=$(grep -iE "$ESCAPE_PATTERN" <<< "$claim_lines" || true)
        unescaped_count=$(comm -23 <(sort -u <<< "$claim_lines") <(sort -u <<< "$escaped_lines") | grep -c . || true)
        if [[ "$unescaped_count" -gt 0 ]]; then
          BLOCK_VIOLATIONS=$((BLOCK_VIOLATIONS+1))
          echo "BLOCK: \"$name\" is claimed to have no variation (only ${#covered[@]} of ${#ids[@]} instances individually deep-read, no single-instance escape note):" >&2
          echo "$claim_lines" | grep -viE "$ESCAPE_PATTERN" | sed 's/^/  -> /' >&2
        fi
      fi
    fi
  fi
done <<< "$NAMES"

if [[ "$FLAGGED_GROUPS" -gt 0 ]]; then
  echo "" >&2
  echo "$FLAGGED_GROUPS sibling group(s) have partial or zero individual coverage. A bare" >&2
  echo "coverage gap is a WARN, not a BLOCK by itself — structural repetition alone does not" >&2
  echo "require every instance to be independently checked (skill §13 rate-limit + §5 dedup)." >&2
  echo "Before presenting the checkpoint, decide per flagged group: either deep-read the" >&2
  echo "uncovered instance(s), or explicitly note in the draft why they were assumed" >&2
  echo "identical (e.g. purely decorative repeat, no state/column context suggesting" >&2
  echo "per-instance variation)." >&2
fi

if [[ "$BLOCK_VIOLATIONS" -gt 0 ]]; then
  echo "" >&2
  echo "$BLOCK_VIOLATIONS \"no variation\" claim(s) failed: fewer than two individually" >&2
  echo "deep-read instances back a claim of universal non-variation, and no single-instance" >&2
  echo "escape note is present. Per skill §14 gate 6's escalation: either deep-read a second" >&2
  echo "instance, downgrade the claim (do not assert universal non-variation), or add an" >&2
  echo "explicit \"only one instance exists/reachable\" note if that is genuinely the case." >&2
  exit 1
fi

echo "OK: sibling-instance coverage check complete, $FLAGGED_GROUPS group(s) flagged (warn-tier), 0 blocking \"no variation\" violations."
exit 0
