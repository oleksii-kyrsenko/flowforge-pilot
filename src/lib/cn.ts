/**
 * Join conditional class names into a single space-separated string.
 * Falsy values are dropped. A tiny utility that also serves as the bootstrap
 * smoke target so the test runner is green from day one.
 */
export function cn(...classes: (string | false | null | undefined)[]): string {
  return classes.filter(Boolean).join(" ");
}
