# Specification — FF-8: Button primitive (ui)

## Purpose

A single, shared, polymorphic `Button` primitive that every button-like CTA on the site consumes. It owns two orthogonal concerns per the project's Component conventions (CLAUDE.md §11): **appearance** (`variant` prop: `filled` gradient CTA / `outline` bordered secondary) and **element polymorphism** (`as`/`asChild`, so the same styled component renders as a native `<button>`, an `<a>` for navigation, or `input[type="submit"]`, with accessibility correct for whichever element actually renders). This is the first shared UI primitive in the repo — it exists so no future ticket re-implements its own button.

## Typed props

```ts
import type { ComponentPropsWithoutRef, ElementType, ReactNode } from "react";

export type ButtonVariant = "filled" | "outline";

type PolymorphicProps<E extends ElementType> = {
  /** Visual treatment. Default 'filled'. */
  variant?: ButtonVariant;
  /** Native element to render (button | a | input, etc.). Default 'button'. */
  as?: E;
  /** Renders as a Slot around a single custom child (Radix-style) instead of `as`. */
  asChild?: boolean;
  disabled?: boolean;
  className?: string;
  children: ReactNode;
} & Omit<ComponentPropsWithoutRef<E>, "as" | "className" | "children" | "disabled">;

export type ButtonProps<E extends ElementType = "button"> = PolymorphicProps<E>;

export declare function Button<E extends ElementType = "button">(
  props: ButtonProps<E>,
): JSX.Element;
```

- `variant` drives appearance only (`filled` | `outline`); a genuinely different look is a different component per the Component conventions rule — not the case here, both are the same family.
- `as`/`asChild` drive element polymorphism; when `as="a"`, `href` is required by the resulting prop type (via `ComponentPropsWithoutRef<'a'>`); when `as="input"` with a submit usage, `type="submit"` flows through the same way.
- No `size` prop yet — see Design tokens section: only one size preset per variant is in this ticket's observed scope.

## Coverage inventory (component/primitive ticket — scoped per design-extraction skill §10's component carve-out; explicitly NOT a document-wide page sweep)

- **Design-system source consulted for states/variants:** Components file (`JFKSRWAuZTSR4nUMNKe0Gn`), showcase frame `Frame 33738` (node 2:51) — screenshotted directly for visual structure recognition before per-node reads (this was a `get_screenshot` visual-context read, not a flattened-paint resolution, so it carries no `[Verify-node:]` tag). Two button-family panels read via `get_design_context`, each returning exact non-flattened hex/rgba values directly in the generated Tailwind classes (no raster/ambiguous paint involved, so no deeper `get_variable_defs`/`download_assets` call was needed on these specific nodes): **CTA Button/Send** (filled) Normal (node 2:53), Hover (node 2:55), Press (node 2:57); **Read-More** (outline) Normal (node 2:114), Hover (node 2:115), Press (node 2:116). No Focus or Disabled variant exists in either panel — both panels' full state columns were read (3 states each, matching docs/design-tokens.md's existing baseline); this is a confirmed absence, not an unread gap.
- **Ticket's own frames** (Website file, `FlWYwSHj7vtd487hdXZi6t`): filled "BOOK NOW" (node 1:598) and outline "View All Cars" (node 1:772), both on the desktop-width (1440px) top-level `HomePage` frame (node 1:590). `get_variable_defs` was called on both exact nodes: 1:598 → `{"Button/Gradient":""}` [Verify-node: 1:598]; 1:772 → `{"Primary":"#E98C00"}` [Verify-node: 1:772].
- **Responsive counterparts for these exact two instances:** located via `get_metadata` on the ticket file's page (`0:1 Homepage`), which surfaced 4 sibling top-level `HomePage` frames at different widths — 1:590 (1440, ticket's own), 1:806 (1440, a second desktop-width duplicate — **not explored further**, see scoping note below), 1:1024 (360, full mobile homepage), 1:1317 (360, a shorter mobile menu-state frame). The filled button's mobile counterpart is node 1:1034 and the outline button's mobile counterpart is node 1:1249, both inside 1:1024, both confirmed via `get_design_context` as the same content/variant at the mobile width, AND both independently re-verified via `get_variable_defs` on their exact node-ids: 1:1034 → `{"Button/Gradient":""}` [Verify-node: 1:1034]; 1:1249 → `{"Primary":"#E98C00"}` [Verify-node: 1:1249].
- **Scoping boundary respected:** a document-wide sweep of the "Website" file (the second desktop sibling 1:806, the non-button content of 1:1317, or the file's second page `62:497 All`) was **intentionally not performed** — per skill §10's component/primitive carve-out, states/variants authority is the design-system file above, and breakpoint authority is this component's own two instances across the widths the tool surfaced directly tied to them, not a document-wide sweep for breadth's sake.
- **Motion check:** `get_motion_context` run on both ticket instances (nodes 1:598, 1:772) — both returned `motionSummary: null`, no prototype reactions. Consistent with the design-system baseline (no motion documented for any Button-family node in docs/design-tokens.md).

Every "absent/undefined" claim below (no Focus variant, no Disabled variant, no motion) cites this inventory.

## States

Diffed by what CHANGES between the design-system's own variant columns (skill §6), ticket frames provide usage context only:

| State             | `filled` variant                                                                                                                                                                                                                                                                                                                                                                                                              | `outline` variant                                                                                                                                                                                                     |
| ----------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Default (Normal)  | fill `gradient-from` `#FFB800`/`gradient-to` `#E97000` (nodes 1:598, 2:53); drop-shadow `rgba(233,140,0,0.15)` (node 1:598 — see Design tokens); label Poppins Bold 20px uppercase, `text-white` (node 1:598), existing button text-shadow `rgba(0,0,0,0.25)` (node 2:53)                                                                                                                                                     | 2px solid border `border-primary` `#E98C00` (nodes 1:772, 2:114); label Poppins SemiBold 16px, existing nav-text-gradient white→white/40 (node 2:114), existing Read-More text-shadow `rgba(0,0,0,0.25)` (node 2:114) |
| Hover             | fill `gradient-hover-from` `#FFC533`/`gradient-hover-to` `#ED8D33` (node 2:55); shadow unchanged (constant across all 3 states on the Send-button source, mirrored here)                                                                                                                                                                                                                                                      | border → `gradient-hover-from` `#FFC533` as solid (node 2:115); label unchanged (text does not change across states on the Read-More source, node 2:115)                                                              |
| Press (`:active`) | fill `gradient-press-from` `#E5A500`/`gradient-press-to` `#D16500` (node 2:57); shadow unchanged                                                                                                                                                                                                                                                                                                                              | border → `gradient-press-from` `#E5A500` as solid (node 2:116); label unchanged                                                                                                                                       |
| Focus-visible     | **Not present in the Figma source (see Coverage inventory)** — derived: 2px solid ring using the existing `border-primary` token `#E98C00` (already established at node 2:206/2:214, Input focus border, per docs/design-tokens.md), `:focus-visible` only, offset ~2px. Reuses the SAME token's already-established "focus accent" role — not a new/invented value, an ambiguous-intent derivation built now, not a blocker. | Same derivation, same token `#E98C00` (node 2:206/2:214).                                                                                                                                                             |
| Disabled          | **Not present in the Figma source (industry-standard derivation, not a Figma value):** ~40% opacity applied to the existing filled tokens (node 1:598's gradient), drop-shadow removed, no hover/press transitions, `disabled` attribute (native `<button>`) or `aria-disabled="true"` + non-interactive handling when `as="a"`.                                                                                              | Same derivation pattern (opacity reduction on the existing border/text tokens from node 1:772).                                                                                                                       |

Neither absence (Focus-visible, Disabled) blocks the spec — both are literal, low-risk engineering derivations built on already-approved tokens, not fabricated raw values; flagged transparently rather than treated as a hard STOP.

## Breakpoints

Two known mockup widths were read for each variant (1440 desktop / 360 mobile) — every observed difference is classified per skill §12:

- **`filled` variant — CONTINUOUS (no-change / constant).** Identical 163×52 footprint at both known widths (node 1:598, 1440) vs (node 1:1034, 360) — same gradient, same padding, same font-size. No interpolation needed; implement as a fixed-size button (or `clamp()` with equal min/max) unchanged across the full range and beyond both extremes.
- **`outline` variant — DISCRETE (layout-mode switch).** Sizing mode changes from **hug-content** (138px, auto-width) at desktop (node 1:772) to **fill-container** (328px, full available width within the 16px mobile margins) at mobile (node 1:1249); height is constant at 48 in both. This is a discrete sizing-MODE switch (`w-auto` → `w-full`), not a numeric interpolation. **Open design question (does not block, see Q4 below):** only two known points exist (360, 1440) with no evidenced tablet frame — the exact switch threshold is a build-time default pending designer confirmation.

## Design tokens

Deduped against `docs/design-tokens.md` (search-by-value across the whole map, per skill §4), across BOTH frames the ticket carries.

**Completeness note (Tailwind color-keyword classes seen in the raw transcript, addressed explicitly per skill §2):** the outline-variant label is rendered with the technique `bg-clip-text text-transparent bg-gradient-to-r from-white to-[rgba(255,255,255,0.4)]` (nodes 1:772, 1:1249, 2:114, 2:115, 2:116) — `from-white` and `text-[transparent]` are not new/different values, they are the literal Tailwind implementation of the already-recorded "nav text gradient" white→white/40 token applied as gradient-clipped text (transparent text-color + background-clip so the gradient paints through the glyphs). The filled-variant label uses flat `text-white` (solid white fill, not gradient-clipped) on nodes 1:598, 1:1034, 2:53, 2:55, 2:57 — this is the literal class backing the "white" descriptor already used for the filled label above. Both are recorded here explicitly so no extracted value is silently dropped.

**Reused, exact match — no new token:**

- `--color-gradient-from` / `--color-gradient-to` (`#FFB800`/`#E97000`) — filled Normal fill; bound to the `Button/Gradient` Figma variable, confirmed via `get_variable_defs` [Verify-node: 1:598].
- `--color-gradient-hover-from` / `--color-gradient-hover-to` (`#FFC533`/`#ED8D33`) — filled Hover fill (node 2:55).
- `--color-gradient-press-from` / `--color-gradient-press-to` (`#E5A500`/`#D16500`) — filled Press fill (node 2:57).
- `--color-primary` (`#E98C00`) — outline Normal border; bound to the `Primary` Figma variable, confirmed via `get_variable_defs` [Verify-node: 1:772].
- Outline Hover/Press border = `gradient-hover-from` (node 2:115) / `gradient-press-from` (node 2:116) used as solid colors — exact reuse of the existing "Read-More button border pattern".
- Nav text gradient (default) `linear-gradient(90deg, #FFFFFF 0%, rgba(255,255,255,0.4) 100%)` (nodes 2:114, 2:115, 2:116, 1:772) — outline-variant label, unchanged across all 3 states — exact reuse (not Tailwind-themed; arbitrary value per existing baseline). Implementation technique noted in the Completeness note above.
- Read-More text-shadow `0px 1px 4px rgba(0,0,0,0.25)` (node 2:114) — outline-variant label — exact reuse.
- Button text-shadow `0px 1px 3px rgba(0,0,0,0.25)` (node 2:53, confirmed identical on node 1:598) — filled-variant label — exact reuse.
- Typography (outline): Poppins SemiBold 16px (node 2:114) — exact reuse of "Outline button (Read More)".
- Typography (filled): Poppins Bold 20px uppercase (node 1:598) — see "second size preset" note below.
- Corner radii: 0 (square corners) on both variants — no `rounded-*` class present on any read node (1:598, 1:772, 1:1034, 1:1249, 2:53, 2:114); consistent with the existing baseline finding of no non-zero radius.

**New token — open design question, not silently collapsed (full evidence and Role/Component tags below):**

| Token                 | Value                              | Nodes                                                                  |
| --------------------- | ---------------------------------- | ---------------------------------------------------------------------- |
| `--shadow-button-cta` | `0px 4px 8px rgba(233,140,0,0.15)` | 1:598, 1:1034 (status: open, see Design Question Q3 immediately below) |

**Design Question Q3 — Filled/CTA button drop-shadow: orange-tinted vs neutral black**
Evidence: existing baseline token `--shadow-button` = `0px 4px 8px rgba(0,0,0,0.15)` `[Role: button-drop-shadow, Component: Button (filled variant)]`, from the Components-file CTA Button/Send, constant across all 3 of its own states [nodes 2:53, 2:55, 2:57]. This ticket's filled "BOOK NOW" instance shows the identical offset/blur/alpha but an **orange-tinted** color, `0px 4px 8px rgba(233,140,0,0.15)` `[Role: button-drop-shadow, Component: Button (filled variant)]` — confirmed on both its desktop [Verify-node: 1:598] and mobile [Verify-node: 1:1034] placements; `get_variable_defs` on both exact nodes returned only `Button/Gradient` (no bound shadow style/variable), ruling out a flattening artifact.
Figma links: https://www.figma.com/design/JFKSRWAuZTSR4nUMNKe0Gn/Components?node-id=2-53 (neutral source) · https://www.figma.com/design/FlWYwSHj7vtd487hdXZi6t/Website?node-id=1-598 (orange-tinted, this ticket)
Question: is the orange-tinted shadow the deliberate treatment for this hero/marketing filled CTA (a distinct size/context preset from the compact header Send button), or an authoring slip that should match the Send button's neutral shadow?
Status: ⏳ open (asked 2026-07-13). Built AS-IS (orange-tinted, constant across Normal/Hover/Press — mirroring how the Send button's own shadow stays constant across its states) pending this answer — per hard rule, never collapsed silently into `--shadow-button`.

**Second size preset — observation, out of this ticket's build scope (does not qualify as a same-slot comparison, per skill §4):** the Components-file CTA Button/Send (node 2:53) shows a second, smaller size preset (74×48, 16px Bold, px16/py11) for the filled family. Its width (74px) falls below this ticket's declared acceptance-criteria range (≈119–163px, per node 1:598's 163×52) — height/padding/font-size all covary together as one coherent size decision, not independent drift on any single property, so this is recorded as a scoping note, not a design question. This ticket builds only the one observed size (163×52, 20px, px24/py11 for filled, node 1:598; 138×48/328×48, 16px for outline, nodes 1:772/1:1249); a future ticket can extend the primitive with a `size` prop for the compact preset (node 2:53).

**Design Question Q4 — outline variant's hug→fill breakpoint threshold**
Evidence: only two known widths exist for this instance — 138px hug-content at 1440 (node 1:772) and 328px fill-container at 360 (node 1:1249); no tablet frame was surfaced in this file. Question: at what viewport does the outline button switch from hug-content to fill-container? Recommend the project's standard small-breakpoint boundary (~640px) as the literal default pending confirmation — does not block the build.

## Animations

Hover/Press are simple CSS transitions on background-gradient (filled, nodes 2:53/2:55/2:57) / border-color (outline, nodes 2:114/2:115/2:116), 150–200ms ease — no prototype easing/duration authored in Figma (`get_motion_context` returned `null` on both ticket instances 1:598 and 1:772, consistent with the design-system's own baseline having no motion data for any Button-family node). Not a complex animation. This is not a composite behaviour pattern (carousel/marquee/accordion), so no `behaviour-library-map.md` entry applies — implement via Tailwind's `transition-colors`/`transition-[background-image,border-color]` utilities.

## Reuse check

Scanned `src/components/ui/` (contains only `.gitkeep` — empty) and `docs/specs/` (contains only `.gitkeep` — no prior specs). **Creates new primitive `Button`** — this is confirmed as the first shared UI primitive in the repo; nothing exists to reuse, consistent with the ticket's own "no Reuses field — this IS the first shared primitive" note.

## Accessibility

- Native `<button>` by default (Space/Enter activate natively); `as="a"` renders a real `<a href>` with anchor-correct activation (Enter only, no Space) — never fakes button semantics onto a link.
- Visible focus ring only on `:focus-visible` (not plain `:focus`), 2px `border-primary` `#E98C00` (existing token, established at Input focus border, nodes 2:206/2:214), ~2px offset — derived per States section above, not a Figma-authored Button state.
- Accessible name comes from the rendered text children (`BOOK NOW` node 1:598, `View All Cars` node 1:772, etc.) by default; any future icon-only usage must require `aria-label` (out of this ticket's scope — no icon-only instance observed).
- `disabled`: native `disabled` attribute when `as="button"`/`input` (removes from tab order per native semantics); `aria-disabled="true"` + prevented default + `tabIndex={-1}` when `as="a"` (real anchors have no native `disabled`).
- Color contrast: white label on the gradient fill (node 1:598), and the white→white/40 gradient-clipped outline label on the dark background (node 1:772), should both be spot-checked against WCAG AA at implementation time (flagged for `/review`).

## Acceptance criteria

- [ ] `filled` variant renders `gradient-from`/`gradient-to` `#FFB800`/`#E97000` (Normal, node 1:598), `gradient-hover-from`/`gradient-hover-to` `#FFC533`/`#ED8D33` (Hover, node 2:55), `gradient-press-from`/`gradient-press-to` `#E5A500`/`#D16500` (Press, node 2:57), with the `--shadow-button-cta` token (node 1:598, see Design Question Q3) constant across all three states; label Poppins Bold 20px uppercase with the existing button text-shadow (node 2:53).
- [ ] `outline` variant renders 2px solid border (`border-primary` `#E98C00` Normal, node 1:772 / `gradient-hover-from` `#FFC533` Hover, node 2:115 / `gradient-press-from` `#E5A500` Press, node 2:116); label uses the existing nav-text-gradient + Read-More text-shadow (node 2:114), Poppins SemiBold 16px, unchanged across all three states.
- [ ] `focus-visible` shows a visible `border-primary` ring, keyboard-triggered only, on both variants.
- [ ] `disabled` reduces opacity on the existing variant tokens, removes the drop-shadow and hover/press transitions, and is reachable via native `disabled` (button/input) or `aria-disabled` + non-interactive handling (`as="a"`).
- [ ] Renders the correct native element per `as`/`asChild` (button default; `a` with a real `href` for navigation; `input[type="submit"]` supported), with accessibility correct for the actually-rendered element.
- [ ] `outline` variant is hug-content width at desktop (node 1:772) and switches to fill-container width at the mobile breakpoint (node 1:1249) — DISCRETE; `filled` variant keeps its fixed 163×52 footprint unchanged across breakpoints (nodes 1:598/1:1034) — CONTINUOUS/no-change.
- [ ] No raw color/shadow/spacing values in component code — every value sources from a Tailwind theme token (existing tokens + the new `--shadow-button-cta`, status open per Q3).
- [ ] Component and Tailwind theme addition (`--shadow-button-cta`) land together with a `docs/design-tokens.md` row, per Token map maintenance.

## Test plan

Unit only. `/build` generates a co-located `Button.test.tsx` covering: both variants' rendering, all 5 states (default/hover/focus-visible/press/disabled — acceptance-criteria-mapped test titles), polymorphic rendering (`button`/`a`/`input[type=submit]`) with per-element a11y assertions (real anchor gets `href`, real button gets native `disabled`), and accessible-name/keyboard-activation basics. No integration or e2e — this ticket is an isolated primitive with no multi-component data flow or user journey of its own; feature tickets that later compose this Button into a flow carry their own e2e per their own acceptance criteria.

---

No SEO requirements line — this is a component/primitive ticket, not route/page-level.
