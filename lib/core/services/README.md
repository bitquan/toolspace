# Core Services

This directory contains shared services used across all tools in Toolspace.

## SharedDataService

A singleton service for cross-tool data sharing. Allows tools to seamlessly share data with each other without manual copy-paste operations.

### Quick Start

```dart
import 'package:toolspace/core/services/shared_data_service.dart';

// Share data
SharedDataService.instance.shareData(
  SharedData(
    type: SharedDataType.text,
    data: 'Hello from Tool A',
    label: 'Greeting',
    sourceTool: 'tool_a',
  ),
);

// Check if data is available
if (SharedDataService.instance.hasData) {
  final data = SharedDataService.instance.currentData;
  print('Available: ${data?.data}');
}

// Consume (use once and clear)
final consumed = SharedDataService.instance.consumeData();
```

### Integration with Widgets

Use the pre-built UI components:

```dart
import 'package:toolspace/core/ui/share_data_button.dart';
import 'package:toolspace/core/ui/import_data_button.dart';

// In your tool's UI
ShareDataButton(
  data: myTextData,
  type: SharedDataType.text,
  sourceTool: 'my_tool',
  label: 'Send to Other Tools',
)

ImportDataButton(
  acceptedTypes: [SharedDataType.text, SharedDataType.json],
  onImport: (data, type, source) {
    // Handle imported data
    setState(() {
      myController.text = data;
    });
  },
)
```

### Supported Data Types

- `SharedDataType.text` - Plain text
- `SharedDataType.json` - JSON formatted data
- `SharedDataType.url` - URL strings
- `SharedDataType.qrCode` - QR code data
- `SharedDataType.file` - File references

### Features

- **Singleton Pattern**: Single source of truth for shared data
- **Observer Pattern**: Widgets automatically update when data changes
- **History Tracking**: Maintains last 10 shared items
- **Type Safety**: Enum-based data types
- **Consume Pattern**: Use data once and automatically clear

### Testing

Run the unit tests:

```bash
flutter test test/core/services/shared_data_service_test.dart
```

### Documentation

Full documentation available at: [Cross-Tool Data Sharing](../../../docs/tools/cross-tool-data-sharing.md)

### Architecture

The service uses Flutter's `ChangeNotifier` to provide reactive updates:

1. Tool A shares data via `shareData()`
2. Service stores data and notifies listeners
3. Tool B's `ImportDataButton` detects available data
4. User imports data in Tool B
5. Service clears data via `consumeData()`

### Best Practices

1. Always use `consumeData()` when you want single-use behavior
2. Check data type compatibility before importing
3. Provide meaningful labels for better UX
4. Handle empty data states gracefully
5. Show user feedback when sharing/importing

### Example Workflow

```
Text Tools (share) → SharedDataService → QR Maker (import)
     ↓
  "Hello World"
     ↓
  QR Code Generator
     ↓
  Share QR Data
     ↓
  Other Tool (import)
```
