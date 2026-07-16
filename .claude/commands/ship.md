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
2. **LAST**: (a) append `<JIRA-KEY>,ship,done,<TS>,<CLEAN_DURATION>,,` —
   `<CLEAN_DURATION>` computed against the immediately preceding row, per CLAUDE.md §11's
   per-row duration rule (`HH:MM:SS`); (b) immediately append the stage-total row
   `<JIRA-KEY>,ship,total,<TS>,,,<TOTAL_DURATION>` reusing the same `<TS>`, per CLAUDE.md
   §11's stage-total rule; (c) immediately append the whole-task total row
   `<JIRA-KEY>,task,total,<TS>,,,<TASK_TOTAL_DURATION>` reusing the same `<TS>`, per
   CLAUDE.md §11's task-total rule — summing every stage-total row already written for
   this ticket (spec+build+review+ship); (d) append a one-line cycle summary to
   docs/progress-log.md (date, ticket, stages completed); then **commit (node 4 — see
   CLAUDE.md §11 "Git steps — commit & push nodes"):** `git commit` the ship-done metric
   rows + cycle summary as `/ship`'s last action (after the PR is open), and push
   (re-push).
3. **Also:** at every STOP point in this command (the missing-precondition preflight,
   the confirm before opening the PR, and the confirm before the Review transition),
   append `pause` immediately before halting and `resume` as the first action on
   resuming — see CLAUDE.md §11 "Metrics & logging" for the mechanism.

## Preflight (at the start, BEFORE doc-writer/PR)

Per CLAUDE.md §11 "Ticket lifecycle & board statuses", verify the preconditions:

- ticket is **In Progress**;
- branch `feat/<JIRA-KEY>-*` exists with commits ahead of `dev`;
- `docs/specs/<JIRA-KEY>.md` is present.

If **ANY** precondition is missing → **STOP and flag** exactly what is missing and the likely
cause (skipped `/spec` or `/build`, wrong ticket key, or `/ship` already run); ask before
proceeding. This is an ADDITIONAL earlier gate — it does NOT remove the existing confirms
below (before opening the PR and before the status transition, hard rule 3).

## Do

- Delegate documentation to the **doc-writer** subagent (writes only `CHANGELOG.md`,
  `README.md`, `docs/**` — never source): PR description (what / why / screenshots /
  acceptance-criteria checklist), changelog entry, and README updates only if the
  change is structural.
- **Commit (node 3 — see CLAUDE.md §11 "Git steps — commit & push nodes"):** `git commit` the
  doc-writer artifacts (CHANGELOG, README-if-structural) **before** opening the PR.
- **Push (see CLAUDE.md §11 "Git steps — commit & push nodes"):** `git push -u origin <branch>` —
  **feature branch ONLY, never `dev`/`main`** (hard rule 1); no `--no-verify`. Re-push as later
  commits accrue (the open PR auto-updates).
- Open a PR via `gh` with **base branch `dev`** (hard rule 1) and a conventional title
  `feat|fix|chore(<JIRA-KEY>): <description>` — with squash-merge the title becomes the
  dev commit message. **Confirm with the human before opening the PR** (hard rule 3).
  Never target `main`; never merge (humans merge).
- Transition the Jira ticket to **Review** and add the PR link to the ticket. Both are
  Jira writes — use the **adf-formatting** skill (`contentFormat: "adf"`, hard rule 8)
  and **confirm before the status transition** (hard rule 3).
