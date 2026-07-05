---
description: Build or update the design token baseline from Figma in verbatim mode — checkpoint, then apply tokens to the theme source via a PR.
argument-hint: <figma-url...>
---

You are running the **`/baseline`** stage of the FlowForge pipeline. The authoritative
definition lives in `CLAUDE.md` section 11 ("Roles and commands" → `/baseline`, plus
"Token map maintenance", "Design questions", "Design token map", "Skills", hard rules
1, 2 & 8). Read it and follow it exactly — do not duplicate or paraphrase the rules
here; this file only wires the command. The token map DATA lives in
`docs/design-tokens.md` (the law that governs it stays in §11).

Arguments: `$ARGUMENTS` = an unordered SET of Figma file/page/frame URLs (the sources).

**Source required (preflight):** at least one Figma source URL. With no Figma URL argument → STOP
with a clear error ("provide a Figma file/page/frame URL"); never fall back to a default/project
Figma URL. (Forbids only a zero-argument call; the per-source scope cascade is unchanged.)

## Methodology gate

VERBATIM mode — the mockup is canon; the pipeline never normalizes, merges, or "fixes"
design values. Methodology = the **design-extraction** skill. If that skill is missing,
**STOP** and ask to run bootstrap — do not improvise an extraction.

## Do (per CLAUDE.md §11)

- **Scope cascade per source:** (a) tracker tickets' frame links; (b) an explicit frame
  list given in the message; (c) self-exploration — list pages, skip empty/service pages,
  work frame-by-frame, never read a whole document in one call.
- **RE-RUN delta mode:** if the Design token map in `docs/design-tokens.md` is already
  filled, read it AND
  `docs/design-questions.md` first; report ONLY new values (tokens as-is + questions),
  changed values of existing tokens ("canon moved" — its own checkpoint row), and values
  no longer present in any source ("deprecate?" question — never delete silently).
  Unchanged mockups → print "No changes against the approved map", change no files, open
  no PR.
- **Raw-transcript logging (for the completeness gate below):** as you call
  `get_design_context`/`download_assets`/`get_variable_defs` during extraction, append
  each raw tool response verbatim to a scratch transcript file (e.g.
  `<scratchpad>/baseline-raw-transcript.txt`) — not a summary, the actual returned text.
  This is required input for the mechanical completeness gate; without it, that gate has
  nothing to check against.

## Mechanical citation gate (before presenting the checkpoint)

Write the full draft map/pending/questions text to a temporary file, then run:
`.claude/scripts/validate-checkpoint-citations.sh <temp-file>`

If it exits non-zero: do NOT present the checkpoint yet. Re-verify every flagged line
against the actual Figma source via a real tool call (never from memory or aggregation
across multiple nodes) — add the correct node-id citation, or correct the value if the
re-check shows it was wrong. Re-run the script until it passes, THEN present the
checkpoint. This is a mechanical, non-negotiable gate — it does not replace judgment on
whether a cited value is itself correct, only whether every value-bearing line is cited
at all.

## Mechanical completeness gate (before presenting the checkpoint)

Run: `.claude/scripts/validate-checkpoint-completeness.sh <raw-transcript-file> <draft-file>`
(the same draft file used for the citation gate above; the raw-transcript file is the one
built per the logging requirement above).

If it exits non-zero: do NOT present the checkpoint yet. For each flagged value, either
(a) add it to the map with its correct role/token, re-verifying against the real source if
its meaning is unclear, or (b) if it's a legitimate exclusion (an out-of-scope decorative
asset already noted in the page inventory, or a duplicate instance of an already-recorded
value), add an explicit one-line exclusion note in the checkpoint saying so — never drop it
silently a second time. Re-run the script until it passes, THEN present the checkpoint.
This gate catches values silently OMITTED from the map; it does not verify that a value
already in the map is itself correct (that remains human/tool-call verification).

## CHECKPOINT, then STOP

Before any write, present: a **PAGE INVENTORY** per source (swept / skipped: empty or
service / out of scope / **NOT VISIBLE TO TOOL** — coverage claims are valid only against
this inventory), the **full map in sections** with every section printed even when empty
("none found"), the **pending** list, and **draft design questions**. Then **STOP** and
wait for explicit approval (hard rule 2).

## Apply (only after approval)

- Branch `chore/token-baseline` from up-to-date `dev` (hard rule 1).
- Apply tokens to the Tailwind theme source (v4: the `@theme` block in the global
  stylesheet; v3: `theme.extend` in tailwind.config) AND fill the Design token map in
  `docs/design-tokens.md` in place with provenance per token — the map ↔ theme source
  must never diverge.
- Create/update `docs/design-questions.md`; log the run in docs/progress-log.md.
- Open a PR to `dev` (humans merge — hard rule 1). **Confirm before opening the PR**
  (hard rule 3). Never target `main`.
