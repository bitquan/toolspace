# Cross-Tool Data Sharing

## Overview

The cross-tool data sharing feature allows users to seamlessly transfer data between different tools in Toolspace without manual copy-paste operations.

## Components

### SharedDataService

A singleton service that manages data sharing between tools using the Observer pattern (ChangeNotifier).

**Location**: `lib/core/services/shared_data_service.dart`

#### Key Features

- Share data of various types (text, JSON, URL, QR code, file)
- Maintain a history of shared data (up to 10 items)
- Notify listeners when data changes
- Support for data consumption (use once and clear)

#### Usage

```dart
import 'package:toolspace/core/services/shared_data_service.dart';

// Share data from a tool
final sharedData = SharedData(
  type: SharedDataType.text,
  data: 'Hello World',
  label: 'Greeting',
  sourceTool: 'text_tools',
);
SharedDataService.instance.shareData(sharedData);

// Check if data is available
if (SharedDataService.instance.hasData) {
  final data = SharedDataService.instance.currentData;
  print('Received: ${data?.data}');
}

// Consume data (use once)
final consumed = SharedDataService.instance.consumeData();
```

### ShareDataButton

A reusable widget for sharing data to other tools.

**Location**: `lib/core/ui/share_data_button.dart`

#### Properties

- `data`: The data to share (String)
- `type`: Type of data (SharedDataType enum)
- `sourceTool`: Name of the source tool
- `label`: Optional button label
- `icon`: Optional custom icon
- `compact`: Display as icon button (default: false)
- `onShared`: Callback after sharing

#### Usage

```dart
ShareDataButton(
  data: myTextData,
  type: SharedDataType.text,
  sourceTool: 'text_tools',
  label: 'Send to QR Maker',
  onShared: () {
    print('Data shared!');
  },
)
```

### ImportDataButton

A reusable widget for importing shared data from other tools.

**Location**: `lib/core/ui/import_data_button.dart`

#### Properties

- `acceptedTypes`: List of data types this tool can accept
- `onImport`: Callback when data is imported
- `label`: Optional button label
- `icon`: Optional custom icon
- `compact`: Display as icon button (default: false)

#### Usage

```dart
ImportDataButton(
  acceptedTypes: [SharedDataType.text, SharedDataType.json],
  onImport: (data, type, source) {
    setState(() {
      _textController.text = data;
    });
  },
  label: 'Import',
)
```

## Data Types

The following data types are supported:

- `text`: Plain text data
- `json`: JSON formatted data
- `url`: URL strings
- `qrCode`: QR code data (typically text/URL)
- `file`: File references or content

## Integration Examples

### Example 1: Text Tools → QR Maker

1. User processes text in Text Tools
2. Clicks "Share" button to share the processed text
3. Navigates to QR Maker
4. QR Maker shows "Import" button (enabled because text data is available)
5. User clicks "Import" and the text is loaded into QR input

### Example 2: JSON Doctor → Text Tools

1. User validates JSON in JSON Doctor
2. Shares the formatted JSON output
3. Opens Text Tools
4. Imports the JSON for further processing

## Best Practices

### For Tool Developers

1. **Always clear after use**: Use `consumeData()` instead of just reading `currentData` when you want to use data once
2. **Type checking**: Always check if the data type is compatible before importing
3. **User feedback**: Show appropriate snackbars/messages when sharing or importing
4. **Handle empty data**: Disable share buttons when there's no data to share
5. **Label your data**: Provide meaningful labels to help users identify data

### For Users

1. Share data before navigating to the target tool
2. The most recently shared data is available for import
3. Data persists until consumed or explicitly cleared
4. Check the data source and type before importing

## Architecture

```
┌─────────────┐
│  Text Tools │ ──share──┐
└─────────────┘          │
                         ▼
┌─────────────┐    ┌──────────────────┐    ┌─────────────┐
│ JSON Doctor │◄───│ SharedDataService│───►│  QR Maker   │
└─────────────┘    └──────────────────┘    └─────────────┘
       │                     │                      ▲
       └──────share──────────┘                      │
                                              import─┘
```

## Future Enhancements

- Drag-and-drop support between tools
- Multiple concurrent shared items
- Data transformation pipelines
- Persistent storage of history
- Undo/redo functionality
- Data preview before import

## Testing

Unit tests are available at `test/core/services/shared_data_service_test.dart`

Run tests:
```bash
flutter test test/core/services/shared_data_service_test.dart
```

## API Reference

See inline documentation in:
- `lib/core/services/shared_data_service.dart`
- `lib/core/ui/share_data_button.dart`
- `lib/core/ui/import_data_button.dart`
