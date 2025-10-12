#!/usr/bin/env node
/**
 * Code Sync Script for Phase 4A - Docs ⇄ Code Sync
 * Synchronizes code structure with documentation specifications
 */

import { promises as fs } from "fs";
import { dirname, join } from "path";
import { fileURLToPath } from "url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const projectRoot = join(__dirname, "..");

async function extractDocumentedStructure() {
  const structure = {
    tools: {},
    integrations: {},
    apis: {},
    dependencies: {},
  };

  try {
    const toolsDir = join(projectRoot, "docs/tools");
    const entries = await fs.readdir(toolsDir);

    for (const entry of entries) {
      const entryPath = join(toolsDir, entry);
      const stat = await fs.stat(entryPath);

      if (stat.isDirectory()) {
        // Handle tool subdirectories (e.g., palette_extractor/)
        const tools = await fs.readdir(entryPath);

        for (const tool of tools) {
          const toolPath = join(entryPath, tool);
          const toolStat = await fs.stat(toolPath);

          if (toolStat.isDirectory()) {
            structure.tools[tool] = {
              category: entry,
              path: toolPath,
              spec: await parseToolSpec(toolPath),
            };
          }
        }
      } else if (entry.endsWith(".md")) {
        // Handle standalone tool .md files (e.g., text-tools.md)
        const toolName = entry.replace(".md", "").replace(/-/g, "_");
        structure.tools[toolName] = {
          category: "tools",
          path: entryPath,
          spec: await parseStandaloneToolSpec(entryPath),
        };
      }
    }

    // Parse platform documentation
    const platformDir = join(projectRoot, "docs/platform");
    if (
      await fs
        .access(platformDir)
        .then(() => true)
        .catch(() => false)
    ) {
      const platformFiles = await fs.readdir(platformDir);

      for (const file of platformFiles) {
        if (file.endsWith(".md")) {
          const filePath = join(platformDir, file);
          const content = await fs.readFile(filePath, "utf8");

          // Extract integration specs
          if (file === "cross-tool.md") {
            structure.integrations = await parseIntegrationSpec(content);
          }

          // Extract API specs
          if (file === "functions.md") {
            structure.apis = await parseApiSpec(content);
          }
        }
      }
    }
  } catch (err) {
    console.error(`Error extracting documented structure: ${err.message}`);
  }

  return structure;
}

async function parseToolSpec(toolPath) {
  const spec = {
    routes: [],
    dependencies: [],
    files: [],
    apis: [],
    tests: [],
  };

  try {
    // Parse README.md
    const readmePath = join(toolPath, "README.md");
    const readmeContent = await fs.readFile(readmePath, "utf8");

    // Extract routes
    const routeMatches = readmeContent.match(/Route:\s*`([^`]+)`/g) || [];
    spec.routes = routeMatches.map((match) =>
      match.replace(/Route:\s*`([^`]+)`/, "$1")
    );

    // Parse INTEGRATION.md
    const integrationPath = join(toolPath, "INTEGRATION.md");
    if (
      await fs
        .access(integrationPath)
        .then(() => true)
        .catch(() => false)
    ) {
      const integrationContent = await fs.readFile(integrationPath, "utf8");

      // Extract dependencies
      const depMatches = integrationContent.match(/```yaml([^`]+)```/g) || [];
      depMatches.forEach((match) => {
        const yamlContent = match.replace(/```yaml([^`]+)```/s, "$1");
        if (yamlContent.includes("dependencies:")) {
          const deps = yamlContent.match(/^\s*([a-z_]+):/gm) || [];
          spec.dependencies.push(
            ...deps.map((d) => d.replace(/^\s*([a-z_]+):/, "$1"))
          );
        }
      });

      // Extract API endpoints
      const apiMatches =
        integrationContent.match(/POST|GET|PUT|DELETE\s+`([^`]+)`/g) || [];
      spec.apis = apiMatches.map((match) =>
        match.replace(/(POST|GET|PUT|DELETE)\s+`([^`]+)`/, "$2")
      );
    }

    // Parse TESTS.md
    const testsPath = join(toolPath, "TESTS.md");
    if (
      await fs
        .access(testsPath)
        .then(() => true)
        .catch(() => false)
    ) {
      const testsContent = await fs.readFile(testsPath, "utf8");

      // Extract test file patterns
      const testMatches = testsContent.match(/test\/.*\.dart/g) || [];
      spec.tests = testMatches;
    }
  } catch (err) {
    console.warn(`Error parsing tool spec for ${toolPath}: ${err.message}`);
  }

  return spec;
}

async function parseStandaloneToolSpec(toolPath) {
  const spec = {
    routes: [],
    dependencies: [],
    files: [],
    apis: [],
    tests: [],
  };

  try {
    const content = await fs.readFile(toolPath, "utf8");

    // Extract routes from various patterns
    const routeMatches = content.match(/Route:\s*`([^`]+)`/g) || [];
    spec.routes = routeMatches.map((match) =>
      match.replace(/Route:\s*`([^`]+)`/, "$1")
    );

    // Also check for route patterns in implementation sections
    const implementationRoutes = content.match(/\/tools\/([a-z-]+)/g) || [];
    spec.routes.push(...implementationRoutes.map((route) => route));

    // Extract dependencies from import/require statements
    const importMatches =
      content.match(/import\s+.*?from\s+['"]([^'"]+)['"]/g) || [];
    const requireMatches =
      content.match(/require\s*\(\s*['"]([^'"]+)['"]\s*\)/g) || [];

    spec.dependencies = [
      ...importMatches.map((match) =>
        match.replace(/import\s+.*?from\s+['"]([^'"]+)['"]/, "$1")
      ),
      ...requireMatches.map((match) =>
        match.replace(/require\s*\(\s*['"]([^'"]+)['"]\s*\)/, "$1")
      ),
    ];

    // Extract file references
    const fileMatches = content.match(/lib\/([a-z_/]+\.dart)/g) || [];
    spec.files = fileMatches;

    // Extract API references
    const apiMatches = content.match(/\/api\/([a-z-]+)/g) || [];
    spec.apis = [...new Set(apiMatches)];

    // Extract test references
    const testMatches = content.match(/test\/([a-z_/]+\.dart)/g) || [];
    spec.tests = testMatches;
  } catch (err) {
    console.warn(
      `Error parsing standalone tool spec for ${toolPath}: ${err.message}`
    );
  }

  return spec;
}

async function parseIntegrationSpec(content) {
  const integrations = {
    shareEnvelope: {},
    crossTool: {},
    microservices: {},
  };

  try {
    // Extract ShareEnvelope protocol
    const shareSection = content.match(/## ShareEnvelope Protocol(.*?)##/s);
    if (shareSection) {
      const protocolSpecs =
        shareSection[1].match(/```typescript([^`]+)```/g) || [];
      integrations.shareEnvelope.specs = protocolSpecs;
    }

    // Extract cross-tool workflows
    const workflowSection = content.match(/## Cross-Tool Workflows(.*?)##/s);
    if (workflowSection) {
      const workflows = workflowSection[1].match(/### ([^\\n]+)[^#]+/g) || [];
      integrations.crossTool.workflows = workflows;
    }
  } catch (err) {
    console.warn(`Error parsing integration spec: ${err.message}`);
  }

  return integrations;
}

async function parseApiSpec(content) {
  const apis = {
    functions: [],
    endpoints: [],
    schemas: {},
  };

  try {
    // Extract function definitions
    const functionMatches = content.match(/exports\.(\w+)\s*=/g) || [];
    apis.functions = functionMatches.map((match) =>
      match.replace(/exports\.(\w+)\s*=/, "$1")
    );

    // Extract endpoint patterns
    const endpointMatches = content.match(/\/api\/([a-z-]+)/g) || [];
    apis.endpoints = [...new Set(endpointMatches)];
  } catch (err) {
    console.warn(`Error parsing API spec: ${err.message}`);
  }

  return apis;
}

async function extractCodeStructure() {
  const structure = {
    routes: {},
    files: {},
    dependencies: {},
    tests: {},
  };

  try {
    // Scan Flutter app structure
    const libDir = join(projectRoot, "lib");
    structure.files.lib = await scanDirectory(libDir, "lib");

    // Scan Firebase Functions
    const functionsDir = join(projectRoot, "functions/src");
    if (
      await fs
        .access(functionsDir)
        .then(() => true)
        .catch(() => false)
    ) {
      structure.files.functions = await scanDirectory(
        functionsDir,
        "functions/src"
      );
    }

    // Scan test directory
    const testDir = join(projectRoot, "test");
    if (
      await fs
        .access(testDir)
        .then(() => true)
        .catch(() => false)
    ) {
      structure.files.test = await scanDirectory(testDir, "test");
    }

    // Parse pubspec.yaml
    const pubspecPath = join(projectRoot, "pubspec.yaml");
    if (
      await fs
        .access(pubspecPath)
        .then(() => true)
        .catch(() => false)
    ) {
      const content = await fs.readFile(pubspecPath, "utf8");
      structure.dependencies.flutter = parsePubspecDependencies(content);
    }

    // Parse functions/package.json
    const functionsPackagePath = join(projectRoot, "functions/package.json");
    if (
      await fs
        .access(functionsPackagePath)
        .then(() => true)
        .catch(() => false)
    ) {
      const content = await fs.readFile(functionsPackagePath, "utf8");
      structure.dependencies.functions = JSON.parse(content).dependencies || {};
    }
  } catch (err) {
    console.error(`Error extracting code structure: ${err.message}`);
  }

  return structure;
}

async function scanDirectory(dir, relativePath) {
  const files = [];

  try {
    const entries = await fs.readdir(dir);

    for (const entry of entries) {
      const fullPath = join(dir, entry);
      const stat = await fs.stat(fullPath);

      if (stat.isDirectory()) {
        const subFiles = await scanDirectory(
          fullPath,
          `${relativePath}/${entry}`
        );
        files.push(...subFiles);
      } else {
        files.push({
          path: `${relativePath}/${entry}`,
          name: entry,
          size: stat.size,
          modified: stat.mtime,
        });
      }
    }
  } catch (err) {
    console.warn(`Could not scan directory ${dir}: ${err.message}`);
  }

  return files;
}

function parsePubspecDependencies(content) {
  const dependencies = {};

  try {
    const lines = content.split("\n");
    let inDependencies = false;

    for (const line of lines) {
      if (line.trim() === "dependencies:") {
        inDependencies = true;
        continue;
      }

      if (inDependencies) {
        if (line.startsWith("  ") && line.includes(":")) {
          const [name, version] = line.trim().split(":");
          dependencies[name] = version.trim();
        } else if (!line.startsWith("  ") && line.trim() !== "") {
          inDependencies = false;
        }
      }
    }
  } catch (err) {
    console.warn(`Error parsing pubspec dependencies: ${err.message}`);
  }

  return dependencies;
}

async function compareStructures(documented, codeStructure) {
  const report = {
    aligned: [],
    missingFiles: [],
    extraFiles: [],
    missingDependencies: [],
    extraDependencies: [],
    missingTests: [],
  };

  // Compare tools with code files
  Object.entries(documented.tools).forEach(([tool, spec]) => {
    // Check if tool has corresponding implementation
    const toolFiles =
      codeStructure.files.lib?.filter(
        (file) =>
          file.path.toLowerCase().includes(tool.toLowerCase()) ||
          (file.path.includes("tools") &&
            file.name.toLowerCase().includes(tool.toLowerCase()))
      ) || [];

    if (toolFiles.length > 0) {
      report.aligned.push({
        tool,
        category: spec.category,
        files: toolFiles.map((f) => f.path),
      });
    } else {
      report.missingFiles.push({
        tool,
        category: spec.category,
        expectedPath: `lib/tools/${spec.category}/${tool}`,
      });
    }

    // Check test files
    const testFiles =
      codeStructure.files.test?.filter((file) =>
        file.path.toLowerCase().includes(tool.toLowerCase())
      ) || [];

    if (spec.spec.tests.length > 0 && testFiles.length === 0) {
      report.missingTests.push({
        tool,
        expectedTests: spec.spec.tests,
      });
    }
  });

  // Compare dependencies
  Object.entries(documented.tools).forEach(([tool, spec]) => {
    spec.spec.dependencies.forEach((dep) => {
      if (!codeStructure.dependencies.flutter[dep]) {
        report.missingDependencies.push({
          tool,
          dependency: dep,
          type: "flutter",
        });
      }
    });
  });

  // Check for extra files that might be orphaned
  const documentedTools = Object.keys(documented.tools);
  const extraLibFiles =
    codeStructure.files.lib?.filter(
      (file) =>
        file.path.includes("tools") &&
        !documentedTools.some((tool) =>
          file.path.toLowerCase().includes(tool.toLowerCase())
        )
    ) || [];

  if (extraLibFiles.length > 0) {
    report.extraFiles = extraLibFiles.map((file) => ({
      path: file.path,
      type: "potentially orphaned",
    }));
  }

  return report;
}

async function generateSyncPlan(report) {
  const plan = {
    createFiles: [],
    updateFiles: [],
    removeFiles: [],
    addDependencies: [],
    createTests: [],
  };

  // Plan file creation for missing implementations
  report.missingFiles.forEach((item) => {
    plan.createFiles.push({
      action: "create",
      path: `${item.expectedPath}/${item.tool}_screen.dart`,
      template: "tool_screen",
      tool: item.tool,
      category: item.category,
    });

    plan.createFiles.push({
      action: "create",
      path: `${item.expectedPath}/${item.tool}_service.dart`,
      template: "tool_service",
      tool: item.tool,
      category: item.category,
    });
  });

  // Plan dependency additions
  report.missingDependencies.forEach((item) => {
    plan.addDependencies.push({
      action: "add_dependency",
      package: item.dependency,
      type: item.type,
      tool: item.tool,
    });
  });

  // Plan test creation
  report.missingTests.forEach((item) => {
    item.expectedTests.forEach((testFile) => {
      plan.createTests.push({
        action: "create_test",
        path: testFile,
        tool: item.tool,
      });
    });
  });

  return plan;
}

async function generateReport(report, plan) {
  const reportLines = [
    "# Code Sync Report - Phase 4A",
    "",
    `Generated: ${new Date().toISOString()}`,
    "",
    "## Summary",
    `- ✅ Aligned tools: ${report.aligned.length}`,
    `- ❌ Missing files: ${report.missingFiles.length}`,
    `- 🗑️ Extra files: ${report.extraFiles.length}`,
    `- 📦 Missing dependencies: ${report.missingDependencies.length}`,
    `- 🧪 Missing tests: ${report.missingTests.length}`,
    "",
    "## Sync Plan",
    `- 📄 Files to create: ${plan.createFiles.length}`,
    `- 📦 Dependencies to add: ${plan.addDependencies.length}`,
    `- 🧪 Tests to create: ${plan.createTests.length}`,
    "",
  ];

  if (report.aligned.length > 0) {
    reportLines.push("## ✅ Aligned Tools");
    reportLines.push("");
    report.aligned.forEach((item) => {
      reportLines.push(
        `- **${item.tool}** (${item.category}): ${item.files.length} files`
      );
      item.files.forEach((file) => {
        reportLines.push(`  - ${file}`);
      });
    });
    reportLines.push("");
  }

  if (report.missingFiles.length > 0) {
    reportLines.push("## ❌ Missing Implementations");
    reportLines.push("");
    report.missingFiles.forEach((item) => {
      reportLines.push(
        `- **${item.tool}** (${item.category}): Expected at ${item.expectedPath}`
      );
    });
    reportLines.push("");
  }

  if (plan.createFiles.length > 0) {
    reportLines.push("## 📄 Files to Create");
    reportLines.push("");
    plan.createFiles.forEach((item) => {
      reportLines.push(`- ${item.path} (${item.template} for ${item.tool})`);
    });
    reportLines.push("");
  }

  if (plan.addDependencies.length > 0) {
    reportLines.push("## 📦 Dependencies to Add");
    reportLines.push("");
    plan.addDependencies.forEach((item) => {
      reportLines.push(`- ${item.package} (${item.type}) for ${item.tool}`);
    });
    reportLines.push("");
  }

  return reportLines.join("\n");
}

async function main() {
  console.log("🔄 Starting Code Sync for Phase 4A...\n");

  try {
    console.log("📚 Extracting documented structure...");
    const documented = await extractDocumentedStructure();
    console.log(
      `Found ${Object.keys(documented.tools).length} documented tools`
    );

    console.log("💻 Extracting code structure...");
    const codeStructure = await extractCodeStructure();
    console.log(`Found ${codeStructure.files.lib?.length || 0} lib files`);

    console.log("🔄 Comparing structures...");
    const report = await compareStructures(documented, codeStructure);

    console.log("📋 Generating sync plan...");
    const plan = await generateSyncPlan(report);

    console.log("📝 Generating report...");
    const reportContent = await generateReport(report, plan);

    const reportPath = join(projectRoot, "dev-log/phase-4/code-sync-report.md");
    await fs.writeFile(reportPath, reportContent);

    // Save sync plan as JSON for automated execution
    const planPath = join(projectRoot, "dev-log/phase-4/sync-plan.json");
    await fs.writeFile(planPath, JSON.stringify(plan, null, 2));

    console.log(`\n✅ Code sync analysis complete!`);
    console.log(`   Report saved to: ${reportPath}`);
    console.log(`   Sync plan saved to: ${planPath}`);

    // Summary for console
    console.log("\n📊 Summary:");
    console.log(`   ✅ Aligned: ${report.aligned.length}`);
    console.log(`   ❌ Missing files: ${report.missingFiles.length}`);
    console.log(`   📦 Missing deps: ${report.missingDependencies.length}`);
    console.log(`   🧪 Missing tests: ${report.missingTests.length}`);

    // Exit with appropriate code
    if (
      report.missingFiles.length > 0 ||
      report.missingDependencies.length > 0 ||
      report.missingTests.length > 0
    ) {
      console.log(
        "\n⚠️ Code sync issues detected. Check the report for details."
      );
      process.exit(1);
    } else {
      console.log("\n🎉 Code structure is fully aligned with documentation!");
      process.exit(0);
    }
  } catch (error) {
    console.error(`❌ Code sync failed: ${error.message}`);
    process.exit(1);
  }
}

// Run if called directly
if (import.meta.url === `file://${process.argv[1]}`) {
  main();
}

export {
  compareStructures,
  extractCodeStructure,
  extractDocumentedStructure,
  generateReport,
  generateSyncPlan,
};
