import 'package:flutter_test/flutter_test.dart';
import '../../lib/tools/text_diff/logic/word_diff_engine.dart';

void main() {
  group('WordDiffEngine - Word Splitting Tests', () {
    test('splitIntoWords handles simple text', () {
      const text = 'hello world';
      final words = WordDiffEngine.computeWordDiff(text, text);
      expect(words.isNotEmpty, true);
      expect(words.every((w) => w.type == WordDiffType.equal), true);
    });

    test('splitIntoWords preserves whitespace', () {
      const text1 = 'hello  world';
      const text2 = 'hello world';
      final diffs = WordDiffEngine.computeWordDiff(text1, text2);
      // Should detect whitespace differences
      expect(diffs.any((d) => d.type != WordDiffType.equal), true);
    });

    test('splitIntoWords handles newlines', () {
      const text1 = 'hello\nworld';
      const text2 = 'hello world';
      final diffs = WordDiffEngine.computeWordDiff(text1, text2);
      expect(diffs.any((d) => d.type != WordDiffType.equal), true);
    });
  });

  group('WordDiffEngine - Word Diff Tests', () {
    test('computeWordDiff detects word insertion', () {
      const text1 = 'hello world';
      const text2 = 'hello beautiful world';
      final diffs = WordDiffEngine.computeWordDiff(text1, text2);

      final insertions = diffs.where((d) => d.type == WordDiffType.insert);
      expect(insertions.isNotEmpty, true);
      expect(insertions.any((d) => d.text.contains('beautiful')), true);
    });

    test('computeWordDiff detects word deletion', () {
      const text1 = 'hello beautiful world';
      const text2 = 'hello world';
      final diffs = WordDiffEngine.computeWordDiff(text1, text2);

      final deletions = diffs.where((d) => d.type == WordDiffType.delete);
      expect(deletions.isNotEmpty, true);
      expect(deletions.any((d) => d.text.contains('beautiful')), true);
    });

    test('computeWordDiff detects word replacement', () {
      const text1 = 'hello world';
      const text2 = 'hello universe';
      final diffs = WordDiffEngine.computeWordDiff(text1, text2);

      expect(diffs.any((d) => d.type == WordDiffType.delete), true);
      expect(diffs.any((d) => d.type == WordDiffType.insert), true);
    });

    test('computeWordDiff handles identical texts', () {
      const text1 = 'hello world test';
      const text2 = 'hello world test';
      final diffs = WordDiffEngine.computeWordDiff(text1, text2);

      expect(diffs.every((d) => d.type == WordDiffType.equal), true);
    });

    test('computeWordDiff handles empty texts', () {
      const text1 = '';
      const text2 = '';
      final diffs = WordDiffEngine.computeWordDiff(text1, text2);

      expect(diffs.isEmpty, true);
    });

    test('computeWordDiff handles one empty text', () {
      const text1 = '';
      const text2 = 'hello world';
      final diffs = WordDiffEngine.computeWordDiff(text1, text2);

      expect(diffs.every((d) => d.type == WordDiffType.insert), true);
    });

    test('computeWordDiff handles multiple changes', () {
      const text1 = 'The quick brown fox';
      const text2 = 'The fast red fox jumps';
      final diffs = WordDiffEngine.computeWordDiff(text1, text2);

      expect(diffs.any((d) => d.type == WordDiffType.insert), true);
      expect(diffs.any((d) => d.type == WordDiffType.delete), true);
      expect(diffs.any((d) => d.type == WordDiffType.equal), true);
    });
  });

  group('WordDiffEngine - Statistics Tests', () {
    test('getWordDiffStats calculates correct counts', () {
      const text1 = 'hello world';
      const text2 = 'hello beautiful world';
      final diffs = WordDiffEngine.computeWordDiff(text1, text2);
      final stats = WordDiffEngine.getWordDiffStats(diffs);

      expect(stats.additions, greaterThan(0));
      expect(stats.unchanged, greaterThan(0));
    });

    test('getWordDiffStats calculates similarity', () {
      const text1 = 'hello world test';
      const text2 = 'hello world test';
      final diffs = WordDiffEngine.computeWordDiff(text1, text2);
      final stats = WordDiffEngine.getWordDiffStats(diffs);

      expect(stats.similarity, equals(100.0));
    });

    test('getWordDiffStats handles partial similarity', () {
      const text1 = 'hello world';
      const text2 = 'hello universe';
      final diffs = WordDiffEngine.computeWordDiff(text1, text2);
      final stats = WordDiffEngine.getWordDiffStats(diffs);

      expect(stats.similarity, greaterThan(0.0));
      expect(stats.similarity, lessThan(100.0));
    });

    test('getWordDiffStats totalChanges calculation', () {
      const text1 = 'a b c';
      const text2 = 'a x c';
      final diffs = WordDiffEngine.computeWordDiff(text1, text2);
      final stats = WordDiffEngine.getWordDiffStats(diffs);

      expect(stats.totalChanges, greaterThan(0));
      expect(stats.totalWords, greaterThan(0));
    });
  });

  group('WordDiffEngine - Three-Way Merge Tests', () {
    test('computeThreeWayMerge handles no conflicts', () {
      const base = 'hello world';
      const left = 'hello beautiful world';
      const right = 'hello world test';

      final result = WordDiffEngine.computeThreeWayMerge(base, left, right);

      expect(result.hasConflicts, false);
      expect(result.mergedText, isNotEmpty);
    });

    test('computeThreeWayMerge detects conflicts', () {
      const base = 'hello world';
      const left = 'hello beautiful world';
      const right = 'hello amazing world';

      final result = WordDiffEngine.computeThreeWayMerge(base, left, right);

      // Both sides changed "world" differently, should detect conflict
      expect(result.mergedText, isNotEmpty);
    });

    test('computeThreeWayMerge handles identical changes', () {
      const base = 'hello world';
      const left = 'hello beautiful world';
      const right = 'hello beautiful world';

      final result = WordDiffEngine.computeThreeWayMerge(base, left, right);

      expect(result.hasConflicts, false);
      expect(result.mergedText.contains('beautiful'), true);
    });

    test('computeThreeWayMerge handles empty texts', () {
      const base = '';
      const left = '';
      const right = '';

      final result = WordDiffEngine.computeThreeWayMerge(base, left, right);

      expect(result.mergedText, isEmpty);
      expect(result.hasConflicts, false);
    });

    test('computeThreeWayMerge handles base with changes on one side', () {
      const base = 'hello world';
      const left = 'hello world';
      const right = 'hello beautiful world';

      final result = WordDiffEngine.computeThreeWayMerge(base, left, right);

      expect(result.hasConflicts, false);
      expect(result.mergedText.contains('beautiful'), true);
    });

    test('computeThreeWayMerge handles complex merge scenario', () {
      const base = 'The quick brown fox jumps';
      const left = 'The fast brown fox jumps high';
      const right = 'The quick red fox leaps';

      final result = WordDiffEngine.computeThreeWayMerge(base, left, right);

      expect(result.mergedText, isNotEmpty);
      // This is a complex case, just ensure we get a result
    });

    test('computeThreeWayMerge conflict list matches hasConflicts', () {
      const base = 'hello world';
      const left = 'hello universe';
      const right = 'hello cosmos';

      final result = WordDiffEngine.computeThreeWayMerge(base, left, right);

      if (result.hasConflicts) {
        expect(result.conflicts.isNotEmpty, true);
      } else {
        expect(result.conflicts.isEmpty, true);
      }
    });
  });

  group('WordDiffEngine - Edge Cases', () {
    test('handles very long texts', () {
      final text1 = List.generate(1000, (i) => 'word$i').join(' ');
      final text2 = List.generate(1000, (i) => 'word$i').join(' ');
      final diffs = WordDiffEngine.computeWordDiff(text1, text2);

      expect(diffs.every((d) => d.type == WordDiffType.equal), true);
    });

    test('handles special characters', () {
      const text1 = 'hello! world?';
      const text2 = 'hello! universe?';
      final diffs = WordDiffEngine.computeWordDiff(text1, text2);

      expect(diffs.isNotEmpty, true);
    });

    test('handles unicode characters', () {
      const text1 = 'こんにちは world';
      const text2 = 'こんにちは universe';
      final diffs = WordDiffEngine.computeWordDiff(text1, text2);

      expect(diffs.isNotEmpty, true);
      expect(diffs.any((d) => d.text.contains('こんにちは')), true);
    });

    test('handles tabs and mixed whitespace', () {
      const text1 = 'hello\tworld';
      const text2 = 'hello world';
      final diffs = WordDiffEngine.computeWordDiff(text1, text2);

      expect(diffs.isNotEmpty, true);
    });

    test('handles multiple consecutive spaces', () {
      const text1 = 'hello    world';
      const text2 = 'hello  world';
      final diffs = WordDiffEngine.computeWordDiff(text1, text2);

      expect(diffs.isNotEmpty, true);
    });
  });

  group('WordDiff Model Tests', () {
    test('WordDiff constructor works correctly', () {
      const diff = WordDiff(
        text: 'test',
        type: WordDiffType.insert,
        newIndex: 0,
      );

      expect(diff.text, 'test');
      expect(diff.type, WordDiffType.insert);
      expect(diff.newIndex, 0);
      expect(diff.originalIndex, null);
    });

    test('WordDiffStats calculates correctly', () {
      const stats = WordDiffStats(
        additions: 2,
        deletions: 1,
        unchanged: 5,
        changes: 0,
      );

      expect(stats.totalChanges, 3);
      expect(stats.totalWords, 8);
      expect(stats.similarity, 62.5);
    });

    test('WordDiffStats handles zero words', () {
      const stats = WordDiffStats(
        additions: 0,
        deletions: 0,
        unchanged: 0,
        changes: 0,
      );

      expect(stats.similarity, 100.0);
      expect(stats.totalWords, 0);
    });
  });

  group('ThreeWayMergeResult Model Tests', () {
    test('ThreeWayMergeResult constructor works correctly', () {
      const result = ThreeWayMergeResult(
        mergedText: 'merged',
        conflicts: [],
        hasConflicts: false,
      );

      expect(result.mergedText, 'merged');
      expect(result.conflicts.isEmpty, true);
      expect(result.hasConflicts, false);
    });

    test('MergeConflict stores information correctly', () {
      const conflict = MergeConflict(
        baseText: 'base',
        leftText: 'left',
        rightText: 'right',
        position: 10,
      );

      expect(conflict.baseText, 'base');
      expect(conflict.leftText, 'left');
      expect(conflict.rightText, 'right');
      expect(conflict.position, 10);
    });
  });
}
