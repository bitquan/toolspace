/**
 * Legacy quota status function - DEPRECATED
 *
 * This function is kept for backward compatibility with old File Merger UI.
 * New code should use the BillingService and PaywallGuard instead.
 *
 * Returns mock quota status that indicates unlimited access.
 */

// @ts-nocheck
import * as functions from "firebase-functions";

export const getQuotaStatus = functions.https.onCall(async (data, context) => {
  // Require authentication
  if (!context || !context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Authentication required"
    );
  }

  // Return mock quota status - indicates "pro" user with unlimited access
  // This prevents UI errors while we migrate to PaywallGuard
  return {
    isPro: true,
    mergesUsed: 0,
    mergesRemaining: 999,
    mergesLimit: 999,
  };
});
