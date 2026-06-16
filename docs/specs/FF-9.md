# FF-9 — Icon primitive (`ui/Icon`) — Specification

**Status:** Draft — awaiting human RE-approval (contract revised to natural-viewBox; CLAUDE.md hard rule 2)
**Source ticket:** FF-9 (2 SP) · **Figma file:** Website (`FlWYwSHj7vtd487hdXZi6t`)
**Type:** New shared UI primitive (`src/components/ui/Icon.tsx`) — non-route, no page metadata.

## Purpose

A single `Icon` component that wraps the project's SVG icon set so every icon is consistent in size, color, and accessibility semantics. Each glyph is encoded as **inline SVG extracted verbatim from Figma** (its natural viewBox + path + stroke-width). Icons are sized by a `size` prop that sets the **rendered height**, with each glyph's **natural aspect ratio preserved** (square for the seven 24×24 icons; ~16:15 for `edit`). Color inherits via `currentColor`, and ARIA depends on whether the icon is decorative or meaningful. A leaf primitive consumed by Accordion (chevron-down), carousel/gallery controls (chevron-left), and feature/booking cards (calendar, clock, check, edit, plus, x-close).

## Contract change note (supersedes the first-approved spec)

The originally approved spec assumed a **uniform 24×24 box** (`size?: 24`, single token). Verbatim extraction (below) showed the set is **not uniform**: stroke-widths differ per icon (2 / 3 / 1.5 / 1.46813) and `edit` is non-square (16×15). Rather than normalize or guess to force a 24×24 box, the **Icon contract does not impose a uniform box** — each glyph keeps its natural viewBox + real stroke-width, verbatim; `size` sets the rendered height and width follows the aspect ratio. No scaling, no guessing; all 8 ship. (This is why the spec is back for re-approval.)

## Typed props

```ts
// The icon set wrapped by this primitive. Names are the registry keys.
// NOTE: Figma names the edit glyph "edit-02"; the registry key stays "edit"
// (maps to the edit-02 asset) — NOT renamed. See Q22 (informational).
export type IconName =
  | "chevron-left"
  | "chevron-down"
  | "plus"
  | "x-close"
  | "check"
  | "clock"
  | "calendar"
  | "edit";

export interface IconProps extends Omit<ComponentProps<"svg">, "aria-hidden"> {
  /** Which icon from the set to render. */
  name: IconName;
  /**
   * Rendered HEIGHT in px. Width follows the glyph's NATURAL aspect ratio
   * (1:1 for the seven 24×24 icons; ~16:15 for `edit`) — it is NOT a fixed
   * 24×24 box. Defaults to the `--size-icon` token (24px) when omitted.
   * @default 24 (via --size-icon)
   */
  size?: number;
  /**
   * Accessible label for a MEANINGFUL icon (icon conveys information not present
   * in adjacent text). When provided, the icon gets role="img" + aria-label and
   * is NOT aria-hidden. When omitted, the icon is decorative → aria-hidden.
   */
  label?: string;
}
```

- Each glyph is rendered as an inline `<svg>` with the icon's **own `viewBox`** and its path(s) at the icon's **own `stroke-width`** (verbatim — see geometry table). Aspect ratio is preserved: the `<svg>` is given the rendered height and its width follows the viewBox.
- Fill/stroke is driven by `currentColor` (no `color` prop) — callers set color via the surrounding text color, matching how Button colors its content.
- Named export `Icon` (convention) + re-export from `src/components/ui/index.ts`; export `IconName`, `IconProps`. (No `IconSize` union — `size` is a free px height, default `--size-icon`.)

## States

An icon is a static leaf glyph — it has **no interactive variant set** in Figma (no hover/press/loading/error/empty rendering exists for the icons themselves; interactivity belongs to the parent control, e.g. Button or an Accordion trigger). The only thing that changes across icon instances is **which glyph** and **its rendered size/color** — both already props. Therefore: **states = N/A** beyond the `name`/`size`/`label`/`currentColor` matrix. The icon inherits hover/focus visuals from its interactive parent; it does not own them.

## Breakpoints

**N/A.** Size is controlled per-instance via the `size` prop (rendered height), not by viewport. Responsive sizing is the caller's concern (e.g. a parent passing a different `size` at a breakpoint). No breakpoint behavior is defined in Figma for the icons.

## Design tokens & glyph geometry (extracted verbatim via `download_assets` svg)

Vector geometry IS retrievable from Figma via **`download_assets` with `format:"svg"`** on each placed-instance node — confirmed `rawImages:[]` (true vector). Each glyph is encoded verbatim: its natural viewBox + path(s) + stroke-width, with the export's background/frame rects dropped (inner `<g id="<name>"><path id="Icon">` only). **No normalization.** (The earlier "flattened raster / geometry not extractable" reading was a `get_design_context` artifact — corrected; see Q24.)

**Per-icon geometry (verbatim — viewBox is the raw `<svg>` root from the export):**

| Icon         | node                                                                                     | viewBox     | stroke-width | aspect                                                                                                           |
| ------------ | ---------------------------------------------------------------------------------------- | ----------- | ------------ | ---------------------------------------------------------------------------------------------------------------- |
| chevron-left | [1:774](https://www.figma.com/design/FlWYwSHj7vtd487hdXZi6t/Website?node-id=1-774)       | `0 0 24 24` | `2`          | 1:1                                                                                                              |
| chevron-down | [1086:514](https://www.figma.com/design/FlWYwSHj7vtd487hdXZi6t/Website?node-id=1086-514) | `0 0 24 24` | `2`          | 1:1                                                                                                              |
| x-close      | [62:1673](https://www.figma.com/design/FlWYwSHj7vtd487hdXZi6t/Website?node-id=62-1673)   | `0 0 24 24` | `2`          | 1:1                                                                                                              |
| check        | [62:1869](https://www.figma.com/design/FlWYwSHj7vtd487hdXZi6t/Website?node-id=62-1869)   | `0 0 24 24` | `3`          | 1:1                                                                                                              |
| clock        | [62:2726](https://www.figma.com/design/FlWYwSHj7vtd487hdXZi6t/Website?node-id=62-2726)   | `0 0 24 24` | `1.5`        | 1:1                                                                                                              |
| calendar     | [62:2713](https://www.figma.com/design/FlWYwSHj7vtd487hdXZi6t/Website?node-id=62-2713)   | `0 0 24 24` | `1.5`        | 1:1                                                                                                              |
| plus         | [62:1268](https://www.figma.com/design/FlWYwSHj7vtd487hdXZi6t/Website?node-id=62-1268)   | `0 0 24 24` | `1.46813`    | 1:1 (exported viewBox is verbatim `0 0 24 24`; the glyph sits inset/smaller within the box — Q21, informational) |
| edit         | [62:2292](https://www.figma.com/design/FlWYwSHj7vtd487hdXZi6t/Website?node-id=62-2292)   | `0 0 16 15` | `1.5`        | 16:15 non-square (`edit-02`, raw root `width="16" height="15"` — Q22, informational)                             |

Verbatim path data (the inner `<path id="Icon">`, drawn on each viewBox above):

- **chevron-left:** `M15 18L9 12L15 6`
- **chevron-down:** `M6 9L12 15L18 9`
- **x-close:** `M18 6L6 18M6 6L18 18`
- **check:** `M20 6L9 17L4 12`
- **clock:** `M12 6V12L16 14M22 12C22 17.5228 17.5228 22 12 22C6.47715 22 2 17.5228 2 12C2 6.47715 6.47715 2 12 2C17.5228 2 22 6.47715 22 12Z`
- **calendar:** `M21 10H3M16 2V6M8 2V6M7.8 22H16.2C17.8802 22 18.7202 22 19.362 21.673C19.9265 21.3854 20.3854 20.9265 20.673 20.362C21 19.7202 21 18.8802 21 17.2V8.8C21 7.11984 21 6.27976 20.673 5.63803C20.3854 5.07354 19.9265 4.6146 19.362 4.32698C18.7202 4 17.8802 4 16.2 4H7.8C6.11984 4 5.27976 4 4.63803 4.32698C4.07354 4.6146 3.6146 5.07354 3.32698 5.63803C3 6.27976 3 7.11984 3 8.8V17.2C3 18.8802 3 19.7202 3.32698 20.362C3.6146 20.9265 4.07354 21.3854 4.63803 21.673C5.27976 22 6.11984 22 7.8 22Z`
- **plus:** `M11.7451 4.8938V18.5963M4.8938 11.7451H18.5963`
- **edit:** `M11.9999 6.00158L9.33319 3.60095M1.6665 12.9034L3.92275 12.6777C4.19841 12.6501 4.33624 12.6364 4.46507 12.5988C4.57936 12.5655 4.68814 12.5184 4.78843 12.4589C4.90147 12.3918 4.99953 12.3035 5.19565 12.127L13.9999 4.20111C14.7362 3.53819 14.7362 2.46339 13.9999 1.80047C13.2635 1.13756 12.0696 1.13755 11.3332 1.80047L2.52899 9.72633C2.33287 9.90288 2.23481 9.99116 2.16026 10.0929C2.09413 10.1832 2.04185 10.2811 2.00485 10.384C1.96314 10.5 1.94783 10.6241 1.9172 10.8722L1.6665 12.9034Z`

**Color:** `currentColor` (no Figma variable bound; `get_variable_defs` → `{}`). The chevron-down instance shows `stroke-opacity 0.6` and the edit-02 instance shows `Primary #E98C00` — both are instance **context** (the caller controls color/opacity), NOT encoded into the glyph.

**Token minted** (added to `@theme` in `src/app/globals.css` + `docs/design-tokens.md` by `/build`):

- `--size-icon: 24px` — the **default rendered height** (the dominant, exactly-measured 24 frame). This is the only design token. Per-icon **viewBox and stroke-width are glyph geometry** (intrinsic to each glyph, encoded verbatim in the component) — NOT `@theme` tokens. No raw color/size design values in component code; the default height uses `--size-icon`.

## Animations

**None for the icon itself.** No prototype reactions are attached to the icon nodes. Any rotation/transition (e.g. chevron-down rotating on Accordion open) is owned by the **parent** component's spec, not this primitive — the Icon stays static.

## Reuse check

**Creates a NEW primitive `Icon` (`src/components/ui/Icon.tsx`).** Scanned `src/components/ui/` (only `Button.tsx` exists) and `docs/specs/` (only `FF-8.md`) — no existing Icon primitive and no icon assets; nothing conflicts. Pre-approved as new by the ticket ("Shared primitive"). Like `Button`, `Icon` inherits color (`currentColor`) from context rather than pinning its own. **Downstream dependents:** Accordion (chevron-down), carousel/gallery controls (chevron-left), feature/booking cards (calendar, clock, check, plus, x-close, edit) — those tickets should "Reuse `Icon` from FF-9" rather than re-implement glyphs.

## a11y requirements

- **Decorative (default, no `label`):** render `aria-hidden="true"` and `focusable="false"` on the `<svg>`; no accessible name (icon duplicates adjacent visible text). This is the default path.
- **Meaningful (`label` provided):** render `role="img"` + `aria-label={label}`; do NOT set `aria-hidden`. Used when the icon is the only conveyor of meaning (e.g. an icon-only control).
- The icon never carries interactive semantics itself — inside an icon-only button, the **parent** provides the accessible name and the Icon stays `aria-hidden` (no double-labeling).
- `currentColor` ensures the icon meets the contrast of its surrounding text (contrast is the caller's responsibility against its background).

## Acceptance criteria

- [ ] AC1: Renders each of the 8 named icons by `name` (`chevron-left`, `chevron-down`, `plus`, `x-close`, `check`, `clock`, `calendar`, `edit`) as an inline `<svg>` carrying that icon's **verbatim viewBox and stroke-width** (per the geometry table).
- [ ] AC2: `size` sets the rendered **height**; **width follows each glyph's natural aspect ratio** (1:1 for the seven 24×24 icons; ~16:15 for `edit`) — no fixed box, no glyph scaling/normalization. Default height is **24px via the `--size-icon` token**; no raw size literal for the default.
- [ ] AC3: Icon color comes from `currentColor` (inherits the parent's text color); no hardcoded fill/stroke color.
- [ ] AC4: With no `label` → `aria-hidden="true"` (+ `focusable="false"`), no accessible name (decorative).
- [ ] AC5: With a `label` → `role="img"` + `aria-label`, and NOT `aria-hidden` (meaningful).
- [ ] AC6: Unknown `name` is prevented at compile time by the `IconName` union (type-safe; no runtime fallback needed).
- [ ] AC7: Glyph geometry (viewBox, path, stroke-width) is **verbatim from Figma** — no hand-authored, normalized, or guessed values; `edit` ships non-square and `plus` ships with its inset glyph as extracted.

## Test plan

**Unit only** (co-located `src/components/ui/Icon.test.tsx`, Vitest + RTL). Justification per the Testing policy: a pure presentational **leaf primitive** with no data flow, no user-interaction sequence, no composition → integration/e2e not warranted. Tests (each maps to an AC):

- renders by `name` for all 8 icons → an `<svg>` with the icon's verbatim `viewBox` (AC1).
- per-icon `stroke-width` is present verbatim (e.g. `check` = 3, `clock`/`calendar` = 1.5, `chevron-*`/`x-close` = 2) (AC1).
- `size` sets the rendered height; **aspect preserved** — `edit` renders non-square (width ≠ height) while a square icon renders 1:1; default height pulls the `--size-icon` token (AC2).
- color via `currentColor`; no hardcoded hex (AC3).
- decorative default → `aria-hidden="true"` + `focusable="false"`, no accessible name (AC4).
- `label` → `role="img"` + `aria-label`, not aria-hidden (AC5).
- a11y smoke for both decorative and labeled modes.

## SEO requirements

**Component-level only — no route metadata.** This primitive renders no page and owns no `<head>`/Metadata API output. SEO baseline = semantic + a11y correctness: a real `<svg>` with proper ARIA (`aria-hidden` for decorative; `role="img"` + `aria-label` for meaningful). No JSON-LD, no `generateMetadata`, no `<title>`/OG — those belong to the route tickets that consume this icon.

## Open design questions (status after this revision)

- **Q21** (`plus` glyph sits inset/smaller within its verbatim `0 0 24 24` box) — **INFORMATIONAL, not a build blocker.** The build ships the plus geometry verbatim; if the designer wants the glyph to fill the box, that's a later geometry update via `/design-fixes`.
- **Q22** (`edit` is `edit-02`, non-square 16×15; registry key naming) — **INFORMATIONAL, not a build blocker.** The build ships `edit` non-square verbatim; the registry key stays `edit`.
- **Q23** (icon size usage) — **informational.** `size` is a free rendered-height (default 24 via `--size-icon`); there is no enumerated size scale for the component to block on.
- **Q24** (was "stroke/geometry not extractable — flattened raster") — **CORRECTED.** Vector IS retrievable via `download_assets` svg; geometry for all 8 was extracted verbatim. The real residual limit: the `plus`/`edit` **master** nodes (`62:659`, `62:679`) return `export: null`, so only their scaled/non-square instances are reachable — which is why `plus` ships inset and `edit` ships 16×15. Not a raster limitation.

## Figma coverage (valid only against what the tool exposed)

All 8 named icons were extracted **verbatim as inline SVG** via `download_assets` `format:"svg"` on their placed-instance nodes (`rawImages:[]` confirms true vector). Master component nodes are not retrievable — `get_metadata` rejects them and `download_assets` on the `plus`/`edit` masters (`62:659`, `62:679`) returns `export: null` — so only placed instances are reachable (hence `plus` inset, `edit` 16×15). No Figma variables are bound to any icon (`get_variable_defs` → `{}`).

| Ticket name  | Found?              | Instance node | viewBox / stroke-width (verbatim)           |
| ------------ | ------------------- | ------------- | ------------------------------------------- |
| chevron-left | ✅                  | 1:774         | `0 0 24 24` / `2`                           |
| chevron-down | ✅                  | 1086:514      | `0 0 24 24` / `2`                           |
| plus         | ✅                  | 62:1268       | `0 0 24 24` / `1.46813` (inset glyph — Q21) |
| x-close      | ✅                  | 62:1673       | `0 0 24 24` / `2`                           |
| check        | ✅                  | 62:1869       | `0 0 24 24` / `3`                           |
| clock        | ✅                  | 62:2726       | `0 0 24 24` / `1.5`                         |
| calendar     | ✅                  | 62:2713       | `0 0 24 24` / `1.5`                         |
| edit         | ✅ as **`edit-02`** | 62:2292       | `0 0 16 15` / `1.5` (non-square — Q22)      |
