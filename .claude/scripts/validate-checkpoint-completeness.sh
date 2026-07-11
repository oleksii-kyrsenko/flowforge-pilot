#!/usr/bin/env bash
# Mechanical check: every color value (hex or rgba), every opacity-bearing attribute
# (fill-opacity="X", stroke-opacity="X", bare opacity="X"), AND every bare Tailwind
# color-keyword class (text-white, bg-black, text-[transparent], from-white, etc. —
# these are genuine, distinct color values that the hex/rgba-only pattern silently
# missed) appearing anywhere in the raw Figma tool-call transcript for this /baseline
# run must also appear somewhere in the final checkpoint draft text. Catches SILENTLY
# DROPPED values, not just missing citations (see validate-checkpoint-citations.sh for
# that).
# Usage: validate-checkpoint-completeness.sh <raw-transcript-file> <checkpoint-draft-file>
# Exit 0 = clean. Exit 1 = one or more raw-seen values missing from the draft.

set -euo pipefail

RAW="$1"
DRAFT="$2"

# Alternation order + leftmost-match semantics (standard in POSIX ERE and PCRE alike)
# mean "fill-opacity=" / "stroke-opacity=" are tried, and win, at their own leftmost
# start position before the bare "opacity=" branch could ever match a later, embedded
# start position within the same attribute — so a line with fill-opacity="0.8" is
# captured once, as "fill-opacity=\"0.8\"", never double-counted against a separate
# bare-opacity match. No lookbehind needed (also keeps this portable to BSD grep,
# which lacks -P/PCRE support).
#
# KEYWORD_COLOR_PATTERN closes a second blind spot: Tailwind lets a color-bearing
# utility carry a bare keyword instead of a hex/rgba value (`text-white`, `from-black`,
# `bg-[transparent]`) — white/black/transparent are the three keywords Tailwind
# recognizes this way. Two alternatives (bare vs. bracketed) rather than independently
# optional brackets, so a malformed one-sided bracket (`text-white]`) can never match —
# each alternative requires BOTH brackets or NEITHER.
COLOR_PATTERN='#[0-9A-Fa-f]{3,8}\b|rgba?\([0-9]+,\s*[0-9]+,\s*[0-9]+(,\s*[0-9.]+)?\)|(fill-opacity|stroke-opacity|opacity)="[0-9.]+"'
KEYWORD_COLOR_PATTERN='\b(text|bg|border|from|via|to|fill|stroke|ring|divide|outline|accent|caret|decoration|placeholder|shadow)-(white|black|transparent)\b|\b(text|bg|border|from|via|to|fill|stroke|ring|divide|outline|accent|caret|decoration|placeholder|shadow)-\[(white|black|transparent)\]'
COLOR_PATTERN="$COLOR_PATTERN|$KEYWORD_COLOR_PATTERN"

extract_colors() {
  # An empty match set (zero colors/opacity values in this file) is a legitimate
  # state, not an error — e.g. a non-UI ticket's draft, or this file simply has
  # none of either. `grep` exits 1 on no-match, which would otherwise trip
  # `set -e` here and silently kill the script before the comparison loop runs
  # (matches the guard already used in validate-checkpoint-deep-read.sh's
  # DEEP_READ_NODES pipelines).
  grep -oE "$COLOR_PATTERN" "$1" | tr 'A-Z' 'a-z' | tr -d ' ' | sort -u || true
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
  echo "$MISSING color/opacity value(s) appeared in raw Figma tool output but do not appear" >&2
  echo "anywhere in the checkpoint draft. Per skill §2, every extracted value must be" >&2
  echo "recorded (even if deduped/normalized under a token name) — re-check each" >&2
  echo "flagged value against its source node and add it to the map, or explain" >&2
  echo "explicitly why it was excluded (e.g. out-of-scope asset, duplicate instance)." >&2
  exit 1
fi

echo "OK: every raw-seen color/opacity value is represented in the checkpoint draft."
exit 0
