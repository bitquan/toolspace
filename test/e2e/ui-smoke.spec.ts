import { test, expect } from "@playwright/test";

/**
 * UX Smoke Tests for Toolspace Landing Page
 *
 * Verifies critical user flows:
 * - Landing page loads with correct title
 * - "Get Started Free" navigates to signup
 * - "View Pricing" navigates to pricing page
 * - Navbar Features link navigates to features page
 * - Navbar Dashboard link navigates to dashboard (or signup if unauth)
 * - Screenshots captured for visual verification
 */

test.describe("Landing Page UX Smoke Tests", () => {
  test("landing page loads with correct title", async ({ page }) => {
    await page.goto("/");

    // Wait for page to be fully loaded
    await page.waitForLoadState("networkidle");

    // Verify title contains "Toolspace"
    await expect(page).toHaveTitle(/Toolspace/);

    // Take screenshot of landing page
    await page.screenshot({
      path: ".artifacts/home.png",
      fullPage: true,
    });
  });

  test("btn-get-started navigates to signup", async ({ page }) => {
    await page.goto("/");
    await page.waitForLoadState("networkidle");

    // Find and click "Get Started Free" button using aria-label
    const getStartedBtn = page.locator('[aria-label="btn-get-started"]');
    await expect(getStartedBtn).toBeVisible();
    await getStartedBtn.click();

    // Wait for navigation
    await page.waitForURL("**/signup");

    // Verify we're on the signup page
    expect(page.url()).toMatch(/\/signup$/);
  });

  test("btn-view-pricing navigates to pricing page", async ({ page }) => {
    await page.goto("/");
    await page.waitForLoadState("networkidle");

    // Find and click "View Pricing" button
    const viewPricingBtn = page.locator('[aria-label="btn-view-pricing"]');
    await expect(viewPricingBtn).toBeVisible();
    await viewPricingBtn.click();

    // Wait for navigation
    await page.waitForURL("**/pricing");

    // Verify we're on the pricing page
    expect(page.url()).toMatch(/\/pricing$/);

    // Verify pricing page content
    const pricingHeading = page.getByRole("heading", {
      name: /Choose your plan/i,
    });
    await expect(pricingHeading).toBeVisible();
  });

  test("nav-features navigates to features page", async ({ page }) => {
    await page.goto("/");
    await page.waitForLoadState("networkidle");

    // Find and click Features navbar link
    const featuresLink = page.locator('[aria-label="nav-features"]');
    await expect(featuresLink).toBeVisible();
    await featuresLink.click();

    // Wait for navigation
    await page.waitForURL("**/features");

    // Verify we're on the features page
    expect(page.url()).toMatch(/\/features$/);

    // Verify features page content
    const featuresContent = page.getByText(
      /Everything you need to build better/i
    );
    await expect(featuresContent).toBeVisible();
  });

  test("nav-pricing navigates to pricing page", async ({ page }) => {
    await page.goto("/");
    await page.waitForLoadState("networkidle");

    // Find and click Pricing navbar link
    const pricingLink = page.locator('[aria-label="nav-pricing"]');
    await expect(pricingLink).toBeVisible();
    await pricingLink.click();

    // Wait for navigation
    await page.waitForURL("**/pricing");

    // Verify we're on the pricing page
    expect(page.url()).toMatch(/\/pricing$/);
  });

  test("nav-dashboard navigates to dashboard", async ({ page }) => {
    await page.goto("/");
    await page.waitForLoadState("networkidle");

    // Find and click Dashboard navbar link
    const dashboardLink = page.locator('[aria-label="nav-dashboard"]');
    await expect(dashboardLink).toBeVisible();
    await dashboardLink.click();

    // Wait for navigation (could be /dashboard or /signup if unauth)
    await page.waitForLoadState("networkidle");

    // Verify we navigated somewhere (dashboard or signup redirect)
    const url = page.url();
    const validUrls = ["/dashboard", "/signup"];
    const matchesValidUrl = validUrls.some((validUrl) =>
      url.includes(validUrl)
    );
    expect(matchesValidUrl).toBeTruthy();
  });

  test("all navigation selectors are present", async ({ page }) => {
    await page.goto("/");
    await page.waitForLoadState("networkidle");

    // Verify all expected selectors exist
    await expect(page.locator('[aria-label="btn-get-started"]')).toBeVisible();
    await expect(page.locator('[aria-label="btn-view-pricing"]')).toBeVisible();
    await expect(page.locator('[aria-label="nav-features"]')).toBeVisible();
    await expect(page.locator('[aria-label="nav-pricing"]')).toBeVisible();
    await expect(page.locator('[aria-label="nav-dashboard"]')).toBeVisible();
  });
});
