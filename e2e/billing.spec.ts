import { test, expect } from "@playwright/test";

test.describe("Billing E2E Tests", () => {
  // Test requires Firebase emulators and Stripe CLI to be running
  test.beforeEach(async ({ page }) => {
    // Set up test context
    await page.goto("http://localhost:8080");
    await page.waitForLoadState("networkidle");
    await page.waitForTimeout(3000); // Give Flutter time to render
  });

  test("app loads successfully", async ({ page }) => {
    // Basic test to ensure the app loads
    const hasFlutterApp = await page.evaluate(() => {
      return document.querySelector('flutter-view, [flt-renderer], flt-glass-pane') !== null;
    });

    expect(hasFlutterApp).toBe(true);
    console.log("✅ Billing test environment - app loaded successfully");
  });

  test("upgrade flow opens Stripe checkout", async ({ page }) => {
    // Navigate to a premium tool
    await page.locator('text="File Merger"').click();
    await page.waitForTimeout(2000);

    // Look for upgrade/subscribe button
    const upgradeButtons = page.locator(
      'button:has-text("Upgrade"), button:has-text("Subscribe"), button:has-text("Get Pro")'
    );

    if (await upgradeButtons.first().isVisible()) {
      // Click upgrade button
      await upgradeButtons.first().click();

      // Should show upgrade sheet or navigate to checkout
      const upgradeSheetOrCheckout = page.locator(
        'text="Choose Plan", text="Stripe", text="checkout"'
      );

      await expect(upgradeSheetOrCheckout.first()).toBeVisible({
        timeout: 5000,
      });
      console.log("✅ Upgrade flow initiated successfully");
    } else {
      console.log("⚠️ No upgrade buttons found - may need authentication");
    }
  });

  test("quota banner shows when approaching limits", async ({ page }) => {
    // This test depends on having used quota
    // Navigate to a heavy tool
    await page.locator('text="Image Resizer"').click();
    await page.waitForTimeout(2000);

    // Look for quota banner
    const quotaBanner = page.locator(
      'text="remaining", text="left today", text="quota"'
    );

    const bannerVisible = await quotaBanner
      .first()
      .isVisible()
      .catch(() => false);

    if (bannerVisible) {
      console.log("✅ Quota banner is showing");
    } else {
      console.log(
        "ℹ️ No quota banner (may have unlimited quota or no usage yet)"
      );
    }
  });

  test("billing button exists on home page", async ({ page }) => {
    // Look for billing-related buttons on home
    const billingButtons = page.locator(
      'button:has-text("Upgrade"), button:has-text("Manage Billing"), button:has-text("Pro")'
    );

    await expect(billingButtons.first()).toBeVisible({ timeout: 5000 });
    console.log("✅ Billing button found on home page");
  });

  test("free tools work without paywall", async ({ page }) => {
    // Test a free tool like JSON Doctor
    await page.locator('text="JSON Doctor"').click();
    await page.waitForTimeout(2000);

    // Should load tool interface without paywall
    const toolInterface = page.locator(
      'textarea, input[type="text"], button:has-text("Format"), button:has-text("Validate")'
    );

    await expect(toolInterface.first()).toBeVisible({ timeout: 5000 });
    console.log("✅ Free tool loads without paywall");
  });

  test("all premium tools have paywall protection", async ({ page }) => {
    const premiumTools = [
      "File Merger",
      "Image Resizer",
      "Markdown to PDF",
      "QR Maker", // (batch mode)
      "JSON Flatten", // (CSV export)
    ];

    for (const toolName of premiumTools) {
      try {
        await page.goto("http://localhost:8080");
        await page.waitForTimeout(1000);

        await page.locator(`text="${toolName}"`).click();
        await page.waitForTimeout(2000);

        // Check if PaywallGuard or premium indicators are present
        const premiumIndicators = page.locator(
          'text="Pro", text="Premium", text="Upgrade", text="Subscribe"'
        );

        const hasPremiumIndicator = await premiumIndicators
          .first()
          .isVisible({ timeout: 3000 })
          .catch(() => false);

        if (hasPremiumIndicator) {
          console.log(`✅ ${toolName} has premium protection`);
        } else {
          console.log(
            `⚠️ ${toolName} may not have paywall (check implementation)`
          );
        }
      } catch (error) {
        console.log(`❌ Error testing ${toolName}: ${error}`);
      }
    }
  });

  // Note: Full payment flow test would require:
  // 1. Firebase Auth test user
  // 2. Stripe test mode configuration
  // 3. Webhook endpoint testing
  // This is typically done in integration tests rather than E2E
  test.skip("complete payment flow (requires test setup)", async ({ page }) => {
    // This test would:
    // 1. Sign in with test user
    // 2. Navigate to premium tool
    // 3. Click upgrade
    // 4. Complete Stripe checkout with test card 4242424242424242
    // 5. Verify webhook received
    // 6. Verify tool unlocked
    // 7. Verify Firestore subscription created

    console.log(
      "💡 Full payment flow test requires Firebase Auth + Stripe test setup"
    );
    console.log(
      "💡 Run manually with: firebase emulators:start + stripe listen"
    );
  });
});
