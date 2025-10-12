#!/usr/bin/env node
/**
 * Repository Sanitize Script for Phase 4A - Docs ⇄ Code Sync
 * Cleans up orphaned files, validates structure, and ensures consistency
 */

import { promises as fs } from "fs";
import { dirname, extname, join } from "path";
import { fileURLToPath } from "url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const projectRoot = join(__dirname, "..");

const PROTECTED_PATHS = [
  ".git",
  "node_modules",
  "build",
  ".dart_tool",
  "coverage",
  ".vscode",
  ".idea",
];

const VALID_EXTENSIONS = [
  ".dart",
  ".js",
  ".ts",
  ".mjs",
  ".json",
  ".yaml",
  ".yml",
  ".md",
  ".txt",
  ".html",
  ".css",
  ".scss",
  ".png",
  ".jpg",
  ".jpeg",
  ".gif",
  ".svg",
  ".ico",
  ".pdf",
  ".gitignore",
  ".gitkeep",
  ".env.example",
  ".rules",
];

async function scanRepository() {
  const scan = {
    allFiles: [],
    orphanedFiles: [],
    misplacedFiles: [],
    invalidExtensions: [],
    emptyDirectories: [],
    stats: {
      totalFiles: 0,
      totalSize: 0,
      filesByType: {},
    },
  };

  try {
    await scanDirectory(projectRoot, "", scan);

    // Calculate statistics
    scan.stats.totalFiles = scan.allFiles.length;
    scan.stats.totalSize = scan.allFiles.reduce(
      (sum, file) => sum + file.size,
      0
    );

    scan.allFiles.forEach((file) => {
      const ext = extname(file.name) || "no-extension";
      scan.stats.filesByType[ext] = (scan.stats.filesByType[ext] || 0) + 1;
    });
  } catch (err) {
    console.error(`Error scanning repository: ${err.message}`);
  }

  return scan;
}

async function scanDirectory(dir, relativePath, scan) {
  try {
    const entries = await fs.readdir(dir);

    let hasFiles = false;

    for (const entry of entries) {
      const fullPath = join(dir, entry);
      const entryRelativePath = relativePath
        ? `${relativePath}/${entry}`
        : entry;

      // Skip protected directories
      if (PROTECTED_PATHS.includes(entry)) {
        continue;
      }

      const stat = await fs.stat(fullPath);

      if (stat.isDirectory()) {
        await scanDirectory(fullPath, entryRelativePath, scan);
      } else {
        hasFiles = true;

        const file = {
          path: entryRelativePath,
          name: entry,
          size: stat.size,
          modified: stat.mtime,
          fullPath,
        };

        scan.allFiles.push(file);

        // Check for invalid extensions
        const ext = extname(entry);
        if (ext && !VALID_EXTENSIONS.includes(ext)) {
          scan.invalidExtensions.push(file);
        }

        // Check for misplaced files
        if (await isMisplacedFile(file)) {
          scan.misplacedFiles.push(file);
        }

        // Check for orphaned files
        if (await isOrphanedFile(file)) {
          scan.orphanedFiles.push(file);
        }
      }
    }

    // Check for empty directories
    if (!hasFiles && entries.length === 0) {
      scan.emptyDirectories.push(relativePath);
    }
  } catch (err) {
    console.warn(`Could not scan directory ${dir}: ${err.message}`);
  }
}

async function isMisplacedFile(file) {
  const rules = [
    // Test files should be in test/ directory
    {
      pattern: /_test\.dart$/,
      expectedPath: /^test\//,
      reason: "Test files should be in test/ directory",
    },

    // Tool implementations should be in lib/tools/
    {
      pattern: /_(screen|service|model)\.dart$/,
      expectedPath: /^lib\/tools\//,
      reason: "Tool implementations should be in lib/tools/",
    },

    // Documentation should be in docs/
    {
      pattern: /\.md$/,
      expectedPath: /^(docs\/|README\.md$|CHANGELOG\.md$)/,
      reason: "Documentation should be in docs/ directory",
    },

    // Scripts should be in scripts/
    {
      pattern: /\.(mjs|js|sh|ps1)$/,
      expectedPath: /^scripts\//,
      reason: "Scripts should be in scripts/ directory",
    },
  ];

  for (const rule of rules) {
    if (rule.pattern.test(file.name) && !rule.expectedPath.test(file.path)) {
      file.misplacementReason = rule.reason;
      return true;
    }
  }

  return false;
}

async function isOrphanedFile(file) {
  // Check if file is referenced anywhere
  const orphanRules = [
    // Unreferenced asset files
    {
      pattern: /\.(png|jpg|jpeg|gif|svg)$/,
      checkReferences: true,
    },

    // Unreferenced Dart files not in main structure
    {
      pattern: /\.dart$/,
      checkStructure: true,
    },

    // Old/backup files
    {
      pattern: /\.(bak|old|tmp|backup)$/,
      alwaysOrphaned: true,
    },

    // Log files
    {
      pattern: /\.log$/,
      alwaysOrphaned: true,
    },
  ];

  for (const rule of orphanRules) {
    if (rule.pattern.test(file.name)) {
      if (rule.alwaysOrphaned) {
        return true;
      }

      if (rule.checkReferences) {
        return !(await hasReferences(file));
      }

      if (rule.checkStructure) {
        return !(await isPartOfValidStructure(file));
      }
    }
  }

  return false;
}

async function hasReferences(file) {
  try {
    // Search for references to this file
    const searchPatterns = [
      file.name,
      file.path,
      file.name.replace(/\.[^.]+$/, ""), // filename without extension
    ];

    for (const pattern of searchPatterns) {
      // This is a simplified check - in a real implementation,
      // you'd want to do a more thorough grep search
      const found = await searchInFiles(pattern);
      if (found) return true;
    }

    return false;
  } catch (err) {
    return false; // Assume referenced if we can't check
  }
}

async function searchInFiles(pattern) {
  // Simplified search - in production, use proper grep or ripgrep
  try {
    const searchDirs = ["lib", "docs", "functions/src"];

    for (const searchDir of searchDirs) {
      const dirPath = join(projectRoot, searchDir);
      if (
        await fs
          .access(dirPath)
          .then(() => true)
          .catch(() => false)
      ) {
        const found = await searchInDirectory(dirPath, pattern);
        if (found) return true;
      }
    }

    return false;
  } catch (err) {
    return false;
  }
}

async function searchInDirectory(dir, pattern) {
  try {
    const entries = await fs.readdir(dir);

    for (const entry of entries) {
      const fullPath = join(dir, entry);
      const stat = await fs.stat(fullPath);

      if (stat.isDirectory()) {
        const found = await searchInDirectory(fullPath, pattern);
        if (found) return true;
      } else if (
        entry.endsWith(".dart") ||
        entry.endsWith(".md") ||
        entry.endsWith(".ts")
      ) {
        const content = await fs.readFile(fullPath, "utf8");
        if (content.includes(pattern)) {
          return true;
        }
      }
    }

    return false;
  } catch (err) {
    return false;
  }
}

async function isPartOfValidStructure(file) {
  const validStructures = [
    // Main app structure
    /^lib\/(main\.dart|app_shell\.dart|firebase_options\.dart)$/,

    // Core structure
    /^lib\/core\//,

    // Screens structure
    /^lib\/screens\//,

    // Tools structure
    /^lib\/tools\/[^\/]+\/[^\/]+\.dart$/,

    // Shared/widgets structure
    /^lib\/(shared|widgets|theme)\//,

    // Test structure
    /^test\/.*_test\.dart$/,

    // Functions structure
    /^functions\/src\/.*\.(ts|js)$/,

    // Documentation structure
    /^docs\/.*\.md$/,
  ];

  return validStructures.some((pattern) => pattern.test(file.path));
}

async function validateStructure(scan) {
  const validation = {
    missingRequired: [],
    incorrectStructure: [],
    suggestions: [],
  };

  // Check for required files
  const requiredFiles = [
    "lib/main.dart",
    "pubspec.yaml",
    "README.md",
    "core/routes.dart",
  ];

  for (const required of requiredFiles) {
    const found = scan.allFiles.find((file) => file.path === required);
    if (!found) {
      validation.missingRequired.push(required);
    }
  }

  // Check structure conventions
  const structureRules = [
    {
      name: "Tools should be categorized",
      check: () => {
        const toolFiles = scan.allFiles.filter(
          (file) =>
            file.path.startsWith("lib/tools/") && file.name.endsWith(".dart")
        );

        const uncategorized = toolFiles.filter((file) => {
          const pathParts = file.path.split("/");
          return pathParts.length < 4; // lib/tools/category/tool.dart
        });

        return uncategorized.length === 0;
      },
      suggestion:
        "Move tool files into category subdirectories under lib/tools/",
    },

    {
      name: "Tests should mirror lib structure",
      check: () => {
        const libFiles = scan.allFiles.filter(
          (file) => file.path.startsWith("lib/") && file.name.endsWith(".dart")
        );

        const testFiles = scan.allFiles.filter(
          (file) =>
            file.path.startsWith("test/") && file.name.endsWith("_test.dart")
        );

        const missingTests = libFiles.filter((libFile) => {
          const expectedTestPath = libFile.path
            .replace("lib/", "test/")
            .replace(".dart", "_test.dart");

          return !testFiles.find(
            (testFile) => testFile.path === expectedTestPath
          );
        });

        return missingTests.length < libFiles.length * 0.5; // Allow 50% test coverage
      },
      suggestion: "Add test files for main library components",
    },
  ];

  structureRules.forEach((rule) => {
    if (!rule.check()) {
      validation.incorrectStructure.push(rule.name);
      validation.suggestions.push(rule.suggestion);
    }
  });

  return validation;
}

async function generateCleanupPlan(scan, validation) {
  const plan = {
    deleteFiles: [],
    moveFiles: [],
    createDirectories: [],
    createFiles: [],
  };

  // Plan deletion of orphaned files
  scan.orphanedFiles.forEach((file) => {
    plan.deleteFiles.push({
      action: "delete",
      path: file.path,
      reason: "Orphaned file",
      size: file.size,
    });
  });

  // Plan moving misplaced files
  scan.misplacedFiles.forEach((file) => {
    const suggestedPath = suggestCorrectPath(file);
    if (suggestedPath) {
      plan.moveFiles.push({
        action: "move",
        from: file.path,
        to: suggestedPath,
        reason: file.misplacementReason,
      });
    }
  });

  // Plan creation of missing required files
  validation.missingRequired.forEach((path) => {
    plan.createFiles.push({
      action: "create",
      path,
      template: getTemplateForFile(path),
      reason: "Required file missing",
    });
  });

  return plan;
}

function suggestCorrectPath(file) {
  // Suggest correct paths based on file patterns
  if (file.name.endsWith("_test.dart")) {
    return `test/${file.name}`;
  }

  if (
    file.name.endsWith("_screen.dart") ||
    file.name.endsWith("_service.dart")
  ) {
    // Try to determine tool category from content or name
    const toolName = file.name.replace(/_(screen|service)\.dart$/, "");
    return `lib/tools/utility/${toolName}/${file.name}`;
  }

  if (file.name.endsWith(".md") && !file.path.startsWith("docs/")) {
    return `docs/${file.name}`;
  }

  if (file.name.endsWith(".mjs") || file.name.endsWith(".js")) {
    return `scripts/${file.name}`;
  }

  return null;
}

function getTemplateForFile(path) {
  const templates = {
    "lib/main.dart": "flutter_main",
    "pubspec.yaml": "flutter_pubspec",
    "README.md": "project_readme",
    "core/routes.dart": "routes_definition",
  };

  return templates[path] || "generic";
}

async function generateReport(scan, validation, plan) {
  const reportLines = [
    "# Repository Sanitize Report - Phase 4A",
    "",
    `Generated: ${new Date().toISOString()}`,
    "",
    "## Summary",
    `- 📁 Total files scanned: ${scan.stats.totalFiles}`,
    `- 💾 Total size: ${formatBytes(scan.stats.totalSize)}`,
    `- 🗑️ Orphaned files: ${scan.orphanedFiles.length}`,
    `- 📍 Misplaced files: ${scan.misplacedFiles.length}`,
    `- ❌ Invalid extensions: ${scan.invalidExtensions.length}`,
    `- 📂 Empty directories: ${scan.emptyDirectories.length}`,
    "",
    "## File Type Distribution",
    "",
  ];

  Object.entries(scan.stats.filesByType)
    .sort(([, a], [, b]) => b - a)
    .forEach(([ext, count]) => {
      reportLines.push(`- ${ext}: ${count} files`);
    });

  reportLines.push("");

  if (scan.orphanedFiles.length > 0) {
    reportLines.push("## 🗑️ Orphaned Files");
    reportLines.push("");
    scan.orphanedFiles.forEach((file) => {
      reportLines.push(`- \`${file.path}\` (${formatBytes(file.size)})`);
    });
    reportLines.push("");
  }

  if (scan.misplacedFiles.length > 0) {
    reportLines.push("## 📍 Misplaced Files");
    reportLines.push("");
    scan.misplacedFiles.forEach((file) => {
      reportLines.push(`- \`${file.path}\`: ${file.misplacementReason}`);
    });
    reportLines.push("");
  }

  if (validation.missingRequired.length > 0) {
    reportLines.push("## ❌ Missing Required Files");
    reportLines.push("");
    validation.missingRequired.forEach((file) => {
      reportLines.push(`- \`${file}\``);
    });
    reportLines.push("");
  }

  if (plan.deleteFiles.length > 0 || plan.moveFiles.length > 0) {
    reportLines.push("## 🧹 Cleanup Plan");
    reportLines.push("");

    if (plan.deleteFiles.length > 0) {
      reportLines.push("### Files to Delete");
      plan.deleteFiles.forEach((item) => {
        reportLines.push(
          `- \`${item.path}\`: ${item.reason} (saves ${formatBytes(item.size)})`
        );
      });
      reportLines.push("");
    }

    if (plan.moveFiles.length > 0) {
      reportLines.push("### Files to Move");
      plan.moveFiles.forEach((item) => {
        reportLines.push(`- \`${item.from}\` → \`${item.to}\`: ${item.reason}`);
      });
      reportLines.push("");
    }
  }

  reportLines.push("## Recommendations");
  reportLines.push("");
  validation.suggestions.forEach((suggestion) => {
    reportLines.push(`- ${suggestion}`);
  });

  return reportLines.join("\n");
}

function formatBytes(bytes) {
  if (bytes === 0) return "0 Bytes";
  const k = 1024;
  const sizes = ["Bytes", "KB", "MB", "GB"];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + " " + sizes[i];
}

async function main() {
  console.log("🧹 Starting Repository Sanitize for Phase 4A...\n");

  try {
    console.log("🔍 Scanning repository structure...");
    const scan = await scanRepository();
    console.log(
      `Found ${scan.stats.totalFiles} files (${formatBytes(
        scan.stats.totalSize
      )})`
    );

    console.log("✅ Validating structure...");
    const validation = await validateStructure(scan);

    console.log("📋 Generating cleanup plan...");
    const plan = await generateCleanupPlan(scan, validation);

    console.log("📝 Generating report...");
    const reportContent = await generateReport(scan, validation, plan);

    const reportPath = join(projectRoot, "dev-log/phase-4/sanitize-report.md");
    await fs.writeFile(reportPath, reportContent);

    // Save cleanup plan as JSON
    const planPath = join(projectRoot, "dev-log/phase-4/cleanup-plan.json");
    await fs.writeFile(planPath, JSON.stringify(plan, null, 2));

    console.log(`\n✅ Repository sanitize complete!`);
    console.log(`   Report saved to: ${reportPath}`);
    console.log(`   Cleanup plan saved to: ${planPath}`);

    // Summary for console
    console.log("\n📊 Summary:");
    console.log(`   📁 Files scanned: ${scan.stats.totalFiles}`);
    console.log(`   🗑️ Orphaned: ${scan.orphanedFiles.length}`);
    console.log(`   📍 Misplaced: ${scan.misplacedFiles.length}`);
    console.log(`   ❌ Missing required: ${validation.missingRequired.length}`);

    // Exit with appropriate code
    if (
      scan.orphanedFiles.length > 0 ||
      scan.misplacedFiles.length > 0 ||
      validation.missingRequired.length > 0
    ) {
      console.log(
        "\n⚠️ Repository issues detected. Check the report for details."
      );
      process.exit(1);
    } else {
      console.log("\n🎉 Repository structure is clean and organized!");
      process.exit(0);
    }
  } catch (error) {
    console.error(`❌ Repository sanitize failed: ${error.message}`);
    process.exit(1);
  }
}

// Run if called directly
if (import.meta.url === `file://${process.argv[1]}`) {
  main();
}

export {
  generateCleanupPlan,
  generateReport,
  scanRepository,
  validateStructure,
};
