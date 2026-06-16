import type { ComponentProps } from "react";
import { cn } from "@/lib/cn";

// The icon set wrapped by this primitive (FF-9). Keys are the registry names.
// NOTE: Figma names the edit glyph "edit-02"; the registry key stays "edit"
// (maps to the edit-02 asset) — not renamed. See docs/design-questions.md Q22.
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
   * Rendered HEIGHT in px; width follows the glyph's natural aspect ratio
   * (1:1 for the seven 24×24 icons, ~16:15 for `edit`). Defaults to the
   * `--size-icon` token (24px) when omitted — NOT a fixed 24×24 box.
   * @default 24 (via --size-icon)
   */
  size?: number;
  /**
   * Accessible label for a MEANINGFUL icon (the icon conveys information not
   * present in adjacent text). When set, the icon is exposed as `role="img"` +
   * `aria-label` and is NOT aria-hidden. When omitted, the icon is decorative
   * and rendered `aria-hidden` (+ `focusable="false"`).
   */
  label?: string;
}

// Glyph geometry, extracted VERBATIM from Figma via download_assets format:svg
// (design-extraction skill §9). Each entry is the icon's own viewBox + stroke
// width + the inner <path id="Icon"> d — no normalization, no guessing. These
// are glyph geometry (intrinsic to the drawing), NOT design tokens. Color is
// `currentColor`; the per-instance stroke-opacity / Primary fill seen on some
// Figma instances are caller context, not encoded here.
const glyphs: Record<IconName, { viewBox: string; strokeWidth: number; d: string }> = {
  "chevron-left": { viewBox: "0 0 24 24", strokeWidth: 2, d: "M15 18L9 12L15 6" },
  "chevron-down": { viewBox: "0 0 24 24", strokeWidth: 2, d: "M6 9L12 15L18 9" },
  "x-close": { viewBox: "0 0 24 24", strokeWidth: 2, d: "M18 6L6 18M6 6L18 18" },
  check: { viewBox: "0 0 24 24", strokeWidth: 3, d: "M20 6L9 17L4 12" },
  clock: {
    viewBox: "0 0 24 24",
    strokeWidth: 1.5,
    d: "M12 6V12L16 14M22 12C22 17.5228 17.5228 22 12 22C6.47715 22 2 17.5228 2 12C2 6.47715 6.47715 2 12 2C17.5228 2 22 6.47715 22 12Z",
  },
  calendar: {
    viewBox: "0 0 24 24",
    strokeWidth: 1.5,
    d: "M21 10H3M16 2V6M8 2V6M7.8 22H16.2C17.8802 22 18.7202 22 19.362 21.673C19.9265 21.3854 20.3854 20.9265 20.673 20.362C21 19.7202 21 18.8802 21 17.2V8.8C21 7.11984 21 6.27976 20.673 5.63803C20.3854 5.07354 19.9265 4.6146 19.362 4.32698C18.7202 4 17.8802 4 16.2 4H7.8C6.11984 4 5.27976 4 4.63803 4.32698C4.07354 4.6146 3.6146 5.07354 3.32698 5.63803C3 6.27976 3 7.11984 3 8.8V17.2C3 18.8802 3 19.7202 3.32698 20.362C3.6146 20.9265 4.07354 21.3854 4.63803 21.673C5.27976 22 6.11984 22 7.8 22Z",
  },
  // plus: exported viewBox is verbatim 24×24 with the glyph drawn inset (Q21, informational).
  plus: {
    viewBox: "0 0 24 24",
    strokeWidth: 1.46813,
    d: "M11.7451 4.8938V18.5963M4.8938 11.7451H18.5963",
  },
  // edit (Figma edit-02): non-square 16×15 viewBox, verbatim (Q22, informational).
  edit: {
    viewBox: "0 0 16 15",
    strokeWidth: 1.5,
    d: "M11.9999 6.00158L9.33319 3.60095M1.6665 12.9034L3.92275 12.6777C4.19841 12.6501 4.33624 12.6364 4.46507 12.5988C4.57936 12.5655 4.68814 12.5184 4.78843 12.4589C4.90147 12.3918 4.99953 12.3035 5.19565 12.127L13.9999 4.20111C14.7362 3.53819 14.7362 2.46339 13.9999 1.80047C13.2635 1.13756 12.0696 1.13755 11.3332 1.80047L2.52899 9.72633C2.33287 9.90288 2.23481 9.99116 2.16026 10.0929C2.09413 10.1832 2.04185 10.2811 2.00485 10.384C1.96314 10.5 1.94783 10.6241 1.9172 10.8722L1.6665 12.9034Z",
  },
};

export function Icon({
  name,
  size = undefined,
  label = undefined,
  className,
  style,
  ...props
}: IconProps) {
  const glyph = glyphs[name];
  // No label → decorative (hidden from assistive tech). Label → meaningful.
  const a11y: Pick<
    ComponentProps<"svg">,
    "aria-hidden" | "focusable" | "role" | "aria-label"
  > = label === undefined
    ? { "aria-hidden": true, focusable: "false" }
    : { role: "img", "aria-label": label };

  return (
    <svg
      viewBox={glyph.viewBox}
      fill="none"
      stroke="currentColor"
      strokeWidth={glyph.strokeWidth}
      strokeLinecap="round"
      strokeLinejoin="round"
      // Height = the --size-icon token by default (no raw literal); an explicit
      // `size` overrides it. Width is `auto` so it follows the viewBox aspect.
      className={cn("w-auto", size === undefined && "h-(--size-icon)", className)}
      style={size === undefined ? style : { height: size, ...style }}
      {...props}
      {...a11y}
    >
      <path d={glyph.d} />
    </svg>
  );
}
