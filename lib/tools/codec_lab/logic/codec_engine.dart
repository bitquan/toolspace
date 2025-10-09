import 'dart:convert';
import 'dart:typed_data';

/// Encoding and decoding engine for Base64, Hex, and URL formats
class CodecEngine {
  /// Encode text to Base64
  static String encodeBase64(String text) {
    try {
      final bytes = utf8.encode(text);
      return base64.encode(bytes);
    } catch (e) {
      throw CodecException('Failed to encode to Base64: $e');
    }
  }

  /// Decode Base64 to text
  static String decodeBase64(String encoded) {
    try {
      // Remove whitespace and newlines that might be present
      final cleaned = encoded.replaceAll(RegExp(r'\s'), '');
      final bytes = base64.decode(cleaned);
      return utf8.decode(bytes);
    } catch (e) {
      throw CodecException('Invalid Base64 input: $e');
    }
  }

  /// Encode text to Hexadecimal
  static String encodeHex(String text) {
    try {
      final bytes = utf8.encode(text);
      return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join('');
    } catch (e) {
      throw CodecException('Failed to encode to Hex: $e');
    }
  }

  /// Decode Hexadecimal to text
  static String decodeHex(String hex) {
    // Remove whitespace and common separators
    final cleaned = hex.replaceAll(RegExp(r'[\s:,-]'), '').toLowerCase();

    // Handle empty string - return empty
    if (cleaned.isEmpty) {
      return '';
    }

    // Validate hex string - must contain only hex characters
    if (!RegExp(r'^[0-9a-f]+$').hasMatch(cleaned)) {
      throw const CodecException('Invalid hexadecimal characters');
    }

    // Validate even length
    if (cleaned.length % 2 != 0) {
      throw const CodecException('Hex string must have even length');
    }

    try {
      final bytes = <int>[];
      for (int i = 0; i < cleaned.length; i += 2) {
        final hex = cleaned.substring(i, i + 2);
        bytes.add(int.parse(hex, radix: 16));
      }

      return utf8.decode(bytes);
    } catch (e) {
      throw CodecException('Invalid Hex input: $e');
    }
  }

  /// Encode text using URL encoding (percent encoding)
  static String encodeUrl(String text) {
    try {
      return Uri.encodeComponent(text);
    } catch (e) {
      throw CodecException('Failed to URL encode: $e');
    }
  }

  /// Decode URL encoded text
  static String decodeUrl(String encoded) {
    try {
      return Uri.decodeComponent(encoded);
    } catch (e) {
      throw CodecException('Invalid URL encoded input: $e');
    }
  }

  /// Encode bytes to Base64 (for file processing)
  static String encodeBytesToBase64(Uint8List bytes) {
    try {
      return base64.encode(bytes);
    } catch (e) {
      throw CodecException('Failed to encode bytes to Base64: $e');
    }
  }

  /// Decode Base64 to bytes (for file processing)
  static Uint8List decodeBase64ToBytes(String encoded) {
    try {
      final cleaned = encoded.replaceAll(RegExp(r'\s'), '');
      return base64.decode(cleaned);
    } catch (e) {
      throw CodecException('Invalid Base64 input: $e');
    }
  }

  /// Encode bytes to Hexadecimal (for file processing)
  static String encodeBytesToHex(Uint8List bytes) {
    try {
      return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join('');
    } catch (e) {
      throw CodecException('Failed to encode bytes to Hex: $e');
    }
  }

  /// Decode Hexadecimal to bytes (for file processing)
  static Uint8List decodeHexToBytes(String hex) {
    final cleaned = hex.replaceAll(RegExp(r'[\s:,-]'), '').toLowerCase();

    // Check for empty string
    if (cleaned.isEmpty) {
      throw const CodecException('Hex string cannot be empty');
    }

    // Validate hex string - must contain only hex characters
    if (!RegExp(r'^[0-9a-f]+$').hasMatch(cleaned)) {
      throw const CodecException('Invalid hexadecimal characters');
    }

    // Validate even length
    if (cleaned.length % 2 != 0) {
      throw const CodecException('Hex string must have even length');
    }

    try {
      final bytes = <int>[];
      for (int i = 0; i < cleaned.length; i += 2) {
        final hex = cleaned.substring(i, i + 2);
        bytes.add(int.parse(hex, radix: 16));
      }

      return Uint8List.fromList(bytes);
    } catch (e) {
      throw CodecException('Invalid Hex input: $e');
    }
  }

  /// Detect the format of encoded text
  static CodecFormat detectFormat(String input) {
    final trimmed = input.trim();

    if (trimmed.isEmpty) {
      return CodecFormat.unknown;
    }

    // Check for URL encoding (contains % followed by hex digits)
    if (RegExp(r'%[0-9A-Fa-f]{2}').hasMatch(trimmed)) {
      return CodecFormat.url;
    }

    // Check for Hex BEFORE Base64 (only hex characters, possibly with separators)
    // This must come first since hex can also look like base64
    final hexCleaned = trimmed.replaceAll(RegExp(r'[\s:,-]'), '');
    if (RegExp(r'^[0-9A-Fa-f]+$').hasMatch(hexCleaned) &&
        hexCleaned.length % 2 == 0 &&
        hexCleaned.length >= 4) {
      // Additional check: if it contains non-base64 hex chars (8-9, a-f, A-F only)
      // and is even length, it's more likely hex than base64
      if (RegExp(r'[8-9a-fA-F]').hasMatch(hexCleaned)) {
        return CodecFormat.hex;
      }
    }

    // Check for Base64 (alphanumeric + / + = padding)
    if (RegExp(r'^[A-Za-z0-9+/]*={0,2}$')
        .hasMatch(trimmed.replaceAll(RegExp(r'\s'), ''))) {
      // Additional validation: Base64 length should be multiple of 4 (with padding)
      final cleaned = trimmed.replaceAll(RegExp(r'\s'), '');
      if (cleaned.length % 4 == 0) {
        try {
          base64.decode(cleaned);
          return CodecFormat.base64;
        } catch (_) {
          // Not valid Base64, might still be hex
          if (RegExp(r'^[0-9A-Fa-f]+$').hasMatch(cleaned) &&
              cleaned.length % 2 == 0) {
            return CodecFormat.hex;
          }
        }
      }
    }

    return CodecFormat.unknown;
  }

  /// Validate if a string is valid for the given format
  static bool isValid(String input, CodecFormat format) {
    try {
      switch (format) {
        case CodecFormat.base64:
          decodeBase64(input);
          return true;
        case CodecFormat.hex:
          decodeHex(input);
          return true;
        case CodecFormat.url:
          decodeUrl(input);
          return true;
        case CodecFormat.unknown:
          return false;
      }
    } catch (_) {
      return false;
    }
  }
}

/// Codec format enumeration
enum CodecFormat {
  base64,
  hex,
  url,
  unknown,
}

/// Extension to get display names for codec formats
extension CodecFormatExtension on CodecFormat {
  String get displayName {
    switch (this) {
      case CodecFormat.base64:
        return 'Base64';
      case CodecFormat.hex:
        return 'Hexadecimal';
      case CodecFormat.url:
        return 'URL Encoding';
      case CodecFormat.unknown:
        return 'Unknown';
    }
  }
}

/// Custom exception for codec operations
class CodecException implements Exception {
  final String message;

  const CodecException(this.message);

  @override
  String toString() => message;
}
