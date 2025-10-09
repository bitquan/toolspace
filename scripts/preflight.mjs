#!/usr/bin/env node

/**
 * Preflight Check Script for Toolspace
 *
 * Runs comprehensive checks before push/commit:
 * - Flutter analyze
 * - Flutter tests (unit, golden, navigation)
 * - Flutter build web
 * - Playwright E2E smoke tests
 *
 * Emits pr-ci-summary.json with results for CI integration
 */

import { spawn } from "child_process";
import { writeFileSync } from "fs";
import { join, dirname } from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const projectRoot = join(__dirname, "..");

// ANSI color codes
const colors = {
  reset: "\x1b[0m",
  green: "\x1b[32m",
  red: "\x1b[31m",
  yellow: "\x1b[33m",
  blue: "\x1b[34m",
  bold: "\x1b[1m",
};

const log = {
  info: (msg) => console.log(`${colors.blue}ℹ${colors.reset} ${msg}`),
  success: (msg) => console.log(`${colors.green}✓${colors.reset} ${msg}`),
  error: (msg) => console.log(`${colors.red}✗${colors.reset} ${msg}`),
  warn: (msg) => console.log(`${colors.yellow}⚠${colors.reset} ${msg}`),
  step: (msg) => console.log(`\n${colors.bold}${msg}${colors.reset}`),
};

/**
 * Execute a command and return its result
 */
function runCommand(command, args, options = {}) {
  return new Promise((resolve, reject) => {
    log.info(`Running: ${command} ${args.join(" ")}`);

    const proc = spawn(command, args, {
      cwd: options.cwd || projectRoot,
      stdio: "inherit",
      shell: true,
      ...options,
    });

    proc.on("close", (code) => {
      if (code === 0) {
        resolve();
      } else {
        reject(new Error(`Command failed with exit code ${code}`));
      }
    });

    proc.on("error", (err) => {
      reject(err);
    });
  });
}

/**
 * Main preflight check sequence
 */
async function runPreflight() {
  const results = {
    success: true,
    timestamp: new Date().toISOString(),
    checks: {},
  };

  try {
    log.step("🔍 Step 1: Flutter Analyze");
    await runCommand("flutter", ["analyze"]);
    log.success("Flutter analyze passed");
    results.checks.analyze = { success: true };
  } catch (error) {
    log.error("Flutter analyze failed");
    results.checks.analyze = { success: false, error: error.message };
    results.success = false;
  }

  try {
    log.step("🧪 Step 2: Flutter Tests (Unit + Golden + Navigation)");
    await runCommand("flutter", ["test", "--reporter", "expanded"]);
    log.success("All Flutter tests passed");
    results.checks.flutterTests = { success: true };
  } catch (error) {
    log.error("Flutter tests failed");
    results.checks.flutterTests = { success: false, error: error.message };
    results.success = false;
  }

  try {
    log.step("🏗️  Step 3: Flutter Build Web");
    await runCommand("flutter", ["build", "web", "--release"]);
    log.success("Web build completed");
    results.checks.buildWeb = { success: true };
  } catch (error) {
    log.error("Web build failed");
    results.checks.buildWeb = { success: false, error: error.message };
    results.success = false;
  }

  try {
    log.step("📦 Step 4: Install E2E Dependencies");
    await runCommand("npm", ["ci"], { cwd: join(projectRoot, "test", "e2e") });
    log.success("E2E dependencies installed");
    results.checks.e2eDeps = { success: true };
  } catch (error) {
    log.warn("E2E dependencies installation failed (skipping E2E tests)");
    results.checks.e2eDeps = {
      success: false,
      error: error.message,
      skipped: true,
    };
  }

  if (results.checks.e2eDeps?.success) {
    try {
      log.step("🎭 Step 5: Install Playwright Browsers");
      await runCommand(
        "npx",
        ["playwright", "install", "--with-deps", "chromium"],
        {
          cwd: join(projectRoot, "test", "e2e"),
        }
      );
      log.success("Playwright browsers installed");
      results.checks.playwrightInstall = { success: true };
    } catch (error) {
      log.warn("Playwright installation failed (skipping E2E tests)");
      results.checks.playwrightInstall = {
        success: false,
        error: error.message,
        skipped: true,
      };
    }

    if (results.checks.playwrightInstall?.success) {
      let serverProcess;
      try {
        log.step("🌐 Step 6: Start Web Server");

        // Start server in background
        serverProcess = spawn("npm", ["run", "serve"], {
          cwd: join(projectRoot, "test", "e2e"),
          shell: true,
          stdio: "pipe",
        });

        // Wait for server to be ready
        log.info("Waiting for server at http://localhost:4173...");
        await new Promise((resolve, reject) => {
          const maxAttempts = 30;
          let attempts = 0;

          const checkServer = async () => {
            try {
              const response = await fetch("http://localhost:4173");
              if (response.ok) {
                log.success("Server is ready");
                resolve();
              } else {
                throw new Error("Server not ready");
              }
            } catch {
              attempts++;
              if (attempts >= maxAttempts) {
                reject(new Error("Server failed to start"));
              } else {
                setTimeout(checkServer, 1000);
              }
            }
          };

          checkServer();
        });

        log.step("🎯 Step 7: Run Playwright E2E Tests");
        await runCommand("npm", ["test"], {
          cwd: join(projectRoot, "test", "e2e"),
        });
        log.success("E2E tests passed");
        results.checks.e2eTests = { success: true };
      } catch (error) {
        log.error("E2E tests failed");
        results.checks.e2eTests = { success: false, error: error.message };
        results.success = false;
      } finally {
        if (serverProcess) {
          log.info("Stopping web server...");
          serverProcess.kill();
        }
      }
    }
  }

  // Write results to file
  const summaryPath = join(projectRoot, "pr-ci-summary.json");
  writeFileSync(summaryPath, JSON.stringify(results, null, 2));
  log.info(`Results written to ${summaryPath}`);

  // Final summary
  console.log("\n" + "=".repeat(60));
  if (results.success) {
    log.success(`${colors.bold}All preflight checks passed! ✨${colors.reset}`);
    console.log("=".repeat(60) + "\n");
    process.exit(0);
  } else {
    log.error(`${colors.bold}Preflight checks failed${colors.reset}`);
    console.log("=".repeat(60) + "\n");
    console.log("Failed checks:");
    Object.entries(results.checks).forEach(([name, result]) => {
      if (!result.success && !result.skipped) {
        console.log(`  - ${name}: ${result.error}`);
      }
    });
    console.log("");
    process.exit(1);
  }
}

// Handle errors
process.on("unhandledRejection", (error) => {
  log.error(`Unhandled error: ${error.message}`);
  process.exit(1);
});

// Run preflight
runPreflight().catch((error) => {
  log.error(`Preflight failed: ${error.message}`);
  process.exit(1);
});
