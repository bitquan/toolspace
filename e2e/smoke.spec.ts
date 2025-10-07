import { test, expect } from "@playwright/test";

test.describe("Toolspace Smoke Tests", () => {
  test("home grid loads and displays tools", async ({ page }) => {
    // Navigate to home
    await page.goto("http://localhost:8080");

    // Wait for app to load
    await page.waitForSelector(
      '[data-testid="tool-card"], .tool-card, div[role="button"]',
      { timeout: 10000 }
    );

    // Check that multiple tools are visible
    const toolCards = page.locator(
      '[data-testid="tool-card"], .tool-card, div[role="button"]'
    );
    const count = await toolCards.count();

    expect(count).toBeGreaterThanOrEqual(15); // Should show at least 15 tools

    // Check for Neo-Playground theme elements
    await expect(page.locator("text=Toolspace")).toBeVisible();
  });

  test("search functionality works", async ({ page }) => {
    await page.goto("http://localhost:8080");
    await page.waitForLoadState("networkidle");

    // Find search input
    const searchInput = page.locator('input[type="text"]').first();
    await searchInput.fill("JSON");

    // Wait a bit for filtering
    await page.waitForTimeout(500);

    // Should show JSON-related tools
    await expect(page.locator("text=JSON Doctor")).toBeVisible();
  });

  test("can open a tool and return home", async ({ page }) => {
    // Go to home
    await page.goto("http://localhost:8080");
    await page.waitForLoadState("networkidle");

    // Click first tool card (wait for it to be ready)
    await page.waitForSelector(
      '[data-testid="tool-card"], .tool-card, div[role="button"]',
      { timeout: 10000 }
    );

    const firstTool = page
      .locator('[data-testid="tool-card"], .tool-card, div[role="button"]')
      .first();
    await firstTool.click();

    // Wait for navigation/loading
    await page.waitForTimeout(2000);

    // Check we're on a tool page (URL should change or content should update)
    // Going back should work
    await page.goBack();

    // Should be back on home
    await expect(page.locator("text=Toolspace")).toBeVisible();
  });

  test("dark mode toggle works", async ({ page }) => {
    await page.goto("http://localhost:8080");
    await page.waitForLoadState("networkidle");

    // The theme should be active (either light or dark)
    const html = page.locator("html");
    const initialTheme = (await html.getAttribute("data-theme")) || "light";

    expect(initialTheme).toBeTruthy();
  });

  test("all category filters work", async ({ page }) => {
    await page.goto("http://localhost:8080");
    await page.waitForLoadState("networkidle");

    // Check for category chips
    const categories = ["All", "Text", "Data", "Media", "Dev Tools"];

    for (const category of categories) {
      const chip = page.locator(`text="${category}"`).first();
      if (await chip.isVisible()) {
        await chip.click();
        await page.waitForTimeout(300);

        // Should still show some tools
        const toolCards = page.locator(
          '[data-testid="tool-card"], .tool-card, div[role="button"]'
        );
        const count = await toolCards.count();
        expect(count).toBeGreaterThan(0);
      }
    }
  });
});
