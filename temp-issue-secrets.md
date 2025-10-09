🔐 PROD Secrets & Env Wiring

**Priority:** 🚨 BLOCKING PRODUCTION RELEASE

This issue tracks the required secrets and environment configuration for production deployment. ALL items must be completed before production release.

## Required GitHub Repository Secrets

Configure these in Repository Settings > Secrets and variables > Actions:

### 🔑 Firebase Secrets

- [ ] `FIREBASE_TOKEN` - Firebase CLI authentication token

  ```bash
  firebase login:ci
  # Copy the token provided
  ```

- [ ] `FIREBASE_PROJECT_ID` - Production Firebase project ID
  ```
  Value: your-prod-project-id
  ```

### 💳 Stripe Secrets

- [ ] `STRIPE_SECRET_KEY` - Live Stripe secret key

  ```
  Format: sk_live_***
  Location: Stripe Dashboard > Developers > API keys
  ```

- [ ] `STRIPE_WEBHOOK_SECRET` - Webhook endpoint secret

  ```
  Format: whsec_***
  Location: Stripe Dashboard > Developers > Webhooks > [webhook] > Signing secret
  ```

- [ ] `STRIPE_PRICE_PRO_MONTH` - Pro plan price ID

  ```
  Format: price_XXXXXXXXXXXXXXXX
  Location: Stripe Dashboard > Products > Pro > Pricing
  Amount: $9.00 USD/month
  ```

- [ ] `STRIPE_PRICE_PRO_PLUS_MONTH` - Pro+ plan price ID
  ```
  Format: price_YYYYYYYYYYYYYYYY
  Location: Stripe Dashboard > Products > Pro+ > Pricing
  Amount: $19.00 USD/month
  ```

## Environment Configuration

### 🔄 Replace Placeholders in Code

Update these files with actual values:

- [ ] `.github/workflows/prod-release.yml`

  - Replace `your-prod-project-id` with actual Firebase project ID
  - Replace `app.example.com` with actual domain

- [ ] `.github/workflows/staging-release.yml`

  - Replace `your-prod-project-id` with actual Firebase project ID

- [ ] `config/pricing.json`
  - Replace `price_XXXXXXXXXXXXXXXX` with actual Pro price ID
  - Replace `price_YYYYYYYYYYYYYYYY` with actual Pro+ price ID

### 🧪 Validation

After setting secrets, run validation:

```bash
# Validate all secrets are present
node scripts/release-check.mjs

# Test workflow with dry run
gh workflow run prod-release.yml -f dry_run=true
```

## Acceptance Criteria

- [ ] All 6 GitHub secrets configured and valid
- [ ] All placeholder values replaced in code
- [ ] `scripts/release-check.mjs` passes without errors
- [ ] Dry run of `prod-release.yml` completes successfully
- [ ] Stripe webhook endpoint responding (test via Stripe Dashboard)

## Dependencies

- Firebase project must be created and configured
- Stripe account must be verified and live mode enabled
- Domain DNS must be configured for Firebase Hosting

## Risk Assessment

**Impact if incomplete:** Production deployment will fail
**Mitigation:** Use exact constants provided, test with dry run first

---

**Assigned to:** Repository administrators
**Due:** Before v1.0.0 production release
**Labels:** `production`, `security`, `blocking`, `configuration`
