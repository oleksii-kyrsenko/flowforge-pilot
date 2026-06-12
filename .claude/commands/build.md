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

## Do

- Update the base first: `git fetch origin && git checkout dev && git pull`.
- Create branch `flowforge/<JIRA-KEY>-<slug>` from up-to-date `dev` (hard rule 1).
- Implement the component per the approved spec, following the canonical `src/`
  structure. Server-first RSC; `'use client'` only at leaf interactivity.
- Apply token additions from the spec to the Tailwind theme source (v4: the `@theme`
  block in the global stylesheet; v3: `theme.extend` in tailwind.config) — see CLAUDE.md
  §11 Token map maintenance — AND append the rows to the Design token map in CLAUDE.md in
  the SAME branch (they must never diverge). No raw values in component code.
- **Animations:** implement CSS transitions and simple keyframes only; anything
  flagged "complex animation" in the spec stays a human decision — do not implement it.
- Generate tests per the spec's Test plan (unit always; integration/e2e as specified).
  E2E specs go in `tests/e2e/<JIRA-KEY>.spec.ts`.
- Get `npm run lint`, `npm run typecheck`, and `npm run test:run` green before finishing.
  Never bypass hooks (`--no-verify` is forbidden).

Do not open a PR here — that is `/ship`.
