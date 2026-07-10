#!/usr/bin/env bash
# Mechanical check: every node-id whose get_design_context response contains a
# raster <img> reference (the "wrong tool" signal per skill §9) must ALSO have
# a download_assets call for that SAME node-id somewhere in the transcript —
# regardless of what download_assets found (a confirmed-raster result is fine;
# NEVER having called it at all is the gap this catches). Generalizes beyond
# any single value-type (color/opacity/blur) to the underlying tool-usage
# pattern itself.
# Usage: validate-checkpoint-deep-read.sh <raw-transcript-file>
# Exit 0 = clean. Exit 1 = one or more flattened nodes never got a deeper read.

set -euo pipefail

RAW="$1"
NODE_ID_PATTERN='[0-9]+:[0-9]+'

# Node-ids associated with an <img reference in a get_design_context response:
# for each line containing "<img", use the nearest data-node-id="X:Y" seen
# above it in the same block.
#
# Two fixed MCP-server boilerplate sentences (present verbatim on every
# get_design_context call, confirmed session-16 dry-run + T39 hook capture)
# each independently contain a literal example that coincidentally matches
# this detector's bare patterns: `data-node-id="1:2"` (in the "Node ids have
# been added..." sentence) and `<img src={image} />` (in the "...used in the
# code as the source for the image..." sentence). They are excluded by their
# full, exact surrounding prose — NOT by the bare tokens, and NOT by deleting
# the range between them, since a real per-node Component-descriptions block
# (different node ids, different text shape entirely) legitimately sits
# between these two sentences and must survive untouched.
FLATTENED_NODES=$(grep -vF \
  -e 'Node ids have been added to the code as data attributes, e.g. `data-node-id="1:2"`.' \
  -e 'These constants will be used in the code as the source for the image, ex: <img src={image} />.' \
  "$RAW" | awk '
  /data-node-id="[0-9]+:[0-9]+"/ {
    match($0, /data-node-id="[0-9]+:[0-9]+"/)
    last_id = substr($0, RSTART+14, RLENGTH-15)
  }
  /<img/ {
    if (last_id != "") print last_id
  }
' | sort -u)

# Node-ids that were passed to a download_assets call anywhere in the transcript
DEEP_READ_NODES=$(grep -oE '"nodeId"\s*:\s*"'"$NODE_ID_PATTERN"'"' "$RAW" \
  | grep -oE "$NODE_ID_PATTERN" | sort -u || true)
DEEP_READ_NODES_ALT=$(grep -oE "download_assets[^)]*$NODE_ID_PATTERN" "$RAW" \
  | grep -oE "$NODE_ID_PATTERN" | sort -u || true)
DEEP_READ_NODES=$(printf '%s\n%s\n' "$DEEP_READ_NODES" "$DEEP_READ_NODES_ALT" | sort -u)

MISSING=0
while IFS= read -r node; do
  [[ -z "$node" ]] && continue
  if ! grep -qF "$node" <<< "$DEEP_READ_NODES"; then
    MISSING=$((MISSING+1))
    echo "NO DEEP READ: node $node returned a raster <img> reference from get_design_context but was never passed to download_assets anywhere in this run." >&2
  fi
done <<< "$FLATTENED_NODES"

if [[ "$MISSING" -gt 0 ]]; then
  echo "" >&2
  echo "$MISSING node(s) flagged. Per skill §9, a raster <img> reference is a" >&2
  echo "wrong-tool signal, not evidence of unavailability — call download_assets" >&2
  echo "(format: svg) on each flagged node before finalizing the checkpoint. If" >&2
  echo "download_assets confirms genuine raster (real photography), that's a" >&2
  echo "legitimate resolution — this gate only checks that the deeper call was" >&2
  echo "made, not what it found." >&2
  exit 1
fi

echo "OK: every flattened (<img) node-id also has a matching download_assets call."
exit 0
