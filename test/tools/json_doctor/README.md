# JSON Doctor Tests

This directory contains comprehensive test suites for the JSON Doctor tool's core logic components.

## Test Coverage

### Schema Validator Tests (`schema_validator_test.dart`)

Tests for JSON Schema validation functionality:

- **Type Validation**: Validates all JSON types (string, integer, boolean, array, object, null, number)
- **Required Properties**: Ensures required object properties are present
- **Property Validation**: Validates nested object properties and detects type mismatches
- **Array Items**: Validates array elements against schemas, including arrays of objects
- **String Constraints**: Tests minLength and maxLength validations
- **Number Constraints**: Tests minimum and maximum value validations
- **Enum Validation**: Validates enum values for different data types
- **Schema Generation**: Tests automatic schema generation from JSON data
- **Complex Scenarios**: Tests nested structures and multiple simultaneous errors

### JSONPath Query Tests (`jsonpath_query_test.dart`)

Tests for JSONPath query execution:

- **Basic Queries**: Root element, simple properties, nested properties
- **Array Queries**: Element access by index, property access from array elements
- **Wildcard Queries**: All properties (`$.*`), all array elements (`$[*]`), wildcard in paths
- **Complex Scenarios**: Mixed array indices and properties, multiple wildcards
- **Edge Cases**: Empty objects/arrays, null values, special characters, top-level arrays
- **Utility Functions**: `getAllPaths`, `isValidPath`, `getExamplePaths`
- **Error Handling**: Malformed paths, queries on non-object data

## Running Tests

```bash
# Run all JSON Doctor tests
flutter test test/tools/json_doctor/

# Run specific test file
flutter test test/tools/json_doctor/schema_validator_test.dart
flutter test test/tools/json_doctor/jsonpath_query_test.dart

# Run with coverage
flutter test --coverage test/tools/json_doctor/
```

## Test Structure

Each test file follows these conventions:

- Tests are organized into logical groups using `group()`
- Each test has a descriptive name explaining what it validates
- Tests verify both positive (valid) and negative (invalid) scenarios
- Edge cases and error conditions are thoroughly tested
- Complex scenarios test real-world usage patterns

## Integration with CI

These tests are automatically run as part of the CI pipeline when changes are pushed to the repository. The CI system:

1. Formats code with `dart format`
2. Runs static analysis with `flutter analyze`
3. Executes all tests with `flutter test`
4. Generates coverage reports

## Adding New Tests

When adding new functionality to JSON Doctor:

1. Add corresponding tests to the appropriate test file
2. Ensure tests cover both success and failure cases
3. Test edge cases and boundary conditions
4. Run tests locally before committing
5. Update this README if new test categories are added

## Related Files

- `lib/tools/json_doctor/logic/schema_validator.dart` - Schema validation implementation
- `lib/tools/json_doctor/logic/jsonpath_query.dart` - JSONPath query implementation
- `lib/tools/json_doctor/json_doctor_screen.dart` - UI implementation
