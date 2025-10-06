# Core Services

This directory contains shared services used across the Toolspace application.

## Services

### Tool Integration Service (`tool_integration_service.dart`)

Singleton service for cross-tool data sharing and workflow integration.

**Features:**
- Store and retrieve shared data between tools
- Key-value store with type-safe retrieval
- ChangeNotifier for reactive updates
- Singleton pattern for global access

**Usage:**
```dart
final service = ToolIntegrationService();

// Share data
service.shareData('my_key', 'my_value');

// Retrieve data
final value = service.getData<String>('my_key');

// Check if data exists
if (service.hasData('my_key')) {
  // Use the data
}

// Clear data
service.clearData('my_key');
```

### Tool Navigation (`tool_navigation.dart`)

Navigation helpers for seamless cross-tool workflows.

**Features:**
- Pre-configured routes to all tools
- Data passing on navigation
- Type-safe navigation methods
- Consistent page transitions

**Usage:**
```dart
// Navigate to Text Tools with initial text
await ToolNavigation.toTextTools(
  context,
  initialText: 'Hello, World!',
);

// Navigate to JSON Doctor
await ToolNavigation.toJsonDoctor(
  context,
  initialJson: '{"key": "value"}',
);

// Generic navigation
await ToolNavigation.navigateToTool(
  context,
  'tool-id',
  sharedData: {'key': 'value'},
);
```

## Testing

Tests are located in `test/core/services/`

Run tests:
```bash
flutter test test/core/services/
```

## Documentation

See [Tool Integration Documentation](../../../docs/tools/tool_integration.md) for complete details.
