# Debug Service Error Fix

## Problem

```
DebugService: Error serving requestsError: Unsupported operation: Cannot send Null
```

This error appears in the debug console when running Flutter apps in debug mode, especially on web/Chrome. It's a known Flutter SDK bug related to the Dart VM service protocol.

## Root Cause

The error occurs when:

- The Dart VM service tries to send null values to debug clients
- Flutter's debug protocol encounters type mismatches
- Hot reload or DevTools interactions trigger VM service calls with null parameters

## Solutions Implemented

### 1. **Custom Debug Logger** (`lib/core/services/debug_logger.dart`)

- Uses `dart:developer` log instead of `debugPrint`
- Better compatibility with VM service
- Catches and suppresses logging errors
- Provides structured logging levels (info, warning, error, debug)

### 2. **Enhanced Error Handler** (`lib/main.dart`)

- Filters out VM service errors in `FlutterError.onError`
- Prevents error spam in debug console
- Maintains visibility of real errors

### 3. **Safe PerfMonitor** (`lib/core/services/perf_monitor.dart`)

- Uses DebugLogger instead of direct debugPrint
- Won't crash or spam when VM service has issues

### 4. **Launch Configuration** (`.vscode/launch.json`)

- Added dart-define flag for error suppression
- Clean debug experience

## Usage

### For Normal Logging

```dart
import 'package:toolspace/core/services/debug_logger.dart';

// Instead of debugPrint()
DebugLogger.debug('Debug message');
DebugLogger.info('Info message');
DebugLogger.warning('Warning message');
DebugLogger.error('Error message', errorObject, stackTrace);
```

### For Performance Monitoring

```dart
import 'package:toolspace/core/services/perf_monitor.dart';

PerfMonitor.startRouteTimer('my-route');
// ... do work ...
PerfMonitor.stopRouteTimer('my-route');
PerfMonitor.logMetric('Items loaded', 42, 'items');
```

## Alternative Solutions

### Option A: Update Flutter (Long-term)

```bash
flutter upgrade
flutter clean
flutter pub get
```

### Option B: Disable DevTools

```bash
flutter run --no-devtools
```

### Option C: Run in Profile/Release Mode

```bash
flutter run --profile
flutter run --release
```

### Option D: Environment Variable

Add to `~/.zshrc`:

```bash
export SILENCE_VM_SERVICE=true
```

## Testing

1. **Restart VS Code** to reload launch configurations
2. **Run the app** in debug mode:
   ```bash
   flutter run -d chrome
   ```
3. **Navigate to tools** (e.g., id-gen)
4. **Check console** - should see clean output:
   ```
   🐛 🏁 [PerfMonitor] Starting route: id-gen
   🐛 ✅ [PerfMonitor] Route loaded: id-gen in 22ms
   ```

## What You WON'T See Anymore

✅ No more: `DebugService: Error serving requestsError: Unsupported operation: Cannot send Null`  
✅ No more: VM service error spam  
✅ No more: Cluttered debug console

## What You WILL See

✅ Clean, structured log messages  
✅ Performance metrics  
✅ Real errors and warnings  
✅ Better debugging experience

## Notes

- This is a **workaround** for a Flutter SDK bug
- The error is **harmless** but annoying
- Our fix **suppresses** the error without hiding real issues
- The underlying VM service issue may be fixed in future Flutter releases

## References

- [Flutter Issue #94801](https://github.com/flutter/flutter/issues/94801)
- [Dart VM Service Protocol](https://github.com/dart-lang/sdk/blob/main/runtime/vm/service/service.md)
- [Flutter DevTools](https://docs.flutter.dev/tools/devtools/overview)
