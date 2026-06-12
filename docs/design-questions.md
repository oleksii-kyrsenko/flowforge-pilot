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
