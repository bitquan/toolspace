# Local CI - Preflight Summary

**Generated:** 2025-10-09T16:51:09.762Z

**Flags:** {"quick":false,"noEmulators":false,"fix":false}

## Results: 2/3 passed

| Step | Status | Duration | Log |
|------|--------|----------|-----|
| Flutter pub get | ✅ PASS | 1470ms | [flutter-pub-get.log](logs/flutter-pub-get.log) |
| Flutter analyze (ZERO tolerance) | ✅ PASS | 5783ms | [flutter-analyze-zero-tolerance-.log](logs/flutter-analyze-zero-tolerance-.log) |
| Flutter test | ❌ FAIL | 1731ms | [flutter-test.log](logs/flutter-test.log) |

## Failures

### Flutter test
```
Flutter failed to check for directory existence at "build\unit_test_assets". The flutter tool cannot access the file or directory.
Please ensure that the SDK and/or project is installed in a location that has read/write permissions for the current user.
```

