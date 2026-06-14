#!/usr/bin/env bash
# FlowForge PreToolUse hook: Jira permission gate.
# Auto-allows ONLY /spec's forward lifecycle calls that CLAUDE.md hard rule 3 marks
# "AUTO, no confirm" — transition 21 (To Do) / 31 (In Progress) and an assignee-only
# claim — so the harness matches the instruction layer. Everything else (the Review
# transition 51, any broader edit, an unknown tool, a parse failure) falls through to
# the normal human confirm.
#
# SAFE-FAILURE INVARIANT: only the two exact cases above ever emit "allow"; every other
# path — including JSON parse failure, missing fields, unknown tool, or node failing to
# run — emits "ask". A bug can only fail toward confirm, never toward auto-allow; the
# hook never broadens approval. The script always exits 0, so a non-zero node exit can't
# drift the decision toward allow, and the bash fallback below emits an explicit "ask" if
# node produces no output.
#
# PROJECT-SPECIFIC: the transition ids (21/31/51) and the mcp__atlassian__* tool names
# are FF/instance-specific. A template adopter rediscovers the ids via
# getTransitionsForJiraIssue (see CLAUDE.md §11 "Ticket lifecycle & board statuses").

# Robust JSON handling in node: read stdin, apply the decision table, print a complete
# hookSpecificOutput object. Any thrown error inside node prints an explicit "ask".
out=$(node -e '
let s = "";
process.stdin.on("data", d => (s += d)).on("end", () => {
  const decide = (permissionDecision, permissionDecisionReason) =>
    process.stdout.write(JSON.stringify({
      hookSpecificOutput: { hookEventName: "PreToolUse", permissionDecision, permissionDecisionReason },
    }));
  const ask = reason => decide("ask", reason);
  const allow = reason => decide("allow", reason);
  try {
    const j = JSON.parse(s);
    const name = j.tool_name;
    const ti = j.tool_input || {};
    if (name === "mcp__atlassian__transitionJiraIssue") {
      const id = String((ti.transition && ti.transition.id) || "");
      if (id === "21" || id === "31")
        return allow("forward lifecycle transition " + id + " (To Do / In Progress) — /spec auto-advance per hard rule 3");
      return ask("transition " + (id || "<none>") + " requires confirm (Review/Done or unknown)");
    }
    if (name === "mcp__atlassian__editJiraIssue") {
      const keys = Object.keys(ti.fields || {});
      if (keys.length === 1 && keys[0] === "assignee")
        return allow("assignee-only edit — /spec ticket claim per hard rule 3");
      return ask("editJiraIssue changes fields [" + keys.join(",") + "] — broader than assignee-only");
    }
    return ask("unrecognized tool " + String(name));
  } catch (e) {
    return ask("parse failure — defaulting to confirm");
  }
});
' 2>/dev/null)

if [ -z "$out" ]; then
  printf '%s\n' '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"jira-transition-guard: no decision produced — defaulting to confirm"}}'
else
  printf '%s\n' "$out"
fi
exit 0
