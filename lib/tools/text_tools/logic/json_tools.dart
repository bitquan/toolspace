import 'dart:convert';

/// Result of JSON validation
class ValidationResult {
  final bool isValid;
  final String? error;
  final int? errorLine;
  final int? errorColumn;
  final dynamic parsedJson;

  const ValidationResult({
    required this.isValid,
    this.error,
    this.errorLine,
    this.errorColumn,
    this.parsedJson,
  });
}

/// JSON processing utilities for validation, formatting, and minification
class JsonTools {
  /// Validate JSON and return detailed error information
  static ValidationResult validateJson(String jsonString) {
    if (jsonString.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        error: 'JSON string is empty',
        errorLine: 1,
        errorColumn: 1,
      );
    }

    try {
      final parsed = jsonDecode(jsonString);
      return ValidationResult(
        isValid: true,
        parsedJson: parsed,
      );
    } catch (e) {
      // Parse error details from FormatException
      if (e is FormatException) {
        final errorMessage = e.message;
        final offset = e.offset;

        if (offset != null) {
          final lines = jsonString.split('\n');
          int currentOffset = 0;
          int lineNumber = 1;
          int columnNumber = 1;

          for (final line in lines) {
            if (currentOffset + line.length >= offset) {
              columnNumber = offset - currentOffset + 1;
              break;
            }
            currentOffset += line.length + 1; // +1 for newline
            lineNumber++;
          }

          return ValidationResult(
            isValid: false,
            error: errorMessage,
            errorLine: lineNumber,
            errorColumn: columnNumber,
          );
        }

        return ValidationResult(
          isValid: false,
          error: errorMessage,
        );
      }

      return ValidationResult(
        isValid: false,
        error: e.toString(),
      );
    }
  }

  /// Pretty-print JSON with proper formatting
  static String prettyPrint(String jsonString, {int indent = 2}) {
    try {
      final parsed = jsonDecode(jsonString);
      final encoder = JsonEncoder.withIndent(' ' * indent);
      return encoder.convert(parsed);
    } catch (e) {
      throw FormatException('Invalid JSON: ${e.toString()}');
    }
  }

  /// Minify JSON (remove all unnecessary whitespace)
  static String minify(String jsonString) {
    try {
      final parsed = jsonDecode(jsonString);
      return jsonEncode(parsed);
    } catch (e) {
      throw FormatException('Invalid JSON: ${e.toString()}');
    }
  }

  /// Sort JSON object keys alphabetically (recursive)
  static String sortKeys(String jsonString, {int indent = 2}) {
    try {
      final parsed = jsonDecode(jsonString);
      final sorted = _sortObjectKeys(parsed);
      final encoder = JsonEncoder.withIndent(' ' * indent);
      return encoder.convert(sorted);
    } catch (e) {
      throw FormatException('Invalid JSON: ${e.toString()}');
    }
  }

  /// Recursively sort object keys
  static dynamic _sortObjectKeys(dynamic obj) {
    if (obj is Map<String, dynamic>) {
      final sortedMap = <String, dynamic>{};
      final sortedKeys = obj.keys.toList()..sort();

      for (final key in sortedKeys) {
        sortedMap[key] = _sortObjectKeys(obj[key]);
      }

      return sortedMap;
    } else if (obj is List) {
      return obj.map(_sortObjectKeys).toList();
    }

    return obj;
  }

  /// Extract all keys from a JSON object (flattened)
  static List<String> extractKeys(String jsonString) {
    try {
      final parsed = jsonDecode(jsonString);
      final keys = <String>{};
      _extractKeysRecursive(parsed, keys, '');
      return keys.toList()..sort();
    } catch (e) {
      return [];
    }
  }

  /// Recursively extract keys with dot notation
  static void _extractKeysRecursive(
      dynamic obj, Set<String> keys, String prefix) {
    if (obj is Map<String, dynamic>) {
      for (final entry in obj.entries) {
        final key = prefix.isEmpty ? entry.key : '$prefix.${entry.key}';
        keys.add(key);
        _extractKeysRecursive(entry.value, keys, key);
      }
    } else if (obj is List) {
      for (int i = 0; i < obj.length; i++) {
        final key = prefix.isEmpty ? '[$i]' : '$prefix[$i]';
        _extractKeysRecursive(obj[i], keys, key);
      }
    }
  }

  /// Get JSON statistics
  static Map<String, dynamic> getStats(String jsonString) {
    try {
      final validation = validateJson(jsonString);
      if (!validation.isValid) {
        return {'error': 'Invalid JSON'};
      }

      final parsed = validation.parsedJson;
      final stats = <String, dynamic>{
        'valid': true,
        'size_bytes': jsonString.length,
        'size_chars': jsonString.length,
        'lines': jsonString.split('\n').length,
        'keys': extractKeys(jsonString).length,
        'type': _getJsonType(parsed),
      };

      if (parsed is Map) {
        stats['object_properties'] = parsed.length;
      } else if (parsed is List) {
        stats['array_elements'] = parsed.length;
      }

      return stats;
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Get the type of the root JSON element
  static String _getJsonType(dynamic obj) {
    if (obj is Map) return 'object';
    if (obj is List) return 'array';
    if (obj is String) return 'string';
    if (obj is num) return 'number';
    if (obj is bool) return 'boolean';
    if (obj == null) return 'null';
    return 'unknown';
  }

  /// Available JSON operations
  static List<String> get availableOperations => [
        'validate',
        'pretty_print',
        'minify',
        'sort_keys',
        'extract_keys',
        'get_stats',
      ];
}
