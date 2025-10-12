# 🧪 Toolspace QA Smoke Testing Guide

## Overview

This guide explains how to run comprehensive smoke tests for all Toolspace tools locally using test keys and emulators.

## Prerequisites

### Environment Setup

- **Node.js** 18+ with npm
- **Dart/Flutter** latest stable
- **Firebase CLI** latest
- **Stripe CLI** for webhook testing

### Required API Keys (Test Mode Only)

```bash
# Firebase (use test project)
FIREBASE_PROJECT_ID=toolspace-test

# Stripe Test Keys (never use production keys for testing)
STRIPE_TEST_PUBLISHABLE_KEY=pk_test_...
STRIPE_TEST_SECRET_KEY=sk_test_...
STRIPE_TEST_WEBHOOK_SECRET=whsec_test_...
```

## Quick Start

### 1. Start Local Environment

```bash
# Terminal 1: Start Firebase Emulators
cd toolspace
firebase emulators:start --only auth,firestore,functions,storage

# Terminal 2: Start Flutter Web App
flutter run -d chrome --web-port 3000

# Terminal 3: Start Stripe Webhook Listener (if testing billing)
stripe listen --forward-to http://localhost:5001/toolspace-test/us-central1/stripeWebhook
```

### 2. Run Smoke Tests

```bash
# Basic smoke test (all tools)
dart tools/smoke/run_smoke.dart

# Focused test (File Merger only)
dart tools/smoke/run_smoke.dart --tool file_merger

# With verbose logging
dart tools/smoke/run_smoke.dart --verbose
```

### 3. Check Results

```bash
# View summary
cat tools/smoke/report/smoke_report.md

# View detailed JSON
cat tools/smoke/report/smoke_report.json

# Check function logs
cat tools/smoke/report/functions.log
```

## Test Structure

### Free Tools (No Authentication)

- ✅ **JSON Doctor** - Validate/format JSON
- ✅ **Text Diff** - Compare text changes
- ✅ **QR Code Generator** - Generate QR codes
- ✅ **URL Shortener** - Shorten URLs
- ✅ **Codec Lab** - Encode/decode data
- ✅ **Time Converter** - Convert time zones
- ✅ **Regex Tester** - Test regular expressions
- ✅ **ID Generator** - Generate UUIDs/IDs
- ✅ **Color Palette Extractor** - Extract colors from images
- ✅ **CSV Cleaner** - Clean/dedupe CSV files
- ✅ **Password Generator** - Generate secure passwords
- ✅ **JSON Flatten** - Flatten nested JSON
- ✅ **Unit Converter** - Convert units

### Pro Tools (Requires Subscription)

- 💎 **File Merger** - Merge PDFs and images
- 💎 **Markdown to PDF** - Convert MD to PDF
- 💎 **Image Resizer** - Resize/compress images
- 💎 **Audio Converter** - Convert audio formats
- 💎 **File Compressor** - Create ZIP archives

### Billing Tests

- 🔒 **Free → Pro Blocking** - Verify paywall shows
- 🔓 **Pro → Tool Access** - Verify tools work for Pro users
- 💳 **Webhook Sync** - Test Stripe → Firestore updates

## Test Fixtures

All test files are located in `tools/smoke/fixtures/`:

```
fixtures/
├── pdf/
│   ├── a.pdf          # 2-page test PDF
│   └── b.pdf          # 1-page test PDF
├── img/
│   ├── a.jpg          # 500x500 test image
│   └── b.png          # 300x300 test image
├── json/
│   ├── valid.json     # Valid JSON object
│   └── invalid.json   # Malformed JSON with errors
├── csv/
│   └── sample.csv     # CSV with duplicate rows
└── md/
    └── sample.md      # Markdown with tables/code
```

## Interpreting Results

### Success Indicators ✅

```
✅ Tool Name: PASS
  Expected: Tool functions without errors
  Actual: Success
  Notes: Tool accessible and functional
```

### Failure Indicators ❌

```
❌ File Merger: FAIL
  Expected: Merged PDF files
  Actual: Error: [firebase_functions/internal]
  Notes: Exception during file merger test - CHECK FOR internal error
```

### Common Issues & Solutions

#### File Merger `[firebase_functions/internal]`

**Symptoms:**

- Generic internal error
- No detailed error message
- Function fails silently

**Causes & Fixes:**

1. **Image → PDF conversion missing**

   ```typescript
   // Add pdf-lib for image conversion
   const pdfDoc = await PDFDocument.create();
   const image = await pdfDoc.embedJpg(imageBuffer);
   ```

2. **Temp file permissions**

   ```typescript
   // Use proper temp directory
   const tempDir = os.tmpdir();
   const tempFile = path.join(tempDir, `temp-${uuid()}.pdf`);
   ```

3. **Storage permissions**
   ```yaml
   # Verify Firebase Storage rules allow function access
   rules_version = '2';
   service firebase.storage {
     match /b/{bucket}/o {
       match /uploads/{userId}/{allPaths=**} {
         allow read: if request.auth != null && request.auth.uid == userId;
       }
       match /merged/{userId}/{allPaths=**} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
       }
     }
   }
   ```

#### Pro Tool Access Issues

**Symptoms:**

- Free users can access Pro tools
- Pro users get upgrade prompts

**Fixes:**

1. **Check billing profile sync**

   ```typescript
   // Verify Firestore structure
   users/{uid}/billing/profile: {
     planId: 'pro',
     status: 'active',
     currentPeriodStart: timestamp,
     currentPeriodEnd: timestamp
   }
   ```

2. **Verify webhook configuration**
   ```bash
   # Test webhook with Stripe CLI
   stripe listen --events checkout.session.completed
   ```

#### Emulator Connection Issues

**Symptoms:**

- Tools can't connect to local functions
- CORS errors
- Network timeouts

**Fixes:**

1. **Check emulator ports**

   ```json
   // firebase.json
   {
     "emulators": {
       "auth": { "port": 9099 },
       "firestore": { "port": 8080 },
       "functions": { "port": 5001 },
       "storage": { "port": 9199 }
     }
   }
   ```

2. **Update Flutter web config**
   ```dart
   // Use emulator endpoints in debug mode
   if (kDebugMode) {
     await FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
   }
   ```

## Advanced Testing

### Performance Testing

```bash
# Test with large files
dart tools/smoke/run_smoke.dart --large-files

# Concurrent user simulation
dart tools/smoke/run_smoke.dart --concurrent 5
```

### Stress Testing

```bash
# Maximum file limits
dart tools/smoke/run_smoke.dart --stress file_merger

# Quota exhaustion
dart tools/smoke/run_smoke.dart --quota-test
```

### Custom Test Scenarios

```dart
// Add custom tests to run_smoke.dart
await testCustomScenario({
  'tool': 'file_merger',
  'files': ['large1.pdf', 'large2.pdf', 'image.jpg'],
  'expectedPages': 5,
});
```

## CI/CD Integration

### GitHub Actions

```yaml
name: Smoke Tests
on: [push, pull_request]
jobs:
  smoke-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: dart-lang/setup-dart@v1
      - run: firebase emulators:start --only functions &
      - run: dart tools/smoke/run_smoke.dart
      - uses: actions/upload-artifact@v3
        with:
          name: smoke-test-results
          path: tools/smoke/report/
```

## Monitoring & Alerts

### Success Metrics

- **Success Rate**: >95% for all tools
- **Response Time**: <5s for heavy operations
- **Error Rate**: <1% for critical paths

### Alert Conditions

- File Merger failing >2 consecutive tests
- Any free tool showing upgrade prompts
- Webhook sync failures

## Troubleshooting Checklist

### Before Running Tests

- [ ] Firebase emulators running on correct ports
- [ ] Flutter web app accessible at localhost:3000
- [ ] Test fixtures exist and are readable
- [ ] Environment variables set for test keys only

### During Test Failures

- [ ] Check `functions.log` for detailed errors
- [ ] Verify network connectivity to emulators
- [ ] Ensure storage bucket permissions
- [ ] Check Firestore rules for auth requirements

### After Tests Complete

- [ ] Review smoke_report.md for patterns
- [ ] Check processing times for performance issues
- [ ] Verify cleanup completed (no temp files)
- [ ] Archive results for historical comparison

## Support

### Getting Help

- **Logs**: Always include `tools/smoke/report/functions.log`
- **Environment**: Note OS, Node/Dart versions, Firebase CLI version
- **Reproduction**: Include specific test command and fixtures used

### Updating Tests

- Add new tools to `run_smoke.dart` test matrix
- Update fixtures when tool requirements change
- Maintain test documentation with code changes

---

**⚠️ Important**: Never use production API keys or data in smoke tests. Always use dedicated test environments and mock data.
