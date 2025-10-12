#!/usr/bin/env node

/**
 * E2E Smoke Test Suite
 * Tests 10 critical user paths in staging environment
 */

import fs from "fs/promises";
import { dirname, join } from "path";
import puppeteer from "puppeteer";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Test configuration
const CONFIG = {
  baseUrl: process.env.PUBLIC_BASE_URL || "http://localhost:8080",
  testEmail: `smoke-test-${Date.now()}@toolzspace-staging.com`,
  testPassword: "SmokeTest123!@#",
  timeout: 30000,
  screenshots: true,
  headless: process.env.HEADLESS !== "false",
};

class SmokeTestSuite {
  constructor() {
    this.browser = null;
    this.page = null;
    this.results = {
      timestamp: new Date().toISOString(),
      tests: [],
      summary: {
        total: 10,
        passed: 0,
        failed: 0,
        skipped: 0,
      },
      errors: [],
      screenshots: [],
    };
  }

  async log(test, status, details = "") {
    const entry = {
      test,
      status,
      details,
      timestamp: new Date().toISOString(),
    };
    this.results.tests.push(entry);
    console.log(`[${status.toUpperCase()}] ${test}: ${details}`);

    // Update summary
    if (status === "pass") this.results.summary.passed++;
    if (status === "fail") this.results.summary.failed++;
    if (status === "skip") this.results.summary.skipped++;
  }

  async takeScreenshot(name) {
    if (!CONFIG.screenshots || !this.page) return;

    try {
      const screenshotPath = join(
        __dirname,
        "../../dev-log/phase-4/screenshots",
        `smoke-${name}.png`
      );
      await fs.mkdir(dirname(screenshotPath), { recursive: true });
      await this.page.screenshot({
        path: screenshotPath,
        fullPage: true,
      });
      this.results.screenshots.push(screenshotPath);
    } catch (error) {
      console.warn(`Screenshot failed for ${name}: ${error.message}`);
    }
  }

  async init() {
    try {
      console.log("🚀 Launching browser...");
      this.browser = await puppeteer.launch({
        headless: CONFIG.headless,
        defaultViewport: { width: 1280, height: 720 },
        args: ["--no-sandbox", "--disable-setuid-sandbox"],
      });
      this.page = await this.browser.newPage();

      // Set up console logging
      this.page.on("console", (msg) => {
        if (msg.type() === "error") {
          console.log(`[BROWSER ERROR] ${msg.text()}`);
        }
      });

      return true;
    } catch (error) {
      console.error("Failed to launch browser:", error);
      return false;
    }
  }

  async navigateToTool(toolPath) {
    try {
      const url = `${CONFIG.baseUrl}${toolPath}`;
      await this.page.goto(url, {
        waitUntil: "networkidle2",
        timeout: CONFIG.timeout,
      });
      await new Promise((resolve) => setTimeout(resolve, 2000)); // Wait for app to load
      return true;
    } catch (error) {
      console.error(`Navigation failed: ${error.message}`);
      return false;
    }
  }

  // FREE TOOL TESTS (No Paywall Expected)

  async testJsonDoctor() {
    try {
      await this.log("json-doctor", "start", "Testing JSON Doctor tool");

      if (!(await this.navigateToTool("/tools/json-doctor"))) {
        throw new Error("Navigation failed");
      }

      await this.takeScreenshot("json-doctor-loaded");

      // Look for JSON input area
      await this.page.waitForSelector(
        'textarea, .CodeMirror, input[type="text"]',
        { timeout: 10000 }
      );

      // Try to input some JSON
      const testJson = '{"test": "data", "number": 42}';
      const input =
        (await this.page.$("textarea")) ||
        (await this.page.$('input[type="text"]'));

      if (input) {
        await input.type(testJson);
        await this.takeScreenshot("json-doctor-input");
      }

      // Check for no paywall
      const paywallPresent =
        (await this.page.$(".paywall, .upgrade-sheet")) !== null;
      if (paywallPresent) {
        throw new Error("Unexpected paywall on free tool");
      }

      await this.log(
        "json-doctor",
        "pass",
        "JSON Doctor accessible and functional"
      );
      return true;
    } catch (error) {
      await this.takeScreenshot("json-doctor-error");
      await this.log("json-doctor", "fail", error.message);
      this.results.errors.push(`JSON Doctor: ${error.message}`);
      return false;
    }
  }

  async testRegexTester() {
    try {
      await this.log("regex-tester", "start", "Testing Regex Tester tool");

      if (!(await this.navigateToTool("/tools/regex-tester"))) {
        throw new Error("Navigation failed");
      }

      await this.takeScreenshot("regex-tester-loaded");

      // Look for regex input
      await this.page.waitForSelector("input, textarea", { timeout: 10000 });

      // Check for no paywall
      const paywallPresent =
        (await this.page.$(".paywall, .upgrade-sheet")) !== null;
      if (paywallPresent) {
        throw new Error("Unexpected paywall on free tool");
      }

      await this.log("regex-tester", "pass", "Regex Tester accessible");
      return true;
    } catch (error) {
      await this.takeScreenshot("regex-tester-error");
      await this.log("regex-tester", "fail", error.message);
      this.results.errors.push(`Regex Tester: ${error.message}`);
      return false;
    }
  }

  async testIdGenerator() {
    try {
      await this.log("id-generator", "start", "Testing ID Generator tool");

      if (!(await this.navigateToTool("/tools/id-gen"))) {
        throw new Error("Navigation failed");
      }

      await this.takeScreenshot("id-gen-loaded");

      // Look for generate button or similar
      await this.page.waitForSelector("button, .btn", { timeout: 10000 });

      // Check for no paywall
      const paywallPresent =
        (await this.page.$(".paywall, .upgrade-sheet")) !== null;
      if (paywallPresent) {
        throw new Error("Unexpected paywall on free tool");
      }

      await this.log("id-generator", "pass", "ID Generator accessible");
      return true;
    } catch (error) {
      await this.takeScreenshot("id-gen-error");
      await this.log("id-generator", "fail", error.message);
      this.results.errors.push(`ID Generator: ${error.message}`);
      return false;
    }
  }

  async testUnitConverter() {
    try {
      await this.log("unit-converter", "start", "Testing Unit Converter tool");

      if (!(await this.navigateToTool("/tools/unit-converter"))) {
        throw new Error("Navigation failed");
      }

      await this.takeScreenshot("unit-converter-loaded");

      // Look for conversion inputs
      await this.page.waitForSelector("input, select", { timeout: 10000 });

      // Check for no paywall
      const paywallPresent =
        (await this.page.$(".paywall, .upgrade-sheet")) !== null;
      if (paywallPresent) {
        throw new Error("Unexpected paywall on free tool");
      }

      await this.log("unit-converter", "pass", "Unit Converter accessible");
      return true;
    } catch (error) {
      await this.takeScreenshot("unit-converter-error");
      await this.log("unit-converter", "fail", error.message);
      this.results.errors.push(`Unit Converter: ${error.message}`);
      return false;
    }
  }

  async testQrMaker() {
    try {
      await this.log("qr-maker", "start", "Testing QR Maker tool");

      if (!(await this.navigateToTool("/tools/qr-maker"))) {
        throw new Error("Navigation failed");
      }

      await this.takeScreenshot("qr-maker-loaded");

      // Look for text input
      await this.page.waitForSelector("input, textarea", { timeout: 10000 });

      // Check for no paywall
      const paywallPresent =
        (await this.page.$(".paywall, .upgrade-sheet")) !== null;
      if (paywallPresent) {
        throw new Error("Unexpected paywall on free tool");
      }

      await this.log("qr-maker", "pass", "QR Maker accessible");
      return true;
    } catch (error) {
      await this.takeScreenshot("qr-maker-error");
      await this.log("qr-maker", "fail", error.message);
      this.results.errors.push(`QR Maker: ${error.message}`);
      return false;
    }
  }

  // PRO TOOL TESTS (Paywall Expected for Non-Pro Users)

  async testFileMerger() {
    try {
      await this.log("file-merger", "start", "Testing File Merger tool (Pro)");

      if (!(await this.navigateToTool("/tools/file-merger"))) {
        throw new Error("Navigation failed");
      }

      await this.takeScreenshot("file-merger-loaded");

      // Wait a moment for the app to load and potentially show paywall
      await new Promise((resolve) => setTimeout(resolve, 3000));

      // Check for paywall (expected for Pro tool)
      const paywallPresent =
        (await this.page.$(".paywall, .upgrade-sheet, .pro-required")) !== null;
      if (paywallPresent) {
        await this.takeScreenshot("file-merger-paywall");
        await this.log(
          "file-merger",
          "pass",
          "Paywall correctly shown for Pro tool"
        );
        return true;
      } else {
        // If no paywall, check if user is already Pro or tool is accessible
        const fileUpload = await this.page.$(
          'input[type="file"], .file-upload, .upload-zone'
        );
        if (fileUpload) {
          await this.log(
            "file-merger",
            "pass",
            "File Merger accessible (user may be Pro)"
          );
          return true;
        } else {
          throw new Error("Neither paywall nor tool interface found");
        }
      }
    } catch (error) {
      await this.takeScreenshot("file-merger-error");
      await this.log("file-merger", "fail", error.message);
      this.results.errors.push(`File Merger: ${error.message}`);
      return false;
    }
  }

  async testImageResizer() {
    try {
      await this.log(
        "image-resizer",
        "start",
        "Testing Image Resizer tool (Pro)"
      );

      if (!(await this.navigateToTool("/tools/image-resizer"))) {
        throw new Error("Navigation failed");
      }

      await this.takeScreenshot("image-resizer-loaded");
      await new Promise((resolve) => setTimeout(resolve, 3000));

      // Check for paywall or tool interface
      const paywallPresent =
        (await this.page.$(".paywall, .upgrade-sheet, .pro-required")) !== null;
      const toolInterface =
        (await this.page.$(
          'input[type="file"], .image-upload, .upload-zone'
        )) !== null;

      if (paywallPresent || toolInterface) {
        await this.log(
          "image-resizer",
          "pass",
          "Image Resizer behavior correct"
        );
        return true;
      } else {
        throw new Error("Neither paywall nor tool interface found");
      }
    } catch (error) {
      await this.takeScreenshot("image-resizer-error");
      await this.log("image-resizer", "fail", error.message);
      this.results.errors.push(`Image Resizer: ${error.message}`);
      return false;
    }
  }

  async testMarkdownToPdf() {
    try {
      await this.log(
        "md-to-pdf",
        "start",
        "Testing Markdown to PDF tool (Pro)"
      );

      if (!(await this.navigateToTool("/tools/md-to-pdf"))) {
        throw new Error("Navigation failed");
      }

      await this.takeScreenshot("md-to-pdf-loaded");
      await new Promise((resolve) => setTimeout(resolve, 3000));

      // Check for paywall or tool interface
      const paywallPresent =
        (await this.page.$(".paywall, .upgrade-sheet, .pro-required")) !== null;
      const toolInterface =
        (await this.page.$("textarea, .markdown-input, .editor")) !== null;

      if (paywallPresent || toolInterface) {
        await this.log("md-to-pdf", "pass", "Markdown to PDF behavior correct");
        return true;
      } else {
        throw new Error("Neither paywall nor tool interface found");
      }
    } catch (error) {
      await this.takeScreenshot("md-to-pdf-error");
      await this.log("md-to-pdf", "fail", error.message);
      this.results.errors.push(`Markdown to PDF: ${error.message}`);
      return false;
    }
  }

  // CROSS-TOOL INTEGRATION TEST

  async testCrossToolIntegration() {
    try {
      await this.log("cross-tool", "start", "Testing cross-tool data sharing");

      // Navigate to JSON Doctor
      if (!(await this.navigateToTool("/tools/json-doctor"))) {
        throw new Error("Navigation to JSON Doctor failed");
      }

      await this.takeScreenshot("cross-tool-json-start");

      // Try to find and use share functionality
      // This is a basic test - actual implementation may vary
      const shareButton = await this.page.$(
        ".share-button, .export-button, [data-share]"
      );
      if (shareButton) {
        await shareButton.click();
        await this.takeScreenshot("cross-tool-share-clicked");
      }

      // Navigate to Text Diff
      if (!(await this.navigateToTool("/tools/text-diff"))) {
        throw new Error("Navigation to Text Diff failed");
      }

      await this.takeScreenshot("cross-tool-diff-loaded");

      await this.log("cross-tool", "pass", "Cross-tool navigation successful");
      return true;
    } catch (error) {
      await this.takeScreenshot("cross-tool-error");
      await this.log("cross-tool", "fail", error.message);
      this.results.errors.push(`Cross-tool: ${error.message}`);
      return false;
    }
  }

  // BILLING PORTAL TEST

  async testBillingPortal() {
    try {
      await this.log(
        "billing-portal",
        "start",
        "Testing billing portal access"
      );

      if (!(await this.navigateToTool("/billing"))) {
        throw new Error("Navigation to billing failed");
      }

      await this.takeScreenshot("billing-portal-loaded");

      // Look for billing interface elements
      const billingElements = await this.page.$$(
        ".billing, .subscription, .plan, .manage"
      );
      if (billingElements.length > 0) {
        await this.log("billing-portal", "pass", "Billing portal accessible");
        return true;
      } else {
        throw new Error("No billing interface elements found");
      }
    } catch (error) {
      await this.takeScreenshot("billing-portal-error");
      await this.log("billing-portal", "fail", error.message);
      this.results.errors.push(`Billing Portal: ${error.message}`);
      return false;
    }
  }

  async cleanup() {
    try {
      if (this.browser) {
        await this.browser.close();
      }
    } catch (error) {
      console.error("Cleanup error:", error);
    }
  }

  async run() {
    console.log("🧪 Starting Smoke Test Suite...");
    console.log(`🌐 Base URL: ${CONFIG.baseUrl}`);
    console.log(`🖥️  Headless: ${CONFIG.headless}`);

    if (!(await this.init())) {
      return this.results;
    }

    try {
      // Run all 10 critical path tests
      await this.testJsonDoctor();
      await this.testRegexTester();
      await this.testIdGenerator();
      await this.testUnitConverter();
      await this.testQrMaker();
      await this.testFileMerger();
      await this.testImageResizer();
      await this.testMarkdownToPdf();
      await this.testCrossToolIntegration();
      await this.testBillingPortal();
    } catch (error) {
      console.error("Test suite error:", error);
      this.results.errors.push(`Suite error: ${error.message}`);
    } finally {
      await this.cleanup();
    }

    return this.results;
  }

  async saveResults() {
    try {
      const resultsPath = join(
        __dirname,
        "../../dev-log/phase-4/smoke-test-results.json"
      );
      await fs.mkdir(dirname(resultsPath), { recursive: true });
      await fs.writeFile(resultsPath, JSON.stringify(this.results, null, 2));
      console.log(`📄 Results saved to: ${resultsPath}`);
    } catch (error) {
      console.error(`❌ Failed to save results: ${error.message}`);
    }
  }
}

// Run the test if called directly
if (import.meta.url === `file://${process.argv[1]}`) {
  const suite = new SmokeTestSuite();

  suite
    .run()
    .then(async (results) => {
      await suite.saveResults();

      console.log("\n🏁 Smoke Test Summary:");
      console.log(`📊 Total Tests: ${results.summary.total}`);
      console.log(`✅ Passed: ${results.summary.passed}`);
      console.log(`❌ Failed: ${results.summary.failed}`);
      console.log(`⏭️  Skipped: ${results.summary.skipped}`);
      console.log(`📸 Screenshots: ${results.screenshots.length}`);

      const successRate = (
        (results.summary.passed / results.summary.total) *
        100
      ).toFixed(1);
      console.log(`🎯 Success Rate: ${successRate}%`);

      if (results.errors.length > 0) {
        console.log("\n❌ Errors:");
        results.errors.forEach((error, i) => {
          console.log(`  ${i + 1}. ${error}`);
        });
      }

      process.exit(results.summary.failed === 0 ? 0 : 1);
    })
    .catch((error) => {
      console.error("💥 Smoke test suite crashed:", error);
      process.exit(1);
    });
}

export default SmokeTestSuite;
