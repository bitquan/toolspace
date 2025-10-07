/// JSON Flattener - Logic for flattening nested JSON structures
///
/// Supports:
/// - Deep nesting with dot notation (e.g., "user.address.city")
/// - Arrays with bracket notation (e.g., "users[0].name")
/// - Custom separators
/// - Field filtering
library;

import 'dart:convert';

/// Result of a flattening operation
class FlattenResult {
  final List<Map<String, dynamic>> rows;
  final List<String> allKeys;
  final bool success;
  final String? error;

  const FlattenResult({
    required this.rows,
    required this.allKeys,
    required this.success,
    this.error,
  });

  factory FlattenResult.error(String message) {
    return FlattenResult(
      rows: [],
      allKeys: [],
      success: false,
      error: message,
    );
  }
}

/// Notation style for flattened keys
enum NotationStyle {
  dot, // user.address.city
  bracket, // user[address][city]
}

/// JSON Flattener utility class
class JsonFlattener {
  /// Flatten a JSON string into a list of flat objects
  ///
  /// If the input is an array, each element becomes a row.
  /// If the input is an object, it becomes a single row.
  static FlattenResult flatten(
    String jsonString, {
    NotationStyle notation = NotationStyle.dot,
    String separator = '.',
    int maxDepth = 100,
  }) {
    if (jsonString.trim().isEmpty) {
      return FlattenResult.error('JSON string is empty');
    }

    try {
      final dynamic parsed = jsonDecode(jsonString);
      return flattenParsed(
        parsed,
        notation: notation,
        separator: separator,
        maxDepth: maxDepth,
      );
    } catch (e) {
      return FlattenResult.error('Invalid JSON: $e');
    }
  }

  /// Flatten already-parsed JSON data
  static FlattenResult flattenParsed(
    dynamic data, {
    NotationStyle notation = NotationStyle.dot,
    String separator = '.',
    int maxDepth = 100,
  }) {
    try {
      List<Map<String, dynamic>> rows = [];

      if (data is List) {
        // If it's an array, flatten each element
        for (var item in data) {
          if (item is Map<String, dynamic>) {
            rows.add(_flattenObject(item, notation, separator, maxDepth));
          } else {
            // Primitive value in array - wrap it
            rows.add({'value': item});
          }
        }
      } else if (data is Map<String, dynamic>) {
        // If it's an object, flatten it as a single row
        rows.add(_flattenObject(data, notation, separator, maxDepth));
      } else {
        // Primitive value - wrap it
        rows.add({'value': data});
      }

      // Collect all unique keys across all rows
      final Set<String> allKeysSet = {};
      for (var row in rows) {
        allKeysSet.addAll(row.keys);
      }

      final List<String> allKeys = allKeysSet.toList()..sort();

      return FlattenResult(
        rows: rows,
        allKeys: allKeys,
        success: true,
      );
    } catch (e) {
      return FlattenResult.error('Flattening error: $e');
    }
  }

  /// Flatten a single object recursively
  static Map<String, dynamic> _flattenObject(
    Map<String, dynamic> obj,
    NotationStyle notation,
    String separator,
    int maxDepth, {
    String prefix = '',
    int currentDepth = 0,
  }) {
    final Map<String, dynamic> result = {};

    if (currentDepth >= maxDepth) {
      // Reached max depth, return as-is
      result[prefix.isEmpty ? 'value' : prefix] = obj;
      return result;
    }

    obj.forEach((key, value) {
      final String newKey = _buildKey(prefix, key, notation, separator);

      if (value == null) {
        result[newKey] = null;
      } else if (value is Map<String, dynamic>) {
        // Recursively flatten nested object
        final flattened = _flattenObject(
          value,
          notation,
          separator,
          maxDepth,
          prefix: newKey,
          currentDepth: currentDepth + 1,
        );
        result.addAll(flattened);
      } else if (value is List) {
        // Handle arrays
        if (value.isEmpty) {
          result[newKey] = '[]';
        } else {
          for (int i = 0; i < value.length; i++) {
            final String arrayKey = notation == NotationStyle.bracket
                ? '$newKey[$i]'
                : '$newKey$separator$i';

            if (value[i] is Map<String, dynamic>) {
              final flattened = _flattenObject(
                value[i] as Map<String, dynamic>,
                notation,
                separator,
                maxDepth,
                prefix: arrayKey,
                currentDepth: currentDepth + 1,
              );
              result.addAll(flattened);
            } else {
              result[arrayKey] = value[i];
            }
          }
        }
      } else {
        // Primitive value
        result[newKey] = value;
      }
    });

    return result;
  }

  /// Build a key based on notation style
  static String _buildKey(
    String prefix,
    String key,
    NotationStyle notation,
    String separator,
  ) {
    if (prefix.isEmpty) {
      return key;
    }

    if (notation == NotationStyle.bracket) {
      return '$prefix[$key]';
    } else {
      return '$prefix$separator$key';
    }
  }

  /// Convert flattened rows to CSV string
  static String toCSV(
    List<Map<String, dynamic>> rows,
    List<String> selectedKeys, {
    String delimiter = ',',
    bool includeHeader = true,
  }) {
    if (rows.isEmpty || selectedKeys.isEmpty) {
      return '';
    }

    final StringBuffer buffer = StringBuffer();

    // Write header
    if (includeHeader) {
      buffer.writeln(selectedKeys.map(_escapeCSV).join(delimiter));
    }

    // Write rows
    for (var row in rows) {
      final List<String> values = selectedKeys
          .map((key) {
            final value = row[key];
            if (value == null) {
              return '';
            }
            return value.toString();
          })
          .map(_escapeCSV)
          .toList();

      buffer.writeln(values.join(delimiter));
    }

    return buffer.toString();
  }

  /// Escape a value for CSV format
  static String _escapeCSV(String value) {
    // If value contains comma, newline, or quote, wrap in quotes and escape quotes
    if (value.contains(',') ||
        value.contains('\n') ||
        value.contains('"') ||
        value.contains('\r')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  /// Get statistics about the flattened data
  static Map<String, dynamic> getStatistics(FlattenResult result) {
    if (!result.success) {
      return {'error': result.error};
    }

    int totalCells = 0;
    int nullCells = 0;
    int maxDepth = 0;

    for (var row in result.rows) {
      totalCells += row.length;
      nullCells += row.values.where((v) => v == null).length;

      for (var key in row.keys) {
        final depth = _getKeyDepth(key);
        if (depth > maxDepth) {
          maxDepth = depth;
        }
      }
    }

    return {
      'rows': result.rows.length,
      'columns': result.allKeys.length,
      'totalCells': totalCells,
      'nullCells': nullCells,
      'maxDepth': maxDepth,
    };
  }

  /// Get the depth of a flattened key
  static int _getKeyDepth(String key) {
    // Count dots or brackets
    int depth = 0;
    depth += '.'.allMatches(key).length;
    depth += '['.allMatches(key).length;
    return depth + 1;
  }

  /// Filter rows to only include selected keys
  static List<Map<String, dynamic>> filterKeys(
    List<Map<String, dynamic>> rows,
    List<String> selectedKeys,
  ) {
    return rows.map((row) {
      final Map<String, dynamic> filtered = {};
      for (var key in selectedKeys) {
        if (row.containsKey(key)) {
          filtered[key] = row[key];
        }
      }
      return filtered;
    }).toList();
  }

  /// Validate JSON before flattening
  static ValidationResult validateJson(String jsonString) {
    if (jsonString.trim().isEmpty) {
      return const ValidationResult(
        isValid: false,
        error: 'JSON string is empty',
        line: 1,
        column: 1,
      );
    }

    try {
      jsonDecode(jsonString);
      return const ValidationResult(isValid: true);
    } catch (e) {
      // Try to extract line and column info from error
      final errorStr = e.toString();
      int? line;
      int? column;

      final lineMatch = RegExp(r'line (\d+)').firstMatch(errorStr);
      if (lineMatch != null) {
        line = int.tryParse(lineMatch.group(1)!);
      }

      final colMatch = RegExp(r'column (\d+)').firstMatch(errorStr);
      if (colMatch != null) {
        column = int.tryParse(colMatch.group(1)!);
      }

      return ValidationResult(
        isValid: false,
        error: errorStr,
        line: line,
        column: column,
      );
    }
  }
}

/// Result of JSON validation
class ValidationResult {
  final bool isValid;
  final String? error;
  final int? line;
  final int? column;

  const ValidationResult({
    required this.isValid,
    this.error,
    this.line,
    this.column,
  });
}
