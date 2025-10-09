# AUTH-01: Production Auth, Security Rules & Billing Link

**Status:** 🚧 In Progress
**Priority:** P0 (Blocker for production launch)
**Epic Owner:** Platform Team
**CI Gate:** [auth-security-ok workflow](../../.github/workflows/auth-security-ok.yml)

---

## Overview

This epic tracks the implementation of production-ready authentication, security rules, and billing integration. All features in this epic are validated by the `auth-security-ok` CI workflow, which must pass before production deployment is allowed.

**Deployment Status:** 🚫 **BLOCKED** until all tests pass

---

## Test Coverage

The `auth-security-ok` workflow runs **52 security tests** across 5 categories:

### 1. Security Rules Tests (32 tests)

- **Firestore Rules** (21 tests): Users, Billing, Usage, URLs collections
- **Storage Rules** (11 tests): File upload/download, size limits, temp directory isolation

### 2. Authentication E2E Tests (6 tests)

- Complete signup → verify → login → logout flow
- Password reset flow
- Email verification enforcement
- Input validation (email format, password strength)

### 3. Anonymous Linking Tests (3 tests)

- Anonymous user to authenticated user UID persistence
- URL shortener data migration across linking
- Unique localStorage UID tracking

### 4. Billing Integration Tests (4 tests)

- Stripe webhook updates billing profile
- Subscription plan persists across browser sessions
- Subscription cancellation downgrades user
- Webhook signature validation

### 5. Tools Gating Tests (7 tests)

- Free tier blocked after quota exceeded (3 heavy operations/day)
- Pro tier unlimited access to heavy tools
- Quota increments correctly per operation
- Upgrade flow unlocks gated tools
- Light tools always accessible
- Daily quota reset at midnight UTC

---

## Implementation Status

### ✅ Implemented Features

1. **Anonymous Auth** - Users can access app without signup
2. **Email/Password Auth** - Basic signup/login functionality exists
3. **Firestore Security Rules** - Rules file exists but needs validation
4. **Storage Security Rules** - Rules file exists but needs validation
5. **Stripe Integration** - Checkout flow implemented
6. **PaywallGuard Widget** - UI component for tool gating

### 🚧 Features Needing Implementation

#### A. Authentication (6 failing tests)

**A1. Email Verification Enforcement** ⚠️ FAILING

- **Test:** `e2e/auth.e2e.spec.ts` - "should require email verification before login"
- **Current State:** Users can login without verifying email
- **Required:** Block login/tool access until email verified
- **Files to Modify:**
  - `lib/core/firebase_auth_service.dart` - Add email verification check
  - `lib/screens/auth/login_screen.dart` - Show "verify email" message
  - `lib/widgets/auth_state_builder.dart` - Block unverified users

**A2. Input Validation** ⚠️ FAILING (2 tests)

- **Tests:**
  - "should reject invalid email format"
  - "should reject weak password"
- **Current State:** Basic validation exists but not comprehensive
- **Required:** Proper regex for email, min 8 chars + uppercase + number for password
- **Files to Modify:**
  - `lib/core/firebase_auth_service.dart` - Add validation methods
  - `lib/screens/auth/signup_screen.dart` - Show validation errors

#### B. Anonymous Linking (2 failing tests)

**B1. UID Persistence Across Linking** ⚠️ FAILING

- **Test:** `e2e/link-anon.e2e.spec.ts` - "should persist UID when linking anonymous to authenticated"
- **Current State:** Anonymous users get new UID after signup
- **Required:** Call `linkWithCredential()` to preserve anonymous UID
- **Files to Modify:**
  - `lib/core/firebase_auth_service.dart` - Add `linkAnonymousAccount()` method
  - `lib/screens/auth/signup_screen.dart` - Call link instead of createUserWithEmailAndPassword

**B2. Data Migration** ⚠️ FAILING

- **Test:** "should migrate URL shortener data after linking"
- **Current State:** Anonymous user data not migrated to authenticated account
- **Required:** Firestore batch write to update ownership
- **Files to Modify:**
  - `lib/core/firebase_auth_service.dart` - Add `migrateAnonymousData()` method
  - `functions/src/user-linking.ts` - Cloud Function to update Firestore docs

#### C. Security Rules Validation (32 tests - status unknown)

**C1. Firestore Rules Testing** 📋 NEEDS VALIDATION

- **Tests:** `test/security/firestore.rules.test.ts` (21 tests)
- **Current State:** Rules file exists, tests created but never run
- **Required:** Run tests, fix any failures
- **Files to Check:**
  - `firestore.rules` - May need updates based on test results

**C2. Storage Rules Testing** 📋 NEEDS VALIDATION

- **Tests:** `test/security/storage.rules.test.ts` (11 tests)
- **Current State:** Rules file exists, tests created but never run
- **Required:** Run tests, fix any failures
- **Files to Check:**
  - `storage.rules` - May need updates based on test results

#### D. Billing Integration (3 failing tests)

**D1. Webhook Profile Updates** ⚠️ FAILING

- **Test:** `e2e/billing-link.e2e.spec.ts` - "should update billing profile on webhook"
- **Current State:** Webhooks received but may not update Firestore correctly
- **Required:** Verify webhook handler writes to `/users/{uid}/billing` subcollection
- **Files to Check:**
  - `functions/src/stripe-webhooks.ts` - Ensure proper Firestore writes

**D2. Plan Persistence** ⚠️ FAILING

- **Test:** "should persist subscription plan across browser sessions"
- **Current State:** Plan may not be stored in Firestore correctly
- **Required:** Save plan details from webhook, load on app init
- **Files to Modify:**
  - `lib/billing/billing_service.dart` - Add Firestore read on init
  - `lib/widgets/auth_state_builder.dart` - Load billing profile early

**D3. Cancellation Handling** ⚠️ FAILING

- **Test:** "should downgrade user on subscription cancellation"
- **Current State:** Cancellation webhook may not update user tier
- **Required:** Handle `customer.subscription.deleted` event
- **Files to Check:**
  - `functions/src/stripe-webhooks.ts` - Add cancellation handler

#### E. Tools Gating & Quotas (5 failing tests)

**E1. Quota Enforcement** ⚠️ FAILING (3 tests)

- **Tests:**
  - "should block free user after quota exceeded"
  - "should not block Pro user"
  - "should increment quota correctly"
- **Current State:** PaywallGuard exists but quota tracking incomplete
- **Required:** Track usage in Firestore, block when limit reached
- **Files to Modify:**
  - `lib/billing/paywall_guard.dart` - Add quota check logic
  - `lib/billing/billing_service.dart` - Add `incrementUsage()` method
  - Cloud Function to reset daily quotas

**E2. Upgrade Flow** ⚠️ FAILING

- **Test:** "should unlock tools immediately after upgrade"
- **Current State:** User may need to refresh after upgrading
- **Required:** Real-time billing profile listener
- **Files to Modify:**
  - `lib/billing/billing_service.dart` - Add `StreamController` for billing changes
  - `lib/billing/paywall_guard.dart` - Rebuild on billing updates

**E3. Daily Reset** ⚠️ FAILING

- **Test:** "should reset quota at midnight UTC"
- **Current State:** No scheduled quota reset
- **Required:** Cloud Scheduler + Cloud Function to reset usage counters
- **Files to Create:**
  - `functions/src/scheduled/reset-quotas.ts` - Scheduled function
  - Update `functions/src/index.ts` to export scheduled function

---

## Success Criteria

All 52 tests in the `auth-security-ok` workflow must pass:

```bash
# Security rules tests
cd test/security && npm ci
firebase emulators:start &
npm run test:rules

# E2E tests
flutter build web --release
npx playwright install chromium
npx playwright test e2e/auth.e2e.spec.ts
npx playwright test e2e/link-anon.e2e.spec.ts
npx playwright test e2e/billing-link.e2e.spec.ts
npx playwright test e2e/tools-gating.e2e.spec.ts
```

**Deployment Gate:** The `firebase-hosting-merge.yml` workflow checks that `auth-security-ok` succeeded before deploying to production.

---

## Development Workflow

1. **Pick a feature** from "Features Needing Implementation" above
2. **Run the test locally** to see the current failure
3. **Implement the feature** following the "Files to Modify" guidance
4. **Run the test again** to verify it passes (red → green)
5. **Commit and push** - CI will run all security tests
6. **Check workflow results** at [Actions](../../actions/workflows/auth-security-ok.yml)

---

## Related Documentation

- [Production Readiness Report](../../PRODUCTION_READINESS_REPORT.md)
- [Local Dev Guide](../../LOCAL_DEV_GUIDE.md)
- [Firebase Setup](../setup/firebase.md)
- [Stripe Integration](../billing/stripe-integration.md)
- [Autonomous Workflow](../autonomous-workflow.md)

---

## CI Workflow Details

**File:** `.github/workflows/auth-security-ok.yml`

**Jobs:**

1. `rules-test` - Run Firestore + Storage rules tests
2. `auth-e2e` - Run authentication E2E tests
3. `link-anon-e2e` - Test anonymous user linking
4. `billing-link-e2e` - Test Stripe webhook integration
5. `tools-gating` - Test paywall and quota enforcement
6. `auth-security-ok` - Composite check (requires ALL above to pass)

**Artifacts:**

- Test coverage reports uploaded to CodeCov
- Test results JSON uploaded for analysis
- Build artifacts cached between jobs

**PR Comments:**

- Posts status update to pull requests
- ✅ "All security checks passed! Safe to deploy."
- ❌ "Security checks failed. Fix failing tests before deploying."

---

**Last Updated:** 2025-01-08
**Next Review:** When first test passes
