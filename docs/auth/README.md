# Firebase Authentication Setup & Configuration

Complete guide for setting up Firebase Authentication in the Neo-Playground Toolspace app.

## Overview

This app uses Firebase Authentication with:

- **Email/Password** authentication (with email verification)
- **Google OAuth** sign-in
- **Auth state persistence** across sessions
- **Email verification** gating for premium features

## Firebase Console Setup

### 1. Enable Authentication Methods

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Navigate to **Authentication** > **Sign-in method**

#### Enable Email/Password

1. Click **Email/Password**
2. Toggle **Enable**
3. **Important**: Also toggle **Email link (passwordless sign-in)** if needed
4. Click **Save**

#### Enable Google OAuth

1. Click **Google**
2. Toggle **Enable**
3. Configure **Project public-facing name**: "Neo-Playground Toolspace"
4. Configure **Project support email**: your-support-email@domain.com
5. Note the **Web SDK configuration** - you'll need the `GOOGLE_OAUTH_CLIENT_ID`
6. Click **Save**

### 2. Configure Authorized Domains

Navigate to **Authentication** > **Settings** > **Authorized domains**

Add your domains:

```
localhost (already included for dev)
your-app-domain.web.app
your-custom-domain.com
```

### 3. Customize Email Templates

Navigate to **Authentication** > **Templates**

#### Email Verification Template

```
Subject: Verify your email for Neo-Playground Toolspace

Hello,

Thanks for signing up for Neo-Playground Toolspace! Please verify your email address by clicking the link below:

%LINK%

This link will expire in 24 hours.

If you didn't create this account, you can safely ignore this email.

---
The Neo-Playground Team
```

#### Password Reset Template

```
Subject: Reset your Neo-Playground Toolspace password

Hello,

We received a request to reset your password. Click the link below to set a new password:

%LINK%

This link will expire in 1 hour.

If you didn't request a password reset, you can safely ignore this email.

---
The Neo-Playground Team
```

### 4. Configure Action URL

In email template settings, configure the **Action URL** (for password reset, email verification):

- **Development**: `http://localhost:8080/auth/action`
- **Production**: `https://your-domain.com/auth/action`

## Environment Configuration

### Required Environment Variables

#### Flutter Web (`.env` or environment)

```bash
# Firebase Configuration
FIREBASE_API_KEY=AIzaSy...
FIREBASE_AUTH_DOMAIN=your-project.firebaseapp.com
FIREBASE_PROJECT_ID=your-project
FIREBASE_STORAGE_BUCKET=your-project.appspot.com
FIREBASE_MESSAGING_SENDER_ID=123456789
FIREBASE_APP_ID=1:123456789:web:abc123

# Google OAuth
GOOGLE_OAUTH_CLIENT_ID=123456789-abc123.apps.googleusercontent.com
```

#### Cloud Functions (`functions/.env` or Firebase config)

```bash
# Stripe Integration
STRIPE_SECRET_KEY=sk_test_...  # or sk_live_... for production
STRIPE_WEBHOOK_SECRET=whsec_...

# Firebase (usually auto-configured)
FIREBASE_CONFIG={"projectId":"your-project", ...}
```

## Testing with Firebase Emulator

### Setup

1. Install Firebase CLI: `npm install -g firebase-tools`
2. Login: `firebase login`
3. Initialize emulators: `firebase init emulators`
   - Select: Authentication, Firestore, Functions
   - Use default ports

### Running Emulators

```bash
# Start all emulators
firebase emulators:start

# Start with data persistence
firebase emulators:start --import=./emulator-data --export-on-exit

# Start specific emulators
firebase emulators:start --only auth,firestore
```

### Connect App to Emulators

In `lib/main.dart`, the app automatically detects and connects to emulators when running locally:

```dart
// Auto-detect emulators (already configured in main.dart)
if (kDebugMode) {
  await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
}
```

### Testing Email Verification

In the emulator, email verification is automatic:

1. Sign up with email/password
2. Check emulator UI at `http://localhost:4000`
3. Click verification link in the emulator console
4. Email is instantly verified (no actual email sent)

## Production Deployment Checklist

### Pre-Deployment

- [ ] All authentication tests passing
- [ ] Email templates customized and approved
- [ ] Authorized domains configured
- [ ] OAuth credentials configured and tested
- [ ] Environment variables set in hosting
- [ ] Security rules deployed and tested

### Deployment Steps

1. **Update Firebase config** with production credentials

```bash
firebase use production
```

2. **Deploy security rules**

```bash
firebase deploy --only firestore:rules,storage:rules
```

3. **Deploy Cloud Functions**

```bash
cd functions
npm install
npm run build
firebase deploy --only functions
```

4. **Deploy hosting**

```bash
flutter build web --release
firebase deploy --only hosting
```

5. **Verify**
   - Test sign-up flow
   - Test email verification
   - Test Google OAuth
   - Test password reset
   - Test Stripe integration

### Post-Deployment

- [ ] Monitor Firebase Authentication dashboard
- [ ] Check for failed verification emails
- [ ] Monitor Cloud Functions logs
- [ ] Verify Stripe webhook delivery
- [ ] Test production billing flow

## Common Issues & Solutions

### Issue: Email verification not sent

**Solution**: Check Firebase Console > Authentication > Templates. Ensure SMTP is configured or using Firebase email service.

### Issue: Google OAuth fails

**Solution**:

1. Verify `GOOGLE_OAUTH_CLIENT_ID` matches Firebase console
2. Check authorized JavaScript origins in Google Cloud Console
3. Ensure domain is added to Firebase authorized domains

### Issue: Emulator connection fails

**Solution**:

1. Check emulators are running: `firebase emulators:start`
2. Verify ports are not blocked by firewall
3. Ensure `useAuthEmulator` is called before any auth operations

### Issue: Production auth works but emulator doesn't

**Solution**: Emulator uses separate data. Import/export data:

```bash
firebase emulators:export ./emulator-data
firebase emulators:start --import=./emulator-data
```

## Security Best Practices

### Password Requirements

Enforced by Firebase (minimum 6 characters). Consider adding client-side validation for stronger passwords:

```dart
// Recommended password validation
bool isStrongPassword(String password) {
  return password.length >= 8 &&
         RegExp(r'[A-Z]').hasMatch(password) &&
         RegExp(r'[a-z]').hasMatch(password) &&
         RegExp(r'\d').hasMatch(password);
}
```

### Email Verification

**Always verify email before critical operations:**

- ✅ Before subscription checkout (implemented)
- ✅ Before accessing premium features (implemented)
- ✅ Before account linking
- ✅ Before data export

### Session Management

- Sessions persist across browser restarts
- Sign out clears all local auth state
- Tokens automatically refreshed by Firebase SDK

## Architecture

### AuthService (`lib/auth/services/auth_service.dart`)

Central authentication service providing:

- Sign in/up with email/password
- Google OAuth sign-in
- Email verification
- Password reset
- Auth state streams

### AuthGuard (`lib/auth/guards/auth_guard.dart`)

Route protection:

- Redirects unauthenticated users to sign-in
- Protects premium tools and account pages

### PaywallGuard (`lib/billing/services/paywall_guard.dart`)

Feature protection:

- Checks user entitlements
- Enforces quota limits
- Requires email verification for billing

## Support

For issues or questions:

- Check Firebase Console > Authentication > Users
- Review Cloud Functions logs
- Check browser console for errors
- Enable debug logging in AuthService

---

**Last Updated**: October 2025
**Version**: 1.0.0
**Status**: Production Ready
