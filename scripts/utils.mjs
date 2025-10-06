#!/usr/bin/env node

/**
 * Utility functions for OPS-Delta sprint management system
 * Provides common functionality for velocity tracking, issue parsing, and sprint management
 */

import dayjs from "dayjs";
import isoWeek from "dayjs/plugin/isoWeek.js";

dayjs.extend(isoWeek);

/**
 * Generate current sprint name using ISO week format: Sprint-YYMM-W##
 * @param {Date} date - Optional date to generate sprint name for (defaults to now)
 * @returns {string} Sprint name in format Sprint-YYMM-W##
 */
export function getCurrentSprintName(date = new Date()) {
  const y = date.getFullYear().toString().slice(-2);
  const month = String(date.getMonth() + 1).padStart(2, "0");
  const week = String(dayjs(date).isoWeek()).padStart(2, "0");
  return `Sprint-${y}${month}-W${week}`;
}

/**
 * Get ISO week identifier for a date (YYYY-WW format)
 * @param {Date} date - Date to get week for
 * @returns {string} ISO week in YYYY-WW format
 */
export function getISOWeek(date = new Date()) {
  const year = dayjs(date).isoWeekYear();
  const week = String(dayjs(date).isoWeek()).padStart(2, "0");
  return `${year}-${week}`;
}

/**
 * Fetch issues from GitHub API with filtering options
 * @param {Object} octokit - GitHub API client
 * @param {Object} repo - Repository info {owner, repo}
 * @param {Object} options - Filter options
 * @param {string} options.state - Issue state ('open', 'closed', 'all')
 * @param {string|string[]} options.labels - Label(s) to filter by
 * @param {string} options.milestone - Milestone title to filter by
 * @param {string} options.since - ISO date string for issues updated since
 * @param {number} options.per_page - Results per page (default 100)
 * @returns {Promise<Array>} Array of issues
 */
export async function fetchIssues(octokit, repo, options = {}) {
  const {
    state = "all",
    labels = "",
    milestone,
    since,
    per_page = 100,
  } = options;

  const params = {
    owner: repo.owner,
    repo: repo.repo,
    state,
    per_page,
    ...(labels && {
      labels: Array.isArray(labels) ? labels.join(",") : labels,
    }),
    ...(since && { since }),
    ...(milestone && { milestone }),
  };

  let allIssues = [];
  let page = 1;

  while (true) {
    const { data: issues } = await octokit.rest.issues.listForRepo({
      ...params,
      page,
    });

    if (issues.length === 0) break;

    // Filter out pull requests
    allIssues = allIssues.concat(issues.filter((issue) => !issue.pull_request));

    if (issues.length < per_page) break;
    page++;
  }

  return allIssues;
}

/**
 * Parse estimate from issue body or labels
 * Looks for patterns like "Estimate: 2.5d" or "est:2.5d" label
 * @param {Object} issue - GitHub issue object
 * @returns {number} Estimated days (default 1.0)
 */
export function parseEstimate(issue) {
  // Check issue body for "estimate: Xd" pattern
  const bodyMatch = (issue.body || "").match(
    /estimate[:\s]*(\d+(?:\.\d+)?)\s*d/i
  );
  if (bodyMatch) {
    return parseFloat(bodyMatch[1]);
  }

  // Check labels for "est:Xd" pattern
  const labels = (issue.labels || []).map((l) => l.name).join(" ");
  const labelMatch = labels.match(/est:([\d\.]+)d/i);
  if (labelMatch) {
    return parseFloat(labelMatch[1]);
  }

  return 1.0; // Default estimate
}

/**
 * Get priority value from issue labels
 * @param {Object} issue - GitHub issue object
 * @returns {string} Priority (P0-blocker, P1, P2, or unknown)
 */
export function getPriority(issue) {
  const labels = (issue.labels || []).map((l) => l.name);

  if (labels.includes("P0-blocker")) return "P0-blocker";
  if (labels.includes("P1")) return "P1";
  if (labels.includes("P2")) return "P2";

  return "unknown";
}

/**
 * Get priority numeric value for sorting (lower = higher priority)
 * @param {string} priority - Priority string (P0-blocker, P1, P2, etc.)
 * @returns {number} Numeric priority (0 = highest)
 */
export function getPriorityValue(priority) {
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

/**
 * Extract tool and area labels from issue
 * @param {Object} issue - GitHub issue object
 * @returns {Object} {tool: string, area: string}
 */
export function getToolAndArea(issue) {
  const labels = (issue.labels || []).map((l) => l.name);

  const tool =
    labels.find((l) => l.startsWith("tool:"))?.replace("tool:", "") ||
    "general";
  const area =
    labels.find((l) => l.startsWith("area:"))?.replace("area:", "") ||
    "general";

  return { tool, area };
}

/**
 * Create a URL-safe slug from a string
 * @param {string} str - String to slugify
 * @returns {string} URL-safe slug
 */
export function slug(str) {
  return str
    .toLowerCase()
    .replace(/[^\w\s-]/g, "") // Remove special characters
    .replace(/\s+/g, "-") // Replace spaces with hyphens
    .replace(/-+/g, "-") // Replace multiple hyphens with single
    .trim();
}

/**
 * Get date range for the last N days
 * @param {number} days - Number of days to look back (default 28)
 * @returns {Object} {since: string, until: string} ISO date strings
 */
export function getDateRange(days = 28) {
  const until = new Date();
  const since = new Date();
  since.setDate(since.getDate() - days);

  return {
    since: since.toISOString(),
    until: until.toISOString(),
  };
}

/**
 * Group items by a key function
 * @param {Array} items - Items to group
 * @param {Function} keyFn - Function to extract grouping key
 * @returns {Object} Object with keys as groups and values as arrays
 */
export function groupBy(items, keyFn) {
  return items.reduce((groups, item) => {
    const key = keyFn(item);
    if (!groups[key]) {
      groups[key] = [];
    }
    groups[key].push(item);
    return groups;
  }, {});
}

/**
 * Format a date for display
 * @param {Date|string} date - Date to format
 * @returns {string} Formatted date string
 */
export function formatDate(date) {
  return new Date(date).toISOString().split("T")[0];
}

/**
 * Calculate the number of days between two dates
 * @param {Date|string} start - Start date
 * @param {Date|string} end - End date
 * @returns {number} Number of days
 */
export function daysBetween(start, end) {
  const startDate = new Date(start);
  const endDate = new Date(end);
  const timeDiff = endDate.getTime() - startDate.getTime();
  return Math.ceil(timeDiff / (1000 * 3600 * 24));
}

/**
 * Check if an issue has been completed (closed with 'done' label)
 * @param {Object} issue - GitHub issue object
 * @returns {boolean} True if issue is completed
 */
export function isCompleted(issue) {
  const labels = (issue.labels || []).map((l) => l.name);
  return issue.state === "closed" && labels.includes("done");
}

/**
 * Check if an issue is in ready state
 * @param {Object} issue - GitHub issue object
 * @returns {boolean} True if issue has 'ready' label
 */
export function isReady(issue) {
  const labels = (issue.labels || []).map((l) => l.name);
  return labels.includes("ready");
}

/**
 * Generate a summary table for markdown
 * @param {Array<Array>} data - 2D array of table data (first row = headers)
 * @returns {string} Markdown table
 */
export function markdownTable(data) {
  if (!data || data.length === 0) return "";

  const [headers, ...rows] = data;
  const separator = headers.map(() => "---");

  const formatRow = (row) => `| ${row.join(" | ")} |`;

  return [
    formatRow(headers),
    formatRow(separator),
    ...rows.map(formatRow),
  ].join("\n");
}

export default {
  getCurrentSprintName,
  getISOWeek,
  fetchIssues,
  parseEstimate,
  getPriority,
  getPriorityValue,
  getToolAndArea,
  slug,
  getDateRange,
  groupBy,
  formatDate,
  daysBetween,
  isCompleted,
  isReady,
  markdownTable,
};
