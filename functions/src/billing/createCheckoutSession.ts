// @ts-nocheck
/**
 * Create Stripe Checkout Session for plan upgrades.
 *
 * Endpoint: POST /api/billing/createCheckoutSession
 * Auth: Requires authenticated user
 */

import * as functions from "firebase-functions/v1";
import Stripe from "stripe";
import {
  BillingProfile,
  CreateCheckoutSessionRequest,
  CreateCheckoutSessionResponse,
} from "../types/billing";
import { loadPricingConfig } from "./entitlements";
import { db } from "../admin";

const stripe = new Stripe(
  process.env.STRIPE_SECRET_KEY ||
    process.env.STRIPE_SECRET ||
    functions.config().stripe?.secret_key ||
    functions.config().stripe?.secret ||
    "",
  {
    apiVersion: "2024-09-30.acacia",
  }
);

export const createCheckoutSession = functions.https.onCall(
  async (
    data: CreateCheckoutSessionRequest,
    context
  ): Promise<CreateCheckoutSessionResponse> => {
    console.log("DEBUG: createCheckoutSession called with data:", data);

    // Require authentication
    if (!context.auth) {
      console.log("DEBUG: Authentication failed");
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Must be logged in"
      );
    }

    console.log("DEBUG: User authenticated:", context.auth.uid);

    // Require email verification before checkout
    if (!context.auth.token.email_verified) {
      console.log("DEBUG: Email not verified");
      throw new functions.https.HttpsError(
        "failed-precondition",
        "Email verification required. Please verify your email address before purchasing a subscription."
      );
    }

    const userId = context.auth.uid;
    const { planId, successUrl, cancelUrl } = data;

    console.log("DEBUG: Processing checkout for:", {
      userId,
      planId,
      successUrl,
      cancelUrl,
    });

    // Validate plan
    if (!planId || !["pro", "pro_plus"].includes(planId)) {
      console.log("DEBUG: Invalid plan ID:", planId);
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Invalid plan ID"
      );
    }

    // Validate URLs
    if (!successUrl || !cancelUrl) {
      console.log("DEBUG: Missing URLs:", { successUrl, cancelUrl });
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Missing success or cancel URL"
      );
    }

    try {
      console.log("DEBUG: Loading pricing config...");
      const config = loadPricingConfig();
      console.log("DEBUG: Pricing config loaded successfully");
      const plan = config.plans[planId as keyof typeof config.plans];

      console.log("DEBUG: Plan found:", plan);

      if (!plan || !plan.stripePriceId) {
        throw new functions.https.HttpsError(
          "not-found",
          "Plan not found or not configured"
        );
      }

      // Get or create Stripe customer
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

      // Create checkout session with proper Firebase UID linking
      const session = await stripe.checkout.sessions.create({
        customer: customerId,
        client_reference_id: userId, // Link to Firebase UID for cross-device access
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
          firebaseUid: userId, // Additional UID tracking
        },
        subscription_data: {
          metadata: {
            userId,
            planId,
            firebaseUid: userId, // Ensure subscription has Firebase UID
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
 * Create Stripe customer with comprehensive Firebase UID metadata
 */
async function createStripeCustomer(
  userId: string,
  email?: string
): Promise<Stripe.Customer> {
  const customer = await stripe.customers.create({
    email: email || undefined,
    metadata: {
      firebaseUserId: userId,
      uid: userId, // Alternative field for UID lookup
      created_by: "toolspace_firebase_auth",
    },
    description: `Toolspace user: ${userId}`,
  });

  functions.logger.info("Stripe customer created", {
    customerId: customer.id,
    firebaseUserId: userId,
    email: email || "none",
  });

  return customer;
}
