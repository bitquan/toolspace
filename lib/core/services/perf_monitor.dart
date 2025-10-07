import 'package:flutter/foundation.dart';

/// Performance monitoring utility for tracking route load times
/// Only active in debug mode
class PerfMonitor {
  static final Map<String, DateTime> _routeStartTimes = {};
  static final Map<String, Duration> _routeLoadTimes = {};

  /// Start timing a route load
  static void startRouteTimer(String routeName) {
    if (kDebugMode) {
      _routeStartTimes[routeName] = DateTime.now();
      debugPrint('🏁 [PerfMonitor] Starting route: $routeName');
    }
  }

  /// Stop timing a route load and log the duration
  static void stopRouteTimer(String routeName) {
    if (kDebugMode) {
      final startTime = _routeStartTimes[routeName];
      if (startTime != null) {
        final duration = DateTime.now().difference(startTime);
        _routeLoadTimes[routeName] = duration;
        debugPrint(
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
      debugPrint('📊 [PerfMonitor] $name: $value$unitStr');
    }
  }

  /// Get all recorded route load times
  static Map<String, Duration> getRouteLoadTimes() {
    return Map.unmodifiable(_routeLoadTimes);
  }

  /// Print performance summary
  static void printSummary() {
    if (kDebugMode && _routeLoadTimes.isNotEmpty) {
      debugPrint('📈 [PerfMonitor] Performance Summary:');
      final sorted = _routeLoadTimes.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      for (final entry in sorted) {
        debugPrint('  ${entry.key}: ${entry.value.inMilliseconds}ms');
      }

      final total = _routeLoadTimes.values.fold<int>(
        0,
        (sum, duration) => sum + duration.inMilliseconds,
      );
      final average = total / _routeLoadTimes.length;
      debugPrint('  Average: ${average.toStringAsFixed(2)}ms');
      debugPrint('  Total: ${total}ms');
    }
  }

  /// Clear all metrics
  static void clear() {
    _routeStartTimes.clear();
    _routeLoadTimes.clear();
  }
}
