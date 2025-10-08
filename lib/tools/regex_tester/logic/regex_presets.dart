/// Common regex patterns library
class RegexPresets {
  /// Get all available preset categories
  static List<PresetCategory> getAllCategories() {
    return [
      PresetCategory(
        name: 'Basic',
        icon: '📝',
        presets: [
          RegexPreset(
            name: 'Email',
            pattern: r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b',
            description: 'Match email addresses',
            example: 'user@example.com',
          ),
          RegexPreset(
            name: 'URL',
            pattern: r'https?://[^\s]+',
            description: 'Match HTTP/HTTPS URLs',
            example: 'https://example.com',
          ),
          RegexPreset(
            name: 'Phone (US)',
            pattern: r'\b\d{3}[-.]?\d{3}[-.]?\d{4}\b',
            description: 'Match US phone numbers',
            example: '123-456-7890 or 123.456.7890',
          ),
          RegexPreset(
            name: 'Date (YYYY-MM-DD)',
            pattern: r'\b\d{4}-\d{2}-\d{2}\b',
            description: 'Match ISO date format',
            example: '2024-01-15',
          ),
          RegexPreset(
            name: 'Time (HH:MM)',
            pattern: r'\b([01]?[0-9]|2[0-3]):[0-5][0-9]\b',
            description: 'Match 24-hour time format',
            example: '14:30 or 09:15',
          ),
        ],
      ),
      PresetCategory(
        name: 'Numbers',
        icon: '🔢',
        presets: [
          RegexPreset(
            name: 'Integer',
            pattern: r'-?\d+',
            description: 'Match integers (positive or negative)',
            example: '42 or -123',
          ),
          RegexPreset(
            name: 'Decimal',
            pattern: r'-?\d+\.?\d*',
            description: 'Match decimal numbers',
            example: '3.14 or -0.5',
          ),
          RegexPreset(
            name: 'Percentage',
            pattern: r'\d+(\.\d+)?%',
            description: 'Match percentages',
            example: '75% or 3.14%',
          ),
          RegexPreset(
            name: 'Currency (USD)',
            pattern: r'\$\d+(\.\d{2})?',
            description: 'Match US dollar amounts',
            example: '\$19.99 or \$100',
          ),
        ],
      ),
      PresetCategory(
        name: 'Text',
        icon: '📄',
        presets: [
          RegexPreset(
            name: 'Word',
            pattern: r'\b\w+\b',
            description: 'Match words',
            example: 'hello, world',
          ),
          RegexPreset(
            name: 'Sentence',
            pattern: r'[A-Z][^.!?]*[.!?]',
            description: 'Match sentences',
            example: 'This is a sentence.',
          ),
          RegexPreset(
            name: 'Hashtag',
            pattern: r'#\w+',
            description: 'Match hashtags',
            example: '#flutter or #regex',
          ),
          RegexPreset(
            name: 'Mention',
            pattern: r'@\w+',
            description: 'Match mentions',
            example: '@username',
          ),
        ],
      ),
      PresetCategory(
        name: 'Programming',
        icon: '💻',
        presets: [
          RegexPreset(
            name: 'HTML Tag',
            pattern: r'<[^>]+>',
            description: 'Match HTML tags',
            example: '<div> or <p class="text">',
          ),
          RegexPreset(
            name: 'Hex Color',
            pattern: r'#[0-9A-Fa-f]{3,6}\b',
            description: 'Match hex color codes',
            example: '#fff or #FF5733',
          ),
          RegexPreset(
            name: 'IPv4 Address',
            pattern: r'\b(?:\d{1,3}\.){3}\d{1,3}\b',
            description: 'Match IPv4 addresses',
            example: '192.168.1.1',
          ),
          RegexPreset(
            name: 'Variable Name',
            pattern: r'\b[a-zA-Z_]\w*\b',
            description: 'Match valid variable names',
            example: 'myVar or _private',
          ),
        ],
      ),
      PresetCategory(
        name: 'Validation',
        icon: '✅',
        presets: [
          RegexPreset(
            name: 'Username',
            pattern: r'^[a-zA-Z0-9_]{3,16}$',
            description: 'Validate username (3-16 chars)',
            example: 'user_name123',
          ),
          RegexPreset(
            name: 'Strong Password',
            pattern:
                r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
            description: 'Validate strong password',
            example: 'Abc123!@',
          ),
          RegexPreset(
            name: 'Credit Card',
            pattern: r'\b\d{4}[- ]?\d{4}[- ]?\d{4}[- ]?\d{4}\b',
            description: 'Match credit card numbers',
            example: '1234-5678-9012-3456',
          ),
        ],
      ),
    ];
  }

  /// Get all presets as a flat list
  static List<RegexPreset> getAllPresets() {
    return getAllCategories().expand((category) => category.presets).toList();
  }

  /// Search presets by name or description
  static List<RegexPreset> search(String query) {
    if (query.isEmpty) return getAllPresets();

    final lowerQuery = query.toLowerCase();
    return getAllPresets()
        .where((preset) =>
            preset.name.toLowerCase().contains(lowerQuery) ||
            preset.description.toLowerCase().contains(lowerQuery))
        .toList();
  }
}

/// A category of regex presets
class PresetCategory {
  final String name;
  final String icon;
  final List<RegexPreset> presets;

  PresetCategory({
    required this.name,
    required this.icon,
    required this.presets,
  });
}

/// A preset regex pattern
class RegexPreset {
  final String name;
  final String pattern;
  final String description;
  final String example;

  RegexPreset({
    required this.name,
    required this.pattern,
    required this.description,
    required this.example,
  });
}
