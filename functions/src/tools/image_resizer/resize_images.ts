import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import sharp from "sharp";
import { v4 as uuid } from "uuid";

/**
 * Preset size configurations
 */
const PRESET_SIZES = {
  thumbnail: { width: 150, height: 150 },
  small: { width: 640, height: 480 },
  medium: { width: 1280, height: 720 },
  large: { width: 1920, height: 1080 },
};

/**
 * Valid output formats
 */
const VALID_FORMATS = ["jpeg", "png", "webp"] as const;
type OutputFormat = (typeof VALID_FORMATS)[number];

/**
 * Resize request data
 */
interface ResizeRequest {
  files: string[]; // Storage paths
  preset?: keyof typeof PRESET_SIZES;
  customWidth?: number;
  customHeight?: number;
  format: string;
}

/**
 * Resize result for a single file
 */
interface ResizeResult {
  originalName: string;
  downloadUrl: string;
  size: number;
  dimensions: { width: number; height: number };
}

/**
 * Resize images with preset or custom dimensions
 * Requires authentication and enforces file limits
 */
export const resizeImages = functions.https.onCall(
  async (data: ResizeRequest, context) => {
    // Validate authentication
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Authentication required to resize images"
      );
    }

    // Validate input
    const { files, preset, customWidth, customHeight, format } = data;

    if (!files || !Array.isArray(files) || files.length === 0) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "At least one file path must be provided"
      );
    }

    if (files.length > 10) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Maximum 10 files allowed per resize operation"
      );
    }

    // Validate format
    if (!format || !VALID_FORMATS.includes(format as OutputFormat)) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        `Invalid format. Must be one of: ${VALID_FORMATS.join(", ")}`
      );
    }

    // Determine dimensions
    let width: number | undefined;
    let height: number | undefined;

    if (preset && PRESET_SIZES[preset]) {
      width = PRESET_SIZES[preset].width;
      height = PRESET_SIZES[preset].height;
    } else if (customWidth || customHeight) {
      width = customWidth;
      height = customHeight;
    } else {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Either preset or custom dimensions must be provided"
      );
    }

    // Validate dimensions
    if (width && (width < 1 || width > 10000)) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Width must be between 1 and 10000 pixels"
      );
    }

    if (height && (height < 1 || height > 10000)) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Height must be between 1 and 10000 pixels"
      );
    }

    const storage = admin.storage();
    const bucket = storage.bucket();
    const results: ResizeResult[] = [];

    try {
      // Process each file
      for (const filePath of files) {
        if (typeof filePath !== "string") {
          throw new functions.https.HttpsError(
            "invalid-argument",
            "File paths must be strings"
          );
        }

        // Download file from storage
        const file = bucket.file(filePath);
        const [fileBuffer] = await file.download();
        const [metadata] = await file.getMetadata();

        // Validate file size (20MB limit)
        if (fileBuffer.length > 20 * 1024 * 1024) {
          throw new functions.https.HttpsError(
            "invalid-argument",
            `File ${filePath} exceeds 20MB limit`
          );
        }

        // Validate MIME type
        const contentType = metadata.contentType || "";
        if (!contentType.startsWith("image/")) {
          throw new functions.https.HttpsError(
            "invalid-argument",
            `File ${filePath} is not a valid image`
          );
        }

        // Resize image with sharp
        const resizeOptions: sharp.ResizeOptions = {
          fit: "inside", // Maintain aspect ratio
          withoutEnlargement: true, // Don't enlarge if smaller
        };

        if (width && height) {
          resizeOptions.width = width;
          resizeOptions.height = height;
        } else if (width) {
          resizeOptions.width = width;
        } else if (height) {
          resizeOptions.height = height;
        }

        const sharpInstance = sharp(fileBuffer).resize(resizeOptions);

        // Convert to output format
        let outputBuffer: Buffer;
        const outputFormat = format as OutputFormat;

        if (outputFormat === "jpeg") {
          outputBuffer = await sharpInstance.jpeg({ quality: 90 }).toBuffer();
        } else if (outputFormat === "png") {
          outputBuffer = await sharpInstance.png({ quality: 90 }).toBuffer();
        } else if (outputFormat === "webp") {
          outputBuffer = await sharpInstance.webp({ quality: 90 }).toBuffer();
        } else {
          throw new functions.https.HttpsError(
            "internal",
            "Unsupported output format"
          );
        }

        // Get output dimensions
        const outputMetadata = await sharp(outputBuffer).metadata();

        // Generate unique filename
        const originalFileNameMeta = metadata.metadata?.originalFileName;
        const originalFileName =
          typeof originalFileNameMeta === "string"
            ? originalFileNameMeta
            : filePath.split("/").pop() || "image";
        const baseFileName = originalFileName.replace(/\.[^/.]+$/, "");
        const outputFileName = `${baseFileName}-resized-${Date.now()}.${outputFormat}`;

        // Upload resized image
        const outputPath = `resized/${context.auth.uid}/${uuid()}-${outputFileName}`;
        const outputFile = bucket.file(outputPath);

        await outputFile.save(outputBuffer, {
          metadata: {
            contentType: `image/${outputFormat}`,
            metadata: {
              originalFileName: originalFileName || "unknown",
              resizedBy: context.auth.uid,
              resizeTimestamp: Date.now().toString(),
            },
          },
        });

        // Generate signed URL (valid for 7 days)
        const [downloadUrl] = await outputFile.getSignedUrl({
          action: "read",
          expires: Date.now() + 7 * 24 * 60 * 60 * 1000,
        });

        results.push({
          originalName: originalFileName,
          downloadUrl,
          size: outputBuffer.length,
          dimensions: {
            width: outputMetadata.width || 0,
            height: outputMetadata.height || 0,
          },
        });

        // Clean up original file
        await file.delete();
      }

      return {
        success: true,
        results,
        totalFiles: results.length,
      };
    } catch (error) {
      // Clean up any uploaded files on error
      for (const result of results) {
        try {
          const urlPath = new URL(result.downloadUrl).pathname;
          const filePath = decodeURIComponent(
            urlPath.split("/o/")[1]?.split("?")[0] || ""
          );
          if (filePath) {
            await bucket.file(filePath).delete();
          }
        } catch (cleanupError) {
          // Ignore cleanup errors
          console.error("Cleanup error:", cleanupError);
        }
      }

      if (error instanceof functions.https.HttpsError) {
        throw error;
      }

      throw new functions.https.HttpsError(
        "internal",
        `Failed to resize images: ${error}`
      );
    }
  }
);
