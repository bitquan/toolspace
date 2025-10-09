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
  validateProductionConfig,
  getConfigSummary,
} from "./config/validation";

// Load environment variables from .env file
dotenv.config();

// Validate production configuration on startup
console.log("🔍 Validating production configuration...");
console.log("📊 Configuration summary:", getConfigSummary());
validateProductionConfig();

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
export { createCheckoutSession } from "./billing/createCheckoutSession";
export { createPortalLink } from "./billing/createPortalLink";
export { webhook as stripeWebhook } from "./billing/webhook";

// Export legacy quota function (deprecated - for backward compatibility)
export { getQuotaStatus } from "./tools/quota/getQuotaStatus";

// export const helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
