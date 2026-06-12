import { defineConfig } from "vitest/config";
import react from "@vitejs/plugin-react";

// Unit/integration tests (Vitest + RTL + jsdom). E2E lives in tests/e2e and runs
// via Playwright (`npm run e2e`) — never through Vitest, never in git hooks.
export default defineConfig({
  plugins: [react()],
  resolve: {
    // Resolve the "@/*" -> "./src/*" alias from tsconfig.json natively.
    tsconfigPaths: true,
  },
  test: {
    environment: "jsdom",
    globals: true,
    setupFiles: ["./vitest.setup.ts"],
    include: ["src/**/*.{test,spec}.{ts,tsx}"],
    exclude: ["node_modules", ".next", "tests/e2e/**"],
  },
});
