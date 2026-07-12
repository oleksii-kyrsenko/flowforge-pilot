#!/usr/bin/env bash
# Mechanical check, WARN-tier only (never blocks): groups node-ids that share the same
# `data-name="X"` in get_design_context output (placed instances of the same component)
# and flags any group where SOME members were never individually passed as `nodeId` to a
# download_assets/get_variable_defs call.
#
# Why this exists: structural repetition of a component (the same icon/button placed
# N times) says nothing about whether an INDEPENDENTLY OVERRIDABLE property — opacity,
# color, blend-mode — is actually shared across those instances (skill §9's widened
# "coincidental match" rule). A real incident: three placed instances of the same
# Instagram icon carried opacity 40% / 100% / 80% respectively, and the flattened
# get_design_context markup for the 100%-and-80% pair was textually IDENTICAL (neither
# showed an opacity class) — so diffing the flattened classes would not have caught it
# either. Only an independent deep-read per instance can.
#
# Deliberately BLUNT and WARN-only, not BLOCK: forcing every sibling instance of every
# repeated component to get its own download_assets/get_variable_defs call would explode
# call volume against the Figma MCP's rate limit (skill §13) and defeat §5's whole point
# (dedup genuinely-identical repeats). This gate cannot tell a state-varying sibling
# group (Normal/Hover/Press columns — exactly the case that broke) from a purely
# decorative repeat (e.g. the same bullet icon reused with no state semantics) — that
# distinction is the same reasoning-based, non-formulaic judgment skill §10.7 already
# declines to reduce to a fixed rule. So this gate over-flags on purpose: every
# partial/zero-coverage group is surfaced, and a human/agent decides which are worth a
# follow-up call versus a documented "assumed identical, low risk because ..." note.
#
# Usage: validate-checkpoint-sibling-coverage.sh <raw-transcript-file>
# Exit 0 always (WARN-tier) — this gate cannot fail the checkpoint by itself.

set -euo pipefail

RAW="$1"
NODE_ID_PATTERN='[0-9]+:[0-9]+'

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
done <<< "$NAMES"

if [[ "$FLAGGED_GROUPS" -gt 0 ]]; then
  echo "" >&2
  echo "$FLAGGED_GROUPS sibling group(s) have partial or zero individual coverage. This is" >&2
  echo "a WARN, not a BLOCK — structural repetition alone does not require every instance to" >&2
  echo "be independently checked (skill §13 rate-limit + §5 dedup). Before presenting the" >&2
  echo "checkpoint, decide per flagged group: either deep-read the uncovered instance(s), or" >&2
  echo "explicitly note in the draft why they were assumed identical (e.g. purely decorative" >&2
  echo "repeat, no state/column context suggesting per-instance variation)." >&2
fi

echo "OK (warn-tier): sibling-instance coverage check complete, $FLAGGED_GROUPS group(s) flagged."
exit 0
