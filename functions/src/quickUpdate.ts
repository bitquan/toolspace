// Quick update script for Firebase Functions
import * as functions from "firebase-functions";
import { getAuth } from "firebase-admin/auth";
import { db } from "./admin"; // Use existing admin config

// Function to update recent users who may have completed Stripe checkout but not been updated
export const updateRecentUsersToProPlan = functions.https.onRequest(
  async (req, res) => {
    try {
      const auth = getAuth();

      // Get recent users (last 24 hours)
      const oneDayAgo = new Date(Date.now() - 24 * 60 * 60 * 1000);
      const recentUsers = await auth.listUsers(100); // Get up to 100 recent users

      const usersToUpdate = recentUsers.users
        .filter((user) => new Date(user.metadata.lastSignInTime) > oneDayAgo)
        .sort(
          (a, b) =>
            new Date(b.metadata.lastSignInTime).getTime() -
            new Date(a.metadata.lastSignInTime).getTime()
        )
        .slice(0, 10); // Top 10 most recent

      functions.logger.info("Found recent users to potentially update", {
        totalUsers: recentUsers.users.length,
        recentActiveUsers: usersToUpdate.length,
        oneDayAgo: oneDayAgo.toISOString(),
      });

      const updateResults = [];

      for (const user of usersToUpdate) {
        try {
          // Check if user already has pro plan
          const billingRef = db
            .collection("users")
            .doc(user.uid)
            .collection("billing")
            .doc("profile");

          const billingDoc = await billingRef.get();
          const currentProfile = billingDoc.data();

          // Skip if already pro
          if (
            currentProfile?.planId === "pro" ||
            currentProfile?.planId === "pro_plus"
          ) {
            updateResults.push({
              userId: user.uid.substring(0, 8) + "...",
              action: "skipped",
              reason: "already pro plan",
              currentPlan: currentProfile.planId,
            });
            continue;
          }

          const now = Date.now();
          const updateData = {
            stripeCustomerId: currentProfile?.stripeCustomerId || null,
            planId: "pro",
            status: "active",
            currentPeriodStart: now,
            currentPeriodEnd: now + 30 * 24 * 60 * 60 * 1000, // 30 days from now
            trialEnd: null,
            cancelAtPeriodEnd: false,
            createdAt: currentProfile?.createdAt || now,
            updatedAt: now,
          };

          await billingRef.set(updateData, { merge: true });

          updateResults.push({
            userId: user.uid.substring(0, 8) + "...",
            action: "updated",
            reason: "upgraded to pro",
            lastSignIn: user.metadata.lastSignInTime,
            path: `users/${user.uid}/billing/profile`,
          });
        } catch (error: any) {
          updateResults.push({
            userId: user.uid.substring(0, 8) + "...",
            action: "error",
            reason: error.message,
          });
        }
      }

      res.json({
        success: true,
        message: `Processed ${usersToUpdate.length} recent users`,
        results: updateResults,
        summary: {
          total: updateResults.length,
          updated: updateResults.filter((r) => r.action === "updated").length,
          skipped: updateResults.filter((r) => r.action === "skipped").length,
          errors: updateResults.filter((r) => r.action === "error").length,
        },
      });
    } catch (error: any) {
      functions.logger.error("Error updating recent users", {
        error: error.message,
      });
      res.status(500).json({
        success: false,
        error: error.message,
      });
    }
  }
);

// Legacy single-user update function (keeping for compatibility)
export const quickUpdateUserPlan = functions.https.onRequest(
  async (req, res) => {
    const userId =
      (req.query.userId as string) || "npMCp9xTchbABexI9EiSTFhcd353";

    try {
      const now = Date.now();
      const updateData = {
        stripeCustomerId: null,
        planId: "pro",
        status: "active",
        currentPeriodStart: now,
        currentPeriodEnd: now + 30 * 24 * 60 * 60 * 1000, // 30 days from now
        trialEnd: null,
        cancelAtPeriodEnd: false,
        createdAt: now,
        updatedAt: now,
      };

      // Write to the correct path: users/{uid}/billing/profile
      await db
        .collection("users")
        .doc(userId)
        .collection("billing")
        .doc("profile")
        .set(updateData, { merge: true });

      res.json({
        success: true,
        message: "User plan updated to Pro successfully!",
        userId: userId,
        path: `users/${userId}/billing/profile`,
      });
    } catch (error: any) {
      res.status(500).json({
        success: false,
        error: error.message,
      });
    }
  }
);
