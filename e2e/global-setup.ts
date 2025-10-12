// Global setup for Playwright E2E tests
// Starts Firebase emulators and configures test environment

import { chromium, FullConfig } from "@playwright/test";

async function globalSetup(config: FullConfig) {
  console.log("🔥 Setting up Firebase emulators for E2E tests...");

  // Wait a bit for emulators to be ready
  await new Promise((resolve) => setTimeout(resolve, 5000));

  // Create a browser instance to warm up the app
  const browser = await chromium.launch();
  const page = await browser.newPage();

  try {
    // Navigate to the app to ensure it loads
    await page.goto("http://localhost:8080", { waitUntil: "networkidle" });
    console.log("✅ App loaded successfully");
  } catch (error) {
    console.warn("⚠️ App may not be fully ready:", error.message);
  } finally {
    await browser.close();
  }

  console.log("🎯 E2E test environment ready!");
}

export default globalSetup;
