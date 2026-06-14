---
name: design-extraction
description: The Figma extraction & dedup methodology for FlowForge. Use whenever extracting design values from a Figma file — the token baseline (GUIDE Prompt B), /spec token sections, and /design-fixes value comparison. Defines what to extract, how to census it, how to normalize, and how near-matches become design questions.
---

# Design extraction & dedup methodology

The single shared home for turning Figma into tokens. The approved mockup is **canon** —
this methodology never normalizes, merges, or "fixes" design values. Discrepancies become
questions to the designer (see the **Design questions** journal), applied only via
`/design-fixes`.

## 1. Extraction categories

Extract every styled property. The list is a **structure, not a filter**:

- **Solid colors** — fills, text colors, icon colors (with the surface/role they appear on).
- **Gradients** — type (linear/radial/angular/diamond), ordered color stops (position + value), angle.
- **Shadows & blurs** — color, x/y offset, blur, spread; note layer (drop/inner) and
  background blur separately.
- **Strokes** — color, weight, dash pattern, alignment (inside/center/outside).
- **Corner radii** — per corner if they differ.
- **Typography** — family, weight, size, line-height, letter-spacing (each a component).
- **Auto-layout spacing** — gaps, padding (per side), item spacing.
- **Breakpoint-like frame widths** — top-level frame widths that imply responsive breakpoints.
- **Prototype reactions** — capture as motion values (trigger, action, easing, duration).
- **OTHER (catch-all)** — ANY styled property that fits no category above MUST still be
  reported, never silently skipped (opacity, blend mode, background image, clip, etc.).

## 2. Census as aggregates only

Never dump raw per-node data. For each UNIQUE value report:
`value → use count + 2–3 example nodes (with node-ids)`.
This keeps the output a readable inventory, not a wall of duplicates.

**Visibility policy:** the census counts **rendered (visible) nodes**. Values found only on
**hidden** layers (the node or any ancestor is hidden) are reported on a separate **HIDDEN**
line per category and are **never tokenized** — they become design questions (deprecated vs
upcoming). Precedent: `#ff3d2e`, present only on two hidden layers, was kept out of the token
map and recorded as a design question.

## 3. Normalization (for dedup comparison only — never to rewrite the value)

- Colors: lowercase hex; expand shorthand; normalize alpha representation.
- Units: unify (px vs rem) before comparing.
- **Composite values compare component-wise**: gradients by ordered stops + angle;
  shadows by color + offset + blur + spread; typography by each field. Two composites are
  "equal" only if every component matches.

## 4. Dedup outcomes

- **Search scope:** search by normalized value in BOTH the token map (CLAUDE.md §11) and the resolved entries of `docs/design-questions.md`. (This lookup is how the removed-value case below is detected at all — per §11 Token map maintenance.)
- **Exact match** (after normalization) → reuse the existing token; do not create a new one.
- **Near-match** (close but not equal — e.g. two close grays) → the new value becomes a
  token **AS-IS** under a descriptive name, marked **"⚠ pending"**, AND a **design question**
  is appended. NEVER collapse silently. NEVER ask the human operator to arbitrate design.
- **Match with a previously REMOVED value** → recreate the token (mockup is canon) and
  append a follow-up design question referencing the original removal.

## 5. Correlated counts

If several distinct values appear ONLY together and with identical use counts, they are
almost certainly one repeated element (one component instanced N times) — record it as a
single observation, not N independent findings.

## 6. Variant states

When a component has a variant set (default/hover/loading/error/empty…), diff variants by
**what CHANGES between them** (the differing properties), not by the variant names. The
changed properties are the states worth specifying.

## 7. Naming

Semantic (role) names only where the source proves the role (a Figma variable/style name,
or clear component usage). Otherwise use descriptive names (e.g. `orange-600`). Renames
happen via `/design-fixes` only. Raw values never appear in component code.

## 8. Primary font determination (baseline, not /spec)

During the census, tally font families by frequency across all swept frames. The most
frequent family is the PRIMARY-FONT CANDIDATE — a hypothesis, not a verdict (like a
near-match token): confirmed by the human at the baseline checkpoint. /spec NEVER determines
the primary font (a single ticket frame is too narrow a view); it consumes the confirmed
primary font. Frames intentionally using a different family → design question.
