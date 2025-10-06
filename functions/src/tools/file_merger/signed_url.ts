import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

/**
 * Generate a signed URL for a merged PDF file
 * This allows users to regenerate download links for their merged files
 */
export const getSignedUrl = functions.https.onCall(async (data, context) => {
  // Validate authentication
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Authentication required to generate signed URLs"
    );
  }

  // Validate input
  const { filePath } = data;
  if (!filePath || typeof filePath !== "string") {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "File path must be provided as a string"
    );
  }

  // Validate that the file path is in the user's merged folder
  const expectedPrefix = `merged/${context.auth.uid}/`;
  if (!filePath.startsWith(expectedPrefix)) {
    throw new functions.https.HttpsError(
      "permission-denied",
      "You can only generate signed URLs for your own merged files"
    );
  }

  try {
    // Check if file exists
    const bucket = admin.storage().bucket();
    const file = bucket.file(filePath);

    const [exists] = await file.exists();
    if (!exists) {
      throw new functions.https.HttpsError(
        "not-found",
        "File not found. It may have been deleted or expired."
      );
    }

    // Get file metadata to return additional info
    const [metadata] = await file.getMetadata();

    // Generate signed URL valid for 7 days
    const [signedUrl] = await file.getSignedUrl({
      action: "read",
      expires: Date.now() + 7 * 24 * 60 * 60 * 1000, // 7 days
    });

    return {
      success: true,
      downloadUrl: signedUrl,
      filePath,
      expiresIn: 7 * 24 * 60 * 60 * 1000, // milliseconds
      metadata: {
        contentType: metadata.contentType,
        size: metadata.size,
        created: metadata.timeCreated,
        originalFileCount: metadata.metadata?.originalFileCount || "unknown",
      },
    };
  } catch (error) {
    console.error("Signed URL generation error:", error);

    // Re-throw known errors
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }

    // Handle unknown errors
    throw new functions.https.HttpsError(
      "internal",
      "Failed to generate signed URL. Please try again."
    );
  }
});
