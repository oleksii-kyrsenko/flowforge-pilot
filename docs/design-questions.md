# Design questions

The single journal of design discrepancies and their fates (English only). Only the agent writes here, always inside the PR that causes the change. Resolved questions are never deleted — the status line is the history. Transport to the designer = `/design-fixes export`.

Status legend: ⏳ open (asked) · ✅ resolved (answer → PR) · ✅ as-designed · 🚫 wontfix.

Node-link files: Components = `JFKSRWAuZTSR4nUMNKe0Gn`, Website = `FlWYwSHj7vtd487hdXZi6t`.

> **Hidden-layer note (per design-extraction skill §2):** values found only on hidden Figma layers are never tokenized — they are recorded here as questions. See Q7 (`#ff3d2e`) and Q8 (`#ffc700`).

---

## Baseline (GUIDE Prompt B, verbatim) — opened 2026-06-12

1. **`Background/80%` and `Background/100%` are the same value.** Both Figma variables resolve to `#080c0f` — the names imply different opacities but the values are identical. → tokenized once as `--color-background-dark`.
   Options: (a) keep both identical · (b) `80%` should be a lower-opacity variant · (c) collapse to one token.
   Status: ⏳ open (asked 2026-06-12)

2. **Three near-match oranges.** `Primary` [`#e98c00`](https://www.figma.com/design/JFKSRWAuZTSR4nUMNKe0Gn/Components?node-id=2-106) vs button-normal-gradient-end [`#e97000`](https://www.figma.com/design/JFKSRWAuZTSR4nUMNKe0Gn/Components?node-id=2-53) vs press-gradient-start [`#e5a500`](https://www.figma.com/design/JFKSRWAuZTSR4nUMNKe0Gn/Components?node-id=2-57). Kept as-is.
   Options: (a) all intentionally distinct · (b) `Primary` should equal one gradient stop (which?).
   Status: ⏳ open (asked 2026-06-12)

3. **`gradient-text-white` stop positions drift.** `0% → 100%` on menu/buttons ([`2:80`](https://www.figma.com/design/JFKSRWAuZTSR4nUMNKe0Gn/Components?node-id=2-80)) vs `0.69% → 100.69%` on the 32px heading ([`1:605`](https://www.figma.com/design/FlWYwSHj7vtd487hdXZi6t/Website?node-id=1-605)). Tokenized once at `0%/100%`.
   Options: (a) one token (0%/100%) · (b) two distinct gradients.
   Status: ⏳ open (asked 2026-06-12)

4. **Two near-match text-shadows.** Button label `0px 1px 3px rgba(0,0,0,0.25)` ([`2:54`](https://www.figma.com/design/JFKSRWAuZTSR4nUMNKe0Gn/Components?node-id=2-54)) vs "Read More" label `0px 1px 4px rgba(0,0,0,0.25)` ([`2:114`](https://www.figma.com/design/JFKSRWAuZTSR4nUMNKe0Gn/Components?node-id=2-114)) — differ only in blur (3 vs 4). Kept as `--text-shadow-sm` / `--text-shadow-md`.
   Options: (a) unify to one · (b) keep both.
   _FF-8 `/review` note (2026-06-13): the outline "Read More" label is rendered with `background-clip:text` + `color:transparent` (its white→white/40 gradient label). A `text-shadow` on transparent glyphs paints as a soft halo around/through the letters rather than a true glyph drop-shadow — so the answer should also confirm whether the outline label keeps a text-shadow at all (and at which blur). Tied to Q3 (the label gradient) and Q20 (outline states)._
   Status: ⏳ open (asked 2026-06-12)

5. **Inconsistent corner radii.** Most controls are sharp `0px` ([`2:53`](https://www.figma.com/design/JFKSRWAuZTSR4nUMNKe0Gn/Components?node-id=2-53)); Apple Pay button is `8px` ([`62:673`](https://www.figma.com/design/FlWYwSHj7vtd487hdXZi6t/Website?node-id=62-673)) and car-photo masks ~`5px` ([`62:945`](https://www.figma.com/design/FlWYwSHj7vtd487hdXZi6t/Website?node-id=62-945)); `13px` not found. Tokenized `--radius-image: 5px`, `--radius-control: 8px` (⚠ pending).
   Options: (a) intended radius system (which elements round?) · (b) controls should all be sharp (Apple Pay is vendor-styled) · (c) all rounded to one value.
   Status: ⏳ open (asked 2026-06-12)

6. **Motion easing.** Durations are resolved (`0.3s` hover/transition → `--duration-base: 300ms`; `1.2s` = Banner auto-advance, kept in the Banner spec). Only **easing curves** are still unknown, and the hero reveal / logo / headlights remain complex animations.
   Options: provide easing (e.g. `ease-out`, custom cubic-bezier) for the 0.3s transitions and the 1.2s banner advance.
   Status: ⏳ open (asked 2026-06-12)

7. **`#ff3d2e` exists only on hidden layers.** Found on hidden "Title" nodes [`62:2065`](https://www.figma.com/design/FlWYwSHj7vtd487hdXZi6t/Website?node-id=62-2065) and [`62:2073`](https://www.figma.com/design/FlWYwSHj7vtd487hdXZi6t/Website?node-id=62-2073) (under hidden ancestors), page "All". The only **rendered** error red is the form `#ff5c00` ([`2:223`](https://www.figma.com/design/JFKSRWAuZTSR4nUMNKe0Gn/Components?node-id=2-223)). Not tokenized (hidden-layer rule).
   Options: (a) `#ff3d2e` is deprecated — ignore · (b) it is the upcoming error color — replace `#ff5c00` · (c) both are valid for different cases.
   Status: ⏳ open (asked 2026-06-12)

8. **`#ffc700` (rating-star yellow) has disappeared.** Present in the 2026-06-11 revision (~84 uses, rating stars); **zero occurrences today** in both files (hidden layers included) — the design changed between runs. No rating/star UI exists in the current design. Not tokenized.
   Options: (a) the rating UI is permanently removed — drop · (b) it is temporarily hidden and returning — recreate `#ffc700` when it does.
   Status: ⏳ open (asked 2026-06-12)

9. **Booking status-badge palette — confirm as canonical tokens.** Five border+fill pairs on My Bookings: New `#54a8d7` ([`62:2128`](https://www.figma.com/design/FlWYwSHj7vtd487hdXZi6t/Website?node-id=62-2128)), Completed `#008f28` ([`62:2158`](https://www.figma.com/design/FlWYwSHj7vtd487hdXZi6t/Website?node-id=62-2158)), Accepted `#bba145` ([`62:2188`](https://www.figma.com/design/FlWYwSHj7vtd487hdXZi6t/Website?node-id=62-2188)), Declined `#953c3c` ([`62:2220`](https://www.figma.com/design/FlWYwSHj7vtd487hdXZi6t/Website?node-id=62-2220)), Canceled `#7c7c7c` ([`62:2250`](https://www.figma.com/design/FlWYwSHj7vtd487hdXZi6t/Website?node-id=62-2250)). Tokenized as `--color-status-*`.
   Options: (a) confirm names/values · (b) adjust any value or add statuses.
   Status: ⏳ open (asked 2026-06-12)

10. **Additional font families.** `Proxima Nova` on password fields ([`62:1242`](https://www.figma.com/design/FlWYwSHj7vtd487hdXZi6t/Website?node-id=62-1242)) and `SF Pro Text` on the Apple Pay button ([`62:674`](https://www.figma.com/design/FlWYwSHj7vtd487hdXZi6t/Website?node-id=62-674)); everything else is Poppins.
    Options: (a) Apple Pay SF Pro is Apple-mandated (keep); password should be Poppins (fix) · (b) both intentional · (c) other.
    Status: ⏳ open (asked 2026-06-12)

11. **Footer gradient alpha near-match.** Footer surface `rgba(255,255,255,0.02)` ([`62:1118`](https://www.figma.com/design/FlWYwSHj7vtd487hdXZi6t/Website?node-id=62-1118)) vs the glass surface `rgba(255,255,255,0.05)` ([`2:94`](https://www.figma.com/design/JFKSRWAuZTSR4nUMNKe0Gn/Components?node-id=2-94)). Kept as distinct `--gradient-surface-footer` / `--gradient-surface-glass`.
    Options: (a) distinct (keep) · (b) should be the same surface token.
    Status: ⏳ open (asked 2026-06-12)

12. **Sub-pixel stroke widths.** File-upload drop-zones use `0.668px` ([`62:1259`](https://www.figma.com/design/FlWYwSHj7vtd487hdXZi6t/Website?node-id=62-1259)) and `0.734px` ([`62:1267`](https://www.figma.com/design/FlWYwSHj7vtd487hdXZi6t/Website?node-id=62-1267)) vs the standard `1px` borders elsewhere.
    Options: (a) normalize all to `1px` · (b) intentional thin strokes (keep).
    Status: ⏳ open (asked 2026-06-12)

13. **Gray `#7c7c7c` ≈ census `#7b7b7b`; divider color unverified.** Badge "Canceled" border is `#7c7c7c` ([`62:2250`](https://www.figma.com/design/FlWYwSHj7vtd487hdXZi6t/Website?node-id=62-2250)); the independent census reported `#7b7b7b` (near-match). Divider "Line 2" ([`62:2886`](https://www.figma.com/design/FlWYwSHj7vtd487hdXZi6t/Website?node-id=62-2886)) renders gray but its exact value was not exposed by `get_design_context`.
    Options: (a) `#7c7c7c` is canonical (census rounded) · (b) confirm the exact divider color value.
    Status: ⏳ open (asked 2026-06-12)

14. **Backdrop blur `20px`.** Confirmed via Plugin-API census on 14 nodes (e.g. Website [`1:1026`](https://www.figma.com/design/FlWYwSHj7vtd487hdXZi6t/Website?node-id=1-1026), Components [`2:44`](https://www.figma.com/design/JFKSRWAuZTSR4nUMNKe0Gn/Components?node-id=2-44)) — glass header / modal backdrop. Tokenized as `--blur-glass: 20px`. (`get_design_context` does not expose effect blur; the Plugin-API census resolved it.)
    Status: ✅ resolved 2026-06-12 — confirmed real, tokenized as `--blur-glass` → this PR.

15. **Spacing near-pairs.** `13px` menu-item gap ([`2:78`](https://www.figma.com/design/JFKSRWAuZTSR4nUMNKe0Gn/Components?node-id=2-78)) vs established `12px` input padding; `30px` card↔image gap ([`1:603`](https://www.figma.com/design/FlWYwSHj7vtd487hdXZi6t/Website?node-id=1-603)) vs established `32px` card padding. Kept as-is (`--spacing-menu-gap`, `--spacing-card-img-gap`, ⚠ pending). (`11/12` and `37` are justified distinct roles, not flagged.)
    Options: (a) unify `13→12` and `30→32` · (b) intentionally distinct (keep).
    Status: ⏳ open (asked 2026-06-12)

16. **Letter-spacing `1.82px`.** Tracking on car-card mask text ([`62:1944`](https://www.figma.com/design/FlWYwSHj7vtd487hdXZi6t/Website?node-id=62-1944)); the only non-default letter-spacing found. Tokenized as `--tracking-mask`.
    Options: (a) intentional tracking token (keep) · (b) drop / round.
    Status: ⏳ open (asked 2026-06-12)

---

## FF-8 Button (`/spec`) — opened 2026-06-13

17. **No `disabled` button variant exists in Figma.** The swatch sheet ([`2:51`](https://www.figma.com/design/JFKSRWAuZTSR4nUMNKe0Gn/Components?node-id=2-51)) shows only Normal / Hover / Press / Active — no disabled rendering. The spec proposes label at `--color-on-dark-40` + non-interactive, but the actual disabled appearance (desaturated gradient? reduced opacity? flat fill?) is undefined.
    Options: (a) confirm the proposed reduced-opacity-label treatment · (b) provide a disabled Figma variant · (c) buttons are never disabled in this product.
    _FF-8 `/review` note (2026-06-13) — deliberate spec↔code divergence: the implementation uses `disabled:opacity-50` (uniform dim), NOT the spec's `--color-on-dark-40` label color, because the outline variant renders its label via `background-clip:text` (transparent text), so a per-variant text-color swap can't apply there. The approved spec **intentionally retains `--color-on-dark-40` as the intended design** (not rewritten); the divergence is recorded here and will be reconciled when Q17 is answered via `/design-fixes`._
    Status: ⏳ open (asked 2026-06-13)

18. **No focus-visible ring in Figma.** A visible focus indicator is required by a11y / AC5, but the mockup defines none. Spec proposes a `2px` `--color-primary` (#e98c00) ring with offset, on `:focus-visible` only.
    Options: (a) confirm the proposed ring color/width · (b) specify a different focus indicator.
    Status: ⏳ open (asked 2026-06-13)

19. **Wide-CTA horizontal padding `24px` has no token.** The "Book Now" CTA ([`1:598`](https://www.figma.com/design/FlWYwSHj7vtd487hdXZi6t/Website?node-id=1-598)) uses `px-24`, while standard buttons use `px-16` (`--spacing-control`). 24px has no existing spacing token and no defined role.
    Options: (a) standardize all buttons to 16px (24px is incidental) · (b) 24px is an intentional "large CTA" padding → mint a token / add a size variant.
    Status: ⏳ open (asked 2026-06-13)

20. **Outline ("Read More") hover/press states render identical.** Normal/Hover/Press instances ([`2:114`](https://www.figma.com/design/JFKSRWAuZTSR4nUMNKe0Gn/Components?node-id=2-114) / [`2:115`](https://www.figma.com/design/JFKSRWAuZTSR4nUMNKe0Gn/Components?node-id=2-115) / [`2:116`](https://www.figma.com/design/JFKSRWAuZTSR4nUMNKe0Gn/Components?node-id=2-116)) show the same border/fill/label via `get_design_context`; no distinguishing change was exposed.
    Options: (a) outline has no hover/press change (single state) · (b) provide the intended outline hover/press treatment (e.g. border → `--color-gold-hover-start`).
    Status: ⏳ open (asked 2026-06-13)

---

## FF-9 Icon (`/spec`) — opened 2026-06-15

21. **`plus` icon frame is 23.49×23.49, not the 24×24 used by every other icon.** Five correlated instances all render 23.49px: [`62:1268`](https://www.figma.com/design/FlWYwSHj7vtd487hdXZi6t/Website?node-id=62-1268), [`62:1477`](https://www.figma.com/design/FlWYwSHj7vtd487hdXZi6t/Website?node-id=62-1477), [`62:2427`](https://www.figma.com/design/FlWYwSHj7vtd487hdXZi6t/Website?node-id=62-2427). All other icons (chevron-left [`1:774`](https://www.figma.com/design/FlWYwSHj7vtd487hdXZi6t/Website?node-id=1-774), chevron-down [`1086:514`](https://www.figma.com/design/FlWYwSHj7vtd487hdXZi6t/Website?node-id=1086-514), x-close `62:1673`, check `62:1869`, calendar `62:2713`, clock `62:2726`) are exactly 24×24. Near-match (Δ0.51px) — kept as-is, treated as 24 in the registry pending answer.
    Options: (a) `plus` should be 24×24 like the rest (the 23.49 is incidental scaling) · (b) 23.49 is intentional — provide the canonical plus size.
    Status: ⏳ open (asked 2026-06-15) — **INFORMATIONAL, not a build blocker** (FF-9 `/build` 2026-06-15): the `plus` glyph ships verbatim — its exported `<svg>` root is `viewBox="0 0 24 24"` (a square box) with the glyph drawn inset/smaller and stroke-width `1.46813`. The Icon contract preserves natural geometry, so no normalization was needed. Open only as a future "should the glyph fill the 24 box?" design choice, resolvable via `/design-fixes`.

22. **`edit` icon is non-square (16×14.07) and named `edit-02`, breaking the 24×24 square convention.** Figma node [`62:2292`](https://www.figma.com/design/FlWYwSHj7vtd487hdXZi6t/Website?node-id=62-2292) / master `62:679`. The ticket calls it "edit"; Figma calls it "edit-02"; its frame is 16×14.07, not a 24×24 square like the other 7 icons.
    Options: (a) provide a 24×24 square `edit` matching the set · (b) `edit-02` is the intended asset and is meant to render smaller/non-square (confirm the canonical size) · (c) rename the registry key to `edit-02` to match Figma.
    Status: ⏳ open (asked 2026-06-15) — **INFORMATIONAL, not a build blocker** (FF-9 `/build` 2026-06-15): `edit` ships verbatim — its exported `<svg>` root is `viewBox="0 0 16 15"` (non-square), stroke-width `1.5`. The Icon contract preserves natural aspect (the `edit` glyph renders ~16:15, not 24×24); the registry key stays `edit`. Open only as a future naming/size design choice, resolvable via `/design-fixes`.

23. **Icon size scale undefined — three observed sizes, no token.** Observed: 24 (baseline, most icons), ~20 (scaled calendar instances [`62:3059`](https://www.figma.com/design/FlWYwSHj7vtd487hdXZi6t/Website?node-id=62-3059), [`62:3066`](https://www.figma.com/design/FlWYwSHj7vtd487hdXZi6t/Website?node-id=62-3066) at 20.21×20), 16 (edit-02). No Figma variable binds icon size (`get_variable_defs` → `{}`). Proposed scale `--size-icon-sm:16 / -md:20 / -icon:24` (⚠ pending).
    Options: (a) confirm the 16/20/24 scale · (b) provide the canonical icon size set · (c) icons are 24-only and the 16/20 are incidental scaling.
    Status: ⏳ open (asked 2026-06-15)

24. **Icon stroke width / corner radius not extractable.** ~~The Figma MCP returns icons as flattened raster `<img>` assets, so stroke weight and any rounding are not exposed for any of the 8 icons.~~ **[Premise disproven — see status.]**
    Options: (a) confirm icons are stroke-based and provide the canonical stroke width (e.g. 1.5px / 2px) · (b) icons are fill-based (no stroke token needed) · (c) export the icon set as SVG source so geometry can be read directly.
    Status: ✅ resolved 2026-06-15 (FF-9 `/build`; engine fix → PR #20, design-extraction §9 v3.48) — the original premise was WRONG. Vector IS retrievable via `download_assets` `format:"svg"` on the placed-instance node; all 8 glyphs were extracted verbatim with real path data and per-icon stroke-widths (chevron-left/down + x-close = `2`, check = `3`, clock/calendar/edit = `1.5`, plus = `1.46813`). The "flattened raster" reading was a `get_design_context` artifact (that tool returns a raster `<img>` reference for icons; `download_assets` svg does not). **Real residual limit:** the `plus`/`edit` MASTER nodes (`62:659`, `62:679`) return `export: null`, so only their scaled/non-square placed instances are reachable — which is why `plus` ships with an inset glyph and `edit` ships non-square (16×15). Not a raster limitation.
