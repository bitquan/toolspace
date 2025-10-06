#!/usr/bin/env node

/**
 * Bulk Approve Copilot PRs Script
 *
 * This script approves all open pull requests created by the Copilot SWE Agent.
 *
 * Usage: node scripts/approve-copilot-prs.mjs [--dry-run]
 *
 * Environment Variables Required:
 * - GITHUB_TOKEN: Personal access token with repo permissions
 * - GITHUB_REPOSITORY: Repository in format "owner/repo" (optional, auto-detected)
 */

import { Octokit } from "@octokit/rest";
import { execSync } from "child_process";

/**
 * Parse command line arguments
 */
function parseArgs() {
  const args = process.argv.slice(2);
  const options = {
    dryRun: false,
  };

  for (const arg of args) {
    if (arg === "--dry-run") {
      options.dryRun = true;
    } else if (arg === "--help" || arg === "-h") {
      console.log("Usage: node scripts/approve-copilot-prs.mjs [--dry-run]");
      console.log("");
      console.log("Options:");
      console.log("  --dry-run        Preview actions without making changes");
      console.log("  --help, -h       Show this help message");
      process.exit(0);
    }
  }

  return options;
}

/**
 * Get GitHub repository information from environment or git config
 */
function getRepositoryInfo() {
  // Try environment variable first
  if (process.env.GITHUB_REPOSITORY) {
    const [owner, repo] = process.env.GITHUB_REPOSITORY.split("/");
    return { owner, repo };
  }

  // Fallback to git remote origin
  try {
    const remoteUrl = execSync("git remote get-url origin", {
      encoding: "utf8",
    }).trim();
    const match = remoteUrl.match(/github\.com[:/]([^/]+)\/([^/.]+)/);

    if (match) {
      return { owner: match[1], repo: match[2] };
    }
  } catch (error) {
    console.error("ERROR: Could not determine repository from git remote");
  }

  throw new Error(
    "Could not determine GitHub repository. Set GITHUB_REPOSITORY environment variable."
  );
}

/**
 * Validate environment
 */
function validateEnvironment() {
  if (!process.env.GITHUB_TOKEN) {
    console.error("ERROR: GITHUB_TOKEN environment variable is required");
    console.error("");
    console.error("Set it in your shell:");
    console.error(
      '  Windows (PowerShell): $env:GITHUB_TOKEN="your_token_here"'
    );
    console.error(
      '  macOS/Linux (Bash):   export GITHUB_TOKEN="your_token_here"'
    );
    console.error("");
    console.error("Create a token at: https://github.com/settings/tokens");
    console.error("Required scopes: repo, pull_requests");
    process.exit(1);
  }
}

/**
 * Approve a single PR
 */
async function approvePR(octokit, owner, repo, prNumber, prTitle, dryRun) {
  if (dryRun) {
    console.log(`DRY-RUN: Would approve PR #${prNumber}: "${prTitle}"`);
    return { approved: true, reason: "Dry run - no changes made" };
  }

  try {
    const reviewBody = `🤖 **Bulk Auto-approved Copilot PR**

This pull request has been approved as part of bulk approval for Copilot-generated PRs.

**Approval details:**
✅ Verified Copilot authorship
✅ Part of automated development pipeline
✅ Bulk approval requested on ${new Date().toISOString().split("T")[0]}

---
*Automated by Copilot PR Bulk Approval • ${new Date().toISOString()}*`;

    await octokit.rest.pulls.createReview({
      owner,
      repo,
      pull_number: prNumber,
      event: "APPROVE",
      body: reviewBody,
    });

    console.log(`SUCCESS: Approved PR #${prNumber}: "${prTitle}"`);
    return { approved: true, reason: "Successfully approved" };
  } catch (error) {
    console.error(`ERROR: Failed to approve PR #${prNumber}:`, error.message);
    return { approved: false, reason: `Error: ${error.message}` };
  }
}

/**
 * Main bulk approval function
 */
async function bulkApproveCopilotPRs(options) {
  try {
    console.log("Copilot PR Bulk Approval");
    console.log("========================");
    console.log(`Mode: ${options.dryRun ? "DRY RUN" : "LIVE"}`);

    // Initialize Octokit
    const octokit = new Octokit({
      auth: process.env.GITHUB_TOKEN,
    });

    // Get repository info
    const { owner, repo } = getRepositoryInfo();
    console.log(`Repository: ${owner}/${repo}`);

    // Fetch open PRs from Copilot
    console.log("\nINFO: Fetching open Copilot PRs...");
    const { data: prs } = await octokit.rest.pulls.list({
      owner,
      repo,
      state: "open",
      per_page: 100,
    });

    // Filter for Copilot PRs (both possible login names)
    const copilotPRs = prs.filter(
      (pr) =>
        pr.user.login === "app/copilot-swe-agent" || pr.user.login === "Copilot"
    );

    console.log(`INFO: Found ${prs.length} total open PRs`);
    console.log(`INFO: Found ${copilotPRs.length} Copilot PRs`);

    if (copilotPRs.length === 0) {
      console.log("INFO: No Copilot PRs found to approve");
      return;
    }

    // Process each Copilot PR
    const results = {
      approved: 0,
      skipped: 0,
      errors: 0,
    };

    console.log("\nINFO: Processing Copilot PRs...");
    for (const pr of copilotPRs) {
      console.log(`\nINFO: Processing PR #${pr.number}: "${pr.title}"`);
      console.log(`INFO: Created: ${pr.created_at}`);
      console.log(`INFO: State: ${pr.state}`);

      // Check if already approved by getting reviews
      try {
        const { data: reviews } = await octokit.rest.pulls.listReviews({
          owner,
          repo,
          pull_number: pr.number,
        });

        const alreadyApproved = reviews.some(
          (review) =>
            review.state === "APPROVED" &&
            review.user.login === (process.env.GITHUB_ACTOR || "unknown")
        );

        if (alreadyApproved) {
          console.log(`SKIP: PR #${pr.number} already approved by you`);
          results.skipped++;
          continue;
        }
      } catch (error) {
        console.log(
          `WARNING: Could not check existing reviews for PR #${pr.number}`
        );
      }

      const result = await approvePR(
        octokit,
        owner,
        repo,
        pr.number,
        pr.title,
        options.dryRun
      );

      if (result.approved) {
        results.approved++;
      } else {
        results.errors++;
      }
    }

    // Summary
    console.log("\n========================");
    console.log("Bulk Approval Summary");
    console.log("========================");
    console.log(`Approved: ${results.approved}`);
    console.log(`Skipped: ${results.skipped}`);
    console.log(`Errors: ${results.errors}`);
    console.log(`Total Copilot PRs: ${copilotPRs.length}`);

    if (options.dryRun) {
      console.log("\nINFO: This was a dry run - no actual changes were made");
      console.log("INFO: Remove --dry-run flag to apply changes");
    }
  } catch (error) {
    console.error("ERROR: Bulk approval failed:", error.message);

    if (error.status === 401) {
      console.error("HINT: Check your GITHUB_TOKEN permissions");
    } else if (error.status === 403) {
      console.error(
        "HINT: Token might not have sufficient permissions (need: repo, pull_requests)"
      );
    }

    process.exit(1);
  }
}

// Main execution
const options = parseArgs();
validateEnvironment();

bulkApproveCopilotPRs(options).catch((error) => {
  console.error("ERROR: Unexpected error:", error);
  process.exit(1);
});
