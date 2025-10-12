/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import * as dotenv from "dotenv";
import { setGlobalOptions } from "firebase-functions";
import {
  getConfigSummary,
  validateProductionConfig,
} from "./config/validation";

// Load environment variables based on environment
const isStaging =
  process.env.FIREBASE_CONFIG?.includes("toolz-space-staging") ||
  process.env.FIREBASE_PROJECT_ID === "toolz-space-staging";

if (isStaging) {
  dotenv.config({ path: ".env.staging" });
  console.log("🔧 STAGING MODE: Loaded .env.staging configuration");
  console.log("🧪 Using TEST Stripe keys and staging Firebase project");
} else {
  dotenv.config();
}

// Log configuration summary (without sensitive values)
console.log("� Configuration summary:", getConfigSummary());

// Only validate production config if not in staging
if (!isStaging) {
  validateProductionConfig();
} else {
  console.log("⚠️ STAGING: Skipping production config validation");
}

// Start writing functions
// https://firebase.google.com/docs/functions/typescript

// For cost control, you can set the maximum number of containers that can be
// running at the same time. This helps mitigate the impact of unexpected
// traffic spikes by instead downgrading performance. This limit is a
// per-function limit. You can override the limit for each function using the
// `maxInstances` option in the function's options, e.g.
// `onRequest({ maxInstances: 5 }, (req, res) => { ... })`.
// NOTE: setGlobalOptions does not apply to functions using the v1 API. V1
// functions should each use functions.runWith({ maxInstances: 10 }) instead.
// In the v1 API, each function can only serve one request per container, so
// this will be the maximum concurrent request count.
setGlobalOptions({ maxInstances: 10 });

// Export billing functions
export {
  createCheckoutSession,
  createCheckoutSessionHttp,
} from "./billing/createCheckoutSession";
export { createPortalLink } from "./billing/createPortalLink";
export { updateUserPlan } from "./billing/updateUserPlan"; // Temporary function for testing
export { stripeWebhook } from "./billing/webhook";

// Export health check
export { health } from "./health";

// Export legacy quota function (deprecated - for backward compatibility)
export { getQuotaStatus } from "./tools/quota/getQuotaStatus";

// Export Invoice Lite functions
export { generateInvoicePdf } from "./tools/invoice_lite/generatePdf";
export {
  createInvoicePaymentLink,
  deactivatePaymentLink,
} from "./tools/invoice_lite/paymentLink";

// Temporary functions for manual plan updates
export { quickUpdateUserPlan, updateRecentUsersToProPlan } from "./quickUpdate";

// export const helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
