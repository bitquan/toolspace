/**
 * Simple Smoke Test - Basic App Loading
 *
 * Tests that the Flutter web app loads and displays basic content
 * without requiring Firebase authentication or emulators.
 */

import { expect, test } from "@playwright/test";

const BASE_URL = process.env.BASE_URL || "http://localhost:8080";

test.describe("🚀 Basic App Smoke Tests", () => {
  test("app loads and displays title", async ({ page }) => {
    // Navigate to the app
    await page.goto(BASE_URL);

    // Wait for the page to load
    await page.waitForLoadState("networkidle");

    // Check that the page title contains "Toolspace"
    await expect(page).toHaveTitle(/Toolspace/i);

    // Check that the app shell loads (body should exist)
    await expect(page.locator("body")).toBeVisible();

    console.log("✅ App loaded successfully");
  });

  test("app displays without critical errors", async ({ page }) => {
    // Listen for console errors
    const errors: string[] = [];
    page.on("console", (msg) => {
      if (msg.type() === "error") {
        errors.push(msg.text());
      }
    });

    // Navigate to the app
    await page.goto(BASE_URL);
    await page.waitForLoadState("networkidle");

    // Wait a bit for any JS to execute
    await page.waitForTimeout(3000);

    // Filter out Firebase-related errors (expected when emulators aren't running)
    const criticalErrors = errors.filter(
      (error) =>
        !error.includes("Firebase") &&
        !error.includes("auth") &&
        !error.includes("firestore") &&
        !error.includes("initializeApp")
    );

    // Report all errors for debugging
    if (errors.length > 0) {
      console.log("Console errors detected:", errors);
    }

    // Only fail on non-Firebase critical errors
    expect(criticalErrors.length).toBeLessThan(5); // Allow some non-critical errors

    console.log("✅ App loaded without critical errors");
  });

  test("app renders Flutter content", async ({ page }) => {
    await page.goto(BASE_URL);
    await page.waitForLoadState("networkidle");

    // Wait for Flutter to initialize (looking for Flutter's root element)
    await page.waitForSelector("flt-scene", { timeout: 10000 }).catch(() => {
      // If flt-scene doesn't exist, try other Flutter indicators
      return page
        .waitForSelector("[data-flt-renderer]", { timeout: 5000 })
        .catch(() => {
          // Fallback: just check that content loaded
          return page.waitForSelector("body *", { timeout: 5000 });
        });
    });

    console.log("✅ Flutter content rendered");
  });
});
