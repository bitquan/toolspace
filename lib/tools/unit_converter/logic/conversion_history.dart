import 'unit_search.dart';

/// Manages conversion history
class ConversionHistory {
  static final List<ConversionPair> _history = [];
  static const int maxHistorySize = 20;

  /// Add a conversion to history
  static void add(ConversionPair pair) {
    // Remove if already exists
    _history.removeWhere((p) => p == pair);

    // Add to front with timestamp
    _history.insert(
      0,
      ConversionPair(
        fromUnit: pair.fromUnit,
        toUnit: pair.toUnit,
        category: pair.category,
        timestamp: DateTime.now(),
      ),
    );

    // Limit size
    if (_history.length > maxHistorySize) {
      _history.removeRange(maxHistorySize, _history.length);
    }
  }

  /// Get recent conversion history
  static List<ConversionPair> getRecent({int limit = 10}) {
    return _history.take(limit).toList();
  }

  /// Clear all history
  static void clear() {
    _history.clear();
  }

  /// Check if history is empty
  static bool get isEmpty => _history.isEmpty;

  /// Get history size
  static int get size => _history.length;
}
