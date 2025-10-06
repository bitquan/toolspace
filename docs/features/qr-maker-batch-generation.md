# QR Maker Batch Generation

## Overview

The QR Maker now supports batch generation of QR codes with logo embedding, allowing users to generate multiple QR codes in one operation from CSV or JSON input.

## Features

### Batch Input Formats

#### CSV Format
```csv
content,filename
https://example.com,example
https://github.com,github
Hello World,greeting
```

The CSV format supports:
- Simple two-column format: `content,filename`
- Optional header row (automatically detected)
- Quoted content for values with commas
- Empty lines are skipped

#### JSON Format

Array of objects:
```json
[
  {"content": "https://example.com", "filename": "example"},
  {"content": "https://github.com", "filename": "github"},
  {"content": "Hello World", "filename": "greeting"}
]
```

Array of strings:
```json
["https://example.com", "https://github.com", "Hello World"]
```

Single object:
```json
{"content": "https://example.com", "filename": "example"}
```

Wrapped format:
```json
{
  "items": [
    {"content": "https://example.com"},
    {"content": "https://github.com"}
  ]
}
```

### Validation

The batch generator validates all items before processing:

- **Empty content**: Content cannot be empty
- **Length limit**: Content must be under 4000 characters
- **Format validation**: Input must be valid CSV or JSON

Validation errors are displayed with detailed messages to help fix issues.

### Batch Processing

1. **Parse Input**: Input is automatically parsed based on selected format (CSV or JSON)
2. **Validate**: All items are validated for correctness
3. **Generate**: Valid items are processed to generate QR codes
4. **Results**: Statistics and results are displayed with success/error details

### Logo Embedding

QR codes can include logos in both single and batch modes:

- **Predefined Logos**: Select from Flutter, GitHub, Google, Apple, Twitter
- **Logo Size**: Adjust logo size from 10% to 40% of QR code
- **Custom Upload**: Upload custom logo images (coming soon)

Logo settings are applied to all QR codes in batch mode.

### Batch Export

- **Download All**: Download all generated QR codes as a ZIP archive
- **Naming**: QR codes are named based on the filename field in input
- **Format**: QR codes are exported in PNG format

## Usage Examples

### Example 1: URL Batch (CSV)

```csv
https://example.com,example
https://github.com/bitquan,github
https://flutter.dev,flutter
```

### Example 2: URL Batch (JSON)

```json
[
  {"content": "https://example.com", "filename": "example"},
  {"content": "https://github.com/bitquan", "filename": "github"},
  {"content": "https://flutter.dev", "filename": "flutter"}
]
```

## Mode Switching

### Single Mode
- Generate one QR code at a time
- Full customization per QR code
- Live preview with animations
- Immediate download

### Batch Mode
- Generate multiple QR codes at once
- Consistent settings across all QR codes
- Batch statistics and error reporting
- Download all as ZIP

Switch between modes using the toggle button in the app bar.

## Configuration

### Batch Config Options

- **QR Size**: 100-500px (applies to all QR codes in batch)
- **Foreground Color**: Color of QR code modules
- **Background Color**: Color of QR code background
- **Logo Path**: Selected logo identifier
- **Logo Size**: Size of embedded logo (10-40%)

## Testing

Run the batch generator tests:

```bash
flutter test test/tools/qr_maker_test.dart
```

Test coverage includes:
- CSV parsing with various formats
- JSON parsing with different structures
- Validation logic
- Batch generation
- Error handling
- Statistics calculation

## Related Files

- `lib/tools/qr_maker/logic/batch_generator.dart` - Core batch logic
- `lib/tools/qr_maker/widgets/batch_panel.dart` - Batch input UI
- `lib/tools/qr_maker/widgets/batch_results.dart` - Results display
- `lib/tools/qr_maker/widgets/logo_selector.dart` - Logo selection UI
- `test/tools/qr_maker_test.dart` - Comprehensive tests
