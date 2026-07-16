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
2. **LAST**, after the spec is posted, append
   `<JIRA-KEY>,spec,done,<TS>,<CLEAN_SECONDS>,<WAIT_SECONDS>` — compute
   `<CLEAN_SECONDS>`/`<WAIT_SECONDS>` from this run's own start/pause/resume rows
   already written above (per CLAUDE.md §11 "Metrics & logging"). Never skip, backfill,
   or estimate these values from memory.
3. **Also:** at every STOP point in this command (the UI-content preflight, the
   Reuses-dependency gate, and the spec-approval checkpoint below), append `pause`
   immediately before halting and `resume` as the first action on resuming — see
   CLAUDE.md §11 "Metrics & logging" for the mechanism.

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
5. **Branch (moved here from the post-approval commit node, session 18):** update the
   base (`git fetch origin && git checkout dev && git pull`); create branch
   `feat/<JIRA-KEY>-<slug>` from up-to-date `dev` — or, if it already exists, check it
   out instead of creating a duplicate. This happens now, right after the ticket reaches
   In Progress — not at spec approval — so this run's own work (Figma/Jira reads, draft
   authoring) happens with the ticket's own branch already checked out. No commit yet;
   the branch may sit with zero commits until the spec is approved and written.

## UI-content preflight (before any Figma read)

If the ticket content describes a visual/UI component (renders with an appearance) AND no
Figma frame link is available (on the ticket or as an argument) → STOP. Do not fabricate
design values, do not write a spec; report the likely missing mockup and ask the human to
supply the frame or confirm the ticket is intentionally non-UI. An honest non-UI ticket
(logic/hook, no UI content) proceeds normally: UI sections N/A with reasons, no Figma call,
no invented tokens.

## Reuses-dependency gate (spec-threshold)

Before proceeding, check every ticket named in the Jira description's **Reuses** field: each one
must have an **existing spec** (`docs/specs/<KEY>.md` — it need not be built or even approved yet).
Missing → **STOP**, name the missing dependency spec(s) and ask. This is one gate with two
thresholds — the stricter, built/merged threshold applies at `/build`, not here.

## Primary-font fallback check (before producing the spec)

Check `docs/design-tokens.md` for an existing confirmed primary font. If one already exists,
skip this — proceed normally, consuming it (design-extraction skill §8). If NONE exists yet
(this project has not run `/baseline`), perform the fallback determination per skill §8:
tally font families across this ticket's own frame(s) only, propose the most frequent as a
NARROW-SOURCE candidate, and include a **Primary font (narrow-source)** line in the spec
output, clearly labeled as based on a single ticket's frames rather than a full-file census.
This is confirmed at the normal spec-approval checkpoint below — not a separate gate.

## Do

- Delegate to the **analyst** subagent (read-only + MCP). It reads the ticket via
  Atlassian MCP and the mockup via Figma MCP, and applies the **design-extraction**
  and **seo** skills.
- Produce the specification with every mandatory section from CLAUDE.md §11:
  purpose, typed props, a **Coverage inventory** line (pages → top-level nodes of ALL
  types → Components-file states/variants → motion check; every absence claim must
  cite it, or it is a defect), states (from the style-guide variant set, matched by what
  CHANGES between variants), breakpoints (when 2+ mockups of the same pattern were read,
  classify every difference CONTINUOUS or DISCRETE — an unclassified difference is a
  defect), design tokens (dedup per Token map maintenance — near-matches never collapsed
  silently → design questions), an **Animations** line (cite the behaviour→library map
  default as reference, never a pin), a **Reuse check** line, a11y, acceptance criteria, a
  **Test plan** line, and an **SEO requirements** line for route/page-level tickets.
- Write the spec to `docs/specs/<JIRA-KEY>.md`. Append any new design questions to
  `docs/design-questions.md`. (Jira-comment posting of the full spec is deferred — see
  CLAUDE.md §4 ambition levels; the ticket lifecycle transitions/assignee claim above
  still run as usual, unaffected.)

## Mechanical verification gates (orchestrator step, before the spec-approval checkpoint)

**Raw Figma-tool-response transcript — hook-driven, not analyst-authored.** The same
PostToolUse hook that serves `/baseline` (`.claude/hooks/figma-transcript-capture.sh`,
matcher `mcp__figma__get_design_context|mcp__figma__download_assets|mcp__figma__get_variable_defs`)
fires for these same three tools regardless of which command's tool call triggered
them — including calls made by the **analyst** subagent — and appends the harness's own
`tool_response` verbatim to `.claude/tmp/baseline-raw-transcript.txt`. The analyst has no
`Write`/`Bash` and never has to write this file itself; it is captured automatically. **At
the start of `/spec`, before any Figma tool call (including any the analyst will make),
truncate this file** (`: > "$CLAUDE_PROJECT_DIR"/.claude/tmp/baseline-raw-transcript.txt`)
— the file is shared with `/baseline` and with every other `/spec` invocation in the same
session, so without this step a prior run's (or a prior command's) leftover entries would
silently leak into this ticket's gate check.

**Draft spec text — still returned by the analyst, still written by the orchestrator.**
The hook only captures raw Figma tool responses, not the analyst's own synthesized spec
prose — that can only cross the subagent boundary via the analyst's single final returned
message (per the Agent tool's own behavior: it returns one message back to the caller).
Have the analyst return its full draft spec text as that final message; the ORCHESTRATOR
then writes it to a scratch draft file (e.g. `.claude/tmp/spec-draft-<JIRA-KEY>.md`)
immediately after the Task returns.

Once both files exist, the ORCHESTRATOR runs all six gates from skill §14 against them,
exactly as `/baseline` does. Fix any BLOCKING failure per skill §14's guidance (re-verify
against the real source, correct the draft, re-run) before presenting the spec for
approval — gates 5 and 6's warn tiers do not block by themselves, but add the missing tag
/ resolve or document the flagged sibling group anyway. This
applies whether `/baseline` has run on this project yet or not — `/spec` may be the first
command run on a project (see skill §8's fallback path), so it cannot assume the gates
were already exercised by an earlier `/baseline`.

## Commit & push (immediately after writing, before the final STOP)

Once the spec is approved and written (`docs/specs/<JIRA-KEY>.md`, `docs/design-questions.md`
if changed, the metrics `done` row):

1. The ticket branch `feat/<JIRA-KEY>-<slug>` already exists and is checked out —
   created at the start of this run, right after the ticket-lifecycle advance (see
   above), not here.
2. `git commit` the spec artifacts — message `chore(<JIRA-KEY>): spec artifacts`.
3. `git push -u origin feat/<JIRA-KEY>-<slug>`.
4. Do NOT open a PR here — the PR still opens at `/ship`, base `dev`, carrying every
   commit (spec + build + review + ship docs) on this one branch.

## Then STOP

Per hard rule 2, after writing the spec STOP and wait for explicit human approval.
Do not start `/build`. (No Jira comment is posted at this stage — deferred, see
CLAUDE.md §4 ambition levels; only docs/specs/<JIRA-KEY>.md and design-questions.md
are written here.)
