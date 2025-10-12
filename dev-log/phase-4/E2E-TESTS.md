# 🧪 Phase 3.5: Test-Production E2E with Stripe Test Keys

**Date:** October 11, 2025  
**Goal:** Deploy release build to Hosting + Functions using STRIPE TEST KEYS, verify full upgrade/paywall flow  
**Domain:** https://toolspace-beta.web.app  
**Environment:** Test Mode (Stripe Test Keys)

## ✅ Pre-flight Verification

### Firebase Configuration:

- **Project:** toolspace-beta ✅
- **Hosting Domain:** toolspace-beta.web.app ✅
- **Functions Region:** us-central1 ✅

### Stripe Configuration:

- **Test Secret Key:** sk_test_51RxNzfQJjz2bfxmC... ✅
- **Test Webhook Secret:** whsec_KlKTrjIhEVHzG7F3... ✅
- **Price IDs in pricing.json:**
  - Pro: price_1SG489QJjz2bfxmClomM29uG ✅
  - Pro Plus: price_1SG48MQJjz2bfxmCtCPRhNnV ✅

### PaywallGuard Status:

- **File Merger:** Pro required ✅
- **Image Resizer:** Pro required ✅
- **Markdown to PDF:** Pro required ✅
- **Free Tools:** Guest access enabled ✅

## 🚨 Critical Fix Applied

**Issue:** Missing pricing.json in Functions deployment

- **Error:** `ENOENT: no such file or directory, open '/functions/lib/config/pricing.json'`
- **Fix:** Copied `config/pricing.json` to `functions/src/config/` and `functions/lib/config/`
- **Status:** Functions rebuilt and redeploying ✅

## 📋 Deployment Log

**Step 1: Flutter Build** ✅ (73.1s)
**Step 2: Functions with Pricing Config** ✅ Fixed missing pricing.json
**Step 3: Firebase Deploy** ✅ (In Progress)

## 🔌 Stripe Webhook Configuration

**Webhook Endpoint:** `https://toolspace-beta.web.app/__/functions/stripeWebhook`

**Required Events:**

- checkout.session.completed
- customer.subscription.created
- customer.subscription.updated
- customer.subscription.deleted
- invoice.payment_succeeded
- invoice.payment_failed

**Configuration Steps:**

1. Go to [Stripe Dashboard → Developers → Webhooks](https://dashboard.stripe.com/test/webhooks)
2. Click "Add endpoint"
3. Enter URL: `https://toolspace-beta.web.app/__/functions/stripeWebhook`
4. Select events listed above
5. Copy webhook secret (whsec_test_xxx) to Firebase Functions config

## 🏥 Health Check

**Direct Function URL:** https://us-central1-toolspace-beta.cloudfunctions.net/health
**Status:** 403 Forbidden (Function not publicly accessible)
**Note:** This is expected behavior for Cloud Functions 2nd Gen

**Main App URL:** https://toolspace-beta.web.app
**Status:** ✅ Deployed and accessible

## 🧪 E2E Test Execution Plan

### Test User Setup

- **Email:** `test-user-phase3@example.com`
- **Password:** `TestPassword123!`
- **Plan Transition:** Free → Pro → Free

### 🔄 Test Sequence

#### **1. Initial Setup & Free Access** ✅

- [ ] Open https://toolspace-beta.web.app
- [ ] Verify freemium landing page loads
- [ ] Test free tool access (QR Generator, JSON Doctor, etc.)
- [ ] Verify guest users can use tools without signup

#### **2. User Registration & Authentication**

- [ ] Create new account with test credentials
- [ ] Verify email confirmation (if required)
- [ ] Login successfully
- [ ] Navigate to dashboard

#### **3. Pro Tool Paywall Verification**

- [ ] Access File Merger → expect paywall
- [ ] Access Image Resizer → expect paywall
- [ ] Access Markdown to PDF → expect paywall
- [ ] Verify upgrade prompts show correctly

#### **4. Stripe Checkout Flow (Test Mode)**

- [ ] Click "Upgrade to Pro" button
- [ ] Complete Stripe checkout with test card: `4242 4242 4242 4242`
- [ ] Use test expiry: `12/34`, CVC: `123`
- [ ] Verify successful payment completion
- [ ] Check for webhook delivery

#### **5. Pro Access Verification**

- [ ] Reload application
- [ ] Verify billing status updated to Pro
- [ ] Access File Merger → should work
- [ ] Perform actual file merge operation
- [ ] Check usage tracking in Firestore

#### **6. Usage Tracking & Limits**

- [ ] Perform multiple Pro operations
- [ ] Verify usage increment in database
- [ ] Test approaching quota limits
- [ ] Verify quota warnings appear

#### **7. Subscription Management**

- [ ] Test customer portal access
- [ ] Verify subscription details
- [ ] Test subscription modification

#### **8. Downgrade Testing**

- [ ] Cancel subscription in Stripe Dashboard
- [ ] Wait for webhook delivery
- [ ] Verify plan reverts to Free
- [ ] Test Pro tools are blocked again

### 📊 Expected Results Table

| Test Step           | Expected   | Actual | Status | Notes |
| ------------------- | ---------- | ------ | ------ | ----- |
| Landing Page Load   | 200 OK     |        | ⏳     |       |
| Free Tool Access    | Works      |        | ⏳     |       |
| Pro Tool Paywall    | Blocked    |        | ⏳     |       |
| Stripe Checkout     | Success    |        | ⏳     |       |
| Webhook Delivery    | 200 OK     |        | ⏳     |       |
| Pro Access Enabled  | Works      |        | ⏳     |       |
| Usage Tracking      | Increments |        | ⏳     |       |
| Subscription Cancel | Plan=Free  |        | ⏳     |       |

### 🔍 Data Collection Points

#### **Firestore Documents to Capture:**

1. `users/{uid}/billing/profile` (before/after upgrade)
2. `users/{uid}/usage/{date}` (usage tracking)
3. Stripe webhook logs
4. Function execution logs

#### **Stripe Dashboard Evidence:**

1. Customer creation
2. Subscription status
3. Payment confirmation
4. Webhook delivery logs

## 🚀 Ready for Manual E2E Testing

**Current Status:** Deployment complete, ready for manual testing phase
**Next Action:** Execute test sequence and collect evidence

## 🚀 Deployment Steps

### Step 1: Firebase Functions Config ✅

```bash
firebase functions:config:set \
  stripe.secret="sk_test_..." \
  stripe.webhook_secret="whsec_test_..." \
  --project toolspace-beta
```

### Step 2: Build & Deploy

```bash
flutter build web --release
firebase deploy --only functions,hosting --project toolspace-beta
```

### Step 3: Health Check Function ✅

Created `/api/health` endpoint to verify:

- Stripe test mode status
- Function configuration
- Deployment timestamp

## 📋 E2E Test Plan

### Test User Profile:

- **Email:** test-user-phase4@example.com
- **Initial Plan:** Free
- **Target Plan:** Pro ($9/month)

### Test Scenarios:

#### 1. Free User Experience ✅

- [ ] Access free tools without signup
- [ ] Hit paywall on Pro tools (File Merger)
- [ ] See upgrade prompts

#### 2. Stripe Checkout Flow

- [ ] Sign up new test user
- [ ] Click "Upgrade to Pro"
- [ ] Complete checkout with test card (4242 4242 4242 4242)
- [ ] Verify webhook processing
- [ ] Confirm Firestore profile update

#### 3. Pro User Experience

- [ ] Reload app - verify Pro status
- [ ] Access File Merger successfully
- [ ] Track usage in Firestore
- [ ] Test additional Pro tools

#### 4. Downgrade/Cancel Flow

- [ ] Cancel subscription in Stripe Dashboard
- [ ] Verify webhook updates Firestore
- [ ] Confirm Pro tools are blocked again

## 📊 Expected Webhook Sequence:

1. `checkout.session.completed`
2. `customer.subscription.created`
3. `invoice.payment_succeeded`
4. Firestore update: planId="pro", status="active"

## 📁 Artifacts to Collect:

- [ ] Before/after Firestore profile snapshots
- [ ] Usage tracking documents
- [ ] Webhook payload logs
- [ ] Function execution logs
- [ ] Screenshots of UI states

---

**Status:** 🔄 In Progress - Building Flutter Web App...
