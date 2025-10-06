/// Case conversion utilities for text transformation
class CaseConverter {
  /// Convert text to sentence case (first letter capitalized, rest lowercase)
  static String toSentenceCase(String text) {
    if (text.isEmpty) return text;

    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Convert text to title case (each word capitalized)
  static String toTitleCase(String text) {
    if (text.isEmpty) return text;

    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Convert text to UPPER CASE
  static String toUpperCase(String text) {
    return text.toUpperCase();
  }

  /// Convert text to lower case
  static String toLowerCase(String text) {
    return text.toLowerCase();
  }

  /// Convert text to snake_case
  static String toSnakeCase(String text) {
    if (text.isEmpty) return text;

    // First handle camelCase by adding underscores before uppercase letters
    String result = text.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (match) => '${match.group(1)}_${match.group(2)}',
    );

    // Replace spaces and special characters with underscores
    result = result
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .toLowerCase();

    return result;
  }

  /// Convert text to kebab-case
  static String toKebabCase(String text) {
    if (text.isEmpty) return text;

    // First handle camelCase by adding hyphens before uppercase letters
    String result = text.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (match) => '${match.group(1)}-${match.group(2)}',
    );

    // Replace spaces and special characters with hyphens
    result = result
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .toLowerCase();

    return result;
  }

  /// Convert text to camelCase
  static String toCamelCase(String text) {
    if (text.isEmpty) return text;

    List<String> words = text
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();

    if (words.isEmpty) return '';

    String result = words.first.toLowerCase();
    for (int i = 1; i < words.length; i++) {
      result += words[i][0].toUpperCase() + words[i].substring(1).toLowerCase();
    }

    return result;
  }

  /// Convert text to PascalCase
  static String toPascalCase(String text) {
    if (text.isEmpty) return text;

    List<String> words = text
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();

    return words
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join('');
  }

  /// Get all available case conversion options
  static List<String> get availableCases => [
        'sentence',
        'title',
        'upper',
        'lower',
        'snake',
        'kebab',
        'camel',
        'pascal',
      ];

  /// Convert text using the specified case type
  static String convert(String text, String caseType) {
    switch (caseType.toLowerCase()) {
      case 'sentence':
        return toSentenceCase(text);
      case 'title':
        return toTitleCase(text);
      case 'upper':
        return toUpperCase(text);
      case 'lower':
        return toLowerCase(text);
      case 'snake':
        return toSnakeCase(text);
      case 'kebab':
        return toKebabCase(text);
      case 'camel':
        return toCamelCase(text);
      case 'pascal':
        return toPascalCase(text);
      default:
        return text;
    }
  }
}
