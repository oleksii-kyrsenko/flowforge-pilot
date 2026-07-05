#!/usr/bin/env bash
# Mechanical check: every color value (hex or rgba) appearing anywhere in the raw
# Figma tool-call transcript for this /baseline run must also appear somewhere in
# the final checkpoint draft text. Catches SILENTLY DROPPED values, not just
# missing citations (see validate-checkpoint-citations.sh for that).
# Usage: validate-checkpoint-completeness.sh <raw-transcript-file> <checkpoint-draft-file>
# Exit 0 = clean. Exit 1 = one or more raw-seen values missing from the draft.

set -euo pipefail

RAW="$1"
DRAFT="$2"

COLOR_PATTERN='#[0-9A-Fa-f]{3,8}\b|rgba?\([0-9]+,\s*[0-9]+,\s*[0-9]+(,\s*[0-9.]+)?\)'

extract_colors() {
  grep -oE "$COLOR_PATTERN" "$1" | tr 'A-Z' 'a-z' | tr -d ' ' | sort -u
}

RAW_COLORS=$(extract_colors "$RAW")
DRAFT_COLORS=$(extract_colors "$DRAFT")

MISSING=0
while IFS= read -r color; do
  [[ -z "$color" ]] && continue
  if ! grep -qF "$color" <<< "$DRAFT_COLORS"; then
    MISSING=$((MISSING+1))
    echo "MISSING FROM DRAFT: $color (seen in raw tool output, absent from checkpoint)" >&2
  fi
done <<< "$RAW_COLORS"

if [[ "$MISSING" -gt 0 ]]; then
  echo "" >&2
  echo "$MISSING color value(s) appeared in raw Figma tool output but do not appear" >&2
  echo "anywhere in the checkpoint draft. Per skill §2, every extracted value must be" >&2
  echo "recorded (even if deduped/normalized under a token name) — re-check each" >&2
  echo "flagged value against its source node and add it to the map, or explain" >&2
  echo "explicitly why it was excluded (e.g. out-of-scope asset, duplicate instance)." >&2
  exit 1
fi

echo "OK: every raw-seen color value is represented in the checkpoint draft."
exit 0
