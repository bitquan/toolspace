# CSV Cleaner Documentation

**Route**: `/tools/csv-cleaner`  
**Status**: Active  

## Overview

CSV Cleaner is a tool for cleaning and normalizing CSV (Comma-Separated Values) files. It provides operations for trimming whitespace, normalizing headers, removing duplicate rows, and exporting cleaned data.

## Features

### 1. File Upload

- Upload CSV files using the file picker
- Supports standard CSV format with comma delimiters
- Handles quoted values and escaped quotes
- Validates CSV structure on upload
- Loading state during file parsing

### 2. Data Preview

- Interactive table preview of CSV data
- Shows all rows and columns
- Header row highlighted with distinct styling
- Horizontal and vertical scrolling for large datasets
- Displays file name and dimensions (rows × columns)

### 3. Cleaning Operations

#### Trim Whitespace
- Removes leading and trailing whitespace from all cells
- Keeps internal spaces intact
- Applies to all rows including headers

#### Lowercase Headers
- Converts all header names to lowercase
- Ensures consistency in column naming
- Only affects the first row

#### Remove Duplicates
- Removes duplicate rows from the dataset
- Two modes:
  - **By entire row**: Removes rows where all columns match
  - **By key column**: Removes rows with duplicate values in a specific column
- Interactive column selection via dropdown dialog
- Shows count of removed duplicates

### 4. Export

- Export cleaned CSV to clipboard
- Properly escapes special characters (commas, quotes, newlines)
- Maintains data integrity in exported format

## Usage

### Basic Workflow

1. Click "Upload CSV File" button
2. Select a CSV file from your computer
3. Review the data preview table
4. Apply desired cleaning operations:
   - Trim Whitespace
   - Lowercase Headers
   - Remove Duplicates (choose key column)
5. Click "Export CSV" to copy cleaned data to clipboard
6. Paste into your preferred application

### Keyboard Shortcuts

- None (file upload and operations require button clicks)

## States & Error Handling

### States

- **Empty State**: No file loaded, shows upload prompt
- **Loading State**: File parsing in progress, shows spinner
- **Data View**: CSV loaded successfully, shows table and operations
- **Success State**: Operation completed, shows green snackbar notification

### Error Messages

- **Invalid CSV format**: CSV structure is malformed
- **Inconsistent columns**: Not all rows have the same number of columns
- **Failed to load**: File reading error or unsupported format
- **Empty CSV**: File is empty or contains only whitespace

### Success Feedback

- "CSV file loaded successfully"
- "Whitespace trimmed from all cells"
- "Headers converted to lowercase"
- "Removed N duplicate row(s)"
- "CSV exported to clipboard"

## API Reference

### CsvProcessor

```dart
class CsvProcessor {
  // Parse CSV string into rows
  static List<List<String>> parseCsv(String csvContent)
  
  // Convert rows back to CSV string
  static String toCsv(List<List<String>> rows)
  
  // Trim whitespace from all cells
  static List<List<String>> trimWhitespace(List<List<String>> rows)
  
  // Lowercase headers (first row)
  static List<List<String>> lowercaseHeaders(List<List<String>> rows)
  
  // Remove duplicate rows
  static List<List<String>> removeDuplicates(
    List<List<String>> rows,
    {int? keyColumnIndex}
  )
  
  // Get column names from first row
  static List<String> getHeaders(List<List<String>> rows)
  
  // Apply all cleaning operations
  static List<List<String>> cleanAll(
    List<List<String>> rows,
    {bool trimWhitespace = true,
    bool lowercaseHeaders = true,
    int? dedupeKeyColumn}
  )
  
  // Validate CSV data structure
  static CsvValidationResult validate(List<List<String>> rows)
}

class CsvValidationResult {
  final bool isValid
  final String? error
  final int? rowNumber
}
```

## Examples

### Example 1: Clean Employee Data

**Input CSV:**
```
  NAME  ,  AGE  ,  DEPARTMENT  
  John  ,  30  ,  Engineering  
  Jane  ,  25  ,  Marketing  
  John  ,  30  ,  Engineering  
```

**After Trim Whitespace:**
```
NAME,AGE,DEPARTMENT
John,30,Engineering
Jane,25,Marketing
John,30,Engineering
```

**After Lowercase Headers:**
```
name,age,department
John,30,Engineering
Jane,25,Marketing
John,30,Engineering
```

**After Remove Duplicates (entire row):**
```
name,age,department
John,30,Engineering
Jane,25,Marketing
```

### Example 2: Deduplicate by Key Column

**Input CSV:**
```
Email,Name,Score
john@test.com,John Doe,85
jane@test.com,Jane Smith,92
john@test.com,John Different,90
```

**After Remove Duplicates (by Email column):**
```
Email,Name,Score
john@test.com,John Doe,85
jane@test.com,Jane Smith,92
```

### Example 3: Quoted Values

**Input CSV:**
```
Name,Address,Note
"John, Jr.","123 Main St, NYC","Said ""hello"""
```

**Parsed correctly:**
- Name: `John, Jr.`
- Address: `123 Main St, NYC`
- Note: `Said "hello"`

## Technical Details

### CSV Parsing

- Handles comma-delimited values
- Supports quoted fields (with quotes)
- Escapes quotes within fields (`""` becomes `"`)
- Skips empty lines
- Validates consistent column count across rows

### Performance

- Suitable for CSV files up to several thousand rows
- In-memory processing (no file streaming)
- Operations are applied synchronously
- UI remains responsive during operations

### Limitations

- Maximum file size depends on available memory
- Only supports comma as delimiter (not semicolon or tab)
- Does not support custom encoding (assumes UTF-8)
- No undo functionality (operations are immediate)

## Testing

### Unit Tests

```dart
// Test CSV parsing
test('parses simple CSV correctly', () {...})
test('handles quoted values with commas', () {...})
test('handles escaped quotes', () {...})

// Test cleaning operations
test('trims whitespace from all cells', () {...})
test('converts headers to lowercase', () {...})
test('removes duplicate rows', () {...})

// Test validation
test('validates correct CSV', () {...})
test('detects inconsistent column count', () {...})
```

### Widget Tests

```dart
// Test UI states
testWidgets('displays empty state initially', () {...})
testWidgets('shows upload button in empty state', () {...})
testWidgets('app bar displays correct title', () {...})
```

### Manual Testing Checklist

- [ ] Upload valid CSV file
- [ ] Upload invalid CSV file (should show error)
- [ ] Upload file with quoted values
- [ ] Trim whitespace operation
- [ ] Lowercase headers operation
- [ ] Remove duplicates (entire row)
- [ ] Remove duplicates (by key column)
- [ ] Export to clipboard
- [ ] Clear data and upload new file
- [ ] Handle large CSV files (1000+ rows)

## Future Enhancements

- Support for different delimiters (semicolon, tab)
- Column sorting and filtering
- Data type detection and validation
- Find and replace functionality
- Column reordering
- Export to different formats (JSON, Excel)
- Undo/redo functionality
- Save/load cleaning presets
- Batch processing multiple files
- Custom delimiter selection

## Related Tools

- **Text Tools**: For general text cleaning operations
- **JSON Doctor**: For working with JSON data
- **File Merger**: For combining multiple files

## Troubleshooting

### Issue: File won't upload
**Solution**: Ensure the file has a `.csv` extension and is a valid CSV format.

### Issue: Some rows are missing after deduplication
**Solution**: This is expected behavior. The tool removes rows with duplicate values based on your key column selection.

### Issue: Special characters appear incorrectly
**Solution**: Ensure your CSV file is UTF-8 encoded. The tool assumes UTF-8 encoding.

### Issue: Export doesn't work
**Solution**: The tool copies data to clipboard. After clicking "Export CSV", paste into your destination application.

## Support

For issues or feature requests, please create an issue on the GitHub repository.
