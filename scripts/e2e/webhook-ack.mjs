#!/usr/bin/env node

/**
 * E2E Webhook Acknowledgment Test
 * Tests webhook event processing and idempotency
 */

import crypto from "crypto";
import fs from "fs/promises";
import fetch from "node-fetch";
import { dirname, join } from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Test configuration
const CONFIG = {
  functionsUrl:
    process.env.FUNCTIONS_URL ||
    "http://localhost:5001/toolz-space-staging/us-central1",
  webhookSecret: process.env.STRIPE_WEBHOOK_SECRET || "whsec_test_local_secret",
  timeout: 10000,
};

// Sample webhook events for testing
const SAMPLE_EVENTS = {
  "checkout.session.completed": {
    id: "evt_test_checkout_completed",
    object: "event",
    type: "checkout.session.completed",
    created: Math.floor(Date.now() / 1000),
    data: {
      object: {
        id: "cs_test_checkout_session",
        object: "checkout.session",
        customer: "cus_test_customer",
        subscription: "sub_test_subscription",
        metadata: {
          uid: "test-user-uid-123",
        },
        amount_total: 999,
        currency: "usd",
        payment_status: "paid",
      },
    },
  },
  "customer.subscription.created": {
    id: "evt_test_subscription_created",
    object: "event",
    type: "customer.subscription.created",
    created: Math.floor(Date.now() / 1000),
    data: {
      object: {
        id: "sub_test_subscription",
        object: "subscription",
        customer: "cus_test_customer",
        status: "active",
        items: {
          data: [
            {
              price: {
                id: "price_test_pro",
                nickname: "Pro Plan",
              },
            },
          ],
        },
        metadata: {
          uid: "test-user-uid-123",
        },
      },
    },
  },
  "invoice.payment_succeeded": {
    id: "evt_test_payment_succeeded",
    object: "event",
    type: "invoice.payment_succeeded",
    created: Math.floor(Date.now() / 1000),
    data: {
      object: {
        id: "in_test_invoice",
        object: "invoice",
        customer: "cus_test_customer",
        subscription: "sub_test_subscription",
        amount_paid: 999,
        currency: "usd",
        paid: true,
        status: "paid",
      },
    },
  },
};

class WebhookAckTest {
  constructor() {
    this.results = {
      timestamp: new Date().toISOString(),
      tests: [],
      success: false,
      errors: [],
    };
  }

  async log(test, status, details = "") {
    const entry = {
      test,
      status,
      details,
      timestamp: new Date().toISOString(),
    };
    this.results.tests.push(entry);
    console.log(`[${status.toUpperCase()}] ${test}: ${details}`);
  }

  generateStripeSignature(payload, secret) {
    const timestamp = Math.floor(Date.now() / 1000);
    const signedPayload = `${timestamp}.${payload}`;
    const signature = crypto
      .createHmac("sha256", secret)
      .update(signedPayload, "utf8")
      .digest("hex");

    return {
      timestamp,
      signature: `t=${timestamp},v1=${signature}`,
    };
  }

  async testWebhookEvent(eventType, eventData) {
    try {
      await this.log(`webhook-${eventType}`, "start", "Sending webhook event");

      const payload = JSON.stringify(eventData);
      const { signature } = this.generateStripeSignature(
        payload,
        CONFIG.webhookSecret
      );

      const response = await fetch(`${CONFIG.functionsUrl}/stripeWebhook`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Stripe-Signature": signature,
          "User-Agent": "Stripe/1.0 (+https://stripe.com/docs/webhooks)",
        },
        body: payload,
      });

      const responseText = await response.text();

      if (response.status === 200) {
        await this.log(
          `webhook-${eventType}`,
          "success",
          `Event processed: ${response.status}`
        );
        return {
          success: true,
          status: response.status,
          response: responseText,
        };
      } else {
        await this.log(
          `webhook-${eventType}`,
          "error",
          `Unexpected status: ${response.status} - ${responseText}`
        );
        this.results.errors.push(
          `${eventType}: ${response.status} - ${responseText}`
        );
        return {
          success: false,
          status: response.status,
          response: responseText,
        };
      }
    } catch (error) {
      await this.log(`webhook-${eventType}`, "error", error.message);
      this.results.errors.push(`${eventType}: ${error.message}`);
      return { success: false, error: error.message };
    }
  }

  async testIdempotency(eventType, eventData) {
    try {
      await this.log(
        `idempotency-${eventType}`,
        "start",
        "Testing idempotent replay"
      );

      const payload = JSON.stringify(eventData);
      const { signature } = this.generateStripeSignature(
        payload,
        CONFIG.webhookSecret
      );

      // Send the same event twice
      const response1 = await fetch(`${CONFIG.functionsUrl}/stripeWebhook`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Stripe-Signature": signature,
        },
        body: payload,
      });

      const response2 = await fetch(`${CONFIG.functionsUrl}/stripeWebhook`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Stripe-Signature": signature,
        },
        body: payload,
      });

      if (response1.status === 200 && response2.status === 200) {
        await this.log(
          `idempotency-${eventType}`,
          "success",
          "Both requests returned 200 OK"
        );
        return { success: true };
      } else {
        await this.log(
          `idempotency-${eventType}`,
          "error",
          `Status mismatch: ${response1.status}, ${response2.status}`
        );
        return { success: false };
      }
    } catch (error) {
      await this.log(`idempotency-${eventType}`, "error", error.message);
      this.results.errors.push(`Idempotency ${eventType}: ${error.message}`);
      return { success: false };
    }
  }

  async testInvalidSignature() {
    try {
      await this.log(
        "invalid-signature",
        "start",
        "Testing invalid signature rejection"
      );

      const payload = JSON.stringify(
        SAMPLE_EVENTS["checkout.session.completed"]
      );
      const invalidSignature = "t=1234567890,v1=invalid_signature_hash";

      const response = await fetch(`${CONFIG.functionsUrl}/stripeWebhook`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Stripe-Signature": invalidSignature,
        },
        body: payload,
      });

      if (response.status === 400) {
        await this.log(
          "invalid-signature",
          "success",
          "Invalid signature correctly rejected"
        );
        return { success: true };
      } else {
        await this.log(
          "invalid-signature",
          "error",
          `Expected 400, got ${response.status}`
        );
        return { success: false };
      }
    } catch (error) {
      await this.log("invalid-signature", "error", error.message);
      this.results.errors.push(`Invalid signature test: ${error.message}`);
      return { success: false };
    }
  }

  async testWebhookEndpoint() {
    try {
      await this.log(
        "endpoint-health",
        "start",
        "Testing webhook endpoint health"
      );

      const response = await fetch(`${CONFIG.functionsUrl}/stripeWebhook`, {
        method: "GET",
      });

      if (response.status === 405) {
        // Method not allowed for GET
        await this.log("endpoint-health", "success", "Endpoint is responsive");
        return { success: true };
      } else {
        await this.log(
          "endpoint-health",
          "warning",
          `Unexpected GET response: ${response.status}`
        );
        return { success: true }; // Still consider this OK
      }
    } catch (error) {
      await this.log("endpoint-health", "error", error.message);
      this.results.errors.push(`Endpoint health: ${error.message}`);
      return { success: false };
    }
  }

  async run() {
    console.log("🧪 Starting E2E Webhook Acknowledgment Test...");
    console.log(`🔧 Functions URL: ${CONFIG.functionsUrl}`);
    console.log(
      `🔐 Webhook Secret: ${CONFIG.webhookSecret.substring(0, 10)}...`
    );

    const testResults = [];

    try {
      // Test 1: Endpoint health
      const healthResult = await this.testWebhookEndpoint();
      testResults.push(healthResult);

      // Test 2: Invalid signature rejection
      const invalidSigResult = await this.testInvalidSignature();
      testResults.push(invalidSigResult);

      // Test 3: Process each event type
      for (const [eventType, eventData] of Object.entries(SAMPLE_EVENTS)) {
        const eventResult = await this.testWebhookEvent(eventType, eventData);
        testResults.push(eventResult);

        // Test idempotency for this event
        if (eventResult.success) {
          const idempotencyResult = await this.testIdempotency(
            eventType,
            eventData
          );
          testResults.push(idempotencyResult);
        }

        // Small delay between events
        await new Promise((resolve) => setTimeout(resolve, 1000));
      }

      // Determine overall success
      this.results.success = testResults.every((result) => result.success);

      await this.log(
        "test-complete",
        "success",
        `Overall success: ${this.results.success}`
      );
    } catch (error) {
      await this.log("test-error", "error", error.message);
      this.results.errors.push(error.message);
      this.results.success = false;
    }

    return this.results;
  }

  async saveResults() {
    try {
      const resultsPath = join(
        process.cwd(),
        "dev-log/phase-4/webhook-e2e-results.json"
      );
      await fs.mkdir(dirname(resultsPath), { recursive: true });
      await fs.writeFile(resultsPath, JSON.stringify(this.results, null, 2));
      console.log(`📄 Results saved to: ${resultsPath}`);
    } catch (error) {
      console.error(`❌ Failed to save results: ${error.message}`);
    }
  }
}

// Run the test if called directly
if (import.meta.url === `file://${process.argv[1]}`) {
  const test = new WebhookAckTest();

  test
    .run()
    .then(async (results) => {
      await test.saveResults();

      console.log("\n🏁 Test Summary:");
      console.log(`✅ Success: ${results.success}`);
      console.log(`📝 Tests: ${results.tests.length}`);
      console.log(`❌ Errors: ${results.errors.length}`);

      if (results.errors.length > 0) {
        console.log("\n❌ Errors:");
        results.errors.forEach((error, i) => {
          console.log(`  ${i + 1}. ${error}`);
        });
      }

      process.exit(results.success ? 0 : 1);
    })
    .catch((error) => {
      console.error("💥 Test crashed:", error);
      process.exit(1);
    });
}

export default WebhookAckTest;
