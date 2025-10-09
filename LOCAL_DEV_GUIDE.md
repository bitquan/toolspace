# Quick Start Guide - Local Development

## ✅ Setup Complete!

You've successfully pulled all the latest changes including:

- Firebase emulator configuration
- Stripe integration
- Billing backend (4 Cloud Functions)
- Test stabilization (94.9% pass rate)

## 🔑 Keys Configured

### Backend (.env file)

Location: `functions/.env`

```
STRIPE_SECRET_KEY=sk_test_51RxNzfQJjz2bfxmC...
STRIPE_WEBHOOK_SECRET=whsec_KlKTrjIhEVHzG7F3...
APP_URL=http://localhost:5000
PROJECT_ID=toolspace-beta
```

### Frontend (stripe_config.dart)

Location: `lib/config/stripe_config.dart`

```dart
publishableKey = 'pk_test_51RxNzfQJjz2bfxmCmpf...'
```

## 🚀 How to Run

### Option 1: Full Stack with Billing (Recommended)

**Terminal 1 - Firebase Emulators:**

```powershell
cd E:\toolspace\toolspace
firebase emulators:start
```

Wait for: `✔  All emulators ready!`

**Terminal 2 - Stripe CLI (for webhooks):**

```powershell
stripe listen --forward-to localhost:5001/toolspace-beta/us-central1/stripeWebhook
```

Wait for: `Ready! Your webhook signing secret is whsec_...`

**Terminal 3 - Flutter App:**

```powershell
cd E:\toolspace\toolspace
flutter run -d chrome
```

### Option 2: Quick Development (No Billing)

**Single Terminal:**

```powershell
cd E:\toolspace\toolspace
flutter run -d chrome
```

App will work but billing features will be disabled.

## 🧪 Testing the Billing Flow

1. **Open app** → Click **"Upgrade"** button in navbar (⭐ icon)
2. **View plans** → UpgradeSheet modal appears
3. **Select plan** → Click "Upgrade to Pro" ($9/mo)
4. **Stripe Checkout** → Opens in new tab
5. **Test card**: `4242 4242 4242 4242`
   - Expiry: Any future date (e.g., `12/34`)
   - CVC: Any 3 digits (e.g., `123`)
   - ZIP: Any 5 digits (e.g., `12345`)
6. **Complete payment** → Redirects to `/billing/success`
7. **Check quota** → Try using File Merger (should show 200 ops/day instead of 3)

## 📊 Available Commands

### Run Tests

```powershell
# All tests
flutter test

# Specific test file
flutter test test/tools/codec_lab/codec_lab_widget_test.dart

# With coverage
flutter test --coverage
```

### Backend Tests

```powershell
cd functions
npm test
```

### Format Code

```powershell
dart format .
```

### Analyze Code

```powershell
flutter analyze
```

## 🔧 Emulator URLs

When emulators are running:

- **Emulator UI**: http://localhost:4000
- **Firestore**: http://localhost:4000/firestore
- **Functions**: http://localhost:4000/functions
- **Auth**: http://localhost:4000/auth

## 📁 Important Files

### Configuration

- `functions/.env` - Backend environment variables (Stripe keys)
- `lib/config/stripe_config.dart` - Frontend Stripe config
- `lib/firebase_options.dart` - Firebase configuration
- `firebase.json` - Emulator configuration

### Documentation

- `docs/setup/FIREBASE_SETUP.md` - Firebase setup guide
- `docs/setup/STRIPE_SETUP.md` - Stripe setup guide
- `docs/setup/STRIPE_CLI_SETUP.md` - Stripe CLI installation
- `docs/billing/README.md` - Billing system overview

### Helper Scripts

- `scripts/setup-firebase.sh` - Initialize Firebase
- `scripts/dev-with-stripe.sh` - Start all services

## 🐛 Troubleshooting

### Issue: Firebase emulators won't start

**Solution**:

```powershell
# Install Firebase CLI if not installed
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize emulators
firebase init emulators
```

### Issue: Stripe CLI not found

**Solution**:

```powershell
# Download from: https://github.com/stripe/stripe-cli/releases/latest
# Or use Chocolatey:
choco install stripe-cli
```

### Issue: Functions not deploying

**Solution**:

```powershell
cd functions
npm install
npm run build
```

### Issue: App shows "No internet connection"

**Check**:

1. Firebase emulators running? (http://localhost:4000)
2. Check `lib/main.dart` - emulator config at line 37-42
3. Anonymous auth working? Check Firebase Auth emulator

## 🎯 Quick Verification

Run this to verify everything is working:

```powershell
# 1. Backend tests
cd functions
npm test

# 2. Frontend tests
cd ..
flutter test

# 3. Start emulators (separate terminal)
firebase emulators:start

# 4. Run app
flutter run -d chrome
```

All green? You're ready to develop! 🚀

## 📝 Notes

- **Emulators persist data** between runs (in `.firebase/` folder)
- **Stripe CLI** webhook secret changes each time you restart it
- **Anonymous auth** is auto-configured for testing (see `lib/main.dart:50`)
- **All test keys** are safe to commit (they're test mode only)

---

**Need help?** Check the docs in `docs/setup/` or the README files! 📚
