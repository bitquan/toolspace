import 'package:flutter_test/flutter_test.dart';
import '../../../lib/tools/password_gen/logic/password_generator.dart';

void main() {
  group('PasswordConfig Tests', () {
    test('creates valid configuration', () {
      const config = PasswordConfig(
        length: 16,
        includeUppercase: true,
        includeLowercase: true,
        includeDigits: true,
        includeSymbols: true,
      );
      
      expect(config.isValid(), true);
      expect(config.getValidationError(), null);
    });

    test('validates minimum length', () {
      const config = PasswordConfig(
        length: 7,
        includeUppercase: true,
      );
      
      expect(config.isValid(), false);
      expect(config.getValidationError(), 'Password length must be at least 8 characters');
    });

    test('validates maximum length', () {
      const config = PasswordConfig(
        length: 129,
        includeUppercase: true,
      );
      
      expect(config.isValid(), false);
      expect(config.getValidationError(), 'Password length must be at most 128 characters');
    });

    test('requires at least one character set', () {
      const config = PasswordConfig(
        length: 16,
        includeUppercase: false,
        includeLowercase: false,
        includeDigits: false,
        includeSymbols: false,
      );
      
      expect(config.isValid(), false);
      expect(config.getValidationError(), 'At least one character set must be selected');
    });

    test('builds correct character set', () {
      const config = PasswordConfig(
        length: 16,
        includeUppercase: true,
        includeLowercase: true,
        includeDigits: true,
        includeSymbols: true,
      );
      
      final charset = config.getCharacterSet();
      expect(charset.contains('A'), true);
      expect(charset.contains('a'), true);
      expect(charset.contains('0'), true);
      expect(charset.contains('!'), true);
    });

    test('excludes ambiguous characters when enabled', () {
      const config = PasswordConfig(
        length: 16,
        includeUppercase: true,
        includeLowercase: true,
        includeDigits: true,
        includeSymbols: true,
        avoidAmbiguous: true,
      );
      
      final charset = config.getCharacterSet();
      expect(charset.contains('0'), false); // Excluded
      expect(charset.contains('O'), false); // Excluded
      expect(charset.contains('1'), false); // Excluded
      expect(charset.contains('l'), false); // Excluded
      expect(charset.contains('I'), false); // Excluded
      
      // Other characters should still be present
      expect(charset.contains('A'), true);
      expect(charset.contains('a'), true);
      expect(charset.contains('2'), true);
    });

    test('builds charset with only uppercase', () {
      const config = PasswordConfig(
        length: 16,
        includeUppercase: true,
        includeLowercase: false,
        includeDigits: false,
        includeSymbols: false,
      );
      
      final charset = config.getCharacterSet();
      expect(charset, CharacterSets.uppercase);
    });
  });

  group('PasswordGenerator Tests', () {
    test('generates password with correct length', () {
      const config = PasswordConfig(
        length: 16,
        includeUppercase: true,
        includeLowercase: true,
        includeDigits: true,
        includeSymbols: true,
      );
      
      final password = PasswordGenerator.generate(config);
      expect(password.length, 16);
    });

    test('generates password with only specified character sets', () {
      const config = PasswordConfig(
        length: 50, // Larger sample to increase probability of having all types
        includeUppercase: true,
        includeLowercase: false,
        includeDigits: false,
        includeSymbols: false,
      );
      
      final password = PasswordGenerator.generate(config);
      
      // Check that all characters are uppercase letters
      for (var char in password.split('')) {
        expect(CharacterSets.uppercase.contains(char), true);
      }
    });

    test('generates different passwords on multiple calls', () {
      const config = PasswordConfig(
        length: 16,
        includeUppercase: true,
        includeLowercase: true,
        includeDigits: true,
        includeSymbols: true,
      );
      
      final password1 = PasswordGenerator.generate(config);
      final password2 = PasswordGenerator.generate(config);
      
      // While technically possible for two random passwords to be the same,
      // the probability is extremely low for 16-character passwords
      expect(password1, isNot(equals(password2)));
    });

    test('throws error for invalid configuration', () {
      const config = PasswordConfig(
        length: 5, // Too short
        includeUppercase: true,
      );
      
      expect(() => PasswordGenerator.generate(config), throwsArgumentError);
    });

    test('generates batch of passwords', () {
      const config = PasswordConfig(
        length: 16,
        includeUppercase: true,
        includeLowercase: true,
        includeDigits: true,
        includeSymbols: true,
      );
      
      final passwords = PasswordGenerator.generateBatch(config, count: 20);
      
      expect(passwords.length, 20);
      
      // Check that all passwords have correct length
      for (var password in passwords) {
        expect(password.length, 16);
      }
      
      // Check that passwords are different
      final uniquePasswords = passwords.toSet();
      expect(uniquePasswords.length, 20); // All should be unique
    });

    test('respects avoidAmbiguous in generated passwords', () {
      const config = PasswordConfig(
        length: 100, // Large sample
        includeUppercase: true,
        includeLowercase: true,
        includeDigits: true,
        includeSymbols: false,
        avoidAmbiguous: true,
      );
      
      final password = PasswordGenerator.generate(config);
      
      // Check that ambiguous characters are not present
      expect(password.contains('0'), false);
      expect(password.contains('O'), false);
      expect(password.contains('1'), false);
      expect(password.contains('l'), false);
      expect(password.contains('I'), false);
    });
  });

  group('Entropy Calculation Tests', () {
    test('calculates charset entropy correctly', () {
      // For a charset of size 26 (lowercase only) and length 8
      // Entropy = log2(26) * 8 ≈ 37.6 bits
      const config = PasswordConfig(
        length: 8,
        includeUppercase: false,
        includeLowercase: true,
        includeDigits: false,
        includeSymbols: false,
      );
      
      final entropy = PasswordGenerator.calculateCharsetEntropy(config);
      expect(entropy, closeTo(37.6, 0.5));
    });

    test('calculates entropy for full charset', () {
      // Full charset: 26+26+10+28 = 90 characters
      // For length 16: log2(90) * 16 ≈ 103.3 bits
      const config = PasswordConfig(
        length: 16,
        includeUppercase: true,
        includeLowercase: true,
        includeDigits: true,
        includeSymbols: true,
      );
      
      final entropy = PasswordGenerator.calculateCharsetEntropy(config);
      expect(entropy, greaterThan(100));
    });

    test('returns zero entropy for empty charset', () {
      const config = PasswordConfig(
        length: 16,
        includeUppercase: false,
        includeLowercase: false,
        includeDigits: false,
        includeSymbols: false,
      );
      
      final entropy = PasswordGenerator.calculateCharsetEntropy(config);
      expect(entropy, 0.0);
    });

    test('calculates Shannon entropy for actual password', () {
      const password = 'aaabbbccc'; // 3 chars, each appearing 3 times
      final entropy = PasswordGenerator.calculateEntropy(password);
      
      // Should have some entropy but less than fully random
      expect(entropy, greaterThan(0));
      expect(entropy, lessThan(password.length * 6.64)); // Max for 100 unique chars
    });

    test('Shannon entropy is zero for empty password', () {
      final entropy = PasswordGenerator.calculateEntropy('');
      expect(entropy, 0.0);
    });
  });

  group('Strength Label Tests', () {
    test('labels weak passwords correctly', () {
      expect(PasswordGenerator.getStrengthLabel(30), 'weak');
      expect(PasswordGenerator.getStrengthLabel(39), 'weak');
    });

    test('labels moderate passwords correctly', () {
      expect(PasswordGenerator.getStrengthLabel(40), 'moderate');
      expect(PasswordGenerator.getStrengthLabel(59), 'moderate');
    });

    test('labels strong passwords correctly', () {
      expect(PasswordGenerator.getStrengthLabel(60), 'strong');
      expect(PasswordGenerator.getStrengthLabel(79), 'strong');
    });

    test('labels very strong passwords correctly', () {
      expect(PasswordGenerator.getStrengthLabel(80), 'very strong');
      expect(PasswordGenerator.getStrengthLabel(100), 'very strong');
      expect(PasswordGenerator.getStrengthLabel(150), 'very strong');
    });
  });

  group('Strength Score Tests', () {
    test('calculates score in 0-100 range', () {
      expect(PasswordGenerator.getStrengthScore(0), 0);
      expect(PasswordGenerator.getStrengthScore(50), 50);
      expect(PasswordGenerator.getStrengthScore(100), 100);
      expect(PasswordGenerator.getStrengthScore(150), 100); // Clamped
    });

    test('returns reasonable scores for typical passwords', () {
      const weakConfig = PasswordConfig(
        length: 8,
        includeUppercase: false,
        includeLowercase: true,
        includeDigits: false,
        includeSymbols: false,
      );
      
      final weakEntropy = PasswordGenerator.calculateCharsetEntropy(weakConfig);
      final weakScore = PasswordGenerator.getStrengthScore(weakEntropy);
      expect(weakScore, lessThan(50));
      
      const strongConfig = PasswordConfig(
        length: 20,
        includeUppercase: true,
        includeLowercase: true,
        includeDigits: true,
        includeSymbols: true,
      );
      
      final strongEntropy = PasswordGenerator.calculateCharsetEntropy(strongConfig);
      final strongScore = PasswordGenerator.getStrengthScore(strongEntropy);
      expect(strongScore, greaterThan(80));
    });
  });
}
