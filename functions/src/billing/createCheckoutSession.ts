// @ts-nocheck
/**
 * Create Stripe Checkout Session for plan upgrades.
 *
 * Endpoint: POST /api/billing/createCheckoutSession
 * Auth: Requires authenticated user
 */

import * as functions from "firebase-functions/v1";
import Stripe from "stripe";
import { db } from "../admin";
import { BillingProfile } from "../types/billing";
import { loadPricingConfig } from "./entitlements";

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
  async (data, context) => {
    // Verify user is authenticated
    if (!context.auth) {
      console.log("DEBUG: No auth context");
      throw new functions.https.HttpsError(
        "unauthenticated",
        "User must be authenticated"
      );
    }

    // Log EVERYTHING about the auth context
    console.log("DEBUG: Full auth context analysis:", {
      authExists: !!context.auth,
      uid: context.auth.uid,
      uidLength: context.auth.uid?.length,
      uidCharCodes: context.auth.uid?.split("").map((c) => c.charCodeAt(0)),
      token: {
        email: context.auth.token?.email,
        email_verified: context.auth.token?.email_verified,
        sub: context.auth.token?.sub,
        firebase: {
          identities: context.auth.token?.firebase?.identities,
          sign_in_provider: context.auth.token?.firebase?.sign_in_provider,
        },
      },
      rawContextAuth: JSON.stringify(context.auth),
    });

    // Check if user's email is verified
    if (!context.auth.token?.email_verified) {
      console.log("DEBUG: Email not verified");
      throw new functions.https.HttpsError(
        "failed-precondition",
        "Email verification required. Please verify your email address before purchasing a subscription."
      );
    }

    const rawUserId = context.auth.uid;
    const { planId, successUrl, cancelUrl } = data;

    // Log the raw user ID for debugging
    console.log("DEBUG: Raw user ID extracted:", {
      rawUserId,
      length: rawUserId?.length,
      charCodes: rawUserId?.split("").map((c) => c.charCodeAt(0)),
    });

    // Validate and potentially correct user ID
    // Check if this user exists in our database
    let userId = rawUserId;
    try {
      const userDoc = await db.collection("users").doc(rawUserId).get();
      if (!userDoc.exists) {
        console.log(
          "DEBUG: User not found with raw ID, checking for similar IDs"
        );

        // Look for users with similar IDs (potential character encoding issues)
        const usersSnapshot = await db.collection("users").get();
        let foundCorrectId = null;

        usersSnapshot.forEach((doc) => {
          const docId = doc.id;
          // Check if the IDs are similar (same length, mostly same characters)
          if (docId.length === rawUserId.length) {
            let differences = 0;
            for (let i = 0; i < docId.length; i++) {
              if (docId[i] !== rawUserId[i]) {
                differences++;
              }
            }
            // If only 1-2 character differences, this might be the correct ID
            if (differences <= 2) {
              foundCorrectId = docId;
              console.log("DEBUG: Found potential correct user ID:", {
                original: rawUserId,
                corrected: docId,
                differences: differences,
              });
            }
          }
        });

        if (foundCorrectId) {
          userId = foundCorrectId;
          console.log("DEBUG: Using corrected user ID:", userId);
        } else {
          console.log("DEBUG: No similar user ID found, using raw ID");
        }
      } else {
        console.log("DEBUG: User found with raw ID, proceeding normally");
      }
    } catch (error) {
      console.log("DEBUG: Error checking user existence:", error);
    }

    console.log("DEBUG: Processing checkout for:", {
      rawUserId,
      finalUserId: userId,
      userIdLength: userId?.length,
      planId,
      successUrl,
      cancelUrl,
      authContext: {
        uid: context.auth?.uid,
        email: context.auth?.token?.email,
      },
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

// Lightweight HTTP wrapper for E2E testing via REST
export const createCheckoutSessionHttp = functions.https.onRequest(
  async (req, res) => {
    if (req.method !== "POST") {
      res.set("Allow", "POST");
      return res.status(405).send("Method Not Allowed");
    }

    try {
      const { priceId, successUrl, cancelUrl, customerEmail, uid } =
        req.body || {};

      // In staging, allow unauthenticated invocation for automation; require explicit uid
      const isStaging =
        process.env.FIREBASE_PROJECT_ID === "toolz-space-staging" ||
        (process.env.FIREBASE_CONFIG || "").includes("toolz-space-staging");

      if (!isStaging) {
        return res.status(403).json({ error: "Forbidden outside staging" });
      }

      if (!uid || !customerEmail) {
        return res
          .status(400)
          .json({ error: "uid and customerEmail required" });
      }

      // Minimal session creation using provided priceId
      const session = await stripe.checkout.sessions.create({
        mode: "subscription",
        line_items: [{ price: priceId || "price_test_pro", quantity: 1 }],
        success_url:
          successUrl || `${process.env.PUBLIC_BASE_URL}/billing/success`,
        cancel_url:
          cancelUrl || `${process.env.PUBLIC_BASE_URL}/billing/cancel`,
        customer_email: customerEmail,
        metadata: { uid },
      });

      return res.status(200).json({ url: session.url });
    } catch (err) {
      console.error("createCheckoutSessionHttp error", err);
      return res.status(500).json({ error: String(err?.message || err) });
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
