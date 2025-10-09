# Billing & Stripe Integration Documentation

Complete guide for Firebase UID ↔ Stripe customer linking and subscription management.

## Overview

Our billing system creates a robust link between Firebase Authentication and Stripe:

- **Firebase UID** = Primary identifier for users
- **Stripe Customer ID** = Stripe's customer identifier
- **Bidirectional Linking** = Firebase→Stripe and Stripe→Firebase metadata
- **Webhook-Driven** = Subscription state synced via Stripe webhooks

## Architecture

```
┌─────────────────┐         ┌──────────────────┐         ┌─────────────────┐
│ Firebase Auth   │         │ Cloud Functions  │         │ Stripe API      │
│                 │         │                  │         │                 │
│ UID: alice123   │◄───────►│ createCheckout   │────────►│ Customer        │
│ Email: alice@.. │         │ webhook          │         │ ID: cus_abc123  │
│ Verified: true  │         │ portalLink       │         │ Meta: uid       │
└─────────────────┘         └──────────────────┘         └─────────────────┘
         │                           │                            │
         │                           ▼                            │
         │                  ┌──────────────────┐                 │
         └─────────────────►│ Firestore        │◄────────────────┘
                            │ /users/{uid}/    │
                            │   billing/       │
                            │     profile      │
                            └──────────────────┘
```

## Firebase UID → Stripe Customer Linking

### Creating Checkout Sessions

When a user upgrades, we create a Stripe checkout session with Firebase UID in metadata:

**File**: `functions/src/billing/createCheckoutSession.ts`

```typescript
export const createCheckoutSession = onCall(
  { cors: true },
  async (request) => {
    const userId = request.auth?.uid;
    const planId = request.data.planId;

    // Get or create Stripe customer
    const billingRef = db.doc(`users/${userId}/billing/profile`);
    const billingDoc = await billingRef.get();
    let customerId = billingDoc.data()?.stripeCustomerId;

    if (!customerId) {
      // Create new Stripe customer
      const customer = await stripe.customers.create({
        email: request.auth.token.email,
        metadata: {
          firebaseUserId: userId,  // 🔑 KEY LINK
          uid: userId,              // 🔑 BACKUP LINK
        },
      });
      customerId = customer.id;

      // Save to Firestore
      await billingRef.set({
        stripeCustomerId: customerId,
        ...
      }, { merge: true });
    }

    // Create checkout session
    const session = await stripe.checkout.sessions.create({
      customer: customerId,
      client_reference_id: userId,  // 🔑 TERTIARY LINK
      metadata: {
        userId,                      // 🔑 PRIMARY LINK
        firebaseUid: userId,         // 🔑 SECONDARY LINK
        planId,
      },
      ...
    });

    return { url: session.url };
  }
);
```

### Multiple Link Points

We store Firebase UID in **three places** for robustness:

1. **`session.metadata.userId`** - Primary source
2. **`session.metadata.firebaseUid`** - Secondary source
3. **`session.client_reference_id`** - Tertiary fallback

This redundancy ensures we never lose the UID mapping.

## Stripe → Firebase UID Resolution

### Webhook Event Processing

When Stripe webhooks arrive, we resolve Firebase UID using a waterfall approach:

**File**: `functions/src/billing/webhook.ts`

```typescript
async function handleSubscriptionUpdated(event: Stripe.Event) {
  const subscription = event.data.object as Stripe.Subscription;

  // Try multiple ways to get Firebase UID
  let userId =
    subscription.metadata?.userId ||          // Try subscription metadata first
    subscription.metadata?.firebaseUid;       // Try alternate key

  // If not in subscription, check customer metadata
  if (!userId && subscription.customer) {
    const customer = await stripe.customers.retrieve(
      subscription.customer as string
    );
    if (!customer.deleted) {
      userId =
        customer.metadata?.firebaseUserId ||  // Try customer metadata
        customer.metadata?.uid;               // Try alternate key
    }
  }

  if (!userId) {
    functions.logger.error("Cannot find Firebase UID", {
      subscriptionId: subscription.id,
      customerId: subscription.customer,
    });
    return;
  }

  // Update Firestore with subscription data
  const billingRef = db.doc(`users/${userId}/billing/profile`);
  await billingRef.set({
    stripeCustomerId: subscription.customer,
    planId: subscription.metadata?.planId || 'free',
    status: mapStripeStatus(subscription.status),
    currentPeriodEnd: subscription.current_period_end * 1000,
    ...
  }, { merge: true });
}
```

### UID Resolution Priority

```
1. subscription.metadata.userId
2. subscription.metadata.firebaseUid
3. customer.metadata.firebaseUserId
4. customer.metadata.uid
```

If all fail, we log an error and skip the update.

## Subscription Lifecycle Management

### States & Transitions

```
FREE (Initial)
  │
  ├─► CHECKOUT ─────► TRIALING ─────► ACTIVE ──┐
  │                      │              │       │
  │                      ▼              ▼       ▼
  │                   ACTIVE    ────► PAST_DUE ─► CANCELED
  │                                      │
  └──────────────────────────────────────┘
```

### Webhook Events We Handle

| Event                           | Handler                      | Action                                   |
| ------------------------------- | ---------------------------- | ---------------------------------------- |
| `checkout.session.completed`    | `handleCheckoutCompleted`    | Log completion, update customer metadata |
| `customer.subscription.created` | `handleSubscriptionUpdated`  | Create billing profile                   |
| `customer.subscription.updated` | `handleSubscriptionUpdated`  | Update billing profile                   |
| `customer.subscription.deleted` | `handleSubscriptionDeleted`  | Downgrade to free                        |
| `invoice.paid`                  | `handleInvoicePaid`          | Log payment (no action)                  |
| `invoice.payment_failed`        | `handleInvoicePaymentFailed` | Log failure, Stripe updates status       |

### Status Mapping

**File**: `functions/src/billing/webhook.ts`

```typescript
function mapStripeStatus(
  stripeStatus: Stripe.Subscription.Status
): BillingProfile["status"] {
  switch (stripeStatus) {
    case "active":
      return "active";
    case "trialing":
      return "trialing";
    case "past_due":
      return "past_due";
    case "canceled":
      return "canceled";
    case "unpaid":
      return "unpaid";
    case "incomplete":
      return "incomplete";
    case "incomplete_expired":
      return "incomplete_expired";
    default:
      return "free";
  }
}
```

## Webhook Configuration

### Stripe Dashboard Setup

1. Go to [Stripe Dashboard](https://dashboard.stripe.com/) → **Developers** → **Webhooks**
2. Click **Add endpoint**
3. Configure endpoint:

   - **URL**: `https://your-region-your-project.cloudfunctions.net/api/billing/webhook`
   - **Events**: Select these events:
     - `checkout.session.completed`
     - `customer.subscription.created`
     - `customer.subscription.updated`
     - `customer.subscription.deleted`
     - `invoice.paid`
     - `invoice.payment_failed`

4. Copy **Signing secret** (starts with `whsec_`)
5. Add to Firebase config:

```bash
firebase functions:config:set stripe.webhook_secret="whsec_..."
```

### Testing Webhooks Locally

Use Stripe CLI to forward webhooks to local emulator:

```bash
# Install Stripe CLI
# https://stripe.com/docs/stripe-cli

# Login
stripe login

# Forward webhooks to local functions
stripe listen --forward-to http://localhost:5001/your-project/us-central1/api/billing/webhook

# Trigger test events
stripe trigger checkout.session.completed
stripe trigger customer.subscription.updated
```

### Webhook Signature Verification

**File**: `functions/src/billing/webhook.ts`

```typescript
export const webhook = functions.https.onRequest(async (req, res) => {
  const sig = req.headers["stripe-signature"];

  if (!sig) {
    res.status(400).send("Missing signature");
    return;
  }

  let event: Stripe.Event;

  try {
    // Verify webhook signature
    event = stripe.webhooks.constructEvent(req.rawBody, sig, webhookSecret);
  } catch (err: any) {
    functions.logger.error("Webhook verification failed", {
      error: err.message,
    });
    res.status(400).send(`Webhook Error: ${err.message}`);
    return;
  }

  // Process verified event
  await handleWebhookEvent(event);
  res.json({ received: true });
});
```

## Anonymous User Migration (Future Feature)

### Problem

Users might start with anonymous auth, then sign up with email later. We need to migrate their Stripe customer to the new UID.

### Solution (Not Yet Implemented)

```typescript
async function migrateAnonymousUserBilling(
  anonymousUid: string,
  newUid: string
) {
  // 1. Get anonymous user's billing profile
  const anonBillingRef = db.doc(`users/${anonymousUid}/billing/profile`);
  const anonBilling = await anonBillingRef.get();

  if (!anonBilling.exists) return; // No billing to migrate

  const customerId = anonBilling.data()?.stripeCustomerId;
  if (!customerId) return;

  // 2. Update Stripe customer metadata
  await stripe.customers.update(customerId, {
    metadata: {
      firebaseUserId: newUid,
      uid: newUid,
      migratedFrom: anonymousUid,
    },
  });

  // 3. Copy billing data to new UID
  const newBillingRef = db.doc(`users/${newUid}/billing/profile`);
  await newBillingRef.set(anonBilling.data(), { merge: true });

  // 4. Archive old billing data
  await anonBillingRef.update({
    migratedTo: newUid,
    migratedAt: Date.now(),
  });

  functions.logger.info("Migrated anonymous user billing", {
    from: anonymousUid,
    to: newUid,
    customerId,
  });
}
```

### Trigger Migration

Call during account linking:

```dart
// In AuthService.linkWithCredential
await migrateAnonymousUserBilling(
  anonymousUid: oldUid,
  newUid: currentUser.uid,
);
```

## Customer Portal Integration

### Creating Portal Sessions

**File**: `functions/src/billing/createPortalLink.ts`

```typescript
export const createPortalLink = onCall(
  withAuth, // Requires authentication
  async (request) => {
    const userId = request.auth.uid;
    const returnUrl = request.data.returnUrl;

    // Get customer ID from Firestore
    const billingRef = db.doc(`users/${userId}/billing/profile`);
    const billing = await billingRef.get();
    const customerId = billing.data()?.stripeCustomerId;

    if (!customerId) {
      throw new HttpsError("failed-precondition", "No billing profile found");
    }

    // Create portal session
    const session = await stripe.billingPortal.sessions.create({
      customer: customerId,
      return_url: returnUrl,
    });

    return { url: session.url };
  }
);
```

### Usage in Flutter

**File**: `lib/billing/billing_service.dart`

```dart
Future<String> createPortalLink(String returnUrl) async {
  final result = await _functions
      .httpsCallable('billing-createPortalLink')
      .call({'returnUrl': returnUrl});

  return result.data['url'] as String;
}
```

## Data Model

### Firestore Structure

```
/users/{uid}/billing/
  ├── profile (document)
  │   ├── stripeCustomerId: string
  │   ├── planId: 'free' | 'pro' | 'pro_plus'
  │   ├── status: 'active' | 'trialing' | 'past_due' | ...
  │   ├── currentPeriodStart: timestamp
  │   ├── currentPeriodEnd: timestamp
  │   ├── trialEnd: timestamp?
  │   ├── cancelAtPeriodEnd: boolean
  │   ├── createdAt: timestamp
  │   └── updatedAt: timestamp
  │
  ├── usage/
  │   └── {YYYY-MM-DD} (documents)
  │       ├── date: string
  │       ├── heavyOps: number
  │       ├── storageBytes: number
  │       └── updatedAt: timestamp
  │
  └── entitlements/ (computed from plan)
      └── current (document)
          ├── heavyOpsPerDay: number
          ├── storageGB: number
          ├── features: string[]
          └── updatedAt: timestamp
```

### Stripe Metadata Structure

**Customer Object**:

```json
{
  "id": "cus_abc123",
  "email": "alice@example.com",
  "metadata": {
    "firebaseUserId": "alice-firebase-uid",
    "uid": "alice-firebase-uid"
  }
}
```

**Subscription Object**:

```json
{
  "id": "sub_xyz789",
  "customer": "cus_abc123",
  "metadata": {
    "userId": "alice-firebase-uid",
    "firebaseUid": "alice-firebase-uid",
    "planId": "pro"
  }
}
```

## Testing

### Unit Tests

Test UID resolution logic:

```typescript
describe("UID Resolution", () => {
  it("should resolve from subscription.metadata.userId", () => {
    const subscription = {
      metadata: { userId: "alice123" },
    };
    expect(resolveUserId(subscription)).toBe("alice123");
  });

  it("should fallback to customer metadata", async () => {
    const subscription = {
      customer: "cus_123",
      metadata: {},
    };
    // Mock Stripe API
    stripe.customers.retrieve.mockResolvedValue({
      metadata: { firebaseUserId: "alice123" },
    });

    expect(await resolveUserId(subscription)).toBe("alice123");
  });
});
```

### Integration Tests

Test full checkout flow:

1. User signs up with email
2. User upgrades to Pro
3. Checkout session created with correct metadata
4. Webhook updates Firestore correctly
5. User sees updated plan in app

## Monitoring & Debugging

### Check Linking Status

```bash
# Firebase Firestore
firebase firestore:get users/alice123/billing/profile

# Stripe Customer
stripe customers retrieve cus_abc123
```

### Common Issues

**Issue**: Webhook shows "Cannot find Firebase UID"

**Solution**: Check Stripe customer/subscription metadata. Update manually if needed:

```bash
stripe customers update cus_abc123 --metadata firebaseUserId=alice123
stripe subscriptions update sub_xyz789 --metadata userId=alice123
```

**Issue**: Billing profile not updating

**Solution**:

1. Check webhook endpoint is reachable
2. Verify webhook secret is correct
3. Check Cloud Functions logs for errors

## Production Checklist

- [ ] Webhook endpoint configured in Stripe Dashboard
- [ ] Webhook secret set in Firebase config
- [ ] Customer metadata includes Firebase UID
- [ ] Subscription metadata includes Firebase UID
- [ ] Email verification enforced before checkout
- [ ] Portal return URL configured correctly
- [ ] All webhook events being processed
- [ ] Audit logs enabled for billing events

## Support & Resources

- [Stripe Webhooks Guide](https://stripe.com/docs/webhooks)
- [Stripe Customer Portal](https://stripe.com/docs/billing/subscriptions/customer-portal)
- [Firebase Cloud Functions](https://firebase.google.com/docs/functions)

---

**Last Updated**: October 2025
**Version**: 1.0.0
**Status**: Production Ready
