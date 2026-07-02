# Behaviour → library map

A companion reference to the `design-extraction` skill (§11 Behaviour derivation, §12 Breakpoint
continuity). It maps an observed UI behaviour/pattern to a vetted **default** implementation, so
`/spec`'s behaviour derivation and `/build`'s implementation choice are not each re-deciding
library-vs-CSS from scratch per ticket.

## Boundary — this is a `/build`-side default, never a spec-level pin

`/spec` (analyst) consults this map only to know what vocabulary of patterns exists and to cite the
default as **informational context** — it never pins an implementation in the spec (the
design-extraction skill's "no unnecessary client JS, not zero-JS" boundary stays intact; a spec that
pins a library is making a build-time decision the analyst isn't positioned to make). `/build`
consults this map to make the actual implementation pick, and MAY deviate from the default with a
documented reason (a cheap/reversible deviation is reported; a real tradeoff goes to the human).

## Map (seed entries — grow only via the expansion rule below)

| Behaviour pattern                            | Default implementation | Notes                                                                                                                 |
| -------------------------------------------- | ---------------------- | --------------------------------------------------------------------------------------------------------------------- |
| Carousel / paginated multi-item row          | **Swiper**             | Keyboard + ARIA accessible out of the box; prev/next + pagination-dot support built in.                               |
| Continuous marquee (repeating row, no pause) | **react-fast-marquee** | CSS-transform-based, no unnecessary JS overhead; respects `prefers-reduced-motion` when configured.                   |
| Accordion / expand-collapse                  | **Radix UI Accordion** | Headless, a11y-correct (`aria-expanded`, `aria-controls`, keyboard) out of the box — pairs with any visual treatment. |

These are DEFAULTS, not an exhaustive catalogue — populated from real ticket needs, not a speculative
survey of every possible UI pattern.

## Expansion rule

When a ticket exhibits a behaviour pattern with **no existing map entry**, the agent ADDS an entry to
this map **in the same cycle**, under **human confirm** — a new standing default is a real decision,
not a class-A pick. **Never leave an unrecorded ad-hoc library choice implicit in one component's
code** — an unrecorded pick is exactly the failure mode this map exists to prevent (the same
verify-or-omit spirit CLAUDE.md applies to facts, applied here to implementation defaults).
