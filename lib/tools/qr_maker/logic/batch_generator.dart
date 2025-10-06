/// Batch QR code generation logic
///
/// Handles parsing batch input data (CSV, JSON) and generating multiple QR codes.
library;

/// Represents a single QR code generation request
class QrBatchItem {
  final String content;
  final String? filename;
  final Map<String, dynamic>? metadata;

  const QrBatchItem({
    required this.content,
    this.filename,
    this.metadata,
  });

  factory QrBatchItem.fromJson(Map<String, dynamic> json) {
    return QrBatchItem(
      content: json['content'] as String? ?? '',
      filename: json['filename'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      if (filename != null) 'filename': filename,
      if (metadata != null) 'metadata': metadata,
    };
  }
}

/// Batch generation configuration
class BatchConfig {
  final int qrSize;
  final String foregroundColor;
  final String backgroundColor;
  final String? logoPath;
  final double? logoSize;

  const BatchConfig({
    this.qrSize = 200,
    this.foregroundColor = '#000000',
    this.backgroundColor = '#FFFFFF',
    this.logoPath,
    this.logoSize,
  });
}

/// Result of batch generation
class BatchResult {
  final List<QrBatchItem> successful;
  final List<BatchError> errors;
  final Duration processingTime;

  const BatchResult({
    required this.successful,
    required this.errors,
    required this.processingTime,
  });

  int get totalProcessed => successful.length + errors.length;
  double get successRate =>
      totalProcessed > 0 ? successful.length / totalProcessed : 0.0;
}

/// Error during batch processing
class BatchError {
  final QrBatchItem item;
  final String errorMessage;

  const BatchError({
    required this.item,
    required this.errorMessage,
  });
}

/// Batch QR code generator
class BatchQrGenerator {
  /// Parse CSV content into batch items
  static List<QrBatchItem> parseCsv(String csvContent) {
    final lines = csvContent.trim().split('\n');
    if (lines.isEmpty) return [];

    final items = <QrBatchItem>[];
    
    // Skip header if present
    final startIndex = lines[0].toLowerCase().contains('content') ? 1 : 0;
    
    for (int i = startIndex; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      final parts = _parseCsvLine(line);
      if (parts.isEmpty) continue;

      items.add(QrBatchItem(
        content: parts[0],
        filename: parts.length > 1 ? parts[1] : null,
        metadata: parts.length > 2
            ? {'extra': parts.sublist(2).join(',')}
            : null,
      ));
    }

    return items;
  }

  /// Parse JSON array into batch items
  static List<QrBatchItem> parseJson(String jsonContent) {
    try {
      final dynamic parsed = _parseJsonString(jsonContent);
      
      if (parsed is List) {
        return parsed
            .map((item) {
              if (item is Map<String, dynamic>) {
                return QrBatchItem.fromJson(item);
              } else if (item is String) {
                return QrBatchItem(content: item);
              }
              return null;
            })
            .whereType<QrBatchItem>()
            .toList();
      } else if (parsed is Map<String, dynamic>) {
        // Handle single object wrapped in object
        if (parsed.containsKey('items')) {
          final items = parsed['items'];
          if (items is List) {
            return parseJson(_stringifyJson(items));
          }
        }
        // Single item
        return [QrBatchItem.fromJson(parsed)];
      }
    } catch (e) {
      // Return empty list on parse error
      return [];
    }

    return [];
  }

  /// Validate batch items
  static List<BatchError> validateItems(List<QrBatchItem> items) {
    final errors = <BatchError>[];
    
    for (final item in items) {
      if (item.content.isEmpty) {
        errors.add(BatchError(
          item: item,
          errorMessage: 'Content cannot be empty',
        ));
      } else if (item.content.length > 4000) {
        errors.add(BatchError(
          item: item,
          errorMessage: 'Content exceeds maximum length of 4000 characters',
        ));
      }
    }

    return errors;
  }

  /// Generate batch of QR codes
  static Future<BatchResult> generateBatch(
    List<QrBatchItem> items,
    BatchConfig config,
  ) async {
    final startTime = DateTime.now();
    final successful = <QrBatchItem>[];
    final errors = <BatchError>[];

    // Validate all items first
    errors.addAll(validateItems(items));
    final validItems = items.where((item) => 
      !errors.any((error) => error.item == item)
    ).toList();

    // Process valid items
    for (final item in validItems) {
      try {
        // Simulate QR generation
        await Future.delayed(const Duration(milliseconds: 10));
        successful.add(item);
      } catch (e) {
        errors.add(BatchError(
          item: item,
          errorMessage: 'Generation failed: $e',
        ));
      }
    }

    final processingTime = DateTime.now().difference(startTime);

    return BatchResult(
      successful: successful,
      errors: errors,
      processingTime: processingTime,
    );
  }

  // Helper methods for CSV parsing
  static List<String> _parseCsvLine(String line) {
    final parts = <String>[];
    final buffer = StringBuffer();
    bool inQuotes = false;

    for (int i = 0; i < line.length; i++) {
      final char = line[i];

      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        parts.add(buffer.toString().trim());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }

    if (buffer.isNotEmpty) {
      parts.add(buffer.toString().trim());
    }

    return parts;
  }

  // Minimal JSON parsing without dart:convert
  static dynamic _parseJsonString(String jsonString) {
    final trimmed = jsonString.trim();
    
    if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
      // Simple array parsing
      final content = trimmed.substring(1, trimmed.length - 1).trim();
      if (content.isEmpty) return [];
      
      final items = <dynamic>[];
      final parts = _splitJsonArray(content);
      
      for (final part in parts) {
        items.add(_parseJsonString(part));
      }
      
      return items;
    } else if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
      // Simple object parsing
      final content = trimmed.substring(1, trimmed.length - 1).trim();
      if (content.isEmpty) return <String, dynamic>{};
      
      final map = <String, dynamic>{};
      final pairs = _splitJsonObject(content);
      
      for (final pair in pairs) {
        final colonIndex = pair.indexOf(':');
        if (colonIndex > 0) {
          final key = _unquote(pair.substring(0, colonIndex).trim());
          final value = _parseJsonString(pair.substring(colonIndex + 1).trim());
          map[key] = value;
        }
      }
      
      return map;
    } else if (trimmed.startsWith('"') && trimmed.endsWith('"')) {
      return _unquote(trimmed);
    } else if (trimmed == 'null') {
      return null;
    } else if (trimmed == 'true') {
      return true;
    } else if (trimmed == 'false') {
      return false;
    } else {
      // Try to parse as number
      final numValue = num.tryParse(trimmed);
      return numValue ?? trimmed;
    }
  }

  static List<String> _splitJsonArray(String content) {
    final parts = <String>[];
    final buffer = StringBuffer();
    int depth = 0;
    bool inString = false;

    for (int i = 0; i < content.length; i++) {
      final char = content[i];

      if (char == '"' && (i == 0 || content[i - 1] != '\\')) {
        inString = !inString;
        buffer.write(char);
      } else if (!inString) {
        if (char == '{' || char == '[') {
          depth++;
          buffer.write(char);
        } else if (char == '}' || char == ']') {
          depth--;
          buffer.write(char);
        } else if (char == ',' && depth == 0) {
          if (buffer.toString().trim().isNotEmpty) {
            parts.add(buffer.toString().trim());
          }
          buffer.clear();
        } else {
          buffer.write(char);
        }
      } else {
        buffer.write(char);
      }
    }

    if (buffer.toString().trim().isNotEmpty) {
      parts.add(buffer.toString().trim());
    }

    return parts;
  }

  static List<String> _splitJsonObject(String content) {
    return _splitJsonArray(content);
  }

  static String _unquote(String str) {
    final trimmed = str.trim();
    if (trimmed.startsWith('"') && trimmed.endsWith('"')) {
      return trimmed.substring(1, trimmed.length - 1);
    }
    return trimmed;
  }

  static String _stringifyJson(dynamic value) {
    if (value == null) return 'null';
    if (value is String) return '"$value"';
    if (value is num || value is bool) return value.toString();
    if (value is List) {
      return '[${value.map(_stringifyJson).join(',')}]';
    }
    if (value is Map) {
      final pairs = value.entries
          .map((e) => '"${e.key}":${_stringifyJson(e.value)}')
          .join(',');
      return '{$pairs}';
    }
    return value.toString();
  }
}
