import * as functions from "firebase-functions/v1";
import * as admin from "firebase-admin";
// TODO: Add puppeteer dependency for PDF generation
// import puppeteer from "puppeteer";
import { randomUUID } from "crypto";

interface InvoiceData {
  businessInfo: {
    name: string;
    address: string;
    email: string;
    phone: string;
  };
  clientInfo: {
    name: string;
    address: string;
    email: string;
  };
  invoiceNumber: string;
  issueDate: string;
  dueDate: string;
  items: Array<{
    description: string;
    quantity: number;
    rate: number;
    amount: number;
  }>;
  subtotal: number;
  taxRate: number;
  taxAmount: number;
  discountRate: number;
  discountAmount: number;
  total: number;
  notes?: string;
}

/**
 * Generate PDF invoice from invoice data
 * Requires authentication and Pro plan
 */
export const generateInvoicePdf = functions
  .runWith({
    memory: "1GB",
    timeoutSeconds: 120,
  })
  .https.onCall(
    async (data: InvoiceData, context: functions.https.CallableContext) => {
      // Validate authentication
      if (!context.auth) {
        throw new functions.https.HttpsError(
          "unauthenticated",
          "Authentication required to generate PDF"
        );
      }

      // Check Pro plan requirement
      const userId = context.auth.uid;
      const userDoc = await admin.firestore().doc(`users/${userId}`).get();
      const userData = userDoc.data();

      if (!userData?.billing?.plan || userData.billing.plan !== "pro") {
        throw new functions.https.HttpsError(
          "permission-denied",
          "Pro plan required for PDF generation"
        );
      }

      // Validate input
      if (
        !data.businessInfo ||
        !data.clientInfo ||
        !data.items ||
        data.items.length === 0
      ) {
        throw new functions.https.HttpsError(
          "invalid-argument",
          "Valid invoice data is required"
        );
      }

      try {
        // For now, return HTML content instead of PDF
        // TODO: Implement PDF generation with puppeteer once dependency is added
        const html = generateInvoiceHtml(data);

        // Upload HTML to Firebase Storage as temporary solution
        const filename = `invoices/${userId}/${randomUUID()}.html`;
        const bucket = admin.storage().bucket();
        const file = bucket.file(filename);

        await file.save(Buffer.from(html), {
          metadata: {
            contentType: "text/html",
            metadata: {
              invoiceNumber: data.invoiceNumber,
              userId: userId,
              createdAt: new Date().toISOString(),
            },
          },
        });

        // Make the file publicly accessible
        await file.makePublic();

        // Get the public URL
        const publicUrl = `https://storage.googleapis.com/${bucket.name}/${filename}`;

        // Log usage
        await admin
          .firestore()
          .collection("usage")
          .add({
            userId: userId,
            action: "invoice_html_generated",
            timestamp: admin.firestore.FieldValue.serverTimestamp(),
            metadata: {
              invoiceNumber: data.invoiceNumber,
              filename: filename,
            },
          });

        return {
          success: true,
          downloadUrl: publicUrl,
          filename: filename,
          note: "HTML preview generated. PDF generation requires puppeteer dependency.",
        };
      } catch (error) {
        console.error("Error generating invoice:", error);
        throw new functions.https.HttpsError(
          "internal",
          "Failed to generate invoice"
        );
      }
    }
  );

function generateInvoiceHtml(data: InvoiceData): string {
  return `
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Invoice ${data.invoiceNumber}</title>
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      line-height: 1.6;
      color: #333;
      max-width: 800px;
      margin: 0 auto;
      padding: 20px;
    }
    .header {
      display: flex;
      justify-content: space-between;
      align-items: flex-start;
      margin-bottom: 40px;
      border-bottom: 2px solid #007bff;
      padding-bottom: 20px;
    }
    .invoice-title {
      font-size: 32px;
      font-weight: bold;
      color: #007bff;
      margin: 0;
    }
    .invoice-number {
      font-size: 18px;
      color: #666;
      margin: 5px 0;
    }
    .business-info, .client-info {
      margin-bottom: 30px;
    }
    .info-label {
      font-weight: bold;
      color: #007bff;
      margin-bottom: 10px;
      font-size: 16px;
    }
    .info-content {
      background: #f8f9fa;
      padding: 15px;
      border-radius: 5px;
      border-left: 4px solid #007bff;
    }
    .dates {
      display: flex;
      justify-content: space-between;
      margin: 30px 0;
    }
    .date-item {
      text-align: center;
    }
    .date-label {
      font-weight: bold;
      color: #666;
      font-size: 14px;
    }
    .date-value {
      font-size: 16px;
      color: #333;
    }
    .items-table {
      width: 100%;
      border-collapse: collapse;
      margin: 30px 0;
    }
    .items-table th {
      background: #007bff;
      color: white;
      padding: 12px;
      text-align: left;
      font-weight: bold;
    }
    .items-table td {
      padding: 12px;
      border-bottom: 1px solid #ddd;
    }
    .items-table tr:nth-child(even) {
      background: #f8f9fa;
    }
    .amount {
      text-align: right;
      font-family: 'Courier New', monospace;
    }
    .totals {
      float: right;
      width: 300px;
      margin-top: 20px;
    }
    .total-row {
      display: flex;
      justify-content: space-between;
      padding: 8px 0;
      border-bottom: 1px solid #eee;
    }
    .total-row.final {
      border-top: 2px solid #007bff;
      border-bottom: 2px solid #007bff;
      font-weight: bold;
      font-size: 18px;
      color: #007bff;
    }
    .notes {
      margin-top: 60px;
      clear: both;
    }
    .notes-title {
      font-weight: bold;
      color: #007bff;
      margin-bottom: 10px;
    }
    .notes-content {
      background: #f8f9fa;
      padding: 15px;
      border-radius: 5px;
      border-left: 4px solid #007bff;
    }
    @media print {
      body { margin: 0; padding: 15px; }
    }
  </style>
</head>
<body>
  <div class="header">
    <div>
      <h1 class="invoice-title">INVOICE</h1>
      <div class="invoice-number">#${data.invoiceNumber}</div>
    </div>
  </div>

  <div style="display: flex; justify-content: space-between;">
    <div class="business-info" style="width: 48%;">
      <div class="info-label">From:</div>
      <div class="info-content">
        <strong>${data.businessInfo.name}</strong><br>
        ${data.businessInfo.address.replace(/\n/g, "<br>")}<br>
        ${data.businessInfo.email}<br>
        ${data.businessInfo.phone}
      </div>
    </div>

    <div class="client-info" style="width: 48%;">
      <div class="info-label">Bill To:</div>
      <div class="info-content">
        <strong>${data.clientInfo.name}</strong><br>
        ${data.clientInfo.address.replace(/\n/g, "<br>")}<br>
        ${data.clientInfo.email}
      </div>
    </div>
  </div>

  <div class="dates">
    <div class="date-item">
      <div class="date-label">Issue Date</div>
      <div class="date-value">${data.issueDate}</div>
    </div>
    <div class="date-item">
      <div class="date-label">Due Date</div>
      <div class="date-value">${data.dueDate}</div>
    </div>
  </div>

  <table class="items-table">
    <thead>
      <tr>
        <th>Description</th>
        <th style="width: 80px;">Qty</th>
        <th style="width: 100px;">Rate</th>
        <th style="width: 100px;">Amount</th>
      </tr>
    </thead>
    <tbody>
      ${data.items
        .map(
          (item) => `
        <tr>
          <td>${item.description}</td>
          <td class="amount">${item.quantity}</td>
          <td class="amount">$${item.rate.toFixed(2)}</td>
          <td class="amount">$${item.amount.toFixed(2)}</td>
        </tr>
      `
        )
        .join("")}
    </tbody>
  </table>

  <div class="totals">
    <div class="total-row">
      <span>Subtotal:</span>
      <span>$${data.subtotal.toFixed(2)}</span>
    </div>
    ${
      data.discountAmount > 0
        ? `
    <div class="total-row">
      <span>Discount (${data.discountRate}%):</span>
      <span>-$${data.discountAmount.toFixed(2)}</span>
    </div>
    `
        : ""
    }
    ${
      data.taxAmount > 0
        ? `
    <div class="total-row">
      <span>Tax (${data.taxRate}%):</span>
      <span>$${data.taxAmount.toFixed(2)}</span>
    </div>
    `
        : ""
    }
    <div class="total-row final">
      <span>Total:</span>
      <span>$${data.total.toFixed(2)}</span>
    </div>
  </div>

  ${
    data.notes
      ? `
  <div class="notes">
    <div class="notes-title">Notes:</div>
    <div class="notes-content">${data.notes.replace(/\n/g, "<br>")}</div>
  </div>
  `
      : ""
  }
</body>
</html>
  `;
}
