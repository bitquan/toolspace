import { defineConfig, devices } from "@playwright/test";

/**
 * Playwright configuration for UX smoke tests
 *
 * Tests the Flutter web build at http://localhost:4173
 * Captures screenshots on failure to .artifacts/
 */
export default defineConfig({
  testDir: "./",
  testMatch: "**/*.spec.ts",

  // Fail the build on CI if tests fail
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,

  // Reporter configuration
  reporter: [["html", { outputFolder: ".artifacts/html-report" }], ["list"]],

  // Shared settings for all tests
  use: {
    baseURL: "http://localhost:4173",
    trace: "on-first-retry",
    screenshot: "only-on-failure",
    video: "retain-on-failure",
  },

  // Output directory for test artifacts
  outputDir: ".artifacts",

  // Test against Chromium only (sufficient for smoke tests)
  projects: [
    {
      name: "chromium",
      use: { ...devices["Desktop Chrome"] },
    },
  ],

  // Don't start a dev server (we'll serve build/web manually)
  webServer: undefined,
});
