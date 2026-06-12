#!/usr/bin/env bash
# FlowForge PostToolUse hook: fast feedback after the agent edits TypeScript.
# Runs the project's lint and type-check scripts on .ts/.tsx edits only, so other
# file types (md, json, css, config) don't pay the cost. On failure it returns the
# output to Claude (exit 2) so the agent can fix it immediately. This is the "fast
# feedback" layer in CLAUDE.md s.11 — husky (pre-commit) is the enforcement gate.
cd "${CLAUDE_PROJECT_DIR:-.}" || exit 0

# Extract tool_input.file_path from the hook's JSON stdin (robust JSON parse via node).
fp=$(node -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>{try{const j=JSON.parse(s);process.stdout.write((j.tool_input&&j.tool_input.file_path)||"")}catch{process.stdout.write("")}})')

case "$fp" in
  *.ts | *.tsx) ;;
  *) exit 0 ;;
esac

if out=$(npm run --silent lint 2>&1 && npm run --silent typecheck 2>&1); then
  exit 0
fi

{
  echo "FlowForge PostToolUse: lint/typecheck failed after editing ${fp}"
  echo "$out"
} >&2
exit 2
