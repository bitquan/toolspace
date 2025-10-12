import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import * as fs from "fs/promises";
import PDFMerger from "pdf-merger-js";
import { v4 as uuid } from "uuid";

const logger = functions.logger;

/**
 * Enhanced PDF/Image Merger with verbose logging and error handling
 * Fixes common issues causing [firebase_functions/internal] errors
 */
export const mergePdfsEnhanced = functions.https.onCall(
  async (data, context) => {
    const startTime = Date.now();
    const requestId = uuid();

    logger.info(`[${requestId}] Starting merge request`, {
      uid: context.auth?.uid,
      fileCount: data?.files?.length,
      timestamp: startTime,
    });

    // Validate authentication
    if (!context.auth) {
      logger.warn(`[${requestId}] Unauthenticated request blocked`);
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Authentication required to merge files"
      );
    }

    // Validate input
    const { files } = data;
    if (!files || !Array.isArray(files) || files.length === 0) {
      logger.warn(`[${requestId}] Invalid input files`, { files });
      throw new functions.https.HttpsError(
        "invalid-argument",
        "At least one file path must be provided"
      );
    }

    if (files.length > 20) {
      logger.warn(`[${requestId}] Too many files`, { count: files.length });
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Maximum 20 files allowed per merge"
      );
    }

    const tempFiles: string[] = [];

    try {
      // Check billing plan and quota
      const planCheck = await checkUserPlan(context.auth.uid);
      logger.info(`[${requestId}] Plan check result`, planCheck);

      if (!planCheck.canMerge) {
        throw new functions.https.HttpsError(
          "permission-denied",
          planCheck.reason || "Upgrade required to merge files"
        );
      }

      // Initialize PDF merger
      logger.info(`[${requestId}] Initializing PDF merger`);
      const merger = new PDFMerger();

      // Process each file with detailed logging
      for (let i = 0; i < files.length; i++) {
        const filePath = files[i];
        logger.info(`[${requestId}] Processing file ${i + 1}/${files.length}`, {
          filePath,
        });

        if (typeof filePath !== "string") {
          throw new functions.https.HttpsError(
            "invalid-argument",
            `File path at index ${i} must be a string`
          );
        }

        try {
          // Download file from Firebase Storage
          const bucket = admin.storage().bucket();
          const file = bucket.file(filePath);

          // Check if file exists
          const [exists] = await file.exists();
          if (!exists) {
            logger.error(`[${requestId}] File not found`, { filePath });
            throw new functions.https.HttpsError(
              "not-found",
              `File not found: ${filePath}`
            );
          }

          // Get file metadata
          const [metadata] = await file.getMetadata();
          const fileSize = parseInt(metadata.size || "0");
          const contentType = metadata.contentType || "unknown";

          logger.info(`[${requestId}] File metadata`, {
            filePath,
            size: fileSize,
            contentType,
          });

          // Check file size (10MB limit)
          if (fileSize > 10 * 1024 * 1024) {
            throw new functions.https.HttpsError(
              "invalid-argument",
              `File too large: ${filePath} (${fileSize} bytes, max 10MB)`
            );
          }

          // Download file content
          logger.info(`[${requestId}] Downloading file`, { filePath });
          const [fileBuffer] = await file.download();
          logger.info(`[${requestId}] Downloaded file`, {
            filePath,
            bufferSize: fileBuffer.length,
          });

          // Handle different file types
          if (contentType.startsWith("image/")) {
            // Convert image to PDF first
            logger.info(`[${requestId}] Converting image to PDF`, {
              filePath,
              contentType,
            });
            const pdfBuffer = await convertImageToPdf(
              fileBuffer,
              contentType,
              requestId
            );
            await merger.add(pdfBuffer);
          } else if (contentType === "application/pdf") {
            // Add PDF directly
            logger.info(`[${requestId}] Adding PDF directly`, { filePath });
            await merger.add(fileBuffer);
          } else {
            // Try adding as PDF (fallback)
            logger.warn(
              `[${requestId}] Unknown content type, attempting as PDF`,
              {
                filePath,
                contentType,
              }
            );
            await merger.add(fileBuffer);
          }

          logger.info(`[${requestId}] Successfully processed file ${i + 1}`, {
            filePath,
          });
        } catch (fileError) {
          logger.error(`[${requestId}] Error processing file ${i + 1}`, {
            filePath,
            error: fileError,
            stack: fileError instanceof Error ? fileError.stack : undefined,
          });
          throw fileError;
        }
      }

      // Generate merged PDF
      logger.info(`[${requestId}] Generating merged PDF`);
      const mergedBuffer = await merger.saveAsBuffer();
      logger.info(`[${requestId}] Merged PDF generated`, {
        size: mergedBuffer.length,
      });

      // Generate unique filename and upload path
      const mergeId = uuid();
      const outputPath = `merged/${context.auth.uid}/${mergeId}.pdf`;

      logger.info(`[${requestId}] Uploading merged file`, { outputPath });

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
            requestId,
          },
        },
      });

      logger.info(`[${requestId}] File uploaded successfully`);

      // Generate signed URL valid for 7 days
      const [signedUrl] = await outputFile.getSignedUrl({
        action: "read",
        expires: Date.now() + 7 * 24 * 60 * 60 * 1000, // 7 days
      });

      // Update user quota
      await incrementMergeQuota(context.auth.uid, requestId);

      const result = {
        success: true,
        downloadUrl: signedUrl,
        mergeId,
        fileCount: files.length,
        outputPath,
        processingTime: Date.now() - startTime,
      };

      logger.info(`[${requestId}] Merge completed successfully`, result);
      return result;
    } catch (error) {
      logger.error(`[${requestId}] Merge failed`, {
        error: error,
        stack: error instanceof Error ? error.stack : undefined,
        processingTime: Date.now() - startTime,
      });

      // Clean up temp files
      for (const tempFile of tempFiles) {
        try {
          await fs.unlink(tempFile);
        } catch (cleanupError) {
          logger.warn(`[${requestId}] Failed to cleanup temp file`, {
            tempFile,
            error: cleanupError,
          });
        }
      }

      // Re-throw known errors
      if (error instanceof functions.https.HttpsError) {
        throw error;
      }

      // Handle specific error types
      if (error instanceof Error) {
        if (
          error.message.includes("pdf-merger-js") ||
          error.message.includes("PDF")
        ) {
          throw new functions.https.HttpsError(
            "invalid-argument",
            `PDF processing failed: ${error.message}`
          );
        }

        if (
          error.message.includes("storage") ||
          error.message.includes("bucket")
        ) {
          throw new functions.https.HttpsError(
            "internal",
            "Storage operation failed. Please try again."
          );
        }
      }

      // Generic fallback
      throw new functions.https.HttpsError(
        "internal",
        `Merge operation failed. Request ID: ${requestId}`
      );
    }
  }
);

/**
 * Convert image to PDF using a simple approach
 */
async function convertImageToPdf(
  imageBuffer: Buffer,
  contentType: string,
  requestId: string
): Promise<Buffer> {
  try {
    logger.info(`[${requestId}] Converting image to PDF`, { contentType });

    // Use pdf-lib for image to PDF conversion
    const PDFLib = await import("pdf-lib");
    const pdfDoc = await PDFLib.PDFDocument.create();

    let image;
    if (contentType === "image/jpeg" || contentType === "image/jpg") {
      image = await pdfDoc.embedJpg(imageBuffer);
    } else if (contentType === "image/png") {
      image = await pdfDoc.embedPng(imageBuffer);
    } else {
      throw new Error(`Unsupported image type: ${contentType}`);
    }

    // Create a page with the image
    const page = pdfDoc.addPage([image.width, image.height]);
    page.drawImage(image, {
      x: 0,
      y: 0,
      width: image.width,
      height: image.height,
    });

    const pdfBytes = await pdfDoc.save();
    logger.info(`[${requestId}] Image converted to PDF`, {
      originalSize: imageBuffer.length,
      pdfSize: pdfBytes.length,
    });

    return Buffer.from(pdfBytes);
  } catch (error) {
    logger.error(`[${requestId}] Image to PDF conversion failed`, {
      contentType,
      error,
    });
    throw new Error(`Failed to convert image to PDF: ${error}`);
  }
}

/**
 * Check user's plan and merge permissions
 */
async function checkUserPlan(
  uid: string
): Promise<{ canMerge: boolean; reason?: string; plan?: string }> {
  try {
    const userRef = admin.firestore().doc(`users/${uid}`);
    const userDoc = await userRef.get();

    if (!userDoc.exists) {
      // New user - create default free profile
      await userRef.set({
        quota: { merges: 0 },
        subscription: { isPro: false, planId: "free" },
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      return {
        canMerge: false,
        reason: "File merger requires Pro plan. Current plan: Free",
      };
    }

    const userData = userDoc.data()!;
    const isPro = userData?.subscription?.isPro || false;
    const planId = userData?.subscription?.planId || "free";
    const currentMerges = userData?.quota?.merges || 0;

    if (!isPro) {
      return {
        canMerge: false,
        reason: `File merger requires Pro plan. Current plan: ${planId}`,
        plan: planId,
      };
    }

    return { canMerge: true, plan: planId };
  } catch (error) {
    logger.error("Failed to check user plan", { uid, error });
    return { canMerge: false, reason: "Unable to verify subscription status" };
  }
}

/**
 * Increment merge quota for Pro users (tracking only)
 */
async function incrementMergeQuota(
  uid: string,
  requestId: string
): Promise<void> {
  try {
    const userRef = admin.firestore().doc(`users/${uid}`);

    await admin.firestore().runTransaction(async (transaction) => {
      const userDoc = await transaction.get(userRef);
      const userData = userDoc.data() || {};
      const currentMerges = userData?.quota?.merges || 0;

      transaction.update(userRef, {
        "quota.merges": currentMerges + 1,
        "quota.lastMerge": admin.firestore.FieldValue.serverTimestamp(),
      });
    });

    logger.info(`[${requestId}] Quota updated`, { uid });
  } catch (error) {
    logger.warn(`[${requestId}] Failed to update quota`, { uid, error });
    // Don't fail the entire operation for quota tracking
  }
}
