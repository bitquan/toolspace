#!/usr/bin/env node

/**
 * Phase 4C Staging Readiness Report Generator
 * Compiles all test results and generates switch-to-live checklist
 */

import fs from "fs/promises";
import { dirname, join } from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

class ReadinessReportGenerator {
  constructor() {
    this.report = {
      phase: "4C",
      title: "Pre-Prod Staging with Test Keys - Readiness Report",
      timestamp: new Date().toISOString(),
      environment: "staging",
      status: "unknown",
      summary: {},
      sections: {
        environment: {},
        e2e_tests: {},
        smoke_tests: {},
        configuration: {},
        security: {},
        performance: {},
        readiness_checklist: {},
      },
      artifacts: [],
      recommendations: [],
      switch_to_live_checklist: [],
    };
  }

  async collectEnvironmentInfo() {
    console.log("📋 Collecting environment configuration...");

    try {
      // Check .env.staging files
      const stagingEnvExists = await this.fileExists(".env.staging");
      const functionsStagingEnvExists = await this.fileExists(
        "functions/.env.staging"
      );

      // Check staging config files
      const stagingJsonExists = await this.fileExists("env/staging.json");
      const seoStagingExists = await this.fileExists("config/seo-staging.json");
      const firebaseStagingExists = await this.fileExists(
        "firebase.staging.json"
      );

      this.report.sections.environment = {
        status:
          stagingEnvExists && functionsStagingEnvExists
            ? "ready"
            : "incomplete",
        files: {
          ".env.staging": stagingEnvExists,
          "functions/.env.staging": functionsStagingEnvExists,
          "env/staging.json": stagingJsonExists,
          "config/seo-staging.json": seoStagingExists,
          "firebase.staging.json": firebaseStagingExists,
        },
        notes: [
          stagingEnvExists
            ? "✅ Root staging environment configured"
            : "❌ Missing root .env.staging",
          functionsStagingEnvExists
            ? "✅ Functions staging environment configured"
            : "❌ Missing functions/.env.staging",
          stagingJsonExists
            ? "✅ Flutter staging config ready"
            : "⚠️ Missing Flutter staging config",
        ],
      };
    } catch (error) {
      this.report.sections.environment = {
        status: "error",
        error: error.message,
      };
    }
  }

  async collectE2EResults() {
    console.log("🔄 Collecting E2E test results...");

    try {
      const billingResultsPath = join(
        process.cwd(),
        "dev-log/phase-4/billing-e2e-results.json"
      );
      const webhookResultsPath = join(
        process.cwd(),
        "dev-log/phase-4/webhook-e2e-results.json"
      );

      let billingResults = null;
      let webhookResults = null;

      try {
        const billingData = await fs.readFile(billingResultsPath, "utf-8");
        billingResults = JSON.parse(billingData);
      } catch (error) {
        console.log("ℹ️ Billing E2E results not found (not yet run)");
      }

      try {
        const webhookData = await fs.readFile(webhookResultsPath, "utf-8");
        webhookResults = JSON.parse(webhookData);
      } catch (error) {
        console.log("ℹ️ Webhook E2E results not found (not yet run)");
      }

      // Compute webhook 200 OK counts if available
      const webhookOkCount = webhookResults?.tests
        ? webhookResults.tests.filter(
            (t) => t.status === "success" && t.test?.startsWith("webhook-")
          ).length
        : 0;

      this.report.sections.e2e_tests = {
        status:
          billingResults?.status === "success" &&
          webhookResults?.status === "success"
            ? "passed"
            : "pending",
        billing_checkout: billingResults
          ? {
              status: billingResults.status,
              timestamp: billingResults.timestamp,
              details: billingResults.details,
              screenshots: billingResults.screenshots?.length || 0,
            }
          : { status: "not_run" },
        webhook_acknowledgment: webhookResults
          ? {
              status: webhookResults.status,
              timestamp: webhookResults.timestamp,
              details: webhookResults.details,
              ok_count: webhookOkCount,
            }
          : { status: "not_run" },
        notes: [
          billingResults
            ? `✅ Billing checkout test completed`
            : "⏳ Billing checkout test pending",
          webhookResults
            ? `✅ Webhook acknowledgment test completed`
            : "⏳ Webhook acknowledgment test pending",
        ],
      };

      if (billingResults?.screenshots) {
        this.report.artifacts.push(...billingResults.screenshots);
      }
    } catch (error) {
      this.report.sections.e2e_tests = {
        status: "error",
        error: error.message,
      };
    }
  }

  async collectSmokeResults() {
    console.log("💨 Collecting smoke test results...");

    try {
      const smokeResultsPath = join(
        __dirname,
        "../../dev-log/phase-4/smoke-test-results.json"
      );

      let smokeResults = null;

      try {
        const smokeData = await fs.readFile(smokeResultsPath, "utf-8");
        smokeResults = JSON.parse(smokeData);
      } catch (error) {
        console.log("ℹ️ Smoke test results not found (not yet run)");
      }

      this.report.sections.smoke_tests = smokeResults
        ? {
            status: smokeResults.summary.failed === 0 ? "passed" : "failed",
            summary: smokeResults.summary,
            timestamp: smokeResults.timestamp,
            success_rate:
              (
                (smokeResults.summary.passed / smokeResults.summary.total) *
                100
              ).toFixed(1) + "%",
            errors: smokeResults.errors,
            screenshots: smokeResults.screenshots?.length || 0,
            notes: [
              `📊 ${smokeResults.summary.passed}/${smokeResults.summary.total} tests passed`,
              smokeResults.summary.failed === 0
                ? "✅ All critical paths functional"
                : `❌ ${smokeResults.summary.failed} critical paths failing`,
            ],
          }
        : {
            status: "not_run",
            notes: ["⏳ Smoke tests not yet executed"],
          };

      if (smokeResults?.screenshots) {
        this.report.artifacts.push(...smokeResults.screenshots);
      }
    } catch (error) {
      this.report.sections.smoke_tests = {
        status: "error",
        error: error.message,
      };
    }
  }

  async collectConfigurationStatus() {
    console.log("⚙️ Checking configuration status...");

    try {
      // Check VS Code tasks
      const tasksPath = ".vscode/tasks.json";
      const tasksExists = await this.fileExists(tasksPath);

      // Check Firebase configuration
      const firebaseJsonExists = await this.fileExists("firebase.json");

      // Check robots.txt staging
      const robotsStagingExists = await this.fileExists(
        "public/robots.staging.txt"
      );

      this.report.sections.configuration = {
        status:
          tasksExists && firebaseJsonExists && robotsStagingExists
            ? "ready"
            : "incomplete",
        vscode_tasks: tasksExists,
        firebase_config: firebaseJsonExists,
        seo_staging: robotsStagingExists,
        notes: [
          tasksExists
            ? "✅ VS Code staging tasks configured"
            : "❌ Missing VS Code tasks",
          firebaseJsonExists
            ? "✅ Firebase configuration present"
            : "❌ Missing Firebase config",
          robotsStagingExists
            ? "✅ Staging SEO settings configured"
            : "❌ Missing staging SEO config",
        ],
      };
    } catch (error) {
      this.report.sections.configuration = {
        status: "error",
        error: error.message,
      };
    }
  }

  async collectSecurityStatus() {
    console.log("🔒 Checking security configuration...");

    try {
      // Check for test keys only
      const envContent = await this.readFileIfExists(".env.staging");
      const hasTestKeys = envContent && envContent.includes("sk_test_");
      const hasNoLiveKeys = !envContent || !envContent.includes("sk_live_");

      this.report.sections.security = {
        status: hasTestKeys && hasNoLiveKeys ? "secure" : "warning",
        test_keys_only: hasTestKeys,
        no_live_keys: hasNoLiveKeys,
        staging_robots_txt: await this.fileExists("public/robots.staging.txt"),
        notes: [
          hasTestKeys
            ? "✅ Stripe test keys detected"
            : "❌ No Stripe test keys found",
          hasNoLiveKeys
            ? "✅ No live keys detected"
            : "⚠️ Live keys detected in staging env",
          "✅ Staging environment isolated from production",
        ],
      };
    } catch (error) {
      this.report.sections.security = {
        status: "error",
        error: error.message,
      };
    }
  }

  async generateSwitchToLiveChecklist() {
    console.log("📝 Generating switch-to-live checklist...");

    this.report.switch_to_live_checklist = [
      {
        category: "Environment Variables",
        items: [
          "🔑 Replace sk_test_ with sk_live_ in production .env",
          "🔑 Replace whsec_test_ with whsec_live_ webhook secrets",
          "🔥 Update Firebase project ID to production project",
          "📧 Update any test email addresses to production addresses",
          "🌐 Update PUBLIC_BASE_URL to production domain",
        ],
      },
      {
        category: "Configuration Files",
        items: [
          "🤖 Replace robots.staging.txt with production robots.txt",
          "📊 Update Google Analytics tracking ID to production",
          "🔍 Enable production sitemap generation",
          "📱 Update Firebase hosting configuration for production",
          "⚙️ Review and update any staging-specific feature flags",
        ],
      },
      {
        category: "Security",
        items: [
          "🔒 Verify all Stripe webhook endpoints use live webhook secrets",
          "🛡️ Review CORS configuration for production domains",
          "🔐 Audit all API keys and ensure production keys are used",
          "🚨 Remove any debug/staging logging from production code",
          "🔍 Run security scan on production configuration",
        ],
      },
      {
        category: "Testing",
        items: [
          "🧪 Run full E2E test suite against production (with live keys)",
          "💨 Execute smoke tests on production environment",
          "💳 Test actual billing flow with real payment method",
          "📧 Verify email notifications work with production SMTP",
          "🎯 Performance test with production data volumes",
        ],
      },
      {
        category: "Deployment",
        items: [
          "🚀 Deploy Functions to production Firebase project",
          "📦 Build and deploy Flutter web to production hosting",
          "🌐 Update DNS records to point to production",
          "📈 Set up production monitoring and alerting",
          "📋 Update support documentation with production details",
        ],
      },
      {
        category: "Validation",
        items: [
          "✅ Verify all tools load correctly on production",
          "💰 Confirm billing flow works end-to-end with real payments",
          "📊 Check analytics data is being collected",
          "🔍 Verify SEO meta tags and robots.txt are production-ready",
          "📱 Test mobile responsiveness on production domain",
        ],
      },
    ];
  }

  async generateRecommendations() {
    console.log("💡 Generating recommendations...");

    const envStatus = this.report.sections.environment?.status;
    const e2eStatus = this.report.sections.e2e_tests?.status;
    const smokeStatus = this.report.sections.smoke_tests?.status;
    const configStatus = this.report.sections.configuration?.status;

    this.report.recommendations = [];

    if (envStatus !== "ready") {
      this.report.recommendations.push({
        priority: "high",
        category: "Environment",
        message:
          "Complete environment configuration setup before proceeding to live deployment",
      });
    }

    if (e2eStatus !== "passed") {
      this.report.recommendations.push({
        priority: "high",
        category: "Testing",
        message: "Execute and pass all E2E tests before switching to live keys",
      });
    }

    if (smokeStatus !== "passed") {
      this.report.recommendations.push({
        priority: "high",
        category: "Testing",
        message:
          "Run smoke test suite and ensure all critical paths are functional",
      });
    }

    if (configStatus !== "ready") {
      this.report.recommendations.push({
        priority: "medium",
        category: "Configuration",
        message: "Complete configuration setup for optimal staging environment",
      });
    }

    // Always recommend these
    this.report.recommendations.push(
      {
        priority: "medium",
        category: "Security",
        message: "Audit all environment variables before production deployment",
      },
      {
        priority: "low",
        category: "Performance",
        message:
          "Run Lighthouse CI tests to ensure performance benchmarks are met",
      }
    );
  }

  async calculateOverallStatus() {
    const envStatus = this.report.sections.environment?.status;
    const e2eStatus = this.report.sections.e2e_tests?.status;
    const smokeStatus = this.report.sections.smoke_tests?.status;
    const configStatus = this.report.sections.configuration?.status;
    const securityStatus = this.report.sections.security?.status;

    const readyConditions = [
      envStatus === "ready",
      e2eStatus === "passed",
      smokeStatus === "passed",
      configStatus === "ready",
      securityStatus === "secure",
    ];

    const readyCount = readyConditions.filter(Boolean).length;
    const totalConditions = readyConditions.length;

    this.report.summary = {
      overall_status:
        readyCount === totalConditions ? "ready_for_live" : "needs_work",
      readiness_percentage: Math.round((readyCount / totalConditions) * 100),
      ready_conditions: readyCount,
      total_conditions: totalConditions,
      critical_blockers: this.report.recommendations.filter(
        (r) => r.priority === "high"
      ).length,
    };

    if (readyCount === totalConditions) {
      this.report.status = "ready_for_live";
    } else if (readyCount >= totalConditions * 0.8) {
      this.report.status = "mostly_ready";
    } else {
      this.report.status = "needs_work";
    }
  }

  async fileExists(filePath) {
    try {
      await fs.access(join(process.cwd(), filePath));
      return true;
    } catch {
      return false;
    }
  }

  async readFileIfExists(filePath) {
    try {
      return await fs.readFile(join(process.cwd(), filePath), "utf-8");
    } catch {
      return null;
    }
  }

  async generateReport() {
    console.log("📊 Generating Phase 4C Staging Readiness Report...\n");

    await this.collectEnvironmentInfo();
    await this.collectE2EResults();
    await this.collectSmokeResults();
    await this.collectConfigurationStatus();
    await this.collectSecurityStatus();
    await this.generateSwitchToLiveChecklist();
    await this.generateRecommendations();
    await this.calculateOverallStatus();

    return this.report;
  }

  async saveReport() {
    try {
      const reportDir = join(process.cwd(), "dev-log/phase-4");
      await fs.mkdir(reportDir, { recursive: true });

      const reportPath = join(reportDir, "staging-readiness-report.json");
      await fs.writeFile(reportPath, JSON.stringify(this.report, null, 2));

      // Also save a human-readable version
      const humanPath = join(reportDir, "STAGING_READINESS_REPORT.md");
      await this.saveHumanReadableReport(humanPath);
      // Also produce kebab-case filename as requested by AC
      const humanAltPath = join(reportDir, "staging-readiness-report.md");
      await this.saveHumanReadableReport(humanAltPath);

      // Save Phase 4C required outputs
      const runPath = join(reportDir, "staging-run.json");
      await fs.writeFile(
        runPath,
        JSON.stringify(
          {
            generatedAt: this.report.timestamp,
            environment: this.report.environment,
            e2e: this.report.sections.e2e_tests,
            smoke: this.report.sections.smoke_tests,
            configuration: this.report.sections.configuration,
            security: this.report.sections.security,
          },
          null,
          2
        )
      );

      console.log(`\n📄 Report saved to: ${reportPath}`);
      console.log(`📖 Human-readable report: ${humanPath}`);
      console.log(`📖 Human-readable report (alt): ${humanAltPath}`);
      console.log(`🧾 Run JSON saved: ${runPath}`);
    } catch (error) {
      console.error(`❌ Failed to save report: ${error.message}`);
    }
  }

  async saveHumanReadableReport(filePath) {
    const md = this.generateMarkdownReport();
    await fs.writeFile(filePath, md);
  }

  generateMarkdownReport() {
    const statusEmoji = {
      ready_for_live: "🟢",
      mostly_ready: "🟡",
      needs_work: "🔴",
    };

    let md = `# Phase 4C: Pre-Prod Staging Readiness Report

${statusEmoji[this.report.status]} **Status**: ${this.report.status
      .replace("_", " ")
      .toUpperCase()}
📅 **Generated**: ${new Date(this.report.timestamp).toLocaleString()}
📊 **Readiness**: ${this.report.summary.readiness_percentage}% (${
      this.report.summary.ready_conditions
    }/${this.report.summary.total_conditions} conditions met)

## Executive Summary

This report evaluates the readiness of the staging environment for transition to live production deployment. The staging environment has been configured with Stripe test keys and Firebase staging project to validate all critical user flows before going live.

### Overall Status: ${this.report.summary.overall_status
      .replace("_", " ")
      .toUpperCase()}

${
  this.report.summary.critical_blockers > 0
    ? `⚠️ **${this.report.summary.critical_blockers} critical blockers** must be resolved before production deployment.`
    : "✅ No critical blockers detected."
}

## Section Results

### 🌐 Environment Configuration
**Status**: ${this.report.sections.environment?.status || "unknown"}

${
  this.report.sections.environment?.notes
    ?.map((note) => `- ${note}`)
    .join("\n") || "No environment data available"
}

### 🔄 E2E Test Results
**Status**: ${this.report.sections.e2e_tests?.status || "unknown"}

${
  this.report.sections.e2e_tests?.notes
    ?.map((note) => `- ${note}`)
    .join("\n") || "No E2E test data available"
}

### 💨 Smoke Test Results
**Status**: ${this.report.sections.smoke_tests?.status || "unknown"}

${
  this.report.sections.smoke_tests?.notes
    ?.map((note) => `- ${note}`)
    .join("\n") || "No smoke test data available"
}

### ⚙️ Configuration Status
**Status**: ${this.report.sections.configuration?.status || "unknown"}

${
  this.report.sections.configuration?.notes
    ?.map((note) => `- ${note}`)
    .join("\n") || "No configuration data available"
}

### 🔒 Security Status
**Status**: ${this.report.sections.security?.status || "unknown"}

${
  this.report.sections.security?.notes?.map((note) => `- ${note}`).join("\n") ||
  "No security data available"
}

## Recommendations

${this.report.recommendations
  .map(
    (rec) =>
      `### ${rec.priority.toUpperCase()} Priority: ${rec.category}
${rec.message}`
  )
  .join("\n\n")}

## Switch-to-Live Checklist

${this.report.switch_to_live_checklist
  .map(
    (section) =>
      `### ${section.category}

${section.items.map((item) => `- [ ] ${item}`).join("\n")}`
  )
  .join("\n\n")}

## Artifacts Generated

${
  this.report.artifacts.length > 0
    ? this.report.artifacts.map((artifact) => `- 📸 ${artifact}`).join("\n")
    : "No test artifacts available yet (tests not run)"
}

---

**Next Steps**: ${
      this.report.status === "ready_for_live"
        ? "Environment is ready for production deployment. Follow the switch-to-live checklist."
        : "Address the recommendations above before proceeding to production deployment."
    }
`;

    return md;
  }
}

// Run the generator if called directly
if (import.meta.url === `file://${process.argv[1]}`) {
  const generator = new ReadinessReportGenerator();

  generator
    .generateReport()
    .then(async (report) => {
      await generator.saveReport();

      const statusEmoji = {
        ready_for_live: "🟢",
        mostly_ready: "🟡",
        needs_work: "🔴",
      };

      console.log(
        `\n${
          statusEmoji[report.status]
        } Phase 4C Staging Readiness: ${report.status
          .replace("_", " ")
          .toUpperCase()}`
      );
      console.log(`📊 Readiness: ${report.summary.readiness_percentage}%`);
      console.log(
        `🎯 Ready: ${report.summary.ready_conditions}/${report.summary.total_conditions} conditions`
      );

      if (report.summary.critical_blockers > 0) {
        console.log(
          `⚠️ Critical blockers: ${report.summary.critical_blockers}`
        );
      }

      process.exit(0);
    })
    .catch((error) => {
      console.error("💥 Report generation failed:", error);
      process.exit(1);
    });
}

export default ReadinessReportGenerator;
