# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `Button` primitive (`src/components/ui/Button.tsx`) — `filled` / `outline` variants, `asChild` slot rendering, token-only styling; 16 unit tests. (FF-8)
- `Icon` primitive (`src/components/ui/Icon.tsx`) — 8 SVG glyphs (chevron-left, chevron-down, plus, x-close, check, clock, calendar, edit) extracted verbatim from Figma (per-icon viewBox + stroke-width, no normalization); `size` prop sets rendered height with natural aspect ratio preserved, `currentColor` styling, decorative (`aria-hidden`) / meaningful (`role="img"` + `aria-label`) a11y modes; `--size-icon` token (24px); 19 unit tests. (FF-9)
