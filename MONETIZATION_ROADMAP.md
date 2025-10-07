# Monetization v1 - Implementation Roadmap

**⚡ Quick Status:** 30% Complete | Backend foundation ready | UI components needed

---

## 🎯 What's Been Done (30%)

### ✅ Backend Infrastructure (COMPLETE)

- Stripe Cloud Functions (checkout, portal, webhooks)
- Entitlements resolver with quota logic
- TypeScript types for all billing entities
- Firestore schema defined
- Audit logging for all billing events

### ✅ Flutter Foundation (COMPLETE)

- BillingService with reactive streams
- Dart types matching backend
- Usage tracking methods
- Entitlement check functions
- Dependencies added (cloud_firestore, pricing.json asset)

---

## 🚀 Next: Critical Path to MVP

### Step 1: Install Stripe CLI & Configure Webhooks (30 min)

```bash
# Install Stripe CLI
# Windows: scoop install stripe
# Mac: brew install stripe/stripe-cli/stripe

# Login to Stripe
stripe login

# Create products and prices (test mode)
stripe products create --name="Toolspace Pro" --description="For power users"
stripe prices create --product=prod_xxx --amount=900 --currency=usd --recurring='interval=month'

stripe products create --name="Toolspace Pro+" --description="Maximum power"
stripe prices create --product=prod_yyy --amount=1900 --currency=usd --recurring='interval=month'

# Update config/pricing.json with price IDs

# Test webhook forwarding
stripe listen --forward-to http://localhost:5001/toolspace/us-central1/webhook
```

### Step 2: Create UI Components (2-3 hours)

**Priority Order:**

1. **PaywallGuard Widget** (`lib/billing/widgets/paywall_guard.dart`)

   - Wraps tool content
   - Checks `canAccessTool()` and `canPerformHeavyOp()`
   - Shows UpgradeSheet if blocked

2. **UpgradeSheet Modal** (`lib/billing/widgets/upgrade_sheet.dart`)

   - Display all 3 plans (Free, Pro, Pro+)
   - Neo-Playground glassmorphism cards
   - Highlight current plan
   - "Upgrade" button → `createCheckoutSession()`
   - Open checkout URL in browser

3. **QuotaBanner Widget** (`lib/billing/widgets/quota_banner.dart`)

   - Shows remaining heavy ops: "2 merges left today"
   - Soft upsell when < 20% remaining
   - "Upgrade for 200/day" CTA

4. **ManageButton** (`lib/billing/widgets/manage_button.dart`)

   - Opens Stripe customer portal
   - Calls `createPortalLink()`
   - Opens in browser tab

5. **Billing Result Pages** (`lib/screens/billing/`)
   - `success_screen.dart` - "Welcome to Pro! 🎉"
   - `cancel_screen.dart` - "Upgrade cancelled - no problem!"

### Step 3: Integrate into 5 Heavy Tools (1-2 hours)

For each tool, wrap main UI in `PaywallGuard`:

```dart
// Example: lib/tools/file_merger/file_merger_screen.dart
return PaywallGuard(
  toolId: 'file_merger',
  child: Scaffold(
    appBar: AppBar(title: Text('File Merger')),
    body: Column(
      children: [
        QuotaBanner(), // Shows usage
        // ... existing tool UI
      ],
    ),
  ),
);
```

**Tools to update:**

1. `lib/tools/file_merger/file_merger_screen.dart`
2. `lib/tools/image_resizer/image_resizer_screen.dart`
3. `lib/tools/md_to_pdf/md_to_pdf_screen.dart`
4. `lib/tools/qr_maker/qr_maker_screen.dart` (batch mode only)
5. `lib/tools/json_doctor/json_doctor_screen.dart` (CSV export feature)

### Step 4: Update Navigation (30 min)

**In `neo_home_screen.dart`:**

```dart
// Add to AppBar actions:
StreamBuilder<BillingProfile>(
  stream: billingService.billingProfileStream,
  builder: (context, snapshot) {
    final profile = snapshot.data ?? BillingProfile.free();

    if (profile.planId == PlanId.free) {
      return TextButton.icon(
        icon: Icon(Icons.star),
        label: Text('Upgrade'),
        onPressed: () => showUpgradeSheet(context),
      );
    } else {
      return ManageButton();
    }
  },
)
```

### Step 5: Manual Testing (1 hour)

1. Start Firebase emulators (or connect to dev project)
2. Start Stripe webhook forwarding: `stripe listen --forward-to ...`
3. Run Flutter app: `flutter run -d chrome`
4. Test flows:
   - Free user → try heavy tool → see paywall
   - Click Upgrade → complete checkout with test card `4242 4242 4242 4242`
   - Verify webhook processes subscription
   - Verify UI unlocks tool
   - Test customer portal access

---

## 📝 Documentation (Low Priority)

Can be done after MVP works:

- `/docs/billing/README.md` - Setup guide
- `/docs/billing/faq.md` - User FAQ
- `/docs/legal/terms.md` - Terms of Service
- `/docs/legal/privacy.md` - Privacy Policy

---

## 🧪 Testing (Medium Priority)

After manual testing works:

- Unit tests for entitlements logic
- Integration tests for webhooks
- E2E test: full checkout flow

---

## 📦 Deployment Checklist

Before production:

- [ ] Create Stripe **production** products and prices
- [ ] Update `config/pricing.json` with prod price IDs
- [ ] Set `STRIPE_SECRET` (prod key) in Firebase Functions config
- [ ] Set `STRIPE_WEBHOOK_SECRET` (prod endpoint) in Functions config
- [ ] Configure Stripe webhook endpoint: `https://yourapp.com/api/billing/webhook`
- [ ] Enable webhook events in Stripe Dashboard:
  - `checkout.session.completed`
  - `customer.subscription.created`
  - `customer.subscription.updated`
  - `customer.subscription.deleted`
  - `invoice.paid`
  - `invoice.payment_failed`
- [ ] Test one real subscription in production
- [ ] Add legal links to footer (ToS, Privacy)
- [ ] Add "Contact support" link for billing issues

---

## 🎨 UI Design Notes

### UpgradeSheet Layout (Neo-Playground Style)

```
┌─────────────────────────────────────┐
│  Upgrade to unlock more power 🚀    │
│                                     │
│  ┌─────┐  ┌─────┐  ┌─────┐        │
│  │ Free│  │ Pro │  │Pro+ │        │
│  │ $0  │  │ $9  │  │ $19 │        │
│  │     │  │⭐   │  │🏆   │        │
│  │3/day│  │200  │  │2000 │        │
│  │10MB │  │50MB │  │100MB│        │
│  │     │  │     │  │     │        │
│  └─────┘  └─────┘  └─────┘        │
│            [Upgrade]                │
└─────────────────────────────────────┘
```

**Glassmorphism Effects:**

- Semi-transparent cards: `Colors.white.withOpacity(0.1)`
- Backdrop blur: `BackdropFilter(ImageFilter.blur(20, 20))`
- Gradient borders
- Smooth animations on hover/press

---

## ⚡ Quick Commands Reference

```bash
# Frontend
flutter pub get
flutter run -d chrome

# Backend
cd functions
npm install
npm run build

# Stripe
stripe listen --forward-to http://localhost:5001/toolspace/us-central1/webhook
stripe trigger checkout.session.completed
stripe trigger customer.subscription.created

# Firebase
firebase emulators:start
firebase deploy --only functions
```

---

## 🐛 Troubleshooting

### Webhook not processing

- Check `stripe listen` is running
- Verify `STRIPE_WEBHOOK_SECRET` matches
- Check Firebase Functions logs: `firebase functions:log`

### Checkout session fails

- Verify `STRIPE_SECRET` is set
- Check price IDs in `pricing.json` are valid
- Ensure user is authenticated

### UI not updating after payment

- Verify webhook processed successfully
- Check Firestore `users/{uid}/billing/profile` document
- Ensure `billingProfileStream` is being listened to

---

**Estimated Time to MVP:** 4-6 hours
**Estimated Time to Production:** 8-10 hours (including testing and docs)

**Next Action:** Start with Step 2 (UI Components) - create `PaywallGuard` widget
