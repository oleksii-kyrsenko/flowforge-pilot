import { defineConfig, globalIgnores } from "eslint/config";
import { plugins, configs } from "eslint-config-airbnb-extended";
import eslintConfigPrettier from "eslint-config-prettier";

// Airbnb-extended owns all plugin registration (flat-config, ESLint 9). It bundles
// @next/eslint-plugin-next, so Next.js coverage is preserved without eslint-config-next
// (whose plugin registrations would collide with Airbnb's in flat config).
const eslintConfig = defineConfig([
  // Register plugins once.
  plugins.stylistic,
  plugins.importX,
  plugins.node,
  plugins.react,
  plugins.reactA11y,
  plugins.reactHooks,
  plugins.next,
  plugins.typescriptEslint,
  // Airbnb rule sets: base -> React -> Next, each with its TypeScript layer.
  ...configs.base.recommended,
  ...configs.base.typescript,
  ...configs.react.recommended,
  ...configs.react.typescript,
  ...configs.next.recommended,
  ...configs.next.typescript,
  // Project conventions that intentionally differ from Airbnb defaults.
  {
    rules: {
      // CLAUDE.md s.11 "Code standards": components and modules use NAMED exports.
      "import-x/prefer-default-export": "off",
    },
  },
  // Tooling, config, and test files legitimately import devDependencies.
  {
    files: [
      "**/*.config.{js,mjs,cjs,ts,mts}",
      "**/*.{test,spec}.{ts,tsx}",
      "vitest.setup.ts",
      "tests/**",
    ],
    rules: {
      "import-x/no-extraneous-dependencies": "off",
    },
  },
  // Prettier last — turn off every stylistic rule that would fight the formatter.
  eslintConfigPrettier,
  globalIgnores([".next/**", "out/**", "build/**", "next-env.d.ts"]),
]);

export default eslintConfig;
