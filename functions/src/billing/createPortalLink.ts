// @ts-nocheck
/**
 * Create Stripe Customer Portal link for subscription management.
 *
 * Endpoint: POST /api/billing/createPortalLink
 * Auth: Requires authenticated user with existing subscription
 */

import * as admin from "firebase-admin";
import * as functions from "firebase-functions/v1";
import Stripe from "stripe";
import { BillingProfile, CreatePortalLinkResponse } from "../types/billing";

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

export const createPortalLink = functions.https.onCall(
  async (
    data: { returnUrl: string },
    context
  ): Promise<CreatePortalLinkResponse> => {
    // Require authentication
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Must be logged in"
      );
    }

    const userId = context.auth.uid;
    const { returnUrl } = data;

    if (!returnUrl) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Missing return URL"
      );
    }

    try {
      const db = admin.firestore();
      const billingRef = db.doc(`users/${userId}/billing/profile`);
      const billingDoc = await billingRef.get();

      if (!billingDoc.exists) {
        throw new functions.https.HttpsError(
          "not-found",
          "No billing profile found"
        );
      }

      const profile = billingDoc.data() as BillingProfile;

      if (!profile.stripeCustomerId) {
        throw new functions.https.HttpsError(
          "failed-precondition",
          "No Stripe customer ID found"
        );
      }

      // Create portal session
      const session = await stripe.billingPortal.sessions.create({
        customer: profile.stripeCustomerId,
        return_url: returnUrl,
      });

      functions.logger.info("Portal link created", {
        userId,
        customerId: profile.stripeCustomerId,
      });

      return {
        url: session.url,
      };
    } catch (error: any) {
      functions.logger.error("Failed to create portal link", {
        userId,
        error: error.message,
      });

      if (error instanceof functions.https.HttpsError) {
        throw error;
      }

      throw new functions.https.HttpsError(
        "internal",
        "Failed to create portal link",
        error.message
      );
    }
  }
);
