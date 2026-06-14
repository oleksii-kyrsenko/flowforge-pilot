---
description: Read a Jira ticket + Figma mockup and produce a component specification (analyst), then STOP for approval.
argument-hint: <JIRA-KEY> [figma-url]
---

You are running the **`/spec`** stage of the FlowForge pipeline. The authoritative
definition lives in `CLAUDE.md` section 11 ("Roles and commands" → `/spec`, plus
"Testing policy", "Performance/SEO standards", "Token map maintenance", and
"Design questions"). Read it and follow it exactly — do not duplicate or paraphrase
the rules here; this file only wires the command.

Arguments: `$ARGUMENTS` = `<JIRA-KEY>` and an optional Figma URL. If the Figma URL is
omitted, take the frame link(s) from the ticket. A ticket may carry several frame
links (e.g. desktop + mobile) — extract and dedup across ALL of them.

## Metrics (mandatory — first and last action)

1. **FIRST**, before anything else, append a `start` row to `docs/metrics/metrics.csv`:
   `<JIRA-KEY>,spec,start,<TS>` where `<TS>` = `date -u +%Y-%m-%dT%H:%M:%SZ`.
2. **LAST**, after the spec is posted, append `<JIRA-KEY>,spec,done,<TS>`.
   Never skip or backfill these rows from memory.

## Ticket lifecycle (AUTO, at the start — after the metrics `start` row, before reading the ticket)

Advance the ticket per CLAUDE.md §11 "Ticket lifecycle & board statuses". This is fully
automatic — **no confirm** (running `/spec` is itself the intent to start work; hard rule 3
asymmetry). Idempotent and forward-only — never move a ticket backwards.

1. Read the ticket's current status.
2. If status is **Backlog** → transition **21** (To Do); if already To Do or further → skip.
3. **Claim assignee:** resolve the current Atlassian user dynamically via `atlassianUserInfo`
   (do NOT hardcode an accountId — keep portable for the template). If the ticket's assignee
   is empty or not the current user → set it to the current user; if already the current
   user → skip.
4. Transition **31** (In Progress); if already In Progress or further → skip.

## UI-content preflight (before any Figma read)

If the ticket content describes a visual/UI component (renders with an appearance) AND no
Figma frame link is available (on the ticket or as an argument) → STOP. Do not fabricate
design values, do not write a spec; report the likely missing mockup and ask the human to
supply the frame or confirm the ticket is intentionally non-UI. An honest non-UI ticket
(logic/hook, no UI content) proceeds normally: UI sections N/A with reasons, no Figma call,
no invented tokens.

## Do

- Delegate to the **analyst** subagent (read-only + MCP). It reads the ticket via
  Atlassian MCP and the mockup via Figma MCP, and applies the **design-extraction**
  and **seo** skills.
- Produce the specification with every mandatory section from CLAUDE.md §11:
  purpose, typed props, states (from the style-guide variant set, matched by what
  CHANGES between variants), breakpoints, design tokens (dedup per Token map
  maintenance — near-matches never collapsed silently → design questions), an
  **Animations** line, a **Reuse check** line, a11y, acceptance criteria, a
  **Test plan** line, and an **SEO requirements** line for route/page-level tickets.
- Post the spec as a Jira comment using the **adf-formatting** skill
  (`contentFormat: "adf"`, never raw Markdown — hard rule 8) and duplicate it to
  `docs/specs/<JIRA-KEY>.md`. Append any new design questions to
  `docs/design-questions.md`.

## Then STOP

Per hard rule 2, after posting the spec STOP and wait for explicit human approval.
Do not start `/build`. (Posting the Jira comment is a Jira write — per hard rule 3,
confirm before posting.)
