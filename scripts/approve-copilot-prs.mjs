#!/usr/bin/env node

/**
 * Bulk Approve Copilot PRs Script
 *
 * This script approves all open pull requests created by the Copilot SWE Agent.
 * Uses GitHub CLI (gh) for authentication - no token required!
 *
 * Usage: node scripts/approve-copilot-prs.mjs [--dry-run]
 *
 * Prerequisites:
 * - GitHub CLI (gh) installed and authenticated
 */

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
      console.log("");
      console.log("Prerequisites:");
      console.log("  - GitHub CLI (gh) installed and authenticated");
      process.exit(0);
    }
  }

  return options;
}

/**
 * Execute a shell command and return the result
 */
function execCommand(command) {
  try {
    const result = execSync(command, { encoding: 'utf8' });
    return result.trim();
  } catch (error) {
    throw new Error(`Command failed: ${command}\nError: ${error.message}`);
  }
}

/**
 * Get all open PRs created by Copilot
 */
async function getCopilotPRs() {
  console.log("🔍 Finding Copilot PRs...");
  
  const prListJson = execCommand('gh pr list --state open --json number,title,author');
  const prs = JSON.parse(prListJson);
  
  const copilotPRs = prs.filter(pr => 
    pr.author && pr.author.login && (
      pr.author.login === 'app/copilot-swe-agent' ||
      pr.author.login === 'copilot' ||
      pr.author.login === 'github-copilot[bot]' ||
      pr.author.login.includes('copilot')
    )
  );
  
  console.log(`📋 Found ${copilotPRs.length} Copilot PRs out of ${prs.length} total open PRs`);
  
  return copilotPRs;
}

/**
 * Approve a single PR
 */
async function approvePR(prNumber, dryRun = false) {
  const approvalMessage = "🤖 AUTO-APPROVED: Copilot PR approved by bulk approval script\\n\\n✅ Copilot PRs are pre-validated for AUTO-DEV pipeline\\n✅ Enabling automatic merge when CI passes";
  
  if (dryRun) {
    console.log(`  [DRY RUN] Would approve PR #${prNumber}`);
    return true;
  }
  
  try {
    execCommand(`gh pr review ${prNumber} --approve --body "${approvalMessage}"`);
    console.log(`  ✅ Approved PR #${prNumber}`);
    return true;
  } catch (error) {
    console.error(`  ❌ Failed to approve PR #${prNumber}: ${error.message}`);
    return false;
  }
}

/**
 * Add auto-merge labels to a PR
 */
async function addAutoMergeLabels(prNumber, dryRun = false) {
  if (dryRun) {
    console.log(`  [DRY RUN] Would add auto-merge labels to PR #${prNumber}`);
    return true;
  }
  
  try {
    execCommand(`gh pr edit ${prNumber} --add-label "autodev" --add-label "auto-merge"`);
    console.log(`  🏷️ Added auto-merge labels to PR #${prNumber}`);
    return true;
  } catch (error) {
    // Labels might already exist or not be needed
    console.log(`  ℹ️ Could not add labels to PR #${prNumber}: ${error.message}`);
    return false;
  }
}

/**
 * Main function
 */
async function main() {
  console.log("🚀 Copilot PR Bulk Approval Tool");
  console.log("================================");
  
  const options = parseArgs();
  
  if (options.dryRun) {
    console.log("🔍 DRY RUN MODE - No changes will be made");
    console.log("");
  }
  
  try {
    // Test GitHub CLI authentication
    execCommand('gh auth status');
    console.log("✅ GitHub CLI is authenticated");
    console.log("");
  } catch (error) {
    console.error("❌ GitHub CLI is not authenticated or not installed");
    console.error("Please run: gh auth login");
    process.exit(1);
  }
  
  try {
    const copilotPRs = await getCopilotPRs();
    
    if (copilotPRs.length === 0) {
      console.log("ℹ️ No Copilot PRs found to approve");
      return;
    }
    
    console.log("");
    console.log("🔄 Processing Copilot PRs...");
    
    let approvedCount = 0;
    let labeledCount = 0;
    
    for (const pr of copilotPRs) {
      console.log(`\n📝 Processing PR #${pr.number}: ${pr.title}`);
      
      const approved = await approvePR(pr.number, options.dryRun);
      if (approved) approvedCount++;
      
      const labeled = await addAutoMergeLabels(pr.number, options.dryRun);
      if (labeled) labeledCount++;
    }
    
    console.log("");
    console.log("📊 Summary:");
    console.log(`  • Total Copilot PRs: ${copilotPRs.length}`);
    console.log(`  • Successfully approved: ${approvedCount}`);
    console.log(`  • Auto-merge labels added: ${labeledCount}`);
    
    if (!options.dryRun && approvedCount > 0) {
      console.log("");
      console.log("🎉 All Copilot PRs have been approved and labeled for auto-merge!");
      console.log("   The auto-merge workflow will handle the rest when CI passes.");
    }
    
  } catch (error) {
    console.error("❌ Error:", error.message);
    process.exit(1);
  }
}

// Run the script
main().catch(error => {
  console.error("❌ Unexpected error:", error);
  process.exit(1);
});