import * as functions from "firebase-functions";

/**
 * Health check endpoint for monitoring deployment status
 */
export const health = functions.https.onRequest((req, res) => {
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Access-Control-Allow-Methods", "GET");
  res.setHeader("Access-Control-Allow-Headers", "Content-Type");

  if (req.method === "OPTIONS") {
    res.status(200).end();
    return;
  }

  if (req.method !== "GET") {
    res.status(405).json({ error: "Method not allowed" });
    return;
  }

  const healthData = {
    ok: true,
    timestamp: new Date().toISOString(),
    stripe: process.env.STRIPE_SECRET_KEY?.startsWith("sk_test_")
      ? "test"
      : "live",
    authEmulator: false,
    environment: process.env.NODE_ENV || "production",
    functions: {
      region: "us-central1",
      runtime: "nodejs18",
    },
  };

  res.status(200).json(healthData);
});
