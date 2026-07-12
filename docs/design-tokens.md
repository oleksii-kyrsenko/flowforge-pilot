# FlowForge — Design token map

Law: CLAUDE.md section 11 "Token map maintenance"; data lives here.

## Baseline provenance

- Source: https://www.figma.com/design/JFKSRWAuZTSR4nUMNKe0Gn/Components?node-id=0-1&p=f&m=dev (file "Components" — Elite Fleet Group, a car-rental UI kit)
- Built by: `/baseline`, 2026-07-12 (first build — no prior map existed)
- Checkpoint approved 2026-07-12; applied on branch `chore/token-baseline`
- Full checkpoint draft (page inventory, per-value node-id citations, mechanical gate results) lived at `.claude/tmp/baseline-draft.md` (gitignored scratch, not committed)

## Solid colors

| Token              | Value                    | Tailwind theme key                                                            | Provenance                                                                                                                                                                                                                                                                                      |
| ------------------ | ------------------------ | ----------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Background         | `#080C0F`                | `--color-background` (`bg-background`)                                        | Figma variable "Background/100%" [node 4004:366]. Base app background.                                                                                                                                                                                                                          |
| Background (40%)   | `#080C0F` @ 40% opacity  | use `bg-background/40` (Tailwind opacity modifier — no separate token needed) | Figma variable "Background/40%" [node 2:43]. Header translucent panel fill.                                                                                                                                                                                                                     |
| Foreground (white) | `#FFFFFF`                | `--color-foreground` (`text-foreground`)                                      | Headings, primary button text, filled input values, card titles [nodes 2:56, 2:98, 2:203, 2:150, 2:237].                                                                                                                                                                                        |
| Text muted 60%     | `rgba(255,255,255,0.6)`  | use `text-white/60` (Tailwind opacity modifier)                               | FAQ answer copy, input placeholder, card "/ day" unit text [nodes 2:113, 2:195, 2:240].                                                                                                                                                                                                         |
| Text muted 80%     | `rgba(255,255,255,0.8)`  | use `text-white/80`                                                           | Menu Item "Press" state text [node 2:86].                                                                                                                                                                                                                                                       |
| Border neutral 40% | `rgba(255,255,255,0.4)`  | use `border-white/40`                                                         | Input default/filled border [nodes 2:190, 2:198].                                                                                                                                                                                                                                               |
| Input fill         | `rgba(255,255,255,0.03)` | use `bg-white/[0.03]`                                                         | Input field background, all states [node 2:190].                                                                                                                                                                                                                                                |
| Primary            | `#E98C00`                | `--color-primary` (`bg-primary` / `text-primary` / `border-primary`)          | Figma named style "Primary" [nodes 2:106, 2:206, 2:214, 2:149, 2:114]. Focus border, active pagination number, accordion active-border origin, Read-More Normal border.                                                                                                                         |
| Error              | `#FF5C00`                | `--color-error` (`bg-error` / `text-error` / `border-error`)                  | [nodes 2:220, 2:229]. Input error border + error label. Close to Primary in hue but fails the design-extraction skill §4 same-slot test — `[Role: validation-error, Component: Input]` vs Primary's `[Role: focus-accent, Component: various]` — recorded as its own token, no design question. |
| Nav underline      | `#E68A01`                | `--color-nav-underline` (`bg-nav-underline` / used as a gradient stop)        | [node 2:85]. Menu Item underline gradient stop — the design-extraction skill's own worked example of a pair that fails the same-slot test against Primary (different Role, different Component).                                                                                                |

## Gradients

Gradient tokens are Tailwind theme _color pairs_ (`-from` / `-to`), composed in component code via `bg-gradient-to-b from-<token> to-<token>` (or `bg-gradient-to-r` for horizontal text gradients) — Tailwind v4 has no first-class "named gradient" primitive.

| Token pair               | Value                              | Tailwind theme keys                                         | Provenance                                                                                                                                                                                            |
| ------------------------ | ---------------------------------- | ----------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Button gradient (Normal) | `#FFB800 → #E97000`, top-to-bottom | `--color-gradient-from` / `--color-gradient-to`             | Figma style "Button/Gradient" [nodes 2:53, 2:74]. Send-button Normal, BOOK-IT text+icon Normal.                                                                                                       |
| Gradient — Hover         | `#FFC533 → #ED8D33`, top-to-bottom | `--color-gradient-hover-from` / `--color-gradient-hover-to` | Figma style "Gradient/Hover" [nodes 2:55, 2:75, 2:100, 2:105, 2:144]. Also reused as a _solid_ border color on image-thumbnail Hover and Read-More Hover border (exact-value reuse, not a new token). |
| Gradient — Press         | `#E5A500 → #D16500`, top-to-bottom | `--color-gradient-press-from` / `--color-gradient-press-to` | Figma style "Gradient/Press" [nodes 2:57, 2:76 (text only — see Design Question Q2), 2:145]. Also reused as a solid border color on image-thumbnail Press and Read-More Press border.                 |

Non-themed gradients (component-specific, not shared enough to warrant a Tailwind theme key — encode as arbitrary-value utilities in the consuming component, per the values below; verbatim, do not invent stop positions not shown here):

| Usage                               | Value                                                                                                               | Provenance                                                                                                                                          |
| ----------------------------------- | ------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| Nav text gradient (default)         | `linear-gradient(90deg, #FFFFFF 0%, rgba(255,255,255,0.4) 100%)`                                                    | [nodes 2:47, 2:49, 2:78]. Reused verbatim by the Read-More button text [nodes 2:114/2:115/2:116].                                                   |
| CTA text gradient ("Book Now")      | `linear-gradient(90deg, #E98C00 0.403%, rgba(233,140,0,0.4) 99.597%)`                                               | [node 2:50].                                                                                                                                        |
| Accordion panel fill (all 3 states) | `linear-gradient(180deg, rgba(255,255,255,0.05) 0%, rgba(255,255,255,0) 100%)`                                      | [nodes 2:94, 2:100, 2:106].                                                                                                                         |
| Accordion border — Normal           | `linear-gradient(180deg, rgba(255,255,255,0.2) 0%, rgba(255,255,255,0) 100%)`                                       | [node 2:94]. Flattened `get_design_context` showed this as a flat border color — the real paint (confirmed via svg export) is a top-to-bottom fade. |
| Accordion border — Hover            | = Gradient/Hover (reused)                                                                                           | [node 2:100].                                                                                                                                       |
| Accordion border — Active           | `linear-gradient(180deg, #E98C00 0%, rgba(233,140,0,0) 100%)`                                                       | [node 2:106]. Flattened code showed a flat Primary border — real paint fades Primary→transparent.                                                   |
| Nav underline gradient              | `linear-gradient(90deg, rgba(230,138,1,0) 0%, #E68A01 50%, rgba(230,138,1,0) 100%)`                                 | [node 2:85].                                                                                                                                        |
| Header hairline gradient            | `linear-gradient(90deg, rgba(255,255,255,0) 0%, rgba(255,255,255,0.4) 50%, rgba(255,255,255,0) 100%)`, blurred ~1px | [node 2:45].                                                                                                                                        |
| Pagination connector line           | `linear-gradient(90deg, #FFFFFF 0%, rgba(255,255,255,0) 100%)` @ 40% stroke-opacity                                 | [node 2:151]; same asset reused unchanged at 2:157/2:163.                                                                                           |

## Shadows & blurs

| Token                 | Value                                | Tailwind theme key                                             | Provenance                                                                    |
| --------------------- | ------------------------------------ | -------------------------------------------------------------- | ----------------------------------------------------------------------------- |
| Button drop-shadow    | `0px 4px 8px rgba(0,0,0,0.15)`       | `--shadow-button` (`shadow-button`)                            | [nodes 2:53, 2:55, 2:57]. Reused identically across all 3 Send-button states. |
| Button text-shadow    | `0px 1px 3px rgba(0,0,0,0.25)`       | not themed (single-use pattern) — arbitrary value in component | [nodes 2:54, 2:56, 2:58].                                                     |
| Read-More text-shadow | `0px 1px 4px rgba(0,0,0,0.25)`       | not themed                                                     | [nodes 2:114, 2:115, 2:116].                                                  |
| Header panel blur     | `backdrop-filter: blur(10px)`        | not themed                                                     | [node 2:44].                                                                  |
| Header hairline blur  | Gaussian blur, stdDeviation 1 (~2px) | not themed                                                     | [node 2:45].                                                                  |

## Strokes

| Element                          | Value                                                                                           | Provenance                                  |
| -------------------------------- | ----------------------------------------------------------------------------------------------- | ------------------------------------------- |
| Input border — default/filled    | 1px solid, `border-white/40`                                                                    | [nodes 2:190, 2:198].                       |
| Input border — focus             | 1px solid, `border-primary`                                                                     | [nodes 2:206, 2:214].                       |
| Input border — error             | 1px solid, `border-error`                                                                       | node 2:223 (flattened Tailwind class read). |
| Read-More button border          | 2px solid — Normal `border-primary` / Hover `gradient-hover-from` / Press `gradient-press-from` | [nodes 2:114, 2:115, 2:116].                |
| Image-thumbnail selection border | 3px solid — Normal: none / Hover `gradient-hover-from` / Press `gradient-press-from`            | [nodes 2:164 (none), 2:165, 2:166].         |
| Accordion borders                | gradients — see Gradients section above (not flat strokes in any of the 3 states)               |                                             |

## Icons / vector glyphs

| Element                                              | States & values                                                                                                                                                                          | Provenance                                                                                                                                                |
| ---------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `arrow-right` (BOOK IT icon)                         | Normal: stroke = gradient-from/to · Hover: stroke = gradient-hover-from/to · **Press: stroke = gradient-from/to (Normal colors), NOT gradient-press**                                    | [nodes 2:74, 2:75, 2:76]. See Design Question Q2 in design-questions.md — recorded verbatim, not silently corrected.                                      |
| `chevron-down` (accordion)                           | Normal: white @ 60% opacity · Hover: gradient-hover-from/to · Active: white @ 60% opacity (same as Normal — only the panel border adopts Primary, not the chevron)                       | [nodes 2:99, 2:105, 2:111].                                                                                                                               |
| `chevron-left` (pagination, rotated 180° for "next") | Normal: white flat · Hover: gradient-hover-from/to · Press: gradient-press-from/to                                                                                                       | [nodes 2:143, 2:144, 2:145].                                                                                                                              |
| Instagram icon                                       | white fill; **opacity Normal 40% / Hover 100% / Press 80%**                                                                                                                              | [nodes 2:117, 2:126, 2:134]. Independently re-verified this run (this is the design-extraction skill's own documented historical incident for this file). |
| `eye` / `eye-off` (password visibility)              | white stroke @ 60% opacity                                                                                                                                                               | [node 48:84] (`eye`). `eye-off` (48:85) not independently deep-read — assumed symmetric; see Pending below.                                               |
| Elite Fleet Group logo (`Logo_Animation`)            | Unique brand SVG asset — ship as an exported asset, not a token. 6-frame progressive build-in reveal (empty shield → vehicle glyph → stars → "ELITE FLEET" wordmark → "GROUP" subtitle). | [node 2:48]. No prototype/easing data (`get_motion_context` returned none) — **complex animation, human decision** on exact timing.                       |
| Favicon "E" mark                                     | Unique brand SVG asset, white fill on Background                                                                                                                                         | [node 4004:366].                                                                                                                                          |

## Corner radii

No non-zero corner radius observed on the one rounded-rectangle-typed node directly sampled for radius (image-thumbnail [node 2:164], radius = 0 despite the Figma node-type label). Not independently re-sampled on the Favicon backdrop or headlight-photo rounded-rectangles — see Pending.

## Typography

**Primary font: Poppins** — 100% census across the whole file, zero competing families, auto-confirmed per design-extraction skill §8. Applied globally via `next/font/google` in `src/app/layout.tsx`, set as the document default on `<body>` (never as a per-component class). Weights loaded: 300 (Light), 500 (Medium), 600 (SemiBold), 700 (Bold).

| Usage                                  | Family/weight                                  | Size                                            | Node          |
| -------------------------------------- | ---------------------------------------------- | ----------------------------------------------- | ------------- |
| Nav links                              | Poppins SemiBold                               | 16px                                            | 2:80          |
| CTA button (Send)                      | Poppins Bold                                   | 16px, uppercase                                 | 2:54          |
| Link-button (BOOK IT)                  | Poppins Bold                                   | 14px, uppercase                                 | 2:74          |
| Outline button (Read More)             | Poppins SemiBold                               | 16px                                            | 2:114         |
| Section state captions (showcase-only) | Poppins Bold                                   | 14px, uppercase                                 | 2:59          |
| Accordion question                     | Poppins Bold                                   | 16px, line-height 1.5                           | 2:98          |
| Accordion answer                       | Poppins Light                                  | 14px, text-muted-60                             | 2:113         |
| Input label                            | Poppins Bold                                   | 16px, uppercase                                 | 2:189         |
| Input value / placeholder              | Poppins Medium                                 | 14px                                            | 2:195         |
| Input error label                      | Poppins Medium                                 | 12px, error color                               | 2:229         |
| Card title                             | Poppins Bold                                   | 16px                                            | 2:237         |
| Card price amount / unit               | Poppins Bold / Poppins Light                   | 14px / 14px                                     | 2:240         |
| Pagination number — active / inactive  | Poppins Bold (primary) / Poppins Light (white) | 14px                                            | 2:149 / 2:150 |
| Cover "COMPONENTS" title               | Poppins Bold                                   | 128px, uppercase — decorative service-page only | 16:59         |

## Auto-layout spacing

| Component         | Spacing                                                        | Node         |
| ----------------- | -------------------------------------------------------------- | ------------ |
| Header nav item   | gap 13px (column), pt 11px, height 48px, px 16px               | 2:47         |
| CTA Button (Send) | px 16px, py 11px, height 48px                                  | 2:53         |
| Accordion         | padding 24px; header gap 16px; Active-variant content gap 24px | 2:94 / 2:106 |
| Input             | label→field gap 8px; field height 48px; field px 12px          | 2:190        |
| Item card         | image→title→price gap 8px; price-row internal gap 32px         | 2:238        |

## Breakpoint-like frame widths

Single desktop-width design-system file — canvas/Header width 1440px throughout [node 2:43]; no second breakpoint (mobile/tablet) mockup exists in this source. Skill §12's CONTINUOUS/DISCRETE classification is not applicable this run — deferred to a future `/baseline` re-run or per-ticket `/spec` once responsive frames are supplied.

## Prototype reactions / motion

- Logo build-in reveal [node 4004:80 / 2:48] — see Icons above.
- Headlights Off→On [node 4004:355] — two static photo states, no motion data; likely a hover/toggle cross-fade in implementation — complex animation, human decision.

## ⚠ Pending (verification punch-list — not near-match ambiguity)

1. `eye-off` icon (48:85) not independently deep-read — assumed to mirror `eye`'s white-@-60%-opacity treatment.
2. Corner radii: only one rounded-rectangle-typed node sampled directly for radius (2:164, radius 0); Favicon backdrop and headlight-photo rounded-rectangles confirmed as real photography [nodes 2:165, 2:166, 16:57] but their corner-radius value specifically was not independently re-sampled.
3. No responsive/mobile frame exists in this source — breakpoint continuity classification deferred to a future run.
4. Motion/easing data checked only for the Logo frame — other components' hover/press transitions have no Figma-authored timing data (expected; not a gap requiring designer input).

## Design questions

See `docs/design-questions.md` Q1 and Q2, opened by this baseline run.
