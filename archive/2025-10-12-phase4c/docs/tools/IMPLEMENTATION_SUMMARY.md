# Cross-Tool Data Sharing - Implementation Summary

## Overview

This document provides a technical summary of the cross-tool data sharing feature implementation.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Toolspace Application                     │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐              │
│  │QR Maker  │    │Text Diff │    │JSON Dr   │              │
│  │          │    │          │    │          │              │
│  │ [Import] │    │ [Import] │    │ [Import] │              │
│  │ [Share]  │    │ [Share]  │    │ [Share]  │              │
│  └─────┬────┘    └─────┬────┘    └─────┬────┘              │
│        │               │               │                     │
│        └───────────────┼───────────────┘                     │
│                        │                                     │
│                   ┌────▼────┐                               │
│                   │ Shared  │                               │
│                   │  Data   │  ChangeNotifier               │
│                   │ Service │  (Singleton)                  │
│                   └─────────┘                               │
│                        │                                     │
│              ┌─────────┴─────────┐                          │
│              │                   │                          │
│         [SharedData]       [History]                        │
│        currentData     List<SharedData>                     │
│              │                   │                          │
│        ┌─────▼─────┐       ┌────▼────┐                     │
│        │SharedData │       │SharedData│                     │
│        │           │       │          │                     │
│        │- type     │       │- type    │                     │
│        │- data     │       │- data    │                     │
│        │- label    │       │- label   │                     │
│        │- source   │       │- source  │                     │
│        │- timestamp│       │- timestamp│                    │
│        └───────────┘       └──────────┘                     │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

## Components

### 1. SharedDataService

**File**: `lib/core/services/shared_data_service.dart`

**Pattern**: Singleton + ChangeNotifier

**Key Methods**:
```dart
void shareData(SharedData data)      // Share data from a tool
SharedData? consumeData()             // Use data once and clear
void clearData()                      // Clear current data
List<SharedData> get history          // Get all history
List<SharedData> getHistoryByType()   // Filter by type
```

**State**:
- `currentData`: The active shared data item
- `history`: Last 10 shared items (FIFO queue)

### 2. ShareDataButton

**File**: `lib/core/ui/share_data_button.dart`

**Purpose**: Reusable button to share data from a tool

**Props**:
- `data`: String - The data to share
- `type`: SharedDataType - Type of data
- `sourceTool`: String - Name of source tool
- `label`: String? - Optional button label
- `compact`: bool - Display as icon button

**Behavior**:
- Disabled when data is empty
- Shows snackbar on share
- Calls optional `onShared` callback

### 3. ImportDataButton

**File**: `lib/core/ui/import_data_button.dart`

**Purpose**: Reusable button to import shared data

**Props**:
- `acceptedTypes`: List<SharedDataType> - Types this tool accepts
- `onImport`: Function(data, type, source) - Import callback
- `label`: String? - Optional button label
- `compact`: bool - Display as icon button

**Behavior**:
- Listens to SharedDataService via ListenableBuilder
- Auto-enables when compatible data is available
- Auto-disables when no compatible data
- Shows source tool in tooltip
- Consumes data on import

## Data Types

```dart
enum SharedDataType {
  text,      // Plain text
  json,      // JSON formatted data
  url,       // URL strings
  qrCode,    // QR code content
  file,      // File references
}
```

## Integration Pattern

### Minimal Integration

```dart
// 1. Import packages
import '../../core/services/shared_data_service.dart';
import '../../core/ui/share_data_button.dart';
import '../../core/ui/import_data_button.dart';

// 2. Add import button
ImportDataButton(
  acceptedTypes: const [SharedDataType.text],
  onImport: (data, type, source) {
    setState(() {
      _controller.text = data;
    });
  },
)

// 3. Add share button
ShareDataButton(
  data: _controller.text,
  type: SharedDataType.text,
  sourceTool: 'My Tool',
  compact: true,
)
```

## Current Integrations

### QR Maker
- **Imports**: text, url
- **Shares**: text (QR content)
- **Location**: AppBar (share), Input area (import)

### Text Diff
- **Imports**: text (for both inputs)
- **Shares**: text (original or modified)
- **Location**: AppBar (share), Input headers (import)

### JSON Doctor
- **Imports**: json, text
- **Shares**: json (formatted output)
- **Location**: AppBar (both)

## Testing

**File**: `test/core/services/shared_data_service_test.dart`

**Coverage**: 14 tests covering:
- Singleton pattern
- Share/consume operations
- History management
- Type filtering
- Listener notifications
- Edge cases (empty, overflow)

**Run Tests**:
```bash
flutter test test/core/services/shared_data_service_test.dart
```

## State Flow

```
User Action → Tool A
     ↓
ShareDataButton.onPressed()
     ↓
SharedDataService.shareData(data)
     ↓
_currentData = data
_history.insert(0, data)
notifyListeners()
     ↓
ImportDataButton (in Tool B) - ListenableBuilder rebuilds
     ↓
Button enabled if type matches
     ↓
User clicks Import
     ↓
onImport callback fired
     ↓
SharedDataService.consumeData()
     ↓
_currentData = null
notifyListeners()
     ↓
ImportDataButton (in Tool B) - Button disabled
```

## Design Decisions

### Why Singleton?
- Single source of truth for shared data
- Easy access from anywhere: `SharedDataService.instance`
- No need for dependency injection

### Why ChangeNotifier?
- Built-in Flutter pattern for state management
- Automatic UI updates via ListenableBuilder
- Minimal boilerplate

### Why Consume Pattern?
- Prevents accidental reuse of data
- Clear intent: data used once
- User can explicitly keep data by not consuming

### Why History?
- Allows users to access previous shares
- Useful for reference/debugging
- Limited to 10 items to prevent memory issues

## Performance Considerations

- **Memory**: History limited to 10 items
- **Listeners**: Uses ChangeNotifier, automatically cleaned up by Flutter
- **Data Size**: No size limit on shared data (consider adding if needed)
- **Persistence**: Data cleared on app restart (by design)

## Future Enhancements

1. **Persistent Storage**
   - Save history to SharedPreferences
   - Restore on app launch

2. **Data Transformation**
   - Convert between types automatically
   - e.g., JSON → formatted text

3. **Multiple Selections**
   - Share multiple items at once
   - Batch import

4. **Drag and Drop**
   - Visual drag from one tool to another
   - More intuitive UX

5. **Data Preview**
   - Show preview before importing
   - Confirm dialog for large data

6. **Undo/Redo**
   - Undo data consumption
   - Redo previous shares

## Files Modified/Created

```
lib/
  core/
    services/
      shared_data_service.dart       [NEW] Core service
      README.md                      [NEW] Service docs
    ui/
      share_data_button.dart         [NEW] Share widget
      import_data_button.dart        [NEW] Import widget
    README.md                        [MODIFIED] Updated docs
  tools/
    qr_maker/qr_maker_screen.dart    [MODIFIED] Added sharing
    text_diff/text_diff_screen.dart  [MODIFIED] Added sharing
    json_doctor/json_doctor_screen.dart [MODIFIED] Added sharing

test/
  core/
    services/
      shared_data_service_test.dart  [NEW] Unit tests

docs/
  tools/
    cross-tool-data-sharing.md       [NEW] Feature docs
    integration-example.md           [NEW] Integration guide
    IMPLEMENTATION_SUMMARY.md        [NEW] This file

README.md                            [MODIFIED] Feature highlights
```

## Quick Reference

### Share Data
```dart
ShareDataButton(
  data: myData,
  type: SharedDataType.text,
  sourceTool: 'Tool Name',
)
```

### Import Data
```dart
ImportDataButton(
  acceptedTypes: const [SharedDataType.text],
  onImport: (data, type, source) {
    // Use the data
  },
)
```

### Direct Access
```dart
// Check availability
if (SharedDataService.instance.hasData) { }

// Get current data
final data = SharedDataService.instance.currentData;

// Share programmatically
SharedDataService.instance.shareData(SharedData(...));

// Get history
final history = SharedDataService.instance.history;
```

## Contact

For questions or issues with this feature:
- See [Cross-Tool Data Sharing](cross-tool-data-sharing.md) for usage
- See [Integration Example](integration-example.md) for code examples
- Check inline code documentation
- Review test cases for examples
