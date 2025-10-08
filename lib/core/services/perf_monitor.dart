import 'package:flutter/foundation.dart';
import 'debug_logger.dart';

/// Performance monitoring utility for tracking route load times
/// Only active in debug mode
class PerfMonitor {
  static final Map<String, DateTime> _routeStartTimes = {};
  static final Map<String, Duration> _routeLoadTimes = {};

  /// Safe debug print that won't trigger VM service errors
  static void _safePrint(String message) {
    if (kDebugMode) {
      DebugLogger.debug(message);
    }
  }

  /// Start timing a route load
  static void startRouteTimer(String routeName) {
    if (kDebugMode) {
      _routeStartTimes[routeName] = DateTime.now();
      _safePrint('🏁 [PerfMonitor] Starting route: $routeName');
    }
  }

  /// Stop timing a route load and log the duration
  static void stopRouteTimer(String routeName) {
    if (kDebugMode) {
      final startTime = _routeStartTimes[routeName];
      if (startTime != null) {
        final duration = DateTime.now().difference(startTime);
        _routeLoadTimes[routeName] = duration;
        _safePrint(
          '✅ [PerfMonitor] Route loaded: $routeName in ${duration.inMilliseconds}ms',
        );
        _routeStartTimes.remove(routeName);
      }
    }
  }

  /// Log a performance metric
  static void logMetric(String name, dynamic value, [String? unit]) {
    if (kDebugMode) {
      final unitStr = unit != null ? ' $unit' : '';
      _safePrint('📊 [PerfMonitor] $name: $value$unitStr');
    }
  }

  /// Get all recorded route load times
  static Map<String, Duration> getRouteLoadTimes() {
    return Map.unmodifiable(_routeLoadTimes);
  }

  /// Print performance summary
  static void printSummary() {
    if (kDebugMode && _routeLoadTimes.isNotEmpty) {
      _safePrint('📈 [PerfMonitor] Performance Summary:');
      final sorted = _routeLoadTimes.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      for (final entry in sorted) {
        _safePrint('  ${entry.key}: ${entry.value.inMilliseconds}ms');
      }

      final total = _routeLoadTimes.values.fold<int>(
        0,
        (sum, duration) => sum + duration.inMilliseconds,
      );
      final average = total / _routeLoadTimes.length;
      _safePrint('  Average: ${average.toStringAsFixed(2)}ms');
      _safePrint('  Total: ${total}ms');
    }
  }

  /// Clear all metrics
  static void clear() {
    _routeStartTimes.clear();
    _routeLoadTimes.clear();
  }
}
