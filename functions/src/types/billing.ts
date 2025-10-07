/**
 * Billing and subscription types for Toolspace monetization.
 *
 * Covers Stripe integration, plan entitlements, usage tracking,
 * and webhook event handling.
 */

export interface PricingConfig {
  version: string;
  lastUpdated: string;
  plans: {
    free: Plan;
    pro: Plan;
    pro_plus: Plan;
  };
  tools: Record<string, ToolMetadata>;
  metadata: BillingMetadata;
}

export interface Plan {
  id: string;
  name: string;
  displayName: string;
  description: string;
  price: {
    amount: number; // in cents
    currency: string;
    interval: "month" | "year" | null;
  };
  stripePriceId: string | null;
  stripeProductId: string | null;
  popular?: boolean;
  features: string[];
  entitlements: Entitlements;
  restrictions: {
    heavyTools: string[];
    requiresUpgrade: boolean;
  };
}

export interface Entitlements {
  heavyOpsPerDay: number;
  lightOpsPerDay: number;
  maxFileSize: number; // bytes
  maxBatchSize: number;
  priorityQueue: boolean;
  supportLevel: "community" | "email" | "priority";
  canExportBatch: boolean;
  advancedFeatures: boolean;
}

export interface ToolMetadata {
  name: string;
  category: "light" | "heavy";
  minPlan: "free" | "pro" | "pro_plus";
  description: string;
}

export interface BillingMetadata {
  trialDays: number;
  gracePeriodDays: number;
  defaultPlan: string;
  currencySymbol: string;
  billingPortalUrl: string;
  supportEmail: string;
}

/**
 * Firestore document: users/{uid}/billing/profile
 */
export interface BillingProfile {
  stripeCustomerId: string | null;
  planId: "free" | "pro" | "pro_plus";
  status: SubscriptionStatus;
  currentPeriodStart: number | null; // unix timestamp
  currentPeriodEnd: number | null;
  trialEnd: number | null;
  cancelAtPeriodEnd: boolean;
  createdAt: number;
  updatedAt: number;
}

export type SubscriptionStatus =
  | "active"
  | "trialing"
  | "past_due"
  | "canceled"
  | "unpaid"
  | "incomplete"
  | "incomplete_expired"
  | "free";

/**
 * Firestore document: users/{uid}/usage/{yyyy-mm-dd}
 */
export interface UsageRecord {
  date: string; // yyyy-mm-dd
  heavyOps: number;
  lightOps: number;
  filesProcessed: number;
  bytesProcessed: number;
  lastUpdated: number; // unix timestamp
}

/**
 * Request body for createCheckoutSession
 */
export interface CreateCheckoutSessionRequest {
  planId: "pro" | "pro_plus";
  successUrl: string;
  cancelUrl: string;
}

/**
 * Response from createCheckoutSession
 */
export interface CreateCheckoutSessionResponse {
  sessionId: string;
  url: string;
}

/**
 * Response from createPortalLink
 */
export interface CreatePortalLinkResponse {
  url: string;
}

/**
 * Stripe webhook event types we handle
 */
export type StripeWebhookEventType =
  | "checkout.session.completed"
  | "customer.subscription.created"
  | "customer.subscription.updated"
  | "customer.subscription.deleted"
  | "invoice.paid"
  | "invoice.payment_failed";

/**
 * Audit log for billing events
 * Stored in: ops/billing_events/{eventId}
 */
export interface BillingEvent {
  eventId: string;
  type: StripeWebhookEventType | "manual_upgrade" | "manual_downgrade";
  userId: string | null;
  customerId: string | null;
  subscriptionId: string | null;
  planId: string | null;
  status: string | null;
  timestamp: number;
  metadata: Record<string, any>;
  processed: boolean;
  error?: string;
}

/**
 * Result of entitlement check
 */
export interface EntitlementCheckResult {
  allowed: boolean;
  reason?: string;
  currentUsage?: number;
  limit?: number;
  planId?: string;
  requiresUpgrade?: boolean;
  suggestedPlan?: string;
}
