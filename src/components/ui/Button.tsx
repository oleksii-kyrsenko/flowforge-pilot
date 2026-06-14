import { Slot } from "@radix-ui/react-slot";
import type { ComponentProps, ElementType } from "react";
import { cn } from "@/lib/cn";

export type ButtonVariant = "filled" | "outline";

export interface ButtonProps extends ComponentProps<"button"> {
  /**
   * Visual style. `filled` = orange gradient CTA (Figma 2:53); `outline` =
   * 2px orange border, transparent fill, gradient label ("Read More", 2:114).
   * @default "filled"
   */
  variant?: ButtonVariant;
  /**
   * Render as the child element (e.g. a `next/link` `<a>`) instead of `<button>`,
   * merging props and forwarding the ref. Used for navigation CTAs.
   * @default false
   */
  asChild?: boolean;
}

// Shared across both variants. Tokens only — no raw values (CLAUDE.md §11).
// Gradients have no first-class v4 utility, so they ride via bg-[image:var(--…)].
const base = cn(
  "inline-flex items-center justify-center whitespace-nowrap",
  // Poppins is inherited from the document default (root layout); no per-component font class.
  "text-base rounded-none px-control py-btn-y cursor-pointer",
  // Gradient swaps are instant (CSS can't interpolate gradients); shadow/opacity ease.
  "transition-[background-image,box-shadow,opacity] duration-base ease-out",
  "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary",
  "focus-visible:ring-offset-2 focus-visible:ring-offset-background-dark",
  // Disabled appearance is a proposed default (Q17, pending designer): dim + inert.
  "disabled:pointer-events-none disabled:opacity-50 disabled:shadow-none",
);

const variantClasses: Record<ButtonVariant, string> = {
  filled: cn(
    "uppercase font-bold text-white shadow-button",
    "[text-shadow:var(--text-shadow-sm)]",
    "bg-[image:var(--gradient-primary)]",
    "hover:bg-[image:var(--gradient-primary-hover)]",
    "active:bg-[image:var(--gradient-primary-press)]",
  ),
  // White→white/40 gradient label via background-clip:text (Q3/Q4 pending tokens).
  outline: cn(
    "font-semibold border-2 border-primary bg-transparent",
    "bg-[image:var(--gradient-text-white)] bg-clip-text text-transparent",
    "[text-shadow:var(--text-shadow-md)]",
  ),
};

export function Button({
  variant = "filled",
  asChild = false,
  className,
  type,
  ...props
}: ButtonProps) {
  const Comp = (asChild ? Slot : "button") as ElementType;

  return (
    <Comp
      // Only a real <button> needs a default type; an asChild element keeps its own.
      type={asChild ? undefined : (type ?? "button")}
      className={cn(base, variantClasses[variant], className)}
      {...props}
    />
  );
}
