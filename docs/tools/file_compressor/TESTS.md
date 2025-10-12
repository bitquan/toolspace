# File Compressor - Testing Documentation

## Comprehensive Testing Framework

File Compressor implements a multi-layered testing approach ensuring reliability, performance, and quality across diverse file types, compression scenarios, and integration workflows.

### Unit Testing Coverage

#### Core Compression Algorithm Testing

**Compression Engine Tests:**

```dart
// Test compression ratio accuracy across file types
testGroup('Compression Ratio Validation', () {
  test('should achieve target compression ratio for JPEG images', () async {
    final testImage = await TestAssets.loadJpegImage('test_image_1920x1080.jpg');
    final compressionResult = await FileCompressor.compress(
      file: testImage,
      profile: CompressionProfile.imageOptimization(targetRatio: 0.7),
    );

    expect(compressionResult.compressionRatio, isInRange(0.65, 0.75));
    expect(compressionResult.qualityScore, greaterThan(0.9));
  });

  test('should preserve document searchability during PDF compression', () async {
    final testPdf = await TestAssets.loadPdfDocument('searchable_document.pdf');
    final compressionResult = await FileCompressor.compress(
      file: testPdf,
      profile: CompressionProfile.documentArchival(),
    );

    final searchability = await PdfAnalyzer.checkSearchability(
      compressionResult.compressedFile
    );
    expect(searchability.isSearchable, isTrue);
    expect(searchability.textExtractable, isTrue);
  });

  test('should maintain audio quality above threshold', () async {
    final testAudio = await TestAssets.loadAudioFile('test_audio_44khz.wav');
    final compressionResult = await FileCompressor.compress(
      file: testAudio,
      profile: CompressionProfile.audioOptimization(qualityThreshold: 0.95),
    );

    final qualityAnalysis = await AudioQualityAnalyzer.analyze(
      original: testAudio,
      compressed: compressionResult.compressedFile,
    );
    expect(qualityAnalysis.qualityScore, greaterThan(0.95));
  });
});
```

**File Type Detection Tests:**

```dart
testGroup('File Type Detection Accuracy', () {
  test('should correctly identify file types from content', () async {
    final testCases = [
      FileTypeTestCase('image.jpg', FileType.jpeg),
      FileTypeTestCase('document.pdf', FileType.pdf),
      FileTypeTestCase('audio.mp3', FileType.mp3),
      FileTypeTestCase('archive.zip', FileType.zip),
      FileTypeTestCase('video.mp4', FileType.mp4),
    ];

    for (final testCase in testCases) {
      final detectedType = await FileTypeDetector.detectFromContent(
        await TestAssets.loadFile(testCase.fileName)
      );
      expect(detectedType, equals(testCase.expectedType));
    }
  });

  test('should handle corrupted files gracefully', () async {
    final corruptedFile = await TestAssets.loadCorruptedFile('corrupted.jpg');
    final detectionResult = await FileTypeDetector.detectWithValidation(
      corruptedFile
    );

    expect(detectionResult.isValid, isFalse);
    expect(detectionResult.errorType, equals(FileError.corruption));
  });
});
```

#### Quality Assurance Testing

**Quality Metrics Validation:**

```dart
testGroup('Quality Metrics Accuracy', () {
  test('should calculate SSIM correctly for image compression', () async {
    final originalImage = await TestAssets.loadImage('reference_image.png');
    final compressedImage = await TestAssets.loadImage('compressed_image.jpg');

    final ssimScore = await QualityMetrics.calculateSSIM(
      original: originalImage,
      compressed: compressedImage,
    );

    expect(ssimScore, isInRange(0.0, 1.0));
    expect(ssimScore, greaterThan(0.8)); // High quality preservation expected
  });

  test('should measure perceptual quality accurately', () async {
    final qualityTestSuite = await QualityTestSuite.load('perceptual_quality_tests');

    for (final testCase in qualityTestSuite.testCases) {
      final calculatedQuality = await QualityMetrics.calculatePerceptualQuality(
        original: testCase.originalFile,
        compressed: testCase.compressedFile,
      );

      expect(
        calculatedQuality,
        isInRange(
          testCase.expectedQuality - 0.05,
          testCase.expectedQuality + 0.05
        ),
      );
    }
  });
});
```

### Integration Testing Suite

#### Cross-Tool Integration Tests

**Audio Converter Integration:**

```dart
testGroup('Audio Converter Integration', () {
  test('should maintain quality through compression and conversion workflow', () async {
    final originalAudio = await TestAssets.loadAudioFile('test_audio.wav');

    // Step 1: Compress audio
    final compressionResult = await FileCompressor.compress(
      file: originalAudio,
      profile: CompressionProfile.audioOptimization(),
    );

    // Step 2: Convert compressed audio
    final conversionResult = await AudioConverter.convert(
      file: compressionResult.compressedFile,
      targetFormat: AudioFormat.mp3,
      qualitySettings: QualitySettings.high(),
    );

    // Step 3: Validate end-to-end quality
    final endToEndQuality = await AudioQualityAnalyzer.compareFiles(
      original: originalAudio,
      processed: conversionResult.convertedFile,
    );

    expect(endToEndQuality.qualityScore, greaterThan(0.85));
    expect(conversionResult.metadata.compressionProvenance, isNotNull);
  });

  test('should coordinate batch processing efficiently', () async {
    final audioFiles = await TestAssets.loadAudioBatch('audio_batch_100_files');

    final batchResult = await FileCompressor.processBatchWithAudioConverter(
      files: audioFiles,
      compressionProfile: CompressionProfile.audioOptimization(),
      conversionTarget: AudioFormat.aac,
    );

    expect(batchResult.processedFiles.length, equals(audioFiles.length));
    expect(batchResult.failedFiles.length, equals(0));
    expect(batchResult.averageProcessingTime, lessThan(Duration(seconds: 5)));
  });
});
```

**Image Resizer Integration:**

```dart
testGroup('Image Resizer Integration', () {
  test('should optimize resize-compression pipeline', () async {
    final originalImage = await TestAssets.loadLargeImage('high_res_image.tiff');

    final pipelineResult = await FileCompressor.executeImagePipeline(
      image: originalImage,
      resizeTargets: [
        ResizeTarget(width: 1920, height: 1080),
        ResizeTarget(width: 1280, height: 720),
        ResizeTarget(width: 640, height: 480),
      ],
      compressionProfile: CompressionProfile.imageOptimization(),
    );

    expect(pipelineResult.resizedImages.length, equals(3));

    for (final resizedImage in pipelineResult.resizedImages) {
      expect(resizedImage.compressionRatio, greaterThan(0.3));
      expect(resizedImage.qualityScore, greaterThan(0.85));
    }
  });
});
```

#### ShareEnvelope Integration Tests

**Data Sharing Validation:**

```dart
testGroup('ShareEnvelope Integration', () {
  test('should preserve compression metadata in sharing', () async {
    final originalFile = await TestAssets.loadFile('test_document.pdf');
    final compressionResult = await FileCompressor.compress(
      file: originalFile,
      profile: CompressionProfile.documentArchival(),
    );

    final shareEnvelope = await FileCompressor.createShareEnvelope(
      compressionResult: compressionResult,
      targetTool: 'file_merger',
    );

    expect(shareEnvelope.meta['compressionProfile'], isNotNull);
    expect(shareEnvelope.meta['compressionRatio'], isA<double>());
    expect(shareEnvelope.compressionProvenance, isNotNull);
  });

  test('should maintain quality chain across tool transitions', () async {
    final qualityChain = QualityChain.empty();
    final originalFile = await TestAssets.loadFile('test_image.png');

    // Compression step
    final compressionResult = await FileCompressor.compressWithQualityTracking(
      file: originalFile,
      profile: CompressionProfile.imageOptimization(),
      qualityChain: qualityChain,
    );

    // Share with another tool
    final shareEnvelope = await FileCompressor.shareWithQualityChain(
      compressionResult: compressionResult,
      qualityChain: compressionResult.qualityChain,
      targetTool: 'image_resizer',
    );

    expect(shareEnvelope.qualityChain.steps.length, equals(1));
    expect(shareEnvelope.qualityChain.overallQualityScore, greaterThan(0.8));
  });
});
```

### Performance Testing Framework

#### Compression Performance Benchmarks

**Single File Performance Tests:**

```dart
testGroup('Single File Performance', () {
  test('should compress 10MB image within performance threshold', () async {
    final largeImage = await TestAssets.loadFile('large_image_10mb.jpg');
    final stopwatch = Stopwatch()..start();

    final compressionResult = await FileCompressor.compress(
      file: largeImage,
      profile: CompressionProfile.imageOptimization(),
    );

    stopwatch.stop();

    expect(stopwatch.elapsedMilliseconds, lessThan(5000)); // 5 second limit
    expect(compressionResult.compressionRatio, greaterThan(0.5));
  });

  test('should handle large PDF documents efficiently', () async {
    final largePdf = await TestAssets.loadFile('large_document_50mb.pdf');
    final performanceMetrics = await PerformanceProfiler.profile(() async {
      return await FileCompressor.compress(
        file: largePdf,
        profile: CompressionProfile.documentArchival(),
      );
    });

    expect(performanceMetrics.peakMemoryUsage, lessThan(200 * 1024 * 1024)); // 200MB limit
    expect(performanceMetrics.processingTime, lessThan(Duration(seconds: 30)));
  });
});
```

**Batch Processing Performance:**

```dart
testGroup('Batch Processing Performance', () {
  test('should process 100 images within time limit', () async {
    final imageBatch = await TestAssets.loadImageBatch('batch_100_images');
    final stopwatch = Stopwatch()..start();

    final batchResult = await FileCompressor.compressBatch(
      files: imageBatch,
      profile: CompressionProfile.imageOptimization(),
      maxConcurrency: 4,
    );

    stopwatch.stop();

    expect(stopwatch.elapsedMilliseconds, lessThan(60000)); // 1 minute limit
    expect(batchResult.successRate, greaterThan(0.95)); // 95% success rate
    expect(batchResult.averageCompressionRatio, greaterThan(0.4));
  });

  test('should scale compression performance with available cores', () async {
    final testFiles = await TestAssets.loadMixedBatch('mixed_files_50');

    final singleCoreResult = await FileCompressor.compressBatch(
      files: testFiles,
      profile: CompressionProfile.general(),
      maxConcurrency: 1,
    );

    final multiCoreResult = await FileCompressor.compressBatch(
      files: testFiles,
      profile: CompressionProfile.general(),
      maxConcurrency: Platform.numberOfProcessors,
    );

    final speedup = singleCoreResult.totalProcessingTime /
                   multiCoreResult.totalProcessingTime;

    expect(speedup, greaterThan(1.5)); // At least 50% improvement
  });
});
```

### Quality Assurance Testing

#### Compression Quality Validation

**Image Quality Preservation:**

```dart
testGroup('Image Quality Preservation', () {
  test('should maintain visual quality above threshold for various image types', () async {
    final imageTypes = [
      'photograph.jpg',
      'screenshot.png',
      'diagram.svg',
      'drawing.tiff',
    ];

    for (final imageType in imageTypes) {
      final originalImage = await TestAssets.loadImage(imageType);
      final compressionResult = await FileCompressor.compress(
        file: originalImage,
        profile: CompressionProfile.imageOptimization(qualityThreshold: 0.9),
      );

      final qualityAnalysis = await ImageQualityAnalyzer.analyze(
        original: originalImage,
        compressed: compressionResult.compressedFile,
      );

      expect(
        qualityAnalysis.structuralSimilarity,
        greaterThan(0.9),
        reason: 'SSIM score too low for $imageType',
      );

      expect(
        qualityAnalysis.peakSignalToNoiseRatio,
        greaterThan(30.0),
        reason: 'PSNR too low for $imageType',
      );
    }
  });
});
```

**Document Integrity Testing:**

```dart
testGroup('Document Integrity Preservation', () {
  test('should preserve document structure and metadata', () async {
    final testDocument = await TestAssets.loadPdfDocument('complex_document.pdf');

    final compressionResult = await FileCompressor.compress(
      file: testDocument,
      profile: CompressionProfile.documentArchival(),
    );

    final integrityCheck = await DocumentIntegrityChecker.verify(
      original: testDocument,
      compressed: compressionResult.compressedFile,
    );

    expect(integrityCheck.metadataPreserved, isTrue);
    expect(integrityCheck.structureIntact, isTrue);
    expect(integrityCheck.accessibilityMaintained, isTrue);
    expect(integrityCheck.searchabilityPreserved, isTrue);
  });

  test('should handle encrypted documents appropriately', () async {
    final encryptedPdf = await TestAssets.loadEncryptedPdf('encrypted_document.pdf');

    final compressionResult = await FileCompressor.compress(
      file: encryptedPdf,
      profile: CompressionProfile.documentArchival(),
    );

    expect(compressionResult.status, equals(CompressionStatus.success));
    expect(compressionResult.encryptionPreserved, isTrue);

    // Verify encryption still works
    final decryptionTest = await PdfDecryptor.testDecryption(
      compressionResult.compressedFile,
      password: 'test_password',
    );
    expect(decryptionTest.canDecrypt, isTrue);
  });
});
```

### Error Handling and Edge Case Testing

#### Failure Scenario Testing

**Corrupted File Handling:**

```dart
testGroup('Corrupted File Handling', () {
  test('should detect and handle corrupted files gracefully', () async {
    final corruptedFiles = await TestAssets.loadCorruptedFiles([
      'corrupted_image.jpg',
      'truncated_audio.mp3',
      'malformed_pdf.pdf',
    ]);

    for (final corruptedFile in corruptedFiles) {
      final compressionResult = await FileCompressor.compress(
        file: corruptedFile,
        profile: CompressionProfile.general(),
      );

      expect(compressionResult.status, equals(CompressionStatus.failed));
      expect(compressionResult.error, isA<FileCorruptionError>());
      expect(compressionResult.error.isRecoverable, isA<bool>());
    }
  });
});
```

**Resource Limitation Testing:**

```dart
testGroup('Resource Limitation Handling', () {
  test('should handle low memory conditions gracefully', () async {
    final largeFile = await TestAssets.loadFile('very_large_file_1gb.zip');

    // Simulate low memory condition
    await MemoryLimiter.setLimit(100 * 1024 * 1024); // 100MB limit

    final compressionResult = await FileCompressor.compress(
      file: largeFile,
      profile: CompressionProfile.general(),
    );

    // Should either succeed with streaming or fail gracefully
    if (compressionResult.status == CompressionStatus.success) {
      expect(compressionResult.processingMethod, equals(ProcessingMethod.streaming));
    } else {
      expect(compressionResult.error, isA<InsufficientMemoryError>());
    }
  });

  test('should handle disk space limitations', () async {
    final testFile = await TestAssets.loadFile('test_file.jpg');

    // Simulate low disk space
    await DiskSpaceSimulator.setAvailableSpace(1024); // 1KB available

    final compressionResult = await FileCompressor.compress(
      file: testFile,
      profile: CompressionProfile.imageOptimization(),
    );

    expect(compressionResult.status, equals(CompressionStatus.failed));
    expect(compressionResult.error, isA<InsufficientStorageError>());
  });
});
```

### Regression Testing Suite

#### Version Compatibility Testing

**Backward Compatibility:**

```dart
testGroup('Backward Compatibility', () {
  test('should handle files compressed with previous versions', () async {
    final legacyCompressedFiles = await TestAssets.loadLegacyFiles([
      'compressed_v1.0.jpg',
      'compressed_v1.1.pdf',
      'compressed_v1.2.mp3',
    ]);

    for (final legacyFile in legacyCompressedFiles) {
      final decompressionResult = await FileCompressor.decompress(legacyFile);
      expect(decompressionResult.status, equals(DecompressionStatus.success));

      // Verify the decompressed file is valid
      final validationResult = await FileValidator.validate(
        decompressionResult.decompressedFile
      );
      expect(validationResult.isValid, isTrue);
    }
  });
});
```

**API Stability Testing:**

```dart
testGroup('API Stability', () {
  test('should maintain API contract across updates', () async {
    final apiContract = await ApiContractLoader.load('file_compressor_v2.0.json');
    final currentApi = await ApiIntrospector.analyze(FileCompressor);

    final compatibilityCheck = await ApiCompatibilityChecker.check(
      contract: apiContract,
      implementation: currentApi,
    );

    expect(compatibilityCheck.isBackwardCompatible, isTrue);
    expect(compatibilityCheck.breakingChanges, isEmpty);
  });
});
```

### Automated Testing Pipeline

#### Continuous Integration Tests

**CI/CD Pipeline Integration:**

```yaml
# Example CI configuration
test_suites:
  unit_tests:
    - compression_algorithm_tests
    - quality_metrics_tests
    - file_type_detection_tests

  integration_tests:
    - cross_tool_integration_tests
    - shareenvelope_integration_tests

  performance_tests:
    - single_file_benchmarks
    - batch_processing_benchmarks

  quality_assurance:
    - image_quality_preservation
    - document_integrity_tests

  regression_tests:
    - backward_compatibility_tests
    - api_stability_tests

coverage_requirements:
  minimum_coverage: 95%
  critical_paths_coverage: 100%

performance_thresholds:
  max_compression_time_10mb: 5000ms
  max_batch_processing_100_files: 60000ms
  min_success_rate: 95%
```

This comprehensive testing framework ensures File Compressor maintains high quality, performance, and reliability standards across all compression scenarios and integration workflows.
