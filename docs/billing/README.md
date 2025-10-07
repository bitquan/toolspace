# Billing System Documentation

**Version:** 1.0.0
**Last Updated:** October 6, 2025

---

## 📋 Overview

Toolspace implements a Stripe-based subscription system with three tiers: Free, Pro, and Pro+. The system enforces quotas on heavy operations, file sizes, and batch processing.

---

## 🎯 Plans & Pricing

### Free Plan - $0/month

- ✅ Access to all 17 tools
- ✅ 3 heavy operations per day
- ✅ Files up to 10MB
- ✅ Single file processing only
- ✅ Community support

**Heavy Operations:**

- File Merger
- Image Resizer
- Markdown to PDF
- Batch QR Generator
- JSON to CSV Export

### Pro Plan - $9/month

- ✅ Everything in Free
- ✅ 200 heavy operations per day
- ✅ Files up to 50MB
- ✅ Batch processing (up to 20 items)
- ✅ Export batch results
- ✅ Email support

### Pro+ Plan - $19/month

- ✅ Everything in Pro
- ✅ 2,000 heavy operations per day
- ✅ Files up to 100MB
- ✅ Batch processing (up to 100 items)
- ✅ Priority queue (faster processing)
- ✅ Priority email support

---

## 🚀 Setup Guide

### Prerequisites

1. **Stripe Account**: Create at [stripe.com](https://stripe.com)
2. **Stripe CLI**: Install for local webhook testing

   ```bash
   # Windows (with Scoop)
   scoop install stripe

   # macOS
   brew install stripe/stripe-cli/stripe

   # Linux
   # Download from https://github.com/stripe/stripe-cli/releases
   ```

3. **Firebase Project**: With Authentication and Firestore enabled

### Step 1: Create Stripe Products

```bash
# Login to Stripe
stripe login

# Create Pro Product
stripe products create \
  --name="Toolspace Pro" \
  --description="For power users and professionals"

# Note the product ID (prod_xxx), then create price
stripe prices create \
  --product=prod_xxx \
  --unit-amount=900 \
  --currency=usd \
  --recurring=interval=month

# Create Pro+ Product
stripe products create \
  --name="Toolspace Pro+" \
  --description="Maximum power for teams"

# Create Pro+ price
stripe prices create \
  --product=prod_yyy \
  --unit-amount=1900 \
  --currency=usd \
  --recurring=interval=month
```

### Step 2: Update Configuration

Edit `config/pricing.json` and update the Stripe IDs:

```json
{
  "plans": {
    "pro": {
      "stripePriceId": "price_xxx",
      "stripeProductId": "prod_xxx"
    },
    "pro_plus": {
      "stripePriceId": "price_yyy",
      "stripeProductId": "prod_yyy"
    }
  }
}
```

### Step 3: Configure Firebase Functions

Set Stripe secret keys:

```bash
# Test mode keys (for development)
firebase functions:config:set \
  stripe.secret="sk_test_..." \
  stripe.webhook_secret="whsec_..."

# Deploy functions
firebase deploy --only functions
```

### Step 4: Setup Webhook Endpoint

#### For Production:

1. Go to Stripe Dashboard → Developers → Webhooks
2. Add endpoint: `https://yourapp.com/api/billing/webhook`
3. Select events:
   - `checkout.session.completed`
   - `customer.subscription.created`
   - `customer.subscription.updated`
   - `customer.subscription.deleted`
   - `invoice.paid`
   - `invoice.payment_failed`
4. Copy webhook signing secret
5. Update Firebase config:
   ```bash
   firebase functions:config:set stripe.webhook_secret="whsec_..."
   ```

#### For Local Development:

```bash
# Get your Firebase project ID from firebase.json
PROJECT_ID="your-project-id"

# Forward webhooks to local functions emulator
stripe listen --forward-to http://localhost:5001/$PROJECT_ID/us-central1/webhook

# Copy the webhook signing secret shown (starts with whsec_...)
# Update in functions/.env or use firebase functions:config:set
```

**Troubleshooting Webhook Issues:**

- **Webhook not firing**: Check stripe listen output for errors
- **401 Unauthorized**: Verify webhook secret matches between Stripe and Firebase config
- **Function timeout**: Check Firebase Functions logs for errors
- **Profile not updating**: Verify Firestore security rules allow writes to `users/{uid}/billing/profile`

---

## 🧪 Testing

### Test Cards

Stripe provides test cards for different scenarios:

| Card Number           | Scenario                            |
| --------------------- | ----------------------------------- |
| `4242 4242 4242 4242` | Success                             |
| `4000 0000 0000 0002` | Card declined                       |
| `4000 0025 0000 3155` | Requires authentication (3D Secure) |

**Expiry:** Any future date
**CVC:** Any 3 digits
**ZIP:** Any 5 digits

### Test Flow

1. **Free User Journey**:

   ```
   1. Open Toolspace
   2. Try to use File Merger (heavy tool)
   3. Perform 3 operations → quota shown
   4. Try 4th operation → UpgradeSheet appears
   5. Click "Upgrade to Pro"
   6. Complete Stripe checkout with test card
   7. Redirected to /billing/success
   8. File Merger now unlocked with 200 ops/day
   ```

2. **Pro User Journey**:

   ```
   1. Click "Manage Billing" in navbar
   2. Opens Stripe Customer Portal
   3. Can change plan, update payment, view invoices
   4. Cancel subscription → downgraded to Free after period ends
   ```

3. **Quota Reset**:
   ```
   - Daily quotas reset at midnight UTC
   - Usage tracked in Firestore: users/{uid}/usage/{yyyy-mm-dd}
   ```

### Manual Testing Checklist

- [ ] Free user sees "Upgrade" button in navbar
- [ ] Pro/Pro+ user sees "Manage Billing" button
- [ ] Heavy tools show QuotaBanner when < 20% quota remaining
- [ ] Free user blocked at 4th heavy operation
- [ ] Upgrade flow redirects to Stripe, then /billing/success
- [ ] Webhook updates Firestore billing profile
- [ ] Pro features unlock immediately after webhook
- [ ] File size limits enforced (10MB/50MB/100MB)
- [ ] Batch size limits enforced (1/20/100)
- [ ] Customer portal opens correctly
- [ ] Subscription cancellation downgrades plan

---

## 🏗️ Architecture

### Data Flow

```
┌─────────────┐
│   Flutter   │
│     App     │
└──────┬──────┘
       │
       ├─────────► BillingService.createCheckoutSession()
       │           │
       │           ▼
       │    ┌──────────────┐
       │    │   Callable   │
       │    │   Function   │
       │    └──────┬───────┘
       │           │
       │           ▼
       │    ┌──────────────┐
       │    │    Stripe    │
       │    │   Checkout   │
       │    └──────┬───────┘
       │           │
       │           │ (user completes payment)
       │           │
       │           ▼
       │    ┌──────────────┐
       │    │   Webhook    │
       │    │   Handler    │
       │    └──────┬───────┘
       │           │
       │           ▼
       │    ┌──────────────┐
       │    │  Firestore   │
       │    │   Billing    │
       │    │   Profile    │
       │    └──────┬───────┘
       │           │
       ◄───────────┘
       │
   (Stream updates UI)
```

### Firestore Collections

```
users/
  {uid}/
    billing/
      profile                    → BillingProfile document
    usage/
      {yyyy-mm-dd}              → Daily UsageRecord

ops/
  billing_events/
    events/
      {eventId}                 → Audit log
```

### Cloud Functions

- **createCheckoutSession** (Callable)

  - Creates Stripe checkout session
  - Links to Firebase user
  - Returns checkout URL

- **createPortalLink** (Callable)

  - Creates Stripe customer portal session
  - For managing subscription

- **webhook** (HTTP)
  - Processes Stripe events
  - Updates Firestore
  - Logs to audit trail

---

## 📊 Quota Enforcement

### Heavy Operations

```dart
// Check before operation
final check = await billingService.canPerformHeavyOp();
if (!check.allowed) {
  // Show upgrade prompt
  return;
}

// Perform operation
await doHeavyOperation();

// Track usage
await billingService.trackHeavyOp();
```

### File Size Limits

```dart
// Check file size
final check = await billingService.canProcessFileSize(fileBytes.length);
if (!check.allowed) {
  showErrorDialog(check.reason);
  return;
}

// Process file
await processFile(fileBytes);
await billingService.trackFileProcessed(fileBytes.length);
```

### Batch Size Limits

```dart
// Check batch size
final check = await billingService.canProcessBatchSize(files.length);
if (!check.allowed) {
  showErrorDialog(check.reason);
  return;
}

// Process batch
await processBatch(files);
```

---

## 🎨 UI Components

### PaywallGuard

Wraps tool content and checks entitlements:

```dart
PaywallGuard(
  permission: ToolPermission(
    toolId: 'file_merger',
    requiresHeavyOp: true,
  ),
  billingService: billingService,
  child: YourToolUI(),
)
```

### UpgradeSheet

Modal with plan comparison:

```dart
UpgradeSheet.show(
  context,
  billingService: billingService,
  currentPlan: PlanId.free,
);
```

### QuotaBanner

Shows remaining operations:

```dart
QuotaBanner(
  remaining: 2,
  limit: 3,
  currentPlan: PlanId.free,
  onUpgrade: () => showUpgradeSheet(),
)
```

---

## 🐛 Troubleshooting

### Webhook Not Processing

**Symptoms**: Payment completes but user plan not updated

**Solutions**:

1. Check webhook signing secret matches:
   ```bash
   firebase functions:config:get stripe.webhook_secret
   ```
2. View function logs:
   ```bash
   firebase functions:log --only webhook
   ```
3. Verify events are selected in Stripe Dashboard
4. Test locally:
   ```bash
   stripe listen --forward-to http://localhost:5001/.../webhook
   stripe trigger checkout.session.completed
   ```

### Checkout Session Fails

**Symptoms**: Error when clicking "Upgrade"

**Solutions**:

1. Verify Stripe secret key is set
2. Check price IDs in `pricing.json` are valid
3. Ensure user is authenticated
4. Check browser console for errors

### UI Not Updating After Payment

**Symptoms**: Paid but features still locked

**Solutions**:

1. Check webhook processed successfully
2. Verify Firestore document updated:
   - Path: `users/{uid}/billing/profile`
   - Field: `planId` should be "pro" or "pro_plus"
3. Ensure `billingProfileStream` is being listened to
4. Try manual refresh or reload app

### Quota Not Resetting

**Symptoms**: Daily quota doesn't reset at midnight

**Solutions**:

1. Check system timezone (should be UTC)
2. Verify date string format: `yyyy-mm-dd`
3. Ensure new usage document created for new day
4. Check Firestore rules allow writes

---

## 🔒 Security Notes

1. **Webhook Verification**: Always verify Stripe signatures
2. **Firestore Rules**: Restrict billing profile writes to Cloud Functions only
3. **Callable Functions**: Require authentication
4. **Price IDs**: Never expose secret keys in frontend code
5. **Customer Portal**: Use return_url to redirect back to your app

---

## 📈 Analytics & Monitoring

Track these metrics:

- **Conversion Rate**: Free → Pro upgrades
- **Churn Rate**: Pro cancellations
- **Popular Tools**: Which tools drive upgrades
- **Quota Usage**: Average ops/day per plan
- **Failed Payments**: Invoice payment failures

Use Stripe Dashboard for:

- Revenue reports
- Customer lifetime value
- Payment success rates
- Subscription metrics

---

## 🔄 Upgrade Paths

### Free → Pro

- User clicks "Upgrade" button
- Selects Pro plan in UpgradeSheet
- Completes Stripe checkout
- Webhook updates plan
- Features unlock immediately

### Pro → Pro+

- User clicks "Manage Billing"
- In Customer Portal, clicks "Update plan"
- Selects Pro+ and confirms
- Webhook updates plan
- Higher limits apply immediately

### Pro → Free (Downgrade)

- User clicks "Manage Billing"
- In Customer Portal, clicks "Cancel subscription"
- Plan remains active until period end
- At period end, webhook processes cancellation
- Downgraded to Free plan

---

## 📞 Support Resources

- **Stripe Docs**: https://stripe.com/docs
- **Firebase Functions**: https://firebase.google.com/docs/functions
- **Firestore**: https://firebase.google.com/docs/firestore
- **Test Cards**: https://stripe.com/docs/testing

---

**Need Help?** Check [FAQ](./faq.md) or contact support@toolspace.dev
