import 'dart:math';

/// NanoID generation utilities
class NanoidGenerator {
  static final Random _random = Random.secure();

  // Default alphabet (URL-safe characters)
  static const String defaultAlphabet =
      '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_-';

  // Common preset alphabets
  static const String numbersAlphabet = '0123456789';
  static const String lowercaseAlphabet = 'abcdefghijklmnopqrstuvwxyz';
  static const String uppercaseAlphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const String alphanumericAlphabet =
      '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
  static const String hexAlphabet = '0123456789abcdef';

  /// Generate a NanoID with default settings (21 characters, URL-safe alphabet)
  static String generate({int size = 21}) {
    return generateCustom(size: size, alphabet: defaultAlphabet);
  }

  /// Generate a NanoID with custom alphabet
  /// [size] - Length of the ID (default: 21)
  /// [alphabet] - Custom alphabet to use (default: URL-safe characters)
  static String generateCustom({
    int size = 21,
    String alphabet = defaultAlphabet,
  }) {
    if (size <= 0) {
      throw ArgumentError('Size must be greater than 0');
    }

    if (alphabet.isEmpty) {
      throw ArgumentError('Alphabet cannot be empty');
    }

    if (alphabet.length > 256) {
      throw ArgumentError('Alphabet cannot have more than 256 characters');
    }

    // Check for duplicate characters in alphabet
    if (alphabet.split('').toSet().length != alphabet.length) {
      throw ArgumentError('Alphabet must contain unique characters');
    }

    final buffer = StringBuffer();
    for (int i = 0; i < size; i++) {
      buffer.write(alphabet[_random.nextInt(alphabet.length)]);
    }

    return buffer.toString();
  }

  /// Generate multiple NanoIDs at once
  /// Returns a list of [count] NanoIDs
  static List<String> generateMultiple(
    int count, {
    int size = 21,
    String alphabet = defaultAlphabet,
  }) {
    if (count <= 0) {
      throw ArgumentError('Count must be greater than 0');
    }

    return List.generate(
      count,
      (_) => generateCustom(size: size, alphabet: alphabet),
    );
  }

  /// Generate NanoID with numbers only
  static String generateNumeric({int size = 21}) {
    return generateCustom(size: size, alphabet: numbersAlphabet);
  }

  /// Generate NanoID with lowercase letters only
  static String generateLowercase({int size = 21}) {
    return generateCustom(size: size, alphabet: lowercaseAlphabet);
  }

  /// Generate NanoID with uppercase letters only
  static String generateUppercase({int size = 21}) {
    return generateCustom(size: size, alphabet: uppercaseAlphabet);
  }

  /// Generate NanoID with alphanumeric characters only
  static String generateAlphanumeric({int size = 21}) {
    return generateCustom(size: size, alphabet: alphanumericAlphabet);
  }

  /// Generate NanoID with hexadecimal characters only
  static String generateHex({int size = 21}) {
    return generateCustom(size: size, alphabet: hexAlphabet);
  }

  /// Validate if a string could be a valid NanoID with given alphabet
  static bool isValid(String id, {String alphabet = defaultAlphabet}) {
    if (id.isEmpty) return false;

    for (int i = 0; i < id.length; i++) {
      if (!alphabet.contains(id[i])) {
        return false;
      }
    }

    return true;
  }

  /// Calculate collision probability for given size and alphabet
  /// Returns approximate probability as a string
  static String calculateCollisionProbability(int size, int alphabetSize) {
    if (size <= 0 || alphabetSize <= 0) {
      return 'Invalid parameters';
    }

    // Calculate total possible IDs
    final totalIds = pow(alphabetSize, size);

    // For 1% probability of collision: ~N/100 IDs needed
    // Using birthday paradox approximation: P ≈ n²/(2*N)
    // For 1% probability: n ≈ sqrt(0.01 * 2 * N)
    final idsFor1Percent = sqrt(0.01 * 2 * totalIds.toDouble());

    if (idsFor1Percent > 1e12) {
      return '~1% after ${(idsFor1Percent / 1e12).toStringAsFixed(1)} trillion IDs';
    } else if (idsFor1Percent > 1e9) {
      return '~1% after ${(idsFor1Percent / 1e9).toStringAsFixed(1)} billion IDs';
    } else if (idsFor1Percent > 1e6) {
      return '~1% after ${(idsFor1Percent / 1e6).toStringAsFixed(1)} million IDs';
    } else if (idsFor1Percent > 1e3) {
      return '~1% after ${(idsFor1Percent / 1e3).toStringAsFixed(1)} thousand IDs';
    } else {
      return '~1% after ${idsFor1Percent.toStringAsFixed(0)} IDs';
    }
  }
}
