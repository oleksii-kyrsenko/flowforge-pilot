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

## Reuses-dependency gate (build-threshold)

Before proceeding, check every ticket named in the Jira description's **Reuses** field: each one
must be **BUILT — merged code on `dev`**, not merely spec'd. Missing → **STOP**, name the
unbuilt dependency/dependencies and ask. This is the same gate as `/spec`'s Reuses-dependency
gate, at its stricter (build) threshold — one gate, two thresholds, not a duplicate rule.

## Do

- Update the base first: `git fetch origin && git checkout dev && git pull`.
- **Branch:** `flowforge/<JIRA-KEY>-<slug>` normally already exists — created and pushed
  by `/spec`'s own commit node. `git fetch origin` and check it out. If it does not exist
  (an edge case: a ticket whose `/spec` predates this rule, or a non-UI ticket), create it
  fresh from up-to-date `dev` (hard rule 1).
- Implement the component per the approved spec, following the canonical `src/`
  structure. Server-first RSC; `'use client'` only at leaf interactivity.
- **Derived behaviour (carousel / marquee / accordion / etc.):** consult
  `.claude/skills/design-extraction/behaviour-library-map.md` for the vetted default
  implementation; use it unless there is a documented reason to deviate (a cheap/reversible
  deviation is reported, a real tradeoff goes to the human). A pattern with no map entry gets
  one ADDED to the map in this cycle, under human confirm — never an unrecorded ad-hoc pick.
- **Fluid/adaptive CSS as the default (breakpoint continuity):** implement per the spec's
  CONTINUOUS/DISCRETE classification — CONTINUOUS properties (font-size, spacing, image scale)
  use fluid CSS across the FULL range between (and beyond) the known mockup points: `clamp()`
  for fluid typography, `min()`/`max()` for fluid spacing, `aspect-ratio` for images instead of
  fixed px, container queries where the component's own size should drive the switch. DISCRETE
  properties (layout-mode switches) switch at the specific threshold the spec names, not
  before/after. **Never copy-paste two fixed `@media` states with nothing engineered for the gap
  between them.** Below the narrowest or above the widest known mockup, the same fluid principle
  continues — graceful degradation, no hard cutoff. A spec lacking this classification is
  incomplete — STOP and ask rather than guessing which kind of difference it is.
- Apply token additions from the spec to the Tailwind theme source (v4: the `@theme`
  block in the global stylesheet; v3: `theme.extend` in tailwind.config) — see CLAUDE.md
  §11 Token map maintenance — AND append the rows to the Design token map in
  docs/design-tokens.md in the SAME branch (docs/design-tokens.md ↔ the `@theme` block
  must never diverge). No raw values in component code.
- **Primary-font application (idempotent guard, CLAUDE.md §11 Token map maintenance):** if
  this ticket has a Figma source (one or more frames) and `docs/design-tokens.md` carries a
  confirmed primary font (from `/baseline` or from this ticket's own `/spec` fallback
  determination), ensure it is wired ONCE, globally, via `next/font` in the root layout, set
  as the document default on `<body>` — never as a per-component class. Idempotent: if
  already correctly wired, this is a no-op — do not re-apply or duplicate the import. If the
  approved spec proposed a NEW confirmed value via its fallback line (not yet in
  `docs/design-tokens.md`), write it there in this same commit, alongside the other token
  additions. Pure-logic tickets with no Figma frame do not trigger this step.
- **Scaffold audit** (CLAUDE.md §11 Token map maintenance) — applies here too, whenever
  this step touches `globals.css`/`layout.tsx`.
- **Animations:** implement CSS transitions and simple keyframes only; anything
  flagged "complex animation" in the spec stays a human decision — do not implement it.
- **Icons / vector assets:** obtain glyph geometry via the design-extraction skill's vector-asset
  method; if vector geometry cannot be retrieved by any available tool → STOP and ask, never
  hand-author or guess path geometry (hard rule 5, at the build layer). **Mechanical check
  (orchestrator step, before accepting geometry or the STOP above):** log the raw icon-related
  tool-call transcript for this ticket's nodes (same logging requirement as skill §14) and run
  the skill §14 Deep-read gate (`validate-checkpoint-deep-read.sh`) against it — the orchestrator
  has `Bash` here, so there is no analyst-style access gap. This confirms `download_assets` was
  actually called for every node where `get_design_context` returned a raster reference, before
  either finalizing extracted geometry or concluding the STOP is warranted. Gates 1/2/4 do not
  apply at `/build` — no color/token checkpoint draft is produced here (skill §9: color/opacity
  extraction happens at `/baseline`/`/spec` time, not `/build`).
- Generate tests per the spec's Test plan (unit always; integration/e2e as specified).
  E2E specs go in `tests/e2e/<JIRA-KEY>.spec.ts`.
- Get `npm run lint`, `npm run typecheck`, and `npm run test:run` green before finishing.
  Never bypass hooks (`--no-verify` is forbidden).
- **Commit (node 1 — see CLAUDE.md §11 "Git steps — commit & push nodes"):** after the gate is
  green, `git commit` the component code + unit tests (+ any token additions). Only after green —
  never a red gate; no `--no-verify`. The `/spec` artifacts (docs/specs, design-questions,
  spec-stage metrics rows) were already committed by `/spec`'s own commit node — this
  commit adds only the build-stage code/tests/tokens/token-docs and build-stage metrics
  rows. **Do not push here — push is `/ship`.**

Do not open a PR here — that is `/ship`.
