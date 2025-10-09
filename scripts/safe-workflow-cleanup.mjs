#!/usr/bin/env node
// scripts/safe-workflow-cleanup.mjs
// SAFE cleanup: Only disables truly redundant workflows (no branch deletion)

import fs from "node:fs";
import path from "node:path";

const WF_DIR = ".github/workflows";

// Workflows that are TRULY redundant (replaced by better alternatives)
const SAFE_TO_DISABLE = [
  "ci.yml", // Replaced by pr-ci.yml + nightly-ci.yml
  "policy-checks.yml", // Functionality in other checks
  "push-diagnose.yml", // Debug workflow, not needed
];

console.log("🧹 Safe Workflow Cleanup\n");
console.log(
  "This script will disable redundant workflows by renaming them to .disabled\n"
);

let disabled = [];
let errors = [];

for (const workflow of SAFE_TO_DISABLE) {
  const filePath = path.join(WF_DIR, workflow);
  const disabledPath = `${filePath}.disabled`;

  try {
    if (fs.existsSync(filePath)) {
      fs.renameSync(filePath, disabledPath);
      disabled.push(workflow);
      console.log(`✅ Disabled: ${workflow}`);
    } else {
      console.log(`⚠️  Not found: ${workflow} (already disabled or removed)`);
    }
  } catch (error) {
    errors.push({ workflow, error: error.message });
    console.error(`❌ Error disabling ${workflow}: ${error.message}`);
  }
}

console.log("\n" + "=".repeat(60));
console.log("📊 SUMMARY");
console.log("=".repeat(60));
console.log(`Workflows disabled: ${disabled.length}`);
console.log(`Errors: ${errors.length}`);

if (disabled.length > 0) {
  console.log("\n✅ The following workflows have been disabled:");
  disabled.forEach((w) => console.log(`   - ${w}`));
  console.log("\nTo re-enable, rename from .yml.disabled back to .yml");
}

console.log(
  "\n💡 All automation workflows (auto-assign, auto-pr, etc.) remain active."
);
console.log("💡 No branches were deleted.");
console.log("✅ Safe cleanup complete!");
