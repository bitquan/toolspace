import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Wrapper for debug logging that suppresses VM service errors
class DebugLogger {
  static bool _suppressVMServiceErrors = true;

  /// Enable or disable VM service error suppression
  static void setSuppressVMServiceErrors(bool suppress) {
    _suppressVMServiceErrors = suppress;
  }

  /// Safe logging that won't trigger VM service errors
  static void log(
    String message, {
    int level = 0,
    String? name,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!kDebugMode) return;

    try {
      // Use developer.log instead of debugPrint for better VM service compatibility
      developer.log(
        message,
        level: level,
        name: name ?? 'DebugLogger',
        error: error,
        stackTrace: stackTrace,
      );
    } catch (e) {
      // Silently fail - VM service issues shouldn't crash the app
      if (!_suppressVMServiceErrors) {
        // Only print the error if suppression is disabled
        // ignore: avoid_print
        print('DebugLogger error: $e');
      }
    }
  }

  /// Log info message
  static void info(String message) {
    log('ℹ️ $message', level: 800);
  }

  /// Log warning message
  static void warning(String message) {
    log('⚠️ $message', level: 900);
  }

  /// Log error message
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    log('❌ $message', level: 1000, error: error, stackTrace: stackTrace);
  }

  /// Log debug message
  static void debug(String message) {
    log('🐛 $message', level: 500);
  }
}
