# Image Resizer - Comprehensive Testing Documentation

**Last Updated**: December 29, 2024  
**Test Suite Version**: 1.0  
**Coverage Target**: 95%+ for critical batch processing paths

## Test Strategy Overview

Image Resizer testing encompasses comprehensive validation of batch processing workflows, Sharp library integration, Pro plan billing enforcement, and cross-tool communication patterns. The test strategy emphasizes quality assurance for professional-grade image processing, performance validation under load, and robust error handling for production deployment confidence.

### Testing Philosophy

- **Quality Assurance First**: Comprehensive validation of image processing quality and batch operations
- **Performance Excellence**: Load testing and resource optimization validation
- **Integration Reliability**: Cross-tool communication and platform service integration testing
- **Professional Grade**: Enterprise-level quality assurance suitable for production workflows

## Test Coverage Matrix

### Core Functionality Testing

#### Unit Tests - Image Processing Engine

**Location**: `test/tools/image_resizer/`

```dart
// Test file: test/tools/image_resizer/image_processor_test.dart
group('Image Processing Engine', () {
  late ImageProcessor processor;
  late MockSharpService mockSharp;

  setUp(() {
    mockSharp = MockSharpService();
    processor = ImageProcessor(sharpService: mockSharp);
  });

  group('Single Image Processing', () {
    testWidgets('should resize image to exact dimensions', (tester) async {
      // Arrange
      final testImage = await loadTestImage('sample_1920x1080.jpg');
      final settings = ResizeSettings(width: 1280, height: 720);

      when(mockSharp.resize(any, any)).thenAnswer((_) async =>
        MockProcessedImage(width: 1280, height: 720));

      // Act
      final result = await processor.processImage(testImage, settings);

      // Assert
      expect(result.dimensions.width, equals(1280));
      expect(result.dimensions.height, equals(720));
      expect(result.processingSuccess, isTrue);
      verify(mockSharp.resize(testImage, settings)).called(1);
    });

    testWidgets('should maintain aspect ratio when requested', (tester) async {
      final testImage = await loadTestImage('sample_1920x1080.jpg');
      final settings = ResizeSettings(
        width: 1280,
        preserveAspectRatio: true
      );

      final result = await processor.processImage(testImage, settings);

      expect(result.dimensions.width, equals(1280));
      expect(result.dimensions.height, equals(720)); // Calculated from aspect ratio
      expect(result.aspectRatioPreserved, isTrue);
    });

    testWidgets('should convert image format correctly', (tester) async {
      final testImage = await loadTestImage('sample.png');
      final settings = ResizeSettings(outputFormat: ImageFormat.webp);

      final result = await processor.processImage(testImage, settings);

      expect(result.format, equals(ImageFormat.webp));
      expect(result.fileSize, lessThan(testImage.fileSize)); // WebP compression
    });
  });

  group('Batch Processing', () {
    testWidgets('should process multiple images in parallel', (tester) async {
      final testImages = await loadTestImageBatch(5);
      final settings = ResizeSettings(width: 800, height: 600);

      final startTime = DateTime.now();
      final results = await processor.processBatch(testImages, settings);
      final endTime = DateTime.now();

      expect(results.length, equals(5));
      expect(results.every((r) => r.processingSuccess), isTrue);
      // Batch processing should be faster than sequential
      expect(endTime.difference(startTime).inMilliseconds, lessThan(5000));
    });

    testWidgets('should handle batch processing errors gracefully', (tester) async {
      final mixedBatch = [
        await loadTestImage('valid_image.jpg'),
        await loadCorruptedImage('corrupted.jpg'),
        await loadTestImage('another_valid.png'),
      ];

      final results = await processor.processBatch(mixedBatch, ResizeSettings());

      expect(results.length, equals(3));
      expect(results[0].processingSuccess, isTrue);
      expect(results[1].processingSuccess, isFalse);
      expect(results[1].error, isNotNull);
      expect(results[2].processingSuccess, isTrue);
    });

    testWidgets('should respect batch size limits', (tester) async {
      final largeBatch = await loadTestImageBatch(15); // Exceeds limit of 10

      expect(
        () => processor.processBatch(largeBatch, ResizeSettings()),
        throwsA(isA<BatchSizeExceededException>())
      );
    });
  });

  group('Quality Optimization', () {
    testWidgets('should apply quality settings correctly', (tester) async {
      final testImage = await loadTestImage('high_quality.jpg');
      final settings = ResizeSettings(quality: 50);

      final result = await processor.processImage(testImage, settings);

      expect(result.quality, equals(50));
      expect(result.fileSize, lessThan(testImage.fileSize * 0.7));
    });

    testWidgets('should optimize file size while maintaining visual quality', (tester) async {
      final testImage = await loadTestImage('large_photo.jpg');
      final settings = ResizeSettings(
        width: 1920,
        height: 1080,
        quality: 85,
        optimizeForWeb: true
      );

      final result = await processor.processImage(testImage, settings);

      expect(result.compressionRatio, greaterThan(0.6));
      expect(result.visualQualityScore, greaterThan(0.85));
    });
  });
});
```

#### Integration Tests - Platform Services

**Location**: `test/tools/image_resizer/integration/`

```dart
// Test file: test/tools/image_resizer/integration/platform_integration_test.dart
group('Platform Integration', () {
  late ImageResizerService service;
  late MockFirebaseStorage mockStorage;
  late MockBillingService mockBilling;

  setUp(() {
    mockStorage = MockFirebaseStorage();
    mockBilling = MockBillingService();
    service = ImageResizerService(
      storage: mockStorage,
      billing: mockBilling
    );
  });

  group('Storage Integration', () {
    testWidgets('should upload batch to temporary storage', (tester) async {
      final batch = await createTestImageBatch(3);

      when(mockStorage.uploadBatch(any, any)).thenAnswer((_) async =>
        UploadBatchResult(
          uploadedFiles: batch.map((f) => 'temp/${f.name}').toList(),
          totalSize: batch.fold(0, (sum, f) => sum + f.size)
        ));

      final result = await service.uploadBatch(batch);

      expect(result.success, isTrue);
      expect(result.uploadedFiles.length, equals(3));
      verify(mockStorage.uploadBatch(batch, any)).called(1);
    });

    testWidgets('should generate secure download URLs', (tester) async {
      final processedFiles = ['processed1.jpg', 'processed2.png'];

      when(mockStorage.generateDownloadUrls(any, any)).thenAnswer((_) async =>
        processedFiles.map((f) => DownloadUrl(
          url: 'https://storage.googleapis.com/temp/$f?token=secure_token',
          expiresAt: DateTime.now().add(Duration(days: 7))
        )).toList());

      final urls = await service.generateDownloadUrls(processedFiles);

      expect(urls.length, equals(2));
      expect(urls.every((url) => url.url.contains('secure_token')), isTrue);
      expect(urls.every((url) => url.expiresAt.isAfter(DateTime.now())), isTrue);
    });

    testWidgets('should cleanup expired files automatically', (tester) async {
      when(mockStorage.cleanupExpiredFiles()).thenAnswer((_) async =>
        CleanupResult(deletedFiles: 15, freedSpace: 2.5 * 1024 * 1024));

      final result = await service.performCleanup();

      expect(result.deletedFiles, greaterThan(0));
      expect(result.freedSpace, greaterThan(0));
    });
  });

  group('Billing Integration', () {
    testWidgets('should enforce Pro plan requirements', (tester) async {
      final freeUser = await createTestUser(plan: SubscriptionPlan.free);
      final batch = await createTestImageBatch(5);

      when(mockBilling.getUserPlan(freeUser.id)).thenAnswer((_) async =>
        SubscriptionPlan.free);

      expect(
        () => service.processBatch(batch, userId: freeUser.id),
        throwsA(isA<InsufficientPlanException>())
      );
    });

    testWidgets('should track usage for billing', (tester) async {
      final proUser = await createTestUser(plan: SubscriptionPlan.pro);
      final batch = await createTestImageBatch(3);

      when(mockBilling.getUserPlan(proUser.id)).thenAnswer((_) async =>
        SubscriptionPlan.pro);

      await service.processBatch(batch, userId: proUser.id);

      verify(mockBilling.trackUsage(
        userId: proUser.id,
        feature: 'image_resizer',
        quantity: 3,
        metadata: any
      )).called(1);
    });

    testWidgets('should enforce monthly usage limits', (tester) async {
      final proUser = await createTestUser(plan: SubscriptionPlan.pro);

      when(mockBilling.getMonthlyUsage(proUser.id, 'image_resizer'))
        .thenAnswer((_) async => 950); // Near limit of 1000

      final largeBatch = await createTestImageBatch(10);

      expect(
        () => service.processBatch(largeBatch, userId: proUser.id),
        throwsA(isA<UsageLimitExceededException>())
      );
    });
  });
});
```

### Widget Testing

#### UI Component Tests

**Location**: `test/tools/image_resizer/widgets/`

```dart
// Test file: test/tools/image_resizer/widgets/image_upload_zone_test.dart
group('Image Upload Zone Widget', () {
  testWidgets('should display empty state correctly', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: ImageUploadZone(
        onFilesSelected: (files) {},
        maxBatchSize: 10,
      )
    ));

    expect(find.text('Drop images here or click to browse'), findsOneWidget);
    expect(find.text('Batch processing: Up to 10'), findsOneWidget);
    expect(find.text('Max size: 20 MB per image'), findsOneWidget);
    expect(find.byIcon(Icons.photo_size_select_large), findsOneWidget);
  });

  testWidgets('should handle file selection', (tester) async {
    final selectedFiles = <File>[];

    await tester.pumpWidget(MaterialApp(
      home: ImageUploadZone(
        onFilesSelected: (files) => selectedFiles.addAll(files),
        maxBatchSize: 10,
      )
    ));

    // Simulate file selection
    final testFiles = await createTestFiles(['image1.jpg', 'image2.png']);
    await tester.simulateFileSelection(testFiles);

    expect(selectedFiles.length, equals(2));
    expect(selectedFiles.map((f) => f.name), containsAll(['image1.jpg', 'image2.png']));
  });

  testWidgets('should validate file types and sizes', (tester) async {
    final validFiles = <File>[];
    final errors = <String>[];

    await tester.pumpWidget(MaterialApp(
      home: ImageUploadZone(
        onFilesSelected: (files) => validFiles.addAll(files),
        onValidationErrors: (errorList) => errors.addAll(errorList),
        maxBatchSize: 10,
      )
    ));

    final mixedFiles = [
      await createTestImage('valid.jpg', sizeKB: 1024),
      await createTestFile('document.pdf', sizeKB: 500),
      await createTestImage('too_large.png', sizeMB: 25),
    ];

    await tester.simulateFileSelection(mixedFiles);

    expect(validFiles.length, equals(1));
    expect(validFiles.first.name, equals('valid.jpg'));
    expect(errors.length, equals(2));
    expect(errors, contains(containsString('not an image file')));
    expect(errors, contains(containsString('exceeds 20 MB limit')));
  });

  testWidgets('should show drag and drop visual feedback', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: ImageUploadZone(onFilesSelected: (files) {})
    ));

    // Simulate drag enter
    await tester.simulateDragEnter();
    await tester.pump();

    expect(find.byType(DragActiveIndicator), findsOneWidget);
    expect(tester.widget<Container>(find.byType(Container).first).decoration,
           isA<BoxDecoration>().having((d) => d.border?.top.color, 'border color',
               equals(Colors.blue)));

    // Simulate drag exit
    await tester.simulateDragExit();
    await tester.pump();

    expect(find.byType(DragActiveIndicator), findsNothing);
  });
});

// Test file: test/tools/image_resizer/widgets/image_list_test.dart
group('Image List Widget', () {
  testWidgets('should display batch of images with thumbnails', (tester) async {
    final testImages = await createTestImageBatch(5);

    await tester.pumpWidget(MaterialApp(
      home: ImageList(
        images: testImages,
        onImageRemoved: (index) {},
        onImageReordered: (oldIndex, newIndex) {},
      )
    ));

    expect(find.byType(ImageListItem), findsNWidgets(5));
    expect(find.byType(Image), findsNWidgets(5)); // Thumbnails

    for (var i = 0; i < testImages.length; i++) {
      expect(find.text(testImages[i].name), findsOneWidget);
      expect(find.text('${(testImages[i].size / 1024 / 1024).toStringAsFixed(1)} MB'),
             findsOneWidget);
    }
  });

  testWidgets('should handle image removal', (tester) async {
    final testImages = await createTestImageBatch(3);
    var removedIndex = -1;

    await tester.pumpWidget(MaterialApp(
      home: ImageList(
        images: testImages,
        onImageRemoved: (index) => removedIndex = index,
      )
    ));

    // Tap remove button on second image
    await tester.tap(find.byIcon(Icons.close).at(1));

    expect(removedIndex, equals(1));
  });

  testWidgets('should support drag and drop reordering', (tester) async {
    final testImages = await createTestImageBatch(3);
    var reorderCall = <int>[];

    await tester.pumpWidget(MaterialApp(
      home: ImageList(
        images: testImages,
        onImageReordered: (oldIndex, newIndex) {
          reorderCall = [oldIndex, newIndex];
        },
      )
    ));

    // Simulate drag from index 0 to index 2
    await tester.drag(find.byType(ImageListItem).first, Offset(0, 200));
    await tester.pumpAndSettle();

    expect(reorderCall, equals([0, 2]));
  });
});

// Test file: test/tools/image_resizer/widgets/resize_settings_test.dart
group('Resize Settings Widget', () {
  testWidgets('should display preset options', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: ResizeSettings(
        onSettingsChanged: (settings) {},
      )
    ));

    expect(find.text('Thumbnail'), findsOneWidget);
    expect(find.text('Small'), findsOneWidget);
    expect(find.text('Medium'), findsOneWidget);
    expect(find.text('Large'), findsOneWidget);
    expect(find.text('Custom'), findsOneWidget);
  });

  testWidgets('should handle preset selection', (tester) async {
    ResizeSettings? selectedSettings;

    await tester.pumpWidget(MaterialApp(
      home: ResizeSettings(
        onSettingsChanged: (settings) => selectedSettings = settings,
      )
    ));

    await tester.tap(find.text('Medium'));
    await tester.pump();

    expect(selectedSettings?.width, equals(1280));
    expect(selectedSettings?.height, equals(720));
    expect(selectedSettings?.preset, equals(ResizePreset.medium));
  });

  testWidgets('should enable custom dimensions input', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: ResizeSettings(onSettingsChanged: (settings) {})
    ));

    // Select custom preset
    await tester.tap(find.text('Custom'));
    await tester.pump();

    expect(find.byType(TextField), findsNWidgets(2)); // Width and height inputs
    expect(find.text('Width'), findsOneWidget);
    expect(find.text('Height'), findsOneWidget);
    expect(find.byType(Checkbox), findsOneWidget); // Preserve aspect ratio
  });

  testWidgets('should validate custom dimension inputs', (tester) async {
    ResizeSettings? selectedSettings;

    await tester.pumpWidget(MaterialApp(
      home: ResizeSettings(
        onSettingsChanged: (settings) => selectedSettings = settings,
      )
    ));

    await tester.tap(find.text('Custom'));
    await tester.pump();

    // Enter invalid dimensions
    await tester.enterText(find.byType(TextField).first, '0');
    await tester.enterText(find.byType(TextField).last, '10000');

    expect(find.text('Width must be between 1 and 4096'), findsOneWidget);
    expect(find.text('Height must be between 1 and 4096'), findsOneWidget);
  });
});
```

### Performance Testing

#### Load Testing Framework

**Location**: `test/tools/image_resizer/performance/`

```dart
// Test file: test/tools/image_resizer/performance/load_test.dart
group('Performance Testing', () {
  late ImageResizerService service;
  late PerformanceProfiler profiler;

  setUp(() {
    service = ImageResizerService();
    profiler = PerformanceProfiler();
  });

  group('Batch Processing Performance', () {
    testWidgets('should process maximum batch within time limits', (tester) async {
      final maxBatch = await createTestImageBatch(10, sizeMB: 5); // 50MB total

      profiler.startMeasurement('max_batch_processing');
      final result = await service.processBatch(maxBatch, ResizeSettings(
        width: 1920,
        height: 1080,
        quality: 85
      ));
      final measurement = profiler.stopMeasurement('max_batch_processing');

      expect(result.processedImages.length, equals(10));
      expect(measurement.durationMs, lessThan(30000)); // Under 30 seconds
      expect(measurement.peakMemoryMB, lessThan(500)); // Under 500MB
    });

    testWidgets('should handle concurrent batch processing', (tester) async {
      final batches = await Future.wait([
        createTestImageBatch(5),
        createTestImageBatch(5),
        createTestImageBatch(5),
      ]);

      profiler.startMeasurement('concurrent_processing');
      final results = await Future.wait([
        service.processBatch(batches[0], ResizeSettings(width: 800)),
        service.processBatch(batches[1], ResizeSettings(width: 1200)),
        service.processBatch(batches[2], ResizeSettings(width: 1600)),
      ]);
      final measurement = profiler.stopMeasurement('concurrent_processing');

      expect(results.every((r) => r.processedImages.length == 5), isTrue);
      expect(measurement.durationMs, lessThan(45000)); // Concurrent should be faster
      expect(measurement.resourceUtilization, lessThan(0.8)); // Under 80% utilization
    });

    testWidgets('should maintain quality under load', (tester) async {
      final largeBatch = await createTestImageBatch(8, sizeMB: 10); // 80MB total

      final result = await service.processBatch(largeBatch, ResizeSettings(
        width: 2048,
        height: 1536,
        quality: 95
      ));

      for (final image in result.processedImages) {
        expect(image.qualityScore, greaterThan(0.9));
        expect(image.processingTime, lessThan(5000)); // Under 5 seconds per image
        expect(image.compressionEfficiency, greaterThan(0.7));
      }
    });
  });

  group('Memory Management', () {
    testWidgets('should not leak memory during batch processing', (tester) async {
      final initialMemory = await getMemoryUsage();

      // Process multiple batches sequentially
      for (int i = 0; i < 5; i++) {
        final batch = await createTestImageBatch(6, sizeMB: 3);
        await service.processBatch(batch, ResizeSettings());

        // Force garbage collection
        await triggerGarbageCollection();
        await Future.delayed(Duration(milliseconds: 100));
      }

      final finalMemory = await getMemoryUsage();
      final memoryIncrease = finalMemory - initialMemory;

      expect(memoryIncrease, lessThan(50 * 1024 * 1024)); // Less than 50MB increase
    });

    testWidgets('should cleanup temporary files efficiently', (tester) async {
      final batch = await createTestImageBatch(10);

      final tempFilesBefore = await getTempFileCount();
      await service.processBatch(batch, ResizeSettings());
      final tempFilesDuring = await getTempFileCount();

      // Wait for cleanup
      await Future.delayed(Duration(seconds: 2));
      final tempFilesAfter = await getTempFileCount();

      expect(tempFilesDuring, greaterThan(tempFilesBefore));
      expect(tempFilesAfter, equals(tempFilesBefore)); // Should return to baseline
    });
  });
});
```

### Cross-Tool Integration Tests

#### ShareBus Communication Testing

**Location**: `test/tools/image_resizer/integration/cross_tool_test.dart`

```dart
group('Cross-Tool Integration', () {
  late ShareBus shareBus;
  late ImageResizerService imageResizer;
  late FileMergerService fileMerger;

  setUp(() {
    shareBus = ShareBus.instance;
    imageResizer = ImageResizerService();
    fileMerger = FileMergerService();

    // Setup message listeners
    shareBus.listen(ShareMessageType.imageProcessingComplete,
                   fileMerger.handleImageBatch);
  });

  testWidgets('should broadcast processed images to File Merger', (tester) async {
    final testImages = await createTestImageBatch(3);
    var receivedBatch = false;

    // Listen for File Merger to receive the batch
    fileMerger.onImageBatchReceived = (batch) {
      receivedBatch = true;
      expect(batch.images.length, equals(3));
      expect(batch.settings.width, equals(1200));
    };

    // Process images in Image Resizer
    await imageResizer.processBatch(testImages, ResizeSettings(width: 1200));

    // Wait for async message propagation
    await Future.delayed(Duration(milliseconds: 100));

    expect(receivedBatch, isTrue);
  });

  testWidgets('should handle PDF optimization workflow', (tester) async {
    final highResImages = await createTestImageBatch(5,
        width: 4000, height: 3000, sizeMB: 8);

    // Image Resizer optimizes for PDF inclusion
    final optimizedBatch = await imageResizer.optimizeForPDF(highResImages);

    expect(optimizedBatch.images.every((img) =>
        img.dimensions.width <= 2000 && img.fileSize < 2 * 1024 * 1024), isTrue);

    // File Merger receives optimized images
    final pdfResult = await fileMerger.createPDFFromImages(optimizedBatch);

    expect(pdfResult.success, isTrue);
    expect(pdfResult.fileSize, lessThan(20 * 1024 * 1024)); // Under 20MB
  });

  testWidgets('should integrate with Text Tools for OCR preprocessing', (tester) async {
    final documentImages = await createTestDocumentImages(3);

    // Optimize images for OCR
    final ocrBatch = await imageResizer.optimizeForOCR(documentImages);

    expect(ocrBatch.images.every((img) =>
        img.format == ImageFormat.png && img.quality >= 95), isTrue);

    // Text Tools receives optimized images for OCR
    // (Would test TextToolsService.processImageBatch in actual integration)
  });
});
```

### Security Testing

#### Security Validation Tests

**Location**: `test/tools/image_resizer/security/`

```dart
group('Security Testing', () {
  late ImageResizerService service;
  late SecurityValidator validator;

  setUp(() {
    service = ImageResizerService();
    validator = SecurityValidator();
  });

  group('File Validation Security', () {
    testWidgets('should reject malicious file uploads', (tester) async {
      final maliciousFiles = [
        await createMaliciousFile('script.jpg'), // JavaScript in EXIF
        await createMaliciousFile('exploit.png'), // Buffer overflow attempt
        await createFakeImageFile('virus.exe'), // Executable disguised as image
      ];

      for (final file in maliciousFiles) {
        expect(
          () => service.validateFile(file),
          throwsA(isA<SecurityViolationException>())
        );
      }
    });

    testWidgets('should sanitize image metadata', (tester) async {
      final imageWithMetadata = await createImageWithEXIF({
        'GPS': '40.7128,-74.0060', // Location data
        'Comment': '<script>alert("xss")</script>', // Potential XSS
        'Software': 'PhotoEditor Pro 2024',
      });

      final result = await service.processImage(imageWithMetadata, ResizeSettings());

      expect(result.metadata.containsKey('GPS'), isFalse);
      expect(result.metadata['Comment'], isNot(contains('<script>')));
      expect(result.metadata['Software'], contains('Toolspace')); // Replaced
    });

    testWidgets('should enforce file size limits strictly', (tester) async {
      final oversizedFile = await createTestImage('huge.jpg', sizeMB: 25);

      expect(
        () => service.validateFile(oversizedFile),
        throwsA(isA<FileSizeExceededException>())
      );
    });
  });

  group('Access Control', () {
    testWidgets('should enforce Pro plan requirements', (tester) async {
      final freeUser = await createTestUser(plan: SubscriptionPlan.free);
      final batch = await createTestImageBatch(5);

      expect(
        () => service.processBatch(batch, userId: freeUser.id),
        throwsA(isA<InsufficientPlanException>())
      );
    });

    testWidgets('should validate download URL access', (tester) async {
      final proUser = await createTestUser(plan: SubscriptionPlan.pro);
      final otherUser = await createTestUser(plan: SubscriptionPlan.pro);

      // Process batch for first user
      final batch = await createTestImageBatch(3);
      final result = await service.processBatch(batch, userId: proUser.id);

      // Try to access URLs with different user
      for (final url in result.downloadUrls) {
        expect(
          () => service.validateDownloadAccess(url, otherUser.id),
          throwsA(isA<UnauthorizedAccessException>())
        );
      }
    });
  });

  group('Data Protection', () {
    testWidgets('should encrypt temporary files', (tester) async {
      final batch = await createTestImageBatch(3);

      final uploadResult = await service.uploadBatch(batch);

      // Check that temporary files are encrypted
      for (final tempPath in uploadResult.tempPaths) {
        final tempFile = File(tempPath);
        final bytes = await tempFile.readAsBytes();

        // Should not contain recognizable image headers
        expect(bytes.take(4).toList(), isNot(equals([0xFF, 0xD8, 0xFF, 0xE0]))); // JPEG
        expect(bytes.take(8).toList(), isNot(contains([0x89, 0x50, 0x4E, 0x47]))); // PNG
      }
    });

    testWidgets('should cleanup sensitive data after processing', (tester) async {
      final batch = await createTestImageBatch(3);

      await service.processBatch(batch, ResizeSettings());

      // Wait for cleanup
      await Future.delayed(Duration(seconds: 1));

      // Check that temporary files are removed
      final tempDir = Directory('/tmp/image_resizer');
      if (tempDir.existsSync()) {
        expect(tempDir.listSync().length, equals(0));
      }
    });
  });
});
```

## Test Automation

### Continuous Integration Pipeline

#### Automated Test Execution

**Configuration**: `.github/workflows/image_resizer_tests.yml`

```yaml
name: Image Resizer Test Suite

on:
  push:
    paths:
      - "lib/tools/image_resizer/**"
      - "functions/src/tools/image_resizer/**"
      - "test/tools/image_resizer/**"

jobs:
  unit_tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: "3.16.0"

      - name: Install dependencies
        run: flutter pub get

      - name: Run unit tests
        run: flutter test test/tools/image_resizer/unit/ --coverage

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: coverage/lcov.info

  integration_tests:
    runs-on: ubuntu-latest
    services:
      redis:
        image: redis
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

    steps:
      - uses: actions/checkout@v3
      - name: Setup test environment
        run: |
          docker-compose -f docker-compose.test.yml up -d
          npm install -g firebase-tools

      - name: Run integration tests
        run: flutter test test/tools/image_resizer/integration/

  performance_tests:
    runs-on: ubuntu-latest
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'

    steps:
      - uses: actions/checkout@v3
      - name: Run performance benchmarks
        run: |
          flutter test test/tools/image_resizer/performance/
          python scripts/analyze_performance.py

      - name: Comment performance results
        uses: actions/github-script@v6
        with:
          script: |
            const fs = require('fs');
            const results = fs.readFileSync('performance_results.json', 'utf8');
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: `## Performance Test Results\n\`\`\`json\n${results}\n\`\`\``
            });
```

#### Quality Gates

**Performance Thresholds**:

- Batch processing (10 images): < 30 seconds
- Memory usage: < 500MB peak
- Individual image processing: < 5 seconds
- Concurrent batch handling: 3 batches simultaneously

**Coverage Requirements**:

- Unit test coverage: > 95%
- Integration test coverage: > 90%
- Critical path coverage: 100%
- Security test coverage: > 98%

### Test Data Management

#### Test Asset Generation

**Location**: `test/tools/image_resizer/helpers/test_data_generator.dart`

```dart
class TestDataGenerator {
  // Generate test images with specific properties
  static Future<File> createTestImage({
    required String filename,
    int width = 1920,
    int height = 1080,
    ImageFormat format = ImageFormat.jpeg,
    int sizeMB = 2,
    Map<String, String>? metadata,
  }) async {
    final bytes = await generateImageBytes(
      width: width,
      height: height,
      format: format,
      targetSize: sizeMB * 1024 * 1024,
      metadata: metadata ?? {},
    );

    final tempFile = File('${Directory.systemTemp.path}/$filename');
    await tempFile.writeAsBytes(bytes);
    return tempFile;
  }

  // Create batch of test images with variety
  static Future<List<File>> createTestImageBatch(
    int count, {
    double sizeMB = 2.0,
    bool includeVariety = true,
  }) async {
    final images = <File>[];

    for (int i = 0; i < count; i++) {
      final format = includeVariety
        ? ImageFormat.values[i % ImageFormat.values.length]
        : ImageFormat.jpeg;

      final dimensions = includeVariety
        ? _getVariedDimensions(i)
        : (width: 1920, height: 1080);

      final image = await createTestImage(
        filename: 'test_image_$i.${format.extension}',
        width: dimensions.width,
        height: dimensions.height,
        format: format,
        sizeMB: sizeMB.round(),
      );

      images.add(image);
    }

    return images;
  }

  // Generate corrupted files for error testing
  static Future<File> createCorruptedImage(String filename) async {
    final randomBytes = List.generate(1024, (index) => Random().nextInt(256));
    final tempFile = File('${Directory.systemTemp.path}/$filename');
    await tempFile.writeAsBytes(randomBytes);
    return tempFile;
  }

  // Create realistic document images for OCR testing
  static Future<List<File>> createTestDocumentImages(int count) async {
    final documents = <File>[];

    for (int i = 0; i < count; i++) {
      final document = await createDocumentImage(
        text: 'Sample document text for OCR testing page ${i + 1}',
        filename: 'document_$i.png',
      );
      documents.add(document);
    }

    return documents;
  }
}
```

#### Mock Service Implementation

**Location**: `test/tools/image_resizer/mocks/`

```dart
// Mock Sharp service for isolated testing
class MockSharpService extends Mock implements SharpService {
  @override
  Future<ProcessedImage> resize(File input, ResizeSettings settings) async {
    // Simulate processing time
    await Future.delayed(Duration(milliseconds: 100));

    return ProcessedImage(
      filename: input.path,
      width: settings.width ?? 1920,
      height: settings.height ?? 1080,
      format: settings.outputFormat ?? ImageFormat.jpeg,
      fileSize: (input.lengthSync() * 0.8).round(), // Simulate compression
      processingTime: 100,
      quality: settings.quality ?? 85,
    );
  }
}

// Mock Firebase Storage for integration testing
class MockFirebaseStorage extends Mock implements FirebaseStorage {
  final Map<String, Uint8List> _storage = {};

  @override
  Future<UploadResult> uploadFile(File file, String path) async {
    _storage[path] = await file.readAsBytes();
    return UploadResult(
      path: path,
      downloadUrl: 'https://mock-storage.com/$path',
      size: file.lengthSync(),
    );
  }

  @override
  Future<void> deleteFile(String path) async {
    _storage.remove(path);
  }
}
```

---

**Test Execution Schedule**: Automated on every commit with full suite on release  
**Performance Monitoring**: Continuous benchmarking with monthly regression analysis  
**Security Testing**: Weekly automated security scans with quarterly penetration testing  
**Integration Validation**: Daily cross-tool integration testing with error monitoring
