# Text Diff Logic

Word-level text comparison engine with three-way merge support.

## Overview

The `word_diff_engine.dart` module provides sophisticated text comparison algorithms that operate at the word level, preserving whitespace and providing detailed diff information.

## Features

### Word-Level Diffing

- **Whitespace Preservation**: Maintains exact whitespace (spaces, tabs, newlines) in diff results
- **Word Tokenization**: Splits text into words and whitespace segments
- **LCS Algorithm**: Uses Longest Common Subsequence for accurate diff computation
- **Change Detection**: Identifies insertions, deletions, and unchanged segments

### Three-Way Merge

- **Conflict Detection**: Identifies conflicting changes between left and right versions
- **Automatic Merging**: Merges non-conflicting changes automatically
- **Git-Style Markers**: Uses familiar conflict markers for manual resolution
- **Base Comparison**: Compares against a common base version

### Statistics

- **Word Counts**: Additions, deletions, unchanged words
- **Similarity Score**: Percentage-based similarity metric
- **Total Changes**: Aggregated change statistics

## Usage

### Basic Word Diff

```dart
import 'package:toolspace/tools/text_diff/logic/word_diff_engine.dart';

final text1 = "The quick brown fox";
final text2 = "The fast red fox";

final diffs = WordDiffEngine.computeWordDiff(text1, text2);

for (final diff in diffs) {
  switch (diff.type) {
    case WordDiffType.insert:
      print('+ ${diff.text}');
      break;
    case WordDiffType.delete:
      print('- ${diff.text}');
      break;
    case WordDiffType.equal:
      print('  ${diff.text}');
      break;
    case WordDiffType.changed:
      print('~ ${diff.text}');
      break;
  }
}
```

### Three-Way Merge

```dart
final baseText = "Hello world";
final leftText = "Hello beautiful world";
final rightText = "Hello world!";

final result = WordDiffEngine.computeThreeWayMerge(
  baseText,
  leftText,
  rightText,
);

if (result.hasConflicts) {
  print('Merge has ${result.conflicts.length} conflict(s)');
  for (final conflict in result.conflicts) {
    print('Conflict at position ${conflict.position}');
    print('Left:  ${conflict.leftText}');
    print('Right: ${conflict.rightText}');
  }
}

print('Merged text: ${result.mergedText}');
```

### Statistics

```dart
final stats = WordDiffEngine.getWordDiffStats(diffs);

print('Additions: ${stats.additions}');
print('Deletions: ${stats.deletions}');
print('Unchanged: ${stats.unchanged}');
print('Similarity: ${stats.similarity.toStringAsFixed(1)}%');
```

## Models

### WordDiff

Represents a single word or whitespace segment with its diff type.

```dart
class WordDiff {
  final String text;
  final WordDiffType type;
  final int? originalIndex;
  final int? newIndex;
}

enum WordDiffType { insert, delete, equal, changed }
```

### WordDiffStats

Statistical information about word-level differences.

```dart
class WordDiffStats {
  final int additions;
  final int deletions;
  final int unchanged;
  final int changes;
  
  int get totalChanges => additions + deletions + changes;
  int get totalWords => additions + deletions + unchanged + changes;
  double get similarity => (unchanged / totalWords) * 100;
}
```

### ThreeWayMergeResult

Result of a three-way merge operation.

```dart
class ThreeWayMergeResult {
  final String mergedText;
  final List<MergeConflict> conflicts;
  final bool hasConflicts;
}
```

### MergeConflict

Information about a merge conflict.

```dart
class MergeConflict {
  final String baseText;
  final String leftText;
  final String rightText;
  final int position;
}
```

## Algorithm Details

### Word Splitting

The engine splits text into alternating sequences of:
- **Word tokens**: Consecutive non-whitespace characters
- **Whitespace tokens**: Consecutive whitespace characters (spaces, tabs, newlines)

This approach preserves exact formatting while enabling word-level comparison.

### LCS-Based Diffing

Uses dynamic programming to compute the Longest Common Subsequence (LCS) between word lists. This provides optimal diff results with O(m×n) time complexity where m and n are the word counts.

### Three-Way Merge Algorithm

1. Computes diffs between base→left and base→right
2. Identifies regions changed by only one side (auto-merge)
3. Detects regions changed by both sides (conflicts)
4. Generates merged text with conflict markers

## Testing

Comprehensive test suite in `test/tools/text_diff_test.dart` covers:
- Word splitting edge cases
- Diff computation accuracy
- Three-way merge scenarios
- Conflict detection
- Statistical calculations
- Unicode and special character handling

## Performance

- Efficient for typical text documents (< 10,000 words)
- Memory usage scales linearly with text size
- Optimized LCS implementation with O(m×n) space complexity
- Real-time performance for interactive editing

## Future Enhancements

- Character-level diffing for fine-grained comparison
- Smart merge strategies (prefer left/right/newer/older)
- Diff visualization with syntax highlighting
- Patch generation and application
- File format support (code, markdown, JSON)
