# QR Maker

**Status**: ⚠️ v2.0 Logic Complete, UI Integration Pending  
**Type**: Client-side tool (Flutter)  
**Location**: `lib/tools/qr_maker/`

## Overview

QR Maker is a QR code generation tool with customization options. Version 2.0 adds batch generation capabilities for creating multiple QR codes from various data sources.

## Features

### v1.0 Features (Implemented)

- **Multiple QR types** - Support for 7 data formats:
  - Text - Plain text content
  - URL - Website links
  - Email - Mailto links
  - Phone - Tel links
  - SMS - SMS messages
  - WiFi - Network configuration
  - vCard - Contact information
- **Live preview** - Real-time QR generation
- **Customization**:
  - Size adjustment (100-500px)
  - Foreground color selection
  - Background color selection
- **Quick templates** - Pre-filled examples for each type
- **Download functionality** - Export QR codes
- **Copy to clipboard** - Quick data export
- **Animated interactions** - Bounce effects on generation

### v2.0 Features (Logic Complete)

#### Batch Generation

Multiple methods for generating QR codes in bulk:

##### 1. List-Based Generation

Generate QR codes from a simple list of data:

```dart
final result = QrBatchGenerator.generateBatch(
  ['Data 1', 'Data 2', 'Data 3'],
  type: 'url'
);
```

##### 2. CSV Import

Generate from CSV files with configurable options:

```dart
final result = QrBatchGenerator.generateFromCsv(
  csvContent,
  dataColumnIndex: 0,     // Which column contains QR data
  hasHeader: true,        // Skip first row
  type: 'text'
);
```

Features:
- Header row detection
- Column selection
- Quoted field handling
- Empty line skipping

##### 3. Sequential Generation

Create numbered sequences automatically:

```dart
final result = QrBatchGenerator.generateSequential(
  prefix: 'TICKET-',
  count: 100,
  startNumber: 1,
  suffix: '-2024',
  type: 'text'
);
```

Generates: TICKET-1-2024, TICKET-2-2024, ..., TICKET-100-2024

##### 4. Template-Based Generation

Use templates with variable substitution:

```dart
final result = QrBatchGenerator.generateFromTemplate(
  template: 'Hello {{name}}, your code is {{code}}',
  variables: {
    'name': ['Alice', 'Bob', 'Charlie'],
    'code': ['ABC', 'DEF', 'GHI']
  }
);
```

Generates personalized QR codes from template patterns.

#### Batch Features

- **Unique IDs** - Each QR code gets a unique identifier
- **Metadata** - Attach custom metadata to each code
- **Validation** - Input validation and error handling
- **Export** - JSON export of batch results
- **Statistics** - Type breakdown and analytics
- **Safety limits** - Maximum count restrictions (1000/batch)

## User Interface

### Current UI (v1.0)

- **Type selector** - Filter chips for QR types
- **Input panel** - Text field with templates
- **Preview area** - Live QR code display (simulated)
- **Customization panel** - Size and color controls
- **Actions** - Download, copy, clear buttons

### Planned UI (v2.0)

- **Batch generation tab** - Separate interface for bulk operations
- **CSV upload** - File picker integration
- **Template builder** - Visual template creation
- **Batch preview** - Grid view of generated codes
- **Export options** - ZIP download, JSON export

## Implementation Details

### Architecture

```
lib/tools/qr_maker/
├── qr_maker_screen.dart          # Main UI (v1.0 complete)
├── logic/
│   └── batch_generator.dart      # v2.0 batch logic (complete)
```

### Logic Components (v2.0)

#### QrBatchGenerator

Main batch generation class:

```dart
class QrBatchGenerator {
  // Generate from list
  static QrBatchResult generateBatch(List<String> dataList, {...})
  
  // Generate from CSV
  static QrBatchResult generateFromCsv(String csvContent, {...})
  
  // Generate sequential
  static QrBatchResult generateSequential({...})
  
  // Generate from template
  static QrBatchResult generateFromTemplate({...})
  
  // Export and statistics
  static String exportToJson(QrBatchResult result)
  static Map<String, dynamic> getBatchStats(QrBatchResult result)
}
```

#### QrBatchResult

Contains generation outcome:

```dart
class QrBatchResult {
  final bool success;
  final List<QrCodeData> qrCodes;
  final String? error;
  final int totalGenerated;
}
```

#### QrCodeData

Individual QR code representation:

```dart
class QrCodeData {
  final String id;              // Unique identifier
  final String data;            // QR content
  final String type;            // QR type
  final Map<String, dynamic>? metadata;  // Custom data
}
```

## Usage Examples

### Single QR Generation (v1.0)

```
Type: URL
Input: https://example.com
Size: 200px
Colors: Black on White

Result: QR code preview with download option
```

### Batch from List (v2.0 Logic)

```dart
final urls = [
  'https://example.com/page1',
  'https://example.com/page2',
  'https://example.com/page3'
];

final result = QrBatchGenerator.generateBatch(urls, type: 'url');

// Result contains 3 QR codes with unique IDs
```

### CSV Batch Generation (v2.0 Logic)

```csv
Name,Email,Phone
John Doe,john@example.com,555-0100
Jane Smith,jane@example.com,555-0101
```

```dart
final result = QrBatchGenerator.generateFromCsv(
  csvContent,
  dataColumnIndex: 1,  // Use email column
  type: 'email'
);

// Generates QR codes for each email
```

### Sequential Tickets (v2.0 Logic)

```dart
final result = QrBatchGenerator.generateSequential(
  prefix: 'EVENT-2024-',
  count: 50,
  startNumber: 1
);

// Generates: EVENT-2024-1, EVENT-2024-2, ..., EVENT-2024-50
```

### Template-Based (v2.0 Logic)

```dart
final result = QrBatchGenerator.generateFromTemplate(
  template: 'Name: {{name}}\nRole: {{role}}\nID: {{id}}',
  variables: {
    'name': ['Alice', 'Bob'],
    'role': ['Admin', 'User'],
    'id': ['A001', 'U002']
  }
);

// Generates personalized vCard-style QR codes
```

## Testing

Comprehensive test suite at `test/tools/qr_maker_test.dart`:

- Batch generation (40+ assertions)
- CSV parsing (25+ assertions)
- Sequential generation (20+ assertions)
- Template processing (25+ assertions)
- Export and statistics (20+ assertions)
- Edge cases (unicode, special chars, limits)

## Performance

- **Efficient processing** - Handles up to 1000 codes/batch
- **Memory management** - Streaming for large datasets
- **Validation** - Input sanitization and limits
- **Error handling** - Graceful degradation

## Safety Features

- **Maximum limits** - 1000 codes per batch
- **Input validation** - Empty/invalid data handling
- **Error recovery** - Partial success support
- **Rate limiting** - Prevents abuse

## Known Limitations

- v2.0 UI integration pending (logic complete)
- No actual QR image generation yet (preview only)
- Logo embedding not implemented
- No batch download as ZIP

## Future Enhancements

### Planned for v2.0 UI

- Batch generation interface
- CSV file upload
- Template builder UI
- Batch preview grid
- Export options

### Future Versions

- **Logo embedding** - Add custom logos to QR codes
- **Advanced styling** - Gradient colors, rounded corners
- **Batch download** - ZIP file with all QR codes
- **Database integration** - Save and manage QR batches
- **Analytics** - Track QR code scans
- **API integration** - Cloud QR generation service

## Integration Status

| Feature | Logic | UI | Tests | Status |
|---------|-------|----|----|--------|
| Single generation | ✅ | ✅ | ⚠️ | Complete |
| Batch list | ✅ | ❌ | ✅ | Logic complete |
| Batch CSV | ✅ | ❌ | ✅ | Logic complete |
| Batch sequential | ✅ | ❌ | ✅ | Logic complete |
| Batch template | ✅ | ❌ | ✅ | Logic complete |

## Export Format

Batch results can be exported as JSON:

```json
{
  "success": true,
  "totalGenerated": 3,
  "qrCodes": [
    {
      "id": "qr_1_1234567890",
      "data": "Hello World",
      "type": "text"
    },
    {
      "id": "qr_2_1234567891",
      "data": "https://example.com",
      "type": "url"
    }
  ]
}
```

## Related

- **Text Tools** - For data preparation
- **JSON Doctor** - For JSON QR data validation
- **File Merger** - For combining QR assets

## Support

- Report issues with the `tool:qr-maker` label
- See dev log: `docs/dev-log/features/t-toolspack-micro-tools.md`
- Roadmap: `docs/roadmap/phase-1.md`
