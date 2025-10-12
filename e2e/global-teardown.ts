// Global teardown for Playwright E2E tests
// Cleans up Firebase emulators and test environment

import { FullConfig } from "@playwright/test";

async function globalTeardown(config: FullConfig) {
  console.log("🧹 Cleaning up E2E test environment...");

  // Note: Firebase emulators will be automatically stopped by Playwright
  // when the webServer processes are terminated

  console.log("✅ E2E teardown complete");
}

export default globalTeardown;
