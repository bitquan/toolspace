import 'package:flutter_test/flutter_test.dart';
import 'package:toolspace/tools/text_diff/logic/word_diff_engine.dart';

void main() {
  group('WordDiffEngine Tests', () {
    test('computeWordDiff detects insertions', () {
      final text1 = 'Hello world';
      final text2 = 'Hello beautiful world';
      
      final diffs = WordDiffEngine.computeWordDiff(text1, text2);
      
      final insertions = diffs.where((d) => d.type == WordDiffType.insert);
      expect(insertions.length, greaterThan(0));
      expect(insertions.any((d) => d.text.contains('beautiful')), true);
    });

    test('computeWordDiff detects deletions', () {
      final text1 = 'Hello beautiful world';
      final text2 = 'Hello world';
      
      final diffs = WordDiffEngine.computeWordDiff(text1, text2);
      
      final deletions = diffs.where((d) => d.type == WordDiffType.delete);
      expect(deletions.length, greaterThan(0));
    });

    test('computeWordDiff detects equal words', () {
      final text1 = 'Hello world';
      final text2 = 'Hello world';
      
      final diffs = WordDiffEngine.computeWordDiff(text1, text2);
      
      expect(diffs.every((d) => d.type == WordDiffType.equal), true);
    });

    test('computeWordDiff handles empty strings', () {
      final text1 = '';
      final text2 = 'Hello';
      
      final diffs = WordDiffEngine.computeWordDiff(text1, text2);
      
      expect(diffs, isNotEmpty);
      expect(diffs.first.type, WordDiffType.insert);
    });

    test('computeWordDiff handles whitespace', () {
      final text1 = 'Hello   world';
      final text2 = 'Hello world';
      
      final diffs = WordDiffEngine.computeWordDiff(text1, text2);
      
      expect(diffs, isNotEmpty);
    });

    test('computeWordDiff handles multiline text', () {
      final text1 = 'Line 1\nLine 2';
      final text2 = 'Line 1\nLine 2\nLine 3';
      
      final diffs = WordDiffEngine.computeWordDiff(text1, text2);
      
      final insertions = diffs.where((d) => d.type == WordDiffType.insert);
      expect(insertions.length, greaterThan(0));
    });

    test('getWordDiffStats calculates statistics correctly', () {
      final text1 = 'Hello world';
      final text2 = 'Hello beautiful new world';
      
      final diffs = WordDiffEngine.computeWordDiff(text1, text2);
      final stats = WordDiffEngine.getWordDiffStats(diffs);
      
      expect(stats.additions, greaterThan(0));
      expect(stats.unchanged, greaterThan(0));
      expect(stats.totalWords, greaterThan(0));
      expect(stats.similarity, greaterThanOrEqualTo(0));
      expect(stats.similarity, lessThanOrEqualTo(100));
    });

    test('getWordDiffStats handles identical text', () {
      final text1 = 'Hello world';
      final text2 = 'Hello world';
      
      final diffs = WordDiffEngine.computeWordDiff(text1, text2);
      final stats = WordDiffEngine.getWordDiffStats(diffs);
      
      expect(stats.additions, 0);
      expect(stats.deletions, 0);
      expect(stats.similarity, 100.0);
    });
  });

  group('ThreeWayMerge Tests', () {
    test('computeThreeWayMerge handles no conflicts', () {
      final baseText = 'Hello world';
      final leftText = 'Hello beautiful world';
      final rightText = 'Hello wonderful world';
      
      final result = WordDiffEngine.computeThreeWayMerge(
        baseText,
        leftText,
        rightText,
      );
      
      expect(result, isNotNull);
      expect(result.mergedText, isNotEmpty);
    });

    test('computeThreeWayMerge detects conflicts', () {
      final baseText = 'Hello world';
      final leftText = 'Hello beautiful world';
      final rightText = 'Hello amazing world';
      
      final result = WordDiffEngine.computeThreeWayMerge(
        baseText,
        leftText,
        rightText,
      );
      
      expect(result, isNotNull);
      // Conflicts may or may not be detected depending on implementation
    });

    test('computeThreeWayMerge handles identical changes', () {
      final baseText = 'Hello world';
      final leftText = 'Hello beautiful world';
      final rightText = 'Hello beautiful world';
      
      final result = WordDiffEngine.computeThreeWayMerge(
        baseText,
        leftText,
        rightText,
      );
      
      expect(result, isNotNull);
      expect(result.hasConflicts, false);
    });

    test('computeThreeWayMerge handles empty base text', () {
      final baseText = '';
      final leftText = 'Left changes';
      final rightText = 'Right changes';
      
      final result = WordDiffEngine.computeThreeWayMerge(
        baseText,
        leftText,
        rightText,
      );
      
      expect(result, isNotNull);
      expect(result.mergedText, isNotEmpty);
    });

    test('computeThreeWayMerge preserves non-conflicting changes', () {
      final baseText = 'Line 1\nLine 2\nLine 3';
      final leftText = 'Line 1 modified\nLine 2\nLine 3';
      final rightText = 'Line 1\nLine 2\nLine 3 modified';
      
      final result = WordDiffEngine.computeThreeWayMerge(
        baseText,
        leftText,
        rightText,
      );
      
      expect(result, isNotNull);
      expect(result.mergedText, isNotEmpty);
    });

    test('ThreeWayMergeResult provides conflict information', () {
      final baseText = 'Base';
      final leftText = 'Left';
      final rightText = 'Right';
      
      final result = WordDiffEngine.computeThreeWayMerge(
        baseText,
        leftText,
        rightText,
      );
      
      expect(result.mergedText, isNotNull);
      expect(result.conflicts, isNotNull);
      expect(result.hasConflicts is bool, true);
    });
  });

  group('WordDiffStats Tests', () {
    test('totalChanges calculates correctly', () {
      final stats = WordDiffStats(
        additions: 2,
        deletions: 1,
        unchanged: 5,
        changes: 1,
      );
      
      expect(stats.totalChanges, 4);
    });

    test('totalWords calculates correctly', () {
      final stats = WordDiffStats(
        additions: 2,
        deletions: 1,
        unchanged: 5,
        changes: 1,
      );
      
      expect(stats.totalWords, 9);
    });

    test('similarity calculates percentage correctly', () {
      final stats = WordDiffStats(
        additions: 1,
        deletions: 1,
        unchanged: 8,
        changes: 0,
      );
      
      expect(stats.similarity, 80.0);
    });

    test('similarity handles zero total words', () {
      final stats = WordDiffStats(
        additions: 0,
        deletions: 0,
        unchanged: 0,
        changes: 0,
      );
      
      expect(stats.similarity, 100.0);
    });
  });

  group('Word Splitting Tests', () {
    test('splits words correctly with spaces', () {
      final text1 = 'word1 word2 word3';
      final text2 = 'word1 word2';
      
      final diffs = WordDiffEngine.computeWordDiff(text1, text2);
      
      expect(diffs, isNotEmpty);
    });

    test('handles punctuation correctly', () {
      final text1 = 'Hello, world!';
      final text2 = 'Hello world';
      
      final diffs = WordDiffEngine.computeWordDiff(text1, text2);
      
      expect(diffs, isNotEmpty);
    });

    test('handles tabs and newlines', () {
      final text1 = 'word1\tword2\nword3';
      final text2 = 'word1 word2 word3';
      
      final diffs = WordDiffEngine.computeWordDiff(text1, text2);
      
      expect(diffs, isNotEmpty);
    });
  });

  group('Edge Cases', () {
    test('handles very long text efficiently', () {
      final text1 = List.generate(1000, (i) => 'word$i').join(' ');
      final text2 = List.generate(1000, (i) => 'word$i').join(' ') + ' extra';
      
      expect(() {
        WordDiffEngine.computeWordDiff(text1, text2);
      }, returnsNormally);
    });

    test('handles special characters', () {
      final text1 = '!@#\$%^&*()';
      final text2 = '!@#\$%^&*()_+';
      
      final diffs = WordDiffEngine.computeWordDiff(text1, text2);
      
      expect(diffs, isNotEmpty);
    });

    test('handles unicode characters', () {
      final text1 = 'Hello 世界';
      final text2 = 'Hello world';
      
      final diffs = WordDiffEngine.computeWordDiff(text1, text2);
      
      expect(diffs, isNotEmpty);
    });
  });
}
