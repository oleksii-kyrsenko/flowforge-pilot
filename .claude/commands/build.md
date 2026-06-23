---
description: Implement an approved spec on a fresh branch off dev — component, tests, tokens — and get lint/type/tests green.
argument-hint: <JIRA-KEY>
---

You are running the **`/build`** stage of the FlowForge pipeline. The authoritative
definition lives in `CLAUDE.md` section 11 ("Roles and commands" → `/build`, plus
"Project structure", "Testing policy", "Token map maintenance", "Code standards",
and "Performance, Next.js usage & SEO"). Read it and follow it exactly.

Arguments: `$ARGUMENTS` = `<JIRA-KEY>`. Only proceed if that ticket's spec has been
explicitly approved (hard rule 2) — if not, stop and ask.

## Metrics (mandatory — first and last action)

1. **FIRST**: append `<JIRA-KEY>,build,start,<TS>` to `docs/metrics/metrics.csv`
   (`<TS>` = `date -u +%Y-%m-%dT%H:%M:%SZ`).
2. **LAST**: append `<JIRA-KEY>,build,done,<TS>`.

## Status preflight (at the start)

Per CLAUDE.md §11 "Ticket lifecycle & board statuses", check the ticket's status first:

- **In Progress** → proceed normally (the expected path — no prompt).
- **NOT In Progress** (Backlog / To Do / Review / Done) → **STOP and flag.** Report the actual
  status, note this is unusual (`/spec` normally leaves it In Progress) and may mean `/spec`
  was skipped (no approved spec?) or the wrong ticket key was passed. Ask for confirmation
  before transition **31** (In Progress) and proceeding. Human confirm is required only on
  this anomaly.

## Do

- Update the base first: `git fetch origin && git checkout dev && git pull`.
- Create branch `flowforge/<JIRA-KEY>-<slug>` from up-to-date `dev` (hard rule 1).
- Implement the component per the approved spec, following the canonical `src/`
  structure. Server-first RSC; `'use client'` only at leaf interactivity.
- Apply token additions from the spec to the Tailwind theme source (v4: the `@theme`
  block in the global stylesheet; v3: `theme.extend` in tailwind.config) — see CLAUDE.md
  §11 Token map maintenance — AND append the rows to the Design token map in
  docs/design-tokens.md in the SAME branch (docs/design-tokens.md ↔ the `@theme` block
  must never diverge). No raw values in component code.
- **Animations:** implement CSS transitions and simple keyframes only; anything
  flagged "complex animation" in the spec stays a human decision — do not implement it.
- **Icons / vector assets:** obtain glyph geometry via the design-extraction skill's vector-asset
  method; if vector geometry cannot be retrieved by any available tool → STOP and ask, never
  hand-author or guess path geometry (hard rule 5, at the build layer).
- Generate tests per the spec's Test plan (unit always; integration/e2e as specified).
  E2E specs go in `tests/e2e/<JIRA-KEY>.spec.ts`.
- Get `npm run lint`, `npm run typecheck`, and `npm run test:run` green before finishing.
  Never bypass hooks (`--no-verify` is forbidden).
- **Commit (node 1 — see CLAUDE.md §11 "Git steps — commit & push nodes"):** after the gate is
  green, `git commit` the component code + unit tests (+ any token additions). Only after green —
  never a red gate; no `--no-verify`. This commit also carries the `/spec` artifacts and the
  `metrics.csv` rows already in the working tree. **Do not push here — push is `/ship`.**

Do not open a PR here — that is `/ship`.
