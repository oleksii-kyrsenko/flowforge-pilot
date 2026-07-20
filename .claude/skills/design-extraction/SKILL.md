---
name: design-extraction
description: The Figma extraction & dedup methodology for FlowForge. Use whenever extracting design values from a Figma file — the token baseline, /spec token sections, and /design-fixes value comparison. Defines what to extract, how to census it, how to normalize, and how near-matches become design questions.
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

**Citation completeness check.** Before finalizing any section (including OTHER catch-all),
verify every reported value carries node-id citations per this section's format. A line
without citations is not a stylistic omission — it's a signal the value wasn't
independently re-checked before being written down, and should be re-verified before the
checkpoint is presented.

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

  **Near-match scoping — same slot, not just similar value.** A pair of values qualifies as a near-match
  (triggering the rule above) ONLY when they occupy the SAME semantic slot: the same named role on the
  same component, or the same property across instances/states of the literally same component — and
  differ numerically. This is the case where the difference could be authoring drift within one
  continuous decision.

  A pair does NOT qualify as a near-match — no question, no "⚠ pending" — when the values occupy
  DIFFERENT slots, even if numerically or visually close:
  - **Different named/semantic roles** (e.g. "error" vs "primary" — each is its own decision,
    regardless of hue proximity).
  - **The same property on DIFFERENT components or variants** (e.g. the filled button's shadow vs the
    outline button's shadow — two independent decisions, not one decision expressed twice).

  Record each such value as its own token, under its own name, with no question — proximity in value
  space alone is never evidence of drift.

  **Mandatory Role/Component tagging (mechanical verification).** Whenever a near-match candidate
  IS raised (the pair passed the same-slot test above and a design question is warranted), state
  the Role and Component of EACH value explicitly, in this exact parseable format:
  `[Role: <role-name>, Component: <component-name>]` immediately after each value. This is not
  optional formatting — it is the evidence a mechanical gate checks: if the two tags show a
  different Role or a different Component, the pair did NOT pass the same-slot test above and
  should not have been raised as a near-match at all. Example: `#E68A01 [Role:
decorative-underline-fill, Component: MenuItem] vs #E98C00 [Role: border, Component: Accordion]`
  — this pair's own tags show a different Role and Component, so per the rule above it should be
  recorded as two independent tokens, not raised as a design question.

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

## 8. Primary font determination — baseline-preferred, with a /spec fallback when no baseline has run

Primary font determination resolves to exactly ONE confirmed value in `docs/design-tokens.md`;
there are two paths to fill it depending on which command runs first on a given project —
never two independent determinations in force at once.

- **Preferred path — full-coverage census (`/baseline`):** during the census, tally font
  families by frequency across ALL swept frames. The most frequent family is the
  PRIMARY-FONT CANDIDATE — a hypothesis, not a verdict (like a near-match token): confirmed
  by the human at the baseline checkpoint, then recorded in `docs/design-tokens.md`.
- **Fallback path — `/spec` runs before any `/baseline` has confirmed a value:** `/baseline`
  is not a mandatory project step — a project may go straight to `/spec`. If
  `docs/design-tokens.md` has no confirmed primary font when `/spec` starts, `/spec` MUST NOT
  silently proceed without one and MUST NOT silently defer it either: determine a candidate
  from ONLY this ticket's own frame(s), label it explicitly as a NARROW-SOURCE hypothesis (a
  single ticket's frames, not a full-file census — weaker evidence than the baseline path;
  say so in the spec text). Present it for confirmation at the SAME spec-approval checkpoint
  (hard rule 2) — this is not a separate gate.
- Once ANY value is confirmed (by either path) it is recorded in `docs/design-tokens.md`;
  every subsequent `/spec` run on that project simply CONSUMES it — `/spec` never
  re-determines a value that already exists there. If a LATER `/baseline` is run on the same
  project, a differing full-coverage result supersedes a narrow-source one — treat this as a
  "canon moved" case per `/baseline`'s RE-RUN delta mode, not a silent conflict.
- **Auto-confirm on unanimous census.** If the full-coverage census (baseline path) or the
  narrow-source census (`/spec` fallback path) finds exactly ONE family with ZERO competing
  entries, the primary-font confirmation is auto-accepted — do not present it as a checkpoint
  item requiring an explicit human click. Present it as a confirmed fact in the output ("Primary
  font: Poppins — 100% census, auto-confirmed, no competing family"), not a question. Explicit
  confirmation remains required only when the census shows 2+ families in meaningful proportion
  (genuine ambiguity).
- Frames intentionally using a different family → design question (unchanged).

## 9. Vector extraction — icons & decorative vectors

Icons are vector geometry, not tokens — but the same canon rule applies: extract the real
source, never invent it.

This extraction happens now, in whichever pass is currently reading the icon — there is
no "defer to /build" or "defer to the ticket that uses it" exception for an icon's STYLED
PROPERTIES (fill/stroke color, opacity, gradient, blur — anything on §1's extraction
list). §1's "extract every styled property, the list is a structure not a filter" applies
to icons exactly as to every other element. What MAY legitimately wait for a per-ticket
read is raw PATH GEOMETRY (`d=`, `viewBox`) when a broad sweep (like `/baseline`) is
surveying many icons and a full geometry pull for each would be excessive — but even then,
the icon's per-state COLOR (a design token, same as any border or fill) is extracted now,
not deferred alongside the geometry.

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

**When Bash/WebFetch is available in the running context** (e.g. orchestrator-run commands like
`/baseline` and `/design-fixes`, which don't dispatch a tool-restricted sub-agent) — resolve to RAW BYTES
via `curl` on the returned export URL, not a `WebFetch` paraphrase. A `WebFetch` summary is generated by an
intermediary model and is not raw evidence — treat it as a hint at most, and always follow up with `curl`
before recording a value as confirmed. This does not create a new capability requirement — it only governs
how an already-available tool must be used; a context without Bash (the `analyst` sub-agent under `/spec`,
restricted per its own tool list) remains bound by the STOP-and-ask rule above, unchanged.

**Coincidental match is not identity for any overridable property — color, opacity, or blend-mode
alike.** When `get_design_context` flattens a paint (border, fill, stroke) to a solid hex that happens to
equal an already-established token's value, do NOT record it as "confirmed, same token" on that visual/hex
coincidence alone — a flattened representation can silently hide a gradient, a bound variable, or an
unrelated raw value that merely renders to the same hex at a glance (illustrative failure mode: a
component state's border may be flattened by `get_design_context` into a single flat color while the real
Figma paint is actually a vertical gradient — trusting the flattened read alone would silently record the
wrong value). Before writing the claim, run, in this order:

1. **`get_variable_defs` on that exact node** — if the paint is bound to a variable/style, that settles
   identity (reuse or distinguish per the dedup rules in §4).
2. **If unbound and no named local style resolves it, the `download_assets` (format: svg) export for that
   SAME node MUST actually be fetched** (`curl` on the returned URL, per the raw-bytes rule above) **and its
   real paint data read** — inferring identity from a sibling state's already-confirmed pattern is NOT
   sufficient evidence. Each state/node earns its own curl-and-read; a match confirmed on one sibling does
   not carry over to the next just because the property name is the same.

**The same discipline applies beyond color — structural repetition of a component does not imply its
overridable properties are shared.** A component placed N times as "the same icon/button" is only the same
GEOMETRY N times; opacity, blend-mode, and any other independently-overridable §1 property are each their
own per-instance fact, not something a shared name or shared geometry lets you infer. Illustrative failure
mode (a controller-caught real incident, not a hypothetical): three placed instances of the same Instagram
icon, structurally identical, carried opacity 40% / 100% / 80% respectively — and the flattened
`get_design_context` markup for the 100%-and-80% pair was textually IDENTICAL (neither instance showed an
opacity utility class), so even diffing the flattened code between instances would not have surfaced the
difference. Only an independent `download_assets`/`get_variable_defs` read per instance resolves this —
the same "each state/node earns its own curl-and-read" rule above, now named explicitly for opacity and
blend-mode so it is not read as color-only. Skill §14's gate 6 gives this a mechanical (WARN-tier) backstop:
it flags any group of same-named placed instances where some were never individually deep-read — it cannot
tell a state-varying group from a purely decorative repeat, so treat every flag as a prompt to check or to
explicitly document the assumption, not as a defect by itself.

**A child/descendant's export is not a substitute for calling the tool on the node itself.** The
sibling-state trap above is sibling-to-sibling (Hover's confirmed value doesn't carry over to Press). A
second, distinct trap is parent-to-child: `download_assets` on a small descendant node (an icon, a text
leaf) can return an SVG that — because Figma's export includes ancestor positioning/paint context — also
happens to contain the PARENT frame's own border or fill, rendered correctly. Reading that incidental
payload and recording the parent node as verified is still a violation of rule 2 above: `get_variable_defs`
and `download_assets` were never called with the parent's OWN node-id, only the child's. The data read this
way can be perfectly accurate — the trap is procedural, not factual — but the claim "verified" attached to
the parent's node-id is unbacked until a call naming that exact node-id exists in the transcript. If a
descendant's export is the only practical source for a given value, call `download_assets` on the actual
node the claim is about anyway (it is always addressable, being an ancestor of an addressable node) before
writing the claim.

**Mandatory `[Verify-node: X:Y]` tagging (mechanical verification).** Whenever a claim resolves a
flattened/ambiguous paint via `get_variable_defs` or `download_assets` — "confirmed", "verified",
"svg-confirmed", "FALSE FLATTENING caught via svg", or equivalent wording — tag it in this exact
parseable format immediately after the claim: `[Verify-node: <node-id>]`, naming the EXACT node-id the
calls were actually made on. This is not optional formatting — it is the evidence a mechanical gate
checks (skill §14 gate 5): a tagged claim with no matching `get_variable_defs`/`download_assets` call on
that exact node-id in the transcript fails the gate, and an untagged claim that reads like a verification
(trigger wording plus a node-id citation but no tag) is flagged as a warning to add one. Tag the node the
claim is actually ABOUT, never a child/descendant used only as an incidental data source — that
distinction is the entire point of this rule; see the parent/child trap directly above. Example: `border
resolves to white 20%→0% opacity fade [Verify-node: 2:94]` is only valid if the transcript shows a
`get_variable_defs` or `download_assets` call with `"nodeId":"2:94"` — a call on a different id (e.g. a
child icon `2:99`) does not satisfy the tag, no matter how accurate the value read from it turned out to
be.

This applies wherever the raster-≠-unavailable / `download_assets svg` rule above already applies — a
passed `download_assets` _call_ is not proof the export was actually read; the mechanical deep-read gate
(skill §14 gate 3) only checks that the call was made, never what its payload contained. Closing that gap
is a methodology discipline (this rule), not something the mechanical gate can enforce.

**A project-wide icon/glyph registry (`docs/icon-glyphs.md`) — created by whichever
ticket first needs it, grown by every ticket after.** No single ticket owns this file.
Before adding any icon glyph to a component, check whether `docs/icon-glyphs.md` already
exists: if not, create it and seed it with this ticket's own found glyphs (verbatim
geometry, node-id, in/out-of-scope classification) — same discipline as
`docs/design-tokens.md`. If it already exists, dedup against it exactly as tokens are
deduped (§4): an exact match reuses the existing entry; a genuinely new glyph is
appended (never silently substituted for an existing entry); a near-duplicate becomes a
design question, same as a near-match token. Every ticket that encounters an icon not
yet in the registry is responsible for adding it there, not just consuming it locally
within its own component.

## 10. Source coverage — exhaust the sources before flagging "unextractable / undefined"

**Visual structure recognition — before any per-node extraction.** A component/style-guide file exists
specifically to show, for each interactive element category, its state set side-by-side (buttons/links/
icons: Normal/Hover/Press; inputs: their own broader set; a carousel: its own set; etc.) — this is the
file's basic organizing principle, not a pattern to infer. Before reading individual nodes, get a full
screenshot of each relevant showcase frame and visually identify: how many distinct component-category
panels exist, and what state-columns each panel demonstrates. Treat a state-column header as governing
the FULL set of component instances visually grouped beneath it in that panel. This applies equally to
`/baseline` (reading a whole design-system file) and to `/spec` (reading a component's state set for one
ticket) — whichever command is doing the reading, look at the panel as a human would before computing
anything from individual node positions or text.

A value, state, frame, or behaviour is "unextractable" or "undefined" **only after the available sources are
exhausted**, never from the primary read alone. **This is not advisory — it is a mandatory ATTACHED
ARTIFACT.** Before raising any "absent / unextractable / undefined / no counterpart" flag, produce and attach
a coverage inventory to the spec, in order:

**Coverage scope depends on what is being read — do not over-sweep, do not under-sweep:**

- **`/baseline` and ROUTE/PAGE `/spec` tickets:** the full page + top-level-node enumeration (points 1–2) is load-bearing — a route/page's completeness genuinely depends on finding every sibling frame (the defect class that once let a whole mobile page-frame go missing). Enumerate all pages and all top-level nodes of all types per points 1–2.
- **GLOBAL SET-PRIMITIVE `/spec` tickets (icons, and any primitive whose deliverable is a project-wide SET of assets rather than one visual component):** the deliverable is "every X in the project", so coverage is GLOBAL by nature — enumerate ALL pages of the file (point 1) and search EVERY page for every instance of the asset class (icons: every vector glyph at every call site), not only instances of names/sizes the ticket happens to enumerate. A ticket's own list of expected members (names, count, sizes) is a starting hint, never the coverage boundary — the inventory must state what the full-file search found, including members the ticket did not name. **Search method — structural enumeration, not name-keyword matching.** A keyword/name-pattern search over node names is not exhaustive by construction — a member whose name does not happen to match any anticipated keyword is invisible to it, regardless of how many keywords are tried. Enumerate EVERY non-text leaf node within the asset class's typical size range on every swept page — this explicitly includes vector/instance/boolean-operation nodes AND raster/image-fill nodes (a rectangle or frame with an image fill, not only SVG-shaped nodes) — and classify EACH one individually (in-scope member / out-of-scope / already-catalogued duplicate) — never filtered out before classification by whether its name matches an expected pattern, and never filtered out by node type either. A real incident: a raster icon-shaped asset was missed twice in the same file because a sweep's own stated method named only vector/instance/boolean-operation node types, silently excluding a structurally-present, correctly-sized raster leaf node from consideration entirely. The class is decided by the DELIVERABLE's nature (does the whole project consume this set?), not by the ticket's wording. For each found member, the per-instance disciplines of §9 (verbatim geometry, canonical instance, scaled-instance question) apply unchanged.
- **SINGLE-COMPONENT / PRIMITIVE `/spec` tickets (one visual component — NOT a global set-primitive, see above):** the authoritative source for the component's variants/states is the design-system/library variant set (point 3); for its responsive behaviour, the component's OWN instances across the breakpoint frames the ticket references (point 4). A component's definition does NOT live in the document's other unrelated pages — a document-wide page enumeration (points 1–2) is NOT required and must not be performed for breadth's sake; read the component itself across its breakpoints instead. Do NOT assert a document-wide page count (e.g. "exactly N pages, none skipped") the ticket did not need and did not fully take — an unneeded, unverified completeness claim is itself a defect. An absence claim about the component's states is valid against point 3; an absence claim about its responsive layout is valid against point 4.

Points 3–8 apply to every ticket. The numbered list is the full menu; the scope above says which entries are load-bearing for the ticket at hand.

1. **All pages** of the relevant Figma file, listed (skip only genuinely empty/service pages, and say so —
   "skipped: empty" is part of the inventory, not a silent omission). **Retrieval method — `figma.root.children` via `use_figma`, not `get_metadata` with no `nodeId`.** The latter is confirmed unreliable: it returns whatever node is "currently selected" in the connector's own session state rather than a guaranteed full page list, once ANY node-specific call has already happened earlier in that session — a real incident showed it silently returning 2 pages of a genuinely 19-page (18 content pages + 1 divider) file, consistently, across four separate attempts. `figma.root.children` (a read-only Plugin-API snippet returning `{id, name}` for every top-level page) is state-independent and was independently verified to match the file's real page list exactly. If `use_figma` (or equivalent Plugin-API read access) is unavailable in the running context, STOP and report this as a tool-access gap (per §13's rate-limit-STOP precedent) — never fall back to `get_metadata`'s unscoped call as if it were equivalent.
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
7. **Exhaustive, evidence-based label correlation — reasoning, not a formula.** When a coverage sweep
   finds unassigned text nodes resembling state names (Normal/Hover/Press/Active, etc.), correlate them
   to component instances by REASONING through the structure the way a human reading the design file
   would — not by applying a fixed coordinate formula. A label may legitimately apply to ONE instance, to
   a WHOLE GROUP of stacked/columned instances demonstrated together in that state (a design-system
   reference file commonly shows many unrelated component types under one shared state heading), or to
   NONE at all — all three are valid outcomes, and none should be forced.

   Weigh multiple, converging signals together, not position alone:
   - **Structural grouping** — does the candidate sit within an evident column/row/section the label
     heads, however many instances that grouping contains and however far it extends?
   - **Figma-internal style/variable names** that echo the state (e.g. a fill or stroke annotated
     "Gradient/Hover", "Gradient/Press", or a bound "Primary" variable) — corroborating evidence, not
     proof by itself.
   - **Plausibility** — does this component type ever have this state, and does the visual content
     support it?

   Do not stop at the first plausible match if the same evident grouping contains further, still-unassigned
   instances — follow the grouping to its natural end (a new label, a different grouping, or unrelated
   content), not to an arbitrary distance cutoff. Equally, do not force a match where the evidence is
   genuinely absent or contradictory — an honest "no applicable label found, per available
   structural/style evidence" is a correct conclusion, not a failure.

   **Self-audit before writing "unexplained."** Before recording ANY property difference (opacity, color,
   or otherwise) as an unexplained inconsistency or open design question, cross-check it against every
   column/grouping ALREADY established elsewhere in the same coverage sweep — a difference that
   structurally coincides with an already-identified grouping is a state finding, not a mystery, even if
   it wasn't the component the grouping was first noticed on. An "unexplained inconsistency" design
   question that a five-minute cross-check against already-gathered data would have resolved is the same
   defect as an unbacked absence claim.

8. **Decorative-vector children within an already-swept parent are not automatically covered.** Marking
   a parent frame/instance (a Header, a component showcase frame, a card) "swept" in the coverage
   inventory does NOT mean every descendant decorative vector — thin lines, dividers, hairlines,
   background shapes generically named "Rectangle N"/"Line N"/"Vector" — was individually queried.
   Before excluding such a child from the token map, explicitly call `get_design_context` (and
   `download_assets svg` per §9 if it renders as a raster `<img>` reference) on it directly — a
   parent-level sweep does not implicitly cover it. This applies with equal force on a RE-RUN: an
   element correctly tokenized in a PRIOR baseline run and now silently absent from the current one is
   a coverage REGRESSION, not evidence the element stopped existing — cross-check the current run's
   decorative-vector coverage against any prior approved checkpoint for the same file before concluding
   an element is out of scope.

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

## 13. Extraction execution — concurrency & rate-limit handling

The Figma MCP enforces an account/seat-level tool-call quota (both a per-day and a
per-minute cap). This constrains HOW extraction work is executed, not what to extract.

- **Do not fan out wide-parallel extraction sub-agents against the Figma MCP.** A 6-way
  parallel fan-out has been observed to exhaust the shared quota within a few calls.
  Extract multiple component groups either **sequentially**, or with **limited
  concurrency (≤2 sub-agents at once)**.
- **On a rate-limit error, STOP that sub-task immediately.** Report exactly what was
  extracted before the limit hit and what is missing, flagged as a **tool-access gap, not
  a design absence** (§10 applies here too — a rate-limit STOP is not evidence a value
  doesn't exist). Never retry the same call in a loop hoping the limit clears mid-session.

## 14. Mechanical verification gates (Bash-capable contexts only)

These seven gates mechanically check a checkpoint draft before it is presented to the
human. They require a raw tool-call transcript (built per the logging requirement below)
and run wherever Bash is available — the `/baseline` orchestrator directly; for `/spec`,
the ORCHESTRATOR runs them after the `analyst` subagent (which has no Bash) returns its
draft — see the per-command wiring in each command file, which points here rather than
restating the gate logic.

**Raw-transcript logging (prerequisite for all seven gates):** as `get_design_context` /
`download_assets` / `get_variable_defs` calls are made during extraction, append each raw
tool response verbatim to a scratch transcript file — not a summary, the actual returned
text. For `download_assets` specifically, the hook that builds this transcript
(`.claude/hooks/figma-transcript-capture.sh`) also fetches the export's own SVG body
(size-capped, real photography exports excluded) and appends it too — the tool's own
JSON response only ever carries an export URL, not the paint/opacity data inside it, so
without the body fetch, gate 2 (completeness) would have nothing but a claim that a call
happened, never what it actually returned. Without any of this, the gates below have
nothing to check against.

1. **Citation gate** (`validate-checkpoint-citations.sh <draft-file>`) — every
   value-bearing line (hex color / % / px) must carry a Figma node-id citation on the
   same line. Catches values written without a traceable source.
2. **Completeness gate** (`validate-checkpoint-completeness.sh <raw-transcript-file>
<draft-file>`) — every color AND opacity-bearing value (hex/rgba, `fill-opacity=`,
   `stroke-opacity=`, bare `opacity=`) seen anywhere in the raw transcript must also
   appear somewhere in the draft. Catches values that were extracted but silently
   dropped before the draft was written.
3. **Deep-read gate** (`validate-checkpoint-deep-read.sh <raw-transcript-file>`) — every
   node-id whose `get_design_context` response contained a raster `<img>` reference (the
   §9 wrong-tool signal) must also have a `download_assets` call for that same node-id
   somewhere in the transcript, regardless of what it found. Catches a flattened tool
   result accepted as final without ever calling the deeper tool.
4. **Near-match scoping gate** (`validate-checkpoint-near-match-scoping.sh <draft-file>`)
   — every near-match/`⚠ pending` line must tag both compared values with
   `[Role: ..., Component: ...]` (per §4); if the two tags show a different Role or
   Component, the pair fails the same-slot test and should not have been raised as a
   near-match. Catches a near-match raised where the pair's own stated evidence
   contradicts §4's same-slot rule.
5. **Verify-node tag gate** (`validate-checkpoint-verify-node-tags.sh <raw-transcript-file>
<draft-file>`) — two-tier: (a) **block** every `[Verify-node: X:Y]` tag (per §9) whose
   exact node-id `X:Y` has no matching `get_variable_defs`/`download_assets` call in the
   transcript — a tag naming a different node (e.g. a child used as an incidental data
   source) does not satisfy it; (b) **warn** (non-blocking) on prose that reads as a
   verification claim — trigger wording ("confirmed", "verified", "svg-confirmed", "FALSE
   FLATTENING", etc.) plus a node-id citation on the same line — but carries no
   `[Verify-node:]` tag at all, nudging the author to add one. Catches a claim whose
   verification-call evidence doesn't actually name the node the claim is about — the
   defect this gate exists for is a controller-caught real incident, not a hypothetical
   (a claim of "svg-confirmed" for a parent node backed only by a call on its child).
6. **Sibling-instance coverage gate** (`validate-checkpoint-sibling-coverage.sh
<raw-transcript-file> <draft-file>`) — **Two-tier: WARN by default
   (the base coverage flag), with a BLOCK escalation for one specific claim-shape (see
   below).** Groups node-ids that share
   the same `data-name="X"` in `get_design_context` output (placed instances of the same
   component) and flags any group where some members were never individually passed as
   `nodeId` to a `download_assets`/`get_variable_defs` call. Deliberately blunt: it cannot
   distinguish a state-varying sibling group (Normal/Hover/Press columns) from a purely
   decorative repeat, so it over-flags on purpose rather than risk staying silent on a
   real one — see the widened "coincidental match" rule earlier in §9 for the incident
   this closes (three placed instances of one icon at 40%/100%/80% opacity, only one of
   which had ever been individually deep-read). Every flag is a prompt to check or to
   explicitly document the assumption, not proof of a defect by itself.

   **Escalation to BLOCKING for a specific claim-shape:** the general sibling-group flag
   above stays WARN-tier, but any claim that explicitly asserts a value/glyph has NO
   variation across its placements (e.g. "single-tone", "plain", "no per-instance
   override") is a stronger, narrower claim than a bare sibling grouping — verifying it
   from only ONE individually-read instance is insufficient evidence for a universal
   claim. This specific claim-shape is a **blocking** fail unless at least TWO
   independently-read instances (or an explicit "only one instance exists" note) back it.

7. **Page-inventory gate** (`validate-checkpoint-page-inventory.sh <live-pages-file>
<draft-file>`) — for tickets flagged as requiring document-wide coverage (per §10's
   coverage-scope test): immediately before running this gate, the orchestrator makes
   its OWN fresh `figma.root.children` call (via `use_figma` — never trusts the
   analyst's self-reported page list) and saves the raw JSON result to a scratch file
   (e.g. `.claude/tmp/live-pages-<JIRA-KEY>.json`); the script then diffs every page
   name in that file against the draft's coverage-inventory page list. Any live page
   absent from the draft's table is a **blocking** fail, regardless of whether it
   plausibly contains new members — the point is completeness of the LISTING, not a
   judgment call about relevance. Does not run for single-component tickets (§10
   already exempts them from document-wide coverage entirely).

**On any BLOCKING gate failing:** do not present the checkpoint yet. Re-verify each
flagged item against the real source (never from memory), correct the draft, re-run the
gate until it passes. Gate 5's warn tier and gate 6's WARN tier (the base sibling-coverage flag) do not block
the checkpoint by themselves — treat gate 5's warns as a prompt to add the missing tag,
and gate 6's coverage warns as a prompt to check or document, before presenting; neither
is a hard stop. Gate 6's BLOCK escalation (a "no variation" claim backed by fewer than
two individually-read instances) and gate 7 are hard stops, same as gates 1–4. **Scope
boundary, honest:** these gates check MECHANICAL properties (citation present, value
present, deeper tool called on the right node-id, tags internally consistent, sibling
instances individually read) — none of them verify that a cited/tagged/extracted value
is itself CORRECT. That remains human/tool-call verification.

**A residual gap no gate can close, named honestly rather than forced into a mechanical
answer:** a styled value that is never written down in ANY claim-shaped form — not
cited, not tagged, folded into vague prose instead of its own citable line — cannot be
caught by any of the seven gates above, because a gate can only check text that was
actually written; it has no ground truth for what SHOULD have been written. A real
incident: an accordion Active-state border's true value (a gradient to transparent) was
incidentally present in a transcript response the whole time, but got folded into a
generic, untagged sentence instead of its own `[Verify-node:]`-backed claim — invisible
to gate 5 because the sentence never looked like a verification claim at all. **"All seven
gates pass" must never be read as "every value was correctly extracted" or "every
per-instance override was checked"** — it means the claims that were written down are
internally consistent with the transcript, nothing more. Closing this specific residual
is a human/controller full-re-read responsibility, not a gate's.
