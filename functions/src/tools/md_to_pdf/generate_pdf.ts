import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import puppeteer from "puppeteer";
import { marked } from "marked";
import { v4 as uuid } from "uuid";
import { themes } from "./themes.js";

interface PdfOptions {
  markdown: string;
  theme: string;
  pageSize: string;
  margins: {
    top: number;
    bottom: number;
    left: number;
    right: number;
  };
  includePageNumbers: boolean;
}

/**
 * Generate PDF from Markdown with customizable themes and options
 * Requires authentication
 */
export const generatePdfFromMarkdown = functions
  .runWith({
    memory: "1GB",
    timeoutSeconds: 120,
  })
  .https.onCall(async (data: PdfOptions, context) => {
    // Validate authentication
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Authentication required to generate PDF"
      );
    }

    // Validate input
    const { markdown, theme, pageSize, margins, includePageNumbers } = data;
    
    if (!markdown || typeof markdown !== "string") {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Valid markdown content is required"
      );
    }

    if (markdown.length > 1000000) { // 1MB limit
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Markdown content exceeds maximum size of 1MB"
      );
    }

    const validThemes = ["github", "clean", "academic"];
    if (!validThemes.includes(theme)) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        `Invalid theme. Must be one of: ${validThemes.join(", ")}`
      );
    }

    try {
      // Convert markdown to HTML
      const htmlContent = await marked(markdown);

      // Get theme CSS
      const themeCSS = themes[theme as keyof typeof themes];

      // Build complete HTML document
      const html = buildHtmlDocument(htmlContent, themeCSS, includePageNumbers);

      // Configure page format
      const format = getPageFormat(pageSize);
      
      // Launch puppeteer
      const browser = await puppeteer.launch({
        headless: true,
        args: [
          "--no-sandbox",
          "--disable-setuid-sandbox",
          "--disable-dev-shm-usage",
        ],
      });

      const page = await browser.newPage();
      await page.setContent(html, { waitUntil: "networkidle0" });

      // Generate PDF
      const pdfBuffer = await page.pdf({
        format: format as any,
        printBackground: true,
        margin: {
          top: `${margins.top}mm`,
          bottom: `${margins.bottom}mm`,
          left: `${margins.left}mm`,
          right: `${margins.right}mm`,
        },
        displayHeaderFooter: includePageNumbers,
        headerTemplate: includePageNumbers ? "<div></div>" : undefined,
        footerTemplate: includePageNumbers
          ? `
            <div style="font-size: 10px; text-align: center; width: 100%; color: #666;">
              <span class="pageNumber"></span> / <span class="totalPages"></span>
            </div>
          `
          : undefined,
      });

      await browser.close();

      // Generate unique filename
      const pdfId = uuid();
      const outputPath = `pdf-exports/${context.auth.uid}/${pdfId}.pdf`;

      // Upload to Firebase Storage
      const bucket = admin.storage().bucket();
      const file = bucket.file(outputPath);

      await file.save(pdfBuffer, {
        metadata: {
          contentType: "application/pdf",
          metadata: {
            createdBy: context.auth.uid,
            theme,
            pageSize,
            createdAt: Date.now().toString(),
          },
        },
      });

      // Generate signed URL valid for 7 days
      const [signedUrl] = await file.getSignedUrl({
        action: "read",
        expires: Date.now() + 7 * 24 * 60 * 60 * 1000, // 7 days
      });

      return {
        success: true,
        downloadUrl: signedUrl,
        pdfId,
        outputPath,
      };
    } catch (error) {
      console.error("PDF generation error:", error);

      // Re-throw known errors
      if (error instanceof functions.https.HttpsError) {
        throw error;
      }

      // Handle unknown errors
      throw new functions.https.HttpsError(
        "internal",
        "Failed to generate PDF. Please try again."
      );
    }
  });

function buildHtmlDocument(
  content: string,
  css: string,
  includePageNumbers: boolean
): string {
  return `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Markdown PDF Export</title>
  <style>
    ${css}
    @media print {
      body {
        margin: 0;
      }
      ${includePageNumbers ? `
      @page {
        margin-bottom: 20mm;
      }
      ` : ""}
    }
  </style>
</head>
<body>
  ${content}
</body>
</html>
  `;
}

function getPageFormat(pageSize: string): string {
  const formats: Record<string, string> = {
    a4: "A4",
    letter: "Letter",
    legal: "Legal",
  };
  return formats[pageSize] || "A4";
}
