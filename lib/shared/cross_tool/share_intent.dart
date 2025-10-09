import 'dart:convert';
import 'share_envelope.dart';

/// Share intent for cross-tool navigation with data
/// Encodes data as base64url for safe URL transmission
class ShareIntent {
  final String targetTool;
  final ShareEnvelope envelope;

  ShareIntent({
    required this.targetTool,
    required this.envelope,
  });

  /// Create intent URL for navigation
  /// Format: /tools/{tool}?intent={base64url_encoded_envelope}
  String toUrl() {
    final encodedEnvelope = _encodeEnvelope(envelope);
    return '/tools/$targetTool?intent=$encodedEnvelope';
  }

  /// Parse intent from URL query parameters
  static ShareIntent? fromUrl(String toolRoute, Map<String, String> query) {
    final intentParam = query['intent'];
    if (intentParam == null) return null;

    try {
      final envelope = _decodeEnvelope(intentParam);
      return ShareIntent(
        targetTool: toolRoute,
        envelope: envelope,
      );
    } catch (e) {
      return null;
    }
  }

  /// Encode envelope to base64url
  static String _encodeEnvelope(ShareEnvelope envelope) {
    final jsonStr = jsonEncode(envelope.toJson());
    final bytes = utf8.encode(jsonStr);
    return base64Url.encode(bytes);
  }

  /// Decode base64url to envelope
  static ShareEnvelope _decodeEnvelope(String encoded) {
    final bytes = base64Url.decode(encoded);
    final jsonStr = utf8.decode(bytes);
    final json = jsonDecode(jsonStr) as Map<String, dynamic>;
    return ShareEnvelope.fromJson(json);
  }

  @override
  String toString() {
    return 'ShareIntent(targetTool: $targetTool, envelope: ${envelope.kind})';
  }
}
