# FF-8 — Button primitive (ui)

> Component specification produced by the FlowForge analyst from Jira **FF-8** + Figma. All values verbatim from Figma; tokens reused from the approved baseline (`docs/design-tokens.md`). Pending human approval (hard rule 2) before `/build`.
>
> **Sources:** ticket frame instance — Website [`1:598`](https://www.figma.com/design/FlWYwSHj7vtd487hdXZi6t/Website?node-id=1-598&m=dev). State variants — Components file `JFKSRWAuZTSR4nUMNKe0Gn`, swatch sheet `2:51`.

## 1. Purpose

A single reusable `Button` primitive so every CTA across the site shares one styled, accessible, token-driven implementation. Figma exposes two visual styles for this primitive: a **filled gradient CTA** (the dominant orange call-to-action — "Book Now", "Send", "View All") and an **outline/secondary** button (the bordered "Read More" style with a white→transparent gradient label). The primitive renders as a native `<button>` by default and optionally as a link element for navigation CTAs (`asChild`), exposes its visual variants, and reproduces the interaction states diffed from the style-guide swatch sheet (default / hover / press / focus-visible / disabled), consuming only existing design tokens.

## 2. Typed props

Variants matched to **what actually CHANGES in Figma**, not by layer names: the gradient-fill family (`2:53/2:55/2:57`) vs. the bordered transparent-fill family (`2:114`).

```ts
import type { ButtonHTMLAttributes, ReactNode } from "react";

export type ButtonVariant = "filled" | "outline";

export interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  /** Visual style. `filled` = orange gradient CTA (Figma 2:53);
   *  `outline` = 2px orange border, transparent fill, gradient label ("Read More", 2:114). */
  variant?: ButtonVariant; // default: 'filled'
  /** Render as a child element (e.g. next/link <a>) instead of <button>,
   *  preserving role/keyboard semantics. Used for navigation CTAs. */
  asChild?: boolean; // default: false
  /** Disabled state — no disabled variant exists in Figma (see Design questions, Q17).
   *  Proposed: reduced-opacity label via --color-on-dark-40 + non-interactive. */
  disabled?: boolean;
  children: ReactNode;
}
```

Notes:

- **No `size` prop.** Figma instances vary only in label and horizontal padding (16px on "Send"/"Read More", 24px on the wide "Book Now" CTA at `1:598`); height is a static 48px. Width is content-driven (observed ≈74–163px). A discrete size scale would be a behavior decision → Q19.
- **No `loading` state** appears anywhere in the Figma swatch sheet — not added (would be invented behavior).
- Standard button attributes (`type`, `onClick`, `aria-*`) flow through via `ButtonHTMLAttributes`.

## 3. States

Diffed by **what changes between the swatch variants**, not by their labels. Source: Components swatch sheet `2:51`.

| State                       | What changes (verbatim from Figma)                                                                                                                                                                                             | Tokens                                                         | Source node                                                                                                                                                                        |
| --------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | -------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **default** (filled)        | Fill `--gradient-primary` (`#ffb800`→`#e97000`, 180deg); drop-shadow `0px 4px 8px rgba(0,0,0,0.15)`; white uppercase Poppins-Bold label, label shadow `0px 1px 3px`; radius 0px                                                | `--gradient-primary`, `--shadow-button`, `--text-shadow-sm`    | [`2:53`](https://www.figma.com/design/JFKSRWAuZTSR4nUMNKe0Gn/Components?node-id=2-53), label [`2:54`](https://www.figma.com/design/JFKSRWAuZTSR4nUMNKe0Gn/Components?node-id=2-54) |
| **hover** (filled)          | Fill swaps to `--gradient-primary-hover` (`#ffc533`→`#ed8d33`); shadow + label shadow unchanged                                                                                                                                | `--gradient-primary-hover`                                     | [`2:55`](https://www.figma.com/design/JFKSRWAuZTSR4nUMNKe0Gn/Components?node-id=2-55)                                                                                              |
| **press / active** (filled) | Fill swaps to `--gradient-primary-press` (`#e5a500`→`#d16500`). Figma "Active" (`2:72`,`2:73`) shares the press visual — active == pressed                                                                                     | `--gradient-primary-press`                                     | [`2:57`](https://www.figma.com/design/JFKSRWAuZTSR4nUMNKe0Gn/Components?node-id=2-57)                                                                                              |
| **focus-visible**           | No focus variant in Figma. Spec mandates a visible ring (a11y, AC5). Proposed: `2px` ring in `--color-primary` (#e98c00) with offset, `:focus-visible` only                                                                    | `--color-primary`                                              | — (Q18)                                                                                                                                                                            |
| **disabled**                | No disabled variant in Figma. Proposed: label drops to `--color-on-dark-40`, pointer-events none, no shadow                                                                                                                    | `--color-on-dark-40`                                           | — (Q17)                                                                                                                                                                            |
| **default** (outline)       | `border-2` solid `--color-primary` (#e98c00); transparent fill; label is white→`rgba(255,255,255,0.4)` 90deg gradient (`--gradient-text-white`), Poppins-SemiBold, label shadow `0px 1px 4px` (`--text-shadow-md`); radius 0px | `--color-primary`, `--gradient-text-white`, `--text-shadow-md` | [`2:114`](https://www.figma.com/design/JFKSRWAuZTSR4nUMNKe0Gn/Components?node-id=2-114)                                                                                            |

**Outline hover/press:** "Read More" Normal/Hover/Press (`2:114/2:115/2:116`) render visually identical in `get_design_context` — no distinguishing change exposed. Treated as a single rendered state pending confirmation → Q20.

## 4. Breakpoints

Button is **size-static** — height 48px, content-driven width, identical token set at both baseline widths.

- `--breakpoint-mobile` 360px and `--breakpoint-desktop` 1440px: no variant change; label stays `whitespace-nowrap` per Figma.
- No full-width usage is defined in the Button frames; full-width is a consumer-layout concern (parent passes `className`), not a Button variant. The primitive does not hard-code width.

## 5. Design tokens

All tokens **reused** from the approved baseline (`docs/design-tokens.md` ↔ `@theme` in `src/app/globals.css`). No raw values in component code.

| Theme key                                       | Raw value                                                | Provenance node                                                                                                                                                                  | Used for                                                 |
| ----------------------------------------------- | -------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------- |
| `--gradient-primary`                            | `linear-gradient(180deg, #ffb800, #e97000)`              | [`2:53`](https://www.figma.com/design/JFKSRWAuZTSR4nUMNKe0Gn/Components?node-id=2-53)                                                                                            | filled default fill                                      |
| `--gradient-primary-hover`                      | `linear-gradient(180deg, #ffc533, #ed8d33)`              | [`2:55`](https://www.figma.com/design/JFKSRWAuZTSR4nUMNKe0Gn/Components?node-id=2-55)                                                                                            | filled hover fill                                        |
| `--gradient-primary-press`                      | `linear-gradient(180deg, #e5a500, #d16500)`              | [`2:57`](https://www.figma.com/design/JFKSRWAuZTSR4nUMNKe0Gn/Components?node-id=2-57)                                                                                            | filled press/active fill                                 |
| `--shadow-button`                               | `0px 4px 8px rgba(0,0,0,0.15)`                           | [`2:53`](https://www.figma.com/design/JFKSRWAuZTSR4nUMNKe0Gn/Components?node-id=2-53)                                                                                            | filled drop shadow                                       |
| `--text-shadow-sm`                              | `0px 1px 3px rgba(0,0,0,0.25)`                           | [`2:54`](https://www.figma.com/design/JFKSRWAuZTSR4nUMNKe0Gn/Components?node-id=2-54)                                                                                            | filled label shadow                                      |
| `--text-shadow-md` ⚠ pending (Q4)               | `0px 1px 4px rgba(0,0,0,0.25)`                           | [`2:114`](https://www.figma.com/design/JFKSRWAuZTSR4nUMNKe0Gn/Components?node-id=2-114)                                                                                          | outline label shadow                                     |
| `--color-primary`                               | `#e98c00`                                                | [`2:114`](https://www.figma.com/design/JFKSRWAuZTSR4nUMNKe0Gn/Components?node-id=2-114), [`2:106`](https://www.figma.com/design/JFKSRWAuZTSR4nUMNKe0Gn/Components?node-id=2-106) | outline border + focus ring                              |
| `--gradient-text-white` ⚠ pending (Q3)          | `linear-gradient(90deg, #ffffff, rgba(255,255,255,0.4))` | [`2:80`](https://www.figma.com/design/JFKSRWAuZTSR4nUMNKe0Gn/Components?node-id=2-80), [`2:114`](https://www.figma.com/design/JFKSRWAuZTSR4nUMNKe0Gn/Components?node-id=2-114)   | outline label gradient (bg-clip-text)                    |
| `--color-on-dark-40`                            | `rgba(255,255,255,0.4)`                                  | derived from styles                                                                                                                                                              | disabled label (proposed)                                |
| `--spacing-btn-y`                               | `11px`                                                   | [`2:53`](https://www.figma.com/design/JFKSRWAuZTSR4nUMNKe0Gn/Components?node-id=2-53)                                                                                            | vertical padding                                         |
| `--spacing-control`                             | `16px`                                                   | swatch instances                                                                                                                                                                 | horizontal padding (standard)                            |
| `--font-poppins`                                | `"Poppins", …`                                           | swatch labels                                                                                                                                                                    | label family                                             |
| `--font-weight-bold` / `--font-weight-semibold` | `700` / `600`                                            | [`2:54`](https://www.figma.com/design/JFKSRWAuZTSR4nUMNKe0Gn/Components?node-id=2-54) / [`2:114`](https://www.figma.com/design/JFKSRWAuZTSR4nUMNKe0Gn/Components?node-id=2-114)  | filled / outline label weight                            |
| `--text-base` (16px) / `--text-h4` (20px)       | `16px` / `20px`                                          | `2:56` / [`1:598`](https://www.figma.com/design/FlWYwSHj7vtd487hdXZi6t/Website?node-id=1-598&m=dev)                                                                              | label size (16 standard; 20 wide CTA)                    |
| `--duration-base`                               | `300ms`                                                  | prototype reactions                                                                                                                                                              | state transition                                         |
| radius `0px` ⚠ pending (Q5)                     | `0px`                                                    | [`2:53`](https://www.figma.com/design/JFKSRWAuZTSR4nUMNKe0Gn/Components?node-id=2-53)                                                                                            | sharp corners (`--radius-control` 8px is Apple-Pay-only) |

**Pending-token dependencies (must not be resolved silently):** `--text-shadow-md` (Q4), `--gradient-text-white` (Q3), sharp `0px` radius (Q5). Existing OPEN questions — referenced, not duplicated.

**Horizontal padding:** Figma shows `16px` on standard instances (matches `--spacing-control` exactly → reuse) and `24px` on the wide "Book Now" CTA (`1:598`), which has no exact token → Q19.

### Proposed token additions

**None.** All state fills/shadows/colors/spacing reused from the map. The only candidate (24px wide-CTA padding) is raised as a design question (Q19) rather than minted, since it has no clear semantic role and 16px covers the standard case.

## 6. Animations

- **Trigger:** `:hover` and `:active` (press) on the filled variant.
- **Property:** `background` (gradient swap default→hover→press) — CSS transition only.
- **Motion token:** `--duration-base` (300ms), matching the 0.3s prototype-reaction census.
- **Easing:** UNCONFIRMED — existing OPEN **Q6** covers easing curves for the 0.3s transitions. Use `ease-out` at build time, update when Q6 resolves.
- Not complex — plain CSS transition, no human-decision flag required.

## 7. Reuse check

Scanned `src/components/ui/` (only `.gitkeep` — empty) and `docs/specs/` (no prior specs). **No existing primitive to reuse.**

**Button is a NEW `ui/` primitive → requires explicit human approval** before `/build` (per CLAUDE.md §11 "Reuse check"). Proposed location: `src/components/ui/Button.tsx` + co-located `Button.test.tsx` + `index.ts`. This is the shared-primitive ticket the backlog depends on (FF-9…FF-22 reuse it).

## 8. a11y requirements

- Renders a native `<button>` by default; `asChild` renders the provided element (e.g. `next/link` `<a>`) while preserving an interactive role and keyboard operability (Enter/Space for button; Enter for link).
- **Accessible name** comes from `children`; icon-only usage (none in current mockups) would require `aria-label`.
- **focus-visible:** visible 2px ring in `--color-primary` on `:focus-visible` only (not mouse focus), with offset for contrast against dark backgrounds (Q18).
- **disabled:** native `disabled` on `<button>`; for `asChild` links, apply `aria-disabled="true"` + `tabIndex={-1}` + prevent activation.
- **Contrast:** label legibility supported by the text-shadow tokens; reviewer confirms WCAG AA at build.
- Keyboard: fully operable without a pointer; no keyboard trap.

## 9. Acceptance criteria

Mapped 1:1 to FF-8's existing acceptance criteria (each testable):

- [ ] **AC1** — Variants cover what changes between mockup instances: `filled` (orange gradient CTA, `2:53`) and `outline`/secondary (bordered transparent-fill "Read More", `2:114`).
- [ ] **AC2** — States default / hover / press / focus-visible / disabled implemented, diffed from the swatch set (gradient swap for filled; border + gradient label for outline) — not by variant names.
- [ ] **AC3** — Size matches observed dimensions (height 48px; width content-driven ≈74–163px); padding and radius from design tokens (`--spacing-btn-y`, `--spacing-control`, sharp `0px`) — no raw values.
- [ ] **AC4** — Renders as a `<button>` by default; supports `asChild`/link rendering for navigation CTAs.
- [ ] **AC5** — Keyboard-operable, visible focus ring on `:focus-visible`, accessible name from children.
- [ ] **AC6** — Unit tests cover each variant and each state plus a11y basics.

## 10. Test plan

Button is a **leaf primitive → unit tests only** (Vitest + React Testing Library + jsdom). No integration or e2e for this ticket (no multi-component data flow, no user journey). Co-located `src/components/ui/Button.test.tsx`. Every acceptance criterion maps to ≥1 test (title references the criterion):

- **AC1** — renders `filled` and `outline` with the correct token-backed classes; default variant is `filled`.
- **AC2** — hover/press class application (gradient swap) on filled; outline border + gradient-label classes; `:focus-visible` ring; disabled styling/attribute.
- **AC3** — no raw color/spacing literals in markup (token classes only); height/padding classes present.
- **AC4** — renders `<button>` by default; `asChild` renders the passed child (e.g. `<a>`) and forwards props; `onClick` fires.
- **AC5** — focusable via keyboard, Enter/Space activates, accessible name resolves from children, focus-visible ring present; disabled is non-interactive and out of tab order.
- **AC6** — coverage assertion that all variants × states are exercised.

## 11. Design questions

**Existing OPEN questions that already affect Button (referenced, not duplicated):**

- **Q2** — three near-match oranges (`#e98c00` Primary vs `#e97000` gradient-end vs `#e5a500` press-start); the Button consumes all three.
- **Q3** — `--gradient-text-white` stop positions drift; the outline label gradient consumes this pending token.
- **Q4** — button-label `--text-shadow-sm` (blur 3) vs "Read More" `--text-shadow-md` (blur 4); the outline variant depends on pending `--text-shadow-md`.
- **Q5** — control corner radii: Button is sharp `0px`; depends on the pending radius decision.
- **Q6** — easing curves for the 0.3s (`--duration-base`) transitions are unknown; the Button hover/press animation depends on it.

**New questions raised by this spec (Q17–Q20)** — see `docs/design-questions.md`:

- **Q17** — no `disabled` variant exists in Figma; disabled appearance undefined.
- **Q18** — no focus-visible ring in Figma; a11y requires one (proposed `2px --color-primary`).
- **Q19** — wide-CTA horizontal padding `24px` (`1:598`) has no token vs standard `16px`.
- **Q20** — outline "Read More" hover/press render identical; intended state change unconfirmed.
