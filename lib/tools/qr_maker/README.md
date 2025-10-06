# QR Maker

## Overview

QR Maker is a comprehensive QR code generation tool with support for both single and batch generation modes, customization options, and logo embedding.

## Features

### Single Mode
- Generate individual QR codes with real-time preview
- Support for multiple QR types: Text, URL, Email, Phone, SMS, WiFi, vCard
- Customizable size (100-500px), colors, and logo
- Live animations and instant feedback
- Quick templates for common formats

### Batch Mode
- Generate multiple QR codes from CSV or JSON input
- Real-time validation with error reporting
- Batch statistics and success rate tracking
- Download all QR codes as ZIP archive
- Consistent settings across all generated codes

### Logo Embedding
- Predefined logo templates (Flutter, GitHub, Google, Apple, Twitter)
- Adjustable logo size (10-40% of QR code)
- Logo preview in single mode
- Custom logo upload support (coming soon)

## Architecture

### Directory Structure

```
lib/tools/qr_maker/
├── logic/
│   └── batch_generator.dart      # Core batch generation logic
├── widgets/
│   ├── batch_panel.dart          # Batch input UI
│   ├── batch_results.dart        # Batch results display
│   └── logo_selector.dart        # Logo selection widget
├── qr_maker_screen.dart          # Main screen with mode switching
└── README.md                     # This file
```

### Key Components

#### 1. Batch Generator (`logic/batch_generator.dart`)

Core logic for batch processing:
- **QrBatchItem**: Data model for batch items
- **BatchConfig**: Configuration for batch generation
- **BatchResult**: Results with statistics
- **BatchQrGenerator**: Parser and generator functions

```dart
// Parse CSV
final items = BatchQrGenerator.parseCsv(csvContent);

// Parse JSON
final items = BatchQrGenerator.parseJson(jsonContent);

// Validate
final errors = BatchQrGenerator.validateItems(items);

// Generate
final result = await BatchQrGenerator.generateBatch(items, config);
```

#### 2. Batch Panel (`widgets/batch_panel.dart`)

UI for batch input:
- Format selector (CSV/JSON)
- Input text area with hints
- Real-time parsing and validation
- Example templates
- Generate button with item count

#### 3. Batch Results (`widgets/batch_results.dart`)

Results display:
- Statistics cards (success, errors, time)
- Success rate visualization
- Item lists with status
- Download all button
- Error details

#### 4. Logo Selector (`widgets/logo_selector.dart`)

Logo configuration:
- Predefined logo grid
- Logo size slider
- Custom upload placeholder
- Remove logo option

## Usage

### Single Mode

```dart
// In qr_maker_screen.dart
setState(() {
  _qrData = 'https://example.com';
  _selectedLogoPath = 'flutter';
  _logoSize = 20.0;
});
```

### Batch Mode

```dart
// Parse and generate
final items = BatchQrGenerator.parseCsv('''
https://example.com,example
https://github.com,github
''');

final config = BatchConfig(
  qrSize: 200,
  foregroundColor: '#000000',
  backgroundColor: '#FFFFFF',
  logoPath: 'flutter',
  logoSize: 20.0,
);

final result = await BatchQrGenerator.generateBatch(items, config);
```

## Testing

### Run Tests

```bash
flutter test test/tools/qr_maker_test.dart
```

### Test Coverage

- CSV parsing with various formats
- JSON parsing with different structures
- Validation logic
- Batch generation workflow
- Error handling
- Statistics calculation

### Test Structure

```dart
group('BatchQrGenerator - CSV Parsing', () {
  test('parseCsv handles simple content correctly', () { ... });
  test('parseCsv handles content with quotes', () { ... });
});

group('BatchQrGenerator - JSON Parsing', () {
  test('parseJson handles array of objects', () { ... });
  test('parseJson handles array of strings', () { ... });
});

group('BatchQrGenerator - Validation', () {
  test('validateItems detects empty content', () { ... });
  test('validateItems detects content too long', () { ... });
});
```

## Development

### Adding New Features

1. **New QR Type**
   - Add to `QrType` enum
   - Update `_getTypeLabel()` and `_getHintText()`
   - Add template in `_getQuickTemplate()`

2. **New Logo**
   - Add identifier to `_predefinedLogos` in `logo_selector.dart`
   - Map icon in `_getIconForLogo()`

3. **New Input Format**
   - Add parser method in `batch_generator.dart`
   - Add format option in `batch_panel.dart`
   - Update tests

### Code Style

Follow Flutter/Dart conventions:
- Use `///` for public API documentation
- Keep widgets small and focused
- Extract reusable components
- Add tests for new logic
- Use const constructors where possible

## Performance

- **CSV Parsing**: O(n) where n is number of lines
- **JSON Parsing**: O(n) where n is content length
- **Validation**: O(n) where n is number of items
- **Generation**: ~10ms per QR code (simulated)

## Future Enhancements

- [ ] Custom logo upload from device
- [ ] Real QR code generation (currently placeholder)
- [ ] Export formats: SVG, PDF, EPS
- [ ] Advanced styling: gradients, rounded corners
- [ ] QR code error correction level selection
- [ ] Bulk editing of batch items
- [ ] Import from external sources
- [ ] Cloud storage integration

## Related Documentation

- [Batch Generation Guide](../../../docs/features/qr-maker-batch-generation.md)
- [T-ToolsPack Feature Log](../../../docs/dev-log/features/t-toolspack-micro-tools.md)
- [Phase 1 Roadmap](../../../docs/roadmap/phase-1.md)

## Contributing

When contributing:
1. Follow existing code patterns
2. Add tests for new functionality
3. Update documentation
4. Maintain backward compatibility
5. Consider performance for large batches

## License

Part of the Toolspace project.
