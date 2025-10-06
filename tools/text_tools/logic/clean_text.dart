/// Text cleaning utilities for whitespace and punctuation normalization
class TextCleaner {
  /// Remove leading and trailing whitespace
  static String trim(String text) {
    return text.trim();
  }

  /// Collapse multiple consecutive spaces into single spaces
  static String collapseSpaces(String text) {
    return text.replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Remove all extra whitespace (trim + collapse)
  static String cleanWhitespace(String text) {
    return collapseSpaces(trim(text));
  }

  /// Remove weird Unicode characters and normalize text
  static String normalizeUnicode(String text) {
    // Remove common problematic Unicode characters
    String cleaned = text
        // Remove zero-width characters
        .replaceAll(RegExp(r'[\u200B-\u200D\uFEFF]'), '')
        // Remove other format characters
        .replaceAll(
            RegExp(r'[\u00AD\u034F\u061C\u115F\u1160\u17B4\u17B5\u180E]'), '')
        // Replace non-breaking spaces with regular spaces
        .replaceAll('\u00A0', ' ')
        // Replace various dash types with regular hyphens
        .replaceAll(RegExp(r'[\u2010-\u2015]'), '-')
        // Replace various quote types with straight quotes
        .replaceAll(RegExp(r'[\u2018\u2019]'), "'")
        .replaceAll(RegExp(r'[\u201C\u201D]'), '"')
        // Replace various apostrophes with straight apostrophe
        .replaceAll(RegExp(r'[\u2019\u02BC]'), "'");

    return cleaned;
  }

  /// Remove all punctuation except basic ones (. , ! ? - ')
  static String stripPunctuation(String text, {bool keepBasic = true}) {
    if (keepBasic) {
      // Keep only basic punctuation
      return text.replaceAll(RegExp(r'[^\w\s.,!?\-\x27]'), '');
    } else {
      // Remove all punctuation
      return text.replaceAll(RegExp(r'[^\w\s]'), '');
    }
  }

  /// Remove numbers from text
  static String stripNumbers(String text) {
    return text.replaceAll(RegExp(r'\d'), '');
  }

  /// Remove extra line breaks (more than 2 consecutive)
  static String normalizeLineBreaks(String text) {
    return text.replaceAll(RegExp(r'\n{3,}'), '\n\n');
  }

  /// Complete text cleaning with all operations
  static String cleanAll(
    String text, {
    bool trimWhitespace = true,
    bool collapseSpaces = true,
    bool normalizeUnicode = true,
    bool normalizeLineBreaks = true,
    bool stripWeirdPunctuation = true,
  }) {
    String result = text;

    if (normalizeUnicode) {
      result = TextCleaner.normalizeUnicode(result);
    }

    if (stripWeirdPunctuation) {
      result = stripPunctuation(result, keepBasic: true);
    }

    if (normalizeLineBreaks) {
      result = TextCleaner.normalizeLineBreaks(result);
    }

    if (collapseSpaces) {
      result = TextCleaner.collapseSpaces(result);
    }

    if (trimWhitespace) {
      result = TextCleaner.trim(result);
    }

    return result;
  }

  /// Get list of cleaning operations available
  static List<String> get availableOperations => [
        'trim',
        'collapse_spaces',
        'normalize_unicode',
        'strip_punctuation',
        'strip_numbers',
        'normalize_line_breaks',
        'clean_all',
      ];

  /// Apply a specific cleaning operation by name
  static String clean(String text, String operation) {
    switch (operation.toLowerCase()) {
      case 'trim':
        return trim(text);
      case 'collapse_spaces':
        return collapseSpaces(text);
      case 'normalize_unicode':
        return normalizeUnicode(text);
      case 'strip_punctuation':
        return stripPunctuation(text);
      case 'strip_numbers':
        return stripNumbers(text);
      case 'normalize_line_breaks':
        return normalizeLineBreaks(text);
      case 'clean_all':
        return cleanAll(text);
      default:
        return text;
    }
  }
}
