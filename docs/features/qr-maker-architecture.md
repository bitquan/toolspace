# QR Maker Architecture

## Component Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    QR Maker Screen                          │
│                 (qr_maker_screen.dart)                       │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │            Mode Toggle (Single/Batch)                 │  │
│  └──────────────────────────────────────────────────────┘  │
│                           │                                  │
│         ┌─────────────────┴─────────────────┐               │
│         │                                    │               │
│    ┌────▼────────┐                   ┌──────▼──────┐        │
│    │ Single Mode │                   │ Batch Mode  │        │
│    └─────────────┘                   └─────────────┘        │
│         │                                    │               │
│    ┌────▼────────────────┐        ┌─────────▼───────────┐  │
│    │  Input Panel        │        │  Batch Panel        │  │
│    │  - Type selector    │        │  - CSV/JSON input   │  │
│    │  - Content field    │        │  - Format selector  │  │
│    │  - Quick templates  │        │  - Validation       │  │
│    │  - Customization    │        │  - Examples         │  │
│    │  - Logo selector    │        └─────────────────────┘  │
│    └─────────────────────┘                   │               │
│         │                                    │               │
│    ┌────▼────────────────┐        ┌─────────▼───────────┐  │
│    │  Preview Panel      │        │  Results Panel      │  │
│    │  - Live QR preview  │        │  - Statistics       │  │
│    │  - Animations       │        │  - Success rate     │  │
│    │  - Info display     │        │  - Item list        │  │
│    │  - Download button  │        │  - Download all     │  │
│    └─────────────────────┘        └─────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                   │
┌───────▼───────┐  ┌──────▼────────┐  ┌───────▼──────────┐
│ Batch         │  │ Logo          │  │ Widgets          │
│ Generator     │  │ Selector      │  │ - BatchPanel     │
│ (Logic)       │  │ (Widget)      │  │ - BatchResults   │
│               │  │               │  │ - ColorPicker    │
│ - Parse CSV   │  │ - Predefined  │  │ - QrPreview      │
│ - Parse JSON  │  │   logos       │  └──────────────────┘
│ - Validate    │  │ - Size adjust │
│ - Generate    │  │ - Upload      │
└───────────────┘  └───────────────┘
```

## Data Flow

### Single Mode Flow

```
User Input → Type Change → Template Load → Content Edit
                                              │
                                              ▼
                                    Live Validation
                                              │
                    ┌─────────────────────────┴──────────────────────┐
                    │                                                │
            ┌───────▼────────┐                            ┌─────────▼────────┐
            │ Customization   │                            │ QR Preview       │
            │ - Size          │────────────────────────────▶ - Real-time     │
            │ - Colors        │                            │ - Animation      │
            │ - Logo          │                            └──────────────────┘
            └─────────────────┘                                     │
                                                                    ▼
                                                            Download/Copy
```

### Batch Mode Flow

```
CSV/JSON Input → Format Detection → Parse Content
                                           │
                                           ▼
                                   Validate Items
                                           │
                    ┌──────────────────────┴──────────────────────┐
                    │                                              │
            ┌───────▼────────┐                          ┌─────────▼────────┐
            │ Valid Items     │                          │ Invalid Items    │
            │                 │                          │ - Error messages │
            └────────┬────────┘                          └──────────────────┘
                     │
                     ▼
            Batch Generation
            (with config)
                     │
            ┌────────┴────────┐
            │                 │
    ┌───────▼────────┐  ┌────▼───────────┐
    │ Successful      │  │ Failed         │
    │ Items           │  │ Items          │
    └────────┬────────┘  └────┬───────────┘
             │                │
             └────────┬───────┘
                      │
                      ▼
            Display Results
            - Statistics
            - Success rate
            - Item lists
                      │
                      ▼
            Download All (ZIP)
```

## State Management

### QR Maker Screen State

```dart
class _QrMakerScreenState {
  // Mode
  bool _isBatchMode = false;
  
  // Single mode state
  String _qrData = '';
  QrType _selectedType = QrType.text;
  
  // Common configuration
  int _qrSize = 200;
  Color _foregroundColor = Colors.black;
  Color _backgroundColor = Colors.white;
  String? _selectedLogoPath;
  double _logoSize = 20.0;
  
  // Batch mode state
  BatchResult? _batchResult;
  
  // UI state
  bool _isGenerating = false;
  
  // Animation
  AnimationController _bounceController;
  Animation<double> _bounceAnimation;
}
```

## Module Dependencies

```
qr_maker_screen.dart
    ├── logic/batch_generator.dart
    │   ├── QrBatchItem
    │   ├── BatchConfig
    │   ├── BatchResult
    │   └── BatchQrGenerator
    │
    ├── widgets/batch_panel.dart
    │   └── Uses: BatchQrGenerator, QrBatchItem, BatchConfig
    │
    ├── widgets/batch_results.dart
    │   └── Uses: BatchResult
    │
    └── widgets/logo_selector.dart
        └── Standalone widget
```

## Testing Structure

```
test/tools/qr_maker_test.dart
    ├── CSV Parsing Tests
    │   ├── Simple content
    │   ├── Quoted content
    │   ├── Empty lines
    │   ├── Header detection
    │   └── No filename
    │
    ├── JSON Parsing Tests
    │   ├── Array of objects
    │   ├── Array of strings
    │   ├── Single object
    │   ├── Wrapped format
    │   └── Invalid JSON
    │
    ├── Validation Tests
    │   ├── Empty content
    │   ├── Content too long
    │   └── Valid items
    │
    ├── Batch Generation Tests
    │   ├── Process valid items
    │   ├── Filter invalid items
    │   └── Calculate processing time
    │
    └── Serialization Tests
        ├── fromJson
        ├── toJson
        └── Statistics
```

## Performance Characteristics

### Time Complexity

| Operation | Complexity | Notes |
|-----------|-----------|-------|
| CSV Parse | O(n) | n = lines in CSV |
| JSON Parse | O(m) | m = JSON string length |
| Validation | O(k) | k = number of items |
| Generation | O(k × g) | g = generation time per item (~10ms) |

### Space Complexity

| Component | Space | Notes |
|-----------|-------|-------|
| Batch Items | O(k) | k = number of items |
| Generated QRs | O(k × s) | s = QR code size |
| UI State | O(1) | Fixed size state |

### Scalability

- **Recommended batch size**: 1-100 items
- **Maximum tested**: 1000 items
- **Memory per item**: ~1KB (data model)
- **Memory per QR**: ~50KB (200x200 PNG)

## Extension Points

### Adding New Input Format

1. Add parser in `batch_generator.dart`:
```dart
static List<QrBatchItem> parseXML(String xmlContent) {
  // Implementation
}
```

2. Add format option in `batch_panel.dart`:
```dart
ButtonSegment(
  value: 'xml',
  label: Text('XML'),
  icon: Icon(Icons.code),
)
```

### Adding New QR Type

1. Add to enum:
```dart
enum QrType { text, url, email, phone, sms, wifi, vcard, newType }
```

2. Update methods:
```dart
String _getTypeLabel(QrType type) {
  case QrType.newType: return 'New Type';
}
```

### Adding Custom Logo Source

1. Extend `logo_selector.dart`:
```dart
Future<void> _uploadCustomLogo() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.image,
  );
  // Handle upload
}
```

## File Organization

```
lib/tools/qr_maker/
├── README.md                   # Module documentation
├── qr_maker_screen.dart        # Main screen (792 lines)
├── logic/
│   └── batch_generator.dart    # Core logic (348 lines)
└── widgets/
    ├── batch_panel.dart        # Input UI (312 lines)
    ├── batch_results.dart      # Results UI (276 lines)
    └── logo_selector.dart      # Logo UI (147 lines)

test/tools/
└── qr_maker_test.dart          # Tests (256 lines)

docs/
├── features/
│   ├── qr-maker-batch-generation.md  # User guide
│   └── qr-maker-architecture.md      # This file
└── dev-log/features/
    └── t-toolspack-micro-tools.md    # Feature log
```

## Summary Statistics

- **Total Lines of Code**: 1,339
- **Logic Layer**: 348 lines
- **UI Layer**: 735 lines (3 widgets)
- **Tests**: 256 lines
- **Documentation**: 3 files

## Related Documents

- [Batch Generation User Guide](qr-maker-batch-generation.md)
- [Module README](../../lib/tools/qr_maker/README.md)
- [T-ToolsPack Feature Log](../dev-log/features/t-toolspack-micro-tools.md)
