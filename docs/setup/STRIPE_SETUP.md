# Stripe Integration Setup Guide

**Date:** October 8, 2025  
**Project:** toolspace  
**Purpose:** Configure Stripe for billing and subscriptions

---

## 🔑 Your Stripe Keys

**Test Mode Keys:** (Safe to use for development)

```bash
# Publishable Key (safe to expose in client-side code)
STRIPE_PUBLISHABLE_KEY=pk_test_YOUR_PUBLISHABLE_KEY_HERE

# Secret Key (NEVER expose in client code - backend only)
STRIPE_SECRET_KEY=sk_test_YOUR_SECRET_KEY_HERE
```

⚠️ **Security Note:** Test keys are safe for development, but NEVER commit live keys (`pk_live_*`, `sk_live_*`) to git!

---

## Step 1: Configure Firebase Cloud Functions

### 1.1 Set Stripe Secret Key in Firebase

```bash
# Set Stripe secret key for Cloud Functions
firebase functions:config:set stripe.secret_key="sk_test_YOUR_SECRET_KEY_HERE"

# Set your app URL (for redirects)
firebase functions:config:set app.url="https://toolspace-beta.web.app"

# Verify configuration
firebase functions:config:get
```

### 1.2 For Local Emulator Testing

Create `.runtimeconfig.json` in functions directory:

```bash
cd functions
cat > .runtimeconfig.json << 'EOF'
{
  "stripe": {
    "secret_key": "sk_test_YOUR_SECRET_KEY_HERE"
  },
  "app": {
    "url": "http://localhost:5000"
  }
}
EOF
```

⚠️ **Important:** Add `.runtimeconfig.json` to `.gitignore`!

---

## Step 2: Configure Flutter App

### 2.1 Create Environment Configuration

Create `lib/config/stripe_config.dart`:

```dart
/// Stripe configuration for the app
class StripeConfig {
  // Test mode publishable key (safe to expose)
  static const String publishableKey =
    'pk_test_YOUR_PUBLISHABLE_KEY_HERE';

  // For production, use environment variables:
  // static const String publishableKey = String.fromEnvironment(
  //   'STRIPE_PUBLISHABLE_KEY',
  //   defaultValue: publishableKey,
  // );
}
```

### 2.2 Initialize Stripe in Your App

Update `lib/main.dart` to initialize Stripe:

```dart
import 'package:flutter_stripe/flutter_stripe.dart';
import 'config/stripe_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Stripe
  Stripe.publishableKey = StripeConfig.publishableKey;

  runApp(const MyApp());
}
```

---

## Step 3: Install Dependencies

### 3.1 Flutter Dependencies

Check if `flutter_stripe` is in your `pubspec.yaml`:

```yaml
dependencies:
  flutter_stripe: ^11.1.0 # or latest version
```

If not present:

```bash
flutter pub add flutter_stripe
flutter pub get
```

### 3.2 Cloud Functions Dependencies

```bash
cd functions

# Install Stripe SDK
npm install stripe

# Install other dependencies if needed
npm install cors express
npm install --save-dev @types/cors @types/express

# Build TypeScript
npm run build
```

---

## Step 4: Create Stripe Products (In Stripe Dashboard)

### 4.1 Open Stripe Dashboard

```bash
open https://dashboard.stripe.com/test/products
```

### 4.2 Create Products

**Product 1: Pro Plan**

- Name: `Pro Plan`
- Description: `Access to premium tools and features`
- Pricing:
  - Price: `$9.99/month` (or your choice)
  - Billing period: `Monthly`
  - Currency: `USD`
- Copy the **Price ID** (starts with `price_`)

**Product 2: Premium Plan** (optional)

- Name: `Premium Plan`
- Description: `All features + priority support`
- Pricing:
  - Price: `$19.99/month`
  - Billing period: `Monthly`
  - Currency: `USD`
- Copy the **Price ID**

### 4.3 Save Price IDs

Update `config/pricing.json`:

```json
{
  "plans": [
    {
      "id": "pro",
      "name": "Pro Plan",
      "price": 9.99,
      "currency": "USD",
      "interval": "month",
      "stripePriceId": "price_YOUR_PRICE_ID_HERE",
      "features": [
        "All basic tools",
        "Premium tools access",
        "No watermarks",
        "Priority support"
      ]
    }
  ]
}
```

---

## Step 5: Deploy Cloud Functions

### 5.1 Build and Deploy

```bash
# From project root
cd functions

# Install and build
npm install
npm run build

# Deploy to Firebase
cd ..
firebase deploy --only functions
```

### 5.2 Verify Deployment

Check that these functions deployed:

- `createStripeCheckoutSession`
- `stripeWebhook` (for subscription updates)
- `createStripePortalSession` (for subscription management)

---

## Step 6: Configure Stripe Webhook (Important!)

### 6.1 Get Your Cloud Function URL

After deploying, you'll see URLs like:

```
✔  functions[createStripeCheckoutSession]: https://us-central1-toolspace-beta.cloudfunctions.net/createStripeCheckoutSession
```

### 6.2 Add Webhook in Stripe Dashboard

1. Go to: https://dashboard.stripe.com/test/webhooks
2. Click **"Add endpoint"**
3. Enter endpoint URL:
   ```
   https://us-central1-toolspace-beta.cloudfunctions.net/stripeWebhook
   ```
4. Select events to listen to:

   - ✅ `checkout.session.completed`
   - ✅ `customer.subscription.created`
   - ✅ `customer.subscription.updated`
   - ✅ `customer.subscription.deleted`
   - ✅ `invoice.payment_succeeded`
   - ✅ `invoice.payment_failed`

5. Click **"Add endpoint"**
6. Copy the **Signing secret** (starts with `whsec_`)

### 6.3 Add Webhook Secret to Firebase

```bash
firebase functions:config:set stripe.webhook_secret="whsec_YOUR_WEBHOOK_SECRET"

# Redeploy functions to pick up new config
firebase deploy --only functions
```

---

## Step 7: Test Locally with Emulators

### 7.1 Start Firebase Emulators

```bash
firebase emulators:start
```

This starts:

- Auth: http://localhost:9099
- Firestore: http://localhost:8080
- Functions: http://localhost:5001
- Hosting: http://localhost:5000

### 7.2 Test Stripe Integration

1. Run your Flutter app:

   ```bash
   flutter run -d chrome --web-port 8081
   ```

2. Navigate to a paywalled tool
3. Click "Upgrade" or "Subscribe"
4. Should redirect to Stripe Checkout
5. Use test card: `4242 4242 4242 4242`

   - Expiry: Any future date
   - CVC: Any 3 digits
   - ZIP: Any 5 digits

6. Complete checkout
7. Should redirect back and unlock premium features

---

## Step 8: Environment Variables (Production)

For production deployment, use environment variables:

### 8.1 GitHub Secrets (for CI/CD)

In your GitHub repo settings → Secrets → Actions:

```
STRIPE_PUBLISHABLE_KEY=pk_live_...
STRIPE_SECRET_KEY=sk_live_...
STRIPE_WEBHOOK_SECRET=whsec_...
```

### 8.2 Build with Environment Variables

```bash
# Build with production keys
flutter build web \
  --dart-define=STRIPE_PUBLISHABLE_KEY=pk_live_... \
  --release
```

---

## Testing Checklist

- [ ] Stripe initialized in Flutter app
- [ ] Cloud Functions deployed with secret key
- [ ] Products created in Stripe Dashboard
- [ ] Price IDs added to `pricing.json`
- [ ] Webhook endpoint configured
- [ ] Webhook secret added to Firebase config
- [ ] Local emulator test successful
- [ ] Test payment with `4242 4242 4242 4242`
- [ ] Subscription status updates in Firestore
- [ ] Premium features unlock after payment

---

## Test Cards (Stripe Test Mode)

| Card Number           | Description                         |
| --------------------- | ----------------------------------- |
| `4242 4242 4242 4242` | Success                             |
| `4000 0000 0000 0002` | Card declined                       |
| `4000 0000 0000 9995` | Insufficient funds                  |
| `4000 0025 0000 3155` | Requires authentication (3D Secure) |

All test cards:

- Any future expiry date
- Any 3-digit CVC
- Any ZIP code

---

## Security Best Practices

✅ **DO:**

- Use test keys for development
- Store secret keys in Firebase Functions config
- Use environment variables for production
- Add `.runtimeconfig.json` to `.gitignore`
- Validate webhooks with signing secret
- Use HTTPS for all Stripe requests

❌ **DON'T:**

- Commit secret keys to git
- Expose secret keys in client code
- Use live keys in development
- Skip webhook signature verification
- Store keys in plain text files

---

## Troubleshooting

### "Stripe publishable key not set"

→ Check `StripeConfig.publishableKey` is initialized before Stripe.publishableKey

### "Function not found: createStripeCheckoutSession"

→ Deploy functions: `firebase deploy --only functions`

### "Invalid API key"

→ Check secret key in Firebase config: `firebase functions:config:get`

### "Webhook signature verification failed"

→ Ensure webhook secret is set: `firebase functions:config:set stripe.webhook_secret=...`

### "CORS error when calling Cloud Function"

→ Add CORS headers in your function code

---

## Next Steps

1. ✅ Configure Stripe keys (DONE)
2. ✅ Deploy Cloud Functions
3. ✅ Create products in Stripe
4. ✅ Configure webhooks
5. ⏳ Test locally with emulators
6. ⏳ E2E testing in production
7. ⏳ Switch to live keys when ready

---

## Resources

- [Stripe Dashboard (Test Mode)](https://dashboard.stripe.com/test)
- [Stripe API Docs](https://stripe.com/docs/api)
- [Flutter Stripe Package](https://pub.dev/packages/flutter_stripe)
- [Firebase Functions + Stripe](https://firebase.google.com/docs/functions/use-cases#integrate_with_third-party_services_and_apis)

---

**Status:** Ready to configure! Run the commands in order.
