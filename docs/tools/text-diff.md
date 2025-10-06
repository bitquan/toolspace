# Text Diff

**Status**: ⚠️ v2.0 Logic Complete, UI Integration Pending  
**Type**: Client-side tool (Flutter)  
**Location**: `lib/tools/text_diff/`

## Overview

Text Diff is a text comparison tool that highlights differences between two text inputs. Version 2.0 adds word-level diffing and three-way merge capabilities for advanced text comparison and merging scenarios.

## Features

### v1.0 Features (Implemented)

- **Line-by-line comparison** - Simple text diff visualization
- **Visual highlighting** - Color-coded additions/deletions
- **Statistics panel** - Shows:
  - Number of additions (green)
  - Number of deletions (red)
  - Similarity percentage
- **Swap texts** - Quick reversal of comparison
- **Copy diff** - Export comparison results
- **Real-time comparison** - Auto-update with debouncing

### v2.0 Features (Logic Complete)

#### Word-Level Diffing

- **Granular comparison** - Word-by-word difference detection
- **Whitespace handling** - Preserves spacing information
- **Multiple diff types**:
  - Insert (new words)
  - Delete (removed words)
  - Equal (unchanged words)
  - Changed (modified words)
- **LCS algorithm** - Efficient longest common subsequence computation
- **Statistics**:
  - Word additions count
  - Word deletions count
  - Word changes count
  - Similarity percentage

#### Three-Way Merge

- **Base + two variants** - Compare three text versions
- **Conflict detection** - Identifies conflicting changes
- **Automatic merging** - Non-conflicting changes merged automatically
- **Conflict markers** - Clear visual indication:
  ```
  <<<<<<< LEFT
  Left version text
  =======
  Right version text
  >>>>>>> RIGHT
  ```
- **Conflict resolution** - Manual review of conflicts
- **Merge statistics** - Conflict count and locations

## User Interface

### Current UI (v1.0)

- **Two-panel layout** - Original and modified text side-by-side
- **Stats banner** - Real-time statistics
- **Action buttons** - Swap, clear, copy
- **Animated transitions** - Smooth fade effects

### Planned UI (v2.0)

- **Tab-based navigation**:
  - Line Diff (current)
  - Word Diff (new)
  - Three-Way Merge (new)
- **Enhanced visualization** - Word-level highlighting
- **Conflict resolution UI** - Interactive merge interface

## Implementation Details

### Architecture

```
lib/tools/text_diff/
├── text_diff_screen.dart         # Main UI (v1.0 complete, v2.0 pending)
├── logic/
│   └── word_diff_engine.dart     # v2.0 logic (complete)
```

### Logic Components (v2.0)

#### WordDiffEngine

Core class for word-level text comparison:

```dart
// Compute word-level differences
List<WordDiff> computeWordDiff(String text1, String text2)

// Three-way merge
ThreeWayMergeResult computeThreeWayMerge(
  String baseText,
  String leftText, 
  String rightText
)

// Get statistics
WordDiffStats getWordDiffStats(List<WordDiff> diffs)
```

#### WordDiff

Represents a single word difference:

```dart
class WordDiff {
  final String text;
  final WordDiffType type;  // insert, delete, equal, changed
  final int? originalIndex;
  final int? newIndex;
}
```

#### ThreeWayMergeResult

Contains merge outcome:

```dart
class ThreeWayMergeResult {
  final String mergedText;
  final List<MergeConflict> conflicts;
  final bool hasConflicts;
}
```

### Algorithm Details

- **Word splitting** - Intelligent tokenization preserving whitespace
- **LCS computation** - Dynamic programming approach
- **Diff generation** - Backtracking through LCS matrix
- **Conflict detection** - Comparing changes from both sides against base

## Usage Examples

### Basic Line Diff (v1.0)

```
Original:
Hello world
This is a test

Modified:
Hello universe
This is a test
Added line

Result:
- Hello world
+ Hello universe
  This is a test
+ Added line

Statistics:
Additions: 2
Deletions: 1
Similarity: 66.7%
```

### Word-Level Diff (v2.0 Logic)

```dart
final diffs = WordDiffEngine.computeWordDiff(
  'The quick brown fox',
  'The slow brown dog'
);

// Results in:
// [equal: "The ", delete: "quick", insert: "slow", 
//  equal: " brown ", delete: "fox", insert: "dog"]

final stats = WordDiffEngine.getWordDiffStats(diffs);
// additions: 2, deletions: 2, unchanged: 2
```

### Three-Way Merge (v2.0 Logic)

```dart
final result = WordDiffEngine.computeThreeWayMerge(
  baseText: 'Hello world',
  leftText: 'Hello beautiful world',
  rightText: 'Hello amazing world'
);

// Result may contain conflicts if both sides
// changed the same portion differently
```

## Testing

Comprehensive test suite available at `test/tools/text_diff_test.dart`:

- Word diff computation (50+ assertions)
- Three-way merge scenarios (30+ assertions)
- Edge cases (unicode, special chars, long texts)
- Statistics calculation
- Performance tests

## Performance

- **Efficient algorithms** - O(n*m) LCS with optimizations
- **Debounced input** - 500ms delay prevents excessive processing
- **Large text handling** - Tested with 1000+ words
- **Memory efficient** - Minimal state management

## Known Limitations

- v2.0 UI integration pending (logic complete)
- No recursive descent support yet
- Merge conflict resolution is manual
- No syntax-aware diffing (treats as plain text)

## Future Enhancements

### Planned for v2.0 UI

- Tab-based interface for diff modes
- Word-level highlighting visualization
- Interactive conflict resolution
- Side-by-side word diff view

### Future Versions

- Syntax-aware diffing (JSON, XML, code)
- Patch generation and application
- File comparison support
- Diff export formats (unified diff, patch files)
- Custom diff algorithms

## Integration Status

| Feature | Logic | UI | Tests | Status |
|---------|-------|----|----|--------|
| Line diff | ✅ | ✅ | ✅ | Complete |
| Word diff | ✅ | ⚠️ | ✅ | Logic complete |
| Three-way merge | ✅ | ⚠️ | ✅ | Logic complete |

## Related

- **JSON Doctor** - For JSON-specific comparison
- **Text Tools** - Complementary text utilities
- **File Merger** - For combining files

## Support

- Report issues with the `tool:text-diff` label
- See dev log: `docs/dev-log/features/t-toolspack-micro-tools.md`
- Roadmap: `docs/roadmap/phase-1.md`
