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

| Route | CTA | Expected Destination |
|-------|-----|----------------------|
| `/signup` | "Get Started Free" | Signup page |
| `/pricing` | "View Pricing" | Pricing page |
| `/features` | "Features" (navbar) | Features page |
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

## Implementation Status

✅ Marketing pages created (Features, Pricing)  
✅ Routes registered and wired  
✅ Test selectors added (Keys + Semantics)  
🔄 Golden tests (template ready, needs goldens generation)  
🔄 Navigation tests (template ready)  
🔄 Playwright E2E (spec file ready)  
🔄 CI workflow (template ready)  

## Next Steps

1. Generate initial golden files
2. Complete navigation test scenarios
3. Finalize Playwright spec with auth flows
4. Enable ux-smoke.yml as required check
