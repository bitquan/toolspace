# Firebase Hosting Workflows - Missing Flutter Setup

**Branch:** `fix/ci-firebase-hosting-missing-flutter`
**Issue:** #98
**Status:** Scaffold created, ready for implementation

---

## Problem Summary

Firebase hosting deployment workflows fail with "flutter: command not found" because they don't install Flutter SDK before running `flutter build web --release`.

---

## Files to Modify

- `.github/workflows/firebase-hosting-pull-request.yml`
- `.github/workflows/firebase-hosting-merge.yml`
- `.github/workflows/preview-hosting.yml`

---

## Implementation Plan

1. Add Flutter setup step using `subosito/flutter-action@v2`
2. Specify Flutter version: `3.24.3` (match current project)
3. Add `flutter pub get` before build
4. Test on a sample PR

---

## Code Snippet

```yaml
- uses: subosito/flutter-action@v2
  with:
    flutter-version: "3.24.3"
    channel: "stable"

- run: flutter pub get
```

---

## Testing Checklist

- [ ] Create test branch with changes
- [ ] Open PR to trigger firebase-hosting-pull-request workflow
- [ ] Verify workflow runs successfully
- [ ] Verify Firebase preview deployment works
- [ ] Merge to main and verify firebase-hosting-merge workflow
- [ ] Check preview-hosting workflow on another PR

---

**AUTO-DEV Ready:** Yes - clear implementation path, no ambiguity.
