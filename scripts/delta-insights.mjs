#!/usr/bin/env node

/**
 * OPS-Epsilon Delta Insights
 * Advanced analytics and trend analysis for sprint performance and system health
 */

import { Octokit } from "@octokit/rest";
import dayjs from "dayjs";
import isoWeek from "dayjs/plugin/isoWeek.js";
import {
  getCurrentSprintName,
  getISOWeek,
  fetchIssues,
  parseEstimate,
  getPriority,
  getToolAndArea,
  getDateRange,
  groupBy,
  formatDate,
} from "./utils.mjs";

dayjs.extend(isoWeek);

/**
 * Generate comprehensive insights and analytics
 * @param {Object} options - Configuration options
 * @param {number} options.lookbackDays - Days to analyze (default 60)
 * @param {string} options.token - GitHub token
 * @param {string} options.owner - Repository owner
 * @param {string} options.repo - Repository name
 * @param {boolean} options.dryRun - If true, output to console instead of files
 * @returns {Promise<Object>} Insights and analytics data
 */
async function generateInsights(options = {}) {
  const {
    lookbackDays = 60,
    token = process.env.GITHUB_TOKEN,
    owner = process.env.GITHUB_REPOSITORY?.split("/")[0],
    repo = process.env.GITHUB_REPOSITORY?.split("/")[1],
    dryRun = false,
  } = options;

  if (!token || !owner || !repo) {
    throw new Error("Missing required parameters: token, owner, repo");
  }

  const octokit = new Octokit({ auth: token });
  const { since } = getDateRange(lookbackDays);

  console.log(`🔍 OPS-Epsilon Insights Starting`);
  console.log(
    `📅 Analyzing ${lookbackDays} days of data from ${since.split("T")[0]}`
  );

  // Fetch comprehensive data
  const data = await fetchAnalyticsData(octokit, { owner, repo }, since);

  // Generate insights
  const insights = {
    metadata: {
      generatedAt: new Date().toISOString(),
      lookbackDays,
      dataRange: {
        start: since.split("T")[0],
        end: new Date().toISOString().split("T")[0],
      },
      repository: `${owner}/${repo}`,
    },
    velocity: analyzeVelocity(data),
    health: analyzeSystemHealth(data),
    predictive: generatePredictiveInsights(data),
    trends: analyzeTrends(data),
    recommendations: generateRecommendations(data),
    risks: identifyRisks(data),
  };

  if (dryRun) {
    console.log("\n📊 INSIGHTS SUMMARY");
    console.log("==================");
    console.log(`Velocity Score: ${insights.velocity.score}/100`);
    console.log(`Health Score: ${insights.health.score}/100`);
    console.log(`Trend Direction: ${insights.trends.overall}`);
    console.log(`Recommendations: ${insights.recommendations.length}`);
    console.log(`Risk Alerts: ${insights.risks.length}`);
  }

  return insights;
}

/**
 * Fetch all necessary data for analysis
 */
async function fetchAnalyticsData(octokit, repo, since) {
  console.log("📥 Fetching analytics data...");

  const [closedIssues, openIssues, workflows, milestones] = await Promise.all([
    fetchIssues(octokit, repo, { state: "closed", since }),
    fetchIssues(octokit, repo, { state: "open" }),
    fetchWorkflowRuns(octokit, repo, since),
    fetchMilestones(octokit, repo),
  ]);

  // Filter for completed issues (with 'done' label)
  const completedIssues = closedIssues.filter((issue) =>
    issue.labels.some((label) => label.name === "done")
  );

  // Get merged PRs
  const mergedPRs = await fetchMergedPRs(octokit, repo, since);

  return {
    completedIssues,
    openIssues,
    workflows,
    milestones,
    mergedPRs,
  };
}

/**
 * Fetch workflow runs for health analysis
 */
async function fetchWorkflowRuns(octokit, repo, since) {
  const { data: runs } = await octokit.rest.actions.listWorkflowRunsForRepo({
    owner: repo.owner,
    repo: repo.repo,
    per_page: 100,
  });

  return runs.workflow_runs.filter(
    (run) => new Date(run.created_at) >= new Date(since)
  );
}

/**
 * Fetch milestones for sprint analysis
 */
async function fetchMilestones(octokit, repo) {
  const { data: milestones } = await octokit.rest.issues.listMilestones({
    owner: repo.owner,
    repo: repo.repo,
    state: "all",
    per_page: 100,
  });

  return milestones;
}

/**
 * Fetch merged PRs
 */
async function fetchMergedPRs(octokit, repo, since) {
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
 * Analyze velocity metrics and patterns
 */
function analyzeVelocity(data) {
  const { completedIssues, mergedPRs } = data;

  // Group by week for trend analysis
  const weeklyData = groupBy(completedIssues, (issue) =>
    getISOWeek(new Date(issue.closed_at))
  );

  const weeklyVelocity = Object.entries(weeklyData)
    .map(([week, issues]) => ({
      week,
      issueCount: issues.length,
      totalPoints: issues.reduce((sum, issue) => sum + parseEstimate(issue), 0),
      avgEstimate:
        issues.length > 0
          ? issues.reduce((sum, issue) => sum + parseEstimate(issue), 0) /
            issues.length
          : 0,
    }))
    .sort((a, b) => a.week.localeCompare(b.week));

  // Calculate velocity metrics
  const totalIssues = completedIssues.length;
  const totalPoints = completedIssues.reduce(
    (sum, issue) => sum + parseEstimate(issue),
    0
  );
  const avgWeeklyIssues =
    weeklyVelocity.length > 0
      ? weeklyVelocity.reduce((sum, week) => sum + week.issueCount, 0) /
        weeklyVelocity.length
      : 0;
  const avgWeeklyPoints =
    weeklyVelocity.length > 0
      ? weeklyVelocity.reduce((sum, week) => sum + week.totalPoints, 0) /
        weeklyVelocity.length
      : 0;

  // Calculate velocity consistency (lower standard deviation = more consistent)
  const velocityVariance =
    weeklyVelocity.length > 1
      ? calculateStandardDeviation(weeklyVelocity.map((w) => w.issueCount))
      : 0;

  // Calculate velocity score (0-100)
  const velocityScore = Math.min(
    100,
    Math.round(
      avgWeeklyIssues * 10 + // Base score from volume
        avgWeeklyPoints * 5 + // Bonus for points
        (velocityVariance < 2 ? 20 : 0) + // Consistency bonus
        (totalIssues > 0 ? 10 : 0) // Activity bonus
    )
  );

  return {
    score: velocityScore,
    totalIssues,
    totalPoints: Math.round(totalPoints * 10) / 10,
    avgWeeklyIssues: Math.round(avgWeeklyIssues * 10) / 10,
    avgWeeklyPoints: Math.round(avgWeeklyPoints * 10) / 10,
    consistency:
      velocityVariance < 2 ? "High" : velocityVariance < 4 ? "Medium" : "Low",
    weeklyData,
    prVelocity: mergedPRs.length,
  };
}

/**
 * Analyze system health metrics
 */
function analyzeSystemHealth(data) {
  const { workflows } = data;

  // Filter for delta workflows
  const deltaWorkflows = workflows.filter(
    (run) => run.name.includes("Delta") || run.name.includes("OPS-")
  );

  const totalRuns = deltaWorkflows.length;
  const successfulRuns = deltaWorkflows.filter(
    (run) => run.conclusion === "success"
  ).length;
  const failedRuns = deltaWorkflows.filter(
    (run) => run.conclusion === "failure"
  ).length;
  const cancelledRuns = deltaWorkflows.filter(
    (run) => run.conclusion === "cancelled"
  ).length;

  const successRate = totalRuns > 0 ? (successfulRuns / totalRuns) * 100 : 0;
  const failureRate = totalRuns > 0 ? (failedRuns / totalRuns) * 100 : 0;

  // Calculate health score
  const healthScore = Math.round(
    successRate * 0.7 + // 70% weight on success rate
      (totalRuns > 10 ? 20 : totalRuns * 2) + // Activity bonus
      (failureRate < 5 ? 10 : failureRate < 10 ? 5 : 0) // Low failure bonus
  );

  // Analyze workflow patterns
  const workflowsByName = groupBy(deltaWorkflows, (run) => run.name);
  const workflowHealth = Object.entries(workflowsByName).map(
    ([name, runs]) => ({
      name,
      totalRuns: runs.length,
      successRate:
        runs.length > 0
          ? (runs.filter((r) => r.conclusion === "success").length /
              runs.length) *
            100
          : 0,
      avgDuration:
        runs.length > 0
          ? runs.reduce((sum, run) => {
              const duration =
                new Date(run.updated_at) - new Date(run.created_at);
              return sum + duration;
            }, 0) /
            runs.length /
            1000 /
            60
          : 0, // in minutes
    })
  );

  return {
    score: Math.min(100, healthScore),
    successRate: Math.round(successRate * 10) / 10,
    failureRate: Math.round(failureRate * 10) / 10,
    totalRuns,
    successfulRuns,
    failedRuns,
    cancelledRuns,
    workflowHealth: workflowHealth.sort(
      (a, b) => b.successRate - a.successRate
    ),
  };
}

/**
 * Generate predictive insights
 */
function generatePredictiveInsights(data) {
  const { completedIssues, openIssues } = data;

  // Predict sprint completion based on current ready queue and historical velocity
  const readyIssues = openIssues.filter((issue) =>
    issue.labels.some((label) => label.name === "ready")
  );

  const currentSprintIssues = openIssues.filter(
    (issue) => issue.milestone && issue.milestone.title.includes("Sprint-")
  );

  // Calculate historical completion time
  const completionTimes = completedIssues
    .filter((issue) => issue.created_at && issue.closed_at)
    .map((issue) => {
      const created = new Date(issue.created_at);
      const closed = new Date(issue.closed_at);
      return (closed - created) / (1000 * 60 * 60 * 24); // days
    });

  const avgCompletionTime =
    completionTimes.length > 0
      ? completionTimes.reduce((sum, time) => sum + time, 0) /
        completionTimes.length
      : 7;

  // Predict current sprint completion
  const sprintPrediction = {
    readyQueueSize: readyIssues.length,
    estimatedCompletionDays: Math.round(avgCompletionTime * readyIssues.length),
    currentSprintSize: currentSprintIssues.length,
    avgCompletionTime: Math.round(avgCompletionTime * 10) / 10,
  };

  // Capacity analysis
  const lastWeekCompleted = completedIssues.filter((issue) => {
    const closed = new Date(issue.closed_at);
    const weekAgo = new Date();
    weekAgo.setDate(weekAgo.getDate() - 7);
    return closed >= weekAgo;
  }).length;

  const capacityUtilization =
    readyIssues.length > 0 && lastWeekCompleted > 0
      ? Math.round((lastWeekCompleted / Math.max(readyIssues.length, 5)) * 100)
      : 0;

  return {
    sprint: sprintPrediction,
    capacity: {
      utilization: capacityUtilization,
      status:
        capacityUtilization > 80
          ? "High"
          : capacityUtilization > 50
          ? "Medium"
          : "Low",
      weeklyThroughput: lastWeekCompleted,
    },
    bottlenecks: identifyBottlenecks(data),
  };
}

/**
 * Analyze trends over time
 */
function analyzeTrends(data) {
  const { completedIssues } = data;

  // Group by week for trend analysis
  const weeklyData = groupBy(completedIssues, (issue) =>
    getISOWeek(new Date(issue.closed_at))
  );

  const sortedWeeks = Object.entries(weeklyData)
    .map(([week, issues]) => ({
      week,
      count: issues.length,
      points: issues.reduce((sum, issue) => sum + parseEstimate(issue), 0),
    }))
    .sort((a, b) => a.week.localeCompare(b.week));

  if (sortedWeeks.length < 2) {
    return {
      overall: "Insufficient data",
      direction: "stable",
      strength: "weak",
    };
  }

  // Calculate trend using simple linear regression
  const trend = calculateTrend(
    sortedWeeks.map((w, i) => ({ x: i, y: w.count }))
  );

  let direction, strength;
  if (Math.abs(trend.slope) < 0.1) {
    direction = "stable";
    strength = "weak";
  } else if (trend.slope > 0) {
    direction = "improving";
    strength = trend.slope > 0.5 ? "strong" : "moderate";
  } else {
    direction = "declining";
    strength = trend.slope < -0.5 ? "strong" : "moderate";
  }

  return {
    overall: `${direction} (${strength})`,
    direction,
    strength,
    slope: Math.round(trend.slope * 100) / 100,
    correlation: Math.round(trend.correlation * 100) / 100,
    weeklyData: sortedWeeks,
  };
}

/**
 * Generate actionable recommendations
 */
function generateRecommendations(data) {
  const recommendations = [];
  const { completedIssues, openIssues, workflows } = data;

  // Velocity recommendations
  const avgWeeklyIssues =
    completedIssues.length /
    Math.max(
      1,
      Math.ceil(
        (new Date() -
          new Date(
            Math.min(...completedIssues.map((i) => new Date(i.created_at)))
          )) /
          (7 * 24 * 60 * 60 * 1000)
      )
    );

  if (avgWeeklyIssues < 3) {
    recommendations.push({
      type: "velocity",
      priority: "high",
      title: "Low Weekly Velocity",
      description:
        "Consider increasing ready queue size or breaking down larger issues",
      action: "Review issue sizing and ready queue management",
    });
  }

  // Ready queue recommendations
  const readyCount = openIssues.filter((issue) =>
    issue.labels.some((label) => label.name === "ready")
  ).length;

  if (readyCount < 3) {
    recommendations.push({
      type: "queue",
      priority: "medium",
      title: "Low Ready Queue",
      description: "Ready queue below optimal size (5 issues)",
      action: "Add more prioritized issues to ready queue",
    });
  } else if (readyCount > 7) {
    recommendations.push({
      type: "queue",
      priority: "medium",
      title: "Oversized Ready Queue",
      description:
        "Ready queue above optimal size - may indicate capacity issues",
      action: "Review team capacity or issue complexity",
    });
  }

  // Workflow health recommendations
  const deltaWorkflows = workflows.filter((run) => run.name.includes("Delta"));
  const failureRate =
    deltaWorkflows.length > 0
      ? (deltaWorkflows.filter((run) => run.conclusion === "failure").length /
          deltaWorkflows.length) *
        100
      : 0;

  if (failureRate > 15) {
    recommendations.push({
      type: "health",
      priority: "high",
      title: "High Workflow Failure Rate",
      description: `${Math.round(failureRate)}% of workflows are failing`,
      action: "Review workflow logs and improve error handling",
    });
  }

  // Priority distribution recommendations
  const priorityDist = groupBy(completedIssues, (issue) => getPriority(issue));
  const p0Count = (priorityDist["P0-blocker"] || []).length;
  const totalCount = completedIssues.length;

  if (p0Count / totalCount > 0.2) {
    recommendations.push({
      type: "priority",
      priority: "medium",
      title: "High P0 Blocker Rate",
      description:
        "Over 20% of completed work was P0 blockers - may indicate reactive mode",
      action: "Consider more proactive planning and risk assessment",
    });
  }

  return recommendations;
}

/**
 * Identify potential risks
 */
function identifyRisks(data) {
  const risks = [];
  const { completedIssues, openIssues, workflows } = data;

  // Stale issues risk
  const staleIssues = openIssues.filter((issue) => {
    const daysSinceUpdate =
      (new Date() - new Date(issue.updated_at)) / (1000 * 60 * 60 * 24);
    return (
      daysSinceUpdate > 14 && !issue.labels.some((l) => l.name === "ready")
    );
  });

  if (staleIssues.length > 5) {
    risks.push({
      type: "stale_issues",
      severity: "medium",
      title: "Stale Issues Detected",
      description: `${staleIssues.length} issues haven't been updated in 14+ days`,
      impact: "May indicate blocked or abandoned work",
    });
  }

  // Workflow reliability risk
  const recentFailures = workflows
    .filter((run) => run.name.includes("Delta"))
    .filter((run) => {
      const daysSinceRun =
        (new Date() - new Date(run.created_at)) / (1000 * 60 * 60 * 24);
      return daysSinceRun <= 7 && run.conclusion === "failure";
    });

  if (recentFailures.length > 3) {
    risks.push({
      type: "workflow_instability",
      severity: "high",
      title: "Workflow Instability",
      description: `${recentFailures.length} workflow failures in the last 7 days`,
      impact: "Automation reliability at risk",
    });
  }

  // Velocity declining risk
  const recentWeeks = groupBy(
    completedIssues.filter((issue) => {
      const daysSinceClosed =
        (new Date() - new Date(issue.closed_at)) / (1000 * 60 * 60 * 24);
      return daysSinceClosed <= 21; // last 3 weeks
    }),
    (issue) => getISOWeek(new Date(issue.closed_at))
  );

  const weekCounts = Object.values(recentWeeks).map((issues) => issues.length);
  if (weekCounts.length >= 2) {
    const trend = calculateTrend(
      weekCounts.map((count, i) => ({ x: i, y: count }))
    );
    if (trend.slope < -0.5) {
      risks.push({
        type: "velocity_decline",
        severity: "medium",
        title: "Declining Velocity Trend",
        description: "Velocity has been decreasing over recent weeks",
        impact: "Sprint commitments may be at risk",
      });
    }
  }

  return risks;
}

/**
 * Identify bottlenecks in the system
 */
function identifyBottlenecks(data) {
  const { completedIssues, openIssues } = data;
  const bottlenecks = [];

  // Tool/area bottleneck analysis
  const toolDistribution = groupBy(
    completedIssues,
    (issue) => getToolAndArea(issue).tool
  );
  const areaDistribution = groupBy(
    completedIssues,
    (issue) => getToolAndArea(issue).area
  );

  // Check for overloaded tools
  const totalIssues = completedIssues.length;
  Object.entries(toolDistribution).forEach(([tool, issues]) => {
    const percentage = (issues.length / totalIssues) * 100;
    if (percentage > 40) {
      bottlenecks.push({
        type: "tool_overload",
        resource: tool,
        utilization: Math.round(percentage),
        description: `${tool} tool handling ${Math.round(
          percentage
        )}% of workload`,
      });
    }
  });

  return bottlenecks;
}

/**
 * Calculate standard deviation for consistency metrics
 */
function calculateStandardDeviation(values) {
  if (values.length <= 1) return 0;

  const mean = values.reduce((sum, val) => sum + val, 0) / values.length;
  const squaredDiffs = values.map((val) => Math.pow(val - mean, 2));
  const avgSquaredDiff =
    squaredDiffs.reduce((sum, val) => sum + val, 0) / squaredDiffs.length;

  return Math.sqrt(avgSquaredDiff);
}

/**
 * Calculate linear trend for time series data
 */
function calculateTrend(points) {
  if (points.length < 2) return { slope: 0, correlation: 0 };

  const n = points.length;
  const sumX = points.reduce((sum, p) => sum + p.x, 0);
  const sumY = points.reduce((sum, p) => sum + p.y, 0);
  const sumXY = points.reduce((sum, p) => sum + p.x * p.y, 0);
  const sumXX = points.reduce((sum, p) => sum + p.x * p.x, 0);
  const sumYY = points.reduce((sum, p) => sum + p.y * p.y, 0);

  const slope = (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX);

  // Calculate correlation coefficient
  const correlation =
    (n * sumXY - sumX * sumY) /
    Math.sqrt((n * sumXX - sumX * sumX) * (n * sumYY - sumY * sumY));

  return {
    slope: isNaN(slope) ? 0 : slope,
    correlation: isNaN(correlation) ? 0 : correlation,
  };
}

// CLI support
if (import.meta.url === `file://${process.argv[1]}`) {
  const args = process.argv.slice(2);
  const dryRun = args.includes("--dry-run");
  const lookbackDays =
    parseInt(args.find((arg) => arg.startsWith("--days="))?.split("=")[1]) ||
    60;

  try {
    const insights = await generateInsights({ lookbackDays, dryRun });

    if (!dryRun) {
      console.log(JSON.stringify(insights, null, 2));
    }
  } catch (error) {
    console.error("❌ Error generating insights:", error.message);
    process.exit(1);
  }
}

export { generateInsights };
export default generateInsights;
