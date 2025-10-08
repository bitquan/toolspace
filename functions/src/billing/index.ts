import * as functions from "firebase-functions";
import { withAuth, withEmailVerification } from "../middleware/withAuth.js";
import { AuthenticatedRequest } from "../types/auth.js";

// Billing endpoints with proper authentication
export const createSubscription = functions.https.onRequest(
  async (req, res) => {
    await withAuth(req, res, async () => {
      await withEmailVerification(req, res, () => {
        const authReq = req as AuthenticatedRequest;
        // Authenticated and email verified user can create subscription
        res.json({
          message: "Subscription creation endpoint",
          userId: authReq.uid,
          userEmail: authReq.user?.email,
          timestamp: Date.now(),
        });
      });
    });
  }
);

export const cancelSubscription = functions.https.onRequest(
  async (req, res) => {
    await withAuth(req, res, () => {
      const authReq = req as AuthenticatedRequest;
      // Authenticated user can cancel subscription
      res.json({
        message: "Subscription cancellation endpoint",
        userId: authReq.uid,
        userEmail: authReq.user?.email,
        timestamp: Date.now(),
      });
    });
  }
);

export const getBillingStatus = functions.https.onRequest(async (req, res) => {
  await withAuth(req, res, () => {
    const authReq = req as AuthenticatedRequest;
    // Authenticated user can check billing status
    res.json({
      message: "Billing status endpoint",
      userId: authReq.uid,
      userEmail: authReq.user?.email,
      emailVerified: authReq.user?.email_verified,
      timestamp: Date.now(),
    });
  });
});
