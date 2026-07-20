# FF-9 — Icon primitive (ui)

## Purpose

A single, project-wide `Icon` React component that renders any icon glyph used anywhere in
the "Website" Figma file, selected by a typed `name` prop, through one consistent,
accessible, token-driven rendering path — replacing ad-hoc inline SVG per feature. This is
a **new primitive** for `src/components/ui/` (see Reuse check below).

## Typed props

```ts
type IconName =
  // navigation / control
  | "arrow-right"
  | "chevron-left"
  | "chevron-down"
  | "plus"
  | "x-close"
  | "menu-02"
  // form / field
  | "check"
  | "check-square"
  | "checkbox-empty"
  | "eye"
  | "eye-off"
  | "calendar"
  | "clock"
  | "edit-02"
  | "x-circle"
  | "map-01"
  | "file-04"
  // info bullets
  | "sale-02"
  | "shield-zap"
  | "user-01"
  // social
  | "social-instagram"
  | "social-facebook"
  | "social-tiktok"
  | "social-linkedin"
  | "social-x"
  // third-party sign-in (brand-colored, exempt from currentColor — see a11y/behaviour note)
  | "signin-google"
  | "signin-facebook"
  | "signin-apple"
  // contact
  | "contact-phone"
  | "contact-mail"
  | "contact-map"
  // numbered feature/requirement pictogram set (final semantic keys pending /build — see registry)
  | "feature-01"
  | "feature-02"
  | "feature-03"
  | "feature-04"
  | "feature-05"
  | "feature-06"
  | "feature-07"
  | "feature-08"
  | "feature-09"
  | "feature-10"
  | "feature-11"
  | "feature-12"
  | "feature-13"
  | "feature-14"
  | "feature-15";

type IconProps = {
  name: IconName; // required — unknown values are a TS compile error (exhaustive union, no string fallback)
  size?: number; // rendered height in px, default 24; width follows the glyph's own natural aspect ratio — never forced square
  className?: string; // style hook; color is controlled by the consumer via `currentColor` (text-color utility), never a prop
} & (
  | { decorative?: true; label?: never } // default: aria-hidden, no accessible name
  | { decorative: false; label: string } // meaningful use: label is required and becomes the accessible name
);
```

- `size` sets height only; the SVG's own `viewBox` (verbatim per glyph, per design-extraction
  skill §9) determines width via natural aspect ratio.
- No `color`/`fill` prop: every glyph's fill/stroke is `currentColor` in the SVG source,
  except the three third-party sign-in brand marks (`signin-google/facebook/apple`), which
  are genuine multi-color brand logos and are explicitly **exempt** from the currentColor
  contract (brand-mark colors must render verbatim, never recolored) — this exemption is
  industry-standard for OAuth sign-in buttons, not a design ambiguity, and is called out
  explicitly rather than silently bent into the general rule.

## Coverage inventory

**Ticket nature:** GLOBAL SET-PRIMITIVE (icons/project-wide asset set) — document-wide
coverage required per design-extraction skill §10, not scoped to one component's own
breakpoint frames.

**Pages swept (all 19 pages of file "Website", `FlWYwSHj7vtd487hdXZi6t`) — every page
directly read, structural non-text-leaf enumeration, not keyword matching:**

| Page (id)                                      | Sweep method                                                                                | Result                                                                                                                                                                                                                                                                                                                                                                                                            |
| ---------------------------------------------- | ------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Homepage (`0:1`)                               | Direct full-page read (Footer master `1:1884`/`1:1919`/`1:1924`/`1:1929`/`1:1941`–`1:1950`) | Icons found (social, contact, feature badges)                                                                                                                                                                                                                                                                                                                                                                     |
| Our Cars (`1:1883`)                            | Direct full-page read (Desktop `1:1960` + Mobile `1:2043`)                                  | Icons found (pagination `chevron-left`, brand-logo strip — out of scope, footer)                                                                                                                                                                                                                                                                                                                                  |
| Car Info (`1:2582`)                            | **Direct full-page read** (structural size-filtered enumeration, 205+ nodes)                | No new glyphs. Confirms the `EFG_ico_01`–`15` feature-pictogram family belongs to this page. New size citations: `arrow-right` also 20×20 (`1:5512`, `1:5471`, `1:5430`, `1:5389`); `chevron-left` also 20×20 compact (`1:3146`, `1:3571`, `1:3932`, `1:4343`, `1:5112`). Confirms `signin-*` (`1:3986`/`1:3994`/`1:3997`), `x-close` (`1:4004`), `checkbox-empty`, stepper `check`, contact/social footer icons. |
| Booking (`1:5906`)                             | **Direct full-page read, in full**                                                          | No new glyphs. Confirms `chevron-left`@20×20 (`1:6272`), `x-close`, `chevron-down`, `check-square`, `checkbox-empty`, and `map-01` (`1:6377`/`1:6405`/`1:6657`/`1:6685`, 20×20) co-existing as a SEPARATE, differently-sized instance from the unnamed `Component 2` (`1:6370`/`1:6396`/`1:6650`/`1:6674`/`1:6885`, 24×24) in the same field rows — see registry correction below.                                |
| Privacy Policy (`1:7198`)                      | **Direct full-page read, in full**                                                          | No new glyphs — legal-text page; only shared contact/social Footer + collapsed Header instance.                                                                                                                                                                                                                                                                                                                   |
| Terms and Conditions (`1:7471`)                | **Direct full-page read, in full**                                                          | Same as Privacy Policy — no new glyphs, shared Footer/Header only.                                                                                                                                                                                                                                                                                                                                                |
| Sign in (`66:6566`)                            | **Direct full-page read** (structural size-filtered enumeration, 413 nodes)                 | No new named glyphs. New unnamed instance found: `Component 1` (24×24, `1021:4945`/`1021:4955`) at the same x=485,y=0 slot where `eye-off` renders on a sibling frame — see registry addition below. Reconfirms `arrow-right`@20×20, `chevron-left`@20×20 compact, `EFG_ico` family, `x-close`, `chevron-down`@16×16 (nav), `menu-02`, 5-icon social footer.                                                      |
| Driver Information (`209:2910`)                | Direct full-page read (structural size-filtered enumeration)                                | New icon found: `file-04`                                                                                                                                                                                                                                                                                                                                                                                         |
| Terms & Conditions (booking) (`386:888`)       | **Direct full-page read, in full**                                                          | No new glyphs — `chevron-down` (summary toggle), stepper `check`, `checkbox-empty` (terms-agreement checkbox), contact/social footer, Header.                                                                                                                                                                                                                                                                     |
| Payment (`729:2416`)                           | Direct full-page read                                                                       | No new icons (`check`/`chevron-down`/contact/social reused)                                                                                                                                                                                                                                                                                                                                                       |
| Almost behind the wheel (`591:1686`)           | Direct full-page read, in full                                                              | No new icons (Header/Footer reuse only)                                                                                                                                                                                                                                                                                                                                                                           |
| Profile (`404:653`)                            | **Direct full-page read** (structural size-filtered enumeration)                            | No new named glyphs. Reconfirms `Component 1` (24×24) at the same x=485/486,y=0 slot — 6 total instances across 2 modal contexts on this page alone, strengthening the eye/eye-off-unnamed-instance hypothesis (still open — see registry). Also `chevron-down`@16×16 (nav), `plus` (accordion), `x-close`, footer icons.                                                                                         |
| Errors (`558:1102`)                            | Direct full-page read, in full                                                              | No new functional icons; 2 unique decorative illustrations found (`EFG_Wrong_1`, `EFG_404`) — out of scope, see registry                                                                                                                                                                                                                                                                                          |
| My Bookings (`619:6537`)                       | Direct full-page read                                                                       | New icon found: `map-01`                                                                                                                                                                                                                                                                                                                                                                                          |
| FAQ (`1074:1859`)                              | **Direct full-page read, in full**                                                          | No new glyphs — confirms exclusive use of `chevron-down` (24×24) for ~17 accordion rows (Desktop + Mobile), never the `plus` variant; footer icons only otherwise.                                                                                                                                                                                                                                                |
| About us (`1084:5736`)                         | Direct full-page read, in full                                                              | No new icons (Header/Footer/Logo_Animation only)                                                                                                                                                                                                                                                                                                                                                                  |
| `_________________________________` (`58:674`) | Checked via `get_metadata`                                                                  | Confirmed genuinely empty canvas (0×0, no children) — **skipped: empty/service page**                                                                                                                                                                                                                                                                                                                             |
| All (`62:497`)                                 | Structural, size-filtered enumeration across its ~19,941×3,803px canvas                     | Supplementary cross-reference only — confirmed unreliable as sole source (missed `EFG_Phone/Mail/Map_icon` entirely; showed a scaled `x-circle` duplicate at 16×14.4 vs the 16×16 canonical). All findings from this page were independently re-confirmed via direct per-page reads before being trusted.                                                                                                         |
| Cover (`58:830`)                               | Direct full-page read                                                                       | No functional icon glyphs (Logo_Animation instance + decorative photo + title text only)                                                                                                                                                                                                                                                                                                                          |

**All 19 pages directly swept — no page relies solely on the unreliable "All" composite
cross-reference.** 32 in-scope functional icon glyphs confirmed; no new glyph names
surfaced in the final verification pass across the 8 pages initially deferred. Two unnamed
instances (`Component 1`, `Component 2`) remain open engineering-identity questions for
`/build`'s SVG-geometry comparison pass (not missing glyphs, not design ambiguities — see
registry).

**Design-system / component-library check:** no dedicated "Icons"/"Components" page exists
among the 19 named pages. Icon **master** components are local, file-scoped nodes sitting
as sibling top-level nodes alongside content frames on the same pages they're used on
(e.g. `arrow-right` master `1:42`, `chevron-left` master `1:86`, `chevron-down` master
`1:88`, `x-close` master `1:276`; `check` master `62:661`; `menu-02` fallback master
`1:105`). Additionally checked `get_libraries` (3 team libraries attached to this file:
"[System] New AmRes", "Engenious System", "[System] Engenious") and ran
`search_design_system` against them for icon names actually in use (`chevron-left`,
`x-close`) — **no match**: those libraries contain an unrelated, legacy Boxicons-style
icon set last touched 2022–2023. This file's icon names match the well-known "Untitled UI"
community icon-kit naming convention, but that kit is not among this file's attached
libraries, so any upstream state/variant definitions are unreachable from here. **No icon
instance anywhere in the sweep showed a Hover/Press/Active variant property** — every
instance observed is a flat, single-state component.

**Motion check (`get_motion_context`):** run on the accordion frame carrying its own
chevron toggle (`62:773`, "& Accordion / v3-m1") and on the mobile hamburger instance
(`62:3424`, `menu-02`). Both returned `motionSummary: null` — **no Figma-authored
prototype animation found on any icon in this sweep.**

Every "absent / no counterpart / stateless" claim in this spec cites this inventory.

## States

**No variant states found for any icon** (backed by the design-system check above — no
Hover/Press/Active property groups on any of the 32 catalogued glyphs). The `Icon`
primitive itself is visually flat and stateless; interactive color changes (e.g. a button's
icon dimming on hover) are applied by the **consuming** component via `currentColor`
inheritance, not by icon-level Figma states. This is a coverage-backed conclusion, not an
assumption.

## Breakpoints

**N/A.** `Icon` is a leaf primitive with no responsive layout of its own; `size` is a
caller-controlled prop, not a viewport-driven variant. No 2+ same-pattern icon mockups were
compared (each glyph is a single flat instance per placement), so design-extraction skill
§12's CONTINUOUS/DISCRETE classification does not apply here — this is stated explicitly
rather than left silent.

## Design tokens

**Colors — dedup against `docs/design-tokens.md`:**

- `arrow-right` fill resolves via `get_variable_defs` to the bound style **"Primary" =
  `#E98C00`** `[Verify-node: 62:2283]` — **exact match** to the existing
  `--color-primary` token (`docs/design-tokens.md`). Reuse; no new token, no design
  question.
- `menu-02` (hamburger) fill is bound to style **"Button/Gradient"** — same named style
  as the existing `--color-gradient-from`/`--color-gradient-to` token pair
  (`#FFB800 → #E97000`) documented in docs/design-tokens.md `[Verify-node: 62:3424]`
  (value string returned empty from `get_variable_defs` — a known limitation for
  multi-stop gradient-typed styles, but the **name** match is the authoritative identity
  signal per design-extraction skill §9's resolution order). Reuse; no new token, no
  design question.
- **All other catalogued glyphs** (`chevron-left`, `chevron-down`, `plus`, `x-close`,
  `check`, `check-square`, `checkbox-empty`, `eye`, `eye-off`, `calendar`, `clock`,
  `sale-02`, `shield-zap`, `user-01`, `edit-02`, `x-circle`, `map-01`, `file-04`,
  social/contact icons): `get_variable_defs` returned `{}` (unbound) and
  `get_design_context` flattens every one of these to a raster `<img>` reference with no
  color/fill utility class exposed in code — confirmed visually via `get_screenshot` as
  plain white/off-white glyphs (consistent with the existing white/opacity token family:
  `--color-foreground`, `text-white/60`, `border-white/40`), but **the exact hex cannot be
  independently machine-verified in the analyst context, which has no Bash/curl tool** to
  read the raw SVG paint bytes that `download_assets` only returns a URL for (confirmed:
  reading the returned asset URL directly errors — that tool cannot fetch remote bytes).
  **This is flagged as a TOOL-ACCESS GAP (design-extraction skill §13 precedent), not a
  design absence.** Since every one of these glyphs is `currentColor`-driven per the
  ticket's own acceptance criteria, the exact hex is non-load-bearing for the component
  itself — color is inherited from the consumer. `/build` runs in a Bash-capable context
  and can close this gap with `curl` on the export URL if a literal hex is ever needed.
- **Opacity:** two icon placements carry a container-level `opacity-40` exposed directly in `get_design_context`'s Tailwind output: the footer social-icon row and the pagination `chevron-left` `[Verify-node: 62:749, 62:690]` (also confirmed identically on the Footer master `1:1941`). By contrast `chevron-down` (accordion, `62:781`) carries **no** opacity utility — confirmed distinct, not assumed uniform. This `opacity-40` is a plain stock Tailwind utility, applied at the wrapper/container level (icon-row/pagination-chevron placement), unrelated to any existing solid-color token in the map (e.g. the unrelated `Background (40%)` entry, which is a header-panel fill, a different element entirely) — it is its own standalone observation, not a token, not a comparison candidate.
- **Sign-in brand logos** (`signin-google`, `signin-facebook`, `signin-apple`, nodes
  `62:2085`/`62:2093`/`62:2096`, also confirmed at `1:3986`/`1:3994`/`1:3997`): genuine
  multi-color brand marks. Exact brand-color SVG extraction is deferred to `/build`'s
  Bash-capable pass (per the geometry-deferral decision, consistent treatment) — **not
  deferrable beyond that**; hard rule 5 (never invent) applies in full once `/build` reads
  them.

**Geometry:** per the orchestrator's own geometry-deferral decision (design-extraction
skill §9's "broad sweep surveying many icons" exception), literal `viewBox`/`d=`/
`stroke-width` values are deferred to `/build`, which re-pulls each glyph's canonical
instance via `download_assets svg` using the exact node-ids cited in the Icon registry
below. Two geometry notes already surfaced during this sweep (so `/build` doesn't
re-discover them from scratch):

- `edit-02` is genuinely **non-square** (16×14.07, confirmed identically across 3
  independent node-id ranges on different pages: `639:8248`, `1196:5580`, `645:8683`) —
  ship verbatim, never force-square.
- `x-circle`'s canonical size is **16×16** (confirmed on 3 independent direct-page reads:
  `639:8249`, `1196:5581`, `645:8684`); a 4th reading on the "All" composite page
  (`62:2296`, 16×14.4) is classified as a scaled/non-canonical duplicate of that specific
  overview artifact, not used for canonical geometry, per design-extraction skill §9's
  scaled-instance handling.
- **Master-vs-instance export availability (Footer icons):** `download_assets` on the
  Footer **master** component's own node-ids for `contact-phone`/`contact-mail`/
  `contact-map`/`social-instagram`/`social-facebook` (`1:1919`, `1:1924`, `1:1929`,
  `1:1944`, `1:1946`, `1:1948`, `1:1951`, and `1:1890`) consistently returns
  `export: null` — reproducible across all 8, not a fluke. The SAME icons' **placed
  instances** elsewhere (Homepage footer row `62:690`'s children `62:693`/`695`/`697`/
  `700`/`702`/`706`/`708`/`710`) export cleanly as genuine vector. **`/build` must pull
  geometry from a placed instance, never from these master node-ids.**

**Incidental page-chrome colors encountered while reading for icons (not icon properties — accounted for, not silently dropped, per skill §2):** while reading the Footer master (`1:1884`/`1:2042`) and its surrounding page background to locate the phone/mail/map/social icons, several non-icon color values surfaced in the raw tool output. None of these belong to `Icon` or its registry; each is either an exact-match reuse of an existing token or explicitly out of scope for this ticket, never silently dropped:

- `#080c0f` — page/canvas background chrome, Homepage root canvas (node 0:1). Exact match to the existing `Background` token `#080C0F` (docs/design-tokens.md, originally cited at node 4004:366 in the "Components" file). Reuse; out of scope for `Icon`.
- `#1e1e1e` — unattributed: likely incidental ancestor-leakage inside one of the social-icon SVG exports (`62:693`/`695`/`697`/`700`/`702`/`706`/`708`/`710`, each independently confirmed by the hook to leak geometry to an ancestor ~3059 wide beyond the node's own declared canvas). Per skill §9's parent/child rule, this is NOT attributed to any specific ancestor node without a direct call naming that exact node-id — flagged explicitly as unconfirmed rather than guessed or silently dropped. Not converted to a token.
- `from-white` and `text-[transparent]` — the Footer's FAQ/Privacy-Policy/Terms nav-link text (node 1:1884), implemented as a `bg-clip-text bg-gradient-to-r from-white ... to-[rgba(255,255,255,0.4)] text-transparent` gradient-text pattern (`text-[transparent]` is the mechanical companion of this pattern, not an independent value). Exact match to the existing "Nav text gradient (default)" token (`linear-gradient(90deg, #FFFFFF 0%, rgba(255,255,255,0.4) 100%)`). Reuse; out of scope for `Icon` (footer nav-link text, not an icon).
- `opacity="0.4"` — already accounted for above (footer social-row wrapper `62:690`/`1:1941` and pagination `chevron-left` `62:749`); cross-referenced here so no value is left unaccounted.
- `rgba(255,255,255,0)` and `rgba(255,255,255,0.02)` — the Footer master's own panel-background gradient (`bg-gradient-to-b from-[rgba(255,255,255,0.02)] ... to-[rgba(255,255,255,0)]`). Out of scope — this is the Footer component's own background token, belongs to a future Footer-ticket spec, not this Icon spec. Named explicitly, not silently dropped.
- `rgba(255,255,255,0.4)` — Footer copyright line color and the nav-link gradient's `to-` stop (node 1:1884). Exact match to the existing `Border neutral 40%` / gradient-stop token. Reuse; out of scope for `Icon`.
- `rgba(255,255,255,0.6)` — Footer contact-info text color (phone/mail/address lines) (node 1:1884). Exact match to the existing `Text muted 60%` token. Reuse; out of scope for `Icon` (text color, not icon color).

**Sibling-instance coverage note (per skill §14 gate 6 — WARN-tier, addressed explicitly rather than left silent):** the Facebook footer icon pair (`1:1950`/`62:699`), the Instagram footer icon pair (`1:1942`/`62:691`), the `chevron-left` pagination pair (`3005:3128`/`62:749`), and an "instagram icon" sub-path pair (`1:1943`/`62:692`) each have at least one placement not yet individually deep-read. This spec does NOT claim these placements share their opacity/color/blend-mode with their deep-read sibling — that would need independent per-instance verification this run didn't do for every placement (the exact Instagram-opacity failure mode this gate exists to catch). Per the geometry-deferral decision already in force for this whole ticket, `/build` independently pulls and verifies every canonical instance it actually encodes, regardless of what this spec observed on a sibling placement — so the open coverage here carries forward as a `/build`-time task, not an assumption baked into this spec.

## Animations

No Figma-authored prototype animation exists on any icon glyph in this sweep (motion check
above). Any icon-level CSS transition (e.g. a chevron rotating 180° when an Accordion
opens, or a hamburger morphing to an X on menu open) is the **consuming** component's own
concern, not this primitive's — `Icon` renders statically. For reference (never pinned
here): the design-extraction skill's `behaviour-library-map.md` lists **Radix UI
Accordion** as the vetted default for accordion expand/collapse behaviour, which would own
any such chevron-rotation transition when the Accordion ticket is built.

## Reuse check

`src/components/ui/` currently contains only `.gitkeep` (empty) — no existing Icon
primitive or overlapping component. `docs/specs/` has no prior spec defining one. **This
ticket creates new primitive `Icon`** — flagging per convention for explicit human approval
at the spec checkpoint (this is the expected, ticket-sanctioned outcome, not an
unauthorized addition).

## Accessibility

- **Decorative (default):** `aria-hidden="true"`, `focusable="false"`, no accessible name.
  Used whenever the icon is purely visual reinforcement next to its own visible text label
  (nav items, footer contact rows with adjacent text, etc.).
- **Meaningful (`decorative={false}`):** `label` is a required prop (enforced at the type
  level via the discriminated union above) and becomes the icon's accessible name
  (`role="img"` + `aria-label={label}`, or an inline `<title>` + `aria-labelledby` — the
  standard accessible inline-SVG pattern). Used for icon-only controls with no visible
  adjacent text (e.g. the mobile hamburger `menu-02`, the password-visibility toggle
  `eye`/`eye-off`, the modal close `x-close`).
- Color contrast is inherited via `currentColor` from the consumer and must be verified by
  the consuming component's own spec/review, not by `Icon` itself.
- Sign-in brand marks (`signin-*`) still require a `label` when used as icon-only buttons
  (e.g. "Sign in with Google") — the brand-color exemption is visual only, not an a11y
  exemption.

## Acceptance criteria

- [ ] Full-project icon inventory: every distinct icon glyph used anywhere in the Website
      Figma file is found and enumerated — **all 19 pages directly swept** (structural,
      non-keyword enumeration), not inferred via composite cross-reference. 32 in-scope
      functional glyphs confirmed with no new glyph names surfacing across the full sweep;
      2 unnamed instances (`Component 1`, `Component 2`) remain open identity questions for
      `/build`'s SVG-geometry pass — engineering confirmations, not missing glyphs or
      design ambiguities. See Coverage inventory above and the Icon registry below.
- [ ] Each glyph's geometry (`viewBox`, path data, `stroke-width`) is extracted verbatim
      from its own canonical instance at `/build` time, per the node-id citations in the
      Icon registry — no normalization, no invented geometry.
- [ ] Rendering selects the glyph by `name`; unknown names are a compile-time TS error
      (exhaustive `IconName` union, no string fallback / no `[key: string]` escape hatch).
- [ ] `size` controls rendered height only; width follows each glyph's own natural aspect
      ratio (verified non-square for `edit-02`) — never stretched to a forced square.
- [ ] Color is `currentColor`-driven for every glyph except the 3 sign-in brand marks
      (explicit, documented exemption); no icon hardcodes its own color.
- [ ] Accessibility: decorative-by-default (`aria-hidden`), explicit `label` required when
      `decorative={false}`.
- [ ] All icon colors deduped against `docs/design-tokens.md` (2 exact-match reuses found:
      `arrow-right`→Primary, `menu-02`→Button/Gradient; no new custom color token needed —
      remaining glyphs' exact hex is a documented tool-access gap, non-blocking since they
      are `currentColor`-driven).
- [ ] Unit tests cover: rendering by name, sizing/aspect-ratio behavior, color contract, both
      accessibility modes (see Test plan).

## Test plan

**Unit only** — this is a leaf primitive, no composite data flow or user-flow journey.
`ComponentName.test.tsx` co-located with `Icon.tsx`, covering:

- Renders the correct glyph for every `IconName` (parameterized over the full union).
- An out-of-union name fails at compile time (a `// @ts-expect-error` test case), never at
  runtime.
- `size` sets rendered height; a known non-square glyph (`edit-02`) is asserted to render
  proportional (not forced-square) width.
- Color contract: no inline/hex `fill`/`stroke`/`color` style is present on the rendered
  SVG (asserts `currentColor` inheritance); sign-in brand icons are asserted to keep their
  own verbatim brand-color paths (exemption test).
- `decorative` (default) renders `aria-hidden="true"` with no accessible name.
- `decorative={false}` requires and renders `label` as the accessible name.

No integration or e2e tests — no data flow, no user journey to trace acceptance criteria
against beyond the unit level.

## SEO requirements

**N/A** — `Icon` is a reusable component, not a route/page-level ticket.
