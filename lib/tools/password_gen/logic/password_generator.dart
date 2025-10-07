import 'dart:math';

/// Character sets for password generation
class CharacterSets {
  static const uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const lowercase = 'abcdefghijklmnopqrstuvwxyz';
  static const digits = '0123456789';
  static const symbols = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

  // Ambiguous characters that can be confused
  static const ambiguousChars = '0O1lI';
}

/// Configuration for password generation
class PasswordConfig {
  final int length;
  final bool includeUppercase;
  final bool includeLowercase;
  final bool includeDigits;
  final bool includeSymbols;
  final bool avoidAmbiguous;

  const PasswordConfig({
    required this.length,
    this.includeUppercase = true,
    this.includeLowercase = true,
    this.includeDigits = true,
    this.includeSymbols = true,
    this.avoidAmbiguous = false,
  });

  /// Get the character set based on the configuration
  String getCharacterSet() {
    var charset = '';

    if (includeUppercase) charset += CharacterSets.uppercase;
    if (includeLowercase) charset += CharacterSets.lowercase;
    if (includeDigits) charset += CharacterSets.digits;
    if (includeSymbols) charset += CharacterSets.symbols;

    if (avoidAmbiguous && charset.isNotEmpty) {
      for (var char in CharacterSets.ambiguousChars.split('')) {
        charset = charset.replaceAll(char, '');
      }
    }

    return charset;
  }

  /// Check if the configuration is valid
  bool isValid() {
    return length >= 8 &&
        length <= 128 &&
        (includeUppercase ||
            includeLowercase ||
            includeDigits ||
            includeSymbols);
  }

  /// Get validation error message
  String? getValidationError() {
    if (length < 8) return 'Password length must be at least 8 characters';
    if (length > 128) return 'Password length must be at most 128 characters';
    if (!includeUppercase &&
        !includeLowercase &&
        !includeDigits &&
        !includeSymbols) {
      return 'At least one character set must be selected';
    }
    return null;
  }
}

/// Password generator utility
class PasswordGenerator {
  static final Random _random = Random.secure();

  /// Generate a single password based on the configuration
  static String generate(PasswordConfig config) {
    if (!config.isValid()) {
      throw ArgumentError(config.getValidationError());
    }

    final charset = config.getCharacterSet();
    if (charset.isEmpty) {
      throw ArgumentError('Character set is empty');
    }

    final buffer = StringBuffer();
    for (var i = 0; i < config.length; i++) {
      final randomIndex = _random.nextInt(charset.length);
      buffer.write(charset[randomIndex]);
    }

    return buffer.toString();
  }

  /// Generate multiple passwords
  static List<String> generateBatch(PasswordConfig config, {int count = 20}) {
    return List.generate(count, (_) => generate(config));
  }

  /// Calculate Shannon entropy for a password
  /// Returns entropy in bits
  static double calculateEntropy(String password) {
    if (password.isEmpty) return 0.0;

    // Count frequency of each character
    final frequency = <String, int>{};
    for (var char in password.split('')) {
      frequency[char] = (frequency[char] ?? 0) + 1;
    }

    // Calculate Shannon entropy
    double entropy = 0.0;
    final length = password.length;

    for (var count in frequency.values) {
      final probability = count / length;
      entropy -= probability * (log(probability) / ln2);
    }

    return entropy * length;
  }

  /// Calculate entropy based on character set and length
  /// This is the more common approach for password strength
  static double calculateCharsetEntropy(PasswordConfig config) {
    final charset = config.getCharacterSet();
    if (charset.isEmpty) return 0.0;

    // Entropy = log2(charset_size) * length
    return (log(charset.length) / ln2) * config.length;
  }

  /// Get password strength based on entropy
  /// Returns: weak, moderate, strong, very strong
  static String getStrengthLabel(double entropy) {
    if (entropy < 40) return 'weak';
    if (entropy < 60) return 'moderate';
    if (entropy < 80) return 'strong';
    return 'very strong';
  }

  /// Get strength score (0-100)
  static int getStrengthScore(double entropy) {
    // Map entropy to 0-100 scale
    // Very strong passwords typically have 80+ bits of entropy
    final score = (entropy / 100 * 100).clamp(0, 100).round();
    return score;
  }
}
