---
name: seo
description: SEO reference for FlowForge route/page-level work — Next.js Metadata API rules, JSON-LD structured-data templates, and a landmark/heading checklist. Use when /spec writes the SEO requirements line for a route ticket and when /review verifies route-level SEO.
---

# SEO reference (Next.js App Router)

For route/page-level tickets only. Component tickets use semantic HTML + a11y as the SEO
baseline. There is no dedicated SEO subagent — the analyst applies this for requirements,
the reviewer for verification.

## 1. Metadata API

- Export `metadata: Metadata` for static, or `generateMetadata()` for dynamic routes.
- Always set: `title` (unique, ≤ ~60 chars), `description` (≤ ~155 chars).
- Open Graph: `openGraph: { title, description, url, images: [{ url, width, height, alt }] }`.
- Twitter: `twitter: { card: "summary_large_image", title, description, images }`.
- Set `metadataBase` (in the root layout) so relative OG/canonical URLs resolve.
- Canonical: `alternates: { canonical: "/path" }` to avoid duplicate-content dilution.
- `robots` only when intentionally diverging from index/follow defaults.

```ts
export const metadata: Metadata = {
  title: "Page title",
  description: "Concise, unique page description.",
  alternates: { canonical: "/path" },
  openGraph: { title: "Page title", description: "…", url: "/path", images: ["/og.png"] },
};
```

## 2. JSON-LD structured data

Inject only the type that matches the content. Render as a `<script type="application/ld+json">`
with serialized JSON (use `dangerouslySetInnerHTML` with `JSON.stringify`).
Common types: `Organization`, `WebSite` (+ SearchAction), `BreadcrumbList`, `Article`,
`Product` (+ `Offer`), `FAQPage`. Skeleton:

```tsx
<script
  type="application/ld+json"
  dangerouslySetInnerHTML={{
    __html: JSON.stringify({
      "@context": "https://schema.org",
      "@type": "Organization",
      name: "…",
      url: "https://…",
    }),
  }}
/>
```

## 3. Landmark & heading checklist

- Exactly one `<h1>` per page; no skipped heading levels (h1 → h2 → h3).
- Landmarks present and singular where required: `<header> <nav> <main> <footer>`;
  one `<main>` per page.
- All images have meaningful `alt` (empty `alt=""` only for decorative).
- Links are descriptive (no "click here"); `next/link` for internal navigation.
- Language set on `<html lang>`; viewport meta handled by Next defaults.
- Use `next/image` with explicit sizing to avoid layout shift (CWV).
