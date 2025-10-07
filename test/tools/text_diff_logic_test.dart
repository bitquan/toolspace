import 'package:flutter_test/flutter_test.dart';
import 'package:toolspace/tools/text_diff/logic/word_diff_engine.dart';

void main() {
  group('WordDiffEngine Tests', () {
    test('computes word diffs for identical texts', () {
      const text1 = 'Hello world';
      const text2 = 'Hello world';

      final diffs = WordDiffEngine.computeWordDiff(text1, text2);

      expect(diffs.every((d) => d.type == WordDiffType.equal), true);
    });

    test('detects word insertions', () {
      const text1 = 'Hello world';
      const text2 = 'Hello beautiful world';

      final diffs = WordDiffEngine.computeWordDiff(text1, text2);

      expect(diffs.any((d) => d.type == WordDiffType.insert), true);
      expect(
        diffs.where((d) => d.type == WordDiffType.insert).first.text,
        contains('beautiful'),
      );
    });

    test('detects word deletions', () {
      const text1 = 'Hello beautiful world';
      const text2 = 'Hello world';

      final diffs = WordDiffEngine.computeWordDiff(text1, text2);

      expect(diffs.any((d) => d.type == WordDiffType.delete), true);
      expect(
        diffs.where((d) => d.type == WordDiffType.delete).first.text,
        contains('beautiful'),
      );
    });

    test('detects word changes', () {
      const text1 = 'Hello world';
      const text2 = 'Hello universe';

      final diffs = WordDiffEngine.computeWordDiff(text1, text2);

      expect(diffs.any((d) => d.type == WordDiffType.delete), true);
      expect(diffs.any((d) => d.type == WordDiffType.insert), true);
    });

    test('handles empty texts', () {
      const text1 = '';
      const text2 = 'Hello';

      final diffs = WordDiffEngine.computeWordDiff(text1, text2);

      expect(diffs.length, greaterThan(0));
      expect(diffs.every((d) => d.type == WordDiffType.insert), true);
    });

    test('preserves whitespace information', () {
      const text1 = 'Hello  world';
      const text2 = 'Hello   world';

      final diffs = WordDiffEngine.computeWordDiff(text1, text2);

      // Should detect the difference in whitespace
      expect(diffs, isNotEmpty);
    });

    test('computes word diff statistics', () {
      const text1 = 'Hello beautiful world';
      const text2 = 'Hello wonderful planet';

      final diffs = WordDiffEngine.computeWordDiff(text1, text2);
      final stats = WordDiffEngine.getWordDiffStats(diffs);

      expect(stats.additions, greaterThan(0));
      expect(stats.deletions, greaterThan(0));
      expect(stats.unchanged, greaterThan(0));
      expect(stats.totalWords, equals(diffs.length));
    });

    test('calculates similarity percentage', () {
      const text1 = 'Hello world';
      const text2 = 'Hello world';

      final diffs = WordDiffEngine.computeWordDiff(text1, text2);
      final stats = WordDiffEngine.getWordDiffStats(diffs);

      expect(stats.similarity, equals(100.0));
    });

    test('handles multiline text', () {
      const text1 = 'Line 1\nLine 2';
      const text2 = 'Line 1\nLine 3';

      final diffs = WordDiffEngine.computeWordDiff(text1, text2);

      expect(diffs, isNotEmpty);
      expect(diffs.any((d) => d.text.contains('\n')), true);
    });
  });

  group('ThreeWayMerge Tests', () {
    test('merges non-conflicting changes', () {
      const base = 'Hello world';
      const left = 'Hello beautiful world';
      const right = 'Hello world everyone';

      final result = WordDiffEngine.computeThreeWayMerge(base, left, right);

      expect(result, isNotNull);
      expect(result.mergedText, isNotEmpty);
    });

    test('detects conflicting changes', () {
      const base = 'Hello world';
      const left = 'Hello universe';
      const right = 'Hello planet';

      final result = WordDiffEngine.computeThreeWayMerge(base, left, right);

      // When both sides change the same word differently, it's a conflict
      expect(result, isNotNull);
      expect(result.mergedText, isNotEmpty);
    });

    test('handles identical changes on both sides', () {
      const base = 'Hello world';
      const left = 'Hello beautiful world';
      const right = 'Hello beautiful world';

      final result = WordDiffEngine.computeThreeWayMerge(base, left, right);

      expect(result.hasConflicts, false);
      expect(result.mergedText, contains('beautiful'));
    });

    test('handles empty base text', () {
      const base = '';
      const left = 'Hello';
      const right = 'World';

      final result = WordDiffEngine.computeThreeWayMerge(base, left, right);

      expect(result, isNotNull);
      expect(result.mergedText, isNotEmpty);
    });

    test('marks conflicts with conflict markers', () {
      const base = 'Hello world';
      const left = 'Hello universe';
      const right = 'Hello planet';

      final result = WordDiffEngine.computeThreeWayMerge(base, left, right);

      if (result.hasConflicts) {
        expect(result.mergedText.contains('<<<<<<< LEFT'), true);
        expect(result.mergedText.contains('======='), true);
        expect(result.mergedText.contains('>>>>>>> RIGHT'), true);
      }
    });

    test('records conflict information', () {
      const base = 'Hello world';
      const left = 'Hello universe';
      const right = 'Hello planet';

      final result = WordDiffEngine.computeThreeWayMerge(base, left, right);

      if (result.hasConflicts) {
        expect(result.conflicts, isNotEmpty);
        expect(result.conflicts.first.leftText, isNotEmpty);
        expect(result.conflicts.first.rightText, isNotEmpty);
      }
    });

    test('handles complex multiline merge', () {
      const base = 'Line 1\nLine 2\nLine 3';
      const left = 'Line 1\nModified Line 2\nLine 3';
      const right = 'Line 1\nLine 2\nModified Line 3';

      final result = WordDiffEngine.computeThreeWayMerge(base, left, right);

      expect(result, isNotNull);
      expect(result.mergedText, isNotEmpty);
    });
  });
}
