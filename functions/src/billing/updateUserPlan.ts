/**
 * Temporary function to manually update user plan for testing
 * This bypasses the webhook and directly updates the billing profile
 */

import * as functions from "firebase-functions/v1";
import { db } from "../admin";

export const updateUserPlan = functions.https.onCall(
  async (data: { userId: string; planId: string }, context) => {
    // Require authentication
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Must be logged in"
      );
    }

    // Only allow users to update their own plan, or admin users
    if (context.auth.uid !== data.userId) {
      throw new functions.https.HttpsError(
        "permission-denied",
        "Can only update your own plan"
      );
    }

    const { userId, planId } = data;

    try {
      const billingRef = db.doc(`users/${userId}/billing/profile`);

      await billingRef.set(
        {
          planId,
          subscriptionStatus: "active",
          stripeCustomerId: context.auth.uid, // Temporary
          updatedAt: new Date().toISOString(),
          manuallyUpdated: true, // Flag for debugging
        },
        { merge: true }
      );

      functions.logger.info("Plan updated manually", { userId, planId });

      return { success: true, planId };
    } catch (error: any) {
      functions.logger.error("Failed to update plan", {
        userId,
        planId,
        error: error.message,
      });
      throw new functions.https.HttpsError("internal", "Failed to update plan");
    }
  }
);
