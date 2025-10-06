/// Result of a JSONPath query
class JsonPathResult {
  final bool success;
  final dynamic value;
  final String? error;
  final List<dynamic> matches;

  const JsonPathResult({
    required this.success,
    this.value,
    this.error,
    this.matches = const [],
  });
}

/// Simple JSONPath query engine
class JsonPathQuery {
  /// Execute a JSONPath query on JSON data
  static JsonPathResult query(dynamic data, String path) {
    try {
      if (path.isEmpty || path == r'$') {
        return JsonPathResult(
          success: true,
          value: data,
          matches: [data],
        );
      }

      // Remove leading $ if present
      final cleanPath = path.startsWith(r'$') ? path.substring(1) : path;

      // Split path into segments
      final segments = _parsePathSegments(cleanPath);

      final results = _evaluatePath(data, segments);

      return JsonPathResult(
        success: true,
        value: results.length == 1 ? results.first : results,
        matches: results,
      );
    } catch (e) {
      return JsonPathResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Parse path segments from JSONPath expression
  static List<String> _parsePathSegments(String path) {
    final segments = <String>[];
    var current = '';
    var inBrackets = false;

    for (int i = 0; i < path.length; i++) {
      final char = path[i];

      if (char == '[') {
        if (current.isNotEmpty) {
          segments.add(current);
          current = '';
        }
        inBrackets = true;
      } else if (char == ']') {
        if (current.isNotEmpty) {
          segments.add(current);
          current = '';
        }
        inBrackets = false;
      } else if (char == '.' && !inBrackets) {
        if (current.isNotEmpty) {
          segments.add(current);
          current = '';
        }
      } else if (char != '.' || inBrackets) {
        current += char;
      }
    }

    if (current.isNotEmpty) {
      segments.add(current);
    }

    return segments.where((s) => s.isNotEmpty).toList();
  }

  /// Evaluate path segments against data
  static List<dynamic> _evaluatePath(dynamic data, List<String> segments) {
    if (segments.isEmpty) {
      return [data];
    }

    final segment = segments.first;
    final remainingSegments = segments.skip(1).toList();

    // Handle wildcard
    if (segment == '*') {
      final results = <dynamic>[];
      if (data is Map) {
        for (final value in data.values) {
          results.addAll(_evaluatePath(value, remainingSegments));
        }
      } else if (data is List) {
        for (final item in data) {
          results.addAll(_evaluatePath(item, remainingSegments));
        }
      }
      return results;
    }

    // Handle array index or slice
    if (_isArrayIndex(segment)) {
      if (data is! List) return [];

      final index = int.tryParse(segment);
      if (index == null) return [];

      if (index < 0 || index >= data.length) return [];

      return _evaluatePath(data[index], remainingSegments);
    }

    // Handle object property
    if (data is Map<String, dynamic>) {
      if (!data.containsKey(segment)) return [];
      return _evaluatePath(data[segment], remainingSegments);
    }

    // Handle quoted strings in maps
    if (data is Map) {
      // Try to find the key with or without quotes
      final unquoted = segment.replaceAll(RegExp(r'^["\x27]|["\x27]$'), '');
      final key = data.keys.firstWhere(
        (k) => k.toString() == segment || k.toString() == unquoted,
        orElse: () => '',
      );

      if (key.isNotEmpty && data.containsKey(key)) {
        return _evaluatePath(data[key], remainingSegments);
      }
    }

    return [];
  }

  /// Check if segment represents an array index
  static bool _isArrayIndex(String segment) {
    return int.tryParse(segment) != null;
  }

  /// Get all possible paths in a JSON object
  static List<String> getAllPaths(dynamic data, [String prefix = r'$']) {
    final paths = <String>[];

    if (data is Map) {
      for (final entry in data.entries) {
        final key = entry.key.toString();
        final newPrefix = prefix == r'$' ? r'$.' + key : '$prefix.$key';
        paths.add(newPrefix);
        paths.addAll(getAllPaths(entry.value, newPrefix));
      }
    } else if (data is List) {
      for (int i = 0; i < data.length; i++) {
        final newPrefix = '$prefix[$i]';
        paths.add(newPrefix);
        paths.addAll(getAllPaths(data[i], newPrefix));
      }
    }

    return paths;
  }

  /// Validate JSONPath syntax
  static bool isValidPath(String path) {
    try {
      if (path.isEmpty) return false;

      // Basic validation - check for balanced brackets
      int bracketCount = 0;
      for (final char in path.split('')) {
        if (char == '[') bracketCount++;
        if (char == ']') bracketCount--;
        if (bracketCount < 0) return false;
      }

      return bracketCount == 0;
    } catch (e) {
      return false;
    }
  }

  /// Get example JSONPaths for common use cases
  static List<String> getExamplePaths() {
    return [
      r'$', // Root
      r'$.name', // Property access
      r'$.users[0]', // Array index
      r'$.users[*]', // All array items
      r'$.users[*].name', // Property in all array items
      r'$..name', // Recursive descent (not implemented)
      r'$.items[0:3]', // Array slice (not implemented)
    ];
  }
}
