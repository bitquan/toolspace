/// Result of text analysis
class CountResult {
  final int characters;
  final int charactersNoSpaces;
  final int words;
  final int sentences;
  final int paragraphs;
  final int lines;
  final double avgWordsPerSentence;
  final double avgCharsPerWord;
  final Map<String, int> wordFrequency;

  const CountResult({
    required this.characters,
    required this.charactersNoSpaces,
    required this.words,
    required this.sentences,
    required this.paragraphs,
    required this.lines,
    required this.avgWordsPerSentence,
    required this.avgCharsPerWord,
    required this.wordFrequency,
  });
}

/// Text counting utilities for words, characters, and statistics
class TextCounters {
  /// Count characters including spaces
  static int countCharacters(String text) {
    return text.length;
  }

  /// Count characters excluding spaces
  static int countCharactersNoSpaces(String text) {
    return text.replaceAll(RegExp(r'\s'), '').length;
  }

  /// Count words (split by whitespace and punctuation)
  static int countWords(String text) {
    if (text.trim().isEmpty) return 0;

    // Split by whitespace and filter out empty strings
    return text
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .length;
  }

  /// Count sentences (split by sentence-ending punctuation)
  static int countSentences(String text) {
    if (text.trim().isEmpty) return 0;

    // Split by sentence endings and filter out empty strings
    return text
        .split(RegExp(r'[.!?]+'))
        .where((sentence) => sentence.trim().isNotEmpty)
        .length;
  }

  /// Count paragraphs (split by double line breaks)
  static int countParagraphs(String text) {
    if (text.trim().isEmpty) return 0;

    // Split by paragraph breaks and filter out empty strings
    return text
        .split(RegExp(r'\n\s*\n'))
        .where((paragraph) => paragraph.trim().isNotEmpty)
        .length;
  }

  /// Count lines (split by line breaks)
  static int countLines(String text) {
    if (text.isEmpty) return 0;

    return text.split('\n').length;
  }

  /// Get word frequency map
  static Map<String, int> getWordFrequency(String text,
      {bool caseSensitive = false}) {
    if (text.trim().isEmpty) return {};

    String processedText = caseSensitive ? text : text.toLowerCase();

    // Extract words (alphanumeric sequences)
    final words = RegExp(r'\b\w+\b')
        .allMatches(processedText)
        .map((match) => match.group(0)!)
        .toList();

    final frequency = <String, int>{};
    for (final word in words) {
      frequency[word] = (frequency[word] ?? 0) + 1;
    }

    return frequency;
  }

  /// Get most common words
  static List<MapEntry<String, int>> getMostCommonWords(
    String text, {
    int limit = 10,
    bool caseSensitive = false,
  }) {
    final frequency = getWordFrequency(text, caseSensitive: caseSensitive);

    final sorted = frequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(limit).toList();
  }

  /// Calculate reading time estimate (average 200 words per minute)
  static Duration getReadingTime(String text, {int wordsPerMinute = 200}) {
    final words = countWords(text);
    final minutes = (words / wordsPerMinute).ceil();
    return Duration(minutes: minutes);
  }

  /// Get comprehensive text analysis
  static CountResult analyze(String text) {
    final characters = countCharacters(text);
    final charactersNoSpaces = countCharactersNoSpaces(text);
    final words = countWords(text);
    final sentences = countSentences(text);
    final paragraphs = countParagraphs(text);
    final lines = countLines(text);
    final wordFrequency = getWordFrequency(text);

    final avgWordsPerSentence = sentences > 0 ? words / sentences : 0.0;
    final avgCharsPerWord = words > 0 ? charactersNoSpaces / words : 0.0;

    return CountResult(
      characters: characters,
      charactersNoSpaces: charactersNoSpaces,
      words: words,
      sentences: sentences,
      paragraphs: paragraphs,
      lines: lines,
      avgWordsPerSentence: avgWordsPerSentence,
      avgCharsPerWord: avgCharsPerWord,
      wordFrequency: wordFrequency,
    );
  }

  /// Get simple counts as a map
  static Map<String, dynamic> getSimpleCounts(String text) {
    return {
      'characters': countCharacters(text),
      'characters_no_spaces': countCharactersNoSpaces(text),
      'words': countWords(text),
      'sentences': countSentences(text),
      'paragraphs': countParagraphs(text),
      'lines': countLines(text),
      'reading_time_minutes': getReadingTime(text).inMinutes,
    };
  }

  /// Available counting operations
  static List<String> get availableCounters => [
        'characters',
        'characters_no_spaces',
        'words',
        'sentences',
        'paragraphs',
        'lines',
        'word_frequency',
        'reading_time',
        'analyze_all',
      ];

  /// Get specific count by type
  static dynamic getCount(String text, String type) {
    switch (type.toLowerCase()) {
      case 'characters':
        return countCharacters(text);
      case 'characters_no_spaces':
        return countCharactersNoSpaces(text);
      case 'words':
        return countWords(text);
      case 'sentences':
        return countSentences(text);
      case 'paragraphs':
        return countParagraphs(text);
      case 'lines':
        return countLines(text);
      case 'word_frequency':
        return getWordFrequency(text);
      case 'reading_time':
        return getReadingTime(text).inMinutes;
      case 'analyze_all':
        return analyze(text);
      default:
        return 0;
    }
  }
}
