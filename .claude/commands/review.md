---
description: Self-review the current diff with the reviewer subagent and fix findings before shipping.
---

You are running the **`/review`** stage of the FlowForge pipeline. The authoritative
definition lives in `CLAUDE.md` section 11 ("Roles and commands" → `/review`, plus
"Performance, Next.js usage & SEO", "Testing policy", "Token map maintenance"). Read
it and follow it exactly.

Arguments: `$ARGUMENTS` = optional `<JIRA-KEY>` for metrics labelling; if omitted,
derive the key from the current branch name (`flowforge/<JIRA-KEY>-...`).

## Metrics (mandatory — first and last action)

1. **FIRST**: append `<JIRA-KEY>,review,start,<TS>` to `docs/metrics/metrics.csv`
   (`<TS>` = `date -u +%Y-%m-%dT%H:%M:%SZ`).
2. **LAST**: append `<JIRA-KEY>,review,done,<TS>`.

## Do

- Delegate to the **reviewer** subagent (read-only; loads the **seo** skill). Review
  the diff against the checklist: types; performance (memoization, bundle size,
  client/server boundary correctness); a11y; Figma token compliance — flag raw values
  AND duplicated primitives (a new component re-implementing an existing `ui/` one);
  pending-token watch (the "⚠ pending" list must not grow silently — new entries need
  a design question); test-to-acceptance-criteria mapping; and SEO semantics for
  route-level changes.
- Fix the findings. Include the review report in the eventual PR description.
