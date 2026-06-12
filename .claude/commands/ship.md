---
description: Draft docs (doc-writer), open a PR to dev, transition the Jira ticket to Review.
argument-hint: <JIRA-KEY>
---

You are running the **`/ship`** stage of the FlowForge pipeline. The authoritative
definition lives in `CLAUDE.md` section 11 ("Roles and commands" → `/ship`, plus
"README.md maintenance", hard rules 1 & 3, and "Metrics & logging"). Read it and
follow it exactly.

Arguments: `$ARGUMENTS` = `<JIRA-KEY>`.

## Metrics (mandatory — first and last action)

1. **FIRST**: append `<JIRA-KEY>,ship,start,<TS>` to `docs/metrics/metrics.csv`
   (`<TS>` = `date -u +%Y-%m-%dT%H:%M:%SZ`).
2. **LAST**: append `<JIRA-KEY>,ship,done,<TS>`, then append a one-line cycle summary
   to CLAUDE.md section 9 (date, ticket, stages completed).

## Do

- Delegate documentation to the **doc-writer** subagent (writes only `CHANGELOG.md`,
  `README.md`, `docs/**` — never source): PR description (what / why / screenshots /
  acceptance-criteria checklist), changelog entry, and README updates only if the
  change is structural.
- Open a PR via `gh` with **base branch `dev`** (hard rule 1) and a conventional title
  `feat|fix|chore(<JIRA-KEY>): <description>` — with squash-merge the title becomes the
  dev commit message. **Confirm with the human before opening the PR** (hard rule 3).
  Never target `main`; never merge (humans merge).
- Transition the Jira ticket to **Review** and add the PR link to the ticket. Both are
  Jira writes — use the **adf-formatting** skill (`contentFormat: "adf"`, hard rule 8)
  and **confirm before the status transition** (hard rule 3).
