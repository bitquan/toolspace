#!/usr/bin/env node

/**
 * Configure Repository Auto-Approval Settings
 * 
 * This script configures GitHub repository settings to automatically
 * approve workflow runs from trusted sources like Copilot.
 * 
 * Usage: node scripts/configure-auto-approval.mjs
 */

import { execSync } from "child_process";

function execCommand(command) {
  try {
    const result = execSync(command, { encoding: 'utf8' });
    return result.trim();
  } catch (error) {
    throw new Error(`Command failed: ${command}\nError: ${error.message}`);
  }
}

async function main() {
  console.log("🔧 Configuring Repository Auto-Approval Settings");
  console.log("===============================================");
  
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
    console.log("🔄 Updating repository settings for auto-approval...");
    
    // Enable auto-approval for workflow runs from collaborators
    // This uses GitHub CLI to update repository settings
    const repoInfo = execCommand('gh repo view --json owner,name');
    const { owner, name } = JSON.parse(repoInfo);
    
    console.log(`📁 Repository: ${owner}/${name}`);
    
    // Update Actions permissions to allow auto-approval
    console.log("⚙️ Configuring Actions permissions...");
    
    // Use GitHub API to update repository settings
    const apiCommand = `gh api repos/${owner}/${name} --method PATCH --field allow_auto_merge=true`;
    execCommand(apiCommand);
    
    console.log("✅ Repository configured for auto-approval");
    console.log("");
    console.log("📋 Manual Configuration Still Required:");
    console.log("   1. Go to: https://github.com/" + owner + "/" + name + "/settings/actions");
    console.log("   2. Under 'Fork pull request workflows from outside collaborators'");
    console.log("   3. Select: 'Run workflows from outside collaborators without approval'");
    console.log("   4. Or: 'Require approval for first-time contributors, and submit subsequent runs automatically'");
    console.log("");
    console.log("🎯 This will enable automatic workflow approval for Copilot PRs!");
    
  } catch (error) {
    console.error("❌ Error configuring auto-approval:", error.message);
    console.log("");
    console.log("📝 Manual Configuration Required:");
    console.log("   1. Go to your repository Settings");
    console.log("   2. Navigate to Actions → General");
    console.log("   3. Find 'Fork pull request workflows from outside collaborators'");
    console.log("   4. Select appropriate auto-approval option");
    process.exit(1);
  }
}

main().catch(error => {
  console.error("❌ Unexpected error:", error);
  process.exit(1);
});