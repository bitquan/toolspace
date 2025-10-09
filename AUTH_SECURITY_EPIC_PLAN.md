# AUTH-01 — Production Auth, Security Rules, and Billing Link

**Status:** 🚨 P0 EPIC - PRODUCTION BLOCKER
**Created:** October 8, 2025
**Labels:** `epic`, `area:auth`, `area:security`, `area:billing`, `P0`
**Milestone:** Current Sprint

## 🎯 EPIC OVERVIEW

Critical infrastructure to make Toolspace a production-ready SaaS application with proper authentication, security, and billing integration.

**Current Problem:** Anonymous-only auth, wide-open database, billing tied to temporary users

**Goal:** Real user accounts, secure data access, persistent billing across devices

## 🚨 PRODUCTION FREEZE

- ❌ **Block all prod deploys** until this epic passes DoD checks
- ✅ CI must require `auth-security-ok` status check
- ✅ Update README with "No Launch Until AUTH-01 complete"

## 📋 EPIC ISSUES

### A1 — Auth UI & Flow (Email/Google/Logout/Reset)

- **Routes:** `/auth/signin`, `/auth/signup`, `/auth/reset`, `/auth/verify`, `/account`
- **Providers:** Email+Password, Google OAuth (web)
- **Features:** Session persistence, anonymous→permanent linking, error handling
- **Tests:** Widget tests for all auth flows

### A2 — Auth Service & Guards

- **Service:** `lib/auth/auth_service.dart` with reactive streams
- **Guards:** Route protection, email verification requirements
- **Features:** Reauth for sensitive actions, provider management
- **Tests:** Service unit tests with Firebase emulator

### S1 — Firestore + Storage Security Rules (LOCK DOWN)

- **Rules:** Strict per-UID access control, owner-only data
- **Protection:** Users, billing, usage, file storage
- **Tests:** Rules tests via `firebase emulators:exec`
- **CI:** `rules-test` job must pass to merge

### S2 — Functions Auth Middleware (JWT Verify)

- **Middleware:** `withAuth.ts` for Firebase ID token verification
- **Helpers:** `assertOwner()` for resource access control
- **Retrofit:** All existing endpoints require authentication
- **Tests:** Middleware unit + integration tests

### B1 — Stripe Linking to Real Users

- **Linking:** `client_reference_id = uid`, customer metadata
- **Webhooks:** Update `users/{uid}/billing/profile` on events
- **Migration:** Anonymous customers → real user linking
- **Tests:** Webhook fixtures, Firestore write verification

### B2 — PaywallGuard Integration (Real Users Only)

- **Gating:** Require verified email before checkout
- **Integration:** Real entitlements for 5 premium tools
- **UX:** Quota banners, usage tracking
- **Tests:** Gating logic, counter increments

### U1 — Account Settings & Billing Management

- **Screen:** `/account` with email, providers, billing
- **Features:** Manage billing portal, logout flow
- **UX:** Neo-Playground styling, confirmation dialogs
- **Tests:** Settings render, portal functionality

### D1 — Docs, Keys, and CI Gates

- **Docs:** Auth setup, security rules, billing linking
- **CI:** `auth-security-ok` composite check
- **Gates:** Flutter tests, functions tests, rules tests
- **Update:** README production readiness warning

## 🎯 DEFINITION OF DONE

Must prove in PR body with screenshots + logs:

✅ **Authentication**

- Can sign up (email), sign in, reset password, verify email, sign out
- Google Sign-in works (web)
- Anonymous → signup preserves usage + data (same UID after link)

✅ **Security**

- Firestore/Storage rules tests PASS
- Unauthorized access denied in emulator tests
- All endpoints require valid authentication

✅ **Billing**

- Heavy tools gate for Free, unlock for Pro/Pro+ after webhook
- Billing profile persists across browsers/devices
- Clearing local storage does NOT lose subscription

✅ **CI/CD**

- CI `auth-security-ok` is green
- Prod deploy unfreezes after completion

## 🤖 AUTODEV EXECUTION

- Each issue: `feat/issue-<id>-<slug>` + `bot/issue-<id>-autodev`
- Implement, test, PR, auto-merge if green
- Final epic summary with PR links and demo script

## 🚀 IMPLEMENTATION SPECIFICS

### Flutter

- Auth screens with Neo-Playground styling (glass panels, gradients)
- Navbar updates (Sign in / avatar menu)
- Route guards and verification requirements

### Functions

- `withAuth` middleware on all callables/HTTP
- Maintain existing Stripe webhook signature verification
- Owner-only resource access patterns

### Migration

- `linkWithCredential` to preserve UID on signup
- Move usage docs and local data to persistent UID
- Update Stripe customer metadata for pre-existing customers

---

**Next:** Create GitHub issues and begin implementation
