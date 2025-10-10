/**
 * Entitlements resolver - pure functions to check plan permissions.
 *
 * Used by both frontend and backend to enforce consistent limits.
 */

import * as fs from "fs";
import * as path from "path";
import {
  PricingConfig,
  Plan,
  Entitlements,
  BillingProfile,
  UsageRecord,
  EntitlementCheckResult,
} from "../types/billing";

let cachedPricingConfig: PricingConfig | null = null;

/**
 * Load pricing config from config/pricing.json
 */
export function loadPricingConfig(): PricingConfig {
  if (cachedPricingConfig) {
    return cachedPricingConfig;
  }

  const configPath = path.resolve(__dirname, "../config/pricing.json");
  const configData = fs.readFileSync(configPath, "utf8");
  cachedPricingConfig = JSON.parse(configData) as PricingConfig;
  return cachedPricingConfig;
}

/**
 * Get plan by ID
 */
export function getPlan(planId: string): Plan | null {
  const config = loadPricingConfig();
  return config.plans[planId as keyof typeof config.plans] || null;
}

/**
 * Get entitlements for a plan
 */
export function getEntitlements(planId: string): Entitlements {
  const plan = getPlan(planId);
  if (!plan) {
    // Default to free plan
    return loadPricingConfig().plans.free.entitlements;
  }
  return plan.entitlements;
}

/**
 * Check if user can perform a heavy operation today
 */
export function canPerformHeavyOp(
  billingProfile: BillingProfile,
  usage: UsageRecord | null
): EntitlementCheckResult {
  const entitlements = getEntitlements(billingProfile.planId);
  const currentUsage = usage?.heavyOps || 0;
  const limit = entitlements.heavyOpsPerDay;

  if (currentUsage >= limit) {
    return {
      allowed: false,
      reason: "Daily heavy operation limit reached",
      currentUsage,
      limit,
      planId: billingProfile.planId,
      requiresUpgrade: billingProfile.planId === "free",
      suggestedPlan: billingProfile.planId === "free" ? "pro" : "pro_plus",
    };
  }

  return {
    allowed: true,
    currentUsage,
    limit,
    planId: billingProfile.planId,
  };
}

/**
 * Check if file size is within plan limits
 */
export function canProcessFileSize(
  billingProfile: BillingProfile,
  fileSize: number
): EntitlementCheckResult {
  const entitlements = getEntitlements(billingProfile.planId);
  const maxSize = entitlements.maxFileSize;

  if (fileSize > maxSize) {
    return {
      allowed: false,
      reason: `File size exceeds ${formatBytes(maxSize)} limit`,
      currentUsage: fileSize,
      limit: maxSize,
      planId: billingProfile.planId,
      requiresUpgrade: true,
      suggestedPlan: getSuggestedPlanForFileSize(fileSize),
    };
  }

  return {
    allowed: true,
    currentUsage: fileSize,
    limit: maxSize,
    planId: billingProfile.planId,
  };
}

/**
 * Check if batch size is within plan limits
 */
export function canProcessBatchSize(
  billingProfile: BillingProfile,
  batchSize: number
): EntitlementCheckResult {
  const entitlements = getEntitlements(billingProfile.planId);
  const maxBatch = entitlements.maxBatchSize;

  if (batchSize > maxBatch) {
    return {
      allowed: false,
      reason: `Batch size exceeds ${maxBatch} items limit`,
      currentUsage: batchSize,
      limit: maxBatch,
      planId: billingProfile.planId,
      requiresUpgrade: true,
      suggestedPlan: getSuggestedPlanForBatchSize(batchSize),
    };
  }

  return {
    allowed: true,
    currentUsage: batchSize,
    limit: maxBatch,
    planId: billingProfile.planId,
  };
}

/**
 * Check if user can access a specific tool
 */
export function canAccessTool(
  billingProfile: BillingProfile,
  toolId: string
): EntitlementCheckResult {
  const config = loadPricingConfig();
  const tool = config.tools[toolId];

  if (!tool) {
    return {
      allowed: false,
      reason: "Tool not found",
    };
  }

  const plan = getPlan(billingProfile.planId);
  if (!plan) {
    return {
      allowed: false,
      reason: "Invalid plan",
    };
  }

  // Check if tool is in restricted list
  if (
    plan.restrictions.heavyTools.includes(toolId) &&
    plan.restrictions.requiresUpgrade
  ) {
    return {
      allowed: false,
      reason: `${tool.name} requires ${tool.minPlan} plan or higher`,
      planId: billingProfile.planId,
      requiresUpgrade: true,
      suggestedPlan: tool.minPlan,
    };
  }

  return {
    allowed: true,
    planId: billingProfile.planId,
  };
}

/**
 * Check if subscription is active
 */
export function isSubscriptionActive(billingProfile: BillingProfile): boolean {
  const now = Date.now();

  // Free plan is always "active"
  if (billingProfile.planId === "free") {
    return true;
  }

  // Check status
  if (!["active", "trialing"].includes(billingProfile.status)) {
    return false;
  }

  // Check period end (with grace period)
  if (billingProfile.currentPeriodEnd) {
    const config = loadPricingConfig();
    const gracePeriodMs = config.metadata.gracePeriodDays * 24 * 60 * 60 * 1000;
    const expiresAt = billingProfile.currentPeriodEnd + gracePeriodMs;

    if (now > expiresAt) {
      return false;
    }
  }

  return true;
}

/**
 * Get suggested plan based on file size
 */
function getSuggestedPlanForFileSize(fileSize: number): string {
  const config = loadPricingConfig();

  if (fileSize <= config.plans.pro.entitlements.maxFileSize) {
    return "pro";
  }

  return "pro_plus";
}

/**
 * Get suggested plan based on batch size
 */
function getSuggestedPlanForBatchSize(batchSize: number): string {
  const config = loadPricingConfig();

  if (batchSize <= config.plans.pro.entitlements.maxBatchSize) {
    return "pro";
  }

  return "pro_plus";
}

/**
 * Format bytes to human-readable string
 */
function formatBytes(bytes: number): string {
  if (bytes === 0) return "0 Bytes";

  const k = 1024;
  const sizes = ["Bytes", "KB", "MB", "GB"];
  const i = Math.floor(Math.log(bytes) / Math.log(k));

  return Math.round((bytes / Math.pow(k, i)) * 100) / 100 + " " + sizes[i];
}

/**
 * Get today's date in yyyy-mm-dd format
 */
export function getTodayDateString(): string {
  const now = new Date();
  const year = now.getFullYear();
  const month = String(now.getMonth() + 1).padStart(2, "0");
  const day = String(now.getDate()).padStart(2, "0");
  return `${year}-${month}-${day}`;
}
