import 'package:flutter/foundation.dart';
import 'share_envelope.dart';

/// In-memory event bus for cross-tool communication
/// Supports TTL-based expiry and multiple subscribers
class ShareBus extends ChangeNotifier {
  static final ShareBus _instance = ShareBus._internal();
  static ShareBus get instance => _instance;

  ShareBus._internal();

  final List<ShareEnvelope> _queue = [];
  final Duration _defaultTtl = const Duration(minutes: 5);

  /// Publish an envelope to the bus
  void publish(ShareEnvelope envelope) {
    _queue.add(envelope);
    notifyListeners();

    // Auto-cleanup expired envelopes
    _cleanupExpired();
  }

  /// Get all non-expired envelopes
  List<ShareEnvelope> getAll() {
    _cleanupExpired();
    return List.unmodifiable(_queue);
  }

  /// Get envelopes by kind
  List<ShareEnvelope> getByKind(ShareKind kind) {
    _cleanupExpired();
    return _queue.where((e) => e.kind == kind).toList();
  }

  /// Get most recent envelope of a specific kind
  ShareEnvelope? getLatest(ShareKind kind) {
    _cleanupExpired();
    final matching = _queue.where((e) => e.kind == kind);
    return matching.isEmpty ? null : matching.last;
  }

  /// Consume (get and remove) the most recent envelope of a kind
  ShareEnvelope? consume(ShareKind kind) {
    _cleanupExpired();
    final matching = _queue.where((e) => e.kind == kind).toList();
    if (matching.isEmpty) return null;

    final envelope = matching.last;
    _queue.remove(envelope);
    notifyListeners();
    return envelope;
  }

  /// Consume (get and remove) a specific envelope
  bool consumeEnvelope(ShareEnvelope envelope) {
    final removed = _queue.remove(envelope);
    if (removed) notifyListeners();
    return removed;
  }

  /// Clear all envelopes
  void clear() {
    _queue.clear();
    notifyListeners();
  }

  /// Remove expired envelopes
  void _cleanupExpired() {
    final now = DateTime.now();
    _queue.removeWhere((e) => now.difference(e.timestamp) > _defaultTtl);
  }

  /// Check if bus has envelopes of a specific kind
  bool has(ShareKind kind) {
    _cleanupExpired();
    return _queue.any((e) => e.kind == kind);
  }

  /// Get count of envelopes
  int get count {
    _cleanupExpired();
    return _queue.length;
  }
}
