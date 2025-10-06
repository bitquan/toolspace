#!/usr/bin/env node

/**
 * Velocity calculation script for OPS-Delta
 * Analyzes completed issues and PRs to generate velocity metrics and Mermaid charts
 */

import { Octokit } from "@octokit/rest";
import dayjs from "dayjs";
import isoWeek from "dayjs/plugin/isoWeek.js";
import {
  getISOWeek,
  parseEstimate,
  getPriority,
  getToolAndArea,
  getDateRange,
  groupBy,
  isCompleted,
  markdownTable,
} from "./utils.mjs";

dayjs.extend(isoWeek);

/**
 * Calculate velocity metrics for the specified time period
 * @param {Object} options - Configuration options
 * @param {number} options.sinceDays - Days to look back (default 28)
 * @param {string} options.token - GitHub token
 * @param {string} options.owner - Repository owner
 * @param {string} options.repo - Repository name
 * @param {boolean} options.dryRun - If true, output to console instead of files
 * @returns {Promise<Object>} Velocity data and charts
 */
async function calculateVelocity(options = {}) {
  const {
    sinceDays = 28,
    token = process.env.GITHUB_TOKEN,
    owner = process.env.GITHUB_REPOSITORY?.split("/")[0],
    repo = process.env.GITHUB_REPOSITORY?.split("/")[1],
    dryRun = false,
  } = options;

  if (!token || !owner || !repo) {
    throw new Error("Missing required parameters: token, owner, repo");
  }

  const octokit = new Octokit({ auth: token });
  const { since, until } = getDateRange(sinceDays);

  console.log(`🔍 Calculating velocity for ${owner}/${repo}`);
  console.log(
    `📅 Period: ${since.split("T")[0]} to ${
      until.split("T")[0]
    } (${sinceDays} days)`
  );

  // Fetch completed issues in the date range
  const issues = await fetchCompletedIssues(octokit, { owner, repo }, since);

  // Fetch merged PRs in the date range
  const mergedPRs = await fetchMergedPRs(octokit, { owner, repo }, since);

  console.log(
    `📊 Found ${issues.length} completed issues and ${mergedPRs.length} merged PRs`
  );

  // Group data by ISO week
  const weeklyData = generateWeeklyData(issues, mergedPRs, sinceDays);

  // Generate statistics
  const stats = generateStatistics(issues, mergedPRs);

  // Generate Mermaid chart
  const mermaidChart = generateMermaidChart(weeklyData);

  // Generate summary table
  const summaryTable = generateSummaryTable(weeklyData);

  const result = {
    period: { since, until, days: sinceDays },
    weeklyData,
    stats,
    mermaidChart,
    summaryTable,
    issues: issues.length,
    prs: mergedPRs.length,
  };

  if (dryRun) {
    console.log("\n📈 VELOCITY REPORT");
    console.log("==================");
    console.log(mermaidChart);
    console.log("\n📋 WEEKLY SUMMARY");
    console.log(summaryTable);
    console.log("\n📊 STATISTICS");
    console.log(JSON.stringify(stats, null, 2));
  }

  return result;
}

/**
 * Fetch completed issues (closed with 'done' label) within date range
 */
async function fetchCompletedIssues(octokit, repo, since) {
  const allIssues = [];
  let page = 1;

  while (true) {
    const { data: issues } = await octokit.rest.issues.listForRepo({
      owner: repo.owner,
      repo: repo.repo,
      state: "closed",
      since,
      per_page: 100,
      page,
    });

    if (issues.length === 0) break;

    // Filter for actual issues (not PRs) with 'done' label
    const completedIssues = issues.filter(
      (issue) =>
        !issue.pull_request &&
        issue.labels.some((label) => label.name === "done")
    );

    allIssues.push(...completedIssues);

    if (issues.length < 100) break;
    page++;
  }

  return allIssues;
}

/**
 * Fetch merged PRs within date range
 */
async function fetchMergedPRs(octokit, repo, since) {
  const allPRs = [];
  let page = 1;

  while (true) {
    const { data: prs } = await octokit.rest.pulls.list({
      owner: repo.owner,
      repo: repo.repo,
      state: "closed",
      per_page: 100,
      page,
    });

    if (prs.length === 0) break;

    // Filter for merged PRs within date range
    const mergedPRs = prs.filter(
      (pr) => pr.merged_at && new Date(pr.merged_at) >= new Date(since)
    );

    allPRs.push(...mergedPRs);

    if (prs.length < 100) break;
    page++;
  }

  return allPRs;
}

/**
 * Generate weekly aggregated data
 */
function generateWeeklyData(issues, prs, sinceDays) {
  const weeks = new Map();

  // Initialize weeks
  const now = new Date();
  for (let i = 0; i < Math.ceil(sinceDays / 7); i++) {
    const weekDate = new Date(now);
    weekDate.setDate(weekDate.getDate() - i * 7);
    const weekKey = getISOWeek(weekDate);

    weeks.set(weekKey, {
      week: weekKey,
      completedIssues: 0,
      completedPoints: 0,
      mergedPRs: 0,
      topLabels: new Map(),
      topTools: new Map(),
    });
  }

  // Aggregate issues by week
  issues.forEach((issue) => {
    const closedWeek = getISOWeek(new Date(issue.closed_at));
    const weekData = weeks.get(closedWeek);

    if (weekData) {
      weekData.completedIssues++;
      weekData.completedPoints += parseEstimate(issue);

      // Track labels and tools
      issue.labels.forEach((label) => {
        const name = label.name;
        weekData.topLabels.set(name, (weekData.topLabels.get(name) || 0) + 1);
      });

      const { tool } = getToolAndArea(issue);
      weekData.topTools.set(tool, (weekData.topTools.get(tool) || 0) + 1);
    }
  });

  // Aggregate PRs by week
  prs.forEach((pr) => {
    const mergedWeek = getISOWeek(new Date(pr.merged_at));
    const weekData = weeks.get(mergedWeek);

    if (weekData) {
      weekData.mergedPRs++;
    }
  });

  // Convert Maps to sorted arrays and return as array
  return Array.from(weeks.values())
    .map((week) => ({
      ...week,
      topLabels: Array.from(week.topLabels.entries())
        .sort((a, b) => b[1] - a[1])
        .slice(0, 5),
      topTools: Array.from(week.topTools.entries())
        .sort((a, b) => b[1] - a[1])
        .slice(0, 3),
    }))
    .sort((a, b) => a.week.localeCompare(b.week));
}

/**
 * Generate overall statistics
 */
function generateStatistics(issues, prs) {
  const totalIssues = issues.length;
  const totalPoints = issues.reduce(
    (sum, issue) => sum + parseEstimate(issue),
    0
  );
  const totalPRs = prs.length;

  // Priority breakdown
  const priorityBreakdown = groupBy(issues, (issue) => getPriority(issue));
  const priorityStats = Object.entries(priorityBreakdown).map(
    ([priority, issues]) => ({
      priority,
      count: issues.length,
      points: issues.reduce((sum, issue) => sum + parseEstimate(issue), 0),
    })
  );

  // Tool/area breakdown
  const toolBreakdown = groupBy(issues, (issue) => getToolAndArea(issue).tool);
  const toolStats = Object.entries(toolBreakdown)
    .map(([tool, issues]) => ({
      tool,
      count: issues.length,
      points: issues.reduce((sum, issue) => sum + parseEstimate(issue), 0),
    }))
    .sort((a, b) => b.count - a.count)
    .slice(0, 10);

  // Average estimates
  const avgEstimate =
    totalIssues > 0 ? (totalPoints / totalIssues).toFixed(1) : 0;

  return {
    totalIssues,
    totalPoints: Math.round(totalPoints * 10) / 10,
    totalPRs,
    avgEstimate: parseFloat(avgEstimate),
    priorityStats,
    toolStats,
  };
}

/**
 * Generate Mermaid bar chart
 */
function generateMermaidChart(weeklyData) {
  if (weeklyData.length === 0) {
    return "```mermaid\nbar chart\n  title No Data Available\n```";
  }

  const weeks = weeklyData.map((w) => w.week.split("-")[1]);
  const issuesData = weeklyData.map((w) => w.completedIssues);
  const pointsData = weeklyData.map((w) => Math.round(w.completedPoints));

  return `\`\`\`mermaid
bar chart
  title Velocity (Issues/Points)
  x-axis [${weeks.join(",")}]
  y-axis "Count"
  "Completed Issues" [${issuesData.join(",")}]
  "Completed Points" [${pointsData.join(",")}]
\`\`\``;
}

/**
 * Generate summary table
 */
function generateSummaryTable(weeklyData) {
  const headers = [
    "Week",
    "Issues",
    "Points",
    "PRs",
    "Top Tools",
    "Top Labels",
  ];
  const rows = weeklyData.map((week) => [
    week.week,
    week.completedIssues.toString(),
    Math.round(week.completedPoints).toString(),
    week.mergedPRs.toString(),
    week.topTools.map(([tool, count]) => `${tool}(${count})`).join(", ") ||
      "None",
    week.topLabels
      .slice(0, 3)
      .map(([label, count]) => `${label}(${count})`)
      .join(", ") || "None",
  ]);

  return markdownTable([headers, ...rows]);
}

// CLI support
if (import.meta.url === `file://${process.argv[1]}`) {
  const args = process.argv.slice(2);
  const dryRun = args.includes("--dry-run");
  const sinceDays =
    parseInt(
      args.find((arg) => arg.startsWith("--since-days="))?.split("=")[1]
    ) || 28;

  try {
    const result = await calculateVelocity({ sinceDays, dryRun });

    if (!dryRun) {
      // Output Mermaid chart for GitHub Actions
      console.log(result.mermaidChart);
      console.log("\n" + result.summaryTable);
    }
  } catch (error) {
    console.error("❌ Error calculating velocity:", error.message);
    process.exit(1);
  }
}

export { calculateVelocity };
export default calculateVelocity;
