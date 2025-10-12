/**
 * Billing Webhook E2E Test
 *
 * Tests that:
 * 1. Stripe webhooks update billing profiles correctly
 * 2. Plan changes persist across browser sessions
 * 3. Subscription lifecycle events are handled
 */

import { expect, test } from "@playwright/test";
import * as http from "http";

const BASE_URL = process.env.BASE_URL || "http://localhost:8080";
const FUNCTIONS_URL = process.env.FUNCTIONS_URL || "http://localhost:5001";

// Stripe webhook test fixtures
const WEBHOOK_FIXTURES = {
  checkoutCompleted: {
    type: "checkout.session.completed",
    data: {
      object: {
        customer: "cus_test_123",
        subscription: "sub_test_123",
        client_reference_id: "user-uid-123",
        metadata: {
          userId: "user-uid-123",
          planId: "pro",
        },
      },
    },
  },
  subscriptionUpdated: {
    type: "customer.subscription.updated",
    data: {
      object: {
        id: "sub_test_123",
        customer: "cus_test_123",
        status: "active",
        items: {
          data: [
            {
              price: {
                id: "price_pro_monthly",
                product: "prod_pro",
              },
            },
          ],
        },
        current_period_end: Math.floor(Date.now() / 1000) + 2592000, // 30 days
        metadata: {
          userId: "user-uid-123",
        },
      },
    },
  },
  subscriptionCanceled: {
    type: "customer.subscription.deleted",
    data: {
      object: {
        id: "sub_test_123",
        customer: "cus_test_123",
        metadata: {
          userId: "user-uid-123",
        },
      },
    },
  },
};

test.describe("💳 Billing Webhook Integration", () => {
  test("🔴 FAILING: Webhook Updates Billing Profile", async ({ page }) => {
    test.fail(); // Feature not fully implemented

    const testUserId = "test-user-" + Date.now();

    // STEP 1: Simulate checkout.session.completed webhook
    const webhookPayload = {
      ...WEBHOOK_FIXTURES.checkoutCompleted,
      data: {
        object: {
          ...WEBHOOK_FIXTURES.checkoutCompleted.data.object,
          client_reference_id: testUserId,
          metadata: {
            userId: testUserId,
            planId: "pro",
          },
        },
      },
    };

    console.log(`🔔 Sending webhook for user: ${testUserId}`);

    // Send webhook to Firebase Function
    const webhookResponse = await sendWebhook(webhookPayload);
    expect(webhookResponse.status).toBe(200);

    // STEP 2: Login as test user and verify billing profile
    await page.goto(BASE_URL);

    // Navigate to account/billing page
    await page.goto(`${BASE_URL}#/account`);

    // Wait for billing info to load
    await page.waitForSelector("text=Pro", { timeout: 10000 });

    // Verify plan is displayed
    const planBadge = page.locator("text=Pro" || "text=Pro Plan");
    await expect(planBadge).toBeVisible();

    console.log("✅ Billing profile updated from webhook");
  });

  test("🔴 FAILING: Plan Persists Across Browser Sessions", async ({
    browser,
  }) => {
    test.fail(); // Feature not fully implemented

    const testUserId = "test-user-persist-" + Date.now();
    const testEmail = `${testUserId}@test.com`;
    const testPassword = "TestPassword123!";

    // STEP 1: Create user and upgrade via webhook
    const context1 = await browser.newContext();
    const page1 = await context1.newPage();

    await page1.goto(`${BASE_URL}#/auth/signup`);
    await page1.fill('input[type="email"]', testEmail);
    await page1.fill('input[type="password"]', testPassword);
    await page1.fill('input[placeholder*="Confirm"]', testPassword);
    await page1.click('button:has-text("Sign Up")');

    // Simulate webhook upgrade
    const webhookPayload = {
      ...WEBHOOK_FIXTURES.checkoutCompleted,
      data: {
        object: {
          ...WEBHOOK_FIXTURES.checkoutCompleted.data.object,
          client_reference_id: testUserId,
          metadata: {
            userId: testUserId,
            planId: "pro",
          },
        },
      },
    };

    await sendWebhook(webhookPayload);

    // Verify Pro badge shows
    await page1.goto(`${BASE_URL}#/account`);
    await expect(page1.locator("text=Pro")).toBeVisible({ timeout: 10000 });

    await context1.close();

    // STEP 2: Open fresh browser profile and login
    const context2 = await browser.newContext();
    const page2 = await context2.newPage();

    await page2.goto(`${BASE_URL}#/auth/signin`);
    await page2.fill('input[type="email"]', testEmail);
    await page2.fill('input[type="password"]', testPassword);
    await page2.click('button:has-text("Sign In")');

    // Navigate to account
    await page2.goto(`${BASE_URL}#/account`);

    // Verify Pro plan persists
    await expect(page2.locator("text=Pro")).toBeVisible({ timeout: 10000 });

    console.log("✅ Plan persists across browser sessions");

    await context2.close();
  });

  test("🔴 FAILING: Subscription Cancellation Downgrades User", async ({
    page,
  }) => {
    test.fail(); // Feature not fully implemented

    const testUserId = "test-user-cancel-" + Date.now();

    // STEP 1: Upgrade user
    const upgradePayload = {
      ...WEBHOOK_FIXTURES.checkoutCompleted,
      data: {
        object: {
          ...WEBHOOK_FIXTURES.checkoutCompleted.data.object,
          client_reference_id: testUserId,
          metadata: { userId: testUserId, planId: "pro" },
        },
      },
    };

    await sendWebhook(upgradePayload);

    // STEP 2: Cancel subscription
    const cancelPayload = {
      ...WEBHOOK_FIXTURES.subscriptionCanceled,
      data: {
        object: {
          ...WEBHOOK_FIXTURES.subscriptionCanceled.data.object,
          metadata: { userId: testUserId },
        },
      },
    };

    await sendWebhook(cancelPayload);

    // STEP 3: Verify user downgraded to Free
    await page.goto(`${BASE_URL}#/account`);

    // Should show Free plan
    await expect(page.locator("text=Free" || "text=Free Plan")).toBeVisible({
      timeout: 10000,
    });

    console.log("✅ Subscription cancellation handled correctly");
  });

  test("Webhook Signature Validation", async () => {
    // Send webhook without valid signature
    const invalidWebhook = {
      type: "customer.subscription.updated",
      data: { object: {} },
    };

    const response = await sendWebhook(invalidWebhook, false);

    // Should reject invalid signature
    expect(response.status).toBe(400);

    console.log("✅ Invalid webhook rejected");
  });
});

// Helper function to send webhook
async function sendWebhook(
  payload: any,
  withSignature: boolean = true
): Promise<{ status: number; body: any }> {
  return new Promise((resolve, reject) => {
    const data = JSON.stringify(payload);

    const options = {
      hostname: "localhost",
      port: 5001,
      path: "/toolspace-test/us-central1/stripeWebhook",
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Content-Length": data.length,
        ...(withSignature && {
          "Stripe-Signature": "test-signature", // Mock signature
        }),
      },
    };

    const req = http.request(options, (res) => {
      let body = "";
      res.on("data", (chunk) => (body += chunk));
      res.on("end", () => {
        resolve({
          status: res.statusCode || 500,
          body: body ? JSON.parse(body) : {},
        });
      });
    });

    req.on("error", reject);
    req.write(data);
    req.end();
  });
}
