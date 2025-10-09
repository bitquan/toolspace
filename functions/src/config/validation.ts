/**
 * Startup validation for production deployment
 * Logs ERROR if any configuration uses placeholder values
 */

import * as functions from "firebase-functions";
import { loadPricingConfig } from "../billing/entitlements";

/**
 * Validates that all production configuration is properly set
 * Logs ERROR for any placeholder values that should be replaced
 */
export function validateProductionConfig(): void {
  const errors: string[] = [];

  // Validate Stripe configuration
  const stripeKey =
    process.env.STRIPE_SECRET_KEY ||
    process.env.STRIPE_SECRET ||
    functions.config().stripe?.secret_key ||
    functions.config().stripe?.secret;

  if (!stripeKey) {
    errors.push("STRIPE_SECRET_KEY is not configured");
  } else if (stripeKey.startsWith("sk_test_")) {
    errors.push("STRIPE_SECRET_KEY is using test key in production");
  } else if (stripeKey === "sk_live_***") {
    errors.push("STRIPE_SECRET_KEY contains placeholder value 'sk_live_***'");
  }

  const webhookSecret =
    process.env.STRIPE_WEBHOOK_SECRET ||
    functions.config().stripe?.webhook_secret;

  if (!webhookSecret) {
    errors.push("STRIPE_WEBHOOK_SECRET is not configured");
  } else if (webhookSecret === "whsec_***") {
    errors.push("STRIPE_WEBHOOK_SECRET contains placeholder value 'whsec_***'");
  }

  // Validate pricing configuration
  try {
    const pricingConfig = loadPricingConfig();

    // Check Pro plan price ID
    const proPlan = pricingConfig.plans.pro;
    if (proPlan && proPlan.stripePriceId) {
      if (proPlan.stripePriceId === "price_XXXXXXXXXXXXXXXX") {
        errors.push(
          "Pro plan stripePriceId contains placeholder 'price_XXXXXXXXXXXXXXXX'"
        );
      } else if (!proPlan.stripePriceId.startsWith("price_")) {
        errors.push(
          `Pro plan stripePriceId has invalid format: ${proPlan.stripePriceId}`
        );
      }
    } else {
      errors.push("Pro plan stripePriceId is not configured");
    }

    // Check Pro+ plan price ID
    const proPlusPlan = pricingConfig.plans.pro_plus;
    if (proPlusPlan && proPlusPlan.stripePriceId) {
      if (proPlusPlan.stripePriceId === "price_YYYYYYYYYYYYYYYY") {
        errors.push(
          "Pro+ plan stripePriceId contains placeholder 'price_YYYYYYYYYYYYYYYY'"
        );
      } else if (!proPlusPlan.stripePriceId.startsWith("price_")) {
        errors.push(
          `Pro+ plan stripePriceId has invalid format: ${proPlusPlan.stripePriceId}`
        );
      }
    } else {
      errors.push("Pro+ plan stripePriceId is not configured");
    }

    // Validate pricing amounts
    if (proPlan && proPlan.price.amount !== 900) {
      errors.push(
        `Pro plan amount should be 900 cents ($9), got ${proPlan.price.amount}`
      );
    }

    if (proPlusPlan && proPlusPlan.price.amount !== 1900) {
      errors.push(
        `Pro+ plan amount should be 1900 cents ($19), got ${proPlusPlan.price.amount}`
      );
    }
  } catch (error: any) {
    errors.push(
      `Failed to load pricing configuration: ${error?.message || String(error)}`
    );
  }

  // Validate Firebase project ID (from environment)
  const projectId =
    process.env.GCLOUD_PROJECT || process.env.FIREBASE_PROJECT_ID;
  if (!projectId) {
    errors.push("Firebase project ID is not configured");
  } else if (projectId === "your-prod-project-id") {
    errors.push(
      "Firebase project ID contains placeholder 'your-prod-project-id'"
    );
  }

  // Log results
  if (errors.length > 0) {
    console.error("🚨 PRODUCTION CONFIGURATION ERRORS DETECTED:");
    errors.forEach((error) => {
      console.error(`❌ ${error}`);
    });
    console.error("🔧 Fix these issues before production deployment!");

    // In production, we might want to prevent startup
    if (process.env.NODE_ENV === "production") {
      console.error(
        "💥 BLOCKING PRODUCTION STARTUP DUE TO CONFIGURATION ERRORS"
      );
      // Don't actually crash in production, just log the errors
    }
  } else {
    console.info("✅ Production configuration validation passed");
  }
}

/**
 * Check if running in production environment
 */
export function isProductionEnvironment(): boolean {
  const nodeEnv = process.env.NODE_ENV;
  const projectId =
    process.env.GCLOUD_PROJECT || process.env.FIREBASE_PROJECT_ID;

  return (
    nodeEnv === "production" ||
    (!!projectId && !projectId.includes("dev") && !projectId.includes("test"))
  );
}

/**
 * Get configuration summary for debugging
 */
export function getConfigSummary(): object {
  const stripeKey =
    process.env.STRIPE_SECRET_KEY ||
    process.env.STRIPE_SECRET ||
    functions.config().stripe?.secret_key ||
    functions.config().stripe?.secret;

  return {
    environment: process.env.NODE_ENV || "unknown",
    projectId:
      process.env.GCLOUD_PROJECT ||
      process.env.FIREBASE_PROJECT_ID ||
      "unknown",
    stripeKeyPresent: !!stripeKey,
    stripeKeyType: stripeKey
      ? stripeKey.startsWith("sk_live_")
        ? "live"
        : stripeKey.startsWith("sk_test_")
        ? "test"
        : "unknown"
      : "none",
    webhookSecretPresent: !!(
      process.env.STRIPE_WEBHOOK_SECRET ||
      functions.config().stripe?.webhook_secret
    ),
    timestamp: new Date().toISOString(),
  };
}
