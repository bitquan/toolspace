# Production Checklist

Complete pre-deployment checklist for Toolspace production release.

## 🔐 Secrets Present

### ✅ GitHub Repository Secrets

**Critical:** All secrets must be configured before production deployment.

- [ ] `FIREBASE_TOKEN` - Firebase CLI authentication token
- [ ] `FIREBASE_PROJECT_ID` - Production project ID: `your-prod-project-id`  
- [ ] `STRIPE_SECRET_KEY` - Live secret key: `sk_live_***`
- [ ] `STRIPE_WEBHOOK_SECRET` - Webhook endpoint secret: `whsec_***`
- [ ] `STRIPE_PRICE_PRO_MONTH` - Pro plan price ID: `price_XXXXXXXXXXXXXXXX`
- [ ] `STRIPE_PRICE_PRO_PLUS_MONTH` - Pro+ plan price ID: `price_YYYYYYYYYYYYYYYY`

**Validation:** Run `scripts/release-check.mjs` to verify all secrets are present.

### ✅ Branch Protections Configured

**Required for main and develop branches:**

- [ ] **main branch protection:**
  - [ ] Require pull request reviews (minimum 2 approvals)
  - [ ] Required status checks: `PR CI`, `CodeQL`, `Auth-Security OK`, `Firebase Preview Deploy`, `Trivy`
  - [ ] Restrict pushes to matching branches
  - [ ] Require linear history
- [ ] **develop branch protection:**
  - [ ] Require pull request reviews (minimum 1 approval)
  - [ ] Required status checks: `PR CI`, `Auth-Security OK`
  - [ ] Auto-delete head branches after merge

## 🚀 Production Environment Setup

### ✅ Firebase Configuration

- [ ] Project created: `your-prod-project-id`
- [ ] Authentication enabled (Email/Password + Google OAuth)
- [ ] Firestore database created in production mode
- [ ] Storage bucket configured with CORS
- [ ] Hosting configured with custom domain: `app.example.com`
- [ ] Security rules deployed and tested

### ✅ Stripe Configuration

- [ ] Live Stripe account verified and activated
- [ ] Products created with exact pricing:
  - [ ] Free: $0/month (no Stripe price needed)
  - [ ] Pro: $9/month → `price_XXXXXXXXXXXXXXXX`
  - [ ] Pro+: $19/month → `price_YYYYYYYYYYYYYYYY`
- [ ] Webhook endpoint configured: `https://us-central1-your-prod-project-id.cloudfunctions.net/webhook`
- [ ] Webhook secret matches `STRIPE_WEBHOOK_SECRET`
- [ ] Webhook events enabled:
  - [ ] `customer.subscription.created`
  - [ ] `customer.subscription.updated`
  - [ ] `customer.subscription.deleted`
  - [ ] `invoice.payment_succeeded`
  - [ ] `invoice.payment_failed`

## � Code Configuration

### ✅ Placeholder Replacement

- [ ] `config/pricing.json` updated with live Stripe price IDs
- [ ] No placeholder values remain in code:
  - [ ] `your-prod-project-id` replaced in workflows
  - [ ] `app.example.com` replaced with actual domain
  - [ ] `price_XXXXXXXXXXXXXXXX` replaced with real Pro price ID
  - [ ] `price_YYYYYYYYYYYYYYYY` replaced with real Pro+ price ID
- [ ] Functions startup validation added (logs ERROR if placeholders detected)

### ✅ Branch Protection

Configure in GitHub repository settings:

#### main branch

- [ ] Require pull request reviews (2 approvals)
- [ ] Dismiss stale reviews when new commits are pushed
- [ ] Require status checks to pass:
  - [ ] `CodeQL`
  - [ ] `PR CI / ci`
  - [ ] `Security Gates / security-gates`
  - [ ] `Preview Deploy / preview-deploy`
- [ ] Require branches to be up to date before merging
- [ ] Require linear history
- [ ] Do not allow force pushes
- [ ] Do not allow deletions
- [ ] Automatically delete head branches

#### develop branch

- [ ] Require pull request reviews (1 approval)
- [ ] Require status checks to pass:
  - [ ] `PR CI / ci`
  - [ ] `Security Gates / security-gates`
- [ ] Require branches to be up to date before merging
- [ ] Do not allow force pushes

## 🔍 Testing Requirements

### ✅ Automated Testing

- [ ] All CI workflows passing on main branch
- [ ] Security rules tests passing
- [ ] End-to-end tests covering critical paths:
  - [ ] User registration and login
  - [ ] Tool access and paywall enforcement
  - [ ] Subscription upgrade flow
  - [ ] Billing management

### ✅ Manual Testing

- [ ] **Authentication Flow**

  - [ ] Sign up with email/password
  - [ ] Email verification works
  - [ ] Sign in/out functionality
  - [ ] Google OAuth integration

- [ ] **Billing Integration**

  - [ ] Free user sees paywall on premium tools
  - [ ] Upgrade flow redirects to Stripe correctly
  - [ ] Successful payment updates user plan
  - [ ] Billing portal access works

- [ ] **Tool Functionality**
  - [ ] All 17 tools load and function
  - [ ] File uploads work correctly
  - [ ] Export functionality works
  - [ ] Cross-tool data sharing works

## 🌐 Infrastructure Requirements

### ✅ Domain Configuration

- [ ] Domain DNS configured to point to Firebase Hosting
- [ ] SSL certificate provisioned and active
- [ ] CNAME records configured correctly
- [ ] Domain verification completed in Firebase Console

### ✅ Monitoring Setup

- [ ] Firebase Performance monitoring enabled
- [ ] Cloud Functions monitoring configured
- [ ] Uptime monitoring configured (external service)
- [ ] Error tracking and alerting set up
- [ ] Log aggregation configured

## 📊 Performance Requirements

### ✅ Load Testing

- [ ] Application handles expected concurrent users
- [ ] Database queries optimized with proper indexes
- [ ] Cloud Functions perform within acceptable limits
- [ ] CDN configuration optimized for global distribution

### ✅ Performance Benchmarks

- [ ] First Contentful Paint < 2 seconds
- [ ] Largest Contentful Paint < 3 seconds
- [ ] Time to Interactive < 4 seconds
- [ ] Cumulative Layout Shift < 0.1

## 🔒 Security Validation

### ✅ Security Audit

- [ ] Firestore security rules prevent unauthorized access
- [ ] All API endpoints require proper authentication
- [ ] Input validation implemented on all user inputs
- [ ] No sensitive data exposed in client-side code
- [ ] HTTPS enforced everywhere
- [ ] Content Security Policy configured

### ✅ Compliance

- [ ] Privacy policy published and accessible
- [ ] Terms of service available
- [ ] GDPR compliance measures implemented
- [ ] Data retention policies defined
- [ ] User data export/deletion procedures documented

## 📋 Operational Requirements

### ✅ Backup and Recovery

- [ ] Automated daily Firestore backups configured
- [ ] Backup retention policy implemented
- [ ] Recovery procedures documented and tested
- [ ] Disaster recovery plan created

### ✅ Support and Documentation

- [ ] Support contact information available
- [ ] User documentation complete
- [ ] Admin runbooks created
- [ ] Incident response procedures documented

## 🚦 Go-Live Procedure

### Final Checks

1. [ ] **Tag Release**: Create and push `v1.0.0` tag
2. [ ] **Monitor Deployment**: Watch `prod-release.yml` workflow
3. [ ] **Smoke Tests**: Verify critical functionality post-deployment
4. [ ] **User Communication**: Announce launch (if applicable)
5. [ ] **Monitor Metrics**: Watch for errors and performance issues

### Rollback Plan

If issues are detected:

1. [ ] **Immediate Rollback**: Deploy previous stable version
2. [ ] **Database Rollback**: Restore from backup if needed
3. [ ] **Communication**: Notify users of temporary issues
4. [ ] **Investigation**: Document and analyze failure
5. [ ] **Fix and Redeploy**: Address issues and attempt deployment again

## 📈 Post-Launch Monitoring

### First 24 Hours

- [ ] Monitor error rates and performance metrics
- [ ] Watch for unusual user behavior or complaints
- [ ] Verify billing webhooks are processing correctly
- [ ] Check that all integrations are functioning

### First Week

- [ ] Review performance metrics and optimize if needed
- [ ] Analyze user feedback and address issues
- [ ] Monitor security logs for any anomalies
- [ ] Verify backup procedures are working correctly

---

## ✅ Final Sign-Off

- [ ] **Technical Lead**: All technical requirements met
- [ ] **Security Review**: Security audit complete and approved
- [ ] **Product Owner**: Feature completeness verified
- [ ] **Operations**: Infrastructure and monitoring ready

**Ready for Production**: All checklist items completed ✅

---

**Note**: Keep this checklist updated as requirements evolve. Review after each deployment to improve the process.
