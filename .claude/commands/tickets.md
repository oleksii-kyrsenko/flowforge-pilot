---
description: PM-style backlog generation from Figma frames — drafts with shared-primitive scan, then create FF tickets in Jira after approval.
argument-hint: <figma-url...> [count]
---

You are running the **`/tickets`** stage of the FlowForge pipeline. The authoritative
definition lives in `CLAUDE.md` section 11 ("Roles and commands" → `/tickets`, plus
hard rules 1, 2 & 8). Read it and follow it exactly — do not duplicate or paraphrase the
rules here; this file only wires the command.

Arguments: `$ARGUMENTS` = an unordered SET of Figma file/page/frame URLs (the sources),
plus an optional trailing `[count]` for how many tickets to generate.

## Do (per CLAUDE.md §11)

- Generate a PM-style backlog from the mockup frames. Per ticket: title, user story,
  acceptance criteria as checkboxes, an SP estimate, and the exact Figma frame link;
  vary complexity across the batch.
- **SHARED PRIMITIVES:** scan all frames for primitives used in 2+ frames — either carve
  out a dedicated early "ui primitives" ticket that the others depend on, or add explicit
  "Reuses `<Component>` from `<KEY>`" notes to dependent tickets. The backlog must never
  contain two tickets that each build their own version of the same primitive.

## Show drafts, then STOP

Show all ticket drafts first and **STOP** for approval (hard rule 2). Create nothing in
Jira until the human approves.

## Create (only after approval)

- Create the tickets in **Jira project FF** via Atlassian MCP — they default to **Backlog**
  (the project's initial status); do NOT issue an explicit transition.
- Write descriptions in ADF using the **adf-formatting** skill (`contentFormat: "adf"`,
  never raw Markdown — hard rule 8) so checkboxes and links render correctly.
