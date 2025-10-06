#!/usr/bin/env node

/**
 * GitHub Auto-Assignment Script for New Issues
 *
 * This script automatically assigns newly created GitHub issues to the github-copilot user
 * and adds the 'ready' label to trigger the OPS-Zeta Auto-Dev pipeline.
 *
 * Usage: node scripts/auto-assign-new-issues.mjs [--dry-run] [--max-age=hours]
 *
 * Environment Variables Required:
 * - GITHUB_TOKEN: Personal access token with repo permissions
 * - GITHUB_REPOSITORY: Repository in format "owner/repo" (optional, auto-detected)
 *
 * Options:
 * - --dry-run: Preview actions without making changes
 * - --max-age=N: Only process issues created within N hours (default: 24)
 */

import { Octokit } from "@octokit/rest";
import { execSync } from "child_process";
import fs from "fs";

// Configuration
const COPILOT_USER = "github-copilot";
const READY_LABEL = "ready";
const DEFAULT_MAX_AGE_HOURS = 24;

/**
 * Parse command line arguments
 */
function parseArgs() {
  const args = process.argv.slice(2);
  const options = {
    dryRun: false,
    maxAgeHours: DEFAULT_MAX_AGE_HOURS,
  };

  for (const arg of args) {
    if (arg === "--dry-run") {
      options.dryRun = true;
    } else if (arg.startsWith("--max-age=")) {
      options.maxAgeHours =
        parseInt(arg.split("=")[1]) || DEFAULT_MAX_AGE_HOURS;
    } else if (arg === "--help" || arg === "-h") {
      console.log(
        "Usage: node scripts/auto-assign-new-issues.mjs [--dry-run] [--max-age=hours]"
      );
      console.log("");
      console.log("Options:");
      console.log("  --dry-run        Preview actions without making changes");
      console.log(
        "  --max-age=N      Only process issues created within N hours (default: 24)"
      );
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
    console.error("Required scopes: repo, issues");
    process.exit(1);
  }
}

/**
 * Log auto-assignment activity
 */
function logActivity(message, dryRun = false) {
  const timestamp = new Date().toISOString();
  const prefix = dryRun ? "[DRY-RUN]" : "";
  const logEntry = `[${timestamp}] ${prefix} ${message}\n`;

  // Ensure logs directory exists
  if (!fs.existsSync("logs")) {
    fs.mkdirSync("logs", { recursive: true });
  }

  fs.appendFileSync("logs/auto-assignments.log", logEntry);
  console.log(`LOG: ${prefix} ${message}`);
}

/**
 * Check if issue should be auto-assigned
 */
function shouldAutoAssign(issue, maxAgeHours) {
  // Check if issue is too old
  const issueAge = Date.now() - new Date(issue.created_at).getTime();
  const maxAge = maxAgeHours * 60 * 60 * 1000; // Convert hours to milliseconds

  if (issueAge > maxAge) {
    return {
      assign: false,
      reason: `Issue is older than ${maxAgeHours} hours`,
    };
  }

  // Check if already assigned to someone
  if (issue.assignee && issue.assignee.login !== COPILOT_USER) {
    return {
      assign: false,
      reason: `Already assigned to ${issue.assignee.login}`,
    };
  }

  // Check if already assigned to Copilot
  if (issue.assignee && issue.assignee.login === COPILOT_USER) {
    return { assign: false, reason: "Already assigned to github-copilot" };
  }

  // Check if already has ready label
  const hasReadyLabel = issue.labels.some(
    (label) => label.name === READY_LABEL
  );
  if (hasReadyLabel && issue.assignee?.login === COPILOT_USER) {
    return {
      assign: false,
      reason: "Already processed (has ready label and assigned to Copilot)",
    };
  }

  // Check if issue is closed
  if (issue.state === "closed") {
    return { assign: false, reason: "Issue is closed" };
  }

  // Check if issue is a pull request
  if (issue.pull_request) {
    return { assign: false, reason: "Is a pull request, not an issue" };
  }

  return { assign: true, reason: "Eligible for auto-assignment" };
}

/**
 * Process a single issue for auto-assignment
 */
async function processIssue(octokit, owner, repo, issue, dryRun) {
  const issueNumber = issue.number;
  const shouldAssign = shouldAutoAssign(issue, DEFAULT_MAX_AGE_HOURS);

  console.log(`\nINFO: Processing issue #${issueNumber}: "${issue.title}"`);
  console.log(`INFO: Created: ${issue.created_at}`);
  console.log(`INFO: Current assignee: ${issue.assignee?.login || "None"}`);
  console.log(
    `INFO: Labels: ${issue.labels.map((l) => l.name).join(", ") || "None"}`
  );
  console.log(`INFO: Decision: ${shouldAssign.reason}`);

  if (!shouldAssign.assign) {
    console.log(`SKIP: Issue #${issueNumber} - ${shouldAssign.reason}`);
    return { processed: false, reason: shouldAssign.reason };
  }

  if (dryRun) {
    console.log(
      `DRY-RUN: Would assign issue #${issueNumber} to ${COPILOT_USER}`
    );
    console.log(
      `DRY-RUN: Would add '${READY_LABEL}' label to issue #${issueNumber}`
    );
    logActivity(
      `Would auto-assign issue #${issueNumber} to ${COPILOT_USER}`,
      true
    );
    return { processed: true, reason: "Dry run - no changes made" };
  }

  try {
    // Assign to Copilot
    console.log(
      `PROGRESS: Assigning issue #${issueNumber} to ${COPILOT_USER}...`
    );
    await octokit.rest.issues.addAssignees({
      owner,
      repo,
      issue_number: issueNumber,
      assignees: [COPILOT_USER],
    });

    // Add ready label if not present
    const hasReadyLabel = issue.labels.some(
      (label) => label.name === READY_LABEL
    );
    if (!hasReadyLabel) {
      console.log(
        `PROGRESS: Adding '${READY_LABEL}' label to issue #${issueNumber}...`
      );
      await octokit.rest.issues.addLabels({
        owner,
        repo,
        issue_number: issueNumber,
        labels: [READY_LABEL],
      });
    }

    // Add automation comment
    const commentBody = `**Auto-assigned to Copilot Pipeline**

This issue has been automatically assigned to the GitHub Copilot development pipeline.

### What happens next:
1. **OPS-Gamma**: Feature branch will be created
2. **OPS-Zeta**: Auto-development will begin
3. **CI/CD**: Tests and validation will run
4. **PR**: Pull request will be opened for review

---
*Automated by Auto-Assignment Script • ${new Date().toISOString()}*`;

    await octokit.rest.issues.createComment({
      owner,
      repo,
      issue_number: issueNumber,
      body: commentBody,
    });

    console.log(
      `SUCCESS: Auto-assigned issue #${issueNumber} to ${COPILOT_USER}`
    );
    logActivity(`Auto-assigned issue #${issueNumber} to ${COPILOT_USER}`);

    return { processed: true, reason: "Successfully auto-assigned" };
  } catch (error) {
    console.error(
      `ERROR: Failed to process issue #${issueNumber}:`,
      error.message
    );
    logActivity(
      `Failed to auto-assign issue #${issueNumber}: ${error.message}`
    );
    return { processed: false, reason: `Error: ${error.message}` };
  }
}

/**
 * Main auto-assignment function
 */
async function autoAssignNewIssues(options) {
  try {
    console.log("GitHub Auto-Assignment for New Issues");
    console.log("=====================================");
    console.log(`Mode: ${options.dryRun ? "DRY RUN" : "LIVE"}`);
    console.log(`Max Age: ${options.maxAgeHours} hours`);

    // Initialize Octokit
    const octokit = new Octokit({
      auth: process.env.GITHUB_TOKEN,
    });

    // Get repository info
    const { owner, repo } = getRepositoryInfo();
    console.log(`Repository: ${owner}/${repo}`);

    // Calculate time threshold
    const timeThreshold = new Date(
      Date.now() - options.maxAgeHours * 60 * 60 * 1000
    );
    console.log(
      `Processing issues created after: ${timeThreshold.toISOString()}`
    );

    // Fetch recent issues
    console.log("\nINFO: Fetching recent issues...");
    const { data: issues } = await octokit.rest.issues.listForRepo({
      owner,
      repo,
      state: "open",
      sort: "created",
      direction: "desc",
      per_page: 50, // Adjust as needed
    });

    console.log(`INFO: Found ${issues.length} open issues`);

    // Filter issues by age
    const recentIssues = issues.filter((issue) => {
      const issueDate = new Date(issue.created_at);
      return issueDate > timeThreshold;
    });

    console.log(
      `INFO: ${recentIssues.length} issues within ${options.maxAgeHours} hours`
    );

    if (recentIssues.length === 0) {
      console.log("INFO: No recent issues to process");
      return;
    }

    // Process each issue
    const results = {
      processed: 0,
      skipped: 0,
      errors: 0,
    };

    for (const issue of recentIssues) {
      const result = await processIssue(
        octokit,
        owner,
        repo,
        issue,
        options.dryRun
      );

      if (result.processed) {
        results.processed++;
      } else if (result.reason.startsWith("Error:")) {
        results.errors++;
      } else {
        results.skipped++;
      }
    }

    // Summary
    console.log("\n=====================================");
    console.log("Auto-Assignment Summary");
    console.log("=====================================");
    console.log(`Processed: ${results.processed}`);
    console.log(`Skipped: ${results.skipped}`);
    console.log(`Errors: ${results.errors}`);
    console.log(`Total: ${recentIssues.length}`);

    if (options.dryRun) {
      console.log("\nINFO: This was a dry run - no actual changes were made");
      console.log("INFO: Remove --dry-run flag to apply changes");
    }
  } catch (error) {
    console.error("ERROR: Auto-assignment failed:", error.message);

    if (error.status === 401) {
      console.error("HINT: Check your GITHUB_TOKEN permissions");
    } else if (error.status === 403) {
      console.error(
        "HINT: Token might not have sufficient permissions (need: repo, issues)"
      );
    }

    logActivity(`Auto-assignment failed: ${error.message}`);
    process.exit(1);
  }
}

// Main execution
if (import.meta.url === `file://${process.argv[1]}`) {
  const options = parseArgs();

  validateEnvironment();

  autoAssignNewIssues(options).catch((error) => {
    console.error("ERROR: Unexpected error:", error);
    process.exit(1);
  });
}
