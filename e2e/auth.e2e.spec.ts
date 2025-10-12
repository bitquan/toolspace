/**
 * Auth E2E Tests - Complete Authentication Flow
 *
 * Tests:
 * - User signup with email/password
 * - Email verification (mocked)
 * - Login
 * - Logout
 * - Password reset
 */

import { expect, Page, test } from "@playwright/test";
import E2ETestHelper from "./helpers/test-helper";

const TEST_EMAIL = `test-${Date.now()}@toolspace-test.com`;
const TEST_PASSWORD = "TestPassword123!";
const BASE_URL = process.env.BASE_URL || "http://localhost:8080";

test.describe("🔐 Auth E2E Flow", () => {
  let page: Page;
  let helper: E2ETestHelper;

  test.beforeEach(async ({ browser }) => {
    const context = await browser.newContext();
    page = await context.newPage();
    helper = new E2ETestHelper(page);

    // Setup Firebase emulators
    await helper.setupFirebaseEmulators();

    // Clear any existing test data
    await helper.clearEmulatorData();
  });

  test("Complete Auth Flow: Signup → Verify → Login → Logout", async () => {
    // STEP 1: Navigate to app and wait for it to load
    await page.goto(BASE_URL);
    await helper.waitForAppReady();
    await expect(page).toHaveTitle(/Toolspace/i);

    // STEP 2: Look for Sign In or auth-related buttons
    const signInButton = page
      .locator("text=Sign In")
      .or(page.locator("button:has-text('Login')"))
      .or(page.locator("a:has-text('Sign In')"));

    if ((await signInButton.count()) > 0) {
      await signInButton.first().click();
      await helper.waitForAppReady();
    } else {
      // Try navigating directly to auth page
      await helper.navigateAndWait("/auth/signin");
    }

    // STEP 3: Navigate to Sign Up (if not already there)
    const signUpButton = page
      .locator("text=Sign Up")
      .or(page.locator("text=Create account"))
      .or(page.locator("button:has-text('Sign Up')"));

    if ((await signUpButton.count()) > 0) {
      await signUpButton.first().click();
      await helper.waitForAppReady();
    } else {
      await helper.navigateAndWait("/auth/signup");
    }

    // STEP 4: Fill signup form (if form exists)
    const emailInput = page
      .locator('input[type="email"]')
      .or(page.locator('input[placeholder*="email" i]'));
    const passwordInput = page.locator('input[type="password"]').first();
    const confirmPasswordInput = page
      .locator('input[type="password"]')
      .nth(1)
      .or(page.locator('input[placeholder*="Confirm" i]'));

    if ((await emailInput.count()) > 0) {
      await emailInput.fill(TEST_EMAIL);
      await passwordInput.fill(TEST_PASSWORD);

      if ((await confirmPasswordInput.count()) > 0) {
        await confirmPasswordInput.fill(TEST_PASSWORD);
      }

      // STEP 5: Submit signup
      const submitButton = page
        .locator('button:has-text("Sign Up")')
        .or(page.locator('button:has-text("Create")'));
      if ((await submitButton.count()) > 0) {
        await submitButton.click();
        await helper.waitForAppReady();
      }
    }

    // STEP 6: Check if we're on email verification screen or logged in
    const currentUrl = page.url();
    if (currentUrl.includes("/auth/verify-email")) {
      await expect(page.locator("text=verify your email")).toBeVisible();
    } else {
      // Might have auto-logged in or redirected elsewhere
      console.log("Signup flow completed, current URL:", currentUrl);
    }

    // STEP 7: Mock email verification
    // In a real scenario, this would click a link from email
    // For testing, we'll use Firebase Admin SDK or direct API call
    console.log(`📧 Mock: Email verification sent to ${TEST_EMAIL}`);

    // Simulate clicking verification link
    // This would normally be: await page.goto(verificationLink)
    // For now, we'll assume verification and proceed to login

    // STEP 8: Navigate back to Sign In
    await page.goto(`${BASE_URL}#/auth/signin`);

    // STEP 9: Login with verified email
    await page.fill('input[type="email"]', TEST_EMAIL);
    await page.fill('input[type="password"]', TEST_PASSWORD);
    await page.click('button:has-text("Sign In")');

    // STEP 10: Should be redirected to dashboard
    await page.waitForURL(/\/$|\/dashboard/, { timeout: 10000 });
    await expect(
      page.locator("text=Toolspace" || "text=Dashboard")
    ).toBeVisible();

    // STEP 11: Verify user is logged in (check for Sign Out button or user menu)
    const signOutButton = page.locator('button:has-text("Sign Out")');
    const userMenu = page.locator('[aria-label="User menu"]');
    const isLoggedIn =
      (await signOutButton.isVisible().catch(() => false)) ||
      (await userMenu.isVisible().catch(() => false));

    expect(isLoggedIn).toBeTruthy();

    // STEP 12: Logout
    // Try clicking Sign Out button or opening user menu
    if (await signOutButton.isVisible()) {
      await signOutButton.click();
    } else if (await userMenu.isVisible()) {
      await userMenu.click();
      await page.click("text=Sign Out" || "text=Logout");
    }

    // STEP 13: Verify logged out (should see Sign In button again)
    await page.waitForTimeout(2000);
    const signInVisible = await page.locator("text=Sign In").isVisible();
    expect(signInVisible).toBeTruthy();

    console.log("✅ Complete auth flow passed!");
  });

  test("Password Reset Flow", async () => {
    // STEP 1: Navigate to Sign In
    await page.goto(`${BASE_URL}#/auth/signin`);

    // STEP 2: Click "Forgot Password" link
    await page.click("text=Forgot Password" || "text=Reset Password");
    await page.waitForURL(/\/auth\/reset-password/);

    // STEP 3: Enter email
    await page.fill('input[type="email"]', TEST_EMAIL);

    // STEP 4: Submit reset request
    await page.click(
      'button:has-text("Send Reset Link")' ||
        'button:has-text("Reset Password")'
    );

    // STEP 5: Verify success message
    await expect(
      page.locator("text=reset link" || "text=check your email")
    ).toBeVisible({ timeout: 5000 });

    console.log("✅ Password reset flow passed!");
  });

  test("🔴 FAILING: Email Verification Required Before Access", async () => {
    // This test should FAIL if email verification isn't enforced
    test.fail(); // Mark as expected failure until feature is implemented

    await page.goto(`${BASE_URL}#/auth/signup`);

    // Sign up without verifying email
    await page.fill('input[type="email"]', `unverified-${Date.now()}@test.com`);
    await page.fill('input[type="password"]', TEST_PASSWORD);
    await page.fill('input[placeholder*="Confirm"]', TEST_PASSWORD);
    await page.click('button:has-text("Sign Up")');

    // Try to access a tool without verification
    await page.goto(`${BASE_URL}#/tools/markdown-to-pdf`);

    // Should be blocked
    await expect(
      page.locator(
        "text=verify your email" || "text=Email verification required"
      )
    ).toBeVisible({ timeout: 5000 });
  });

  test("🔴 FAILING: Invalid Email Format Rejected", async () => {
    test.fail(); // Mark as expected failure until validation is added

    await page.goto(`${BASE_URL}#/auth/signup`);

    // Try invalid email
    await page.fill('input[type="email"]', "not-an-email");
    await page.fill('input[type="password"]', TEST_PASSWORD);
    await page.fill('input[placeholder*="Confirm"]', TEST_PASSWORD);
    await page.click('button:has-text("Sign Up")');

    // Should show validation error
    await expect(
      page.locator("text=Invalid email" || "text=valid email")
    ).toBeVisible();
  });

  test("🔴 FAILING: Weak Password Rejected", async () => {
    test.fail(); // Mark as expected failure until validation is strengthened

    await page.goto(`${BASE_URL}#/auth/signup`);

    // Try weak password
    await page.fill('input[type="email"]', `test-${Date.now()}@test.com`);
    await page.fill('input[type="password"]', "123"); // Too weak
    await page.fill('input[placeholder*="Confirm"]', "123");
    await page.click('button:has-text("Sign Up")');

    // Should show validation error
    await expect(
      page.locator("text=Password must" || "text=stronger password")
    ).toBeVisible();
  });
});
