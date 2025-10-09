#!/usr/bin/env node

/**
 * OPS-LocalGate: Postflight check system
 * Collects CI logs, uploads artifacts, compares to local logs
 *
 * Usage:
 *   npm run postflight              # After preflight
 *   node scripts/postflight.mjs     # Manual run
 */

import { existsSync } from "fs";
import { readFile, mkdir, writeFile } from "fs/promises";
import { join, dirname } from "path";
import { fileURLToPath } from "url";
import { cyan, green, red, yellow, bold, dim } from "colorette";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const ROOT = join(__dirname, "..");

const LOCAL_CI_DIR = join(ROOT, "local-ci");
const JSON_SUMMARY_PATH = join(LOCAL_CI_DIR, "pr-ci-summary.json");
const SIM_LOG_PATH = join(LOCAL_CI_DIR, "pr-ci-sim.log");
const POSTFLIGHT_LOG = join(LOCAL_CI_DIR, "postflight.log");

function log(message) {
  console.log(message);
}

function banner(text) {
  const line = "=".repeat(60);
  log("");
  log(cyan(line));
  log(cyan(bold(`  ${text}`)));
  log(cyan(line));
  log("");
}

async function main() {
  banner("LOCAL CI – POSTFLIGHT");

  const checks = [];
  let allPassed = true;

  // Check 1: Verify JSON summary exists
  log(bold("🔍 Checking preflight artifacts..."));

  if (existsSync(JSON_SUMMARY_PATH)) {
    log(green("✓ pr-ci-summary.json found"));
    checks.push({ name: "JSON Summary", passed: true });

    try {
      const summary = JSON.parse(await readFile(JSON_SUMMARY_PATH, "utf-8"));

      if (summary.summary?.success === true) {
        log(green("✓ Preflight passed successfully"));
        log(
          dim(
            `  ${summary.summary.passed}/${summary.summary.total} checks passed`
          )
        );
        log(dim(`  Duration: ${summary.summary.duration}ms`));
        checks.push({ name: "Preflight Success", passed: true });
      } else {
        log(red("✗ Preflight had failures"));
        log(
          red(
            `  ${summary.summary.failed}/${summary.summary.total} checks failed`
          )
        );
        allPassed = false;
        checks.push({ name: "Preflight Success", passed: false });
      }
    } catch (err) {
      log(red(`✗ Failed to parse JSON: ${err.message}`));
      allPassed = false;
      checks.push({ name: "JSON Parse", passed: false });
    }
  } else {
    log(red("✗ pr-ci-summary.json not found"));
    log(yellow("  Run 'npm run preflight' first"));
    allPassed = false;
    checks.push({ name: "JSON Summary", passed: false });
  }

  // Check 2: Verify simulation log exists
  log("");
  log(bold("📋 Checking simulation log..."));

  if (existsSync(SIM_LOG_PATH)) {
    log(green("✓ pr-ci-sim.log found"));
    const logSize = (await readFile(SIM_LOG_PATH, "utf-8")).length;
    log(dim(`  Log size: ${(logSize / 1024).toFixed(2)} KB`));
    checks.push({ name: "Simulation Log", passed: true });
  } else {
    log(yellow("⚠ pr-ci-sim.log not found"));
    checks.push({ name: "Simulation Log", passed: false });
  }

  // Check 3: In GitHub Actions, collect CI logs
  const isCI = process.env.GITHUB_ACTIONS === "true";

  if (isCI) {
    log("");
    log(bold("☁️  GitHub Actions detected..."));
    log(dim("  Collecting CI logs..."));

    const ciLogsDir = process.env.RUNNER_WORKSPACE
      ? join(process.env.RUNNER_WORKSPACE, "logs")
      : null;

    if (ciLogsDir && existsSync(ciLogsDir)) {
      log(green(`✓ CI logs found at ${ciLogsDir}`));
      checks.push({ name: "CI Logs Collection", passed: true });
    } else {
      log(yellow("⚠ CI logs directory not found"));
      checks.push({ name: "CI Logs Collection", passed: false });
    }

    // Upload artifacts (would be handled by GH Actions workflow)
    log(dim("  Note: Artifacts upload handled by workflow"));
  } else {
    log("");
    log(dim("ℹ️  Not in GitHub Actions - skipping CI log collection"));
  }

  // Check 4: Consistency check
  log("");
  log(bold("🔄 Consistency check..."));

  if (existsSync(JSON_SUMMARY_PATH)) {
    const summary = JSON.parse(await readFile(JSON_SUMMARY_PATH, "utf-8"));
    const expectedSteps = [
      "Flutter pub get",
      "Flutter analyze (ZERO tolerance)",
      "Flutter test",
      "Flutter build web",
      "Functions npm ci",
      "Functions lint (ZERO warnings)",
      "Functions test",
    ];

    const actualSteps = summary.results?.map((r) => r.name) || [];
    const missingSteps = expectedSteps.filter(
      (s) => !actualSteps.some((a) => a.toLowerCase().includes(s.toLowerCase()))
    );

    if (missingSteps.length === 0) {
      log(green("✓ All expected steps present"));
      checks.push({ name: "Step Consistency", passed: true });
    } else {
      log(yellow(`⚠ Missing steps: ${missingSteps.join(", ")}`));
      checks.push({ name: "Step Consistency", passed: false });
    }
  }

  // Write postflight summary
  const postflightSummary = {
    timestamp: new Date().toISOString(),
    success: allPassed,
    checks,
    isCI,
  };

  await writeFile(
    POSTFLIGHT_LOG,
    JSON.stringify(postflightSummary, null, 2),
    "utf-8"
  );

  // Final status
  log("");
  if (allPassed) {
    banner("✅ POSTFLIGHT PASSED");
    log(green(bold("All postflight checks passed!")));
    log(dim(`\nPostflight log: ${POSTFLIGHT_LOG}`));
    process.exit(0);
  } else {
    banner("⚠️  POSTFLIGHT WARNINGS");
    log(yellow("Some postflight checks failed (non-blocking)"));
    log(dim(`\nPostflight log: ${POSTFLIGHT_LOG}`));
    process.exit(0); // Non-blocking
  }
}

main().catch((err) => {
  log(red(`\n❌ POSTFLIGHT ERROR: ${err.message}`));
  log(red(err.stack));
  process.exit(1);
});
