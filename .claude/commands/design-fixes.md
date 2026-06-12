---
description: The only channel for design decisions — export open questions, or route a designer's reply to config/class/ticket changes.
argument-hint: <designer reply text | export>
---

You are running the **`/design-fixes`** stage of the FlowForge pipeline. The
authoritative definition lives in `CLAUDE.md` section 11 ("Roles and commands" →
`/design-fixes`, plus "Token map maintenance", "Design questions", hard rule 3).
Read it and follow it exactly. This is the ONLY channel for design decisions — the
pipeline never normalizes or "fixes" design values on its own.

Arguments: `$ARGUMENTS` = either the literal word `export`, or the designer's reply text.

## Metrics (mandatory — first and last action)

1. **FIRST**: append `<batch-label-or-JIRA-KEY>,design-fixes,start,<TS>` to
   `docs/metrics/metrics.csv` (columns are `ticket,stage,event,timestamp_iso`; the stage
   is the full command name `design-fixes`, NOT `fixes`; `<TS>` = `date -u +%Y-%m-%dT%H:%M:%SZ`;
   use a short batch label for the ticket column, or a `<JIRA-KEY>` if the reply maps to one).
2. **LAST**: append the matching `done` row (same ticket + stage).

## Mode: `export`

Render all OPEN questions from `docs/design-questions.md` as a self-contained English
markdown document — absolute Figma node links, NO repo references (designers need no
repo access). Output it for the human to send via any channel. Make no repo changes.

## Mode: designer reply

- Match answers to question numbers. Classify each change (composite values compare per
  the **design-extraction** skill):
  - token **VALUE** change → edit the map + the Tailwind theme source (v4: the `@theme` block
    in the global stylesheet; v3: `theme.extend` in tailwind.config) — see CLAUDE.md §11 Token
    map maintenance — only (usages update automatically);
  - token **COLLAPSE / RENAME** → edit map/config AND replace the affected classes across
    `src/` (a config-only change would break the build);
  - **DELETE** → remove the token and its usages;
  - **behavior / appearance** change → do NOT patch here; create a Jira ticket (full cycle with spec).
- Update each question's status in `docs/design-questions.md`: ✅ resolved / ✅ as-designed /
  🚫 wontfix, with date + PR link. (as-designed still produces a PR removing the "⚠ pending" marks.)
- Branch from up-to-date `dev`, one PR per batch. **Confirm before opening the PR**
  (hard rule 3). Log the batch in CLAUDE.md section 9.
