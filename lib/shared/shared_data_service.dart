/// Shared data service for cross-tool data sharing
class SharedDataService {
  static final SharedDataService _instance = SharedDataService._internal();
  static SharedDataService get instance => _instance;

  SharedDataService._internal();

  final Map<String, dynamic> _sharedData = {};

  /// Set shared data with a key
  void setSharedData(String key, dynamic data) {
    _sharedData[key] = data;
  }

  /// Get shared data by key
  T? getSharedData<T>(String key) {
    return _sharedData[key] as T?;
  }

  /// Check if key exists
  bool hasData(String key) {
    return _sharedData.containsKey(key);
  }

  /// Remove data by key
  void removeData(String key) {
    _sharedData.remove(key);
  }

  /// Clear all shared data
  void clearAll() {
    _sharedData.clear();
  }

  /// Get all keys
  List<String> getAllKeys() {
    return _sharedData.keys.toList();
  }
}
