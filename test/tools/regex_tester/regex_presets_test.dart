import 'package:flutter_test/flutter_test.dart';
import '../../../lib/tools/regex_tester/logic/regex_presets.dart';

void main() {
  group('RegexPresets Tests', () {
    test('returns all categories', () {
      final categories = RegexPresets.getAllCategories();

      expect(categories, isNotEmpty);
      expect(categories.length, greaterThanOrEqualTo(4));
      
      // Check for expected categories
      expect(
        categories.any((c) => c.name == 'Basic'),
        true,
        reason: 'Should have Basic category',
      );
      expect(
        categories.any((c) => c.name == 'Numbers'),
        true,
        reason: 'Should have Numbers category',
      );
      expect(
        categories.any((c) => c.name == 'Text'),
        true,
        reason: 'Should have Text category',
      );
      expect(
        categories.any((c) => c.name == 'Programming'),
        true,
        reason: 'Should have Programming category',
      );
    });

    test('returns all presets as flat list', () {
      final presets = RegexPresets.getAllPresets();

      expect(presets, isNotEmpty);
      expect(presets.length, greaterThanOrEqualTo(10));
    });

    test('each category has presets', () {
      final categories = RegexPresets.getAllCategories();

      for (final category in categories) {
        expect(
          category.presets,
          isNotEmpty,
          reason: '${category.name} should have presets',
        );
      }
    });

    test('each preset has required fields', () {
      final presets = RegexPresets.getAllPresets();

      for (final preset in presets) {
        expect(preset.name, isNotEmpty, reason: 'Preset should have name');
        expect(preset.pattern, isNotEmpty, reason: 'Preset should have pattern');
        expect(preset.description, isNotEmpty, reason: 'Preset should have description');
        expect(preset.example, isNotEmpty, reason: 'Preset should have example');
      }
    });

    test('searches presets by name', () {
      final results = RegexPresets.search('email');

      expect(results, isNotEmpty);
      expect(
        results.any((p) => p.name.toLowerCase().contains('email')),
        true,
      );
    });

    test('searches presets by description', () {
      final results = RegexPresets.search('phone');

      expect(results, isNotEmpty);
      expect(
        results.any((p) => 
          p.name.toLowerCase().contains('phone') ||
          p.description.toLowerCase().contains('phone')
        ),
        true,
      );
    });

    test('search is case insensitive', () {
      final lowerResults = RegexPresets.search('email');
      final upperResults = RegexPresets.search('EMAIL');
      final mixedResults = RegexPresets.search('EmAiL');

      expect(lowerResults.length, equals(upperResults.length));
      expect(lowerResults.length, equals(mixedResults.length));
    });

    test('empty search returns all presets', () {
      final allPresets = RegexPresets.getAllPresets();
      final searchResults = RegexPresets.search('');

      expect(searchResults.length, equals(allPresets.length));
    });

    test('search with no matches returns empty list', () {
      final results = RegexPresets.search('xyznonexistent123');

      expect(results, isEmpty);
    });

    test('email preset exists with valid pattern', () {
      final presets = RegexPresets.getAllPresets();
      final emailPreset = presets.firstWhere(
        (p) => p.name.toLowerCase().contains('email'),
        orElse: () => presets.first,
      );

      expect(emailPreset.pattern, isNotEmpty);
      expect(emailPreset.pattern, contains('@'));
    });

    test('URL preset exists', () {
      final presets = RegexPresets.getAllPresets();
      final urlPreset = presets.firstWhere(
        (p) => p.name.toLowerCase().contains('url'),
        orElse: () => presets.first,
      );

      expect(urlPreset.pattern, isNotEmpty);
      expect(urlPreset.pattern.toLowerCase(), contains('http'));
    });

    test('phone preset exists', () {
      final presets = RegexPresets.getAllPresets();
      final phonePreset = presets.firstWhere(
        (p) => p.name.toLowerCase().contains('phone'),
        orElse: () => presets.first,
      );

      expect(phonePreset.pattern, isNotEmpty);
      expect(phonePreset.pattern, contains(r'\d'));
    });

    test('category has icon', () {
      final categories = RegexPresets.getAllCategories();

      for (final category in categories) {
        expect(category.icon, isNotEmpty, reason: '${category.name} should have icon');
      }
    });

    test('presets are organized by category', () {
      final categories = RegexPresets.getAllCategories();
      final basicCategory = categories.firstWhere(
        (c) => c.name == 'Basic',
        orElse: () => categories.first,
      );

      expect(basicCategory.presets, isNotEmpty);
      
      // Basic category should have common patterns
      final presetNames = basicCategory.presets.map((p) => p.name.toLowerCase());
      expect(
        presetNames.any((name) => name.contains('email') || name.contains('url')),
        true,
      );
    });

    test('validates preset patterns are valid regex', () {
      final presets = RegexPresets.getAllPresets();

      for (final preset in presets) {
        expect(
          () => RegExp(preset.pattern),
          returnsNormally,
          reason: '${preset.name} should have valid regex pattern',
        );
      }
    });
  });
}
