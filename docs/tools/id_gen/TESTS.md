# ID Generator - Testing Documentation

## Comprehensive Testing Framework

ID Generator implements a rigorous testing approach ensuring cryptographic security, uniqueness guarantees, performance standards, and compliance across all identifier generation scenarios and integration workflows.

### Unit Testing Coverage

#### Core ID Generation Algorithm Testing

**UUID v4 Generation Tests:**

```dart
testGroup('UUID v4 Generation Validation', () {
  test('should generate RFC 4122 compliant UUID v4', () async {
    final uuid = await IdGenerator.generateUuid4();

    // Test format compliance
    expect(uuid.length, equals(36));
    expect(uuid.split('-').length, equals(5));
    expect(uuid[14], equals('4')); // Version bits
    expect(['8', '9', 'a', 'b'].contains(uuid[19].toLowerCase()), isTrue); // Variant bits

    // Test uniqueness
    final secondUuid = await IdGenerator.generateUuid4();
    expect(uuid, isNot(equals(secondUuid)));
  });

  test('should achieve proper randomness distribution', () async {
    final uuids = await IdGenerator.generateBatch(
      type: IdType.uuidV4,
      count: 10000,
    );

    // Test character distribution
    final characterFrequency = <String, int>{};
    for (final uuid in uuids.generatedIds) {
      for (final char in uuid.replaceAll('-', '').split('')) {
        characterFrequency[char] = (characterFrequency[char] ?? 0) + 1;
      }
    }

    // Check for reasonable distribution (not perfectly uniform due to version/variant bits)
    for (final hexChar in '0123456789abcdef'.split('')) {
      final frequency = characterFrequency[hexChar] ?? 0;
      expect(frequency, greaterThan(15000)); // Reasonable lower bound
      expect(frequency, lessThan(25000)); // Reasonable upper bound
    }
  });

  test('should maintain cryptographic security properties', () async {
    final uuids = await IdGenerator.generateBatch(
      type: IdType.uuidV4,
      count: 1000,
    );

    // Test for patterns that would indicate weak randomness
    final patterns = <String, int>{};
    for (final uuid in uuids.generatedIds) {
      final cleanUuid = uuid.replaceAll('-', '');
      // Check for repeating sequences
      for (int i = 0; i <= cleanUuid.length - 4; i++) {
        final sequence = cleanUuid.substring(i, i + 4);
        patterns[sequence] = (patterns[sequence] ?? 0) + 1;
      }
    }

    // No sequence should appear more than statistically expected
    for (final count in patterns.values) {
      expect(count, lessThan(10)); // Generous threshold for random patterns
    }
  });
});
```

**UUID v7 Generation Tests:**

```dart
testGroup('UUID v7 Generation Validation', () {
  test('should generate sortable timestamp-based UUIDs', () async {
    final startTime = DateTime.now();

    final uuid1 = await IdGenerator.generateUuid7();
    await Future.delayed(Duration(milliseconds: 10));
    final uuid2 = await IdGenerator.generateUuid7();

    // Test sortability
    expect(uuid1.compareTo(uuid2), lessThan(0));

    // Test timestamp extraction
    final timestamp1 = UuidV7Decoder.extractTimestamp(uuid1);
    final timestamp2 = UuidV7Decoder.extractTimestamp(uuid2);

    expect(timestamp1.isBefore(timestamp2), isTrue);
    expect(timestamp1.isAfter(startTime.subtract(Duration(seconds: 1))), isTrue);
  });

  test('should maintain monotonicity under rapid generation', () async {
    final rapidUuids = <String>[];

    // Generate UUIDs rapidly
    for (int i = 0; i < 1000; i++) {
      rapidUuids.add(await IdGenerator.generateUuid7());
    }

    // Test monotonic ordering
    for (int i = 1; i < rapidUuids.length; i++) {
      expect(
        rapidUuids[i-1].compareTo(rapidUuids[i]),
        lessThanOrEqualTo(0),
        reason: 'UUID v7 ordering violation at index $i'
      );
    }
  });

  test('should handle clock rollback gracefully', () async {
    final normalUuid = await IdGenerator.generateUuid7();

    // Simulate clock rollback
    await IdGenerator.simulateClockRollback(Duration(minutes: 1));

    final rollbackUuid = await IdGenerator.generateUuid7();

    // Should still maintain ordering through sequence increment
    expect(normalUuid.compareTo(rollbackUuid), lessThan(0));

    // Verify rollback handling mechanism
    final rollbackInfo = await IdGenerator.getClockRollbackInfo();
    expect(rollbackInfo.detectedRollback, isTrue);
    expect(rollbackInfo.handlingStrategy, equals(RollbackStrategy.sequenceIncrement));
  });
});
```

**NanoID Generation Tests:**

```dart
testGroup('NanoID Generation Validation', () {
  test('should generate URL-safe identifiers with default settings', () async {
    final nanoid = await IdGenerator.generateNanoid();

    expect(nanoid.length, equals(21)); // Default length
    expect(RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(nanoid), isTrue);

    // Test URL safety
    expect(nanoid.contains('+'), isFalse);
    expect(nanoid.contains('/'), isFalse);
    expect(nanoid.contains('='), isFalse);
  });

  test('should respect custom alphabet and size configurations', () async {
    final customNanoid = await IdGenerator.generateNanoid(
      alphabet: '0123456789ABCDEF',
      size: 16,
    );

    expect(customNanoid.length, equals(16));
    expect(RegExp(r'^[0-9A-F]+$').hasMatch(customNanoid), isTrue);

    // Test character distribution
    final charCounts = <String, int>{};
    for (final char in customNanoid.split('')) {
      charCounts[char] = (charCounts[char] ?? 0) + 1;
    }

    // All characters should be from custom alphabet
    for (final char in charCounts.keys) {
      expect('0123456789ABCDEF'.contains(char), isTrue);
    }
  });

  test('should calculate collision probability accurately', () async {
    final probability8 = await IdGenerator.calculateCollisionProbability(
      alphabetSize: 64,
      idLength: 8,
      generationCount: 1000,
    );

    final probability16 = await IdGenerator.calculateCollisionProbability(
      alphabetSize: 64,
      idLength: 16,
      generationCount: 1000,
    );

    // Longer IDs should have lower collision probability
    expect(probability16, lessThan(probability8));

    // Test specific probability calculation
    expect(probability8, isA<double>());
    expect(probability8, greaterThan(0.0));
    expect(probability8, lessThan(1.0));
  });
});
```

#### Batch Generation Testing

**Large Scale Generation Tests:**

```dart
testGroup('Batch Generation Performance', () {
  test('should generate large batches efficiently', () async {
    final stopwatch = Stopwatch()..start();

    final batchResult = await IdGenerator.generateBatch(
      type: IdType.nanoid,
      count: 10000,
      options: BatchOptions(
        maxConcurrency: 4,
        validateUniqueness: true,
      ),
    );

    stopwatch.stop();

    expect(batchResult.generatedIds.length, equals(10000));
    expect(stopwatch.elapsedMilliseconds, lessThan(5000)); // 5 second limit
    expect(batchResult.uniquenessValidated, isTrue);

    // Test uniqueness
    final uniqueIds = Set<String>.from(batchResult.generatedIds);
    expect(uniqueIds.length, equals(10000));
  });

  test('should handle memory constraints during large batch generation', () async {
    final memoryMonitor = MemoryMonitor();
    memoryMonitor.startMonitoring();

    final batchResult = await IdGenerator.generateBatch(
      type: IdType.uuidV4,
      count: 100000,
      options: BatchOptions(
        memoryLimit: 100 * 1024 * 1024, // 100MB limit
        streamingMode: true,
      ),
    );

    final peakMemory = memoryMonitor.getPeakUsage();
    memoryMonitor.stopMonitoring();

    expect(batchResult.generatedIds.length, equals(100000));
    expect(peakMemory, lessThan(150 * 1024 * 1024)); // Allow some overhead
    expect(batchResult.processingMode, equals(ProcessingMode.streaming));
  });
});
```

### Integration Testing Suite

#### Cross-Tool Integration Tests

**ShareEnvelope Integration:**

```dart
testGroup('ShareEnvelope Integration', () {
  test('should create valid ShareEnvelope with ID generation metadata', () async {
    final generationResult = await IdGenerator.generateBatch(
      type: IdType.nanoid,
      count: 50,
    );

    final shareEnvelope = await IdGenerator.createShareEnvelope(
      generationResult: generationResult,
      targetTool: 'json_doctor',
    );

    expect(shareEnvelope.kind, equals(ShareKind.identifiers));
    expect(shareEnvelope.payload['generatedIds'], isA<List<String>>());
    expect(shareEnvelope.meta['generation_profile'], isNotNull);
    expect(shareEnvelope.meta['uniqueness_guarantee'], isA<double>());

    // Test metadata completeness
    expect(shareEnvelope.provenance.generationTimestamp, isNotNull);
    expect(shareEnvelope.provenance.generationAlgorithm, isNotNull);
  });

  test('should preserve quality metrics across tool transfers', () async {
    final generationResult = await IdGenerator.generateWithQualityMetrics(
      type: IdType.uuidV7,
      count: 100,
      qualityChecks: [
        QualityCheck.uniqueness,
        QualityCheck.formatCompliance,
        QualityCheck.cryptographicStrength,
      ],
    );

    final shareEnvelope = await IdGenerator.shareWithQualityChain(
      generationResult: generationResult,
      targetTool: 'csv_cleaner',
    );

    expect(shareEnvelope.qualityChain.steps.length, equals(1));
    expect(shareEnvelope.qualityChain.overallQualityScore, greaterThan(0.95));

    // Verify quality metrics preservation
    final qualityMetrics = shareEnvelope.qualityChain.steps.first.metrics;
    expect(qualityMetrics['uniqueness_score'], equals(1.0));
    expect(qualityMetrics['format_compliance'], equals(1.0));
  });
});
```

**Database Integration Testing:**

```dart
testGroup('Database Integration', () {
  test('should generate database-optimized identifiers', () async {
    final databaseIds = await IdGenerator.generateForDatabase(
      databaseType: DatabaseType.postgresql,
      tableSchema: TestSchemas.userTable,
      indexOptimization: true,
    );

    expect(databaseIds.primaryKeyIds.length, equals(1000));
    expect(databaseIds.foreignKeyIds.length, equals(5000));

    // Test database compatibility
    for (final id in databaseIds.primaryKeyIds) {
      expect(DatabaseValidator.isValidPostgreSQLId(id), isTrue);
    }

    // Test index optimization
    expect(databaseIds.indexOptimized, isTrue);
    expect(databaseIds.clusteringStrategy, equals(ClusteringStrategy.temporal));
  });

  test('should maintain referential integrity in complex schemas', () async {
    final schemaIds = await IdGenerator.generateSchemaIds(
      schema: TestSchemas.ecommerceSchema,
      relationships: TestSchemas.ecommerceRelationships,
      dataVolume: DataVolume.large,
    );

    // Validate relationship consistency
    final integrityCheck = await DatabaseIntegrityChecker.validate(
      schemaIds: schemaIds,
      relationships: TestSchemas.ecommerceRelationships,
    );

    expect(integrityCheck.isValid, isTrue);
    expect(integrityCheck.orphanedRecords, isEmpty);
    expect(integrityCheck.duplicateKeys, isEmpty);
  });
});
```

### Performance Testing Framework

#### Throughput and Latency Testing

**Single ID Generation Performance:**

```dart
testGroup('Single ID Generation Performance', () {
  test('should generate UUID v4 within performance threshold', () async {
    final iterations = 10000;
    final stopwatch = Stopwatch()..start();

    for (int i = 0; i < iterations; i++) {
      await IdGenerator.generateUuid4();
    }

    stopwatch.stop();

    final averageTimePerGeneration = stopwatch.elapsedMicroseconds / iterations;
    expect(averageTimePerGeneration, lessThan(100)); // 100 microseconds per ID

    final throughput = iterations / (stopwatch.elapsedMilliseconds / 1000);
    expect(throughput, greaterThan(50000)); // 50K IDs per second
  });

  test('should generate NanoID with custom alphabet efficiently', () async {
    final customAlphabet = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
    final iterations = 5000;

    final stopwatch = Stopwatch()..start();

    for (int i = 0; i < iterations; i++) {
      await IdGenerator.generateNanoid(
        alphabet: customAlphabet,
        size: 21,
      );
    }

    stopwatch.stop();

    final averageTime = stopwatch.elapsedMicroseconds / iterations;
    expect(averageTime, lessThan(200)); // 200 microseconds per custom NanoID
  });
});
```

**Concurrent Generation Testing:**

```dart
testGroup('Concurrent Generation Performance', () {
  test('should handle high concurrency without conflicts', () async {
    final concurrentTasks = 100;
    final idsPerTask = 100;

    final futures = List.generate(concurrentTasks, (index) async {
      return await IdGenerator.generateBatch(
        type: IdType.uuidV4,
        count: idsPerTask,
        taskId: 'task_$index',
      );
    });

    final results = await Future.wait(futures);

    // Collect all generated IDs
    final allIds = <String>{};
    for (final result in results) {
      allIds.addAll(result.generatedIds);
    }

    // Verify uniqueness across all concurrent generations
    expect(allIds.length, equals(concurrentTasks * idsPerTask));

    // Verify no task failed
    for (final result in results) {
      expect(result.status, equals(GenerationStatus.success));
      expect(result.generatedIds.length, equals(idsPerTask));
    }
  });

  test('should scale performance with available cores', () async {
    final singleCoreTime = await _measureBatchGenerationTime(
      batchSize: 10000,
      maxConcurrency: 1,
    );

    final multiCoreTime = await _measureBatchGenerationTime(
      batchSize: 10000,
      maxConcurrency: Platform.numberOfProcessors,
    );

    final speedup = singleCoreTime / multiCoreTime;
    expect(speedup, greaterThan(1.5)); // At least 50% improvement
    expect(speedup, lessThan(Platform.numberOfProcessors * 1.2)); // Reasonable upper bound
  });
});
```

### Security and Cryptographic Testing

#### Randomness Quality Testing

**Statistical Randomness Tests:**

```dart
testGroup('Cryptographic Randomness Quality', () {
  test('should pass NIST randomness tests', () async {
    final testData = await IdGenerator.generateRandomnessTestData(
      type: IdType.uuidV4,
      sampleSize: 100000,
    );

    final nistResults = await NistRandomnessTest.runSuite(testData);

    expect(nistResults.frequencyTest.passed, isTrue);
    expect(nistResults.blockFrequencyTest.passed, isTrue);
    expect(nistResults.runsTest.passed, isTrue);
    expect(nistResults.longestRunTest.passed, isTrue);
    expect(nistResults.spectralTest.passed, isTrue);

    expect(nistResults.overallScore, greaterThan(0.95));
  });

  test('should resist pattern detection attacks', () async {
    final largeDataset = await IdGenerator.generateBatch(
      type: IdType.uuidV4,
      count: 50000,
    );

    final patternAnalysis = await PatternDetector.analyze(
      data: largeDataset.generatedIds,
      algorithms: [
        PatternAlgorithm.sequenceDetection,
        PatternAlgorithm.frequencyAnalysis,
        PatternAlgorithm.correlationAnalysis,
        PatternAlgorithm.compressionTest,
      ],
    );

    expect(patternAnalysis.suspiciousPatterns, isEmpty);
    expect(patternAnalysis.compressionRatio, lessThan(1.01)); // Minimal compression
    expect(patternAnalysis.entropyScore, greaterThan(0.99));
  });
});
```

**Collision Resistance Testing:**

```dart
testGroup('Collision Resistance Validation', () {
  test('should have no collisions in massive generation test', () async {
    final massiveGeneration = await IdGenerator.generateBatch(
      type: IdType.uuidV4,
      count: 1000000, // 1 million IDs
      options: BatchOptions(
        validateUniqueness: true,
        streamingMode: true,
      ),
    );

    expect(massiveGeneration.collisionsDetected, equals(0));
    expect(massiveGeneration.uniquenessScore, equals(1.0));

    // Additional set-based uniqueness check
    final uniqueSet = Set<String>.from(massiveGeneration.generatedIds);
    expect(uniqueSet.length, equals(1000000));
  });

  test('should maintain uniqueness across multiple sessions', () async {
    final session1Ids = await IdGenerator.generateBatch(
      type: IdType.nanoid,
      count: 10000,
      sessionId: 'session_1',
    );

    final session2Ids = await IdGenerator.generateBatch(
      type: IdType.nanoid,
      count: 10000,
      sessionId: 'session_2',
    );

    final combinedIds = [
      ...session1Ids.generatedIds,
      ...session2Ids.generatedIds,
    ];

    final uniqueIds = Set<String>.from(combinedIds);
    expect(uniqueIds.length, equals(20000));
  });
});
```

### Quality Assurance Testing

#### Standards Compliance Testing

**RFC Compliance Validation:**

```dart
testGroup('Standards Compliance', () {
  test('should generate RFC 4122 compliant UUID v4', () async {
    final uuids = await IdGenerator.generateBatch(
      type: IdType.uuidV4,
      count: 1000,
    );

    for (final uuid in uuids.generatedIds) {
      final compliance = await Rfc4122Validator.validate(uuid);

      expect(compliance.isValid, isTrue);
      expect(compliance.version, equals(4));
      expect(compliance.variant, equals(Rfc4122Variant.standard));
      expect(compliance.formatValid, isTrue);
    }
  });

  test('should generate RFC 9562 compliant UUID v7', () async {
    final uuids = await IdGenerator.generateBatch(
      type: IdType.uuidV7,
      count: 1000,
    );

    for (final uuid in uuids.generatedIds) {
      final compliance = await Rfc9562Validator.validate(uuid);

      expect(compliance.isValid, isTrue);
      expect(compliance.version, equals(7));
      expect(compliance.timestampValid, isTrue);
      expect(compliance.monotonicity, isTrue);
    }
  });
});
```

### Error Handling and Edge Case Testing

#### Failure Scenario Testing

**Resource Exhaustion Handling:**

```dart
testGroup('Error Handling and Recovery', () {
  test('should handle memory exhaustion gracefully', () async {
    await MemoryLimiter.setLimit(50 * 1024 * 1024); // 50MB limit

    final result = await IdGenerator.generateBatch(
      type: IdType.uuidV4,
      count: 10000000, // Attempt to generate 10M UUIDs
    );

    // Should either succeed with streaming or fail gracefully
    if (result.status == GenerationStatus.failed) {
      expect(result.error, isA<InsufficientMemoryError>());
      expect(result.error.isRecoverable, isTrue);
      expect(result.partialResults, isNotNull);
    } else {
      expect(result.processingMode, equals(ProcessingMode.streaming));
      expect(result.memoryUsage, lessThan(100 * 1024 * 1024));
    }
  });

  test('should recover from system clock issues', () async {
    // Test UUID v7 generation with simulated clock problems
    await SystemClock.simulateClockSkew(Duration(hours: 1));

    final result = await IdGenerator.generateUuid7WithRecovery();

    expect(result.generated, isTrue);
    expect(result.clockIssueDetected, isTrue);
    expect(result.recoveryStrategy, isNotNull);

    // Verify the generated UUID is still valid
    final compliance = await Rfc9562Validator.validate(result.uuid);
    expect(compliance.isValid, isTrue);
  });
});
```

This comprehensive testing framework ensures ID Generator maintains the highest standards of security, performance, and reliability across all usage scenarios and integration patterns.
