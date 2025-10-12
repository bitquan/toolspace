#!/usr/bin/env node

/**
 * Documentation Validator for Toolspace
 * Validates that all documentation is complete, accurate, and matches the codebase
 */

import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Configuration
const PROJECT_ROOT = path.resolve(__dirname, "..");
const DOCS_ROOT = path.join(PROJECT_ROOT, "docs");
const LIB_ROOT = path.join(PROJECT_ROOT, "lib");
const CONFIG_ROOT = path.join(PROJECT_ROOT, "config");

// Forbidden tokens that indicate incomplete documentation
const FORBIDDEN_TOKENS = [
  "TODO",
  "TBD",
  "<<placeholder>>",
  "lorem",
  "___",
  "PLACEHOLDER",
  "Coming soon",
  "Not implemented",
  "Will be added",
];

// ANSI colors for console output
const colors = {
  reset: "\x1b[0m",
  bright: "\x1b[1m",
  red: "\x1b[31m",
  green: "\x1b[32m",
  yellow: "\x1b[33m",
  blue: "\x1b[34m",
  magenta: "\x1b[35m",
  cyan: "\x1b[36m",
};

class ValidationError {
  constructor(file, type, message, line = null) {
    this.file = file;
    this.type = type;
    this.message = message;
    this.line = line;
  }

  toString() {
    const fileDisplay = this.file.replace(PROJECT_ROOT, "");
    const lineDisplay = this.line ? `:${this.line}` : "";
    return `${colors.red}✗${colors.reset} ${colors.cyan}${fileDisplay}${lineDisplay}${colors.reset} [${colors.yellow}${this.type}${colors.reset}] ${this.message}`;
  }
}

class DocumentationValidator {
  constructor() {
    this.errors = [];
    this.warnings = [];
    this.routes = new Set();
    this.tools = new Map();
    this.planIds = new Set();
  }

  /**
   * Main validation entry point
   */
  async validate() {
    console.log(
      `${colors.bright}${colors.blue}📋 Toolspace Documentation Validator${colors.reset}\n`
    );

    try {
      await this.loadCodebaseInfo();
      await this.validatePlatformDocs();
      await this.validateToolDocs();
      await this.validateStyleDocs();
      await this.generateSummary();

      this.printResults();

      return this.errors.length === 0;
    } catch (error) {
      console.error(
        `${colors.red}Fatal error during validation:${colors.reset}`,
        error.message
      );
      return false;
    }
  }

  /**
   * Load information from the codebase to validate against
   */
  async loadCodebaseInfo() {
    console.log("🔍 Loading codebase information...");

    // Load routes from routes.dart
    await this.loadRoutes();

    // Load tool information from lib/tools/
    await this.loadTools();

    // Load billing plans from config/pricing.json
    await this.loadPricingConfig();
  }

  /**
   * Load all routes from lib/core/routes.dart
   */
  async loadRoutes() {
    const routesFile = path.join(LIB_ROOT, "core", "routes.dart");

    if (!fs.existsSync(routesFile)) {
      this.errors.push(
        new ValidationError(routesFile, "MISSING_FILE", "Routes file not found")
      );
      return;
    }

    const content = fs.readFileSync(routesFile, "utf8");

    // Extract route constants
    const routeMatches = content.match(/static const String \w+ = '([^']+)';/g);
    if (routeMatches) {
      routeMatches.forEach((match) => {
        const route = match.match(/'([^']+)'/)[1];
        this.routes.add(route);
      });
    }

    console.log(`  Found ${this.routes.size} routes`);
  }

  /**
   * Load tool information from lib/tools/ directory
   */
  async loadTools() {
    const toolsDir = path.join(LIB_ROOT, "tools");

    if (!fs.existsSync(toolsDir)) {
      this.errors.push(
        new ValidationError(
          toolsDir,
          "MISSING_DIR",
          "Tools directory not found"
        )
      );
      return;
    }

    const toolDirs = fs.readdirSync(toolsDir).filter((dir) => {
      const dirPath = path.join(toolsDir, dir);
      return fs.statSync(dirPath).isDirectory();
    });

    for (const toolDir of toolDirs) {
      const toolPath = path.join(toolsDir, toolDir);
      const screenFile = path.join(toolPath, `${toolDir}_screen.dart`);

      if (fs.existsSync(screenFile)) {
        this.tools.set(toolDir, {
          id: toolDir,
          path: toolPath,
          screenFile: screenFile,
          route: `/tools/${toolDir.replace("_", "-")}`,
        });
      }
    }

    console.log(`  Found ${this.tools.size} tools`);
  }

  /**
   * Load pricing configuration from config/pricing.json
   */
  async loadPricingConfig() {
    const pricingFile = path.join(CONFIG_ROOT, "pricing.json");

    if (!fs.existsSync(pricingFile)) {
      this.errors.push(
        new ValidationError(
          pricingFile,
          "MISSING_FILE",
          "Pricing config not found"
        )
      );
      return;
    }

    try {
      const content = fs.readFileSync(pricingFile, "utf8");
      const config = JSON.parse(content);

      if (config.plans) {
        Object.keys(config.plans).forEach((planId) => {
          this.planIds.add(planId);
        });
      }

      console.log(`  Found ${this.planIds.size} billing plans`);
    } catch (error) {
      this.errors.push(
        new ValidationError(
          pricingFile,
          "INVALID_JSON",
          `Failed to parse pricing config: ${error.message}`
        )
      );
    }
  }

  /**
   * Validate platform documentation
   */
  async validatePlatformDocs() {
    console.log("\n📚 Validating platform documentation...");

    const platformDocs = [
      "billing.md",
      "cross-tool.md",
      "routes.md",
      "storage.md",
      "functions.md",
      "qa-e2e.md",
    ];

    for (const docFile of platformDocs) {
      const filePath = path.join(DOCS_ROOT, "platform", docFile);
      await this.validateDocumentFile(filePath, "PLATFORM");
    }
  }

  /**
   * Validate tool documentation for each tool
   */
  async validateToolDocs() {
    console.log("\n🛠️  Validating tool documentation...");

    for (const [toolId, toolInfo] of this.tools) {
      const toolDocsDir = path.join(DOCS_ROOT, "tools", toolId);

      // Check if tool docs directory exists
      if (!fs.existsSync(toolDocsDir)) {
        this.errors.push(
          new ValidationError(
            toolDocsDir,
            "MISSING_DIR",
            `Tool documentation directory missing for ${toolId}`
          )
        );
        continue;
      }

      // Required files for each tool
      const requiredFiles = [
        "README.md",
        "UX.md",
        "INTEGRATION.md",
        "TESTS.md",
        "LIMITS.md",
        "CHANGELOG.md",
      ];

      for (const fileName of requiredFiles) {
        const filePath = path.join(toolDocsDir, fileName);
        await this.validateDocumentFile(filePath, "TOOL", toolId);
      }

      // Validate tool-specific requirements
      await this.validateToolSpecificRequirements(
        toolId,
        toolInfo,
        toolDocsDir
      );
    }
  }

  /**
   * Validate style documentation
   */
  async validateStyleDocs() {
    console.log("\n🎨 Validating style documentation...");

    const styleDocs = ["ux-theme.md", "copy.md"];

    for (const docFile of styleDocs) {
      const filePath = path.join(DOCS_ROOT, "style", docFile);
      await this.validateDocumentFile(filePath, "STYLE");
    }
  }

  /**
   * Validate a single documentation file
   */
  async validateDocumentFile(filePath, category, toolId = null) {
    const relativePath = filePath.replace(PROJECT_ROOT, "");

    if (!fs.existsSync(filePath)) {
      this.errors.push(
        new ValidationError(
          filePath,
          "MISSING_FILE",
          `${category} documentation file missing`
        )
      );
      return;
    }

    const content = fs.readFileSync(filePath, "utf8");
    const lines = content.split("\n");

    // Check for forbidden tokens
    for (let i = 0; i < lines.length; i++) {
      const line = lines[i];
      for (const token of FORBIDDEN_TOKENS) {
        if (line.includes(token)) {
          this.errors.push(
            new ValidationError(
              filePath,
              "FORBIDDEN_TOKEN",
              `Contains forbidden token "${token}"`,
              i + 1
            )
          );
        }
      }
    }

    // Check for minimum content length
    if (content.trim().length < 100) {
      this.errors.push(
        new ValidationError(
          filePath,
          "INSUFFICIENT_CONTENT",
          "Documentation file is too short (less than 100 characters)"
        )
      );
    }

    // Tool-specific validations
    if (
      category === "TOOL" &&
      toolId &&
      path.basename(filePath) === "README.md"
    ) {
      await this.validateToolReadme(filePath, toolId, content);
    }
  }

  /**
   * Validate tool README.md files for required sections
   */
  async validateToolReadme(filePath, toolId, content) {
    const requiredSections = [
      "# ", // Tool name header
      "**Route:**",
      "**Category:**",
      "**Billing:**",
      "**Heavy Op:**",
      "**Owner Code:**",
      "## 1. Overview",
      "## 2. Features",
      "## 3. UX Flow",
      "## 4. Data & Types",
      "## 5. Integration",
      "## 6. Billing & Quotas",
      "## 7. Validation & Error Handling",
      "## 8. Accessibility",
      "## 9. Test Plan (Manual)",
      "## 10. Automation Hooks",
      "## 11. Release Notes",
    ];

    for (const section of requiredSections) {
      if (!content.includes(section)) {
        this.errors.push(
          new ValidationError(
            filePath,
            "MISSING_SECTION",
            `Tool README missing required section: "${section}"`
          )
        );
      }
    }

    // Validate route matches actual routes
    const routeMatch = content.match(/\*\*Route:\*\* `([^`]+)`/);
    if (routeMatch) {
      const documentedRoute = routeMatch[1];
      if (!this.routes.has(documentedRoute)) {
        this.errors.push(
          new ValidationError(
            filePath,
            "INVALID_ROUTE",
            `Documented route "${documentedRoute}" not found in routes.dart`
          )
        );
      }
    }

    // Validate billing plan references
    const billingMatch = content.match(/\*\*Billing:\*\* \(([^)]+)\)/);
    if (billingMatch) {
      const billingPlans = billingMatch[1]
        .split(" | ")
        .map((p) => p.trim().toLowerCase());
      for (const plan of billingPlans) {
        if (plan !== "free" && plan !== "pro" && plan !== "pro+") {
          this.warnings.push(
            new ValidationError(
              filePath,
              "UNKNOWN_PLAN",
              `Unknown billing plan referenced: "${plan}"`
            )
          );
        }
      }
    }
  }

  /**
   * Validate tool-specific requirements
   */
  async validateToolSpecificRequirements(toolId, toolInfo, toolDocsDir) {
    // Check if screen file exists and matches documentation
    if (!fs.existsSync(toolInfo.screenFile)) {
      this.errors.push(
        new ValidationError(
          toolInfo.screenFile,
          "MISSING_FILE",
          `Screen file missing for tool ${toolId}`
        )
      );
    }

    // Check if route is documented and matches actual route
    const expectedRoute = `/tools/${toolId.replace("_", "-")}`;
    if (!this.routes.has(expectedRoute)) {
      this.warnings.push(
        new ValidationError(
          toolDocsDir,
          "ROUTE_MISMATCH",
          `Expected route ${expectedRoute} not found in routes.dart`
        )
      );
    }
  }

  /**
   * Generate documentation summary
   */
  async generateSummary() {
    console.log("\n📝 Generating documentation summary...");

    const summaryPath = path.join(DOCS_ROOT, "DOCUMENTATION_SUMMARY.md");

    const summary = this.createDocumentationSummary();

    fs.writeFileSync(summaryPath, summary, "utf8");
    console.log(
      `  Generated summary at: ${summaryPath.replace(PROJECT_ROOT, "")}`
    );
  }

  /**
   * Create the documentation summary content
   */
  createDocumentationSummary() {
    const timestamp = new Date().toISOString();

    let summary = `# Toolspace Documentation Summary

**Generated:** ${timestamp}  
**Validator Version:** 1.0.0  
**Status:** ${
      this.errors.length === 0 ? "✅ VALIDATED" : "❌ VALIDATION FAILED"
    }

## Overview

This documentation serves as the single source of truth for all Toolspace tools and platform components. Every feature, API, and behavior documented here must match the actual implementation.

## Documentation Structure

\`\`\`
docs/
├── tools/                    # Individual tool documentation
│   ├── <tool-id>/
│   │   ├── README.md        # Complete tool specification
│   │   ├── UX.md           # User experience flows
│   │   ├── INTEGRATION.md  # Cross-tool integrations
│   │   ├── TESTS.md        # Test specifications
│   │   ├── LIMITS.md       # Quotas and limitations
│   │   └── CHANGELOG.md    # Version history
├── platform/               # Platform-wide documentation
│   ├── billing.md         # Billing and subscriptions
│   ├── cross-tool.md      # Tool-to-tool communication
│   ├── routes.md          # Application routing
│   ├── storage.md         # Data storage patterns
│   ├── functions.md       # Cloud Functions
│   └── qa-e2e.md          # End-to-end testing
├── style/                 # Design system documentation
│   ├── ux-theme.md       # UI theme and components
│   └── copy.md           # Writing style guide
└── DOCUMENTATION_SUMMARY.md  # This file
\`\`\`

## Tools Documentation

| Tool | Route | Category | Billing | Status |
|------|-------|----------|---------|--------|
`;

    // Add tool documentation status
    const toolIds = Array.from(this.tools.keys()).sort();
    for (const toolId of toolIds) {
      const toolInfo = this.tools.get(toolId);
      const route = toolInfo.route;
      const docsDir = path.join(DOCS_ROOT, "tools", toolId);
      const hasReadme = fs.existsSync(path.join(docsDir, "README.md"));
      const status = hasReadme ? "✅" : "❌";

      summary += `| ${toolId
        .replace("_", " ")
        .replace(/\b\w/g, (l) =>
          l.toUpperCase()
        )} | \`${route}\` | - | - | ${status} |\n`;
    }

    summary += `

## Platform Documentation Status

| Component | File | Status |
|-----------|------|--------|
| Billing & Subscriptions | platform/billing.md | ${
      fs.existsSync(path.join(DOCS_ROOT, "platform", "billing.md"))
        ? "✅"
        : "❌"
    } |
| Cross-Tool Communication | platform/cross-tool.md | ${
      fs.existsSync(path.join(DOCS_ROOT, "platform", "cross-tool.md"))
        ? "✅"
        : "❌"
    } |
| Application Routing | platform/routes.md | ${
      fs.existsSync(path.join(DOCS_ROOT, "platform", "routes.md")) ? "✅" : "❌"
    } |
| Data Storage | platform/storage.md | ${
      fs.existsSync(path.join(DOCS_ROOT, "platform", "storage.md"))
        ? "✅"
        : "❌"
    } |
| Cloud Functions | platform/functions.md | ${
      fs.existsSync(path.join(DOCS_ROOT, "platform", "functions.md"))
        ? "✅"
        : "❌"
    } |
| End-to-End Testing | platform/qa-e2e.md | ${
      fs.existsSync(path.join(DOCS_ROOT, "platform", "qa-e2e.md")) ? "✅" : "❌"
    } |

## Style Documentation Status

| Component | File | Status |
|-----------|------|--------|
| UX Theme & Components | style/ux-theme.md | ${
      fs.existsSync(path.join(DOCS_ROOT, "style", "ux-theme.md")) ? "✅" : "❌"
    } |
| Copy & Style Guide | style/copy.md | ${
      fs.existsSync(path.join(DOCS_ROOT, "style", "copy.md")) ? "✅" : "❌"
    } |

## Validation Summary

- **Total Tools:** ${this.tools.size}
- **Documentation Errors:** ${this.errors.length}
- **Documentation Warnings:** ${this.warnings.length}
- **Routes Validated:** ${this.routes.size}
- **Billing Plans:** ${this.planIds.size}

## Quality Standards

All documentation must:
- ✅ Be complete with no placeholders or TODO items
- ✅ Match the actual implementation exactly
- ✅ Include working code examples and file paths
- ✅ Provide comprehensive test coverage specifications
- ✅ Document all billing and quota restrictions accurately

*This summary is automatically generated by \`scripts/docs-validate.mjs\`. Do not edit manually.*
`;

    return summary;
  }

  /**
   * Print validation results to console
   */
  printResults() {
    console.log("\n" + "=".repeat(80));
    console.log(`${colors.bright}📊 VALIDATION RESULTS${colors.reset}`);
    console.log("=".repeat(80));

    if (this.errors.length === 0 && this.warnings.length === 0) {
      console.log(
        `${colors.green}${colors.bright}✅ All documentation validates successfully!${colors.reset}`
      );
      console.log(`\n📋 Summary:`);
      console.log(`   Tools documented: ${this.tools.size}`);
      console.log(`   Routes validated: ${this.routes.size}`);
      console.log(`   Billing plans: ${this.planIds.size}`);
    } else {
      if (this.errors.length > 0) {
        console.log(
          `${colors.red}${colors.bright}❌ ${this.errors.length} ERRORS FOUND:${colors.reset}\n`
        );
        this.errors.forEach((error) => console.log(error.toString()));
      }

      if (this.warnings.length > 0) {
        console.log(
          `\n${colors.yellow}${colors.bright}⚠️  ${this.warnings.length} WARNINGS:${colors.reset}\n`
        );
        this.warnings.forEach((warning) => console.log(warning.toString()));
      }

      console.log(
        `\n${colors.red}${colors.bright}❌ Documentation validation failed!${colors.reset}`
      );
      console.log("Please fix all errors before proceeding.");
    }

    console.log("\n" + "=".repeat(80));
  }
}

// CLI handling
const args = process.argv.slice(2);
const isSummaryMode = args.includes("--summary");

async function main() {
  const validator = new DocumentationValidator();

  if (isSummaryMode) {
    await validator.loadCodebaseInfo();
    await validator.generateSummary();
    console.log(
      `${colors.green}✅ Documentation summary generated${colors.reset}`
    );
    return;
  }

  const success = await validator.validate();
  process.exit(success ? 0 : 1);
}

// Run if called directly
if (import.meta.url === `file://${process.argv[1]}`) {
  main().catch((error) => {
    console.error(`${colors.red}Fatal error:${colors.reset}`, error);
    process.exit(1);
  });
}

export { DocumentationValidator };
