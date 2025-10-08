// @ts-nocheck
/**
 * Create Stripe Checkout Session for plan upgrades.
 *
 * Endpoint: POST /api/billing/createCheckoutSession
 * Auth: Requires authenticated user
 */

import * as admin from "firebase-admin";
import * as functions from "firebase-functions/v1";
import Stripe from "stripe";
import {
  BillingProfile,
  CreateCheckoutSessionRequest,
  CreateCheckoutSessionResponse,
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

export const createCheckoutSession = functions.https.onCall(
  async (
    data: CreateCheckoutSessionRequest,
    context
  ): Promise<CreateCheckoutSessionResponse> => {
    // Require authentication
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Must be logged in"
      );
    }

    const userId = context.auth.uid;
    const { planId, successUrl, cancelUrl } = data;

    // Validate plan
    if (!planId || !["pro", "pro_plus"].includes(planId)) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Invalid plan ID"
      );
    }

    // Validate URLs
    if (!successUrl || !cancelUrl) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Missing success or cancel URL"
      );
    }

    try {
      const config = loadPricingConfig();
      const plan = config.plans[planId as keyof typeof config.plans];

      if (!plan || !plan.stripePriceId) {
        throw new functions.https.HttpsError(
          "not-found",
          "Plan not found or not configured"
        );
      }

      // Get or create Stripe customer
      const db = admin.firestore();
      const billingRef = db.doc(`users/${userId}/billing/profile`);
      const billingDoc = await billingRef.get();

      let customerId: string;

      if (billingDoc.exists) {
        const profile = billingDoc.data() as BillingProfile;

        if (profile.stripeCustomerId) {
          customerId = profile.stripeCustomerId;
        } else {
          // Create customer
          const customer = await createStripeCustomer(
            userId,
            context.auth.token.email
          );
          customerId = customer.id;

          // Update profile
          await billingRef.update({
            stripeCustomerId: customerId,
            updatedAt: Date.now(),
          });
        }
      } else {
        // Create customer and profile
        const customer = await createStripeCustomer(
          userId,
          context.auth.token.email
        );
        customerId = customer.id;

        const newProfile: BillingProfile = {
          stripeCustomerId: customerId,
          planId: "free",
          status: "free",
          currentPeriodStart: null,
          currentPeriodEnd: null,
          trialEnd: null,
          cancelAtPeriodEnd: false,
          createdAt: Date.now(),
          updatedAt: Date.now(),
        };

        await billingRef.set(newProfile);
      }

      // Create checkout session
      const session = await stripe.checkout.sessions.create({
        customer: customerId,
        payment_method_types: ["card"],
        line_items: [
          {
            price: plan.stripePriceId,
            quantity: 1,
          },
        ],
        mode: "subscription",
        success_url: successUrl,
        cancel_url: cancelUrl,
        metadata: {
          userId,
          planId,
        },
        subscription_data: {
          metadata: {
            userId,
            planId,
          },
        },
      });

      functions.logger.info("Checkout session created", {
        userId,
        planId,
        sessionId: session.id,
        customerId,
      });

      return {
        sessionId: session.id,
        url: session.url || "",
      };
    } catch (error: any) {
      functions.logger.error("Failed to create checkout session", {
        userId,
        planId,
        error: error.message,
      });

      if (error instanceof functions.https.HttpsError) {
        throw error;
      }

      throw new functions.https.HttpsError(
        "internal",
        "Failed to create checkout session",
        error.message
      );
    }
  }
);

/**
 * Create Stripe customer with metadata
 */
async function createStripeCustomer(
  userId: string,
  email?: string
): Promise<Stripe.Customer> {
  return await stripe.customers.create({
    email: email || undefined,
    metadata: {
      firebaseUserId: userId,
    },
  });
}
