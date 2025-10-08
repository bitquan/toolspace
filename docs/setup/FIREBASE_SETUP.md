# Firebase Project Setup Guide

**Date:** October 8, 2025  
**Project:** toolspace  
**Purpose:** Set up new Firebase project for production deployment

---

## Prerequisites

- [ ] Firebase CLI installed (`npm install -g firebase-tools`)
- [ ] Google/Firebase account
- [ ] Flutter project ready
- [ ] Node.js installed (for Cloud Functions)

---

## Step 1: Create Firebase Project

### 1.1 Via Firebase Console (Recommended)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"** or **"Create a project"**
3. Enter project details:

   - **Project name:** `toolspace-prod` (or your preferred name)
   - **Project ID:** Will be auto-generated (e.g., `toolspace-prod-a1b2c`)
   - **Google Analytics:** Enable (recommended for production)
   - **Analytics account:** Select existing or create new

4. Wait for project creation (~30 seconds)

### 1.2 Via Firebase CLI (Alternative)

```bash
# Login to Firebase
firebase login

# Initialize Firebase in your project
firebase init
```

---

## Step 2: Configure Firebase Services

### 2.1 Enable Required Services

In Firebase Console, enable:

1. **Authentication** → Sign-in method:

   - ✅ Email/Password
   - ✅ Google
   - ✅ Anonymous (for testing)

2. **Firestore Database**:

   - Click **"Create database"**
   - Start in **production mode** (or test mode for development)
   - Choose location: `us-central` (or nearest to your users)

3. **Cloud Storage**:

   - Click **"Get started"**
   - Use default security rules for now
   - Same location as Firestore

4. **Cloud Functions**:
   - Will be set up via Firebase CLI

### 2.2 Configure Billing (Required for Cloud Functions)

1. Go to **Project Settings** → **Usage and billing**
2. Click **"Modify plan"**
3. Upgrade to **Blaze (Pay as you go)** plan
4. Add payment method
5. Set budget alerts (recommended: $10-50/month for starter projects)

---

## Step 3: Register Apps

### 3.1 Web App

1. In Firebase Console, click ⚙️ **Project Settings**
2. Under "Your apps", click **Web** icon (`</>`)
3. Register app:
   - **App nickname:** `toolspace-web`
   - ✅ **Also set up Firebase Hosting**
4. Copy the Firebase config (you'll need this soon)

### 3.2 iOS App (if needed)

1. Click **iOS** icon
2. Enter:
   - **iOS bundle ID:** `com.yourcompany.toolspace`
   - **App nickname:** `toolspace-ios`
3. Download `GoogleService-Info.plist`
4. Add to `ios/Runner/` directory

### 3.3 Android App (if needed)

1. Click **Android** icon
2. Enter:
   - **Android package name:** `com.yourcompany.toolspace`
   - **App nickname:** `toolspace-android`
3. Download `google-services.json`
4. Add to `android/app/` directory

---

## Step 4: Initialize Firebase CLI

```bash
# Navigate to project directory
cd /Volumes/ESD-USB/toolspace

# Login (if not already logged in)
firebase login

# Initialize Firebase
firebase init
```

### 4.1 Select Features

When prompted, select:

- ✅ **Firestore** (rules and indexes)
- ✅ **Functions** (Cloud Functions for Firebase)
- ✅ **Hosting** (Firebase Hosting)
- ✅ **Storage** (Cloud Storage rules)
- ✅ **Emulators** (for local testing)

### 4.2 Configure Each Feature

**Firestore:**

- Use existing file: `firestore.rules`
- Use existing file: `firestore.indexes.json`

**Functions:**

- Language: **TypeScript**
- ESLint: Yes
- Install dependencies: Yes
- Directory: `functions` (already exists)

**Hosting:**

- Public directory: `build/web`
- Single-page app: **Yes**
- Set up automatic builds: No (for now)

**Storage:**

- Use existing file: `storage.rules`

**Emulators:**

- Select: **Authentication**, **Firestore**, **Functions**, **Storage**, **Hosting**
- Ports: Use defaults or match `firebase.json`

---

## Step 5: Configure Flutter App

### 5.1 Install FlutterFire CLI

```bash
# Activate FlutterFire CLI
dart pub global activate flutterfire_cli

# Add to PATH if needed
export PATH="$PATH":"$HOME/.pub-cache/bin"
```

### 5.2 Generate Firebase Options

```bash
# Configure FlutterFire for your project
flutterfire configure

# Select your Firebase project
# This will update lib/firebase_options.dart with real credentials
```

**What this does:**

- Connects to your Firebase project
- Generates platform-specific configuration
- Updates `lib/firebase_options.dart` with real API keys and project IDs
- Creates/updates platform-specific config files

### 5.3 Verify Configuration

Check that `lib/firebase_options.dart` now contains your real project IDs:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'AIza...', // Real API key
  appId: '1:123456789:web:abc123', // Real app ID
  projectId: 'toolspace-prod-a1b2c', // Your project ID
  // ... other fields
);
```

---

## Step 6: Deploy Firestore Rules & Indexes

### 6.1 Review Firestore Rules

Edit `firestore.rules` if needed:

```bash
# View current rules
cat firestore.rules
```

### 6.2 Deploy Rules

```bash
# Deploy Firestore rules
firebase deploy --only firestore:rules

# Deploy Firestore indexes
firebase deploy --only firestore:indexes
```

### 6.3 Deploy Storage Rules

```bash
# Deploy storage rules
firebase deploy --only storage
```

---

## Step 7: Set Up Cloud Functions

### 7.1 Configure Environment

```bash
cd functions

# Install dependencies (if not already done)
npm install

# Build TypeScript
npm run build
```

### 7.2 Set Environment Variables

```bash
# Set Stripe secret key (from Stripe dashboard)
firebase functions:config:set stripe.secret_key="sk_test_..."

# Set other config as needed
firebase functions:config:set app.url="https://toolspace-prod-a1b2c.web.app"
```

### 7.3 Deploy Functions

```bash
# Deploy all functions
cd ..
firebase deploy --only functions

# Or deploy specific function
firebase deploy --only functions:createStripeCheckoutSession
```

---

## Step 8: Verify Deployment

### 8.1 Test Local Emulators

```bash
# Start emulators
firebase emulators:start

# Open Emulator UI
# http://localhost:4000
```

### 8.2 Test Production

```bash
# Build Flutter web app
flutter build web --release

# Deploy to Firebase Hosting
firebase deploy --only hosting

# Visit your app
# https://toolspace-prod-a1b2c.web.app
```

---

## Step 9: Create `.firebaserc`

After initialization, Firebase CLI creates `.firebaserc`:

```bash
# This file should be created automatically
cat .firebaserc
```

**Expected content:**

```json
{
  "projects": {
    "default": "toolspace-prod-a1b2c"
  }
}
```

**If missing, create it:**

```bash
cat > .firebaserc << 'EOF'
{
  "projects": {
    "default": "YOUR_PROJECT_ID"
  }
}
EOF
```

---

## Step 10: Security & Best Practices

### 10.1 Security Checklist

- [ ] Firestore rules deployed (restrict access)
- [ ] Storage rules deployed (validate uploads)
- [ ] API keys restricted (Firebase Console → Credentials)
- [ ] Budget alerts configured
- [ ] Authentication configured
- [ ] CORS configured for Cloud Functions

### 10.2 API Key Restrictions (Important!)

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your Firebase project
3. Navigate to **APIs & Services** → **Credentials**
4. For each API key:
   - Click **Edit**
   - Set **Application restrictions**:
     - Web: HTTP referrers (your domain)
     - iOS: iOS bundle ID
     - Android: Android package name
   - Set **API restrictions**:
     - Restrict to needed APIs only

### 10.3 Enable Required APIs

In Google Cloud Console, enable:

- ✅ Cloud Functions API
- ✅ Cloud Build API
- ✅ Cloud Firestore API
- ✅ Firebase Authentication API
- ✅ Firebase Hosting API

---

## Common Issues & Solutions

### Issue: "Firebase CLI not found"

```bash
npm install -g firebase-tools
```

### Issue: "Permission denied" during deploy

```bash
firebase login --reauth
```

### Issue: "Billing account required"

Cloud Functions require Blaze plan. Upgrade in Firebase Console.

### Issue: "FlutterFire CLI not found"

```bash
dart pub global activate flutterfire_cli
export PATH="$PATH":"$HOME/.pub-cache/bin"
```

### Issue: "CORS errors in Cloud Functions"

Add CORS headers to your Cloud Functions:

```typescript
import * as functions from "firebase-functions";
import * as cors from "cors";

const corsHandler = cors({ origin: true });

export const myFunction = functions.https.onRequest((req, res) => {
  corsHandler(req, res, () => {
    // Your function code
  });
});
```

---

## Quick Reference Commands

```bash
# Login
firebase login

# Initialize project
firebase init

# Configure Flutter
flutterfire configure

# Start emulators
firebase emulators:start

# Deploy everything
firebase deploy

# Deploy specific services
firebase deploy --only hosting
firebase deploy --only functions
firebase deploy --only firestore:rules
firebase deploy --only storage

# View logs
firebase functions:log

# Open Firebase Console
firebase open
```

---

## Next Steps

After Firebase setup:

1. ✅ Set up Stripe integration (see `STRIPE_SETUP.md`)
2. ✅ Configure environment variables
3. ✅ Test locally with emulators
4. ✅ Deploy to production
5. ✅ Run E2E tests
6. ✅ Monitor usage and billing

---

## Resources

- [Firebase Console](https://console.firebase.google.com/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Cloud Functions Documentation](https://firebase.google.com/docs/functions)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)

---

**Status:** Setup guide complete. Follow steps sequentially for best results.
