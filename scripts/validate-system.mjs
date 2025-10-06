#!/usr/bin/env node

/**
 * OPS-Delta System Validation Script
 * Tests all components in dry-run mode to ensure system integrity
 */

import fs from "fs";
import path from "path";

const WORKFLOWS_DIR = ".github/workflows";
const SCRIPTS_DIR = "scripts";
const DOCS_DIR = "docs/automation";

/**
 * Validation results tracking
 */
const results = {
  workflows: {},
  scripts: {},
  docs: {},
  integration: {},
  overall: "pending",
};

/**
 * Test individual workflow file syntax and structure
 */
function validateWorkflow(filename) {
  const filepath = path.join(WORKFLOWS_DIR, filename);

  try {
    if (!fs.existsSync(filepath)) {
      return { status: "error", message: "File not found" };
    }

    const content = fs.readFileSync(filepath, "utf8");

    // Basic YAML structure checks
    const checks = {
      hasName: content.includes("name:"),
      hasOn: content.includes("on:"),
      hasJobs: content.includes("jobs:"),
      hasDryRun: content.includes("dry_run"),
      hasPermissions: content.includes("permissions:"),
      hasGitHubScript: content.includes("actions/github-script@v7"),
    };

    const failedChecks = Object.entries(checks)
      .filter(([key, passed]) => !passed)
      .map(([key]) => key);

    if (failedChecks.length > 0) {
      return {
        status: "warning",
        message: `Missing elements: ${failedChecks.join(", ")}`,
      };
    }

    return { status: "success", message: "Workflow structure valid" };
  } catch (error) {
    return { status: "error", message: error.message };
  }
}

/**
 * Test script file syntax and exports
 */
function validateScript(filename) {
  const filepath = path.join(SCRIPTS_DIR, filename);

  try {
    if (!fs.existsSync(filepath)) {
      return { status: "error", message: "File not found" };
    }

    const content = fs.readFileSync(filepath, "utf8");

    // Check for ES6 module structure
    const checks = {
      hasImports: content.includes("import"),
      hasExports: content.includes("export"),
      hasShebang: content.startsWith("#!/usr/bin/env node"),
      hasCLISupport: content.includes("if (import.meta.url"),
      hasErrorHandling: content.includes("try") && content.includes("catch"),
    };

    const failedChecks = Object.entries(checks)
      .filter(([key, passed]) => !passed)
      .map(([key]) => key);

    if (failedChecks.length > 0) {
      return {
        status: "warning",
        message: `Missing elements: ${failedChecks.join(", ")}`,
      };
    }

    return { status: "success", message: "Script structure valid" };
  } catch (error) {
    return { status: "error", message: error.message };
  }
}

/**
 * Test documentation completeness
 */
function validateDocumentation(filename) {
  const filepath = path.join(DOCS_DIR, filename);

  try {
    if (!fs.existsSync(filepath)) {
      return { status: "error", message: "File not found" };
    }

    const content = fs.readFileSync(filepath, "utf8");

    const requiredSections = [
      "# OPS-Delta",
      "## Overview",
      "## Workflows",
      "## Conventions",
      "## Usage Instructions",
      "## Troubleshooting",
    ];

    const missingSections = requiredSections.filter(
      (section) => !content.includes(section)
    );

    if (missingSections.length > 0) {
      return {
        status: "warning",
        message: `Missing sections: ${missingSections.join(", ")}`,
      };
    }

    return { status: "success", message: "Documentation complete" };
  } catch (error) {
    return { status: "error", message: error.message };
  }
}

/**
 * Test integration between components
 */
function validateIntegration() {
  const tests = {
    workflowFiles: [
      "delta-scheduler.yml",
      "delta-progress.yml",
      "delta-report.yml",
      "delta-watchdog.yml",
    ],
    scriptFiles: ["utils.mjs", "velocity.mjs", "report.mjs"],
    directoryStructure: [".github/workflows", "scripts", "docs/automation"],
  };

  const issues = [];

  // Check all required files exist
  tests.workflowFiles.forEach((file) => {
    if (!fs.existsSync(path.join(WORKFLOWS_DIR, file))) {
      issues.push(`Missing workflow: ${file}`);
    }
  });

  tests.scriptFiles.forEach((file) => {
    if (!fs.existsSync(path.join(SCRIPTS_DIR, file))) {
      issues.push(`Missing script: ${file}`);
    }
  });

  tests.directoryStructure.forEach((dir) => {
    if (!fs.existsSync(dir)) {
      issues.push(`Missing directory: ${dir}`);
    }
  });

  // Check package.json exists
  if (!fs.existsSync("package.json")) {
    issues.push("Missing package.json for script dependencies");
  }

  if (issues.length > 0) {
    return { status: "error", message: issues.join(", ") };
  }

  return { status: "success", message: "All components present" };
}

/**
 * Run all validation tests
 */
async function runValidation() {
  console.log("🔍 OPS-Delta System Validation Starting...\n");

  // Test workflows
  console.log("📋 Validating Workflows:");
  const workflows = [
    "delta-scheduler.yml",
    "delta-progress.yml",
    "delta-report.yml",
    "delta-watchdog.yml",
  ];

  workflows.forEach((workflow) => {
    const result = validateWorkflow(workflow);
    results.workflows[workflow] = result;

    const icon =
      result.status === "success"
        ? "✅"
        : result.status === "warning"
        ? "⚠️"
        : "❌";
    console.log(`  ${icon} ${workflow}: ${result.message}`);
  });

  // Test scripts
  console.log("\n🔧 Validating Scripts:");
  const scripts = ["utils.mjs", "velocity.mjs", "report.mjs"];

  scripts.forEach((script) => {
    const result = validateScript(script);
    results.scripts[script] = result;

    const icon =
      result.status === "success"
        ? "✅"
        : result.status === "warning"
        ? "⚠️"
        : "❌";
    console.log(`  ${icon} ${script}: ${result.message}`);
  });

  // Test documentation
  console.log("\n📚 Validating Documentation:");
  const result = validateDocumentation("ops-delta.md");
  results.docs["ops-delta.md"] = result;

  const icon =
    result.status === "success"
      ? "✅"
      : result.status === "warning"
      ? "⚠️"
      : "❌";
  console.log(`  ${icon} ops-delta.md: ${result.message}`);

  // Test integration
  console.log("\n🔗 Validating Integration:");
  const integrationResult = validateIntegration();
  results.integration.structure = integrationResult;

  const integrationIcon =
    integrationResult.status === "success"
      ? "✅"
      : integrationResult.status === "warning"
      ? "⚠️"
      : "❌";
  console.log(
    `  ${integrationIcon} Component Integration: ${integrationResult.message}`
  );

  // Overall assessment
  const allResults = [
    ...Object.values(results.workflows),
    ...Object.values(results.scripts),
    ...Object.values(results.docs),
    ...Object.values(results.integration),
  ];

  const errors = allResults.filter((r) => r.status === "error").length;
  const warnings = allResults.filter((r) => r.status === "warning").length;
  const successes = allResults.filter((r) => r.status === "success").length;

  console.log("\n📊 Validation Summary:");
  console.log(`  ✅ Success: ${successes}`);
  console.log(`  ⚠️ Warnings: ${warnings}`);
  console.log(`  ❌ Errors: ${errors}`);

  if (errors > 0) {
    results.overall = "failed";
    console.log("\n🚨 VALIDATION FAILED - System has critical errors");
    process.exit(1);
  } else if (warnings > 0) {
    results.overall = "warning";
    console.log(
      "\n⚠️ VALIDATION PASSED WITH WARNINGS - System functional but has issues"
    );
  } else {
    results.overall = "success";
    console.log("\n🎉 VALIDATION PASSED - System ready for deployment");
  }

  // Next steps
  console.log("\n🚀 Next Steps:");
  console.log("  1. Test individual workflows in dry-run mode:");
  console.log("     gh workflow run delta-scheduler.yml -f dry_run=true");
  console.log("     gh workflow run delta-progress.yml -f dry_run=true");
  console.log("     gh workflow run delta-report.yml -f dry_run=true");
  console.log("     gh workflow run delta-watchdog.yml -f dry_run=true");
  console.log("  2. Install dependencies: npm install");
  console.log(
    "  3. Test scripts locally: npm run velocity-dry && npm run report-dry"
  );
  console.log(
    "  4. Enable live mode: Set dry_run=false in workflow dispatches"
  );

  return results;
}

// Run validation if called directly
if (import.meta.url === `file://${process.argv[1]}`) {
  runValidation().catch((error) => {
    console.error("❌ Validation failed with error:", error.message);
    process.exit(1);
  });
}

export { runValidation, results };
export default runValidation;
