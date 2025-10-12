import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Guest usage tracking for free tool limits before signup
/// Uses browser localStorage for web platform
class GuestUsageService {
  static const String _storageKey = 'guest_usage';
  static const int _maxFreeUses = 3;

  static final GuestUsageService _instance = GuestUsageService._internal();
  factory GuestUsageService() => _instance;
  GuestUsageService._internal();

  Map<String, int> _usageCount = {};

  /// Initialize the service
  Future<void> initialize() async {
    await _loadUsageData();
  }

  /// Load usage data from browser localStorage
  Future<void> _loadUsageData() async {
    if (kIsWeb) {
      try {
        // For web, we'll use a simple in-memory store for now
        // In a real implementation, you'd use window.localStorage
        _usageCount = {};
      } catch (e) {
        debugPrint('Error loading guest usage data: $e');
        _usageCount = {};
      }
    }
  }

  /// Save usage data to browser localStorage
  Future<void> _saveUsageData() async {
    if (kIsWeb) {
      try {
        // For web, we'll use a simple in-memory store for now
        // In a real implementation, you'd use window.localStorage
        debugPrint('Saving guest usage: $_usageCount');
      } catch (e) {
        debugPrint('Error saving guest usage data: $e');
      }
    }
  }

  /// Check if guest can use a tool
  bool canUseTool(String toolId) {
    final currentUses = _usageCount[toolId] ?? 0;
    return currentUses < _maxFreeUses;
  }

  /// Get remaining uses for a tool
  int getRemainingUses(String toolId) {
    final currentUses = _usageCount[toolId] ?? 0;
    return (_maxFreeUses - currentUses).clamp(0, _maxFreeUses);
  }

  /// Get current usage count for a tool
  int getCurrentUses(String toolId) {
    return _usageCount[toolId] ?? 0;
  }

  /// Track tool usage (increment counter)
  Future<void> trackToolUse(String toolId) async {
    final currentUses = _usageCount[toolId] ?? 0;
    _usageCount[toolId] = currentUses + 1;
    await _saveUsageData();
  }

  /// Check if user has reached limit for any tools
  bool hasReachedAnyLimit() {
    return _usageCount.values.any((count) => count >= _maxFreeUses);
  }

  /// Get tools that have reached the limit
  List<String> getToolsAtLimit() {
    return _usageCount.entries
        .where((entry) => entry.value >= _maxFreeUses)
        .map((entry) => entry.key)
        .toList();
  }

  /// Clear all usage data (for testing or reset)
  Future<void> clearUsageData() async {
    _usageCount.clear();
    await _saveUsageData();
  }

  /// Get total usage across all tools
  int getTotalUsage() {
    return _usageCount.values.fold(0, (sum, count) => sum + count);
  }

  /// Get usage summary for display
  Map<String, Map<String, int>> getUsageSummary() {
    return {
      'usage': Map.from(_usageCount),
      'limits': _usageCount.map((key, _) => MapEntry(key, _maxFreeUses)),
      'remaining': _usageCount
          .map((key, value) => MapEntry(key, (_maxFreeUses - value).clamp(0, _maxFreeUses))),
    };
  }
}

/// Widget for displaying guest usage limits
class GuestUsageBanner extends StatelessWidget {
  final String toolId;
  final VoidCallback? onUpgrade;

  const GuestUsageBanner({
    super.key,
    required this.toolId,
    this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getUsageInfo(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final info = snapshot.data as Map<String, int>;
        final remaining = info['remaining']!;
        final used = info['used']!;
        final total = info['total']!;

        if (remaining <= 0) {
          return _buildLimitReachedBanner(context);
        }

        if (remaining <= 1) {
          return _buildLastUseBanner(context, remaining);
        }

        return _buildUsageInfoBanner(context, used, total, remaining);
      },
    );
  }

  Future<Map<String, int>> _getUsageInfo() async {
    final service = GuestUsageService();
    await service.initialize();

    final used = service.getCurrentUses(toolId);
    final remaining = service.getRemainingUses(toolId);
    const total = 3; // Max free uses

    return {
      'used': used,
      'remaining': remaining,
      'total': total,
    };
  }

  Widget _buildLimitReachedBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.lock, color: Colors.red[400]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Free limit reached',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red[400],
                  ),
                ),
                const Text(
                  'Create a free account to continue using this tool',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onUpgrade ?? () => Navigator.of(context).pushNamed('/auth/signup'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Up Free'),
          ),
        ],
      ),
    );
  }

  Widget _buildLastUseBanner(BuildContext context, int remaining) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: Colors.amber[400]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Last free use! Sign up to continue using all tools.',
              style: TextStyle(color: Colors.amber[100]),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pushNamed('/auth/signup'),
            child: const Text('Sign Up'),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageInfoBanner(BuildContext context, int used, int total, int remaining) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue[400]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Free trial: $remaining uses remaining ($used/$total used)',
              style: TextStyle(color: Colors.blue[100]),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pushNamed('/auth/signup'),
            child: const Text('Sign Up for Unlimited'),
          ),
        ],
      ),
    );
  }
}
