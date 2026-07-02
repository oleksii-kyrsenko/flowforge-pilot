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
- **Icons / vector glyphs** — extract the real vector source (path geometry), not a raster
  render; see §9 _Icon & vector-glyph extraction_ for the retrieval method.
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

## 9. Vector extraction — icons & decorative vectors

Icons are vector geometry, not tokens — but the same canon rule applies: extract the real
source, never invent it.

- **Retrieve the vector via `download_assets` with `format: "svg"`** on the PLACED-INSTANCE node
  (the master is often not page-addressable). The export is genuine vector: real path data
  (`d="…"`, `stroke`, `stroke-width`, linecaps), with `rawImages: []` confirming no raster fill.
- **`get_design_context` and `get_screenshot` are NOT vector sources.** `get_design_context`
  represents an icon as a raster `<img>` reference; a screenshot is a pixel render. Neither
  exposes path geometry, and **a raster result is NOT evidence that the vector is unavailable** —
  it means "wrong tool": call `download_assets` with `format: "svg"` instead. Never conclude
  "icons are flattened raster / geometry not extractable" from `get_design_context` alone.
- **Isolate the inner glyph group.** The SVG export wraps the glyph in export-frame and
  page-background elements (a background `<rect>`, parent `<g>`s). Emit only the inner glyph group
  (`<g id="<name>"><path id="Icon" …>`); never the wrapper rects/groups.
- **Scaled instances export scaled geometry.** A non-canonical-size instance exports scaled
  coordinates and stroke-width. For canonical geometry prefer a true full-size instance (or the
  master if addressable); if only a scaled instance is reachable, surface it as a design question —
  never silently normalize the geometry.

**Encoding the retrieved glyph (verbatim).** §9 above covers _extraction_ (getting the vector out of
Figma); this covers _encoding_ it into the component. The canon rule applies to geometry exactly as it
does to tokens — encode what Figma gives, never adjust it to look tidy:

- **Natural per-icon `viewBox` + real `stroke-width`, verbatim.** Each glyph keeps its own `viewBox`
  and its own `stroke-width` from the export. Do **not** normalize the set to a unified box or a single
  stroke weight — icons in one set legitimately differ (square and non-square glyphs, different stroke
  widths), and that difference ships as-is.
- **Size = rendered height, aspect ratio preserved.** A `size` prop sets the rendered height; width
  follows the glyph's natural aspect ratio from its `viewBox`. No fixed box; never scale or stretch the
  glyph to force uniform dimensions.
- **Retrieval cascade for canonical geometry.** Take geometry from the placed **instance** (§9 above);
  consult the **master** only if the instance is insufficient. A master may be unaddressable or return
  `export: null` — then **fall back to the instance geometry verbatim** (and if only a scaled/non-canonical
  instance is reachable, surface a design question per the scaled-instances bullet above — ship verbatim,
  never silently normalize).
- **Non-extractable geometry → STOP, never invent (hard rule 5).** If no available tool yields the vector
  geometry, **STOP and ask the designer.** Never hand-author, guess, estimate, approximate, or normalize
  path data, `viewBox`, or `stroke-width` to fill the gap. A glyph whose geometry cannot be retrieved is a
  STOP — the same anti-fabrication rule that forbids inventing design tokens applies, unchanged, to glyph
  geometry.

**Decorative vectors (separator lines, dividers, watermarks, background art) — the "raster ≠ unavailable"
rule is NOT icon-only.** The same wrong-tool trap applies to ANY decorative vector, not just glyphs:
`get_design_context` returns thin lines and background art as a raster `<img>`, and `get_variable_defs` may
return `{}` — **neither means the value is unextractable.** Call `download_assets` with `format: "svg"` on
the node; `rawImages: []` confirms true vector, and the fill / stroke / gradient lives in the SVG source.
**Never flag a decorative vector's color or geometry "unextractable / not exposed" from a `get_design_context`
raster (or an empty `get_variable_defs`) alone** — exhaust `download_assets svg` first.

- **Split by uniqueness when applying it:** a **unique** decorative (a one-off watermark, a piece of
  background art) → **ship the exported SVG as an asset** (no color extraction, no token, no question). A
  **repeating** element (a site-wide divider/separator used in many places) → **read its color once** (from
  the SVG source / a human Dev-Mode read) and **tokenize it** (one token, reused everywhere) — do not
  re-question it per ticket.

## 10. Source coverage — exhaust the sources before flagging "unextractable / undefined"

A value, state, frame, or behaviour is "unextractable" or "undefined" **only after the available sources are
exhausted**, never from the primary read alone. **This is not advisory — it is a mandatory ATTACHED
ARTIFACT.** Before raising any "absent / unextractable / undefined / no counterpart" flag, produce and attach
a coverage inventory to the spec, in order:

1. **All pages** of the relevant Figma file, listed (skip only genuinely empty/service pages, and say so —
   "skipped: empty" is part of the inventory, not a silent omission).
2. **All top-level nodes on each relevant page — of ALL types, not frames only** (frames, groups, sections,
   canvases), each with **type + name + size** recorded. Multiple same-named top-level nodes at the same
   level are COMMON (e.g. several page-root frames sharing a name) — enumerate and check ALL of them before
   concluding a region/variant has no counterpart; stopping at the first name- or shape-matching candidate is
   the exact defect this rule exists to prevent. **No width-anchoring** — never key a "this is the
   mobile/variant one" conclusion to a specific pixel width; widths vary across files and tickets, identify
   by content coverage, not a magic number.
3. **The design-system / component-library file, not only the page/instance frame.** Component **states and
   variants** (hover / focus / pressed / disabled / active) are usually defined in the design-system source as
   variant sets, not on the placed instance in a page frame. If the project keeps a separate
   design-system/library file, you **MUST** consult it for states/variants before declaring them "undefined"
   or inventing a generic default/hover pair — states are read from the design-system source, never guessed
   from the single placed instance.
4. **ALL of the ticket's frames, not just the primary one.** A ticket may carry several frames — desktop
   **and** responsive/mobile/breakpoint variants. Check every frame the ticket references (and the design's
   mobile/breakpoint frames) before declaring "no mobile frame" or a missing layout.
5. **The right tool for the node type** (§9): a raster `get_design_context` result on a vector →
   `download_assets svg`; an empty `get_variable_defs` is not proof of absence.
6. **A motion/prototype check** via `get_motion_context`, run before concluding a pattern has no
   motion/animation — a "static" conclusion without this check run is itself an unbacked absence claim.

**Only against this attached inventory** does an absence claim become valid. A FALSE "unextractable /
undefined" — one that exhausting these sources would have resolved — is an extraction defect; an absence
claim with **no attached inventory at all** is the same defect, regardless of whether the claim happens to be
true — the inventory is the evidence, not an afterthought.

## 11. Behaviour derivation — don't freeze motion into a static snapshot

When the design implies motion or a known interaction pattern but the static frame (and the MCP output) shows
only a snapshot, **derive the pattern from context + the performance budget** — do not describe it as static:

- A **repeating row of logos/items** → a **continuous marquee**; a **multi-item row with prev/next controls
  and pagination** → a **carousel / paginated** behaviour. Read the snapshot for the _content_; derive the
  _behaviour_ from the pattern.
- **Performance budget (CLAUDE.md §11):** the rule is "no **unnecessary** client JS" — **not** zero JS. A
  real interaction (carousel, marquee) is justified client-JS; a vetted library is acceptable. Do **not**
  impose a zero-JS / CSS-only constraint the law does not, and **do not pin an implementation** in the spec —
  note the behaviour and leave library-vs-CSS open.
- Prototype **motion values** (easing / duration / trigger) are often **not** exposed by the static MCP
  tools — capture what the design implies; flag genuinely **complex** motion "complex animation — human
  decision" (existing rule), and mark unverifiable motion specifics as source-authority, never invent them.
- A vetted default implementation per behaviour pattern lives in the companion
  `behaviour-library-map.md` — consult it for the informational default; cite it as reference in the
  spec, never as a pin (the boundary above still holds: leave library-vs-CSS open).

## 12. Breakpoint continuity — classify every cross-mockup difference as continuous or discrete

Each mockup fixes a **known point**, not a range. Reading two known breakpoints correctly (§10) says
nothing about what happens IN BETWEEN them — that is a separate, genuinely distinct gap this section
closes.

- **The principle:** between any two known mockup points, and beyond the narrowest/widest known point,
  layout must degrade gracefully — text stays readable, images never become disproportionately huge or
  tiny, nothing looks "broken" at any width in between or beyond. Achieve this with modern CSS (fluid
  typography via `clamp()`, fluid spacing via `min()`/`max()`, `aspect-ratio` for images instead of fixed
  px, container queries where appropriate) — never by defaulting to a small fixed set of `@media`
  breakpoints that copy-paste two discrete states with nothing considered for the gap.
- **Mandatory classification:** when comparing two known mockups of the SAME pattern, classify EVERY
  observed property/structural difference as one of:
  - **CONTINUOUS (interpolate)** — e.g. font-size, spacing, image scale. Specify as fluid CSS across the
    whole range, not two fixed values with nothing between them.
  - **DISCRETE (layout-mode switch at a threshold)** — e.g. a multi-column grid becoming a stacked list,
    a horizontal nav becoming a hamburger menu. These switch AT a named breakpoint, never interpolate.
- **A spec stating only "mobile: X, desktop: Y" without this classification is INCOMPLETE** — `/build`
  cannot safely fill the gap without knowing which kind of difference it is implementing. An unclassified
  cross-mockup difference, on any ticket where two or more same-pattern mockups were read, is a defect of
  the SAME SEVERITY as an unbacked §10 absence claim.
- **Reference patterns (illustrative, not exhaustive):** a row of items reflowing into a vertically
  stacked list at a narrower breakpoint is a DISCRETE layout-mode switch, not an interpolation of the
  same grid. A divider/rule built with a flex-basis fill (e.g. `flex-[1_0_0]`) that naturally occupies
  available width at any viewport, with no discrete breakpoint switch, is a CONTINUOUS pattern — recognize
  and call this out explicitly rather than leaving it to chance.
- **Below-narrowest / above-widest:** the same fluid principle continues past the extremes of the known
  mockups — graceful degradation, never a hard cutoff at the edge of the design file's coverage.
