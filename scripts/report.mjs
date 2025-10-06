#!/usr/bin/env node

/**
 * Sprint report generation script for OPS-Delta
 * Generates comprehensive sprint reports with velocity charts, shipped items, and progress tracking
 */

import { Octokit } from "@octokit/rest";
import { calculateVelocity } from "./velocity.mjs";
import {
  getCurrentSprintName,
  getISOWeek,
  fetchIssues,
  parseEstimate,
  getPriority,
  getToolAndArea,
  isReady,
  formatDate,
  markdownTable,
} from "./utils.mjs";

/**
 * Generate comprehensive sprint report
 * @param {Object} options - Configuration options
 * @param {string} options.token - GitHub token
 * @param {string} options.owner - Repository owner
 * @param {string} options.repo - Repository name
 * @param {boolean} options.dryRun - If true, output to console instead of files
 * @returns {Promise<Object>} Generated report data
 */
async function generateSprintReport(options = {}) {
  const {
    token = process.env.GITHUB_TOKEN,
    owner = process.env.GITHUB_REPOSITORY?.split("/")[0],
    repo = process.env.GITHUB_REPOSITORY?.split("/")[1],
    dryRun = false,
  } = options;

  if (!token || !owner || !repo) {
    throw new Error("Missing required parameters: token, owner, repo");
  }

  const octokit = new Octokit({ auth: token });
  const currentSprint = getCurrentSprintName();
  const currentWeek = getISOWeek();
  const reportDate = formatDate(new Date());

  console.log(`📊 Generating sprint report for ${owner}/${repo}`);
  console.log(`🏃 Current Sprint: ${currentSprint}`);
  console.log(`📅 Report Date: ${reportDate}`);

  // Generate velocity data
  const velocityData = await calculateVelocity({
    token,
    owner,
    repo,
    dryRun: true,
  });

  // Fetch current sprint data
  const sprintData = await fetchSprintData(
    octokit,
    { owner, repo },
    currentSprint
  );

  // Generate report sections
  const reportSections = {
    header: generateHeader(currentSprint, currentWeek, reportDate),
    velocity: velocityData.mermaidChart,
    velocityTable: velocityData.summaryTable,
    shipped: generateShippedSection(sprintData.shipped),
    inProgress: generateInProgressSection(sprintData.inProgress),
    nextUp: generateNextUpSection(sprintData.backlog),
    stats: generateStatsSection(velocityData.stats, sprintData),
  };

  // Combine into full report
  const fullReport = generateFullReport(reportSections);

  // Generate archive filename
  const archiveFilename = `${currentWeek}.md`;

  const result = {
    currentSprint,
    currentWeek,
    reportDate,
    fullReport,
    archiveFilename,
    sections: reportSections,
    data: {
      velocity: velocityData,
      sprint: sprintData,
    },
  };

  if (dryRun) {
    console.log("\n📋 SPRINT REPORT");
    console.log("================");
    console.log(fullReport);
  }

  return result;
}

/**
 * Fetch current sprint data including shipped, in-progress, and backlog items
 */
async function fetchSprintData(octokit, repo, sprintName) {
  console.log(`🔍 Fetching sprint data for ${sprintName}`);

  // Fetch all open and recently closed issues
  const [openIssues, closedIssues] = await Promise.all([
    fetchIssues(octokit, repo, { state: "open" }),
    fetchIssues(octokit, repo, { state: "closed", since: getRecentDate(14) }),
  ]);

  // Get recently merged PRs (last 7 days)
  const mergedPRs = await fetchRecentMergedPRs(octokit, repo, 7);

  // Categorize issues
  const shipped = closedIssues.filter(
    (issue) =>
      issue.labels.some((label) => label.name === "done") &&
      issue.milestone?.title === sprintName
  );

  const inProgress = openIssues.filter(
    (issue) => isReady(issue) || issue.milestone?.title === sprintName
  );

  const backlog = openIssues
    .filter(
      (issue) =>
        !isReady(issue) &&
        issue.milestone?.title !== sprintName &&
        ["P0-blocker", "P1", "P2"].some((p) =>
          issue.labels.some((l) => l.name === p)
        )
    )
    .sort((a, b) => {
      const priorityA = getPriority(a);
      const priorityB = getPriority(b);
      const priorityDiff =
        getPriorityValue(priorityA) - getPriorityValue(priorityB);
      if (priorityDiff !== 0) return priorityDiff;
      return parseEstimate(a) - parseEstimate(b);
    })
    .slice(0, 10); // Top 10 backlog items

  return {
    shipped,
    inProgress,
    backlog,
    mergedPRs,
    sprintName,
  };
}

/**
 * Fetch recently merged PRs
 */
async function fetchRecentMergedPRs(octokit, repo, days) {
  const since = getRecentDate(days);

  const { data: prs } = await octokit.rest.pulls.list({
    owner: repo.owner,
    repo: repo.repo,
    state: "closed",
    per_page: 100,
  });

  return prs.filter(
    (pr) => pr.merged_at && new Date(pr.merged_at) >= new Date(since)
  );
}

/**
 * Generate report header
 */
function generateHeader(sprintName, weekId, reportDate) {
  return `# Sprint Summary - Week ${weekId}

**Sprint:** ${sprintName}
**Generated:** ${reportDate}
**Period:** ${formatDate(getRecentDate(7))} to ${reportDate}

---`;
}

/**
 * Generate shipped items section
 */
function generateShippedSection(shippedIssues) {
  if (shippedIssues.length === 0) {
    return `## 🚢 What Shipped

*No items completed this sprint.*`;
  }

  const totalPoints = shippedIssues.reduce(
    (sum, issue) => sum + parseEstimate(issue),
    0
  );

  const table = [
    ["Issue", "Title", "Priority", "Points", "Tool"],
    ...shippedIssues.map((issue) => {
      const { tool } = getToolAndArea(issue);
      return [
        `#${issue.number}`,
        issue.title,
        getPriority(issue),
        parseEstimate(issue).toString(),
        tool,
      ];
    }),
  ];

  return `## 🚢 What Shipped

**Completed:** ${shippedIssues.length} issues (${
    Math.round(totalPoints * 10) / 10
  } points)

${markdownTable(table)}`;
}

/**
 * Generate in-progress items section
 */
function generateInProgressSection(inProgressIssues) {
  if (inProgressIssues.length === 0) {
    return `## 🔄 In Progress

*No items currently in progress.*`;
  }

  const totalPoints = inProgressIssues.reduce(
    (sum, issue) => sum + parseEstimate(issue),
    0
  );

  const table = [
    ["Issue", "Title", "Priority", "Points", "Status"],
    ...inProgressIssues.map((issue) => {
      const status = isReady(issue) ? "Ready" : "Planned";
      return [
        `#${issue.number}`,
        issue.title,
        getPriority(issue),
        parseEstimate(issue).toString(),
        status,
      ];
    }),
  ];

  return `## 🔄 In Progress

**Active:** ${inProgressIssues.length} issues (${
    Math.round(totalPoints * 10) / 10
  } points)

${markdownTable(table)}`;
}

/**
 * Generate next up section
 */
function generateNextUpSection(backlogIssues) {
  if (backlogIssues.length === 0) {
    return `## 📋 Next Up

*No prioritized backlog items.*`;
  }

  const table = [
    ["Issue", "Title", "Priority", "Points", "Area"],
    ...backlogIssues.map((issue) => {
      const { area } = getToolAndArea(issue);
      return [
        `#${issue.number}`,
        issue.title,
        getPriority(issue),
        parseEstimate(issue).toString(),
        area,
      ];
    }),
  ];

  return `## 📋 Next Up

**Top Backlog Items** (by priority + estimate):

${markdownTable(table)}`;
}

/**
 * Generate statistics section
 */
function generateStatsSection(velocityStats, sprintData) {
  const readyCount = sprintData.inProgress.filter(isReady).length;
  const plannedCount = sprintData.inProgress.length - readyCount;

  return `## 📊 Sprint Metrics

### Velocity (Last 4 Weeks)
- **Total Issues Completed:** ${velocityStats.totalIssues}
- **Total Points Completed:** ${velocityStats.totalPoints}
- **Average Estimate:** ${velocityStats.avgEstimate}d per issue
- **PRs Merged:** ${velocityStats.totalPRs}

### Current Sprint Health
- **Issues Shipped:** ${sprintData.shipped.length}
- **Ready Queue:** ${readyCount}/5 slots
- **Planned Items:** ${plannedCount}
- **Top Priority Backlog:** ${
    sprintData.backlog.filter((i) => getPriority(i) === "P0-blocker").length
  } P0 items

### Tool Distribution
${velocityStats.toolStats
  .slice(0, 5)
  .map(
    (tool) => `- **${tool.tool}:** ${tool.count} issues (${tool.points} points)`
  )
  .join("\n")}`;
}

/**
 * Generate full report by combining all sections
 */
function generateFullReport(sections) {
  return [
    sections.header,
    "",
    sections.velocity,
    "",
    "## 📈 Velocity Trends",
    "",
    sections.velocityTable,
    "",
    sections.shipped,
    "",
    sections.inProgress,
    "",
    sections.nextUp,
    "",
    sections.stats,
    "",
    "---",
    "*Report generated by OPS-Delta Sprint Reporter*",
  ].join("\n");
}

/**
 * Get date N days ago as ISO string
 */
function getRecentDate(days) {
  const date = new Date();
  date.setDate(date.getDate() - days);
  return date.toISOString();
}

/**
 * Get priority numeric value for sorting
 */
function getPriorityValue(priority) {
  switch (priority) {
    case "P0-blocker":
      return 0;
    case "P1":
      return 1;
    case "P2":
      return 2;
    default:
      return 3;
  }
}

// CLI support
if (import.meta.url === `file://${process.argv[1]}`) {
  const args = process.argv.slice(2);
  const dryRun = args.includes("--dry-run");

  try {
    const result = await generateSprintReport({ dryRun });

    if (!dryRun) {
      console.log(result.fullReport);
    }
  } catch (error) {
    console.error("❌ Error generating report:", error.message);
    process.exit(1);
  }
}

export { generateSprintReport };
export default generateSprintReport;
