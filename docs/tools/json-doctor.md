# JSON Doctor

**Status**: ✅ v2.0 Complete  
**Type**: Client-side tool (Flutter)  
**Location**: `lib/tools/json_doctor/`

## Overview

JSON Doctor is a comprehensive JSON validation, formatting, and analysis tool that provides instant feedback on JSON data quality. Version 2.0 adds advanced schema validation and JSONPath query capabilities.

## Features

### v1.0 Features

- **Real-time JSON validation** - Instant feedback on JSON syntax
- **Auto-formatting** - Pretty-print JSON with configurable indentation
- **Smart error detection** - Identifies common JSON issues
- **Auto-repair** - Automatically fixes common problems:
  - Single quotes to double quotes
  - Python booleans (True/False → true/false)
  - Unquoted keys detection
  - Trailing comma removal
- **Copy to clipboard** - Quick data export

### v2.0 Features

#### Schema Validation

- **JSON Schema validation** - Validate data against JSON Schema specifications
- **Schema generation** - Auto-generate schemas from sample JSON data
- **Detailed error reporting** - Path-based error messages showing:
  - Type mismatches
  - Required property violations
  - Range constraints (min/max)
  - String length violations
  - Enum value validation
- **Complex nested structure support** - Handle deeply nested objects and arrays

#### JSONPath Queries

- **JSONPath query engine** - Extract specific data from JSON structures
- **Multiple query patterns**:
  - Property access: `$.name`
  - Nested properties: `$.user.address.city`
  - Array indexing: `$.users[0]`
  - Wildcard matching: `$.users[*].name`
- **Path exploration** - Get all available paths in a JSON object
- **Query validation** - Syntax validation for JSONPath expressions
- **Match counting** - Shows number of matches found

## User Interface

### Tabs

1. **Validate & Fix** - Main JSON validation and formatting
2. **Schema** - Schema validation and generation
3. **JSONPath** - Query and extract data from JSON

### Visual Feedback

- **Color-coded status** indicators (green/red/blue)
- **Animated success** feedback with pulse animations
- **Error highlighting** with descriptive messages
- **Statistics panel** showing validation results

## Usage Examples

### Basic Validation

```json
Input:
{"name": "test", "value": 123}

Output:
{
  "name": "test",
  "value": 123
}
```

### Auto-Repair

```json
Input:
{'name': 'test', 'active': True}

Auto-Fixed:
{
  "name": "test",
  "active": true
}
```

### Schema Validation

```json
Data:
{
  "user": {
    "name": "John",
    "age": 30,
    "email": "john@example.com"
  }
}

Schema:
{
  "type": "object",
  "required": ["user"],
  "properties": {
    "user": {
      "type": "object",
      "required": ["name", "email"],
      "properties": {
        "name": {"type": "string"},
        "age": {"type": "integer", "minimum": 0, "maximum": 150},
        "email": {"type": "string"}
      }
    }
  }
}

Result: ✅ Valid
```

### JSONPath Queries

```json
Data:
{
  "users": [
    {"name": "Alice", "role": "admin"},
    {"name": "Bob", "role": "user"},
    {"name": "Charlie", "role": "user"}
  ]
}

Query: $.users[*].name
Result: ["Alice", "Bob", "Charlie"]

Query: $.users[0].role
Result: "admin"
```

## Implementation Details

### Architecture

```
lib/tools/json_doctor/
├── json_doctor_screen.dart       # Main UI with tabs
├── logic/
│   ├── schema_validator.dart    # JSON Schema validation engine
│   └── jsonpath_query.dart      # JSONPath query processor
```

### Logic Components

#### SchemaValidator

- `validate()` - Validate JSON against schema
- `generateSchema()` - Create schema from sample data
- Supports JSON Schema draft features:
  - Type validation
  - Required properties
  - Nested objects and arrays
  - String length constraints
  - Number range constraints
  - Enum values

#### JsonPathQuery

- `query()` - Execute JSONPath queries
- `getAllPaths()` - List all paths in JSON
- `isValidPath()` - Validate JSONPath syntax
- Supports:
  - Root access (`$`)
  - Property access (`$.property`)
  - Array indexing (`$.array[0]`)
  - Wildcards (`$.array[*]`)
  - Nested paths (`$.user.address.city`)

### Performance

- **Debounced input** - Prevents excessive processing during typing
- **Efficient state management** - Minimal rebuilds
- **Animation optimization** - Hardware-accelerated transforms

## Testing

Comprehensive test suite available at `test/tools/json_doctor_test.dart`:

- JSONPath query functionality (80+ assertions)
- Schema validation (100+ assertions)
- Edge cases and error handling
- Complex nested structures
- Performance tests

## Future Enhancements

- Advanced JSONPath features (recursive descent, filters)
- JSON diff and merge capabilities
- Bulk processing
- Custom schema templates
- Export validation reports

## Related

- **Text Tools** - Complementary text processing utilities
- **File Merger** - For combining JSON files
- **QR Maker** - Generate QR codes from JSON data

## Support

- Report issues with the `tool:json-doctor` label
- See dev log: `docs/dev-log/features/t-toolspack-micro-tools.md`
