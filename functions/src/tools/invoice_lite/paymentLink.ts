import * as functions from "firebase-functions/v1";
import * as admin from "firebase-admin";
import Stripe from "stripe";

const stripe = new Stripe(
  process.env.STRIPE_SECRET_KEY ||
    process.env.STRIPE_SECRET ||
    functions.config().stripe?.secret_key ||
    functions.config().stripe?.secret ||
    "",
  {
    apiVersion: "2025-09-30.clover",
  }
);

interface PaymentLinkData {
  invoiceNumber: string;
  clientEmail: string;
  amount: number; // in cents
  description: string;
  dueDate?: string;
}

interface PaymentLinkResponse {
  success: boolean;
  paymentUrl: string;
  paymentLinkId: string;
}

/**
 * Create Stripe payment link for invoice
 * Requires authentication and Pro plan
 */
export const createInvoicePaymentLink = functions
  .runWith({
    memory: "512MB",
    timeoutSeconds: 60,
  })
  .https.onCall(
    async (
      data: PaymentLinkData,
      context: functions.https.CallableContext
    ): Promise<PaymentLinkResponse> => {
      // Validate authentication
      if (!context.auth) {
        throw new functions.https.HttpsError(
          "unauthenticated",
          "Authentication required to create payment link"
        );
      }

      // Check Pro plan requirement
      const userId = context.auth.uid;
      const userDoc = await admin.firestore().doc(`users/${userId}`).get();
      const userData = userDoc.data();

      if (!userData?.billing?.plan || userData.billing.plan !== "pro") {
        throw new functions.https.HttpsError(
          "permission-denied",
          "Pro plan required for payment link generation"
        );
      }

      // Validate input
      if (
        !data.invoiceNumber ||
        !data.clientEmail ||
        !data.amount ||
        data.amount <= 0
      ) {
        throw new functions.https.HttpsError(
          "invalid-argument",
          "Valid invoice number, client email, and amount are required"
        );
      }

      if (data.amount > 50000000) {
        // $500,000 limit
        throw new functions.https.HttpsError(
          "invalid-argument",
          "Amount exceeds maximum limit"
        );
      }

      try {
        // Create a product for this invoice
        const product = await stripe.products.create({
          name: `Invoice ${data.invoiceNumber}`,
          description:
            data.description || `Payment for Invoice ${data.invoiceNumber}`,
          metadata: {
            invoiceNumber: data.invoiceNumber,
            userId: userId,
            clientEmail: data.clientEmail,
          },
        });

        // Create a price for the product
        const price = await stripe.prices.create({
          unit_amount: data.amount,
          currency: "usd",
          product: product.id,
          metadata: {
            invoiceNumber: data.invoiceNumber,
            userId: userId,
          },
        });

        // Create the payment link
        const paymentLink = await stripe.paymentLinks.create({
          line_items: [
            {
              price: price.id,
              quantity: 1,
            },
          ],
          metadata: {
            invoiceNumber: data.invoiceNumber,
            userId: userId,
            clientEmail: data.clientEmail,
            dueDate: data.dueDate || "",
          },
          after_completion: {
            type: "hosted_confirmation",
            hosted_confirmation: {
              custom_message: `Thank you for your payment for Invoice ${data.invoiceNumber}!`,
            },
          },
          allow_promotion_codes: false,
          billing_address_collection: "required",
          customer_creation: "always",
        });

        // Store payment link info in Firestore
        await admin
          .firestore()
          .collection("invoicePaymentLinks")
          .add({
            userId: userId,
            invoiceNumber: data.invoiceNumber,
            clientEmail: data.clientEmail,
            amount: data.amount,
            stripePaymentLinkId: paymentLink.id,
            paymentUrl: paymentLink.url,
            active: true,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            dueDate: data.dueDate || null,
          });

        // Log usage
        await admin
          .firestore()
          .collection("usage")
          .add({
            userId: userId,
            action: "invoice_payment_link_created",
            timestamp: admin.firestore.FieldValue.serverTimestamp(),
            metadata: {
              invoiceNumber: data.invoiceNumber,
              amount: data.amount,
              clientEmail: data.clientEmail,
              paymentLinkId: paymentLink.id,
            },
          });

        return {
          success: true,
          paymentUrl: paymentLink.url,
          paymentLinkId: paymentLink.id,
        };
      } catch (error) {
        console.error("Error creating payment link:", error);

        if (error instanceof Stripe.errors.StripeError) {
          throw new functions.https.HttpsError(
            "invalid-argument",
            `Stripe error: ${error.message}`
          );
        }

        throw new functions.https.HttpsError(
          "internal",
          "Failed to create payment link"
        );
      }
    }
  );

/**
 * Deactivate a payment link
 * Requires authentication and ownership
 */
export const deactivatePaymentLink = functions
  .runWith({
    memory: "256MB",
    timeoutSeconds: 30,
  })
  .https.onCall(
    async (
      data: { paymentLinkId: string },
      context: functions.https.CallableContext
    ) => {
      // Validate authentication
      if (!context.auth) {
        throw new functions.https.HttpsError(
          "unauthenticated",
          "Authentication required"
        );
      }

      const userId = context.auth.uid;

      if (!data.paymentLinkId) {
        throw new functions.https.HttpsError(
          "invalid-argument",
          "Payment link ID is required"
        );
      }

      try {
        // Check ownership
        const paymentLinkQuery = await admin
          .firestore()
          .collection("invoicePaymentLinks")
          .where("userId", "==", userId)
          .where("stripePaymentLinkId", "==", data.paymentLinkId)
          .where("active", "==", true)
          .limit(1)
          .get();

        if (paymentLinkQuery.empty) {
          throw new functions.https.HttpsError(
            "not-found",
            "Payment link not found or already deactivated"
          );
        }

        // Deactivate in Stripe
        await stripe.paymentLinks.update(data.paymentLinkId, {
          active: false,
        });

        // Update in Firestore
        const docRef = paymentLinkQuery.docs[0].ref;
        await docRef.update({
          active: false,
          deactivatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        return {
          success: true,
          message: "Payment link deactivated successfully",
        };
      } catch (error) {
        console.error("Error deactivating payment link:", error);

        if (error instanceof Stripe.errors.StripeError) {
          throw new functions.https.HttpsError(
            "invalid-argument",
            `Stripe error: ${error.message}`
          );
        }

        throw new functions.https.HttpsError(
          "internal",
          "Failed to deactivate payment link"
        );
      }
    }
  );
