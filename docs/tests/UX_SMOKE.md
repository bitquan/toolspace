# UX Smoke Testing Guide

## Overview

Comprehensive UX testing for Toolspace landing page and navigation flows. This ensures production-ready user experience with automated visual regression and E2E smoke tests.

## Local Development

### Prerequisites

```bash
flutter pub get
cd test/e2e && npm install
npx playwright install --with-deps
```

### Run Tests Locally

#### 1. Flutter Navigation Tests

```bash
flutter test test/navigation/landing_nav_test.dart
```

#### 2. Golden (Visual) Tests

```bash
flutter test test/golden/landing_golden_test.dart --update-goldens  # First time
flutter test test/golden/landing_golden_test.dart                   # Validate
```

#### 3. Playwright E2E Smoke Tests

```bash
# Terminal 1: Build and serve app
flutter build web --release
npx http-server build/web -p 4173

# Terminal 2: Run Playwright
cd test/e2e
npx playwright test ui-smoke.spec.ts
```

## CI Integration

### Workflows

**`.github/workflows/ux-smoke.yml`** - Runs on all PRs:

- Flutter navigation unit tests
- Golden visual regression tests
- Playwright E2E smoke tests
- Screenshot artifacts uploaded

### Preflight Integration

Pre-push hook runs:

```bash
npm run preflight  # Includes golden tests
npm run e2e:smoke  # Playwright against local build
```

## Test Coverage

### Navigation Routes Tested

| Route        | CTA                  | Expected Destination             |
| ------------ | -------------------- | -------------------------------- |
| `/signup`    | "Get Started Free"   | Signup page                      |
| `/pricing`   | "View Pricing"       | Pricing page                     |
| `/features`  | "Features" (navbar)  | Features page                    |
| `/dashboard` | "Dashboard" (navbar) | Dashboard (or /signup if unauth) |

### Selectors

All navigation elements have test-friendly attributes:

- `Key('btn-get-started')` + `Semantics(label: 'btn-get-started')`
- `Key('btn-view-pricing')` + `Semantics(label: 'btn-view-pricing')`
- `Key('nav-features')` + `Semantics(label: 'nav-features')`
- `Key('nav-pricing')` + `Semantics(label: 'nav-pricing')`
- `Key('nav-dashboard')` + `Semantics(label: 'nav-dashboard')`

### Golden Tests

Visual regression at key breakpoints:

- Phone: 360x800
- Desktop: 1440x900

Stored in: `test/golden/_goldens/`

## Troubleshooting

### Golden Test Failures

If golden tests fail in CI but pass locally:

1. Ensure you're using same Flutter version as CI
2. Run with `--update-goldens` and commit new goldens
3. Check pixel ratio differences (CI uses 1.0)

### Playwright Failures

If E2E tests timeout:

1. Verify app is built: `flutter build web`
2. Ensure server is running on port 4173
3. Check network tab in browser for errors

### Route Not Found

If navigation test fails:

1. Verify route is registered in `lib/core/routes.dart`
2. Check import paths for screen widgets
3. Ensure route constant matches generateRoute switch case

## Maintenance

- **Update goldens** when UI intentionally changes
- **Add new tests** when adding navigation CTAs
- **Screenshot artifacts** in CI for visual review

## Phase 2: Automated Testing Complete ✅

### What's Included

#### 1. Flutter Golden Tests (`test/golden/landing_golden_test.dart`)

Visual regression tests at two breakpoints:

- **Phone**: 360×800 (2.0 pixel ratio)
- **Desktop**: 1440×900 (1.0 pixel ratio)

**Run golden tests:**

```bash
# Generate new golden baselines
flutter test --update-goldens test/golden/landing_golden_test.dart

# Verify against existing goldens
flutter test test/golden/landing_golden_test.dart
```

Golden files are stored in `test/golden/_goldens/` and should be committed to version control.

#### 2. Flutter Navigation Tests (`test/navigation/landing_nav_test.dart`)

Unit tests verifying all CTA routing:

- ✅ `btn-get-started` → `/signup`
- ✅ `btn-view-pricing` → `/pricing`
- ✅ `nav-features` → `/features`
- ✅ `nav-pricing` → `/pricing`
- ✅ `nav-dashboard` → `/dashboard` (or `/signup` if unauth)
- ✅ All navigation selectors present and visible

**Run navigation tests:**

```bash
flutter test test/navigation/landing_nav_test.dart
```

#### 3. Playwright E2E Tests (`test/e2e/ui-smoke.spec.ts`)

Web smoke tests using Playwright:

- Landing page loads with correct title
- All navigation CTAs function correctly
- Screenshots captured at `.artifacts/home.png`
- Full user flow verification

**Run E2E tests:**

```bash
# Install dependencies (first time only)
cd test/e2e
npm install
npx playwright install --with-deps chromium

# Build and serve the app
cd ../..
flutter build web --release
npx http-server build/web -p 4173 &

# Run tests
cd test/e2e
npm test
```

#### 4. CI Workflow (`.github/workflows/ux-smoke.yml`)

Automated testing on all PRs:

- **Job 1: flutter-tests**
  - Flutter analyze
  - Unit tests + golden tests + navigation tests
  - Build web --release
  - Upload build artifact
- **Job 2: e2e-tests**
  - Download build artifact
  - Install Playwright
  - Serve build on port 4173
  - Run Playwright smoke tests
  - Upload screenshots and reports

**View CI results:**

- Check Actions tab in GitHub
- Download artifacts: `ui-smoke-artifacts` (screenshots), `playwright-report` (HTML report)

#### 5. Preflight Script (`scripts/preflight.mjs`)

Local pre-push validation:

```bash
node scripts/preflight.mjs
```

Runs complete test suite:

1. `flutter analyze` - Static analysis
2. `flutter test` - All unit, golden, and navigation tests
3. `flutter build web --release` - Production build
4. E2E dependencies installation
5. Playwright browser installation
6. Web server startup and E2E tests
7. Generates `pr-ci-summary.json` with results

**Exit codes:**

- `0` - All checks passed ✅
- `1` - One or more checks failed ❌

### CI Artifacts

After each PR workflow run, download:

- **`ui-smoke-artifacts`**: Screenshots and videos from Playwright tests
- **`playwright-report`**: Interactive HTML test report
- **`web-build`**: Flutter web production build

Artifacts retained for 7 days.

### Required Checks

To make UX smoke tests required for merging:

1. Go to repository **Settings** → **Branches**
2. Edit branch protection rule for `main`
3. Enable **Require status checks to pass**
4. Add: `Flutter Tests (Golden + Navigation)` and `Playwright E2E Tests`

## Implementation Status

### Phase 1: Routes & Pages ✅

- ✅ Marketing pages created (Features, Pricing)
- ✅ Routes registered and wired
- ✅ Test selectors added (Keys + Semantics)
- ✅ Navigation buttons functional

### Phase 2: Automated Testing ✅

- ✅ Golden tests implemented (`test/golden/landing_golden_test.dart`)
- ✅ Navigation tests implemented (`test/navigation/landing_nav_test.dart`)
- ✅ Playwright E2E implemented (`test/e2e/ui-smoke.spec.ts`)
- ✅ CI workflow created (`.github/workflows/ux-smoke.yml`)
- ✅ Preflight script created (`scripts/preflight.mjs`)
- ✅ Documentation updated

## Next Steps

1. **Generate golden baselines**: Run `flutter test --update-goldens` and commit
2. **Verify all tests pass**: Run preflight script locally
3. **Enable as required check**: Configure branch protection rules
4. **Create PR**: Open PR with Phase 2 changes and CI screenshots
