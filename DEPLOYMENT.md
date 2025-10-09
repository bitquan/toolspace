# Production Deployment Guide

**Target Environment:** Single Production (Firebase + Stripe Live)

## Exact Production Pipeline

### Release Process

```
1. Branch release/vX.Y.Z from develop
2. Bump versions + update CHANGELOG.md
3. Tag vX.Y.Z → triggers prod-release.yml (dry_run=false)
4. After green deployment, publish GitHub Release
```

### Pipeline Steps (prod-release.yml)

1. **Preflight Checks**
   - Run `scripts/release-check.mjs` (validates pricing.json placeholders)
   - Execute `auth-security-ok` composite action
   - Verify all required secrets present

2. **Build Phase**
   - Flutter web build with cache (pub dependencies)
   - Functions build + unit tests
   - Upload artifacts

3. **Deploy Phase**
   - Deploy Hosting + Functions to `${{ secrets.FIREBASE_PROJECT_ID }}`
   - Single environment strategy (production only)

4. **Post-Deploy Smoke Tests**
   - GET `/` must return 200
   - GET `/features` must return 200  
   - GET `/pricing` must return 200
   - All tests must pass for successful deployment

### Staging Pipeline (staging-release.yml)

**Trigger:** Push to `develop` branch

1. Same build/tests as production
2. Deploy to Firebase Hosting Preview only (no main rewrite)
3. Output preview URL in workflow summary
4. No Functions deployment (to avoid conflicts)

## Environment Configuration

- **Firebase Project**: `your-prod-project-id` (single prod environment)
- **Stripe**: Live keys pointing to production Stripe account
- **Domain**: `app.example.com`

## Required Constants (Use Exact Placeholders)

```bash
FIREBASE_PROJECT_ID = your-prod-project-id
PROD_DOMAIN = app.example.com
STRIPE_PRICE_PRO_MONTH = price_XXXXXXXXXXXXXXXX
STRIPE_PRICE_PRO_PLUS_MONTH = price_YYYYYYYYYYYYYYYY
STRIPE_SECRET_KEY = sk_live_***
STRIPE_WEBHOOK_SECRET = whsec_***
```

## Prerequisites

### Required Secrets in GitHub

```bash
FIREBASE_TOKEN              # Firebase CLI token
FIREBASE_PROJECT_ID         # your-prod-project-id
STRIPE_SECRET_KEY          # sk_live_***
STRIPE_WEBHOOK_SECRET      # whsec_***
STRIPE_PRICE_PRO_MONTH     # price_XXXXXXXXXXXXXXXX
STRIPE_PRICE_PRO_PLUS_MONTH # price_YYYYYYYYYYYYYYYY
```

### Local Development Setup

```bash
# Install dependencies
flutter pub get
cd functions && npm ci

# Configure Firebase
firebase use your-prod-project-id

# Set up Stripe webhook forwarding
stripe listen --forward-to http://localhost:5001/your-prod-project-id/us-central1/webhook
```

## Deployment Commands

### Flutter Web (Production)

```bash
flutter build web --release --web-renderer html
```

### Firebase Functions

```bash
cd functions
npm run build
```

### Complete Deployment

```bash
# Set Firebase project
firebase use FIREBASE_PROJECT_ID

# Deploy everything
firebase deploy
```

## Release Process

### 1. Create Release Branch

```bash
git checkout develop
git pull origin develop
git checkout -b release/vX.Y.Z
```

### 2. Version Bumps

Update versions in:

- `pubspec.yaml` (version: X.Y.Z+build)
- `functions/package.json` (version: "X.Y.Z")
- `CHANGELOG.md` (move Unreleased → vX.Y.Z)

### 3. Merge to Staging

```bash
git checkout develop
git merge release/vX.Y.Z
git push origin develop
```

**Verify staging deployment passes all checks**

### 4. Production Release

```bash
git checkout main
git merge release/vX.Y.Z --no-ff
git push origin main
```

### 5. Tag Release

```bash
git tag vX.Y.Z
git push origin vX.Y.Z
```

**This triggers `prod-release.yml` workflow**

## Deployment Verification

### Automated Checks

- Health endpoint: `https://PROD_DOMAIN/api/health`
- Pricing page: `https://PROD_DOMAIN/pricing`
- Auth flow: Sign-up/sign-in smoke test

### Manual Verification

1. **Billing Flow**: Create test subscription
2. **Tools Access**: Verify paywall enforcement
3. **Webhook**: Test Stripe webhook delivery

## Rollback Procedure

### Emergency Rollback

```bash
# Deploy previous version
git checkout vX.Y.Z-1
firebase deploy --only hosting,functions

# Or hosting only (faster)
firebase deploy --only hosting
```

### Database Rollback

See `docs/backup-recovery.md` for Firestore restore procedures.

## Branch Protection Rules

### main branch

- Require PR with 2 approvals
- Required status checks:
  - `CodeQL`
  - `PR CI`
  - `Security Gates`
  - `Preview Deploy`
- No force push
- Linear history required
- Auto-delete merged branches

### develop branch

- Require PR
- Required status checks:
  - `PR CI`
  - `Security Gates`
- No force push

## Troubleshooting

### Build Failures

```bash
# Clear Flutter cache
flutter clean && flutter pub get

# Clear Functions cache
cd functions && rm -rf node_modules && npm ci
```

### Deployment Failures

```bash
# Check Firebase CLI version
firebase --version

# Re-authenticate
firebase logout && firebase login

# Check project access
firebase projects:list
```

### Webhook Issues

```bash
# Test webhook locally
stripe trigger customer.subscription.created

# Check webhook status
stripe webhook_endpoints list
```

## Performance Monitoring

- **Firebase Performance**: Enabled for web
- **Functions Monitoring**: Cloud Functions logs
- **Uptime Monitoring**: External service recommended

## Security Considerations

- All secrets in GitHub Secrets (never in code)
- Service account has minimal required permissions
- Firestore rules enforce user isolation
- HTTPS enforced everywhere

---

**Next Steps**: See `PRODUCTION_CHECKLIST.md` for go-live requirements.
