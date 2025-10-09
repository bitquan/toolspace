# OPS-LocalGate: Pre-Push Validation System

## Overview

OPS-LocalGate enforces local testing before allowing any git push. This ensures that **local development parity with CI** and prevents pushing broken code.

## What Runs

The preflight system runs the following checks:

### 1. Tooling Verification
- Flutter SDK
- Dart SDK
- Node.js
- npm
- Firebase CLI

All tools must be available and their versions are logged.

### 2. Flutter App Checks
- `flutter pub get` - Install dependencies
- `flutter analyze --no-fatal-infos --no-fatal-warnings` - Static analysis (errors fail)
- `flutter test --coverage` - Run all unit tests with coverage
- `flutter build web --release` - Production build (skipped in `--quick` mode)

### 3. Functions Checks (in `functions/`)
- `npm ci` - Clean install dependencies
- `npm run lint` - ESLint validation (auto-fix with `--fix` flag)
- `npm test --silent` - Run Jest unit tests

### 4. Security Rules & E2E
- **Full mode**: Firebase emulators + Firestore rules + Playwright smoke tests
- **Quick mode**: Firestore rules tests only (skip Playwright)

## Usage

### Basic Commands

```bash
# Full preflight (recommended before push)
npm run preflight

# Quick preflight (skip web build + Playwright)
npm run preflight:quick

# Setup Husky hooks (one-time)
npm run setup:hooks
```

### Flags

```bash
# Quick mode: skip Playwright + web build
node scripts/preflight.mjs --quick

# Skip emulators (rules only)
node scripts/preflight.mjs --no-emulators

# Auto-fix linting issues
node scripts/preflight.mjs --fix

# Combined
node scripts/preflight.mjs --quick --fix
```

### VS Code Tasks

- **"Preflight: All checks (local == CI)"** - Full suite
- **"Preflight (quick)"** - Fast validation

Run via: `Ctrl+Shift+P` → "Tasks: Run Task"

## Expected Runtime

| Mode | Duration | What's Included |
|------|----------|----------------|
| **Full** | ~3-5 min | All checks + web build + E2E |
| **Quick** | ~1-2 min | Core checks, no build/E2E |
| **Fix** | Variable | Runs linting with auto-fix |

## Pre-Push Hook

After running `npm run setup:hooks`, every `git push` automatically triggers `npm run preflight`.

The push is **blocked** if any check fails.

## Bypassing (Emergency Only)

⚠️ **Not recommended**. Only for emergencies:

```bash
git push --no-verify
```

**If you bypass:**
1. Open a follow-up issue immediately
2. Fix the failing checks ASAP
3. Never bypass for convenience

## Logs and Debugging

All preflight runs generate logs:

```
local-ci/
├── logs/
│   ├── flutter-pub-get.log
│   ├── flutter-analyze.log
│   ├── flutter-test.log
│   ├── functions-npm-ci.log
│   ├── functions-lint.log
│   ├── functions-test.log
│   └── ...
└── summary.md  # Markdown summary with pass/fail
```

### Viewing Logs

```bash
# View summary
cat local-ci/summary.md

# View specific step log
cat local-ci/logs/flutter-analyze.log

# Open summary in browser
start local-ci/summary.md  # Windows
open local-ci/summary.md   # macOS
```

## CI Parity

The same `preflight.mjs` script is used in CI workflows:

```yaml
- name: 🔒 Preflight checks
  run: node scripts/preflight.mjs --quick
```

This ensures **local == CI**. If it passes locally, it should pass in CI.

## Troubleshooting

### "Missing required tools"
Install Flutter, Dart, Node.js, npm, Firebase CLI and ensure they're in PATH.

### "Flutter analyze failed"
Run `flutter analyze` locally to see errors. Fix or suppress warnings in `analysis_options.yaml`.

### "Functions lint failed"
Run `cd functions && npm run lint` to see issues. Try `npm run lint -- --fix` for auto-fixes.

### "Functions test failed"
Run `cd functions && npm test` to debug failing tests.

### "E2E/Security rules failed"
Check `local-ci/logs/e2e-with-emulators.log` or run:
```bash
cd test/security
npm run test:rules
```

## Philosophy

> "Push-and-pray is dead. Local validation is mandatory."

The Local Gate enforces this principle. All pushes must be green locally before they leave your machine.

## Related

- [AGENTS.md](../../AGENTS.md) - Developer conventions
- [.github/workflows/](../../.github/workflows/) - CI workflows
- [dev-log/operations/](../../dev-log/operations/) - Operational logs
