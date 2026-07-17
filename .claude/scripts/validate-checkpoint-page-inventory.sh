#!/usr/bin/env bash
# Mechanical check, BLOCK-tier: for tickets flagged as requiring document-wide page
# coverage (skill §10's coverage-scope test), every top-level page name returned by a
# FRESH figma.root.children call (via use_figma — see skill §10 point 1) must appear
# somewhere in the checkpoint draft's coverage-inventory. A live page absent from the
# draft is a blocking failure, regardless of whether it plausibly contains new members
# for this ticket's asset class — the point is completeness of the LISTING itself, not
# a judgment call about relevance (that judgment happens per-page, after it is listed).
#
# Why this exists: a real incident (4 consecutive /spec attempts, same ticket, same
# file) had the orchestrator's own page-listing call consistently return only 2 of 18
# real top-level pages — not because pages were skipped by choice, but because the
# call used (get_metadata, no nodeId) follows the connector's own "currently selected"
# session state rather than a guaranteed full-file listing. This gate exists precisely
# because that failure mode produces INTERNALLY CONSISTENT output — the draft's coverage
# table matched what the call returned every time — so nothing about the draft alone
# ever looked wrong. Only cross-checking against an independent, freshly-made call
# catches it.
#
# This script does NOT call Figma itself (bash has no MCP access) — the orchestrator
# must call use_figma (figma.root.children) immediately before running this gate and
# save the raw JSON array result to <live-pages-file> first.
#
# Usage: validate-checkpoint-page-inventory.sh <live-pages-file> <draft-file>
# <live-pages-file>: raw JSON array of {"id": "...", "name": "..."} objects, exactly as
#   returned by figma.root.children this run — never a prior run's cached copy.
# Exit 0 = every live page name appears somewhere in the draft. Exit 1 = one or more
# live pages are missing from the draft's coverage inventory.

set -euo pipefail

LIVE="$1"
DRAFT="$2"

# Extract each page's "name" value from the live JSON array. Deliberately grep/sed, not
# jq — matching this codebase's other gates, which avoid a jq dependency for BSD/portable
# sh compatibility (see validate-checkpoint-sibling-coverage.sh's own note on this).
LIVE_NAMES=$(grep -oE '"name"[[:space:]]*:[[:space:]]*"[^"]*"' "$LIVE" \
  | sed -E 's/"name"[[:space:]]*:[[:space:]]*"([^"]*)"/\1/' || true)

if [[ -z "$LIVE_NAMES" ]]; then
  echo "ERROR: no page names found in $LIVE — this is not a valid figma.root.children result." >&2
  echo "Do not proceed as if coverage were confirmed; re-run the live call and save its actual output." >&2
  exit 1
fi

MISSING=()

while IFS= read -r name; do
  [[ -z "$name" ]] && continue
  # A literal, case-sensitive substring match — the draft is expected to name each
  # swept page verbatim (as its own coverage-inventory convention already requires,
  # skill §10 point 1: "All pages ... listed"). Fixed-string grep (-F), not regex,
  # since page names may contain characters (&, parentheses) that are regex metachars.
  if ! grep -qF -- "$name" "$DRAFT"; then
    MISSING+=("$name")
  fi
done <<< "$LIVE_NAMES"

if [[ "${#MISSING[@]}" -gt 0 ]]; then
  echo "PAGE-INVENTORY VIOLATION: ${#MISSING[@]} live page(s) from this file are absent from the draft's coverage inventory:" >&2
  for name in "${MISSING[@]}"; do
    echo "  - \"$name\"" >&2
  done
  echo "" >&2
  echo "Per skill §14 gate 7: this is a BLOCKING failure regardless of whether these pages" >&2
  echo "plausibly contain in-scope members — list every live page in the coverage inventory" >&2
  echo "(as swept-with-findings, or explicitly swept-and-empty), never silently absent." >&2
  exit 1
fi

echo "OK: every page from the live figma.root.children call ($(printf '%s\n' "$LIVE_NAMES" | wc -l | tr -d ' ') total) appears in the draft's coverage inventory."
exit 0
