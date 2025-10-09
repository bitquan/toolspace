#!/usr/bin/env node
// scripts/set-workflow-perms.mjs
// Harden all .github/workflows/*.yml(yaml) by setting explicit GITHUB_TOKEN permissions.
// - Defaults: { contents: "read", actions: "read" }
// - Elevations per known workflow that needs writes (issues/PRs/commits).
import fs from "node:fs";
import path from "node:path";
import YAML from "yaml";

const ROOT = process.cwd();
const WF_DIR = path.join(ROOT, ".github", "workflows");
const dryRun = process.argv.includes("--dry-run");

// Map workflow filename -> permissions block to apply (override defaults)
const ELEVATE = {
  // creates branches / pushes commits / comments
  "issue-to-branch.yml": {
    contents: "write",
    pull_requests: "write",
    issues: "write",
  },
  // may push or write PR body/labels
  "auto-pr.yml": { contents: "write", pull_requests: "write", issues: "write" },
  // merges PRs, closes issues, deletes branches
  "pr-merge.yml": {
    contents: "write",
    pull_requests: "write",
    issues: "write",
  },
  // writes dev logs back to repo + reads PRs/issues
  "dev-log-updater.yml": {
    contents: "write",
    pull_requests: "read",
    issues: "read",
  },
  // roadmap -> issues generator
  "roadmap-to-issues.yml": {
    contents: "read",
    issues: "write",
    pull_requests: "write",
  },
  // adaptive sprint manager (creates milestones/comments/labels/issues)
  "delta-scheduler.yml": {
    contents: "write",
    issues: "write",
    pull_requests: "write",
  },
  "delta-progress.yml": {
    contents: "write",
    issues: "write",
    pull_requests: "read",
  },
  "delta-report.yml": { contents: "write" }, // writes reports to repo
  "delta-watchdog.yml": {
    contents: "read",
    issues: "write",
    actions: "read",
  },
  // notifications only (reads repo, posts to webhooks only)
  "delta-notify.yml": { contents: "read" },
  "delta-digest.yml": { contents: "read", issues: "read", actions: "read" }, // reads data for digest
  // Firebase hosting needs to post PR comments and check status
  "firebase-hosting-pull-request.yml": {
    contents: "read",
    checks: "write",
    pull_requests: "write",
  },
  "firebase-hosting-merge.yml": { contents: "read" },
  // Preview hosting
  "preview-hosting.yml": {
    contents: "read",
    pull_requests: "write",
  },
  // OPS-Zeta security/quality scans
  "zeta-scan.yml": {
    contents: "read",
    issues: "write",
    pull_requests: "write",
    security_events: "write",
  },
  "zeta-autofix.yml": {
    contents: "write",
    pull_requests: "write",
  },
  "zeta-autodev.yml": {
    contents: "write",
    pull_requests: "write",
    issues: "write",
    actions: "read",
  },
  // Workflow cleanup tools
  "workflow-cleanup.yml": {
    actions: "write",
    contents: "read",
  },
  "nuclear-cleanup.yml": {
    actions: "write",
    contents: "read",
  },
  "auto-approve-actions.yml": {
    actions: "write",
    contents: "read",
  },
  // CI/test-only pipelines → read-only
  "branch-ci.yml": { contents: "read", actions: "read" },
  "test-runner.yml": { contents: "read", actions: "read" },
  "policy-checks.yml": { contents: "read", actions: "read" },
  "auth-security-ok.yml": { contents: "read", actions: "read" },
  "auth-security-gates.yml": { contents: "read", actions: "read" },
  "pr-ci.yml": { contents: "read", actions: "read" },
  "nightly-ci.yml": { contents: "write", issues: "write" }, // Creates maintenance issues + commits weekly digest
};

const DEFAULTS = { contents: "read", actions: "read" };

function normalizePerms(obj) {
  // Convert { a: "read", b: "write" } -> YAML friendly
  const out = {};
  for (const [k, v] of Object.entries(obj)) out[k.replace(/_/g, "-")] = v;
  return out;
}

function mergePerms(current, desired) {
  const merged = { ...current, ...desired };
  // If any write scope present, keep it; otherwise stick to read
  return merged;
}

function ensurePermissions(doc, fileName) {
  const base = normalizePerms(DEFAULTS);
  const elevate = normalizePerms(ELEVATE[path.basename(fileName)] || {});
  const desired = Object.keys(elevate).length
    ? mergePerms(base, elevate)
    : base;

  // If workflow already has a permissions block, downscope unless it already needs write
  const existing = doc.get("permissions");
  if (!existing) {
    doc.set("permissions", desired);
    return { changed: true, reason: "added" };
  }
  const existingObj = doc.toJSON().permissions || {};
  // Only upgrade to required write scopes; otherwise set to defaults
  const needsWrite = Object.values(elevate).includes("write");
  const target = needsWrite ? mergePerms(existingObj, desired) : base;
  const same = JSON.stringify(existingObj) === JSON.stringify(target);
  if (same) return { changed: false, reason: "unchanged" };
  doc.set("permissions", target);
  return { changed: true, reason: "updated" };
}

const files = fs.existsSync(WF_DIR)
  ? fs
      .readdirSync(WF_DIR)
      .filter((f) => f.endsWith(".yml") || f.endsWith(".yaml"))
  : [];

const report = [];
for (const f of files) {
  const p = path.join(WF_DIR, f);
  const raw = fs.readFileSync(p, "utf8");
  const doc = YAML.parseDocument(raw);
  const res = ensurePermissions(doc, f);
  if (res.changed && !dryRun) fs.writeFileSync(p, doc.toString(), "utf8");
  report.push({ file: f, ...res });
}

console.log("🔒 Permissions Hardening Report:");
console.log("================================\n");
for (const r of report) {
  const emoji = r.changed ? "✅" : "ℹ️ ";
  console.log(`${emoji} ${r.file}: ${r.reason}`);
}
console.log("\n");
if (dryRun) {
  console.log(
    "🔍 (DRY RUN) No files written. Re-run without --dry-run to apply changes."
  );
} else {
  console.log(
    `✅ Applied permissions hardening to ${
      report.filter((r) => r.changed).length
    } workflow(s).`
  );
}
