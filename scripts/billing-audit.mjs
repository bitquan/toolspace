#!/usr/bin/env node
/**
 * Billing Audit Script for Phase 4A - Docs ⇄ Code Sync
 * Compares documented billing gates with actual Firebase Functions implementation
 */

import { promises as fs } from "fs";
import { dirname, join } from "path";
import { fileURLToPath } from "url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const projectRoot = join(__dirname, "..");

async function extractDocumentedBilling() {
  const documented = {
    tiers: {},
    gates: {},
    pricing: {},
  };

  try {
    // Check pricing.json config
    const pricingPath = join(projectRoot, "config/pricing.json");
    try {
      const pricingContent = await fs.readFile(pricingPath, "utf8");
      documented.pricing = JSON.parse(pricingContent);
    } catch (err) {
      console.warn(`Could not read config/pricing.json: ${err.message}`);
    }

    // Scan tool documentation for billing gates
    const toolsDir = join(projectRoot, "docs/tools");
    const entries = await fs.readdir(toolsDir);

    for (const entry of entries) {
      const entryPath = join(toolsDir, entry);
      const stat = await fs.stat(entryPath);

      if (stat.isDirectory()) {
        // Handle tool subdirectories
        const tools = await fs.readdir(entryPath);

        for (const tool of tools) {
          const toolPath = join(entryPath, tool);
          const toolStat = await fs.stat(toolPath);

          if (toolStat.isDirectory()) {
            // Check README.md for billing info
            const readmePath = join(toolPath, "README.md");
            try {
              const content = await fs.readFile(readmePath, "utf8");

              // Extract billing tier
              const tierMatch = content.match(/Billing Tier:\s*`([^`]+)`/);
              if (tierMatch) {
                documented.tiers[tool] = tierMatch[1];
              }

              // Extract usage limits
              const limitMatches = content.match(/- (\w+):\s*([^\\n]+)/g) || [];
              const limits = {};
              limitMatches.forEach((match) => {
                const parts = match.match(/- (\w+):\s*([^\\n]+)/);
                if (parts && parts[1].toLowerCase().includes("limit")) {
                  limits[parts[1]] = parts[2];
                }
              });

              if (Object.keys(limits).length > 0) {
                documented.gates[tool] = limits;
              }
            } catch (err) {
              console.warn(`Could not read ${tool} README: ${err.message}`);
            }

            // Check LIMITS.md for detailed billing info
            const limitsPath = join(toolPath, "LIMITS.md");
            try {
              const content = await fs.readFile(limitsPath, "utf8");

              // Extract billing constraints
              const billingSection = content.match(
                /## Billing Constraints(.*?)##/s
              );
              if (billingSection) {
                const constraints = billingSection[1];

                // Parse tier-specific limits
                const tierLimits =
                  constraints.match(/### (\w+) Tier[^#]+(.*?)(?=###|$)/gs) ||
                  [];
                tierLimits.forEach((section) => {
                  const tierMatch = section.match(/### (\w+) Tier/);
                  if (tierMatch) {
                    const tier = tierMatch[1];
                    if (!documented.gates[tool]) documented.gates[tool] = {};
                    documented.gates[tool][tier] = section;
                  }
                });
              }
            } catch (err) {
              // LIMITS.md is optional
            }
          }
        }
      } else if (entry.endsWith(".md")) {
        // Handle standalone tool .md files
        const toolName = entry.replace(".md", "").replace(/-/g, "_");

        try {
          const content = await fs.readFile(entryPath, "utf8");

          // Extract billing tier
          const tierMatch = content.match(/Billing Tier:\s*`([^`]+)`/);
          if (tierMatch) {
            documented.tiers[toolName] = tierMatch[1];
          }

          // Look for Pro/Free mentions as billing indicators
          const proMentions = content.match(/\b(Pro|Premium|Paid)\b/gi) || [];
          const freeMentions = content.match(/\b(Free|Basic)\b/gi) || [];

          if (proMentions.length > 0) {
            documented.tiers[toolName] = "Pro";
          } else if (freeMentions.length > 0) {
            documented.tiers[toolName] = "Free";
          }

          // Extract usage limits
          const limitMatches = content.match(/- (\w+):\s*([^\\n]+)/g) || [];
          const limits = {};
          limitMatches.forEach((match) => {
            const parts = match.match(/- (\w+):\s*([^\\n]+)/);
            if (parts && parts[1].toLowerCase().includes("limit")) {
              limits[parts[1]] = parts[2];
            }
          });

          if (Object.keys(limits).length > 0) {
            documented.gates[toolName] = limits;
          }
        } catch (err) {
          console.warn(
            `Could not read ${toolName} documentation: ${err.message}`
          );
        }
      }
    }

    // Check platform billing docs
    const platformBillingPath = join(projectRoot, "docs/platform/billing.md");
    try {
      const content = await fs.readFile(platformBillingPath, "utf8");

      // Extract tier definitions
      const tierSection = content.match(/## Tier Structure(.*?)##/s);
      if (tierSection) {
        const tiers = tierSection[1].match(/### (\w+)(.*?)(?=###|$)/gs) || [];
        tiers.forEach((tier) => {
          const tierMatch = tier.match(/### (\w+)/);
          if (tierMatch) {
            const tierName = tierMatch[1];
            documented.tiers[`platform_${tierName}`] = tier;
          }
        });
      }
    } catch (err) {
      console.warn(`Could not read platform billing docs: ${err.message}`);
    }
  } catch (err) {
    console.error(`Error extracting documented billing: ${err.message}`);
  }

  return documented;
}

async function extractCodeBilling() {
  const codeBilling = {
    functions: {},
    rules: {},
    configs: {},
  };

  try {
    // Scan Firebase Functions for billing logic
    const functionsDir = join(projectRoot, "functions/src");
    await scanDirectoryForBilling(
      functionsDir,
      codeBilling.functions,
      "functions/src"
    );

    // Check Firestore rules for billing constraints
    const rulesPath = join(projectRoot, "firestore.rules");
    try {
      const content = await fs.readFile(rulesPath, "utf8");

      // Extract billing-related rules
      const billingRules =
        content.match(/\/\/ Billing.*|allow.*tier|allow.*subscription/gi) || [];
      codeBilling.rules.firestore = billingRules;
    } catch (err) {
      console.warn(`Could not read firestore.rules: ${err.message}`);
    }

    // Check storage rules
    const storageRulesPath = join(projectRoot, "storage.rules");
    try {
      const content = await fs.readFile(storageRulesPath, "utf8");

      const billingRules =
        content.match(/\/\/ Billing.*|allow.*tier|allow.*quota/gi) || [];
      codeBilling.rules.storage = billingRules;
    } catch (err) {
      console.warn(`Could not read storage.rules: ${err.message}`);
    }

    // Check Flutter billing code
    const billingDir = join(projectRoot, "lib/billing");
    if (
      await fs
        .access(billingDir)
        .then(() => true)
        .catch(() => false)
    ) {
      await scanDirectoryForBilling(
        billingDir,
        codeBilling.configs,
        "lib/billing"
      );
    }
  } catch (err) {
    console.error(`Error extracting code billing: ${err.message}`);
  }

  return codeBilling;
}

async function scanDirectoryForBilling(dir, billingMap, relativePath) {
  try {
    const entries = await fs.readdir(dir);

    for (const entry of entries) {
      const fullPath = join(dir, entry);
      const stat = await fs.stat(fullPath);

      if (stat.isDirectory()) {
        await scanDirectoryForBilling(
          fullPath,
          billingMap,
          `${relativePath}/${entry}`
        );
      } else if (
        entry.endsWith(".ts") ||
        entry.endsWith(".js") ||
        entry.endsWith(".dart")
      ) {
        try {
          const content = await fs.readFile(fullPath, "utf8");

          // Look for billing-related patterns
          const billingPatterns = [
            /tier\s*[=:]\s*['"](\w+)['"]/gi,
            /subscription\s*[=:]\s*['"](\w+)['"]/gi,
            /quota\s*[=:]\s*(\d+)/gi,
            /billing.*check/gi,
            /usage.*limit/gi,
            /plan.*validation/gi,
          ];

          const matches = [];
          billingPatterns.forEach((pattern) => {
            const found = content.matchAll(pattern);
            for (const match of found) {
              matches.push(match[0]);
            }
          });

          if (matches.length > 0) {
            billingMap[`${relativePath}/${entry}`] = matches;
          }
        } catch (err) {
          console.warn(`Could not read ${fullPath}: ${err.message}`);
        }
      }
    }
  } catch (err) {
    console.warn(`Could not scan directory ${dir}: ${err.message}`);
  }
}

async function compareBilling(documented, codeBilling) {
  const report = {
    aligned: [],
    missingImplementation: [],
    undocumentedImplementation: [],
    misaligned: [],
  };

  // Check documented tiers against code
  Object.entries(documented.tiers).forEach(([tool, tier]) => {
    const foundInCode = Object.entries(codeBilling.functions).find(
      ([file, matches]) =>
        matches.some(
          (match) =>
            match.toLowerCase().includes(tier.toLowerCase()) ||
            match.toLowerCase().includes(tool.toLowerCase())
        )
    );

    if (foundInCode) {
      report.aligned.push({
        tool,
        tier,
        codeFile: foundInCode[0],
        matches: foundInCode[1],
      });
    } else {
      report.missingImplementation.push({
        tool,
        tier,
        docSource: "tool documentation",
      });
    }
  });

  // Check documented gates against rules
  Object.entries(documented.gates).forEach(([tool, gates]) => {
    const foundInRules = Object.entries(codeBilling.rules).find(
      ([ruleType, rules]) =>
        rules.some((rule) => rule.toLowerCase().includes(tool.toLowerCase()))
    );

    if (foundInRules) {
      report.aligned.push({
        tool,
        gates: Object.keys(gates),
        ruleType: foundInRules[0],
        rules: foundInRules[1],
      });
    } else {
      report.missingImplementation.push({
        tool,
        gates: Object.keys(gates),
        docSource: "limits documentation",
      });
    }
  });

  // Check code implementations not in docs
  Object.entries(codeBilling.functions).forEach(([file, matches]) => {
    const foundInDocs = Object.keys(documented.tiers).find((tool) =>
      matches.some((match) => match.toLowerCase().includes(tool.toLowerCase()))
    );

    if (!foundInDocs) {
      report.undocumentedImplementation.push({
        file,
        matches,
        type: "function",
      });
    }
  });

  return report;
}

async function generateReport(report) {
  const reportLines = [
    "# Billing Audit Report - Phase 4A",
    "",
    `Generated: ${new Date().toISOString()}`,
    "",
    "## Summary",
    `- ✅ Aligned: ${report.aligned.length}`,
    `- ❌ Missing implementation: ${report.missingImplementation.length}`,
    `- 📝 Undocumented implementation: ${report.undocumentedImplementation.length}`,
    `- ⚠️ Misaligned: ${report.misaligned.length}`,
    "",
  ];

  if (report.aligned.length > 0) {
    reportLines.push("## ✅ Aligned Billing Features");
    reportLines.push("");
    report.aligned.forEach((item) => {
      if (item.tier) {
        reportLines.push(
          `- **${item.tool}** (${item.tier}): Found in ${item.codeFile}`
        );
      } else if (item.gates) {
        reportLines.push(
          `- **${item.tool}** gates: Found in ${item.ruleType} rules`
        );
      }
    });
    reportLines.push("");
  }

  if (report.missingImplementation.length > 0) {
    reportLines.push("## ❌ Missing Implementation");
    reportLines.push("");
    report.missingImplementation.forEach((item) => {
      if (item.tier) {
        reportLines.push(
          `- **${item.tool}**: Tier "${item.tier}" documented but not implemented`
        );
      } else if (item.gates) {
        reportLines.push(
          `- **${item.tool}**: Gates ${item.gates.join(
            ", "
          )} documented but not implemented`
        );
      }
    });
    reportLines.push("");
  }

  if (report.undocumentedImplementation.length > 0) {
    reportLines.push("## 📝 Undocumented Implementation");
    reportLines.push("");
    report.undocumentedImplementation.forEach((item) => {
      reportLines.push(`- **${item.file}**: ${item.matches.join(", ")}`);
    });
    reportLines.push("");
  }

  reportLines.push("## Recommendations");
  reportLines.push("");

  if (report.missingImplementation.length > 0) {
    reportLines.push("### Missing Implementations");
    reportLines.push("");
    report.missingImplementation.forEach((item) => {
      if (item.tier) {
        reportLines.push(
          `1. Implement ${item.tier} tier validation for ${item.tool}`
        );
      } else if (item.gates) {
        reportLines.push(
          `1. Implement billing gates for ${item.tool}: ${item.gates.join(
            ", "
          )}`
        );
      }
    });
    reportLines.push("");
  }

  if (report.undocumentedImplementation.length > 0) {
    reportLines.push("### Undocumented Features");
    reportLines.push("");
    report.undocumentedImplementation.forEach((item) => {
      reportLines.push(`1. Document billing logic in ${item.file}`);
    });
    reportLines.push("");
  }

  return reportLines.join("\n");
}

async function main() {
  console.log("💳 Starting Billing Audit for Phase 4A...\n");

  try {
    console.log("📚 Extracting documented billing...");
    const documented = await extractDocumentedBilling();
    console.log(
      `Found ${Object.keys(documented.tiers).length} tiers and ${
        Object.keys(documented.gates).length
      } gate sets`
    );

    console.log("💻 Extracting code billing...");
    const codeBilling = await extractCodeBilling();
    console.log(
      `Found billing logic in ${
        Object.keys(codeBilling.functions).length
      } files`
    );

    console.log("🔄 Comparing billing implementations...");
    const report = await compareBilling(documented, codeBilling);

    console.log("📋 Generating report...");
    const reportContent = await generateReport(report);

    const reportPath = join(
      projectRoot,
      "dev-log/phase-4/billing-audit-report.md"
    );
    await fs.writeFile(reportPath, reportContent);

    console.log(`\n✅ Billing audit complete! Report saved to: ${reportPath}`);

    // Summary for console
    console.log("\n📊 Summary:");
    console.log(`   ✅ Aligned: ${report.aligned.length}`);
    console.log(
      `   ❌ Missing implementation: ${report.missingImplementation.length}`
    );
    console.log(
      `   📝 Undocumented: ${report.undocumentedImplementation.length}`
    );
    console.log(`   ⚠️ Misaligned: ${report.misaligned.length}`);

    // Exit with appropriate code
    if (
      report.missingImplementation.length > 0 ||
      report.undocumentedImplementation.length > 0 ||
      report.misaligned.length > 0
    ) {
      console.log(
        "\n⚠️ Billing misalignments detected. Check the report for details."
      );
      process.exit(1);
    } else {
      console.log("\n🎉 All billing features are properly aligned!");
      process.exit(0);
    }
  } catch (error) {
    console.error(`❌ Billing audit failed: ${error.message}`);
    process.exit(1);
  }
}

// Run if called directly
if (import.meta.url === `file://${process.argv[1]}`) {
  main();
}

export {
  compareBilling,
  extractCodeBilling,
  extractDocumentedBilling,
  generateReport,
};
