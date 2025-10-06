import 'dart:math';

/// UUID generation utilities for various formats
class UuidGenerator {
  static final Random _random = Random.secure();

  /// Generate a random UUID v4 (most common format)
  /// Format: xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx
  /// Where x is any hexadecimal digit and y is one of 8, 9, A, or B
  static String generateV4() {
    // Generate 16 random bytes
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));

    // Set version (4) and variant bits according to RFC 4122
    bytes[6] = (bytes[6] & 0x0F) | 0x40; // Version 4
    bytes[8] = (bytes[8] & 0x3F) | 0x80; // Variant bits

    // Convert to hex string with dashes
    return _formatUuid(bytes);
  }

  /// Generate a simple UUID without dashes
  /// Format: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
  static String generateSimple() {
    return generateV4().replaceAll('-', '');
  }

  /// Generate an uppercase UUID
  /// Format: XXXXXXXX-XXXX-4XXX-YXXX-XXXXXXXXXXXX
  static String generateUppercase() {
    return generateV4().toUpperCase();
  }

  /// Generate a short UUID (first 8 characters)
  /// Format: xxxxxxxx
  /// Note: Not guaranteed to be unique, use only for non-critical purposes
  static String generateShort() {
    return generateV4().substring(0, 8);
  }

  /// Generate multiple UUIDs at once
  /// Returns a list of [count] UUIDs
  static List<String> generateMultiple(int count, {bool simple = false}) {
    return List.generate(
        count, (_) => simple ? generateSimple() : generateV4());
  }

  /// Validate if a string is a valid UUID format
  /// Supports both standard and simple formats
  static bool isValid(String uuid) {
    // Standard UUID format
    final standardPattern = RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');

    // Simple UUID format (no dashes)
    final simplePattern = RegExp(r'^[0-9a-fA-F]{32}$');

    return standardPattern.hasMatch(uuid) || simplePattern.hasMatch(uuid);
  }

  /// Format UUID with custom separator
  /// Example: formatWithSeparator(uuid, '_') -> xxxxxxxx_xxxx_4xxx_yxxx_xxxxxxxxxxxx
  static String formatWithSeparator(String uuid, String separator) {
    final clean = uuid.replaceAll('-', '');
    if (clean.length != 32) {
      throw ArgumentError('Invalid UUID format');
    }

    return '${clean.substring(0, 8)}$separator'
        '${clean.substring(8, 12)}$separator'
        '${clean.substring(12, 16)}$separator'
        '${clean.substring(16, 20)}$separator'
        '${clean.substring(20, 32)}';
  }

  /// Convert bytes to formatted UUID string
  static String _formatUuid(List<int> bytes) {
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

    return '${hex.substring(0, 8)}-'
        '${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-'
        '${hex.substring(16, 20)}-'
        '${hex.substring(20, 32)}';
  }
}
