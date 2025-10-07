import 'package:flutter/material.dart';

/// Types of data that can be shared between tools
enum SharedDataType {
  text,
  json,
  url,
  qrCode,
  file,
}

/// A container for data shared between tools
class SharedData {
  final SharedDataType type;
  final dynamic data;
  final String? label;
  final DateTime timestamp;
  final String sourceTool;

  SharedData({
    required this.type,
    required this.data,
    this.label,
    required this.sourceTool,
  }) : timestamp = DateTime.now();

  @override
  String toString() {
    return 'SharedData{type: $type, label: $label, source: $sourceTool}';
  }
}

/// Service for sharing data between tools
/// Uses ChangeNotifier to notify widgets when shared data changes
class SharedDataService extends ChangeNotifier {
  SharedData? _currentData;
  final List<SharedData> _history = [];
  static const int _maxHistorySize = 10;

  /// Get the currently shared data
  SharedData? get currentData => _currentData;

  /// Get the history of shared data
  List<SharedData> get history => List.unmodifiable(_history);

  /// Check if there's data available to receive
  bool get hasData => _currentData != null;

  /// Share data from a tool
  void shareData(SharedData data) {
    _currentData = data;
    _addToHistory(data);
    notifyListeners();
  }

  /// Clear the current shared data
  void clearData() {
    _currentData = null;
    notifyListeners();
  }

  /// Consume the current data and clear it
  SharedData? consumeData() {
    final data = _currentData;
    clearData();
    return data;
  }

  /// Add data to history
  void _addToHistory(SharedData data) {
    _history.insert(0, data);
    if (_history.length > _maxHistorySize) {
      _history.removeLast();
    }
  }

  /// Get history filtered by type
  List<SharedData> getHistoryByType(SharedDataType type) {
    return _history.where((data) => data.type == type).toList();
  }

  /// Clear all history
  void clearHistory() {
    _history.clear();
    notifyListeners();
  }

  /// Singleton pattern for easy access
  static final SharedDataService _instance = SharedDataService._internal();
  factory SharedDataService() => _instance;
  SharedDataService._internal();

  /// Static method to get the singleton instance
  static SharedDataService get instance => _instance;
}
