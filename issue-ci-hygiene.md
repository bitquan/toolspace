## Overview

Reduce redundant CI pipeline jobs and unify test/scan matrices for better efficiency and maintainability.

**Problem:** Multiple workflows run overlapping checks (Flutter tests, static analysis, coverage, security scans) causing:

- Wasted compute resources
- Slower PR feedback loops
- Harder maintenance (changes need updates in multiple places)
- Confusing failure messages (same test failing in different workflows)

---

## Current State Analysis

### Duplicate/Overlapping Jobs

**Flutter Tests** run in:

- [ ] `pr-ci.yml` → Flutter Tests
- [ ] `auth-security-gates.yml` → Flutter Tests
- [ ] `quality.yml` → Tests & Linting

**Functions Tests** run in:

- [ ] `pr-ci.yml` → Functions Unit Tests
- [ ] `auth-security-gates.yml` → Functions Tests
- [ ] `quality.yml` → Tests & Linting

**Static Analysis** run in:

- [ ] `pr-ci.yml` → Flutter Build & Analyze
- [ ] `zeta-scan.yml` → static-analysis
- [ ] `quality.yml` → Tests & Linting

**Coverage Analysis** run in:

- [ ] `zeta-scan.yml` → coverage-analysis
- [ ] `quality.yml` → Tests & Linting (implied)

**Security Scans** run in:

- [ ] `zeta-scan.yml` → security-scan
- [ ] `pr-ci.yml` → Security Smoke Tests
- [ ] `auth-security-gates.yml` → Security Rules Tests

---

## Proposed Consolidation

### Option 1: Single Unified PR Pipeline (Recommended)

```yaml
# .github/workflows/pr-unified.yml
name: 🚀 PR Pipeline (Unified)
on: pull_request

jobs:
  # Flutter matrix: [analyze, test, build]
  flutter:
    strategy:
      matrix:
        task: [analyze, test, build]
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: |
          case "${{ matrix.task }}" in
            analyze) flutter analyze ;;
            test) flutter test --coverage ;;
            build) flutter build web --release ;;
          esac

  # Functions matrix: [lint, test, build]
  functions:
    strategy:
      matrix:
        task: [lint, test, build]
    # similar structure

  # Security composite (runs specialized auth/billing e2e)
  security:
    needs: [flutter, functions]
    # Auth-specific tests only here
```

### Option 2: Keep Separate, Remove Duplicates

- [ ] **pr-ci.yml:** Fast smoke tests only (build, basic tests)
- [ ] **quality.yml:** Deep analysis (coverage, linting, bundle size)
- [ ] **zeta-scan.yml:** Security-only (SAST, dependency scan)
- [ ] **auth-security-gates.yml:** E2E auth flows only (no unit tests)

---

## Related Issues

- #98 - Firebase hosting workflows missing Flutter setup
- #99 - google_sign_in dependency conflict
- (link more as discovered)

---

## Success Metrics

**Before:**

- ~15-20 overlapping jobs per PR
- ~10-15 minute total PR CI time
- 3-4 places to update for test changes

**After:**

- ~8-10 deduplicated jobs per PR
- ~5-8 minute total PR CI time
- 1-2 places to update for test changes

---

## Action Items

- [ ] Audit all workflow files for overlapping jobs (detailed matrix)
- [ ] Design unified PR pipeline structure
- [ ] Implement prototype on feature branch
- [ ] Test on sample PR
- [ ] Migrate workflows incrementally
- [ ] Update required checks configuration
- [ ] Archive/disable redundant workflows
- [ ] Document new pipeline architecture

---

**Labels:** `area:ci`, `P2`, `enhancement`, `ops-zeta`, `tech-debt`
