/**
 * E2E Test Helpers
 *
 * Utilities for setting up Firebase emulators and test data
 */

import { Page } from "@playwright/test";

export class E2ETestHelper {
  constructor(private page: Page) {}

  /**
   * Set up Firebase emulator connection in the browser
   */
  async setupFirebaseEmulators() {
    await this.page.addInitScript(() => {
      // Configure Firebase to use emulators
      (window as any).FIREBASE_EMULATOR_CONFIG = {
        auth: { host: "localhost", port: 9099 },
        firestore: { host: "localhost", port: 8081 },
        functions: { host: "localhost", port: 5001 },
      };
    });
  }

  /**
   * Create a test user in the auth emulator
   */
  async createTestUser(email: string, password: string) {
    // Use Firebase Admin API to create test user
    const response = await fetch(
      "http://localhost:9099/emulator/v1/projects/demo-project/accounts",
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          email,
          password,
          emailVerified: true,
        }),
      }
    );

    if (!response.ok) {
      throw new Error(`Failed to create test user: ${response.statusText}`);
    }

    return response.json();
  }

  /**
   * Clear all data from emulators
   */
  async clearEmulatorData() {
    // Clear Auth emulator
    await fetch(
      "http://localhost:9099/emulator/v1/projects/demo-project/accounts",
      {
        method: "DELETE",
      }
    );

    // Clear Firestore emulator
    await fetch(
      "http://localhost:8081/emulator/v1/projects/demo-project/databases/(default)/documents",
      {
        method: "DELETE",
      }
    );
  }

  /**
   * Wait for the app to load completely
   */
  async waitForAppReady() {
    // Wait for main app container
    await this.page.waitForSelector("body", { timeout: 30000 });

    // Wait for any loading indicators to disappear
    await this.page
      .waitForFunction(
        () => {
          const loadingElements = document.querySelectorAll(
            '[data-testid*="loading"], .loading, .spinner'
          );
          return loadingElements.length === 0;
        },
        { timeout: 15000 }
      )
      .catch(() => {
        // Ignore timeout - app might not have loading indicators
      });

    // Small delay to ensure everything is settled
    await this.page.waitForTimeout(1000);
  }

  /**
   * Navigate to a specific route and wait for it to load
   */
  async navigateAndWait(path: string) {
    await this.page.goto(`${this.page.url().split("#")[0]}#${path}`);
    await this.waitForAppReady();
  }
}

export default E2ETestHelper;
