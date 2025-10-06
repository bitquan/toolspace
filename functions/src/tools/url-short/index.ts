import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { nanoid } from "nanoid";

/**
 * Create a short URL
 * Requires authentication and dev-only access
 */
export const createShortUrl = functions.https.onCall(async (data, context) => {
  // Validate authentication
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Authentication required"
    );
  }

  // TODO: Implement dev-only check
  // For now, all authenticated users can use this
  const userId = context.auth.uid;

  // Validate input
  const { url } = data;
  if (!url || typeof url !== "string") {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "URL is required"
    );
  }

  // Validate URL format
  try {
    new URL(url);
  } catch (e) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Invalid URL format"
    );
  }

  // URL length check
  if (url.length > 2048) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "URL is too long (max 2048 characters)"
    );
  }

  try {
    const db = admin.firestore();

    // Generate unique short code
    let shortCode: string;
    let attempts = 0;
    const maxAttempts = 10;

    do {
      shortCode = nanoid(6);
      const existing = await db.collection("shortUrls").doc(shortCode).get();
      if (!existing.exists) {
        break;
      }
      attempts++;
    } while (attempts < maxAttempts);

    if (attempts >= maxAttempts) {
      throw new Error("Failed to generate unique short code");
    }

    // Store the short URL
    const shortUrlData = {
      userId,
      originalUrl: url,
      shortCode,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      clicks: 0,
    };

    await db.collection("shortUrls").doc(shortCode).set(shortUrlData);

    return {
      success: true,
      shortCode,
      shortUrl: `/u/${shortCode}`,
    };
  } catch (error: any) {
    console.error("Error creating short URL:", error);
    throw new functions.https.HttpsError(
      "internal",
      `Failed to create short URL: ${error.message}`
    );
  }
});

/**
 * Get user's short URLs
 */
export const getUserShortUrls = functions.https.onCall(
  async (data, context) => {
    // Validate authentication
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Authentication required"
      );
    }

    const userId = context.auth.uid;

    try {
      const db = admin.firestore();
      const snapshot = await db
        .collection("shortUrls")
        .where("userId", "==", userId)
        .orderBy("createdAt", "desc")
        .limit(100)
        .get();

      const urls = snapshot.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
      }));

      return {
        success: true,
        urls,
      };
    } catch (error: any) {
      console.error("Error getting short URLs:", error);
      throw new functions.https.HttpsError(
        "internal",
        `Failed to get short URLs: ${error.message}`
      );
    }
  }
);

/**
 * Delete a short URL
 */
export const deleteShortUrl = functions.https.onCall(async (data, context) => {
  // Validate authentication
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Authentication required"
    );
  }

  const userId = context.auth.uid;
  const { shortCode } = data;

  if (!shortCode || typeof shortCode !== "string") {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Short code is required"
    );
  }

  try {
    const db = admin.firestore();
    const docRef = db.collection("shortUrls").doc(shortCode);
    const doc = await docRef.get();

    if (!doc.exists) {
      throw new functions.https.HttpsError("not-found", "Short URL not found");
    }

    const data = doc.data();
    if (data?.userId !== userId) {
      throw new functions.https.HttpsError(
        "permission-denied",
        "You can only delete your own short URLs"
      );
    }

    await docRef.delete();

    return {
      success: true,
    };
  } catch (error: any) {
    console.error("Error deleting short URL:", error);
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    throw new functions.https.HttpsError(
      "internal",
      `Failed to delete short URL: ${error.message}`
    );
  }
});

/**
 * HTTP redirect endpoint for short URLs
 * GET /u/:code
 */
export const redirectShortUrl = functions.https.onRequest(
  async (req, res) => {
    // Extract short code from path
    const pathParts = req.path.split("/").filter((p) => p);
    const shortCode = pathParts[pathParts.length - 1];

    if (!shortCode) {
      res.status(400).send("Short code is required");
      return;
    }

    try {
      const db = admin.firestore();
      const doc = await db.collection("shortUrls").doc(shortCode).get();

      if (!doc.exists) {
        res.status(404).send("Short URL not found");
        return;
      }

      const data = doc.data();
      if (!data) {
        res.status(404).send("Short URL not found");
        return;
      }

      // Increment click counter
      await doc.ref.update({
        clicks: admin.firestore.FieldValue.increment(1),
        lastAccessedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Redirect to original URL
      res.redirect(302, data.originalUrl);
    } catch (error: any) {
      console.error("Error redirecting short URL:", error);
      res.status(500).send("Internal server error");
    }
  }
);
