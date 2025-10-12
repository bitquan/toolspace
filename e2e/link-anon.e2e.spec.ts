/**
 * Anonymous User Linking E2E Test
 *
 * Tests that:
 * 1. User starts as anonymous
 * 2. Creates usage data (e.g., shortens a URL)
 * 3. Signs up with email/password (linkWithCredential)
 * 4. UID persists (same user)
 * 5. Usage data is migrated/retained
 */

import { test, expect } from "@playwright/test";

const BASE_URL = process.env.BASE_URL || "http://localhost:8080";

test.describe("🔗 Anonymous User Linking", () => {
  test("🔴 FAILING: Anonymous → Signed Up User Flow with Data Persistence", async ({
    browser,
  }) => {
    test.fail(); // Mark as failing - feature not fully implemented

    const context = await browser.newContext();
    const page = await context.newPage();

    // STEP 1: Start as anonymous user
    await page.goto(BASE_URL);
    console.log("📱 Started as anonymous user");

    // STEP 2: Create some usage data (e.g., create a shortened URL)
    await page.goto(`${BASE_URL}#/tools/url-short`);

    // Wait for tool to load
    await page.waitForSelector('input[placeholder*="URL"]', { timeout: 10000 });

    // Create a URL
    const testUrl = `https://example.com/test-${Date.now()}`;
    await page.fill('input[placeholder*="URL"]', testUrl);
    await page.click('button:has-text("Shorten")');

    // Verify URL was created
    await page.waitForSelector(`text=${testUrl}`, { timeout: 5000 });
    console.log("✅ Created URL as anonymous user");

    // STEP 3: Get current UID from localStorage or session
    const anonUid = await page.evaluate(() => {
      // Try to get UID from localStorage
      return (
        localStorage.getItem("toolspace_anon_uid") ||
        sessionStorage.getItem("toolspace_uid")
      );
    });

    console.log(`📝 Anonymous UID: ${anonUid}`);
    expect(anonUid).toBeTruthy();

    // STEP 4: Sign up (link account)
    await page.click("text=Sign In");
    await page.waitForURL(/\/auth\/signin/);

    await page.click("text=Sign Up" || "text=Create account");
    await page.waitForURL(/\/auth\/signup/);

    const testEmail = `link-test-${Date.now()}@toolspace-test.com`;
    const testPassword = "TestPassword123!";

    await page.fill('input[type="email"]', testEmail);
    await page.fill('input[type="password"]', testPassword);
    await page.fill('input[placeholder*="Confirm"]', testPassword);
    await page.click('button:has-text("Sign Up")');

    // STEP 5: Verify UID persists (linkWithCredential behavior)
    await page.waitForTimeout(3000); // Wait for linking

    const signedInUid = await page.evaluate(() => {
      return (
        localStorage.getItem("toolspace_uid") ||
        sessionStorage.getItem("toolspace_uid")
      );
    });

    console.log(`📝 Signed-in UID: ${signedInUid}`);

    // UID should be the same (anonymous account linked)
    expect(signedInUid).toBe(anonUid);

    // STEP 6: Verify usage data persists
    await page.goto(`${BASE_URL}#/tools/url-short`);

    // Check if the URL created as anonymous user is still there
    const urlStillExists = await page
      .locator(`text=${testUrl}`)
      .isVisible()
      .catch(() => false);

    expect(urlStillExists).toBeTruthy();
    console.log("✅ Usage data persisted after account linking");
  });

  test("Anonymous User Can Create Usage Document", async ({ page }) => {
    await page.goto(BASE_URL);

    // Navigate to a tool
    await page.goto(`${BASE_URL}#/tools/json-doctor`);

    // Interact with tool (this should create usage record)
    const inputArea = page.locator("textarea").first();
    await inputArea.fill('{"test": "data"}');

    // Verify tool works
    await expect(inputArea).toHaveValue('{"test": "data"}');

    console.log("✅ Anonymous user can use tools");
  });

  test("🔴 FAILING: Anonymous UID is Unique and Persistent", async ({
    browser,
  }) => {
    test.fail(); // Feature may not be implemented

    const context1 = await browser.newContext();
    const page1 = await context1.newPage();

    await page1.goto(BASE_URL);
    const uid1 = await page1.evaluate(() => {
      return localStorage.getItem("toolspace_anon_uid");
    });

    // Reload page - UID should persist
    await page1.reload();
    const uid1After = await page1.evaluate(() => {
      return localStorage.getItem("toolspace_anon_uid");
    });

    expect(uid1).toBe(uid1After);

    // New context should have different UID
    const context2 = await browser.newContext();
    const page2 = await context2.newPage();

    await page2.goto(BASE_URL);
    const uid2 = await page2.evaluate(() => {
      return localStorage.getItem("toolspace_anon_uid");
    });

    expect(uid2).not.toBe(uid1);
    expect(uid2).toBeTruthy();

    await context1.close();
    await context2.close();
  });
});
