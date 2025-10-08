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

import * as admin from "firebase-admin";
import * as functions from "firebase-functions/v1";
import Stripe from "stripe";
import {
  BillingEvent,
  BillingProfile,
  StripeWebhookEventType,
} from "../types/billing";
import { loadPricingConfig } from "./entitlements";

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

export const webhook = functions.https.onRequest(async (req, res) => {
  const sig = req.headers["stripe-signature"];

  if (!sig) {
    functions.logger.error("No stripe-signature header");
    res.status(400).send("Missing signature");
    return;
  }

  let event: Stripe.Event;

  try {
    event = stripe.webhooks.constructEvent(req.rawBody, sig, webhookSecret);
  } catch (err: any) {
    functions.logger.error("Webhook signature verification failed", {
      error: err.message,
    });
    res.status(400).send(`Webhook Error: ${err.message}`);
    return;
  }

  functions.logger.info("Webhook received", {
    type: event.type,
    id: event.id,
  });

  try {
    // Route to appropriate handler
    switch (event.type) {
      case "checkout.session.completed":
        await handleCheckoutCompleted(event);
        break;

      case "customer.subscription.created":
      case "customer.subscription.updated":
        await handleSubscriptionUpdated(event);
        break;

      case "customer.subscription.deleted":
        await handleSubscriptionDeleted(event);
        break;

      case "invoice.paid":
        await handleInvoicePaid(event);
        break;

      case "invoice.payment_failed":
        await handleInvoicePaymentFailed(event);
        break;

      default:
        functions.logger.info("Unhandled event type", { type: event.type });
    }

    res.json({ received: true });
  } catch (error: any) {
    functions.logger.error("Webhook processing failed", {
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
      metadata: { error: error.message },
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
  const userId = session.metadata?.userId;
  const planId = session.metadata?.planId;
  const customerId = session.customer as string;

  if (!userId || !planId) {
    functions.logger.error("Missing metadata in checkout session", {
      sessionId: session.id,
    });
    return;
  }

  functions.logger.info("Processing checkout completion", {
    userId,
    planId,
    customerId,
    sessionId: session.id,
  });

  // Subscription will be updated via subscription.created event
  // Just log the event for audit
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
  const userId = subscription.metadata?.userId;
  const planId = subscription.metadata?.planId;
  const customerId = subscription.customer as string;

  if (!userId) {
    functions.logger.error("Missing userId in subscription metadata", {
      subscriptionId: subscription.id,
    });
    return;
  }

  // Validate plan
  const config = loadPricingConfig();
  const validPlan = planId && ["pro", "pro_plus"].includes(planId);

  if (!validPlan) {
    functions.logger.warn("Invalid plan ID in subscription", {
      userId,
      planId,
      subscriptionId: subscription.id,
    });
  }

  const db = admin.firestore();
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

  await billingRef.set(updatedProfile, { merge: true });

  functions.logger.info("Subscription updated", {
    userId,
    planId,
    status: subscription.status,
    subscriptionId: subscription.id,
  });

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
  const userId = subscription.metadata?.userId;
  const customerId = subscription.customer as string;

  if (!userId) {
    functions.logger.error("Missing userId in subscription metadata", {
      subscriptionId: subscription.id,
    });
    return;
  }

  const db = admin.firestore();
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
  const db = admin.firestore();
  await db
    .collection("ops")
    .doc("billing_events")
    .collection("events")
    .doc(event.eventId)
    .set(event);
}
