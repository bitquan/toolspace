# 🚨 ZERO TOLERANCE POLICY

**Effective Date:** October 8, 2025

## Policy Statement

**This project must have ZERO errors and ZERO warnings at all times.**

No exceptions. No warnings. No errors. Period.

## What This Means

### For All Code

1. **Flutter/Dart Code**

   - Must pass: `flutter analyze --fatal-warnings --fatal-infos`
   - Any info, warning, or error = build fails
   - Includes: deprecation warnings, unused variables, style issues

2. **TypeScript/JavaScript Code (Functions)**

   - Must pass: `eslint . --max-warnings=0`
   - Any ESLint warning = build fails
   - Includes: TypeScript errors, unused imports, formatting issues

3. **Tests: 100% PASS RATE - NO EXCEPTIONS**

   - **Every single test must pass**: `flutter test` and `npm test`
   - **NO failing tests** - Fix or delete unreliable tests
   - **NO skipped tests** - Either fix them or remove them
   - **NO flaky tests** - If it fails sometimes, it's broken
   - Test coverage should not decrease
   - If a test can't be made reliable, remove it and file an issue

4. **Build**
   - Production builds must succeed without warnings
   - `flutter build web --release` must complete cleanly

## Enforcement

### Local Development (Pre-Push Hook)

Every `git push` is blocked by the Local Gate (Husky pre-push hook) which runs:

```bash
npm run preflight
```

This executes comprehensive checks and **blocks the push** if any check fails.

### Continuous Integration

All GitHub Actions workflows enforce the same standards:

- **quality.yml**: Runs `flutter analyze --fatal-warnings --fatal-infos`
- **preview-hosting.yml**: Same strict analysis before deployment
- **All PR checks**: Must pass before merge is allowed

## How to Fix Issues

### Flutter Warnings/Errors

````bash
# Check what's wrong
flutter analyze --fatal-warnings

# Common fixes:
# 1. Unused imports: Remove them
# 2. Deprecated APIs: Update to new APIs (e.g., withOpacity → withValues)

### Test Failures

```bash
# Run tests and see failures
flutter test

# Common fixes:
# 1. Flaky UI tests: Add ensureVisible(), increase pump times
# 2. Off-screen widgets: Use warnIfMissed: false and ensureVisible()
# 3. Async issues: Add proper await and pumpAndSettle()
# 4. Unreliable tests: Fix the root cause or delete the test
# 3. Missing const: Add const where suggested
# 4. Unused variables: Remove or use them
````

### ESLint Warnings

```bash
# Check what's wrong
cd functions
npm run lint

# Auto-fix what's possible
npm run lint -- --fix

# Manual fixes:
# 1. Unused variables: Remove them or prefix with underscore
# 2. TypeScript errors: Fix type issues
# 3. Import order: Let ESLint --fix handle it
```

### Tests Failing

```bash
# Flutter tests
flutter test

# Functions tests
cd functions
npm test

# Debug specific test
flutter test test/path/to/test_test.dart
```

## Rationale

### Why ZERO Tolerance?

1. **Prevent Tech Debt Accumulation**

   - Warnings today = errors tomorrow
   - "We'll fix it later" = never fixed
   - Clean code stays clean

2. **CI/Local Parity**

   - If it passes locally, it passes in CI
   - No surprises in PR checks
   - Faster development cycles

3. **Code Quality**

   - Unused code = confusion
   - Deprecation warnings = future breaks
   - Type errors = runtime failures

4. **Team Standards**
   - Everyone follows same rules
   - No "special exceptions"
   - Clear expectations

## Emergency Bypass

**⚠️ USE ONLY IN GENUINE EMERGENCIES**

If you absolutely must push without passing checks:

```bash
git push --no-verify
```

**REQUIREMENTS:**

1. Open a GitHub issue immediately explaining why
2. Tag issue with `urgent` and `tech-debt`
3. Fix within 24 hours
4. Never use for "I'll fix it later" situations

**Abuse of `--no-verify` will result in:**

- PR rejection
- Code review escalation
- Blocked merge rights

## Questions & Exceptions

### "But I'm just testing something..."

Test in a branch. Don't push broken code.

### "It's just a tiny warning..."

Tiny warnings become big problems. Fix it now.

### "The CI is different from local..."

File a bug. We enforce CI/local parity.

### "I need to deploy urgently..."

Emergency bypass procedure above. Fix immediately after.

### "This is too strict..."

This is the standard. Quality is non-negotiable.

## Success Metrics

We measure success by:

1. **Zero Failed Pushes**: All pushes pass preflight
2. **Zero CI Surprises**: Local = CI results
3. **Zero Tech Debt**: No backlog of "fix later" items
4. **Fast PR Reviews**: No back-and-forth on quality issues

## Related Documentation

- [Local Gate System](./local-gate.md)
- [Contributing Guide](../../README.md#contributing)
- [Dev Log: OPS-LocalGate](../../dev-log/operations/2025-10-08-ops-localgate.md)

---

**Remember:** If it doesn't pass locally with zero warnings, it doesn't leave your machine.

**No exceptions. No warnings. No errors. Period.**
