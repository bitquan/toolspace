#!/usr/bin/env node

/**
 * Release validation script for Toolspace production deployment
 *
 * Validates:
 * - pricing.json contains real Stripe price IDs (not placeholders)
 * - All required GitHub secrets are present
 * - Configuration is ready for production
 *
 * Exit codes:
 * 0 = All checks passed
 * 1 = Validation failures found
 * 2 = Configuration errors
 */

import { readFileSync } from "fs";
import { fileURLToPath } from "url";
import { dirname, join } from "path";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// ANSI color codes for output
const colors = {
  red: "\x1b[31m",
  green: "\x1b[32m",
  yellow: "\x1b[33m",
  blue: "\x1b[34m",
  magenta: "\x1b[35m",
  cyan: "\x1b[36m",
  reset: "\x1b[0m",
  bold: "\x1b[1m",
};

function log(message, color = "reset") {
  console.log(`${colors[color]}${message}${colors.reset}`);
}

function logError(message) {
  log(`❌ ${message}`, "red");
}

function logSuccess(message) {
  log(`✅ ${message}`, "green");
}

function logWarning(message) {
  log(`⚠️  ${message}`, "yellow");
}

function logInfo(message) {
  log(`ℹ️  ${message}`, "blue");
}

class ReleaseValidator {
  constructor() {
    this.errors = [];
    this.warnings = [];
    this.passed = [];
  }

  /**
   * Validate pricing.json configuration
   */
  validatePricingConfig() {
    logInfo("Checking pricing.json configuration...");

    try {
      const configPath = join(__dirname, "..", "config", "pricing.json");
      const configContent = readFileSync(configPath, "utf8");
      const config = JSON.parse(configContent);

      // Check Pro plan
      const proPlan = config.plans?.pro;
      if (!proPlan) {
        this.errors.push("Pro plan not found in pricing.json");
      } else {
        if (proPlan.stripePriceId === "price_XXXXXXXXXXXXXXXX") {
          this.errors.push(
            'Pro plan stripePriceId contains placeholder "price_XXXXXXXXXXXXXXXX"'
          );
        } else if (
          !proPlan.stripePriceId ||
          !proPlan.stripePriceId.startsWith("price_")
        ) {
          this.errors.push(
            `Pro plan stripePriceId invalid: ${proPlan.stripePriceId}`
          );
        } else {
          this.passed.push(`Pro plan stripePriceId: ${proPlan.stripePriceId}`);
        }

        if (proPlan.price?.amount !== 900) {
          this.errors.push(
            `Pro plan amount should be 900 cents ($9), got ${proPlan.price?.amount}`
          );
        } else {
          this.passed.push("Pro plan amount: $9.00");
        }
      }

      // Check Pro+ plan
      const proPlusPlan = config.plans?.pro_plus;
      if (!proPlusPlan) {
        this.errors.push("Pro+ plan not found in pricing.json");
      } else {
        if (proPlusPlan.stripePriceId === "price_YYYYYYYYYYYYYYYY") {
          this.errors.push(
            'Pro+ plan stripePriceId contains placeholder "price_YYYYYYYYYYYYYYYY"'
          );
        } else if (
          !proPlusPlan.stripePriceId ||
          !proPlusPlan.stripePriceId.startsWith("price_")
        ) {
          this.errors.push(
            `Pro+ plan stripePriceId invalid: ${proPlusPlan.stripePriceId}`
          );
        } else {
          this.passed.push(
            `Pro+ plan stripePriceId: ${proPlusPlan.stripePriceId}`
          );
        }

        if (proPlusPlan.price?.amount !== 1900) {
          this.errors.push(
            `Pro+ plan amount should be 1900 cents ($19), got ${proPlusPlan.price?.amount}`
          );
        } else {
          this.passed.push("Pro+ plan amount: $19.00");
        }
      }

      this.passed.push("pricing.json loaded successfully");
    } catch (error) {
      this.errors.push(`Failed to read/parse pricing.json: ${error.message}`);
    }
  }

  /**
   * Validate GitHub secrets (if running in GitHub Actions)
   */
  async validateGitHubSecrets() {
    logInfo("Checking GitHub Actions environment...");

    // Only run in GitHub Actions environment
    if (!process.env.GITHUB_ACTIONS) {
      this.warnings.push(
        "Not running in GitHub Actions - skipping secrets validation"
      );
      return;
    }

    const requiredSecrets = [
      "FIREBASE_TOKEN",
      "FIREBASE_PROJECT_ID",
      "STRIPE_SECRET_KEY",
      "STRIPE_WEBHOOK_SECRET",
      "STRIPE_PRICE_PRO_MONTH",
      "STRIPE_PRICE_PRO_PLUS_MONTH",
    ];

    const secretsStatus = [];

    for (const secret of requiredSecrets) {
      const value = process.env[secret];
      if (!value) {
        this.errors.push(`Required secret ${secret} is not set`);
      } else if (this.isPlaceholderValue(secret, value)) {
        this.errors.push(`Secret ${secret} contains placeholder value`);
      } else {
        this.passed.push(`Secret ${secret} is configured`);
        secretsStatus.push({
          name: secret,
          present: true,
          type: this.getSecretType(secret, value),
        });
      }
    }

    if (secretsStatus.length > 0) {
      logInfo("Secrets summary:");
      secretsStatus.forEach((s) => {
        log(`  ${s.name}: ${s.type}`, "cyan");
      });
    }
  }

  /**
   * Check if a value is a placeholder
   */
  isPlaceholderValue(secretName, value) {
    const placeholders = {
      FIREBASE_PROJECT_ID: ["your-prod-project-id"],
      STRIPE_SECRET_KEY: ["sk_live_***", "sk_test_***"],
      STRIPE_WEBHOOK_SECRET: ["whsec_***"],
      STRIPE_PRICE_PRO_MONTH: ["price_XXXXXXXXXXXXXXXX"],
      STRIPE_PRICE_PRO_PLUS_MONTH: ["price_YYYYYYYYYYYYYYYY"],
    };

    return placeholders[secretName]?.includes(value) || false;
  }

  /**
   * Get the type/category of a secret value
   */
  getSecretType(secretName, value) {
    if (secretName.includes("STRIPE_SECRET_KEY")) {
      return value.startsWith("sk_live_")
        ? "live"
        : value.startsWith("sk_test_")
        ? "test"
        : "unknown";
    }
    if (secretName.includes("PRICE")) {
      return "price_id";
    }
    if (secretName.includes("WEBHOOK")) {
      return "webhook_secret";
    }
    if (secretName.includes("FIREBASE")) {
      return secretName.includes("TOKEN") ? "token" : "project_id";
    }
    return "configured";
  }

  /**
   * Validate workflow files contain proper placeholders
   */
  validateWorkflowFiles() {
    logInfo("Checking workflow files...");

    try {
      // Check prod-release.yml
      const prodWorkflowPath = join(
        __dirname,
        "..",
        ".github",
        "workflows",
        "prod-release.yml"
      );
      const prodContent = readFileSync(prodWorkflowPath, "utf8");

      if (prodContent.includes("your-prod-project-id")) {
        this.errors.push(
          'prod-release.yml contains placeholder "your-prod-project-id"'
        );
      } else {
        this.passed.push("prod-release.yml placeholders updated");
      }

      // Check staging-release.yml
      const stagingWorkflowPath = join(
        __dirname,
        "..",
        ".github",
        "workflows",
        "staging-release.yml"
      );
      const stagingContent = readFileSync(stagingWorkflowPath, "utf8");

      if (stagingContent.includes("your-prod-project-id")) {
        this.errors.push(
          'staging-release.yml contains placeholder "your-prod-project-id"'
        );
      } else {
        this.passed.push("staging-release.yml placeholders updated");
      }

      // Check for explicit permissions in workflows
      if (!prodContent.includes("permissions:")) {
        this.errors.push("prod-release.yml missing explicit permissions block");
      } else {
        this.passed.push("prod-release.yml has explicit permissions");
      }

      if (!stagingContent.includes("permissions:")) {
        this.errors.push(
          "staging-release.yml missing explicit permissions block"
        );
      } else {
        this.passed.push("staging-release.yml has explicit permissions");
      }
    } catch (error) {
      this.errors.push(`Failed to validate workflow files: ${error.message}`);
    }
  }

  /**
   * Run all validations
   */
  async validate() {
    log("\n🔍 TOOLSPACE RELEASE VALIDATION", "bold");
    log("====================================", "blue");

    this.validatePricingConfig();
    await this.validateGitHubSecrets();
    this.validateWorkflowFiles();

    // Report results
    log("\n📊 VALIDATION RESULTS", "bold");
    log("===================", "blue");

    if (this.passed.length > 0) {
      log("\n✅ PASSED CHECKS:", "green");
      this.passed.forEach((check) => logSuccess(check));
    }

    if (this.warnings.length > 0) {
      log("\n⚠️  WARNINGS:", "yellow");
      this.warnings.forEach((warning) => logWarning(warning));
    }

    if (this.errors.length > 0) {
      log("\n❌ FAILED CHECKS:", "red");
      this.errors.forEach((error) => logError(error));

      log("\n💥 VALIDATION FAILED", "red");
      log("Fix the above issues before proceeding with release.", "red");
      return false;
    }

    log("\n🎉 ALL VALIDATIONS PASSED!", "green");
    log("Production release is ready to proceed.", "green");
    return true;
  }
}

// Main execution
async function main() {
  try {
    const validator = new ReleaseValidator();
    const success = await validator.validate();

    process.exit(success ? 0 : 1);
  } catch (error) {
    logError(`Unexpected error: ${error.message}`);
    if (process.env.DEBUG) {
      console.error(error.stack);
    }
    process.exit(2);
  }
}

// Run if called directly
if (import.meta.url === `file://${process.argv[1]}`) {
  main();
}
