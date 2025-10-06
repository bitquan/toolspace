import 'package:flutter_test/flutter_test.dart';
import '../../../lib/tools/regex_tester/logic/regex_engine.dart';

void main() {
  group('RegexEngine Tests', () {
    test('validates simple pattern match', () {
      final result = RegexEngine.test(
        r'\d+',
        'abc 123 def 456',
      );

      expect(result.isValid, true);
      expect(result.hasMatches, true);
      expect(result.matchCount, 2);
      expect(result.matches[0].fullMatch, '123');
      expect(result.matches[1].fullMatch, '456');
    });

    test('handles empty pattern', () {
      final result = RegexEngine.test('', 'test text');

      expect(result.isValid, true);
      expect(result.hasMatches, false);
      expect(result.matchCount, 0);
    });

    test('handles empty text', () {
      final result = RegexEngine.test(r'\d+', '');

      expect(result.isValid, true);
      expect(result.hasMatches, false);
      expect(result.matchCount, 0);
    });

    test('detects invalid regex pattern', () {
      final result = RegexEngine.test(
        r'[unclosed',
        'test text',
      );

      expect(result.isValid, false);
      expect(result.hasError, true);
      expect(result.error, isNotNull);
    });

    test('extracts match positions', () {
      final result = RegexEngine.test(
        r'\d+',
        'abc 123 def',
      );

      expect(result.matches.first.start, 4);
      expect(result.matches.first.end, 7);
      expect(result.matches.first.length, 3);
    });

    test('respects case sensitivity flag', () {
      final pattern = r'hello';
      final text = 'Hello HELLO hello';

      final caseSensitive = RegexEngine.test(
        pattern,
        text,
        caseSensitive: true,
      );
      expect(caseSensitive.matchCount, 1);

      final caseInsensitive = RegexEngine.test(
        pattern,
        text,
        caseSensitive: false,
      );
      expect(caseInsensitive.matchCount, 3);
    });

    test('respects multiline flag', () {
      final pattern = r'^line';
      final text = 'line 1\nline 2\nline 3';

      final singleLine = RegexEngine.test(
        pattern,
        text,
        multiline: false,
      );
      expect(singleLine.matchCount, 1);

      final multiLine = RegexEngine.test(
        pattern,
        text,
        multiline: true,
      );
      expect(multiLine.matchCount, 3);
    });

    test('extracts numbered capture groups', () {
      final result = RegexEngine.test(
        r'(\d+)-(\d+)',
        'Phone: 123-456',
      );

      expect(result.hasMatches, true);
      expect(result.matches.first.hasGroups, true);
      expect(result.matches.first.groups.length, 2);
      expect(result.matches.first.groups[0].value, '123');
      expect(result.matches.first.groups[1].value, '456');
      expect(result.matches.first.groups[0].isNamed, false);
    });

    test('extracts named capture groups', () {
      final result = RegexEngine.test(
        r'(?<area>\d{3})-(?<number>\d{4})',
        'Call: 555-1234',
      );

      expect(result.hasMatches, true);
      final match = result.matches.first;
      expect(match.hasGroups, true);
      
      // Should have both numbered and named groups
      final namedGroups = match.groups.where((g) => g.isNamed).toList();
      expect(namedGroups.isNotEmpty, true);
      
      final areaGroup = namedGroups.firstWhere(
        (g) => g.name == 'area',
        orElse: () => namedGroups.first,
      );
      expect(areaGroup.value, '555');
    });

    test('validates pattern syntax', () {
      expect(RegexEngine.isValidPattern(r'\d+'), true);
      expect(RegexEngine.isValidPattern(r'[a-z]+'), true);
      expect(RegexEngine.isValidPattern(r'(?<name>\w+)'), true);
      expect(RegexEngine.isValidPattern(''), true);
      
      expect(RegexEngine.isValidPattern(r'[unclosed'), false);
      expect(RegexEngine.isValidPattern(r'(?<incomplete'), false);
    });

    test('handles email pattern', () {
      final result = RegexEngine.test(
        r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b',
        'Contact: user@example.com or admin@test.org',
      );

      expect(result.matchCount, 2);
      expect(result.matches[0].fullMatch, 'user@example.com');
      expect(result.matches[1].fullMatch, 'admin@test.org');
    });

    test('handles URL pattern', () {
      final result = RegexEngine.test(
        r'https?://[^\s]+',
        'Visit https://example.com or http://test.org for more',
      );

      expect(result.matchCount, 2);
      expect(result.matches[0].fullMatch, 'https://example.com');
      expect(result.matches[1].fullMatch, 'http://test.org');
    });

    test('handles word boundaries', () {
      final result = RegexEngine.test(
        r'\btest\b',
        'test testing tested test',
      );

      expect(result.matchCount, 2);
      expect(result.matches[0].fullMatch, 'test');
      expect(result.matches[1].fullMatch, 'test');
    });

    test('handles multiple groups in one match', () {
      final result = RegexEngine.test(
        r'(\d{4})-(\d{2})-(\d{2})',
        'Date: 2024-01-15',
      );

      expect(result.matchCount, 1);
      final match = result.matches.first;
      expect(match.groups.length, 3);
      expect(match.groups[0].value, '2024');
      expect(match.groups[1].value, '01');
      expect(match.groups[2].value, '15');
    });

    test('handles no matches gracefully', () {
      final result = RegexEngine.test(
        r'\d+',
        'no numbers here',
      );

      expect(result.isValid, true);
      expect(result.hasMatches, false);
      expect(result.matchCount, 0);
    });

    test('handles overlapping pattern attempts', () {
      final result = RegexEngine.test(
        r'\b\w{3}\b',
        'the cat sat on mat',
      );

      expect(result.hasMatches, true);
      expect(result.matchCount, 4); // 'the', 'cat', 'sat', 'mat'
    });
  });
}
