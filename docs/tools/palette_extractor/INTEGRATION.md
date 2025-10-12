# Palette Extractor - Integration Guide

## ShareEnvelope Framework Integration

The Palette Extractor leverages the ShareEnvelope framework to enable seamless data flow throughout the Toolspace ecosystem, transforming color extraction into a collaborative, multi-tool workflow.

### Core Integration Architecture

```dart
// Palette extraction with ShareEnvelope integration
class PaletteExtractorService extends ShareEnvelopeEnabled {
  @override
  List<SharedDataType> get supportedExports => [
    SharedDataType.text,      // HEX color codes
    SharedDataType.json,      // Structured palette data
    SharedDataType.file,      // Export files
  ];

  @override
  List<SharedDataType> get supportedImports => [
    SharedDataType.file,      // Image files
    SharedDataType.image,     // Direct image data
  ];
}
```

### Data Flow Patterns

#### Outbound Data Sharing

**Color Codes to Text Tools**

```dart
// Share extracted HEX codes for text processing
final colorCodes = extractedPalette.map((color) =>
  ColorUtils.toHex(color)).join('\n');

ShareEnvelope.share(
  data: colorCodes,
  type: SharedDataType.text,
  source: 'palette_extractor',
  metadata: {
    'format': 'hex_list',
    'count': extractedPalette.length,
    'extraction_method': 'kmeans',
  }
);
```

**Structured Palette to JSON Doctor**

```dart
// Share complete palette data for JSON manipulation
final paletteJson = {
  'name': 'Extracted Palette',
  'timestamp': DateTime.now().toIso8601String(),
  'colors': extractedPalette.map((color) => {
    'hex': ColorUtils.toHex(color),
    'rgb': ColorUtils.toRgb(color),
    'hsl': ColorUtils.toHsl(color),
    'frequency': frequencies[extractedPalette.indexOf(color)],
  }).toList(),
  'metadata': {
    'algorithm': 'k-means++',
    'image_size': imageMetadata,
    'extraction_settings': settings,
  }
};

ShareEnvelope.share(
  data: jsonEncode(paletteJson),
  type: SharedDataType.json,
  source: 'palette_extractor',
  metadata: {'schema': 'color_palette_v2'}
);
```

**Export Files to File Manager**

```dart
// Share generated palette files
await _exportPalette(ExportFormat.css).then((cssFile) {
  ShareEnvelope.share(
    data: cssFile,
    type: SharedDataType.file,
    source: 'palette_extractor',
    metadata: {
      'format': 'css',
      'filename': 'palette_${timestamp}.css',
      'mime_type': 'text/css',
    }
  );
});
```

#### Inbound Data Processing

**Image Files from File Compressor**

```dart
// Receive optimized images for color extraction
@override
void handleSharedData(SharedData data) {
  if (data.type == SharedDataType.file &&
      data.metadata['mime_type']?.startsWith('image/') == true) {

    _processSharedImage(
      data.content,
      optimized: data.metadata['compression_applied'] == true,
      originalSize: data.metadata['original_size'],
    );
  }
}
```

**Color References from QR Maker**

```dart
// Import color codes from QR-encoded data
if (data.type == SharedDataType.text &&
    data.metadata['content_type'] == 'color_codes') {

  final colorCodes = data.content.split('\n')
    .where((line) => line.startsWith('#'))
    .map((hex) => ColorUtils.fromHex(hex))
    .toList();

  _displayImportedPalette(colorCodes);
}
```

## Cross-Tool Workflow Integration

### Design System Development

**Complete Brand Color Workflow**

1. **Palette Extractor**: Extract colors from brand assets
2. **Text Tools**: Process and format color names
3. **JSON Doctor**: Structure color tokens for design systems
4. **MD to PDF**: Generate comprehensive color documentation
5. **QR Maker**: Create QR codes for color references

```dart
// Orchestrated workflow example
class BrandColorWorkflow {
  static Future<void> execute(File brandAsset) async {
    // Step 1: Extract palette
    final palette = await PaletteExtractor.extractFromFile(brandAsset);

    // Step 2: Share colors for processing
    await ShareEnvelope.share(
      data: palette.toJson(),
      type: SharedDataType.json,
      source: 'palette_extractor',
      workflow: 'brand_color_development'
    );

    // Workflow continues in other tools...
  }
}
```

### Creative Asset Pipeline

**Multi-Image Color Analysis**

```dart
// Batch processing with cross-tool coordination
class ColorAnalysisPipeline {
  static Future<void> analyzeBrandAssets(List<File> images) async {
    final results = <String, Map<String, dynamic>>{};

    for (final image in images) {
      final palette = await PaletteExtractor.extractFromFile(image);

      results[image.name] = {
        'palette': palette.colors,
        'dominant_color': palette.colors.first,
        'contrast_ratios': _calculateContrastRatios(palette.colors),
        'accessibility_score': _calculateAccessibilityScore(palette.colors),
      };
    }

    // Share comprehensive analysis
    await ShareEnvelope.share(
      data: jsonEncode(results),
      type: SharedDataType.json,
      source: 'palette_extractor',
      metadata: {'analysis_type': 'brand_consistency_audit'}
    );
  }
}
```

## API Integration Layer

### Flutter Framework Integration

**Custom Widget for Embedded Extraction**

```dart
class EmbeddedPaletteExtractor extends StatefulWidget {
  final Function(List<Color>) onPaletteExtracted;
  final int? maxColors;
  final bool autoExtract;

  const EmbeddedPaletteExtractor({
    Key? key,
    required this.onPaletteExtracted,
    this.maxColors = 10,
    this.autoExtract = true,
  }) : super(key: key);

  @override
  State<EmbeddedPaletteExtractor> createState() =>
    _EmbeddedPaletteExtractorState();
}
```

**Service-Level Integration**

```dart
class PaletteService {
  static final _instance = PaletteService._internal();
  factory PaletteService() => _instance;
  PaletteService._internal();

  Future<PaletteResult> extractFromBytes(
    Uint8List imageBytes, {
    int colorCount = 10,
    int? maxSampleSize,
    String? sourceContext,
  }) async {
    final result = await KMeansClustering.extractPalette(
      await _bytesToPixels(imageBytes),
      k: colorCount,
      sampleSize: maxSampleSize,
    );

    // Automatic sharing if context provided
    if (sourceContext != null) {
      await _shareExtractedPalette(result, sourceContext);
    }

    return result;
  }
}
```

### External API Connectivity

**Cloud Color Analysis Service**

```dart
class CloudColorAPI {
  static Future<EnhancedPaletteResult> enhanceWithCloudAnalysis(
    List<Color> localPalette
  ) async {
    final request = {
      'colors': localPalette.map((c) => ColorUtils.toHex(c)).toList(),
      'analysis_type': 'comprehensive',
      'include_harmony': true,
      'include_accessibility': true,
      'include_trends': true,
    };

    final response = await http.post(
      Uri.parse('${Config.apiBase}/color/analyze'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request),
    );

    return EnhancedPaletteResult.fromJson(response.data);
  }
}
```

**Design Tool Synchronization**

```dart
class DesignToolSync {
  static Future<void> syncToFigma(List<Color> palette) async {
    final figmaPayload = {
      'colors': palette.map((color) => {
        'name': ColorNamer.getName(color),
        'hex': ColorUtils.toHex(color),
        'rgb': ColorUtils.toRgbMap(color),
      }).toList(),
    };

    await FigmaAPI.createColorStyles(figmaPayload);
  }

  static Future<void> syncToSketch(List<Color> palette) async {
    // Sketch plugin integration
    final sketchDoc = await SketchAPI.createDocument('Extracted Palette');

    for (final color in palette) {
      await sketchDoc.addColorSwatch(
        ColorUtils.toHex(color),
        name: ColorNamer.getName(color),
      );
    }
  }
}
```

## Database & Storage Integration

### Local Storage Strategy

**Palette History Management**

```dart
class PaletteHistoryService {
  static const String _storageKey = 'palette_history';

  static Future<void> savePalette(
    List<Color> colors,
    String sourceName,
    Map<String, dynamic> metadata,
  ) async {
    final history = await getHistory();

    final entry = PaletteHistoryEntry(
      id: generateUuid(),
      colors: colors,
      sourceName: sourceName,
      extractedAt: DateTime.now(),
      metadata: metadata,
    );

    history.insert(0, entry);

    // Keep only last 50 palettes
    if (history.length > 50) {
      history.removeRange(50, history.length);
    }

    await SharedPreferences.getInstance().then((prefs) {
      prefs.setString(_storageKey, jsonEncode(history));
    });
  }
}
```

**Cross-Session State Management**

```dart
class PaletteState extends ChangeNotifier {
  List<Color> _currentPalette = [];
  PaletteMetadata? _currentMetadata;
  ExtractionSettings _settings = ExtractionSettings.defaults();

  void updatePalette(List<Color> colors, PaletteMetadata metadata) {
    _currentPalette = colors;
    _currentMetadata = metadata;

    // Auto-save to storage
    PaletteHistoryService.savePalette(colors, metadata.sourceName, {
      'extraction_method': metadata.algorithm,
      'color_count': colors.length,
      'processing_time': metadata.processingDuration.inMilliseconds,
    });

    notifyListeners();
  }
}
```

### Cloud Storage Integration

**Palette Synchronization Service**

```dart
class PaletteSyncService {
  static Future<void> syncToCloud(PaletteHistoryEntry entry) async {
    if (!UserAuth.isAuthenticated) return;

    final cloudEntry = {
      'id': entry.id,
      'colors': entry.colors.map((c) => ColorUtils.toHex(c)).toList(),
      'source_name': entry.sourceName,
      'extracted_at': entry.extractedAt.toIso8601String(),
      'metadata': entry.metadata,
      'user_id': UserAuth.currentUser.id,
    };

    await FirebaseFirestore.instance
      .collection('user_palettes')
      .doc(entry.id)
      .set(cloudEntry);
  }

  static Stream<List<PaletteHistoryEntry>> watchUserPalettes() {
    return FirebaseFirestore.instance
      .collection('user_palettes')
      .where('user_id', isEqualTo: UserAuth.currentUser.id)
      .orderBy('extracted_at', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => PaletteHistoryEntry.fromCloudData(doc.data()))
          .toList());
  }
}
```

## Advanced Integration Patterns

### Real-Time Collaboration

**Shared Palette Editing**

```dart
class CollaborativePaletteSession {
  final String sessionId;
  late StreamSubscription _paletteUpdates;

  CollaborativePaletteSession(this.sessionId);

  void startSession() {
    _paletteUpdates = FirebaseFirestore.instance
      .collection('palette_sessions')
      .doc(sessionId)
      .snapshots()
      .listen((snapshot) {
        final data = snapshot.data();
        if (data != null) {
          _handleRemotePaletteUpdate(data);
        }
      });
  }

  Future<void> shareColorUpdate(Color color, int index) async {
    await FirebaseFirestore.instance
      .collection('palette_sessions')
      .doc(sessionId)
      .update({
        'colors.$index': ColorUtils.toHex(color),
        'updated_by': UserAuth.currentUser.id,
        'updated_at': FieldValue.serverTimestamp(),
      });
  }
}
```

### Machine Learning Integration

**Color Trend Analysis**

```dart
class ColorTrendAnalyzer {
  static Future<TrendAnalysisResult> analyzeTrends(
    List<Color> palette
  ) async {
    final features = _extractColorFeatures(palette);

    // Send to ML service
    final prediction = await MLService.predict(
      model: 'color_trend_classifier_v2',
      features: features,
    );

    return TrendAnalysisResult(
      trendScore: prediction['trend_score'],
      categories: prediction['categories'],
      suggestions: prediction['suggestions'],
      seasonality: prediction['seasonality'],
    );
  }

  static Map<String, double> _extractColorFeatures(List<Color> colors) {
    return {
      'hue_variance': _calculateHueVariance(colors),
      'saturation_avg': _calculateAverageSaturation(colors),
      'brightness_avg': _calculateAverageBrightness(colors),
      'contrast_ratio': _calculateOverallContrast(colors),
      'temperature': _calculateColorTemperature(colors),
    };
  }
}
```

### Performance Optimization Integration

**Lazy Loading with Caching**

```dart
class OptimizedPaletteExtractor {
  static final Map<String, PaletteResult> _cache = {};

  static Future<PaletteResult> extractWithCaching(
    Uint8List imageBytes, {
    int colorCount = 10,
    bool forceRefresh = false,
  }) async {
    final cacheKey = _generateCacheKey(imageBytes, colorCount);

    if (!forceRefresh && _cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    // Extract in background isolate
    final result = await compute(_extractionWorker, {
      'bytes': imageBytes,
      'colorCount': colorCount,
      'optimization': true,
    });

    _cache[cacheKey] = result;
    return result;
  }

  static PaletteResult _extractionWorker(Map<String, dynamic> params) {
    // Optimized extraction logic runs in isolate
    return KMeansClustering.extractPalette(
      _bytesToPixels(params['bytes']),
      k: params['colorCount'],
      optimization: params['optimization'],
    );
  }
}
```

## Testing Integration Framework

### Unit Test Integration

```dart
class PaletteExtractorTestHelper {
  static List<Color> createTestPalette({
    int count = 5,
    bool includeGrayscale = false,
  }) {
    final colors = <Color>[];

    for (int i = 0; i < count; i++) {
      if (includeGrayscale && i == 0) {
        colors.add(const Color(0xFF808080)); // Gray
      } else {
        colors.add(Color.fromARGB(
          255,
          (i * 50) % 255,
          (i * 80) % 255,
          (i * 120) % 255,
        ));
      }
    }

    return colors;
  }

  static Future<void> testShareEnvelopeIntegration() async {
    final testPalette = createTestPalette();

    // Test data sharing
    final shared = await ShareEnvelope.share(
      data: jsonEncode(testPalette.map((c) => ColorUtils.toHex(c)).toList()),
      type: SharedDataType.json,
      source: 'palette_extractor_test',
    );

    expect(shared.success, isTrue);
    expect(shared.data, isNotNull);
  }
}
```

### Integration Test Scenarios

```dart
void main() {
  group('Palette Extractor Integration Tests', () {
    testWidgets('should extract and share palette', (tester) async {
      await tester.pumpWidget(const TestApp());

      // Upload test image
      await tester.tap(find.byType(ImageUploadZone));
      await tester.pump();

      // Wait for extraction
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify palette extracted
      expect(find.byType(ColorSwatchCard), findsWidgets);

      // Test sharing functionality
      await tester.tap(find.byIcon(Icons.share));
      await tester.pump();

      // Verify share dialog
      expect(find.text('Share Palette'), findsOneWidget);
    });
  });
}
```

## Documentation Integration

### API Documentation Generation

````dart
/// Generates comprehensive API documentation for palette extraction
class PaletteDocumentationGenerator {
  static Future<String> generateAPIDoc() async {
    final doc = StringBuffer();

    doc.writeln('# Palette Extractor API Reference\n');
    doc.writeln('## Core Methods\n');

    // Auto-generate from code annotations
    final methods = ReflectionHelper.getMethodsWithAnnotation(
      PaletteExtractor,
      APIDocumentation,
    );

    for (final method in methods) {
      doc.writeln('### ${method.name}\n');
      doc.writeln('${method.documentation}\n');
      doc.writeln('```dart');
      doc.writeln(method.signature);
      doc.writeln('```\n');
    }

    return doc.toString();
  }
}
````

This comprehensive integration guide ensures the Palette Extractor functions as a central hub in the Toolspace ecosystem, enabling sophisticated color workflows that span multiple tools and use cases.

---

**Integration Architect**: Alex Rivera, Senior Integration Engineer  
**Last Updated**: October 11, 2025  
**Integration Version**: 2.1.0
