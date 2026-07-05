#!/usr/bin/env bash
# Mechanical check: every value-bearing line in a /baseline checkpoint draft must
# carry a Figma node-id citation (pattern like 2:117, 4004:360, 23:60).
# Usage: validate-checkpoint-citations.sh <checkpoint-draft-file>
# Exit 0 = clean. Exit 1 = violations found (printed to stderr).

set -euo pipefail

FILE="$1"
NODE_ID_PATTERN='[0-9]+:[0-9]+'
VALUE_SIGNAL_PATTERN='#[0-9A-Fa-f]{3,8}|[0-9]+(\.[0-9]+)?%|[0-9]+(\.[0-9]+)?px'

VIOLATIONS=0

while IFS= read -r line; do
  [[ -z "$line" ]] && continue
  [[ "$line" =~ ^[[:space:]]*\|?[[:space:]]*-+[[:space:]]*\|?[[:space:]]*$ ]] && continue
  [[ "$line" =~ ^#+ ]] && continue

  if echo "$line" | grep -qE "$VALUE_SIGNAL_PATTERN"; then
    if ! echo "$line" | grep -qE "$NODE_ID_PATTERN"; then
      VIOLATIONS=$((VIOLATIONS+1))
      echo "MISSING CITATION: $line" >&2
    fi
  fi
done < "$FILE"

if [[ "$VIOLATIONS" -gt 0 ]]; then
  echo "" >&2
  echo "$VIOLATIONS line(s) report a design value with no node-id citation." >&2
  echo "Per skill §2, re-verify each flagged line against the actual Figma" >&2
  echo "source and add the node-id before presenting this checkpoint." >&2
  exit 1
fi

echo "OK: every value-bearing line carries a node-id citation."
exit 0
