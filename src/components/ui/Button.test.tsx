import { describe, expect, it, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { Button } from "./Button";

describe("Button", () => {
  // AC1 — variants cover what changes between mockup instances (filled 2:53 / outline 2:114).
  describe("AC1: variants", () => {
    it("defaults to the filled gradient variant", () => {
      render(<Button>Book Now</Button>);
      const btn = screen.getByRole("button", { name: "Book Now" });
      expect(btn.className).toContain("bg-[image:var(--gradient-primary)]");
      expect(btn.className).toContain("uppercase");
    });

    it("renders the outline variant with border + gradient-clipped label", () => {
      render(<Button variant="outline">Read More</Button>);
      const btn = screen.getByRole("button", { name: "Read More" });
      expect(btn.className).toContain("border-primary");
      expect(btn.className).toContain("bg-clip-text");
      expect(btn.className).toContain("text-transparent");
    });
  });

  // AC2 — states default/hover/press/focus-visible/disabled, diffed from the swatch set.
  describe("AC2: states", () => {
    it("declares hover and active gradient swaps on the filled variant", () => {
      render(<Button>CTA</Button>);
      const btn = screen.getByRole("button", { name: "CTA" });
      expect(btn.className).toContain("hover:bg-[image:var(--gradient-primary-hover)]");
      expect(btn.className).toContain("active:bg-[image:var(--gradient-primary-press)]");
    });

    it("declares a focus-visible ring", () => {
      render(<Button>CTA</Button>);
      const btn = screen.getByRole("button", { name: "CTA" });
      expect(btn.className).toContain("focus-visible:ring-primary");
    });

    it("renders a disabled, non-interactive button", async () => {
      const onClick = vi.fn();
      render(
        <Button disabled onClick={onClick}>
          CTA
        </Button>,
      );
      const btn = screen.getByRole("button", { name: "CTA" });
      expect(btn).toBeDisabled();
      expect(btn.className).toContain("disabled:opacity-50");
      await userEvent.click(btn);
      expect(onClick).not.toHaveBeenCalled();
    });
  });

  // AC3 — padding/radius/colors from tokens; no raw values leak into markup.
  describe("AC3: token-only styling", () => {
    it("uses token utilities and no raw hex or px literals", () => {
      render(<Button variant="outline">X</Button>);
      const { className } = screen.getByRole("button", { name: "X" });
      expect(className).toContain("py-btn-y");
      expect(className).toContain("px-control");
      expect(className).not.toMatch(/#[0-9a-f]{3,6}\b/i);
      expect(className).not.toMatch(/\[\d+px\]/);
    });
  });

  // AC4 — <button> by default; asChild renders the child, merges props, forwards onClick.
  describe("AC4: element & asChild", () => {
    it("renders a native <button> with a default type", () => {
      render(<Button>Go</Button>);
      const btn = screen.getByRole("button", { name: "Go" });
      expect(btn.tagName).toBe("BUTTON");
      expect(btn).toHaveAttribute("type", "button");
    });

    it("fires onClick when activated", async () => {
      const onClick = vi.fn();
      render(<Button onClick={onClick}>Go</Button>);
      await userEvent.click(screen.getByRole("button", { name: "Go" }));
      expect(onClick).toHaveBeenCalledTimes(1);
    });

    it("renders the child element and merges classes when asChild", () => {
      render(
        <Button asChild>
          <a href="/cars">View all</a>
        </Button>,
      );
      const link = screen.getByRole("link", { name: "View all" });
      expect(link).toHaveAttribute("href", "/cars");
      // Slot merges the Button base classes onto the child.
      expect(link.className).toContain("font-poppins");
      // No spurious button type on a non-button child.
      expect(link).not.toHaveAttribute("type");
    });
  });

  // AC5 — keyboard operable, accessible name from children, disabled out of tab order.
  describe("AC5: a11y", () => {
    it("is keyboard focusable and activates on Enter", async () => {
      const onClick = vi.fn();
      render(<Button onClick={onClick}>Submit</Button>);
      await userEvent.tab();
      const btn = screen.getByRole("button", { name: "Submit" });
      expect(btn).toHaveFocus();
      await userEvent.keyboard("{Enter}");
      expect(onClick).toHaveBeenCalled();
    });

    it("activates on Space", async () => {
      const onClick = vi.fn();
      render(<Button onClick={onClick}>Submit</Button>);
      await userEvent.tab();
      await userEvent.keyboard("[Space]");
      expect(onClick).toHaveBeenCalled();
    });

    it("takes its accessible name from children", () => {
      render(<Button>Reserve now</Button>);
      expect(screen.getByRole("button", { name: "Reserve now" })).toBeInTheDocument();
    });

    it("is removed from the tab order when disabled", async () => {
      render(<Button disabled>Nope</Button>);
      await userEvent.tab();
      expect(screen.getByRole("button", { name: "Nope" })).not.toHaveFocus();
    });
  });
});
