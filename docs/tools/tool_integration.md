# Tool Integration System

**Status**: ✅ Active
**Version**: 1.0
**Last Updated**: October 6, 2025

## Overview

The Tool Integration System enables seamless data sharing and workflow integration between different tools in Toolspace. Tools can now pass data to each other, creating powerful multi-tool workflows.

## Features

- **Cross-tool data sharing**: Share text, JSON, or other data between tools
- **Navigation with context**: Navigate to tools with pre-filled data
- **Unified workflow**: Create multi-step processes across different tools
- **Simple API**: Easy-to-use service and navigation helpers

## Architecture

### Core Components

1. **ToolIntegrationService** (`lib/core/services/tool_integration_service.dart`)
   - Singleton service for managing shared data
   - Key-value store for temporary data
   - ChangeNotifier for reactive updates

2. **ToolNavigation** (`lib/core/services/tool_navigation.dart`)
   - Navigation helpers for all tools
   - Pre-configured routes with data passing
   - Type-safe navigation methods

3. **SendToToolButton** (`lib/core/ui/send_to_tool_button.dart`)
   - UI widget for tool selection
   - Dropdown menu with available tools
   - Automatic data routing

## Usage

### For Users

#### Sending Data Between Tools

1. **From Text Tools**: Process text and send to QR Maker or JSON Doctor
2. **From JSON Doctor**: Format JSON and compare in Text Diff
3. **From any tool**: Use "Send to..." button to share output with another tool

### For Developers

#### Using the Integration Service

```dart
import 'package:toolspace/core/services/tool_integration_service.dart';

final service = ToolIntegrationService();

// Store data for another tool
service.shareData('processed_text', myProcessedText);

// Retrieve data from another tool
final sharedText = service.getData<String>('processed_text');

// Check if data exists
if (service.hasData('processed_text')) {
  // Use the data
}

// Clear data when done
service.clearData('processed_text');
```

#### Using Navigation Helpers

```dart
import 'package:toolspace/core/services/tool_navigation.dart';

// Navigate to Text Tools with initial text
await ToolNavigation.toTextTools(
  context,
  initialText: 'Hello, World!',
);

// Navigate to JSON Doctor with JSON
await ToolNavigation.toJsonDoctor(
  context,
  initialJson: '{"key": "value"}',
);

// Navigate to QR Maker with data
await ToolNavigation.toQrMaker(
  context,
  qrData: 'https://example.com',
);

// Navigate to Text Diff with two texts
await ToolNavigation.toTextDiff(
  context,
  text1: 'Original text',
  text2: 'Modified text',
);
```

#### Using the Send To Tool Button

```dart
import 'package:toolspace/core/ui/send_to_tool_button.dart';

// Add to your tool's UI
SendToToolButton(
  data: outputText,
  label: 'Send output to...',
  icon: Icons.share,
  destinations: const [
    ToolDestination.textTools,
    ToolDestination.jsonDoctor,
    ToolDestination.qrMaker,
  ],
)
```

## Integration Patterns

### Pattern 1: Text Processing Pipeline

1. User starts in **Text Tools**
2. Processes text (case conversion, cleaning, etc.)
3. Sends to **JSON Doctor** for validation
4. Sends to **QR Maker** for encoding

### Pattern 2: Compare and Validate

1. User starts in **JSON Doctor**
2. Formats and validates JSON
3. Sends to **Text Diff** to compare with original

### Pattern 3: Data Generation

1. User generates data in any tool
2. Sends to **QR Maker** to create QR code
3. Shares QR code via download or link

## API Reference

### ToolIntegrationService

| Method | Description | Returns |
|--------|-------------|---------|
| `shareData(key, value)` | Store data for sharing | `void` |
| `getData<T>(key)` | Retrieve typed data | `T?` |
| `clearData(key)` | Remove specific data | `void` |
| `clearAll()` | Remove all data | `void` |
| `hasData(key)` | Check if key exists | `bool` |
| `availableKeys` | Get all stored keys | `List<String>` |

### ToolNavigation

| Method | Parameters | Description |
|--------|------------|-------------|
| `toTextTools()` | `initialText` | Navigate to Text Tools |
| `toJsonDoctor()` | `initialJson` | Navigate to JSON Doctor |
| `toQrMaker()` | `qrData` | Navigate to QR Maker |
| `toTextDiff()` | `text1`, `text2` | Navigate to Text Diff |
| `toFileMerger()` | - | Navigate to File Merger |
| `navigateToTool()` | `toolId`, `sharedData` | Generic navigation |

### SendToToolButton

| Property | Type | Description |
|----------|------|-------------|
| `data` | `String` | Data to share with target tool |
| `label` | `String?` | Button tooltip (optional) |
| `icon` | `IconData?` | Button icon (optional) |
| `destinations` | `List<ToolDestination>` | Available target tools |

## Best Practices

1. **Clear data when done**: Use `clearData()` or `clearAll()` to prevent memory leaks
2. **Type-safe retrieval**: Always specify the type when using `getData<T>()`
3. **Check for data**: Use `hasData()` before retrieving to avoid null issues
4. **Appropriate destinations**: Only show relevant tools in SendToToolButton
5. **User feedback**: Show confirmation when data is sent successfully

## Testing

Tests are located in `test/core/services/tool_integration_service_test.dart`

Run tests:
```bash
flutter test test/core/services/tool_integration_service_test.dart
```

## Future Enhancements

- **v1.1**: Persistent data storage across sessions
- **v1.2**: Multi-tool undo/redo
- **v1.3**: Workflow presets and automation
- **v1.4**: Tool chaining and pipelines
- **v1.5**: Export combined results from multiple tools

## Support

For questions or issues:
- Check the [main documentation](../README.md)
- Review [test examples](../../test/core/services/tool_integration_service_test.dart)
- Create an issue with the `tool:integration` label

---

*Part of the Toolspace Tool Integration Epic*
