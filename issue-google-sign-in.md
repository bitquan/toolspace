## Problem

Multiple CI workflows fail due to `google_sign_in` dependency version conflict.

**Affected workflows:**

- `auth-security-ok.yml` (all jobs)
- `auth-security-gates.yml` (all jobs)
- `pr-ci.yml` (Flutter/Functions jobs)
- `quality.yml` (all jobs)
- `zeta-scan.yml` (static-analysis, coverage-analysis)
- `CodeQL` (Dart analysis)

**Error:**

```
Because google_sign_in 7.2.0 requires SDK version ^3.7.0 and no versions of
google_sign_in match >7.2.0 <8.0.0, google_sign_in ^7.2.0 is forbidden.

So, because toolspace depends on google_sign_in ^7.2.0, version solving failed.

The current Dart SDK version is 3.5.3 (from Flutter 3.24.3 stable).
```

**Root cause:** PR #95 (AUTH-01) added `google_sign_in: ^7.2.0` which requires Dart 3.7.0, but the project uses Flutter 3.24.3 (Dart SDK 3.5.3).

---

## Evidence

**Introduced in:** PR #95 (AUTH-01 authentication work)
**Current version:** `google_sign_in: ^7.2.0` in `pubspec.yaml` line 30
**Flutter version:** 3.24.3 stable (Dart SDK 3.5.3)

**Example failures:**

- https://github.com/bitquan/toolspace/actions/runs/18363729622
- https://github.com/bitquan/toolspace/actions/runs/18363729588
- https://github.com/bitquan/toolspace/actions/runs/18363729603

---

## Proposed Fix

**Option 1 (Recommended):** Downgrade google_sign_in to compatible version

```yaml
# pubspec.yaml
dependencies:
  google_sign_in: ^6.2.2 # Compatible with Dart 3.5.3
```

**Option 2:** Upgrade Flutter (more disruptive)

```yaml
# .github/workflows/*.yml - all Flutter workflows
- uses: subosito/flutter-action@v2
  with:
    flutter-version: "3.35.5" # Includes Dart 3.7.0
    channel: "stable"
```

---

## Acceptance Criteria

- [ ] All Auth Security Check jobs pass
- [ ] All PR CI jobs pass (Flutter build, tests, functions)
- [ ] Quality & Performance checks pass
- [ ] OPS-Zeta static-analysis and coverage-analysis pass
- [ ] CodeQL Dart analysis passes
- [ ] No regression in google_sign_in functionality
- [ ] `flutter pub get` resolves dependencies successfully

---

## Reproduction

1. Checkout any branch with AUTH-01 changes
2. Run `flutter pub get`
3. Observe dependency resolution failure

---

## Impact

- **Severity:** P1 (blocks all PRs, blocks main)
- **Scope:** All Dart/Flutter CI workflows
- **Workaround:** None (must fix to merge PRs)

---

**Related:**

- PR #95 (AUTH-01) - introduced the dependency
- PR #96 (permissions hardening) - not caused by permissions changes

**Labels:** `area:ci`, `P1`, `dependencies`, `triage`, `ops-zeta`
