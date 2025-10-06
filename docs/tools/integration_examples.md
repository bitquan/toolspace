# Tool Integration Examples

This document provides examples of how to integrate the Tool Integration system into existing or new tools.

## Quick Integration Guide

### 1. Reading Shared Data on Init

If your tool should accept data from other tools, check for shared data when initializing:

```dart
import '../../core/services/tool_integration_service.dart';

class MyToolScreen extends StatefulWidget {
  const MyToolScreen({super.key});

  @override
  State<MyToolScreen> createState() => _MyToolScreenState();
}

class _MyToolScreenState extends State<MyToolScreen> {
  final _integrationService = ToolIntegrationService();
  final TextEditingController _inputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSharedData();
  }

  void _loadSharedData() {
    // Check if there's shared data for this tool
    if (_integrationService.hasData('input_text')) {
      final sharedText = _integrationService.getData<String>('input_text');
      if (sharedText != null) {
        _inputController.text = sharedText;
        // Clear the data after loading
        _integrationService.clearData('input_text');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Your tool UI
  }
}
```

### 2. Adding "Send To" Button to Output

Add the SendToToolButton to allow users to send processed output to other tools:

```dart
import '../../core/ui/send_to_tool_button.dart';

// In your tool's UI, where you show output:
Row(
  children: [
    Expanded(
      child: TextField(
        controller: _outputController,
        readOnly: true,
      ),
    ),
    // Add Send To button
    SendToToolButton(
      data: _outputController.text,
      label: 'Send output to...',
      icon: Icons.share,
      destinations: const [
        ToolDestination.jsonDoctor,
        ToolDestination.qrMaker,
        ToolDestination.textDiff,
      ],
    ),
  ],
)
```

### 3. Programmatic Navigation with Data

Navigate to another tool from your code:

```dart
import '../../core/services/tool_navigation.dart';

// After processing, navigate to QR Maker
ElevatedButton(
  onPressed: () async {
    final output = _processData();
    await ToolNavigation.toQrMaker(
      context,
      qrData: output,
    );
  },
  child: const Text('Generate QR Code'),
)

// Or navigate to Text Diff for comparison
ElevatedButton(
  onPressed: () async {
    await ToolNavigation.toTextDiff(
      context,
      text1: _originalText,
      text2: _processedText,
    );
  },
  child: const Text('Compare Results'),
)
```

### 4. Complete Example: Enhanced Text Tool

Here's a complete example of adding integration to a simple text processing tool:

```dart
import 'package:flutter/material.dart';
import '../../core/services/tool_integration_service.dart';
import '../../core/services/tool_navigation.dart';
import '../../core/ui/send_to_tool_button.dart';

class EnhancedTextTool extends StatefulWidget {
  const EnhancedTextTool({super.key});

  @override
  State<EnhancedTextTool> createState() => _EnhancedTextToolState();
}

class _EnhancedTextToolState extends State<EnhancedTextTool> {
  final _integrationService = ToolIntegrationService();
  final _inputController = TextEditingController();
  final _outputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSharedData();
  }

  void _loadSharedData() {
    // Load any shared text data
    if (_integrationService.hasData('input_text')) {
      final text = _integrationService.getData<String>('input_text');
      if (text != null) {
        _inputController.text = text;
        _integrationService.clearData('input_text');
      }
    }
  }

  void _processText() {
    // Example: Convert to uppercase
    _outputController.text = _inputController.text.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enhanced Text Tool'),
        actions: [
          // Quick navigation to other tools
          IconButton(
            icon: const Icon(Icons.qr_code),
            tooltip: 'Send to QR Maker',
            onPressed: () {
              if (_outputController.text.isNotEmpty) {
                ToolNavigation.toQrMaker(
                  context,
                  qrData: _outputController.text,
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Input
            TextField(
              controller: _inputController,
              decoration: const InputDecoration(
                labelText: 'Input',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),

            // Process button
            ElevatedButton(
              onPressed: _processText,
              child: const Text('Process'),
            ),
            const SizedBox(height: 16),

            // Output with Send To button
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _outputController,
                    decoration: const InputDecoration(
                      labelText: 'Output',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                    readOnly: true,
                  ),
                ),
                const SizedBox(width: 8),
                SendToToolButton(
                  data: _outputController.text,
                  label: 'Send to...',
                  destinations: const [
                    ToolDestination.jsonDoctor,
                    ToolDestination.qrMaker,
                    ToolDestination.textDiff,
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }
}
```

## Common Integration Patterns

### Pattern 1: Input Receiver

Tools that receive data from other tools:

```dart
void initState() {
  super.initState();
  
  // Check for various input types
  _loadSharedData();
}

void _loadSharedData() {
  final service = ToolIntegrationService();
  
  // Try to load text input
  if (service.hasData('input_text')) {
    _textController.text = service.getData<String>('input_text') ?? '';
    service.clearData('input_text');
  }
  
  // Try to load JSON input
  if (service.hasData('input_json')) {
    _jsonController.text = service.getData<String>('input_json') ?? '';
    service.clearData('input_json');
  }
}
```

### Pattern 2: Output Sharer

Tools that share their output:

```dart
// Add Send To button in actions
actions: [
  SendToToolButton(
    data: _outputController.text,
    destinations: _getRelevantTools(),
  ),
]

List<ToolDestination> _getRelevantTools() {
  // Return relevant tools based on output type
  if (_isJson(_outputController.text)) {
    return [ToolDestination.jsonDoctor, ToolDestination.textDiff];
  }
  return [ToolDestination.qrMaker, ToolDestination.textTools];
}
```

### Pattern 3: Workflow Chain

Tools that guide users through multi-step workflows:

```dart
Future<void> _completeWorkflow() async {
  // Step 1: Process data
  final result = _processData();
  
  // Step 2: Show confirmation
  final shouldContinue = await _showConfirmation(context);
  
  if (shouldContinue) {
    // Step 3: Navigate to next tool with result
    await ToolNavigation.toJsonDoctor(
      context,
      initialJson: result,
    );
  }
}
```

## Best Practices

1. **Always clear data after loading**: Prevent stale data from persisting
2. **Check data exists before loading**: Use `hasData()` to avoid null issues
3. **Type-safe retrieval**: Always specify the type with `getData<T>()`
4. **Provide fallbacks**: Handle cases where no shared data exists
5. **Relevant destinations**: Only show tools that make sense for your data type
6. **User feedback**: Show toast/snackbar when sending data to another tool

## Testing Integration

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:toolspace/core/services/tool_integration_service.dart';

void main() {
  testWidgets('Tool loads shared data', (tester) async {
    // Arrange: Share data
    final service = ToolIntegrationService();
    service.shareData('input_text', 'Test data');

    // Act: Build tool
    await tester.pumpWidget(
      MaterialApp(home: MyToolScreen()),
    );
    await tester.pumpAndSettle();

    // Assert: Data was loaded
    expect(find.text('Test data'), findsOneWidget);
    expect(service.hasData('input_text'), isFalse); // Cleared after load
  });
}
```

## Additional Resources

- [Tool Integration API](tool_integration.md) - Complete API reference
- [Core Services README](../../lib/core/services/README.md) - Service documentation
- [Test Examples](../../test/core/services/tool_integration_service_test.dart) - Unit tests

---

*Last updated: October 6, 2025*
