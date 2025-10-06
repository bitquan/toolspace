/// Word-level difference result
class WordDiff {
  final String text;
  final WordDiffType type;
  final int? originalIndex;
  final int? newIndex;

  const WordDiff({
    required this.text,
    required this.type,
    this.originalIndex,
    this.newIndex,
  });
}

enum WordDiffType { insert, delete, equal, changed }

/// Word-level difference engine
class WordDiffEngine {
  /// Compute word-level differences between two texts
  static List<WordDiff> computeWordDiff(String text1, String text2) {
    final words1 = _splitIntoWords(text1);
    final words2 = _splitIntoWords(text2);

    final lcs = _longestCommonSubsequence(words1, words2);
    return _generateWordDiffs(words1, words2, lcs);
  }

  /// Split text into words preserving whitespace information
  static List<String> _splitIntoWords(String text) {
    final words = <String>[];
    final buffer = StringBuffer();
    bool inWord = false;

    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      final isWhitespace = _isWhitespace(char);

      if (isWhitespace != inWord) {
        if (buffer.isNotEmpty) {
          words.add(buffer.toString());
          buffer.clear();
        }
        inWord = !isWhitespace;
      }

      buffer.write(char);
    }

    if (buffer.isNotEmpty) {
      words.add(buffer.toString());
    }

    return words;
  }

  static bool _isWhitespace(String char) {
    return char == ' ' || char == '\t' || char == '\n' || char == '\r';
  }

  /// Compute longest common subsequence using dynamic programming
  static List<List<int>> _longestCommonSubsequence(
      List<String> words1, List<String> words2) {
    final m = words1.length;
    final n = words2.length;
    final dp = List.generate(m + 1, (_) => List.filled(n + 1, 0));

    for (int i = 1; i <= m; i++) {
      for (int j = 1; j <= n; j++) {
        if (words1[i - 1] == words2[j - 1]) {
          dp[i][j] = dp[i - 1][j - 1] + 1;
        } else {
          dp[i][j] =
              (dp[i - 1][j] > dp[i][j - 1]) ? dp[i - 1][j] : dp[i][j - 1];
        }
      }
    }

    return dp;
  }

  /// Generate word diffs using LCS result
  static List<WordDiff> _generateWordDiffs(
    List<String> words1,
    List<String> words2,
    List<List<int>> lcs,
  ) {
    final diffs = <WordDiff>[];
    int i = words1.length;
    int j = words2.length;

    while (i > 0 || j > 0) {
      if (i > 0 && j > 0 && words1[i - 1] == words2[j - 1]) {
        // Equal word
        diffs.insert(
            0,
            WordDiff(
              text: words1[i - 1],
              type: WordDiffType.equal,
              originalIndex: i - 1,
              newIndex: j - 1,
            ));
        i--;
        j--;
      } else if (j > 0 && (i == 0 || lcs[i][j - 1] >= lcs[i - 1][j])) {
        // Insertion
        diffs.insert(
            0,
            WordDiff(
              text: words2[j - 1],
              type: WordDiffType.insert,
              newIndex: j - 1,
            ));
        j--;
      } else if (i > 0 && (j == 0 || lcs[i][j - 1] < lcs[i - 1][j])) {
        // Deletion
        diffs.insert(
            0,
            WordDiff(
              text: words1[i - 1],
              type: WordDiffType.delete,
              originalIndex: i - 1,
            ));
        i--;
      }
    }

    return diffs;
  }

  /// Compute three-way merge showing conflicts
  static ThreeWayMergeResult computeThreeWayMerge(
    String baseText,
    String leftText,
    String rightText,
  ) {
    final baseWords = _splitIntoWords(baseText);
    final leftDiffs = computeWordDiff(baseText, leftText);
    final rightDiffs = computeWordDiff(baseText, rightText);

    return _mergeChanges(baseWords, leftDiffs, rightDiffs);
  }

  static ThreeWayMergeResult _mergeChanges(
    List<String> baseWords,
    List<WordDiff> leftDiffs,
    List<WordDiff> rightDiffs,
  ) {
    final conflicts = <MergeConflict>[];
    final mergedText = StringBuffer();
    bool hasConflicts = false;

    // Simple conflict detection - if both sides changed the same word
    int leftIndex = 0;
    int rightIndex = 0;

    while (leftIndex < leftDiffs.length && rightIndex < rightDiffs.length) {
      final leftDiff = leftDiffs[leftIndex];
      final rightDiff = rightDiffs[rightIndex];

      if (leftDiff.type == WordDiffType.equal &&
          rightDiff.type == WordDiffType.equal) {
        // Both unchanged
        if (leftDiff.text == rightDiff.text) {
          mergedText.write(leftDiff.text);
          leftIndex++;
          rightIndex++;
        } else {
          // Conflict: both changed differently
          conflicts.add(MergeConflict(
            baseText: '',
            leftText: leftDiff.text,
            rightText: rightDiff.text,
            position: mergedText.length,
          ));
          mergedText.write(
              '<<<<<<< LEFT\n${leftDiff.text}\n=======\n${rightDiff.text}\n>>>>>>> RIGHT\n');
          hasConflicts = true;
          leftIndex++;
          rightIndex++;
        }
      } else if (leftDiff.type == WordDiffType.equal) {
        // Only right side changed
        mergedText.write(rightDiff.text);
        rightIndex++;
      } else if (rightDiff.type == WordDiffType.equal) {
        // Only left side changed
        mergedText.write(leftDiff.text);
        leftIndex++;
      } else {
        // Both sides changed - potential conflict
        if (leftDiff.text == rightDiff.text) {
          // Same change on both sides
          mergedText.write(leftDiff.text);
        } else {
          // Different changes - conflict
          conflicts.add(MergeConflict(
            baseText: '',
            leftText: leftDiff.text,
            rightText: rightDiff.text,
            position: mergedText.length,
          ));
          mergedText.write(
              '<<<<<<< LEFT\n${leftDiff.text}\n=======\n${rightDiff.text}\n>>>>>>> RIGHT\n');
          hasConflicts = true;
        }
        leftIndex++;
        rightIndex++;
      }
    }

    // Handle remaining diffs
    while (leftIndex < leftDiffs.length) {
      mergedText.write(leftDiffs[leftIndex].text);
      leftIndex++;
    }
    while (rightIndex < rightDiffs.length) {
      mergedText.write(rightDiffs[rightIndex].text);
      rightIndex++;
    }

    return ThreeWayMergeResult(
      mergedText: mergedText.toString(),
      conflicts: conflicts,
      hasConflicts: hasConflicts,
    );
  }

  /// Get statistics about word-level differences
  static WordDiffStats getWordDiffStats(List<WordDiff> diffs) {
    int additions = 0;
    int deletions = 0;
    int unchanged = 0;
    int changes = 0;

    for (final diff in diffs) {
      switch (diff.type) {
        case WordDiffType.insert:
          additions++;
          break;
        case WordDiffType.delete:
          deletions++;
          break;
        case WordDiffType.equal:
          unchanged++;
          break;
        case WordDiffType.changed:
          changes++;
          break;
      }
    }

    return WordDiffStats(
      additions: additions,
      deletions: deletions,
      unchanged: unchanged,
      changes: changes,
    );
  }
}

/// Three-way merge result
class ThreeWayMergeResult {
  final String mergedText;
  final List<MergeConflict> conflicts;
  final bool hasConflicts;

  const ThreeWayMergeResult({
    required this.mergedText,
    required this.conflicts,
    required this.hasConflicts,
  });
}

/// Merge conflict information
class MergeConflict {
  final String baseText;
  final String leftText;
  final String rightText;
  final int position;

  const MergeConflict({
    required this.baseText,
    required this.leftText,
    required this.rightText,
    required this.position,
  });
}

/// Statistics for word-level differences
class WordDiffStats {
  final int additions;
  final int deletions;
  final int unchanged;
  final int changes;

  const WordDiffStats({
    required this.additions,
    required this.deletions,
    required this.unchanged,
    required this.changes,
  });

  int get totalChanges => additions + deletions + changes;
  int get totalWords => additions + deletions + unchanged + changes;

  double get similarity {
    if (totalWords == 0) return 100.0;
    return (unchanged / totalWords) * 100;
  }
}
