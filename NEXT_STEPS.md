# 🚀 Local Testing with Stripe CLI (Recommended!)

**Status:** Firebase & Stripe deployed ✅  
**Next Step:** Test locally with Stripe CLI before production

---

## 🎯 Better Approach: Use Stripe CLI for Local Testing

Instead of configuring production webhooks, let's test locally first!

### **Step 1: Login to Stripe CLI**

```bash
stripe login
```

This opens your browser to authorize the CLI.

### **Step 2: Start Firebase Emulators**

```bash
# Terminal 1
firebase emulators:start
```

This starts local Firebase services:

- Functions: `localhost:5001`
- Firestore: `localhost:8080`
- Auth: `localhost:9099`
- UI: `localhost:4000`

### **Step 3: Forward Webhooks to Local Function**

```bash
# Terminal 2 (while emulators run)
stripe listen --forward-to localhost:5001/toolspace-beta/us-central1/stripeWebhook
```

**Important:** Copy the webhook secret that appears: `whsec_...`

### **Step 4: Set Webhook Secret**

```bash
# Add the webhook secret to functions/.env
echo 'STRIPE_WEBHOOK_SECRET=whsec_YOUR_SECRET_FROM_STEP_3' >> functions/.env

# Restart emulators (Ctrl+C in Terminal 1, then restart)
firebase emulators:start
```

### **Step 5: Run Flutter App**

```bash
# Terminal 3
flutter run -d chrome
```

### **Step 6: Test Stripe Events**

```bash
# Terminal 4 - Trigger test events
stripe trigger checkout.session.completed
stripe trigger customer.subscription.created
stripe trigger invoice.payment_succeeded
```

Watch Terminal 2 to see webhook events flowing in real-time!

---

## 🧪 Complete E2E Test Flow

**With everything running, test the full billing flow:**

1. In Flutter app, click on a premium tool (MD to PDF, etc.)
2. PaywallGuard should show subscription prompt
3. Click "Subscribe"
4. Complete checkout with test card: `4242 4242 4242 4242`
5. Watch Terminal 2 (Stripe CLI) - see webhook events
6. Check Firestore UI (`localhost:4000`) - see subscription record
7. App should unlock premium tool

**Or trigger events manually:**

```bash
stripe trigger checkout.session.completed
stripe trigger customer.subscription.created
```

---

## 📋 Current Status

| Task                     | Status                |
| ------------------------ | --------------------- |
| Firebase Project Created | ✅                    |
| FlutterFire Configured   | ✅                    |
| Cloud Functions Deployed | ✅                    |
| Stripe Keys Configured   | ✅                    |
| Firestore Rules Deployed | ✅                    |
| Storage Rules Deployed   | ✅                    |
| **Stripe CLI Installed** | ✅ (v1.29.0)          |
| Stripe CLI Logged In     | ⏳ **← DO THIS NOW**  |
| Local Webhook Forwarding | ⏳ **← DO THIS NEXT** |
| E2E Testing              | ⏳ After setup        |

---

## 🎯 Once Webhook is Set Up

You'll be ready to:

1. ✅ Test billing flow locally
2. ✅ Run E2E tests
3. ✅ Verify PaywallGuard on 5 heavy tools
4. ✅ Complete OPS-ProdGate task
5. ✅ Merge to main and deploy

---

## 🔗 Quick Links

- **Stripe Webhooks:** https://dashboard.stripe.com/test/webhooks
- **Function Logs:** https://console.firebase.google.com/project/toolspace-beta/functions/logs
- **Firestore Data:** https://console.firebase.google.com/project/toolspace-beta/firestore

---

## 💡 Test Card Numbers

For testing checkout:

- **Success:** 4242 4242 4242 4242
- **Decline:** 4000 0000 0000 0002
- **3D Secure:** 4000 0027 6000 3184

Any future expiry date and any 3-digit CVC.

---

## 📦 Production Webhook (Later)

When you're ready to deploy to production, you'll need to configure the production webhook:

1. Go to: https://dashboard.stripe.com/test/webhooks
2. Add endpoint: `https://us-central1-toolspace-beta.cloudfunctions.net/stripeWebhook`
3. Select same events as above
4. Copy webhook secret
5. Set in Firebase: `firebase functions:config:set stripe.webhook_secret="whsec_..."`
6. Deploy: `firebase deploy --only functions`

**But for now, use Stripe CLI for local testing!**

---

**⏭️ Next:** Run through the 6 steps above, then E2E test! 🚀

**Full guide:** See `docs/setup/STRIPE_CLI_SETUP.md`
