# JSON CSV Flattener

**Route**: `/tools/json-flatten`  
**Status**: ✅ Implemented  
**Theme**: Material 3 with UX-Play playful design

## Overview

The JSON CSV Flattener is a powerful tool for transforming nested JSON structures into flat, tabular CSV format. Perfect for data analysis, spreadsheet imports, and simplifying complex JSON data.

## Features

### Core Functionality
- **Paste JSON**: Input JSON arrays or objects directly
- **Flatten Nested Keys**: Automatically flatten deeply nested structures
- **Notation Options**:
  - **Dot Notation**: `user.address.city`
  - **Bracket Notation**: `user[address][city]`
- **Field Selector**: Choose which keys to include in the CSV output
- **Preview Table**: See flattened data before exporting
- **CSV Export**: Copy or download the generated CSV

### Smart Flattening
- **Deep Nesting**: Handles unlimited nesting depth (configurable)
- **Array Handling**: 
  - Arrays of objects → Multiple rows
  - Nested arrays → Indexed keys
  - Mixed-type arrays → Preserved
- **Edge Cases**:
  - Null values
  - Empty objects/arrays
  - Unicode characters
  - Large numbers

## UI Components

### Layout (3-Panel Design)

#### Left Panel: JSON Input
- Large text area for JSON input
- Monospace font for readability
- Notation style selector (Dot/Bracket)
- "Flatten to CSV" button
- Loading indicator during processing

#### Middle Panel: Field Selector
- Checkbox list of all available fields
- "Select All" and "Deselect All" buttons
- Count indicator (e.g., "5/10 selected")
- Scrollable for large field lists

#### Right Panel: CSV Preview
- Read-only monospace text area
- Shows generated CSV in real-time
- Updates as fields are selected/deselected

### Status Bar
When data is flattened, displays:
- Number of rows
- Number of columns
- Total cells
- Maximum nesting depth

### Actions
- **Import**: Load JSON from other tools or clipboard
- **Share**: Share CSV with other tools
- **Copy**: Copy CSV to clipboard
- **Download**: Download CSV file (web)
- **Clear All**: Reset the tool

## Usage Examples

### Example 1: Simple Array of Objects

**Input:**
```json
[
  {"name": "Alice", "age": 30, "city": "NYC"},
  {"name": "Bob", "age": 25, "city": "LA"}
]
```

**Output (CSV):**
```csv
name,age,city
Alice,30,NYC
Bob,25,LA
```

### Example 2: Nested Object

**Input:**
```json
{
  "user": {
    "name": "Alice",
    "address": {
      "city": "NYC",
      "zip": "10001"
    }
  }
}
```

**Output (Dot Notation):**
```csv
user.name,user.address.city,user.address.zip
Alice,NYC,10001
```

**Output (Bracket Notation):**
```csv
user[name],user[address][city],user[address][zip]
Alice,NYC,10001
```

### Example 3: Array with Nested Objects

**Input:**
```json
[
  {
    "name": "Alice",
    "address": {"city": "NYC", "zip": "10001"}
  },
  {
    "name": "Bob",
    "address": {"city": "LA", "zip": "90001"}
  }
]
```

**Output:**
```csv
name,address.city,address.zip
Alice,NYC,10001
Bob,LA,90001
```

### Example 4: Complex Nested Structure

**Input:**
```json
{
  "users": [
    {
      "name": "Alice",
      "contacts": [
        {"type": "email", "value": "alice@example.com"},
        {"type": "phone", "value": "555-0001"}
      ]
    }
  ]
}
```

**Output:**
```csv
users.0.name,users.0.contacts.0.type,users.0.contacts.0.value,users.0.contacts.1.type,users.0.contacts.1.value
Alice,email,alice@example.com,phone,555-0001
```

## States & Error Messages

### States
- **Empty**: Ready to accept JSON input
- **Flattening**: Processing indicator shown
- **Success**: Data flattened, statistics displayed
- **Error**: Validation error shown with details

### Error Messages
- "JSON string is empty" - No input provided
- "Invalid JSON: [details]" - Malformed JSON syntax
- "Flattening error: [details]" - Processing failure

### Success Feedback
- Green statistics bar with data metrics
- Smooth animation on successful flattening
- Real-time CSV preview updates

## Technical Details

### Implementation
- **Logic Module**: `lib/tools/json_flatten/logic/json_flattener.dart`
- **UI Screen**: `lib/tools/json_flatten/json_flatten_screen.dart`
- **Tests**: `test/tools/json_flatten/json_flattener_test.dart`

### Key Classes

#### JsonFlattener
Static utility class for all flattening operations.

**Methods:**
- `flatten(String jsonString, ...)` → `FlattenResult`
- `flattenParsed(dynamic data, ...)` → `FlattenResult`
- `toCSV(List<Map> rows, List<String> keys, ...)` → `String`
- `filterKeys(List<Map> rows, List<String> keys)` → `List<Map>`
- `getStatistics(FlattenResult result)` → `Map`
- `validateJson(String jsonString)` → `ValidationResult`

#### NotationStyle
Enum for key notation preferences:
- `dot`: user.address.city
- `bracket`: user[address][city]

#### FlattenResult
Result container with:
- `rows`: List of flattened objects
- `allKeys`: All unique keys found
- `success`: Operation status
- `error`: Error message if failed

### CSV Features
- **Header Row**: Optional (default: included)
- **Delimiter**: Configurable (default: comma)
- **Value Escaping**: 
  - Quotes fields with commas, newlines, or quotes
  - Doubles internal quotes per CSV standard
- **Null Handling**: Empty string in CSV
- **Missing Keys**: Empty string for missing values

## Testing

### Unit Tests
Comprehensive test coverage in `json_flattener_test.dart`:

- **Simple Objects**: Flat and nested structures
- **Arrays**: Objects, primitives, nested, empty
- **Complex Structures**: Multiple levels, mixed types
- **CSV Generation**: Headers, escaping, null handling
- **Statistics**: Row/column counts, depth calculation
- **Field Filtering**: Key selection, missing keys
- **Validation**: Valid/invalid JSON detection
- **Error Handling**: Empty, malformed, edge cases
- **Edge Cases**: Primitives, booleans, unicode, large numbers

### Widget Tests
Test interactive features:
- JSON input handling
- Notation style switching
- Field selection UI
- CSV preview updates
- Export actions

### Integration Tests
End-to-end scenarios:
- Complex JSON structures
- Large datasets
- Performance with deep nesting
- Field filtering workflows

## Performance Considerations

- **Max Depth**: Configurable limit (default: 100)
- **Large Arrays**: Efficient handling
- **Real-time Updates**: Debounced for UX
- **Memory**: Streaming for large datasets (future)

## Future Enhancements

- [ ] Custom separators (pipes, tabs, etc.)
- [ ] Column reordering
- [ ] Data type inference
- [ ] Export to other formats (Excel, JSON Lines)
- [ ] Unflatten CSV back to JSON
- [ ] Batch processing multiple files
- [ ] Advanced filtering (regex, conditions)
- [ ] Preset configurations
- [ ] History of recent conversions

## Accessibility

- Keyboard navigation
- Screen reader labels
- High contrast support
- Focus indicators
- ARIA attributes

## Related Tools

- **JSON Doctor**: Validate and format JSON before flattening
- **Text Tools**: Additional text manipulation utilities
- Works seamlessly with cross-tool data sharing

## Resources

- [CSV RFC 4180](https://tools.ietf.org/html/rfc4180)
- [JSON Specification](https://www.json.org/)
- [Material 3 Design](https://m3.material.io/)

---

**Last Updated**: 2025-01-06  
**Version**: 1.0.0
