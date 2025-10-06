#!/usr/bin/env node

/**
 * GitHub Issue Assignment Script for VS Code Copilot Integration
 *
 * This script assigns GitHub issues to the github-copilot user and adds the 'ready' label
 * to trigger the OPS-Zeta Auto-Dev pipeline.
 *
 * Usage: node scripts/assign-to-copilot.mjs <issue_number>
 *
 * Environment Variables Required:
 * - GITHUB_TOKEN: Personal access token with repo permissions
 * - GITHUB_REPOSITORY: Repository in format "owner/repo" (optional, auto-detected)
 */

import { Octokit } from "@octokit/rest";
import { execSync } from "child_process";
import fs from "fs";

// Configuration
const COPILOT_USER = "github-copilot";
const READY_LABEL = "ready";

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
 * Validate environment and arguments
 */
function validateEnvironment(issueNumber) {
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

  if (!issueNumber || isNaN(issueNumber)) {
    console.error("ERROR: Issue number is required and must be a valid number");
    console.error("Usage: node scripts/assign-to-copilot.mjs <issue_number>");
    process.exit(1);
  }
}

/**
 * Log assignment activity
 */
function logActivity(message) {
  const timestamp = new Date().toISOString();
  const logEntry = `[${timestamp}] ${message}\n`;

  // Ensure logs directory exists
  if (!fs.existsSync("logs")) {
    fs.mkdirSync("logs", { recursive: true });
  }

  fs.appendFileSync("logs/issue-assignments.log", logEntry);
  console.log(`LOG: ${message}`);
}

/**
 * Main assignment function
 */
async function assignIssueToCopilot(issueNumber) {
  try {
    console.log("GitHub Copilot Issue Assignment");
    console.log("====================================");
    console.log(`Issue: #${issueNumber}`);

    // Initialize Octokit
    const octokit = new Octokit({
      auth: process.env.GITHUB_TOKEN,
    });

    // Get repository info
    const { owner, repo } = getRepositoryInfo();
    console.log(`Repository: ${owner}/${repo}`);

    // Get issue details
    console.log("Fetching issue details...");
    const { data: issue } = await octokit.rest.issues.get({
      owner,
      repo,
      issue_number: issueNumber,
    });

    console.log(`Title: "${issue.title}"`);
    console.log(`Current Assignee: ${issue.assignee?.login || "None"}`);
    console.log(
      `Current Labels: ${issue.labels.map((l) => l.name).join(", ") || "None"}`
    );

    // Check if already assigned to Copilot
    if (issue.assignee?.login === COPILOT_USER) {
      console.log("DONE: Issue is already assigned to github-copilot");
    } else {
      // Assign to Copilot
      console.log(`PROGRESS: Assigning to ${COPILOT_USER}...`);
      await octokit.rest.issues.addAssignees({
        owner,
        repo,
        issue_number: issueNumber,
        assignees: [COPILOT_USER],
      });
      console.log(`SUCCESS: Assigned to ${COPILOT_USER}`);
      logActivity(`Assigned issue #${issueNumber} to ${COPILOT_USER}`);
    }

    // Check if 'ready' label exists
    const hasReadyLabel = issue.labels.some(
      (label) => label.name === READY_LABEL
    );

    if (hasReadyLabel) {
      console.log(`DONE: Issue already has '${READY_LABEL}' label`);
    } else {
      // Add 'ready' label
      console.log(`PROGRESS: Adding '${READY_LABEL}' label...`);
      await octokit.rest.issues.addLabels({
        owner,
        repo,
        issue_number: issueNumber,
        labels: [READY_LABEL],
      });
      console.log(`SUCCESS: Added '${READY_LABEL}' label`);
      logActivity(`Added '${READY_LABEL}' label to issue #${issueNumber}`);
    }

    // Add a comment to track automation
    const commentBody = `**Auto-assigned to Copilot Pipeline**

This issue has been automatically assigned to the GitHub Copilot development pipeline.

### What happens next:
1. **OPS-Gamma**: Feature branch will be created
2. **OPS-Zeta**: Auto-development will begin
3. **CI/CD**: Tests and validation will run
4. **PR**: Pull request will be opened for review

---
*Automated by VS Code Copilot Integration • ${new Date().toISOString()}*`;

    await octokit.rest.issues.createComment({
      owner,
      repo,
      issue_number: issueNumber,
      body: commentBody,
    });

    console.log("SUCCESS: Added tracking comment to issue");
    logActivity(`Added tracking comment to issue #${issueNumber}`);

    console.log("");
    console.log("Assignment Complete!");
    console.log("====================================");
    console.log(`SUCCESS: Issue #${issueNumber} assigned to ${COPILOT_USER}`);
    console.log(`SUCCESS: Added '${READY_LABEL}' label`);
    console.log(
      "INFO: OPS-Gamma and OPS-Zeta pipelines will activate automatically"
    );
    console.log(
      `INFO: View issue: https://github.com/${owner}/${repo}/issues/${issueNumber}`
    );
  } catch (error) {
    console.error("ERROR: Assignment failed:", error.message);

    if (error.status === 404) {
      console.error(
        "HINT: Issue might not exist or you might not have access to the repository"
      );
    } else if (error.status === 401) {
      console.error("HINT: Check your GITHUB_TOKEN permissions");
    } else if (error.status === 403) {
      console.error(
        "HINT: Token might not have sufficient permissions (need: repo, issues)"
      );
    }

    logActivity(
      `Assignment failed for issue #${issueNumber}: ${error.message}`
    );
    process.exit(1);
  }
}

// Main execution
if (import.meta.url === `file://${process.argv[1]}`) {
  const issueNumber = parseInt(process.argv[2]);

  validateEnvironment(issueNumber);

  assignIssueToCopilot(issueNumber).catch((error) => {
    console.error("ERROR: Unexpected error:", error);
    process.exit(1);
  });
}
