# Cross-Tool Data Sharing Integration Example

This document shows how to integrate cross-tool data sharing into a new or existing tool.

## Step 1: Import Required Packages

```dart
import 'package:toolspace/core/services/shared_data_service.dart';
import 'package:toolspace/core/ui/share_data_button.dart';
import 'package:toolspace/core/ui/import_data_button.dart';
```

## Step 2: Add Import Button to Your UI

Add an import button where users can load data from other tools:

```dart
// In your widget's build method
ImportDataButton(
  acceptedTypes: const [
    SharedDataType.text,
    SharedDataType.json,
  ],
  onImport: (data, type, source) {
    setState(() {
      // Load the data into your tool
      _inputController.text = data;
    });
    
    // Optional: Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Imported from $source')),
    );
  },
  label: 'Import',  // Optional custom label
  compact: false,   // Set to true for icon-only button
)
```

## Step 3: Add Share Button to Your UI

Add a share button to allow users to send data to other tools:

```dart
// In your AppBar actions or toolbar
ShareDataButton(
  data: _outputController.text,
  type: SharedDataType.text,
  sourceTool: 'My Tool',
  label: 'Share',
  compact: true,  // Icon-only button
  onShared: () {
    // Optional callback after sharing
    print('Data shared successfully');
  },
)
```

## Complete Example

Here's a complete example of a simple text processing tool with sharing:

```dart
import 'package:flutter/material.dart';
import 'package:toolspace/core/services/shared_data_service.dart';
import 'package:toolspace/core/ui/share_data_button.dart';
import 'package:toolspace/core/ui/import_data_button.dart';

class MyToolScreen extends StatefulWidget {
  const MyToolScreen({super.key});

  @override
  State<MyToolScreen> createState() => _MyToolScreenState();
}

class _MyToolScreenState extends State<MyToolScreen> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  void _processData() {
    // Your tool's logic here
    final processed = _inputController.text.toUpperCase();
    setState(() {
      _outputController.text = processed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tool'),
        actions: [
          // Share button - only enabled when there's output
          if (_outputController.text.isNotEmpty)
            ShareDataButton(
              data: _outputController.text,
              type: SharedDataType.text,
              sourceTool: 'My Tool',
              compact: true,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Input section
            const Text('Input', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            
            // Import button
            ImportDataButton(
              acceptedTypes: const [SharedDataType.text],
              onImport: (data, type, source) {
                setState(() {
                  _inputController.text = data;
                });
              },
              label: 'Import from Other Tools',
            ),
            
            const SizedBox(height: 8),
            
            // Input field
            TextField(
              controller: _inputController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Enter text or import from another tool',
                border: OutlineInputBorder(),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Process button
            ElevatedButton(
              onPressed: _processData,
              child: const Text('Process'),
            ),
            
            const SizedBox(height: 16),
            
            // Output section
            const Text('Output', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _outputController,
              maxLines: 5,
              readOnly: true,
              decoration: const InputDecoration(
                hintText: 'Processed output will appear here',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Tips and Best Practices

### 1. Choose Appropriate Data Types

```dart
// For plain text
SharedDataType.text

// For JSON data
SharedDataType.json

// For URLs
SharedDataType.url

// For QR code content
SharedDataType.qrCode

// For file references
SharedDataType.file
```

### 2. Accept Multiple Types When Appropriate

```dart
ImportDataButton(
  acceptedTypes: const [
    SharedDataType.text,
    SharedDataType.json,
    SharedDataType.url,
  ],
  onImport: (data, type, source) {
    // Handle different types appropriately
    if (type == SharedDataType.json) {
      // Parse JSON
    } else {
      // Handle as text
    }
  },
)
```

### 3. Conditional Display

Only show share buttons when there's data to share:

```dart
if (_hasOutput)
  ShareDataButton(
    data: _outputData,
    type: SharedDataType.text,
    sourceTool: 'My Tool',
  ),
```

### 4. User Feedback

The buttons already show snackbars, but you can add custom callbacks:

```dart
ShareDataButton(
  data: myData,
  type: SharedDataType.text,
  sourceTool: 'My Tool',
  onShared: () {
    // Log analytics, update UI state, etc.
    print('Data shared successfully');
  },
)
```

### 5. Programmatic Access

You can also access the service directly if needed:

```dart
// Check if data is available
if (SharedDataService.instance.hasData) {
  final sharedData = SharedDataService.instance.currentData;
  print('Available: ${sharedData?.sourceTool}');
}

// Get history
final history = SharedDataService.instance.history;
final textHistory = SharedDataService.instance.getHistoryByType(
  SharedDataType.text,
);
```

## Testing Your Integration

1. Add unit tests for your tool's import/share functionality
2. Test with different data types
3. Verify data flows correctly between tools
4. Test edge cases (empty data, large data, special characters)

Example test:

```dart
testWidgets('Import button loads shared data', (tester) async {
  // Setup
  SharedDataService.instance.shareData(
    SharedData(
      type: SharedDataType.text,
      data: 'Test data',
      sourceTool: 'test',
    ),
  );

  await tester.pumpWidget(
    MaterialApp(home: MyToolScreen()),
  );

  // Find and tap import button
  await tester.tap(find.text('Import'));
  await tester.pump();

  // Verify data was imported
  expect(find.text('Test data'), findsOneWidget);
});
```

## Common Patterns

### Pattern 1: Input + Output Tool

Tools that transform input to output (like Text Tools, JSON Doctor):
- Add Import button near input field
- Add Share button for output in AppBar actions

### Pattern 2: Generator Tool

Tools that generate content (like QR Maker):
- Add Import button for input parameters
- Add Share button for generated content

### Pattern 3: Comparison Tool

Tools that compare multiple inputs (like Text Diff):
- Add Import button for each input
- Add Share buttons for each output or result

## Troubleshooting

### Import button is disabled

- Check that data type matches `acceptedTypes`
- Verify `SharedDataService.instance.hasData` returns true
- Ensure another tool has shared data

### Data not showing up

- Make sure you're calling `setState()` in `onImport`
- Verify the data format is correct
- Check that the controller is properly bound to the UI

### Multiple imports overwriting each other

- Use `consumeData()` if you want single-use behavior
- Check if multiple widgets are listening to the service

## See Also

- [Cross-Tool Data Sharing Documentation](cross-tool-data-sharing.md)
- [SharedDataService API Reference](../../lib/core/services/shared_data_service.dart)
- Example implementations:
  - [QR Maker](../../lib/tools/qr_maker/qr_maker_screen.dart)
  - [Text Diff](../../lib/tools/text_diff/text_diff_screen.dart)
  - [JSON Doctor](../../lib/tools/json_doctor/json_doctor_screen.dart)
