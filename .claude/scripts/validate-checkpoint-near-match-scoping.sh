#!/usr/bin/env bash
# Mechanical check: any near-match / "⚠ pending" line naming two values must tag each
# with [Role: ..., Component: ...]. If the two tags show a DIFFERENT Role or a DIFFERENT
# Component, the pair fails skill §4's same-slot test and should NOT have been raised as
# a near-match/design-question — it should be two independent tokens instead.
# Usage: validate-checkpoint-near-match-scoping.sh <checkpoint-draft-file>
# Exit 0 = clean. Exit 1 = one or more near-match lines fail the same-slot test.
#
# Portability note: this machine's `/usr/bin/env bash` resolves to macOS's stock bash 3.2
# (no `mapfile`/`readarray`, introduced in bash 4.0) — this script uses a `while read`
# loop into an array instead, which is bash-3.2-compatible and behaves identically.

set -euo pipefail

FILE="$1"

VIOLATIONS=0

while IFS= read -r line; do
  if echo "$line" | grep -qiE '⚠[[:space:]]*pending|near-match'; then
    tags=()
    while IFS= read -r tag; do
      [[ -n "$tag" ]] && tags+=("$tag")
    done < <(echo "$line" | grep -oE '\[Role:[^]]+\]')
    if [[ ${#tags[@]} -ge 2 ]]; then
      role1=$(echo "${tags[0]}" | sed -E 's/\[Role:[[:space:]]*([^,]+),.*/\1/' | xargs)
      comp1=$(echo "${tags[0]}" | sed -E 's/.*Component:[[:space:]]*([^]]+)\]/\1/' | xargs)
      role2=$(echo "${tags[1]}" | sed -E 's/\[Role:[[:space:]]*([^,]+),.*/\1/' | xargs)
      comp2=$(echo "${tags[1]}" | sed -E 's/.*Component:[[:space:]]*([^]]+)\]/\1/' | xargs)
      if [[ "$role1" != "$role2" || "$comp1" != "$comp2" ]]; then
        VIOLATIONS=$((VIOLATIONS+1))
        echo "SAME-SLOT VIOLATION: $line" >&2
        echo "  -> Role/Component differ (Role: '$role1' vs '$role2', Component: '$comp1' vs '$comp2') — per skill §4, this pair does NOT pass the same-slot test and should be recorded as two independent tokens, not a near-match/design-question." >&2
      fi
    else
      VIOLATIONS=$((VIOLATIONS+1))
      echo "MISSING TAGS: $line" >&2
      echo "  -> a near-match/pending line must tag BOTH values with [Role: ..., Component: ...] per skill §4 — found ${#tags[@]}." >&2
    fi
  fi
done < "$FILE"

if [[ "$VIOLATIONS" -gt 0 ]]; then
  echo "" >&2
  echo "$VIOLATIONS near-match/pending line(s) failed the same-slot mechanical check." >&2
  echo "Per skill §4, re-verify each: if Role or Component genuinely differ, split into" >&2
  echo "two independent tokens (no question); if they're genuinely the same slot, fix the" >&2
  echo "tags to reflect that accurately." >&2
  exit 1
fi

echo "OK: every near-match/pending line's Role/Component tags pass the same-slot test."
exit 0
