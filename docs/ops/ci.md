# CI/CD Pipeline Documentation

**Last Updated:** 2025-10-08
**Status:** ✅ Refactored to Lean PR + Heavy Nightly

---

## Overview

Toolspace uses a **two-tier CI strategy**:

1. **Lean PR CI** (`pr-ci.yml`) - Fast, blocking checks for all pull requests (<10 min target)
2. **Heavy Nightly CI** (`nightly-ci.yml`) - Deep scans, E2E tests, reporting (runs overnight)

This approach balances **fast PR feedback** with **comprehensive testing** without blocking developers.

---

## PR CI Pipeline (Lean & Fast)

**Workflow:** `.github/workflows/pr-ci.yml`
**Triggers:** Pull requests, pushes to main/develop, manual dispatch
**Target Runtime:** <10 minutes
**Status:** ✅ Blocking (required for merge)

### Jobs

| Job               | Description                                 | Timeout |
| ----------------- | ------------------------------------------- | ------- |
| `flutter_build`   | Flutter pub get, analyze, build web release | 10 min  |
| `functions_build` | npm ci, lint, TypeScript type-check         | 8 min   |
| `tests_flutter`   | Flutter unit tests with coverage            | 8 min   |
| `tests_functions` | Functions unit tests (no E2E)               | 8 min   |
| `security_smoke`  | Security rules smoke tests (@smoke tagged)  | 10 min  |

### What Gets Checked

- ✅ Flutter code compiles and builds
- ✅ Functions code compiles and passes lint
- ✅ Unit tests pass (Flutter + Functions)
- ✅ Critical security rules work (@smoke subset)
- ❌ **NOT checked:** E2E tests, full security suite, deep scans

### Running Locally

```bash
# Full PR CI suite
make pr-ci

# Individual jobs
flutter pub get && flutter analyze && flutter build web --release
cd functions && npm ci && npm run lint && npx tsc --noEmit
flutter test --reporter expanded
cd functions && npm run test -- --testPathIgnorePatterns=e2e
cd test/security && npm run test:smoke
```

---

## Nightly CI Pipeline (Heavy Scans)

**Workflow:** `.github/workflows/nightly-ci.yml`
**Triggers:** Daily at 00:30 UTC, manual dispatch
**Target Runtime:** ~30-60 minutes
**Status:** ℹ️ Informational (does NOT block PRs)

### Jobs

| Job              | Description                             | Artifacts                          |
| ---------------- | --------------------------------------- | ---------------------------------- |
| `e2e_full`       | Full Playwright E2E test suite          | Videos, screenshots, JUnit reports |
| `deep_scan`      | CodeQL, Trivy, npm audit, outdated deps | SARIF reports, audit JSON          |
| `coverage_trend` | Coverage analysis with trend tracking   | Codecov uploads                    |
| `deps_health`    | Dependency health report                | Creates/updates maintenance issue  |
| `weekly_digest`  | Velocity, insights, sprint reports      | Commits to docs/reports            |

### What Gets Checked

- ✅ Full E2E authentication flow
- ✅ Anonymous user linking
- ✅ Billing webhook integration
- ✅ Paywall and quota enforcement
- ✅ Security vulnerabilities (CodeQL, Trivy)
- ✅ Dependency health and updates
- ✅ Coverage trends (warns on >10% drop)

### Outputs

- **Artifacts:** Playwright videos/screenshots, security scan reports
- **Issues:** Auto-creates/updates "Dependencies Health Report" issue
- **Reports:** Weekly velocity and insights committed to `docs/reports/`

### Running Locally

```bash
# Heavy nightly suite (subset)
make nightly

# Individual jobs
firebase emulators:start &
npx playwright test
cd functions && npm audit --production
flutter pub outdated
flutter test --coverage
```

---

## Deployment Pipeline

**Workflow:** `.github/workflows/firebase-hosting-merge.yml`
**Triggers:** Push to main, after PR CI completes
**Depends On:** `pr-ci.yml` must pass

### Deployment Flow

1. **PR Created** → PR CI runs (lean checks)
2. **PR Approved** → Merge to main
3. **PR CI Completes** → Triggers deployment workflow
4. **Build & Deploy** → Firebase Hosting (production)

### Deployment Requirements

- ✅ All PR CI jobs must pass
- ✅ PR must be approved
- ✅ No merge conflicts

---

## Removed Workflows (Automation Bots)

The following workflows have been **disabled** (`.disabled` extension):

### Removed Automation

- ❌ `issue-to-branch.yml` - Auto-create branches from issues
- ❌ `auto-pr.yml` - Auto-create pull requests
- ❌ `pr-merge.yml` - Auto-merge approved PRs
- ❌ `auto-assign-issues.yml` - Auto-assign issues to Copilot
- ❌ `scheduled-auto-assign.yml` - Scheduled issue assignment
- ❌ `auto-approve-copilot-prs.yml` - Auto-approve Copilot PRs
- ❌ `auto-approve-copilot.yml` - Duplicate auto-approve

### Removed Duplicate Pipelines

- ❌ `test-runner.yml` - Duplicate test execution
- ❌ `branch-ci.yml` - Duplicate branch checks
- ❌ `policy-checks.yml` - Duplicate policy enforcement
- ❌ `ci.yml` - Legacy CI pipeline

### Why Removed?

**VS Code Copilot handles these tasks better:**

- Issue creation and assignment → Manual in VS Code
- Branch creation → Manual with Copilot suggestions
- PR creation → Manual with Copilot-generated descriptions
- Code review → Human review with Copilot assistance

**Result:** Simpler, more predictable CI with less overhead.

---

## Kept Workflows

These workflows remain **active** for essential automation:

### Post-Merge Cleanup

- ✅ `dev-log-updater.yml` - Updates dev logs after merges
- ✅ Branch deletion after merge (if configured)

### Reporting & Monitoring

- ✅ `delta-*.yml` - OPS-Delta sprint management and reporting
- ✅ `zeta-*.yml` - OPS-Zeta automated improvements

### Manual Operations

- ✅ `workflow-cleanup.yml` - Manual workflow cleanup
- ✅ `nuclear-cleanup.yml` - Emergency cleanup
- ✅ `release.yml` - Release management

---

## Branch Protection Rules

**Required Status Checks:**

```
pr-ci / flutter_build
pr-ci / functions_build
pr-ci / tests_flutter
pr-ci / tests_functions
pr-ci / security_smoke
```

**Settings:**

- ✅ Require status checks to pass before merging
- ✅ Require branches to be up to date before merging
- ✅ Require conversation resolution before merging
- ❌ Do NOT require nightly-ci (informational only)

### Updating Branch Protection

```bash
# Via GitHub CLI
gh api repos/bitquan/toolspace/branches/main/protection \
  --method PUT \
  --field required_status_checks[contexts][]=pr-ci / flutter_build \
  --field required_status_checks[contexts][]=pr-ci / functions_build \
  --field required_status_checks[contexts][]=pr-ci / tests_flutter \
  --field required_status_checks[contexts][]=pr-ci / tests_functions \
  --field required_status_checks[contexts][]=pr-ci / security_smoke
```

---

## Performance Metrics

### Before Refactor

| Metric               | Value         |
| -------------------- | ------------- |
| **Active Workflows** | 35            |
| **PR Checks**        | 12-15         |
| **Avg PR Runtime**   | 25-35 minutes |
| **Duplicate Jobs**   | 5-7           |

### After Refactor

| Metric               | Value          |
| -------------------- | -------------- |
| **Active Workflows** | 15             |
| **PR Checks**        | 5              |
| **Avg PR Runtime**   | <10 minutes ⚡ |
| **Duplicate Jobs**   | 0              |

**Time Saved:** ~20-25 minutes per PR
**Complexity Reduced:** 57% fewer active workflows

---

## Troubleshooting

### PR CI Failing

1. **Check job logs** in GitHub Actions tab
2. **Run locally:** `make pr-ci`
3. **Common issues:**
   - Flutter analyze errors → fix code
   - Functions lint errors → run `npm run lint` in functions/
   - Test failures → run `flutter test` or `npm test`

### Nightly CI Failing

Nightly failures are **informational** and don't block PRs:

1. **E2E failures** → Check Playwright artifacts
2. **Security scan findings** → Review SARIF reports
3. **Coverage drops** → Investigate test changes

### Deployment Failing

1. **Check PR CI passed** → Must be green
2. **Check Firebase credentials** → Verify secrets
3. **Check build artifacts** → Verify Flutter build succeeds

---

## Development Workflow

### Standard PR Flow

```bash
# 1. Create feature branch
git checkout -b feat/my-feature

# 2. Make changes, test locally
make pr-ci

# 3. Commit and push
git add .
git commit -m "feat: my feature"
git push origin feat/my-feature

# 4. Create PR
gh pr create --fill

# 5. Wait for PR CI (should be <10 min)
# 6. Address any failures, push fixes
# 7. Get approval, merge

# 8. Nightly CI runs overnight (no action needed)
```

### Smoke Test Tagging

For security tests to run in PR CI, tag them with `@smoke`:

```typescript
test("@smoke should deny unauthenticated access", async () => {
  // Critical security test
});
```

Run smoke tests: `cd test/security && npm run test:smoke`

---

## Future Improvements

- [ ] Add Lighthouse CI for performance testing (nightly)
- [ ] Integrate dependency scanning (Snyk/Dependabot)
- [ ] Add visual regression testing (Percy/Chromatic)
- [ ] Implement canary deployments
- [ ] Add load testing (nightly)

---

## Support

**Questions?** Check:

- GitHub Actions tab for live runs
- `Makefile` for local commands
- `dev-log/operations/` for historical context

**Issues?** Open issue with:

- Workflow name
- Run ID/link
- Error logs
- Steps to reproduce
