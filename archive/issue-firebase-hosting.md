## Problem

Firebase hosting deployment workflows fail with "flutter: command not found" error.

**Failing workflows:**

- `firebase-hosting-pull-request.yml`
- `firebase-hosting-merge.yml`
- `preview-hosting.yml`

**Error:**

```
/home/runner/work/_temp/xxx.sh: line 1: flutter: command not found
Process completed with exit code 127.
```

**Root cause:** Workflows run `flutter build web --release` but don't have Flutter SDK installed.

---

## Evidence

```bash
gh run list --workflow "firebase-hosting-pull-request.yml" --limit 10
# Result: All runs failed (pre-existing before PR #96)
```

**Example failure:** https://github.com/bitquan/toolspace/actions/runs/18363729626/job/52312241289

---

## Proposed Fix

Add Flutter setup step before build:

```yaml
steps:
  - uses: actions/checkout@v4

  # ADD THIS
  - uses: subosito/flutter-action@v2
    with:
      flutter-version: "3.24.3"
      channel: "stable"

  - run: flutter pub get
  - run: npm ci
  - run: flutter build web --release

  # ... rest of workflow
```

---

## Acceptance Criteria

- [ ] Firebase hosting PR preview workflow runs successfully on a test PR
- [ ] Firebase hosting merge workflow runs successfully on merge to main
- [ ] Preview hosting workflow runs successfully
- [ ] `flutter build web --release` completes without errors
- [ ] No regression in deployment functionality

---

## Reproduction

1. Open any PR
2. Watch `firebase-hosting-pull-request.yml` workflow
3. Observe failure at `flutter build web --release` step

---

## Impact

- **Severity:** P2 (blocks PR previews, doesn't block main)
- **Scope:** Firebase hosting deployments
- **Workaround:** Manual deploy via `firebase deploy`

---

**Related:** PR #96 (permissions hardening) - this failure is pre-existing and not caused by permissions changes.

**Labels:** `area:ci`, `P2`, `triage`, `ops-zeta`
