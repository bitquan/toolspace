import 'package:flutter/material.dart';

/// Service for cross-tool data sharing and workflow integration
///
/// Enables tools to:
/// - Share data with other tools
/// - Navigate with context
/// - Store temporary shared state
class ToolIntegrationService extends ChangeNotifier {
  static final ToolIntegrationService _instance =
      ToolIntegrationService._internal();

  factory ToolIntegrationService() => _instance;

  ToolIntegrationService._internal();

  // Shared data store for cross-tool communication
  final Map<String, dynamic> _sharedData = {};

  /// Store data that can be accessed by other tools
  void shareData(String key, dynamic value) {
    _sharedData[key] = value;
    notifyListeners();
  }

  /// Retrieve shared data from another tool
  T? getData<T>(String key) {
    final data = _sharedData[key];
    return data is T ? data : null;
  }

  /// Clear specific shared data
  void clearData(String key) {
    _sharedData.remove(key);
    notifyListeners();
  }

  /// Clear all shared data
  void clearAll() {
    _sharedData.clear();
    notifyListeners();
  }

  /// Check if data exists for a key
  bool hasData(String key) {
    return _sharedData.containsKey(key);
  }

  /// Get all available keys
  List<String> get availableKeys => _sharedData.keys.toList();
}
