import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import PDFMerger from "pdf-merger-js";
import { v4 as uuid } from "uuid";
import { incrementQuota } from "./quota";

/**
 * Merge multiple PDF or image files into a single PDF
 * Requires authentication and enforces quota limits
 */
export const mergePdfs = functions.https.onCall(async (data, context) => {
  // Validate authentication
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Authentication required to merge files"
    );
  }

  // Validate input
  const { files } = data;
  if (!files || !Array.isArray(files) || files.length === 0) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "At least one file path must be provided"
    );
  }

  if (files.length > 20) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Maximum 20 files allowed per merge"
    );
  }

  try {
    // Check and increment quota
    await incrementQuota(context.auth.uid);

    // Initialize PDF merger
    const merger = new PDFMerger();

    // Process each file
    for (const filePath of files) {
      if (typeof filePath !== "string") {
        throw new functions.https.HttpsError(
          "invalid-argument",
          "File paths must be strings"
        );
      }

      // Download file from Firebase Storage
      const bucket = admin.storage().bucket();
      const file = bucket.file(filePath);

      // Check if file exists
      const [exists] = await file.exists();
      if (!exists) {
        throw new functions.https.HttpsError(
          "not-found",
          `File not found: ${filePath}`
        );
      }

      // Download file content
      const [fileBuffer] = await file.download();

      // Add to merger (pdf-merger-js handles PDFs and images)
      await merger.add(fileBuffer);
    }

    // Generate merged PDF
    const mergedBuffer = await merger.saveAsBuffer();

    // Generate unique filename
    const mergeId = uuid();
    const outputPath = `merged/${context.auth.uid}/${mergeId}.pdf`;

    // Upload merged file to Firebase Storage
    const bucket = admin.storage().bucket();
    const outputFile = bucket.file(outputPath);

    await outputFile.save(mergedBuffer, {
      metadata: {
        contentType: "application/pdf",
        metadata: {
          createdBy: context.auth.uid,
          originalFileCount: files.length.toString(),
          mergeTimestamp: Date.now().toString(),
        },
      },
    });

    // Generate signed URL valid for 7 days
    const [signedUrl] = await outputFile.getSignedUrl({
      action: "read",
      expires: Date.now() + 7 * 24 * 60 * 60 * 1000, // 7 days
    });

    return {
      success: true,
      downloadUrl: signedUrl,
      mergeId,
      fileCount: files.length,
      outputPath,
    };
  } catch (error) {
    console.error("PDF merge error:", error);

    // Re-throw known errors
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }

    // Handle unknown errors
    throw new functions.https.HttpsError(
      "internal",
      "Failed to merge files. Please try again."
    );
  }
});
