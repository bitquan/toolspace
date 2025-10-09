#!/usr/bin/env node
// scripts/baseline-audit.mjs
// Analyze PR checks vs main branch baseline to identify pre-existing failures

import fs from "node:fs";

const prChecks = JSON.parse(fs.readFileSync("pr-checks.json", "utf8"));
const mainRuns = JSON.parse(fs.readFileSync("main-runs.json", "utf8"));

// Get failing checks from PR
const failing = prChecks.filter((c) => c.state === "FAILURE");

console.log("## PR #96 Failing Checks\n");
console.log(`Total failing: ${failing.length}\n`);
console.log("| Workflow | Job | Status | Link |");
console.log("|----------|-----|--------|------|");

failing.forEach((check) => {
  const workflow = check.workflow || "(none)";
  const name = check.name;
  const link = check.link;
  console.log(`| ${workflow} | ${name} | FAILURE | [View](${link}) |`);
});

console.log("\n## Main Branch Baseline\n");
console.log(`Most recent SHA: ${mainRuns[0]?.headSha || "N/A"}`);
console.log(`Total runs analyzed: ${mainRuns.length}\n`);

// Group main runs by workflow name
const mainByWorkflow = {};
mainRuns.forEach((run) => {
  if (!mainByWorkflow[run.name]) {
    mainByWorkflow[run.name] = [];
  }
  mainByWorkflow[run.name].push(run);
});

console.log("### Main Branch Workflow Status\n");
console.log("| Workflow | Latest Status | SHA |");
console.log("|----------|---------------|-----|");

Object.entries(mainByWorkflow).forEach(([name, runs]) => {
  const latest = runs[0];
  const sha = latest.headSha.substring(0, 7);
  console.log(`| ${name} | ${latest.conclusion} | ${sha} |`);
});

// Export for use in PR comment
const auditData = {
  failing,
  mainSha: mainRuns[0]?.headSha,
  mainByWorkflow,
  timestamp: new Date().toISOString(),
};

fs.writeFileSync("audit-data.json", JSON.stringify(auditData, null, 2));
console.log("\n✅ Audit data saved to audit-data.json");
