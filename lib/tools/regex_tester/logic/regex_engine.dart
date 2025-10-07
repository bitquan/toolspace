/// Regex testing engine with match highlighting and capture group extraction
class RegexEngine {
  /// Test a regex pattern against input text
  static RegexTestResult test(
    String pattern,
    String text, {
    bool caseSensitive = true,
    bool multiline = false,
    bool dotAll = false,
    bool unicode = true,
  }) {
    if (pattern.isEmpty) {
      return RegexTestResult(
        isValid: true,
        matches: [],
        error: null,
      );
    }

    try {
      final regex = RegExp(
        pattern,
        caseSensitive: caseSensitive,
        multiLine: multiline,
        dotAll: dotAll,
        unicode: unicode,
      );

      final matches = regex.allMatches(text).toList();
      final matchResults = matches.map((match) {
        return RegexMatch(
          fullMatch: match.group(0) ?? '',
          start: match.start,
          end: match.end,
          groups: _extractGroups(match),
        );
      }).toList();

      return RegexTestResult(
        isValid: true,
        matches: matchResults,
        error: null,
      );
    } catch (e) {
      return RegexTestResult(
        isValid: false,
        matches: [],
        error: _parseError(e.toString()),
      );
    }
  }

  /// Extract all capture groups from a match
  static List<CaptureGroup> _extractGroups(RegExpMatch match) {
    final groups = <CaptureGroup>[];

    // Add all numbered groups (starting from 1, as 0 is the full match)
    for (var i = 1; i <= match.groupCount; i++) {
      final value = match.group(i);
      if (value != null) {
        groups.add(CaptureGroup(
          index: i,
          value: value,
          name: null,
        ));
      }
    }

    // Add named groups if available
    try {
      final patternString = match.pattern.pattern.toString();
      final namedGroupNames = RegExp(r'\(\?<(\w+)>')
          .allMatches(patternString)
          .map((m) => m.group(1))
          .where((name) => name != null)
          .cast<String>()
          .toList();

      for (final name in namedGroupNames) {
        try {
          final value = match.namedGroup(name);
          if (value != null) {
            groups.add(CaptureGroup(
              index: null,
              value: value,
              name: name,
            ));
          }
        } catch (_) {
          // Named group not found, skip
        }
      }
    } catch (_) {
      // Error parsing named groups, skip
    }

    return groups;
  }

  /// Parse error message to make it more user-friendly
  static String _parseError(String error) {
    if (error.contains('FormatException')) {
      error = error.replaceFirst('FormatException: ', '');
      error = error.split('\n').first;
    }

    // Common error patterns
    if (error.contains('Unterminated group')) {
      return 'Unterminated group - check your parentheses';
    } else if (error.contains('Invalid')) {
      return error;
    } else if (error.contains('Unmatched')) {
      return 'Unmatched bracket or parenthesis';
    }

    return error.isEmpty ? 'Invalid regex pattern' : error;
  }

  /// Validate regex pattern syntax
  static bool isValidPattern(String pattern) {
    if (pattern.isEmpty) return true;

    try {
      RegExp(pattern);
      return true;
    } catch (_) {
      return false;
    }
  }
}

/// Result of a regex test operation
class RegexTestResult {
  final bool isValid;
  final List<RegexMatch> matches;
  final String? error;

  RegexTestResult({
    required this.isValid,
    required this.matches,
    required this.error,
  });

  int get matchCount => matches.length;
  bool get hasMatches => matches.isNotEmpty;
  bool get hasError => error != null;
}

/// A single regex match with its position and capture groups
class RegexMatch {
  final String fullMatch;
  final int start;
  final int end;
  final List<CaptureGroup> groups;

  RegexMatch({
    required this.fullMatch,
    required this.start,
    required this.end,
    required this.groups,
  });

  int get length => end - start;
  bool get hasGroups => groups.isNotEmpty;
}

/// A capture group (numbered or named)
class CaptureGroup {
  final int? index;
  final String value;
  final String? name;

  CaptureGroup({
    required this.index,
    required this.value,
    required this.name,
  });

  bool get isNamed => name != null;
  String get displayName => isNamed ? name! : 'Group $index';
}
