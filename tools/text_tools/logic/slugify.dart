/// URL slug generation utilities
class Slugify {
  /// Convert text to a URL-safe slug
  static String toSlug(
    String text, {
    String separator = '-',
    bool lowercase = true,
    int? maxLength,
  }) {
    if (text.isEmpty) return '';

    String result = text;

    // Convert to lowercase if requested
    if (lowercase) {
      result = result.toLowerCase();
    }

    // Replace accented characters with their base equivalents
    result = _removeAccents(result);

    // Remove all non-alphanumeric characters except spaces and hyphens
    result = result.replaceAll(RegExp(r'[^\w\s\-]'), '');

    // Replace spaces and multiple hyphens with separator
    result = result.replaceAll(RegExp(r'[\s\-]+'), separator);

    // Remove leading and trailing separators
    result = result.replaceAll(RegExp('^$separator+|$separator+\$'), '');

    // Truncate if max length is specified
    if (maxLength != null && result.length > maxLength) {
      result = result.substring(0, maxLength);
      // Make sure we don't end with a separator
      result = result.replaceAll(RegExp('$separator+\$'), '');
    }

    return result;
  }

  /// Remove accented characters and replace with base equivalents
  static String _removeAccents(String text) {
    const accentMap = {
      'À': 'A',
      'Á': 'A',
      'Â': 'A',
      'Ã': 'A',
      'Ä': 'A',
      'Å': 'A',
      'à': 'a',
      'á': 'a',
      'â': 'a',
      'ã': 'a',
      'ä': 'a',
      'å': 'a',
      'È': 'E',
      'É': 'E',
      'Ê': 'E',
      'Ë': 'E',
      'è': 'e',
      'é': 'e',
      'ê': 'e',
      'ë': 'e',
      'Ì': 'I',
      'Í': 'I',
      'Î': 'I',
      'Ï': 'I',
      'ì': 'i',
      'í': 'i',
      'î': 'i',
      'ï': 'i',
      'Ò': 'O',
      'Ó': 'O',
      'Ô': 'O',
      'Õ': 'O',
      'Ö': 'O',
      'ò': 'o',
      'ó': 'o',
      'ô': 'o',
      'õ': 'o',
      'ö': 'o',
      'Ù': 'U',
      'Ú': 'U',
      'Û': 'U',
      'Ü': 'U',
      'ù': 'u',
      'ú': 'u',
      'û': 'u',
      'ü': 'u',
      'Ñ': 'N',
      'ñ': 'n',
      'Ç': 'C',
      'ç': 'c',
      'ß': 'ss',
      'Æ': 'AE',
      'æ': 'ae',
      'Œ': 'OE',
      'œ': 'oe',
    };

    String result = text;
    accentMap.forEach((accented, base) {
      result = result.replaceAll(accented, base);
    });

    return result;
  }

  /// Create a filename-safe slug
  static String toFilename(String text, {int? maxLength}) {
    return toSlug(
      text,
      separator: '_',
      lowercase: true,
      maxLength: maxLength,
    );
  }

  /// Create a slug with custom options
  static String custom(
    String text, {
    String separator = '-',
    bool lowercase = true,
    bool removeAccents = true,
    int? maxLength,
    String allowedChars = r'\w\s\-',
  }) {
    if (text.isEmpty) return '';

    String result = text;

    if (lowercase) {
      result = result.toLowerCase();
    }

    if (removeAccents) {
      result = _removeAccents(result);
    }

    // Remove characters not in allowed set
    result = result.replaceAll(RegExp('[^$allowedChars]'), '');

    // Replace spaces and separators
    result = result.replaceAll(RegExp(r'[\s\-_]+'), separator);

    // Clean up edges
    result = result.replaceAll(RegExp('^$separator+|$separator+\$'), '');

    if (maxLength != null && result.length > maxLength) {
      result = result.substring(0, maxLength);
      result = result.replaceAll(RegExp('$separator+\$'), '');
    }

    return result;
  }

  /// Validate if a string is already a valid slug
  static bool isValidSlug(String text, {String separator = '-'}) {
    if (text.isEmpty) return false;

    // Check if it matches slug pattern
    final slugPattern = RegExp('^[a-z0-9]+(?:$separator[a-z0-9]+)*\$');
    return slugPattern.hasMatch(text);
  }

  /// Get available slug types
  static List<String> get availableTypes => [
        'standard',
        'filename',
        'custom',
      ];

  /// Generate slug by type
  static String generate(String text, String type,
      {Map<String, dynamic>? options}) {
    switch (type.toLowerCase()) {
      case 'standard':
        return toSlug(text);
      case 'filename':
        return toFilename(text);
      case 'custom':
        return custom(
          text,
          separator: options?['separator'] ?? '-',
          lowercase: options?['lowercase'] ?? true,
          removeAccents: options?['removeAccents'] ?? true,
          maxLength: options?['maxLength'],
          allowedChars: options?['allowedChars'] ?? r'\w\s\-',
        );
      default:
        return toSlug(text);
    }
  }
}
