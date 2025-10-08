# 🚀 Stripe CLI Local Testing Setup

**Better approach for local development!**

---

## Why Stripe CLI?

✅ **Test webhooks locally** without deploying  
✅ **No need to configure production webhook** yet  
✅ **Simulate real Stripe events** instantly  
✅ **See webhook payloads** in real-time

---

## Setup Instructions

### **Step 1: Login to Stripe**

```bash
stripe login
```

This will:

- Open your browser
- Ask you to authorize the CLI
- Connect to your Stripe account

### **Step 2: Start Firebase Emulators**

```bash
# In terminal 1
firebase emulators:start
```

This starts:

- Functions at `localhost:5001`
- Firestore at `localhost:8080`
- Auth at `localhost:9099`
- UI at `localhost:4000`

### **Step 3: Forward Webhooks to Local Function**

```bash
# In terminal 2 (while emulators are running)
stripe listen --forward-to localhost:5001/toolspace-beta/us-central1/stripeWebhook
```

**Expected output:**

```
> Ready! Your webhook signing secret is whsec_xxx (^C to quit)
```

**IMPORTANT:** Copy that `whsec_xxx` secret!

### **Step 4: Set Webhook Secret in Functions**

```bash
# Add to functions/.env
echo 'STRIPE_WEBHOOK_SECRET=whsec_xxx' >> functions/.env

# Restart emulators to pick up the change
# (Press Ctrl+C in terminal 1, then run firebase emulators:start again)
```

### **Step 5: Run Flutter App**

```bash
# In terminal 3
flutter run -d chrome
```

### **Step 6: Test Stripe Events**

```bash
# In terminal 4 (trigger test events)
stripe trigger payment_intent.succeeded
stripe trigger checkout.session.completed
stripe trigger customer.subscription.created
```

---

## 🧪 Full Testing Flow

### **Terminal Layout:**

```
Terminal 1: Firebase Emulators
Terminal 2: Stripe CLI (webhook forwarding)
Terminal 3: Flutter App
Terminal 4: Stripe event triggers
```

### **Complete Test:**

1. **Start everything:**

   ```bash
   # Terminal 1
   firebase emulators:start

   # Terminal 2
   stripe listen --forward-to localhost:5001/toolspace-beta/us-central1/stripeWebhook

   # Terminal 3
   flutter run -d chrome
   ```

2. **Test billing flow in app:**

   - Navigate to a premium tool (MD to PDF, etc.)
   - PaywallGuard should show
   - Click "Subscribe"
   - Use test card: `4242 4242 4242 4242`

3. **Watch the magic happen:**

   - Terminal 2 shows webhook events received
   - Firebase Emulator UI shows Firestore updates
   - Flutter app updates subscription status

4. **Trigger events manually:**
   ```bash
   # Terminal 4
   stripe trigger checkout.session.completed
   stripe trigger customer.subscription.created
   stripe trigger invoice.payment_succeeded
   ```

---

## 📋 Stripe CLI Commands

### **Listen to webhooks:**

```bash
# Forward to local function
stripe listen --forward-to localhost:5001/toolspace-beta/us-central1/stripeWebhook

# See all events (without forwarding)
stripe listen --print-json
```

### **Trigger events:**

```bash
# Successful payment
stripe trigger payment_intent.succeeded

# Checkout completed
stripe trigger checkout.session.completed

# Subscription created
stripe trigger customer.subscription.created

# Subscription updated
stripe trigger customer.subscription.updated

# Payment failed
stripe trigger invoice.payment_failed

# See all available events
stripe trigger --help
```

### **View event logs:**

```bash
# Recent events
stripe events list

# Specific event
stripe events retrieve evt_xxx
```

---

## 🔧 Configuration Files

### **functions/.env** (add webhook secret from CLI)

```env
STRIPE_SECRET_KEY=sk_test_51RxNzf...
STRIPE_WEBHOOK_SECRET=whsec_xxx  # ← From stripe listen command
```

### **Restart emulators after changing .env:**

```bash
# Stop emulators (Ctrl+C)
# Restart
firebase emulators:start
```

---

## 🎯 When to Use Production Webhook

You only need the production webhook (from Stripe Dashboard) when:

- ✅ Deploying to production
- ✅ Testing on live Firebase (not emulators)
- ✅ Real users making real payments

For now, **Stripe CLI is perfect** for local development!

---

## 🐛 Troubleshooting

### Issue: "No webhook secret found"

**Fix:** Make sure `STRIPE_WEBHOOK_SECRET` is in `functions/.env` and restart emulators

### Issue: "Connection refused"

**Fix:** Make sure Firebase emulators are running before starting `stripe listen`

### Issue: "Events not received"

**Fix:** Check the URL in `stripe listen` matches your function URL exactly

### Issue: "Function not found"

**Fix:** Verify function is deployed in emulators:

```bash
curl http://localhost:5001/toolspace-beta/us-central1/stripeWebhook
```

---

## ✅ Checklist

- [ ] Stripe CLI installed (`stripe --version`)
- [ ] Logged into Stripe (`stripe login`)
- [ ] Firebase emulators running
- [ ] Stripe listening and forwarding
- [ ] Webhook secret in `functions/.env`
- [ ] Emulators restarted with new secret
- [ ] Flutter app running
- [ ] Test checkout with card `4242 4242 4242 4242`
- [ ] Verify subscription in Firestore emulator UI

---

## 🚀 Quick Start Script

Save this as `scripts/dev-with-stripe.sh`:

```bash
#!/bin/bash

echo "🚀 Starting development environment with Stripe..."
echo ""
echo "Make sure you have 4 terminals ready!"
echo ""
echo "Terminal 1: Firebase Emulators"
echo "Terminal 2: Stripe CLI"
echo "Terminal 3: Flutter App"
echo "Terminal 4: Event Triggers"
echo ""
read -p "Press ENTER to see commands..."

echo ""
echo "📋 Run these commands:"
echo ""
echo "# Terminal 1:"
echo "firebase emulators:start"
echo ""
echo "# Terminal 2:"
echo "stripe listen --forward-to localhost:5001/toolspace-beta/us-central1/stripeWebhook"
echo ""
echo "# Terminal 3:"
echo "flutter run -d chrome"
echo ""
echo "# Terminal 4:"
echo "stripe trigger checkout.session.completed"
```

---

**Next:** Run through the setup and test locally! 🎉
