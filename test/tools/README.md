# Tool Tests

This directory contains unit tests for all Toolspace micro-tools.

## Test Coverage

### T-ToolsPack v2 Tests (New)

#### json_doctor_test.dart
Tests for JSON Doctor v2.0 features:
- **JSONPath Query Tests** (11 tests)
  - Root access (`$`)
  - Property access (`$.name`)
  - Nested properties (`$.user.name`)
  - Array indexing (`$.users[0]`)
  - Wildcard matching (`$.users[*].name`)
  - Path validation
  - Path exploration

- **Schema Validator Tests** (11 tests)
  - Type validation
  - Required properties
  - Object property validation
  - Array item validation
  - String length constraints
  - Number range constraints
  - Enum validation
  - Schema generation
  - Complex nested structures

**Total**: ~80+ assertions

#### text_diff_test.dart
Tests for Text Diff v2.0 word-level comparison:
- **WordDiffEngine Tests** (8 tests)
  - Insertion detection
  - Deletion detection
  - Equal word detection
  - Empty string handling
  - Whitespace handling
  - Multiline text support
  - Statistics calculation

- **Three-Way Merge Tests** (6 tests)
  - No conflicts scenario
  - Conflict detection
  - Identical changes
  - Empty base text
  - Non-conflicting change preservation
  - Conflict information

- **WordDiffStats Tests** (4 tests)
  - Total changes calculation
  - Total words calculation
  - Similarity percentage
  - Zero words edge case

- **Edge Cases** (3 tests)
  - Large text performance
  - Special characters
  - Unicode support

**Total**: ~100+ assertions

#### qr_maker_test.dart
Tests for QR Maker v2.0 batch generation:
- **Batch Generation Tests** (5 tests)
  - List-based generation
  - Empty list handling
  - Empty string filtering
  - Metadata inclusion
  - Type specification

- **CSV Generation Tests** (5 tests)
  - Simple CSV parsing
  - Column selection
  - Header/no-header modes
  - Empty line handling
  - Quoted field parsing

- **Sequential Generation Tests** (5 tests)
  - Numbered sequences
  - Start number configuration
  - Suffix inclusion
  - Zero count rejection
  - Maximum count limit

- **Template Generation Tests** (4 tests)
  - Variable replacement
  - Single/multiple variables
  - Empty template rejection
  - Missing variable detection

- **Export and Stats Tests** (6 tests)
  - JSON export
  - Error handling in export
  - Special character escaping
  - Statistics generation
  - Error statistics
  - Type breakdown

- **QrCodeData Tests** (2 tests)
  - JSON serialization
  - Null metadata handling

- **Edge Cases** (3 tests)
  - Very long strings
  - Special characters
  - Unicode support

**Total**: ~130+ assertions

### Existing Tests

#### text_tools_test.dart
Tests for Text Tools utilities:
- Case conversion (8 tests)
- Text cleaning (5 tests)
- JSON tools (5 tests)
- Slugify (6 tests)
- Text counters (4 tests)
- UUID generation (6 tests)

#### file_merger_test.dart
Tests for File Merger upload manager:
- FileUpload creation
- Property validation

#### file_merger_widget_test.dart
Widget tests for File Merger screen:
- UI component smoke tests

## Running Tests

### All Tests
```bash
flutter test
```

### Specific Tool
```bash
flutter test test/tools/json_doctor_test.dart
flutter test test/tools/text_diff_test.dart
flutter test test/tools/qr_maker_test.dart
```

### With Coverage
```bash
flutter test --coverage
```

## Test Structure

Each test file follows this structure:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:toolspace/tools/{tool}/logic/{feature}.dart';

void main() {
  group('Feature Tests', () {
    test('specific behavior', () {
      // Arrange
      // Act
      // Assert
    });
  });
}
```

## Coverage Goals

- **Unit Tests**: All logic classes should have >90% coverage
- **Integration Tests**: Major user flows should be covered
- **Edge Cases**: Unicode, special characters, empty inputs, limits

## CI/CD Integration

Tests are automatically run by:
- Branch CI (`branch-ci.yml`) on every push
- PR merge validation
- Pre-deployment checks

## Adding New Tests

1. Create `{tool_name}_test.dart` in `test/tools/`
2. Import test framework and logic files
3. Group related tests with `group()`
4. Use descriptive test names
5. Follow Arrange-Act-Assert pattern
6. Test edge cases and error conditions

## Test Conventions

- Use `expect()` for assertions
- Test both success and failure paths
- Verify error messages are meaningful
- Check boundary conditions
- Test with realistic data
- Include performance tests for complex algorithms

## Known Issues

- Network-dependent tests should be mocked
- Firebase tests require emulator setup
- Widget tests need material app wrapper

## Related Documentation

- [Testing Policy](../../docs/policies/testing.md)
- [Tool Documentation](../../docs/tools/)
- [Development Workflow](../../docs/autonomous-workflow.md)
