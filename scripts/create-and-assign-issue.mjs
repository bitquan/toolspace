#!/usr/bin/env node

/**
 * GitHub Issue Creation and Auto-Assignment Script
 *
 * This script creates a new GitHub issue and optionally auto-assigns it to the
 * github-copilot user with the 'ready' label to trigger the OPS-Zeta pipeline.
 *
 * Usage: node scripts/create-and-assign-issue.mjs [--assign] [--dry-run]
 *
 * Environment Variables Required:
 * - GITHUB_TOKEN: Personal access token with repo permissions
 * - GITHUB_REPOSITORY: Repository in format "owner/repo" (optional, auto-detected)
 *
 * Options:
 * - --assign: Auto-assign to Copilot after creation
 * - --dry-run: Preview issue creation without making changes
 */

import { Octokit } from "@octokit/rest";
import { execSync } from "child_process";
import fs from "fs";
import readline from "readline";

// Configuration
const COPILOT_USER = "github-copilot";
const READY_LABEL = "ready";

/**
 * Parse command line arguments
 */
function parseArgs() {
  const args = process.argv.slice(2);
  const options = {
    assign: false,
    dryRun: false,
  };

  for (const arg of args) {
    if (arg === "--assign") {
      options.assign = true;
    } else if (arg === "--dry-run") {
      options.dryRun = true;
    } else if (arg === "--help" || arg === "-h") {
      console.log(
        "Usage: node scripts/create-and-assign-issue.mjs [--assign] [--dry-run]"
      );
      console.log("");
      console.log("Options:");
      console.log("  --assign         Auto-assign to Copilot after creation");
      console.log(
        "  --dry-run        Preview issue creation without making changes"
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
 * Prompt user for input
 */
function prompt(question) {
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
  });

  return new Promise((resolve) => {
    rl.question(question, (answer) => {
      rl.close();
      resolve(answer.trim());
    });
  });
}

/**
 * Get issue details from user
 */
async function getIssueDetails() {
  console.log("GitHub Issue Creation");
  console.log("====================");
  console.log("");

  const title = await prompt("Issue Title: ");
  if (!title) {
    console.error("ERROR: Issue title is required");
    process.exit(1);
  }

  console.log("");
  console.log("Issue Description (enter empty line to finish):");

  const bodyLines = [];
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
  });

  return new Promise((resolve) => {
    const askForLine = () => {
      rl.question("> ", (line) => {
        if (line.trim() === "") {
          rl.close();
          const body = bodyLines.join("\n").trim();
          resolve({ title, body });
        } else {
          bodyLines.push(line);
          askForLine();
        }
      });
    };
    askForLine();
  });
}

/**
 * Suggest labels based on title and body
 */
function suggestLabels(title, body) {
  const suggestions = [];
  const text = `${title} ${body}`.toLowerCase();

  // Feature keywords
  if (text.match(/\b(feature|add|implement|create|new)\b/)) {
    suggestions.push("enhancement");
  }

  // Bug keywords
  if (text.match(/\b(bug|fix|error|issue|problem|broken)\b/)) {
    suggestions.push("bug");
  }

  // Documentation keywords
  if (text.match(/\b(doc|documentation|readme|guide|tutorial)\b/)) {
    suggestions.push("documentation");
  }

  // UI/UX keywords
  if (text.match(/\b(ui|ux|interface|design|style|layout)\b/)) {
    suggestions.push("ui/ux");
  }

  // Performance keywords
  if (text.match(/\b(performance|speed|slow|optimize|fast)\b/)) {
    suggestions.push("performance");
  }

  // Testing keywords
  if (text.match(/\b(test|testing|spec|unit|integration)\b/)) {
    suggestions.push("testing");
  }

  return suggestions.length > 0 ? suggestions : ["enhancement"];
}

/**
 * Log issue creation activity
 */
function logActivity(message, dryRun = false) {
  const timestamp = new Date().toISOString();
  const prefix = dryRun ? "[DRY-RUN]" : "";
  const logEntry = `[${timestamp}] ${prefix} ${message}\n`;

  // Ensure logs directory exists
  if (!fs.existsSync("logs")) {
    fs.mkdirSync("logs", { recursive: true });
  }

  fs.appendFileSync("logs/issue-creation.log", logEntry);
  console.log(`LOG: ${prefix} ${message}`);
}

/**
 * Create GitHub issue
 */
async function createIssue(octokit, owner, repo, issueData, options) {
  const { title, body, labels } = issueData;

  if (options.dryRun) {
    console.log("");
    console.log("DRY-RUN: Issue Preview");
    console.log("======================");
    console.log(`Title: ${title}`);
    console.log(`Body: ${body || "(no description)"}`);
    console.log(`Labels: ${labels.join(", ") || "none"}`);
    console.log(`Repository: ${owner}/${repo}`);

    if (options.assign) {
      console.log(`DRY-RUN: Would assign to ${COPILOT_USER}`);
      console.log(`DRY-RUN: Would add '${READY_LABEL}' label`);
    }

    logActivity(`Would create issue: "${title}"`, true);
    return null;
  }

  try {
    console.log("PROGRESS: Creating issue...");

    const { data: issue } = await octokit.rest.issues.create({
      owner,
      repo,
      title,
      body,
      labels,
    });

    console.log(`SUCCESS: Created issue #${issue.number}`);
    console.log(`INFO: URL: ${issue.html_url}`);
    logActivity(`Created issue #${issue.number}: "${title}"`);

    if (options.assign) {
      console.log(`PROGRESS: Assigning to ${COPILOT_USER}...`);

      // Assign to Copilot
      await octokit.rest.issues.addAssignees({
        owner,
        repo,
        issue_number: issue.number,
        assignees: [COPILOT_USER],
      });

      // Add ready label if not already present
      if (!labels.includes(READY_LABEL)) {
        console.log(`PROGRESS: Adding '${READY_LABEL}' label...`);
        await octokit.rest.issues.addLabels({
          owner,
          repo,
          issue_number: issue.number,
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
*Automated by Issue Creation Script • ${new Date().toISOString()}*`;

      await octokit.rest.issues.createComment({
        owner,
        repo,
        issue_number: issue.number,
        body: commentBody,
      });

      console.log(`SUCCESS: Assigned to ${COPILOT_USER} and added automation`);
      logActivity(`Auto-assigned issue #${issue.number} to ${COPILOT_USER}`);
    }

    return issue;
  } catch (error) {
    console.error("ERROR: Failed to create issue:", error.message);
    logActivity(`Failed to create issue: ${error.message}`);
    throw error;
  }
}

/**
 * Main issue creation function
 */
async function createAndAssignIssue(options) {
  try {
    // Get repository info
    const { owner, repo } = getRepositoryInfo();
    console.log(`Repository: ${owner}/${repo}`);
    console.log(`Mode: ${options.dryRun ? "DRY RUN" : "LIVE"}`);
    console.log(`Auto-assign: ${options.assign ? "YES" : "NO"}`);
    console.log("");

    // Get issue details from user
    const { title, body } = await getIssueDetails();

    // Suggest labels
    const suggestedLabels = suggestLabels(title, body);
    console.log("");
    console.log(`Suggested labels: ${suggestedLabels.join(", ")}`);

    const useLabels = await prompt("Use suggested labels? (y/n): ");
    const labels = useLabels.toLowerCase().startsWith("y")
      ? suggestedLabels
      : [];

    if (options.assign && !labels.includes(READY_LABEL)) {
      labels.push(READY_LABEL);
    }

    // Initialize Octokit
    const octokit = new Octokit({
      auth: process.env.GITHUB_TOKEN,
    });

    // Create the issue
    const issue = await createIssue(
      octokit,
      owner,
      repo,
      { title, body, labels },
      options
    );

    if (!options.dryRun && issue) {
      console.log("");
      console.log("Issue Creation Complete!");
      console.log("========================");
      console.log(`SUCCESS: Issue #${issue.number} created`);
      console.log(`SUCCESS: Title: "${issue.title}"`);
      console.log(`INFO: URL: ${issue.html_url}`);

      if (options.assign) {
        console.log(`SUCCESS: Assigned to ${COPILOT_USER}`);
        console.log(
          "INFO: OPS-Gamma and OPS-Zeta pipelines will activate automatically"
        );
      }
    }
  } catch (error) {
    console.error("ERROR: Issue creation failed:", error.message);

    if (error.status === 401) {
      console.error("HINT: Check your GITHUB_TOKEN permissions");
    } else if (error.status === 403) {
      console.error(
        "HINT: Token might not have sufficient permissions (need: repo, issues)"
      );
    }

    process.exit(1);
  }
}

// Main execution
if (import.meta.url === `file://${process.argv[1]}`) {
  const options = parseArgs();

  validateEnvironment();

  createAndAssignIssue(options).catch((error) => {
    console.error("ERROR: Unexpected error:", error);
    process.exit(1);
  });
}
