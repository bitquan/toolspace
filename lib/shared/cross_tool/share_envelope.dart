import 'dart:convert';

/// Types of content that can be shared via cross-tool envelopes
enum ShareKind {
  text,
  json,
  fileUrl,
  dataUrl,
  markdown,
  csv,
  image,
}

/// A wrapper for data shared between tools with metadata
class ShareEnvelope {
  final ShareKind kind;
  final dynamic value;
  final Map<String, dynamic> meta;
  final DateTime timestamp;

  ShareEnvelope({
    required this.kind,
    required this.value,
    Map<String, dynamic>? meta,
  })  : meta = meta ?? {},
        timestamp = DateTime.now();

  /// Create envelope from JSON
  factory ShareEnvelope.fromJson(Map<String, dynamic> json) {
    return ShareEnvelope(
      kind: ShareKind.values.byName(json['kind'] as String),
      value: json['value'],
      meta: Map<String, dynamic>.from(json['meta'] as Map? ?? {}),
    );
  }

  /// Convert envelope to JSON
  Map<String, dynamic> toJson() => {
        'kind': kind.name,
        'value': value,
        'meta': meta,
        'timestamp': timestamp.toIso8601String(),
      };

  /// Check if envelope is expired (default TTL: 5 minutes)
  bool isExpired({Duration ttl = const Duration(minutes: 5)}) {
    return DateTime.now().difference(timestamp) > ttl;
  }

  /// Create envelope with file URL
  factory ShareEnvelope.fileUrl(String url, {Map<String, dynamic>? meta}) {
    return ShareEnvelope(
      kind: ShareKind.fileUrl,
      value: url,
      meta: meta,
    );
  }

  /// Create envelope with JSON data
  factory ShareEnvelope.json(Map<String, dynamic> data,
      {Map<String, dynamic>? meta}) {
    return ShareEnvelope(
      kind: ShareKind.json,
      value: jsonEncode(data),
      meta: meta,
    );
  }

  /// Create envelope with plain text
  factory ShareEnvelope.text(String text, {Map<String, dynamic>? meta}) {
    return ShareEnvelope(
      kind: ShareKind.text,
      value: text,
      meta: meta,
    );
  }

  @override
  String toString() {
    return 'ShareEnvelope(kind: $kind, value: ${value.toString().substring(0, value.toString().length > 50 ? 50 : value.toString().length)}..., meta: $meta)';
  }
}
