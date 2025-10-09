#!/usr/bin/env node
// scripts/audit-repo-cleanup.mjs
// AUDIT-ONLY: Reports stale branches and redundant workflows without deleting
// Run with --execute flag to actually perform cleanup (requires confirmation)

import { execSync } from "node:child_process";
import fs from "node:fs";
import readline from "node:readline";

const DAYS_STALE = 7;
const DRY_RUN = !process.argv.includes("--execute");

// Branches to always keep
const PROTECTED_BRANCHES = [
  /^main$/,
  /^dev$/,
  /^release\//,
  /^feat\/ops-permissions$/, // Active PR #96
  /^fix\/ci-firebase-hosting-missing-flutter$/, // Scaffold for #98
  /^fix\/ci-google-sign-in-dart-sdk-mismatch$/, // Scaffold for #99
  /^feat\/ci-hygiene-unified-pipeline$/, // Scaffold for #100
];

// Essential workflows to keep
const ESSENTIAL_WORKFLOWS = [
  // Core CI/CD
  "pr-ci.yml",
  "branch-ci.yml",
  "nightly-ci.yml",

  // Security & Auth
  "auth-security-ok.yml",
  "auth-security-gates.yml",

  // Firebase
  "firebase-hosting-merge.yml",
  "firebase-hosting-pull-request.yml",
  "preview-hosting.yml",

  // Quality
  "quality.yml",
  "e2e.yml",

  // OPS-Zeta (consolidated)
  "zeta-scan.yml",
  "zeta-autofix.yml",
  "zeta-autodev.yml",

  // Delta (adaptive sprint)
  "delta-scheduler.yml",
  "delta-progress.yml",
  "delta-report.yml",
  "delta-watchdog.yml",
  "delta-notify.yml",
  "delta-digest.yml",

  // Automation
  "roadmap-to-issues.yml",
  "dev-log-updater.yml",

  // Workflow management
  "workflow-cleanup.yml",
  "nuclear-cleanup.yml",
  "auto-approve-actions.yml",

  // Code analysis
  "codeql.yml",

  // Misc
  "labels.yml",
  "release.yml",
  "ui-screenshots.yml",
];

console.log("🔍 Repository Cleanup Audit\n");
console.log(
  DRY_RUN
    ? "📋 DRY RUN MODE (no changes will be made)\n"
    : "⚠️  EXECUTE MODE (changes will be applied)\n"
);

// === BRANCH ANALYSIS ===
console.log("=".repeat(60));
console.log("🌿 BRANCH ANALYSIS");
console.log("=".repeat(60) + "\n");

let staleBranches = [];
let protectedBranches = [];

try {
  const branches = execSync('git branch -r --format="%(refname:short)"', {
    encoding: "utf8",
  })
    .split("\n")
    .map((l) => l.trim().replace(/^origin\//, ""))
    .filter((b) => b && b !== "HEAD");

  for (const branch of branches) {
    // Check if protected
    const isProtected = PROTECTED_BRANCHES.some((pattern) =>
      pattern.test(branch)
    );

    if (isProtected) {
      protectedBranches.push(branch);
      continue;
    }

    // Check age
    try {
      const timestamp = execSync(`git log -1 --format=%ct origin/${branch}`, {
        encoding: "utf8",
      }).trim();
      const ageDays = (Date.now() / 1000 - parseInt(timestamp)) / 86400;

      if (ageDays > DAYS_STALE) {
        staleBranches.push({ name: branch, age: ageDays.toFixed(1) });
      }
    } catch (e) {
      console.log(`⚠️  Could not check age for ${branch}: ${e.message}`);
    }
  }

  console.log(`✅ Protected branches (${protectedBranches.length}):`);
  protectedBranches.forEach((b) => console.log(`   - ${b}`));

  console.log(
    `\n🗑️  Stale branches (${staleBranches.length}) - older than ${DAYS_STALE} days:`
  );
  if (staleBranches.length === 0) {
    console.log("   (none found)");
  } else {
    staleBranches.forEach(({ name, age }) => {
      console.log(`   - ${name} (${age} days old)`);
    });
  }
} catch (error) {
  console.error("❌ Error analyzing branches:", error.message);
}

// === WORKFLOW ANALYSIS ===
console.log("\n" + "=".repeat(60));
console.log("⚙️  WORKFLOW ANALYSIS");
console.log("=".repeat(60) + "\n");

const wfDir = ".github/workflows";
let redundantWorkflows = [];
let essentialWorkflows = [];

try {
  const allWorkflows = fs
    .readdirSync(wfDir)
    .filter((f) => f.endsWith(".yml") || f.endsWith(".yaml"))
    .filter((f) => !f.endsWith(".disabled"));

  for (const file of allWorkflows) {
    if (ESSENTIAL_WORKFLOWS.includes(file)) {
      essentialWorkflows.push(file);
    } else {
      redundantWorkflows.push(file);
    }
  }

  console.log(`✅ Essential workflows (${essentialWorkflows.length}):`);
  essentialWorkflows.forEach((w) => console.log(`   - ${w}`));

  console.log(
    `\n🚮 Potentially redundant workflows (${redundantWorkflows.length}):`
  );
  if (redundantWorkflows.length === 0) {
    console.log("   (none found)");
  } else {
    redundantWorkflows.forEach((w) => console.log(`   - ${w}`));
  }
} catch (error) {
  console.error("❌ Error analyzing workflows:", error.message);
}

// === SUMMARY ===
console.log("\n" + "=".repeat(60));
console.log("📊 SUMMARY");
console.log("=".repeat(60));
console.log(`Protected branches:       ${protectedBranches.length}`);
console.log(`Stale branches:           ${staleBranches.length}`);
console.log(`Essential workflows:      ${essentialWorkflows.length}`);
console.log(`Potentially redundant:    ${redundantWorkflows.length}`);

// === EXECUTION ===
if (!DRY_RUN && (staleBranches.length > 0 || redundantWorkflows.length > 0)) {
  console.log("\n" + "=".repeat(60));
  console.log("⚠️  EXECUTION CONFIRMATION REQUIRED");
  console.log("=".repeat(60));

  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
  });

  rl.question(
    '\n⚠️  Are you sure you want to DELETE the items listed above? (type "DELETE" to confirm): ',
    (answer) => {
      if (answer === "DELETE") {
        console.log("\n🔥 Executing cleanup...\n");

        // Delete stale branches
        staleBranches.forEach(({ name }) => {
          try {
            console.log(`🗑️  Deleting branch: ${name}`);
            execSync(`git push origin --delete ${name}`);
          } catch (e) {
            console.error(`❌ Failed to delete ${name}: ${e.message}`);
          }
        });

        // Delete redundant workflows
        redundantWorkflows.forEach((file) => {
          try {
            console.log(`🚮 Removing workflow: ${file}`);
            fs.unlinkSync(`${wfDir}/${file}`);
          } catch (e) {
            console.error(`❌ Failed to remove ${file}: ${e.message}`);
          }
        });

        console.log("\n✅ Cleanup complete!");
      } else {
        console.log("\n❌ Cleanup cancelled.");
      }
      rl.close();
    }
  );
} else if (DRY_RUN) {
  console.log(
    "\n💡 To execute cleanup, run: node scripts/audit-repo-cleanup.mjs --execute"
  );
  console.log(
    "⚠️  WARNING: This will permanently delete branches and workflows!"
  );
}
