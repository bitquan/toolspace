/**
 * Stripe webhook handler for subscription lifecycle events.
 *
 * Endpoint: POST /api/billing/webhook
 * No auth - uses Stripe signature verification
 *
 * Handles:
 * - checkout.session.completed
 * - customer.subscription.created/updated/deleted
 * - invoice.paid/payment_failed
 */

import * as functions from "firebase-functions/v1";
import Stripe from "stripe";
import { db } from "../admin";
import {
  BillingEvent,
  BillingProfile,
  StripeWebhookEventType,
} from "../types/billing";

// Environment detection
const isStaging =
  process.env.FIREBASE_CONFIG?.includes("toolz-space-staging") ||
  process.env.FIREBASE_PROJECT_ID === "toolz-space-staging";

const stripe = new Stripe(
  process.env.STRIPE_SECRET_KEY ||
    process.env.STRIPE_SECRET ||
    functions.config().stripe?.secret_key ||
    functions.config().stripe?.secret ||
    "",
  {
    apiVersion: "2025-09-30.clover",
  }
);

const webhookSecret =
  process.env.STRIPE_WEBHOOK_SECRET ||
  functions.config().stripe?.webhook_secret ||
  "";

// Log environment on cold start
console.log(
  `🔧 Stripe webhook initialized: ${isStaging ? "STAGING" : "PRODUCTION"} mode`
);
console.log(`🔑 Using ${isStaging ? "TEST" : "LIVE"} Stripe keys`);
console.log(`🪝 Webhook secret configured: ${webhookSecret ? "YES" : "NO"}`);

export const stripeWebhook = functions.https.onRequest(async (req, res) => {
  // Log request details for staging debugging
  if (isStaging) {
    console.log("🧪 STAGING: Webhook request received");
    console.log("📝 Headers:", JSON.stringify(req.headers, null, 2));
  }

  const sig = req.headers["stripe-signature"];

  if (!sig) {
    functions.logger.error("No stripe-signature header");
    res.status(400).send("Missing signature");
    return;
  }

  // Get the raw body - Firebase Functions provides this differently
  let body: string | Buffer;
  if (req.rawBody) {
    body = req.rawBody;
  } else if (typeof req.body === "string") {
    body = req.body;
  } else {
    body = JSON.stringify(req.body);
  }

  if (isStaging) {
    console.log("🧪 STAGING: Webhook signature verification");
    console.log("🔍 Body type:", typeof body);
    console.log("📏 Body length:", body.length);
    console.log("🔑 Webhook secret present:", !!webhookSecret);
  }

  functions.logger.info("Webhook signature verification attempt", {
    environment: isStaging ? "staging" : "production",
    hasSignature: !!sig,
    hasWebhookSecret: !!webhookSecret,
    bodyType: typeof body,
    bodyLength: body.length,
    webhookSecretLength: webhookSecret.length,
    signaturePreview:
      typeof sig === "string"
        ? sig.substring(0, 20) + "..."
        : Array.isArray(sig)
        ? sig[0]?.substring(0, 20) + "..."
        : "unknown",
  });

  let event: Stripe.Event;

  try {
    // Ensure signature is a string
    const signature =
      typeof sig === "string" ? sig : Array.isArray(sig) ? sig[0] : "";

    if (isStaging) {
      console.log("🧪 STAGING: Constructing webhook event");
      console.log("✅ Signature length:", signature.length);
      console.log(
        "✅ Using webhook secret:",
        webhookSecret.substring(0, 10) + "..."
      );
    }

    functions.logger.info("Attempting webhook construction", {
      environment: isStaging ? "staging" : "production",
      signatureLength: signature.length,
      bodyLength: body.length,
      webhookSecretPresent: !!webhookSecret,
    });

    event = stripe.webhooks.constructEvent(body, signature, webhookSecret);

    if (isStaging) {
      console.log("✅ STAGING: Webhook event constructed successfully");
      console.log("🎯 Event type:", event.type);
      console.log("🆔 Event ID:", event.id);
    }

    functions.logger.info("Webhook signature verification successful", {
      environment: isStaging ? "staging" : "production",
      eventType: event.type,
      eventId: event.id,
    });
  } catch (err: any) {
    if (isStaging) {
      console.error("❌ STAGING: Webhook signature verification failed");
      console.error("🚨 Error:", err.message);
      console.error("🔍 Debug info:", {
        hasSignature: !!sig,
        hasWebhookSecret: !!webhookSecret,
        webhookSecretPreview: webhookSecret.substring(0, 10) + "...",
      });
    }

    functions.logger.error("Webhook signature verification failed", {
      environment: isStaging ? "staging" : "production",
      error: err.message,
      hasSignature: !!sig,
      hasWebhookSecret: !!webhookSecret,
      webhookSecretPreview:
        webhookSecret.length > 10
          ? webhookSecret.substring(0, 10) + "..."
          : webhookSecret,
    });
    res.status(400).send(`Webhook Error: ${err.message}`);
    return;
  }

  if (isStaging) {
    console.log("🎉 STAGING: Processing webhook event");
    console.log("📋 Event details:", {
      type: event.type,
      id: event.id,
      livemode: event.livemode,
      created: new Date(event.created * 1000).toISOString(),
    });
  }

  functions.logger.info("Webhook received", {
    environment: isStaging ? "staging" : "production",
    type: event.type,
    id: event.id,
    livemode: event.livemode,
  });

  try {
    // Route to appropriate handler
    switch (event.type) {
      case "checkout.session.completed":
        if (isStaging)
          console.log("🛒 STAGING: Handling checkout.session.completed");
        await handleCheckoutCompleted(event);
        break;

      case "customer.subscription.created":
      case "customer.subscription.updated":
        if (isStaging)
          console.log("📋 STAGING: Handling subscription event:", event.type);
        await handleSubscriptionUpdated(event);
        break;

      case "customer.subscription.deleted":
        if (isStaging) console.log("🗑️ STAGING: Handling subscription.deleted");
        await handleSubscriptionDeleted(event);
        break;

      case "invoice.paid":
        if (isStaging) console.log("💰 STAGING: Handling invoice.paid");
        await handleInvoicePaid(event);
        break;

      case "invoice.payment_failed":
        if (isStaging)
          console.log("💸 STAGING: Handling invoice.payment_failed");
        await handleInvoicePaymentFailed(event);
        break;

      default:
        if (isStaging) {
          console.log("❓ STAGING: Unhandled event type:", event.type);
        }
        functions.logger.info("Unhandled event type", {
          environment: isStaging ? "staging" : "production",
          type: event.type,
        });
    }

    if (isStaging) {
      console.log("✅ STAGING: Webhook processing completed successfully");
    }

    res.json({ received: true });
  } catch (error: any) {
    if (isStaging) {
      console.error("💥 STAGING: Webhook processing error");
      console.error("🚨 Error details:", {
        message: error.message,
        stack: error.stack,
        eventType: event.type,
        eventId: event.id,
      });
    }
    functions.logger.error("Webhook processing failed", {
      environment: isStaging ? "staging" : "production",
      type: event.type,
      id: event.id,
      error: error.message,
    });

    // Log to audit trail
    await logBillingEvent({
      eventId: event.id,
      type: event.type as StripeWebhookEventType,
      userId: null,
      customerId: null,
      subscriptionId: null,
      planId: null,
      status: null,
      timestamp: Date.now(),
      metadata: {
        error: error.message,
        environment: isStaging ? "staging" : "production",
      },
      processed: false,
      error: error.message,
    });

    res.status(500).send("Webhook processing failed");
  }
});

/**
 * Handle checkout.session.completed
 */
async function handleCheckoutCompleted(event: Stripe.Event) {
  const session = event.data.object as Stripe.Checkout.Session;

  // Try multiple ways to get the Firebase UID for robustness
  const userId =
    session.metadata?.userId ||
    session.metadata?.firebaseUid ||
    session.client_reference_id;

  const planId = session.metadata?.planId;
  const customerId = session.customer as string;

  if (!userId) {
    functions.logger.error("No Firebase UID found in checkout session", {
      sessionId: session.id,
      metadata: session.metadata,
      clientReferenceId: session.client_reference_id,
    });
    return;
  }

  if (!planId) {
    functions.logger.error("Missing planId in checkout session metadata", {
      sessionId: session.id,
      userId,
    });
    return;
  }

  functions.logger.info("Processing checkout completion", {
    userId,
    planId,
    customerId,
    sessionId: session.id,
    sessionMetadata: session.metadata,
    clientReferenceId: session.client_reference_id,
    allMetadataKeys: Object.keys(session.metadata || {}),
    source: session.metadata?.userId
      ? "metadata.userId"
      : session.metadata?.firebaseUid
      ? "metadata.firebaseUid"
      : "client_reference_id",
  });

  // Update customer metadata if not already set
  if (customerId) {
    try {
      const customer = await stripe.customers.retrieve(customerId);
      if (
        !customer.deleted &&
        (!customer.metadata?.firebaseUserId || !customer.metadata?.uid)
      ) {
        await stripe.customers.update(customerId, {
          metadata: {
            ...customer.metadata,
            firebaseUserId: userId,
            uid: userId,
            updated_by: "checkout_completion_webhook",
          },
        });

        functions.logger.info("Updated customer metadata with Firebase UID", {
          customerId,
          userId,
        });
      }
    } catch (error) {
      functions.logger.warn("Failed to update customer metadata", {
        customerId,
        userId,
        error: (error as Error).message,
      });
    }
  }

  // Subscription will be updated via subscription.created event
  // But also update billing profile directly as fallback in case subscription webhook fails
  try {
    const billingRef = db.doc(`users/${userId}/billing/profile`);
    const now = Date.now();

    const fallbackProfile = {
      stripeCustomerId: customerId,
      planId: planId as "pro" | "pro_plus",
      status: "active" as const,
      currentPeriodStart: now,
      currentPeriodEnd: now + 30 * 24 * 60 * 60 * 1000, // 30 days
      trialEnd: null,
      cancelAtPeriodEnd: false,
      createdAt: now,
      updatedAt: now,
    };

    await billingRef.set(fallbackProfile, { merge: true });

    functions.logger.info(
      "Updated billing profile from checkout completion (fallback)",
      {
        userId,
        planId,
        customerId,
        sessionId: session.id,
      }
    );
  } catch (error) {
    functions.logger.error(
      "Failed to update billing profile from checkout completion",
      {
        userId,
        planId,
        customerId,
        sessionId: session.id,
        error: (error as Error).message,
      }
    );
  }

  // Log the event for audit
  await logBillingEvent({
    eventId: event.id,
    type: "checkout.session.completed",
    userId,
    customerId,
    subscriptionId: session.subscription as string,
    planId,
    status: session.status,
    timestamp: Date.now(),
    metadata: { sessionId: session.id },
    processed: true,
  });
}

/**
 * Handle subscription created/updated
 */
async function handleSubscriptionUpdated(event: Stripe.Event) {
  const subscription = event.data.object as Stripe.Subscription;

  // Try multiple ways to get the Firebase UID for robustness
  let userId =
    subscription.metadata?.userId || subscription.metadata?.firebaseUid;

  functions.logger.info(
    "Processing subscription update - initial metadata check",
    {
      subscriptionId: subscription.id,
      subscriptionMetadata: subscription.metadata,
      foundUserId: userId,
      allMetadataKeys: Object.keys(subscription.metadata || {}),
    }
  );

  // If not in subscription metadata, check customer metadata
  if (!userId && subscription.customer) {
    try {
      const customer = await stripe.customers.retrieve(
        subscription.customer as string
      );
      if (!customer.deleted) {
        userId = customer.metadata?.firebaseUserId || customer.metadata?.uid;
        functions.logger.info("Resolved userId from customer metadata", {
          customerId: subscription.customer,
          customerMetadata: customer.metadata,
          resolvedUserId: userId,
        });
      }
    } catch (error) {
      functions.logger.warn("Failed to retrieve customer for subscription", {
        subscriptionId: subscription.id,
        customerId: subscription.customer,
        error: (error as Error).message,
      });
    }
  }

  const planId = subscription.metadata?.planId;
  const customerId = subscription.customer as string;

  if (!userId) {
    functions.logger.error("No Firebase UID found for subscription", {
      subscriptionId: subscription.id,
      customerId: subscription.customer,
      subscriptionMetadata: subscription.metadata,
    });
    return;
  }

  // Validate plan
  const validPlan = planId && ["pro", "pro_plus"].includes(planId);

  if (!validPlan) {
    functions.logger.warn("Invalid plan ID in subscription", {
      userId,
      planId,
      subscriptionId: subscription.id,
    });
  }

  const billingRef = db.doc(`users/${userId}/billing/profile`);

  const updatedProfile: Partial<BillingProfile> = {
    stripeCustomerId: customerId,
    planId: validPlan ? (planId as "pro" | "pro_plus") : "free",
    status: mapStripeStatus(subscription.status),
    currentPeriodStart: (subscription as any).current_period_start * 1000,
    currentPeriodEnd: (subscription as any).current_period_end * 1000,
    trialEnd: (subscription as any).trial_end
      ? (subscription as any).trial_end * 1000
      : null,
    cancelAtPeriodEnd: (subscription as any).cancel_at_period_end,
    updatedAt: Date.now(),
  };

  try {
    await billingRef.set(updatedProfile, { merge: true });

    functions.logger.info("Subscription updated successfully", {
      userId,
      planId,
      validPlan,
      finalPlanId: updatedProfile.planId,
      status: subscription.status,
      subscriptionId: subscription.id,
      firestorePath: `users/${userId}/billing/profile`,
      updatedProfile,
      source: subscription.metadata?.userId
        ? "subscription.metadata.userId"
        : subscription.metadata?.firebaseUid
        ? "subscription.metadata.firebaseUid"
        : "customer.metadata",
    });
  } catch (error) {
    functions.logger.error("Failed to update billing profile", {
      userId,
      planId,
      subscriptionId: subscription.id,
      firestorePath: `users/${userId}/billing/profile`,
      error: (error as Error).message,
      updatedProfile,
    });
    throw error; // Re-throw to cause 500 response for retry
  }

  await logBillingEvent({
    eventId: event.id,
    type: event.type as StripeWebhookEventType,
    userId,
    customerId,
    subscriptionId: subscription.id,
    planId,
    status: subscription.status,
    timestamp: Date.now(),
    metadata: { subscriptionId: subscription.id },
    processed: true,
  });
}

/**
 * Handle subscription deleted (cancellation)
 */
async function handleSubscriptionDeleted(event: Stripe.Event) {
  const subscription = event.data.object as Stripe.Subscription;

  // Try multiple ways to get the Firebase UID for robustness
  let userId =
    subscription.metadata?.userId || subscription.metadata?.firebaseUid;

  // If not in subscription metadata, check customer metadata
  if (!userId && subscription.customer) {
    try {
      const customer = await stripe.customers.retrieve(
        subscription.customer as string
      );
      if (!customer.deleted) {
        userId = customer.metadata?.firebaseUserId || customer.metadata?.uid;
      }
    } catch (error) {
      functions.logger.warn(
        "Failed to retrieve customer for subscription deletion",
        {
          subscriptionId: subscription.id,
          customerId: subscription.customer,
          error: (error as Error).message,
        }
      );
    }
  }

  const customerId = subscription.customer as string;

  if (!userId) {
    functions.logger.error("No Firebase UID found for subscription deletion", {
      subscriptionId: subscription.id,
      customerId: subscription.customer,
      subscriptionMetadata: subscription.metadata,
    });
    return;
  }

  const billingRef = db.doc(`users/${userId}/billing/profile`);

  // Downgrade to free plan
  const updatedProfile: Partial<BillingProfile> = {
    planId: "free",
    status: "canceled",
    cancelAtPeriodEnd: false,
    updatedAt: Date.now(),
  };

  await billingRef.set(updatedProfile, { merge: true });

  functions.logger.info("Subscription canceled, downgraded to free", {
    userId,
    subscriptionId: subscription.id,
    source: subscription.metadata?.userId
      ? "subscription.metadata.userId"
      : subscription.metadata?.firebaseUid
      ? "subscription.metadata.firebaseUid"
      : "customer.metadata",
  });

  await logBillingEvent({
    eventId: event.id,
    type: "customer.subscription.deleted",
    userId,
    customerId,
    subscriptionId: subscription.id,
    planId: "free",
    status: "canceled",
    timestamp: Date.now(),
    metadata: { subscriptionId: subscription.id },
    processed: true,
  });
}

/**
 * Handle successful invoice payment
 */
async function handleInvoicePaid(event: Stripe.Event) {
  const invoice = event.data.object as any;
  const customerId = invoice.customer as string;
  const subscriptionId = invoice.subscription as string;

  functions.logger.info("Invoice paid", {
    customerId,
    subscriptionId,
    invoiceId: invoice.id,
    amount: invoice.amount_paid,
  });

  // Update is handled by subscription.updated event
  // Just log for audit
  try {
    await logBillingEvent({
      eventId: event.id,
      type: "invoice.paid",
      userId: null, // Will be resolved via customerId
      customerId,
      subscriptionId,
      planId: null,
      status: "paid",
      timestamp: Date.now(),
      metadata: {
        invoiceId: invoice.id,
        amount: invoice.amount_paid,
        currency: invoice.currency,
      },
      processed: true,
    });
  } catch (error) {
    functions.logger.error("Failed to log invoice.paid event", {
      eventId: event.id,
      customerId,
      subscriptionId,
      error: (error as Error).message,
    });
    // Don't throw - invoice.paid is for audit logging only
  }
}

/**
 * Handle failed invoice payment
 */
async function handleInvoicePaymentFailed(event: Stripe.Event) {
  const invoice = event.data.object as any;
  const customerId = invoice.customer as string;
  const subscriptionId = invoice.subscription as string;

  functions.logger.error("Invoice payment failed", {
    customerId,
    subscriptionId,
    invoiceId: invoice.id,
    attemptCount: invoice.attempt_count,
  });

  // Stripe will update subscription status automatically
  // We'll catch it in subscription.updated event
  await logBillingEvent({
    eventId: event.id,
    type: "invoice.payment_failed",
    userId: null,
    customerId,
    subscriptionId,
    planId: null,
    status: "payment_failed",
    timestamp: Date.now(),
    metadata: {
      invoiceId: invoice.id,
      attemptCount: invoice.attempt_count,
    },
    processed: true,
  });
}

/**
 * Map Stripe subscription status to our status type
 */
function mapStripeStatus(
  stripeStatus: Stripe.Subscription.Status
): BillingProfile["status"] {
  switch (stripeStatus) {
    case "active":
      return "active";
    case "trialing":
      return "trialing";
    case "past_due":
      return "past_due";
    case "canceled":
      return "canceled";
    case "unpaid":
      return "unpaid";
    case "incomplete":
      return "incomplete";
    case "incomplete_expired":
      return "incomplete_expired";
    default:
      return "free";
  }
}

/**
 * Log billing event to audit trail
 */
async function logBillingEvent(event: BillingEvent) {
  await db
    .collection("ops")
    .doc("billing_events")
    .collection("events")
    .doc(event.eventId)
    .set(event);
}
