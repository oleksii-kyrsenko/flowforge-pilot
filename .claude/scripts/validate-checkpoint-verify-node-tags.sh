#!/usr/bin/env bash
# Mechanical check, two-tier: (a) BLOCK — every "[Verify-node: X:Y]" tag (per skill §9) must
# have a matching get_variable_defs or download_assets call with that EXACT nodeId somewhere
# in the raw transcript. A call on a different node-id (e.g. a child/descendant used only as
# an incidental data source — the parent-to-child trap in skill §9) does NOT satisfy the tag,
# no matter how accurate the value read from it turned out to be. (b) WARN (non-blocking) — a
# line that reads like a verification claim (trigger wording: "confirmed", "verified",
# "svg-confirmed", "FALSE FLATTENING", "caught via svg", etc.) plus a node-id citation, but
# carries no [Verify-node:] tag at all, is flagged as a reminder to add one; it does not fail
# the gate by itself.
# Usage: validate-checkpoint-verify-node-tags.sh <raw-transcript-file> <checkpoint-draft-file>
# Exit 0 = no BLOCKING violations (warnings may still have printed). Exit 1 = one or more
# tagged claims lack a backing call on that exact node-id.
#
# Portability note: this machine's `/usr/bin/env bash` resolves to macOS's stock bash 3.2
# (no `mapfile`/`readarray`) — this script uses `while read` loops into arrays instead,
# matching the style already used in validate-checkpoint-near-match-scoping.sh.

set -euo pipefail

RAW="$1"
DRAFT="$2"

NODE_ID_PATTERN='[0-9]+:[0-9]+'
TAG_PATTERN='\[Verify-node:[[:space:]]*[0-9]+:[0-9]+\]'
TRIGGER_PATTERN='svg-confirmed|false flattening|caught via svg|confirmed via (get_variable_defs|download_assets|svg)|deep-read confirm(ed|s)?|\bverified\b'

# Node-ids that were actually passed to get_variable_defs or download_assets anywhere in
# the transcript (the tool_input JSON on the "=== mcp__figma__<tool> tool_input={...} ==="
# header line written for every call).
BACKED_NODES=$(grep -oE '=== mcp__figma__(get_variable_defs|download_assets) tool_input=\{[^}]*\}' "$RAW" \
  | grep -oE '"nodeId"[[:space:]]*:[[:space:]]*"[0-9]+:[0-9]+"' \
  | grep -oE "$NODE_ID_PATTERN" | sort -u || true)

BLOCK_VIOLATIONS=0
WARN_COUNT=0

while IFS= read -r line; do
  [[ -z "$line" ]] && continue

  tag_ids=()
  while IFS= read -r tag; do
    [[ -n "$tag" ]] && tag_ids+=("$tag")
  done < <(echo "$line" | grep -oE "$TAG_PATTERN" | grep -oE "$NODE_ID_PATTERN")

  if [[ ${#tag_ids[@]} -gt 0 ]]; then
    for id in "${tag_ids[@]}"; do
      if ! grep -qxF "$id" <<< "$BACKED_NODES"; then
        BLOCK_VIOLATIONS=$((BLOCK_VIOLATIONS+1))
        echo "UNBACKED VERIFY-NODE CLAIM: [Verify-node: $id] has no get_variable_defs/download_assets call with that exact nodeId in the transcript." >&2
        echo "  -> $line" >&2
      fi
    done
  elif echo "$line" | grep -qiE "$TRIGGER_PATTERN" && echo "$line" | grep -qE "$NODE_ID_PATTERN"; then
    WARN_COUNT=$((WARN_COUNT+1))
    echo "WARN: line reads like a verification claim but carries no [Verify-node: X:Y] tag:" >&2
    echo "  -> $line" >&2
  fi
done < "$DRAFT"

if [[ "$WARN_COUNT" -gt 0 ]]; then
  echo "" >&2
  echo "$WARN_COUNT untagged verification-style claim(s) found — non-blocking. Per skill §9," >&2
  echo "add [Verify-node: X:Y] to each, naming the exact node-id the calls were made on." >&2
fi

if [[ "$BLOCK_VIOLATIONS" -gt 0 ]]; then
  echo "" >&2
  echo "$BLOCK_VIOLATIONS tagged claim(s) failed: the transcript has no get_variable_defs or" >&2
  echo "download_assets call naming that exact node-id. Per skill §9, a child/descendant's" >&2
  echo "export is never a substitute — call the tool on the node the claim is actually about." >&2
  exit 1
fi

echo "OK: every [Verify-node: X:Y] tag is backed by a call on that exact node-id${WARN_COUNT:+ (warnings above are non-blocking)}."
exit 0
