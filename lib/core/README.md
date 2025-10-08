# Toolspace Core

This directory contains shared components used across all micro-tools in the Toolspace platform.

## Components

### Routing
- `routes.dart` - Central router configuration for all tools

### Services
- `services/shared_data_service.dart` - Cross-tool data sharing service

### UI Components
- `ui/clipboard_btn.dart` - Reusable clipboard copy button
- `ui/share_data_button.dart` - Button for sharing data to other tools
- `ui/import_data_button.dart` - Button for importing shared data

### Other
- Authentication helpers (planned)
- Theme configuration
- Billing integration stubs (planned)

## Usage

Tools should import core components to maintain consistency across the platform.

### Cross-Tool Data Sharing

```dart
import 'package:toolspace/core/services/shared_data_service.dart';
import 'package:toolspace/core/ui/share_data_button.dart';
import 'package:toolspace/core/ui/import_data_button.dart';

// Share data from your tool
ShareDataButton(
  data: myData,
  type: SharedDataType.text,
  sourceTool: 'my_tool',
)

// Import data in your tool
ImportDataButton(
  acceptedTypes: [SharedDataType.text, SharedDataType.json],
  onImport: (data, type, source) {
    // Handle imported data
  },
)
```

See [Cross-Tool Data Sharing Documentation](../../docs/tools/cross-tool-data-sharing.md) for details.
