import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

/**
 * User quota limits for file merging
 */
export const QUOTA_LIMITS = {
  FREE_MERGES: 3,
  MAX_FILE_SIZE_MB: 10,
  MAX_FILES_PER_MERGE: 20,
};

/**
 * Increment user's merge quota and enforce limits
 */
export async function incrementQuota(uid: string) {
  const userRef = admin.firestore().doc(`users/${uid}`);

  await admin.firestore().runTransaction(async (transaction) => {
    const userDoc = await transaction.get(userRef);

    // Get current quota data
    const userData = userDoc.exists ? userDoc.data() : {};
    const currentMerges = userData?.quota?.merges || 0;
    const isPro = userData?.subscription?.isPro || false;

    // Check quota limits for free users
    if (!isPro && currentMerges >= QUOTA_LIMITS.FREE_MERGES) {
      throw new functions.https.HttpsError(
        "permission-denied",
        `Free quota exceeded. Maximum ${QUOTA_LIMITS.FREE_MERGES} merges allowed. Upgrade to Pro for unlimited merges.`
      );
    }

    // Increment merge count
    const newMerges = currentMerges + 1;

    // Update user document
    transaction.set(
      userRef,
      {
        quota: {
          merges: newMerges,
          lastMerge: admin.firestore.FieldValue.serverTimestamp(),
        },
        // Preserve existing data
        ...userData,
      },
      { merge: true }
    );
  });
}

/**
 * Get user's current quota status
 */
export const getQuotaStatus = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Authentication required"
    );
  }

  const userRef = admin.firestore().doc(`users/${context.auth.uid}`);
  const userDoc = await userRef.get();

  const userData = userDoc.exists ? userDoc.data() : {};
  const currentMerges = userData?.quota?.merges || 0;
  const isPro = userData?.subscription?.isPro || false;

  return {
    mergesUsed: currentMerges,
    mergesRemaining: isPro
      ? -1
      : Math.max(0, QUOTA_LIMITS.FREE_MERGES - currentMerges), // -1 = unlimited
    isPro,
    limits: QUOTA_LIMITS,
  };
});
