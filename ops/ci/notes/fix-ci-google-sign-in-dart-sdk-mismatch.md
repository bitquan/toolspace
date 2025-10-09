# Google Sign-In Dependency Conflict

**Branch:** `fix/ci-google-sign-in-dart-sdk-mismatch`
**Issue:** #99
**Status:** Scaffold created, ready for implementation

---

## Problem Summary

`google_sign_in: ^7.2.0` requires Dart SDK ^3.7.0, but Flutter 3.24.3 ships with Dart SDK 3.5.3, causing dependency resolution failures across all CI workflows.

---

## Files to Modify

- `pubspec.yaml` (line 30)
- `pubspec.lock` (will regenerate)

---

## Implementation Plan

### Option 1: Downgrade google_sign_in (Recommended - Less Disruptive)

```yaml
# pubspec.yaml
dependencies:
  google_sign_in: ^6.2.2 # Last version compatible with Dart 3.5.3
```

**Pros:**

- Minimal change
- Maintains current Flutter version
- Low risk

**Cons:**

- Misses latest google_sign_in features (if any)

### Option 2: Upgrade Flutter

Update all workflow files to use Flutter with Dart 3.7.0+:

```yaml
# All .github/workflows/*.yml with Flutter
- uses: subosito/flutter-action@v2
  with:
    flutter-version: "3.35.5" # or latest stable with Dart 3.7.0+
    channel: "stable"
```

**Pros:**

- Access to latest packages
- Future-proof

**Cons:**

- More disruptive
- Potential breaking changes
- Must test entire app

---

## Recommended Approach

1. Start with Option 1 (downgrade google_sign_in)
2. Run `flutter pub get` locally to verify
3. Push and verify all CI workflows pass
4. Schedule Option 2 (Flutter upgrade) for next sprint if needed

---

## Testing Checklist

- [ ] Modify pubspec.yaml with recommended version
- [ ] Run `flutter pub get` locally - verify no errors
- [ ] Run `flutter analyze` - verify no new warnings
- [ ] Run `flutter test` - verify all tests pass
- [ ] Push to test branch
- [ ] Verify all CI workflows pass:
  - [ ] pr-ci.yml
  - [ ] auth-security-ok.yml
  - [ ] auth-security-gates.yml
  - [ ] quality.yml
  - [ ] zeta-scan.yml
  - [ ] CodeQL
- [ ] Test Google Sign-In functionality manually (if app uses it)

---

**AUTO-DEV Ready:** Yes - clear fix with Option 1, fallback to Option 2 documented.
