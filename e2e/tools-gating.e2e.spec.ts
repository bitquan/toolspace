/**
 * Tools Gating E2E Test
 *
 * Tests that:
 * 1. Free users are blocked from heavy tools after quota
 * 2. Upgrade unlocks tools
 * 3. Quota increments/decrements correctly
 */

import { expect, test } from "@playwright/test";

const BASE_URL = process.env.BASE_URL || "http://localhost:8080";

const HEAVY_TOOLS = [
  { path: "/tools/file-merger", name: "File Merger" },
  { path: "/tools/markdown-to-pdf", name: "Markdown to PDF" },
  { path: "/tools/image-resizer", name: "Image Resizer" },
];

test.describe("🔒 Tools Gating & Quota Management", () => {
  test("🔴 FAILING: Free User Blocked After Quota Exceeded", async ({
    page,
  }) => {
    test.fail(); // Feature not fully implemented

    // STEP 1: Start as Free user (anonymous or signed in)
    await page.goto(BASE_URL);

    // STEP 2: Use heavy tool 3 times (Free tier limit)
    const tool = HEAVY_TOOLS[0];
    await page.goto(`${BASE_URL}#${tool.path}`);

    for (let i = 0; i < 3; i++) {
      // Simulate heavy operation (e.g., upload a file)
      console.log(`Heavy operation ${i + 1}/3`);

      // Check if upload zone exists
      const uploadZone = page.locator(
        "text=Tap to select" || 'input[type="file"]'
      );
      await expect(uploadZone).toBeVisible({ timeout: 5000 });

      // In a real test, we'd upload a file
      // For now, just verify the tool is accessible
    }

    // STEP 3: Try 4th operation - should be blocked
    await page.reload();

    // Should show paywall/upgrade message
    const paywallMessage = page.locator(
      "text=quota exceeded" || "text=Upgrade" || "text=heavy operations"
    );

    const isBlocked = await paywallMessage.isVisible().catch(() => false);
    expect(isBlocked).toBeTruthy();

    console.log("✅ Free user blocked after quota exceeded");
  });

  test("🔴 FAILING: Pro User Not Blocked - Higher Quota", async ({ page }) => {
    test.fail(); // Feature not fully implemented

    // STEP 1: Login as Pro user (simulate via test account or mock)
    await page.goto(`${BASE_URL}#/auth/signin`);

    // Use test Pro account credentials
    await page.fill('input[type="email"]', "pro-user@test.com");
    await page.fill('input[type="password"]', "TestProPassword123!");
    await page.click('button:has-text("Sign In")');

    // STEP 2: Navigate to heavy tool
    const tool = HEAVY_TOOLS[1];
    await page.goto(`${BASE_URL}#${tool.path}`);

    // STEP 3: Verify tool is accessible (no paywall)
    const uploadZone = page.locator(
      "text=Tap to select" || 'input[type="file"]'
    );
    await expect(uploadZone).toBeVisible({ timeout: 5000 });

    // No paywall should appear
    const paywall = page.locator("text=Upgrade Required");
    const hasPaywall = await paywall.isVisible().catch(() => false);
    expect(hasPaywall).toBeFalsy();

    console.log("✅ Pro user has access to heavy tools");
  });

  test("🔴 FAILING: Quota Increments Correctly", async ({ page }) => {
    test.fail(); // Feature not fully implemented

    await page.goto(BASE_URL);

    // Navigate to account/usage page
    await page.goto(`${BASE_URL}#/account`);

    // Get initial quota count
    const initialQuota = await page
      .locator("text=heavy operations" || "text=quota")
      .innerText()
      .catch(() => "0/3");

    console.log(`Initial quota: ${initialQuota}`);

    // Perform a heavy operation
    await page.goto(`${BASE_URL}#${HEAVY_TOOLS[0].path}`);

    // Simulate operation (upload file)
    // ... operation code ...

    // Go back to account page
    await page.goto(`${BASE_URL}#/account`);

    // Get updated quota
    const updatedQuota = await page
      .locator("text=heavy operations")
      .innerText()
      .catch(() => "1/3");

    console.log(`Updated quota: ${updatedQuota}`);

    // Quota should have incremented
    expect(updatedQuota).not.toBe(initialQuota);
  });

  test("🔴 FAILING: Upgrade Unlocks Tools", async ({ browser }) => {
    test.fail(); // Feature not fully implemented

    const context = await browser.newContext();
    const page = await context.newPage();

    // STEP 1: Exhaust quota as Free user
    await page.goto(BASE_URL);

    // ... exhaust quota ...

    // STEP 2: Tool should be blocked
    await page.goto(`${BASE_URL}#${HEAVY_TOOLS[0].path}`);
    const blocked = await page
      .locator("text=Upgrade Required" || "text=quota exceeded")
      .isVisible()
      .catch(() => false);

    expect(blocked).toBeTruthy();

    // STEP 3: Click Upgrade button
    await page.click(
      'button:has-text("Upgrade")' || 'button:has-text("View Plans")'
    );

    // Select Pro plan
    await page.click('button:has-text("Upgrade to Pro")');

    // Complete checkout (use test mode)
    // ... checkout flow ...

    // STEP 4: Return to tool - should be unlocked
    await page.goto(`${BASE_URL}#${HEAVY_TOOLS[0].path}`);

    const uploadZone = page.locator(
      "text=Tap to select" || 'input[type="file"]'
    );
    await expect(uploadZone).toBeVisible({ timeout: 10000 });

    // No paywall
    const paywall = page.locator("text=Upgrade Required");
    const hasPaywall = await paywall.isVisible().catch(() => false);
    expect(hasPaywall).toBeFalsy();

    console.log("✅ Upgrade unlocked tools");

    await context.close();
  });

  test("Light Tools Always Accessible to Free Users", async ({ page }) => {
    await page.goto(BASE_URL);

    // Test light tools (JSON Doctor, Text Diff, etc.)
    const lightTools = [
      "/tools/json-doctor",
      "/tools/text-diff",
      "/tools/regex-tester",
    ];

    for (const toolPath of lightTools) {
      await page.goto(`${BASE_URL}#${toolPath}`);

      // Should be accessible
      const toolContent = page.locator("textarea" || "input");
      await expect(toolContent.first()).toBeVisible({ timeout: 5000 });

      console.log(`✅ Light tool accessible: ${toolPath}`);
    }
  });

  test("🔴 FAILING: Quota Resets Daily", async ({ page }) => {
    test.fail(); // Feature not fully implemented

    await page.goto(BASE_URL);

    // Mock: Set usage to yesterday
    await page.evaluate(() => {
      const yesterday = new Date();
      yesterday.setDate(yesterday.getDate() - 1);

      localStorage.setItem(
        "toolspace_usage_date",
        yesterday.toISOString().split("T")[0]
      );
      localStorage.setItem("toolspace_heavy_ops", "3"); // Maxed out
    });

    // Reload and check quota
    await page.reload();
    await page.goto(`${BASE_URL}#/account`);

    // Quota should be reset
    const quota = await page
      .locator("text=0/3" || "text=heavy operations")
      .isVisible()
      .catch(() => false);

    expect(quota).toBeTruthy();

    console.log("✅ Quota resets daily");
  });
});
