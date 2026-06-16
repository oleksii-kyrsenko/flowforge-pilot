import { describe, expect, it } from "vitest";
import { render, screen } from "@testing-library/react";
import { Icon } from "./Icon";

// Verbatim per-icon geometry (viewBox + stroke-width) extracted from Figma via
// download_assets svg — the source of truth the spec's geometry table records.
const GEOMETRY = [
  ["chevron-left", "0 0 24 24", "2"],
  ["chevron-down", "0 0 24 24", "2"],
  ["x-close", "0 0 24 24", "2"],
  ["check", "0 0 24 24", "3"],
  ["clock", "0 0 24 24", "1.5"],
  ["calendar", "0 0 24 24", "1.5"],
  ["plus", "0 0 24 24", "1.46813"],
  ["edit", "0 0 16 15", "1.5"],
] as const;

function renderIcon(props: Parameters<typeof Icon>[0]) {
  const { container } = render(<Icon {...props} />);
  const svg = container.querySelector("svg");
  if (!svg) throw new Error("Icon did not render an <svg>");
  return svg;
}

describe("Icon", () => {
  // AC1 — all 8 render as an <svg> with the icon's verbatim viewBox + stroke-width.
  describe("AC1: renders each named icon with verbatim geometry", () => {
    it.each(GEOMETRY)(
      "renders %s with viewBox %s and stroke-width %s",
      (name, viewBox, strokeWidth) => {
        const svg = renderIcon({ name });
        expect(svg).toBeInTheDocument();
        expect(svg).toHaveAttribute("viewBox", viewBox);
        expect(svg).toHaveAttribute("stroke-width", strokeWidth);
        expect(svg.querySelector("path")).toBeInTheDocument();
      },
    );

    it("draws the chevron-left path verbatim", () => {
      const svg = renderIcon({ name: "chevron-left" });
      expect(svg.querySelector("path")).toHaveAttribute("d", "M15 18L9 12L15 6");
    });
  });

  // AC2 — size sets rendered height (default via --size-icon token); width follows
  // the glyph's natural aspect (square for the 24×24 icons, ~16:15 for edit).
  describe("AC2: size = rendered height, aspect preserved", () => {
    it("defaults height to the --size-icon token and lets width follow the viewBox", () => {
      const svg = renderIcon({ name: "check" });
      expect(svg).toHaveClass("h-(--size-icon)");
      expect(svg).toHaveClass("w-auto");
      // No raw pixel literal for the default height.
      expect(svg.getAttribute("style") ?? "").not.toMatch(/height/);
    });

    it("applies an explicit numeric size as the rendered height", () => {
      const svg = renderIcon({ name: "check", size: 32 });
      expect(svg.getAttribute("style")).toContain("height: 32px");
      expect(svg).toHaveClass("w-auto");
      // The token default is not applied once an explicit size is given.
      expect(svg).not.toHaveClass("h-(--size-icon)");
    });

    it("preserves each glyph's natural aspect via its verbatim viewBox", () => {
      // Square icon → square viewBox; edit → non-square 16:15 viewBox.
      expect(renderIcon({ name: "chevron-left" })).toHaveAttribute("viewBox", "0 0 24 24");
      expect(renderIcon({ name: "edit" })).toHaveAttribute("viewBox", "0 0 16 15");
    });
  });

  // AC3 — color from currentColor; no hardcoded fill/stroke color.
  describe("AC3: currentColor, no hardcoded color", () => {
    it("strokes with currentColor and no fill", () => {
      const svg = renderIcon({ name: "calendar" });
      expect(svg).toHaveAttribute("stroke", "currentColor");
      expect(svg).toHaveAttribute("fill", "none");
    });

    it("emits no hardcoded hex color anywhere in the markup", () => {
      const svg = renderIcon({ name: "edit" });
      expect(svg.outerHTML).not.toMatch(/#[0-9a-f]{3,6}\b/i);
    });
  });

  // AC4 — decorative by default: hidden from assistive tech, no accessible name.
  describe("AC4: decorative (no label)", () => {
    it("is aria-hidden and not focusable, with no accessible name", () => {
      const svg = renderIcon({ name: "x-close" });
      expect(svg).toHaveAttribute("aria-hidden", "true");
      expect(svg).toHaveAttribute("focusable", "false");
      expect(screen.queryByRole("img")).not.toBeInTheDocument();
    });
  });

  // AC5 — meaningful when labeled: role="img" + aria-label, not aria-hidden.
  describe("AC5: meaningful (label)", () => {
    it("exposes role=img + aria-label and is not aria-hidden", () => {
      renderIcon({ name: "check", label: "Booking confirmed" });
      const svg = screen.getByRole("img", { name: "Booking confirmed" });
      expect(svg).toBeInTheDocument();
      expect(svg).not.toHaveAttribute("aria-hidden");
    });
  });

  // AC6 — an unknown name is rejected at compile time by the IconName union
  // (no runtime fallback). Enforced by tsc (the gate); asserted here on a
  // traceable, AC-linked line via @ts-expect-error.
  describe("AC6: type-safe name", () => {
    it("rejects an unknown icon name at compile time", () => {
      // @ts-expect-error — a name outside the IconName union is a compile error.
      const invalid = <Icon name="not-an-icon" />;
      // Creating the element does not invoke the component; this exists so the
      // union guard is exercised by the type checker, not at runtime.
      expect(invalid).toBeTruthy();
    });
  });

  // AC7 (a11y smoke) — both modes expose coherent semantics.
  describe("a11y smoke", () => {
    it("decorative icon has no role and no accessible name", () => {
      const svg = renderIcon({ name: "clock" });
      expect(svg).not.toHaveAttribute("role");
      expect(svg).not.toHaveAttribute("aria-label");
    });

    it("labeled icon carries exactly its label as the accessible name", () => {
      renderIcon({ name: "clock", label: "Pending" });
      expect(screen.getByRole("img", { name: "Pending" })).toBeInTheDocument();
    });
  });
});
