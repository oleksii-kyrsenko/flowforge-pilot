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
- **Raw-transcript logging (hook-driven, not model-authored):** a PostToolUse hook
  (`.claude/hooks/figma-transcript-capture.sh`, matcher
  `mcp__figma__get_design_context|mcp__figma__download_assets|mcp__figma__get_variable_defs`)
  automatically appends the harness's own `tool_response` for every call to these three
  tools to `.claude/tmp/baseline-raw-transcript.txt` — verbatim, by construction, since
  the model never chooses what gets written. **At the start of this command, before any
  Figma tool call, truncate that file** (`: > "$CLAUDE_PROJECT_DIR"/.claude/tmp/baseline-raw-transcript.txt`)
  so a prior run's entries never leak into this checkpoint's gate check. Pass this same
  path to the four gates below as `<raw-transcript-file>`.

## Mechanical verification gates (before presenting the checkpoint)

Run all four gates defined in the design-extraction skill §14, in order (citation →
completeness → deep-read → near-match scoping), against the draft file (and the raw
transcript, for the gates that need it). Fix any failure per skill §14's guidance and
re-run until all four pass, THEN present the checkpoint.

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
- **Scaffold audit** (CLAUDE.md §11 Token map maintenance) — applies here, at APPLY time.
- Create/update `docs/design-questions.md`; log the run in docs/progress-log.md.
- Open a PR to `dev` (humans merge — hard rule 1). **Confirm before opening the PR**
  (hard rule 3). Never target `main`.
