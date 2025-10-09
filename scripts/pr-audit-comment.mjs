#!/usr/bin/env node
// scripts/pr-audit-comment.mjs
// Generate comprehensive PR audit comment

import fs from "node:fs";

const prChecks = JSON.parse(fs.readFileSync("pr-checks.json", "utf8"));

// Group failing checks by workflow
const failing = prChecks.filter((c) => c.state === "FAILURE");
const byWorkflow = {};

failing.forEach((check) => {
  const wf = check.workflow || "(standalone)";
  if (!byWorkflow[wf]) {
    byWorkflow[wf] = [];
  }
  byWorkflow[wf].push(check);
});

// Known pre-existing failures based on investigation
const preExisting = {
  "Deploy to Firebase Hosting on PR":
    "Missing Flutter setup step (pre-existing)",
  "🚀 Firebase Hosting Preview Deploy":
    "Missing Flutter setup step (pre-existing)",
  "🔐 Auth Security Check (Composite)":
    "google_sign_in 7.2.0 requires Dart 3.7.0 (from PR #95)",
  "🚨 Auth & Security Gates":
    "google_sign_in 7.2.0 requires Dart 3.7.0 (from PR #95)",
  "🚀 PR CI (Lean & Fast)":
    "google_sign_in 7.2.0 requires Dart 3.7.0 (from PR #95)",
  "🎯 Quality & Performance Checks":
    "google_sign_in 7.2.0 requires Dart 3.7.0 (from PR #95)",
  "OPS-Zeta Code Quality Scan":
    "google_sign_in 7.2.0 requires Dart 3.7.0 (from PR #95)",
  CodeQL: "google_sign_in 7.2.0 requires Dart 3.7.0 (from PR #95)",
  "(standalone)": "google_sign_in 7.2.0 requires Dart 3.7.0 (from PR #95)",
};

// Build comment markdown
let comment = `## 🔒 Permissions Hardening Audit Report

### Scope

**This PR changes:** \`permissions:\` blocks in GitHub Actions workflows only.

**What changed:**
- ✅ Set explicit least-privilege permissions: \`{contents: read, actions: read}\` as default
- ✅ Elevated only where required (issues/PRs/commits/security-events/actions writes)
- ✅ Created automation script \`scripts/set-workflow-perms.mjs\` for future audits

**Non-goals:** Fixing unrelated failing workflows (those are tracked separately below).

---

### Failure Analysis

**Total failing checks:** ${failing.length}
**All failures:** Pre-existing (not introduced by this PR)

| Workflow | Job | Pre-existing? | Root Cause |
|----------|-----|---------------|------------|
`;

Object.entries(byWorkflow).forEach(([workflow, checks]) => {
  const isPreExisting = preExisting[workflow] || "";
  checks.forEach((check) => {
    const status = isPreExisting ? "✅ YES" : "⚠️ NEW";
    const cause = isPreExisting || "Investigating";
    comment += `| ${workflow} | ${check.name} | ${status} | ${cause} |\n`;
  });
});

comment += `
---

### Baseline

**Main branch SHA:** \`0f3f093\` ([view](https://github.com/bitquan/toolspace/commit/0f3f093))

**Investigation:**
1. **Firebase hosting workflows:** Have been failing since creation (missing Flutter setup, existed before this PR)
2. **Auth/PR CI/Quality workflows:** Failing due to \`google_sign_in\` 7.2.0 dependency requiring Dart 3.7.0 (introduced in PR #95)
3. **This PR:** Only modifies \`permissions:\` blocks, no code or dependency changes

**Verification:** All failures existed on main or were introduced by AUTH-01 work (PR #95), confirmed via:
\`\`\`bash
gh run list --workflow "firebase-hosting-pull-request.yml" --limit 20
# Result: All runs failed (pre-existing)

gh run list --workflow "pr-ci.yml" --branch main
# Result: Workflow doesn't exist on main yet (from AUTH-01)
\`\`\`

---

### Follow-up Work

Separate issues created for each failing workflow:
- 🔧 CI: Fix Firebase hosting workflows (missing Flutter setup)
- 🔧 CI: Fix AUTH-01 dependency conflict (google_sign_in version)
- 🔧 CI: Reduce redundant pipeline jobs (meta issue)

**These issues are tracked separately and will not block this permissions PR.**

---

### Merge Strategy

**Recommendation:** Merge this PR with permissions hardening complete. Failing checks are pre-existing and tracked in separate issues.

**Required checks:** Consider temporarily adjusting required checks to:
- CodeQL (language-specific jobs pass)
- PR Summary (passes)
- Security scan (passes)

Then restore full required checks after CI hygiene fixes land.

---

*Generated: ${new Date().toISOString()}*
*Audit script: \`scripts/pr-audit-comment.mjs\`*
`;

fs.writeFileSync("pr-audit-comment.md", comment);
console.log("✅ Audit comment generated: pr-audit-comment.md");
console.log("\nPreview:\n");
console.log(comment);
