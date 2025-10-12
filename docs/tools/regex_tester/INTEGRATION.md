# Regex Tester - Integration Guide

## ShareEnvelope Framework Integration

The Regex Tester serves as a central validation and pattern extraction hub within the Toolspace ecosystem, enabling sophisticated text processing workflows that span multiple tools through the ShareEnvelope framework.

### Core Integration Architecture

```dart
// Regex Tester with ShareEnvelope integration
class RegexTesterService extends ShareEnvelopeEnabled {
  @override
  List<SharedDataType> get supportedExports => [
    SharedDataType.text,      // Extracted matches and patterns
    SharedDataType.json,      // Structured match results
    SharedDataType.config,    // Validated patterns for reuse
  ];

  @override
  List<SharedDataType> get supportedImports => [
    SharedDataType.text,      // Text data for pattern testing
    SharedDataType.file,      // Text files for batch processing
    SharedDataType.config,    // Configuration patterns
  ];
}
```

### Data Flow Patterns

#### Outbound Data Sharing

**Validated Patterns to Development Tools**

```dart
// Share tested regex patterns for implementation
final validatedPattern = RegexPattern(
  pattern: r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b',
  flags: RegexFlags(caseSensitive: false, multiline: true),
  testResults: {
    'matches': 45,
    'accuracy': 0.978,
    'performance': 'excellent',
  },
);

ShareEnvelope.share(
  data: validatedPattern.toJson(),
  type: SharedDataType.config,
  source: 'regex_tester',
  metadata: {
    'pattern_type': 'email_validation',
    'complexity_score': 7,
    'performance_rating': 'A+',
    'test_coverage': 'comprehensive',
  }
);
```

**Extracted Matches to Text Processing**

```dart
// Share pattern matches for further processing
final extractionResult = {
  'source_text': originalText,
  'pattern_used': currentPattern,
  'matches': matches.map((match) => {
    'text': match.fullMatch,
    'position': {'start': match.start, 'end': match.end},
    'groups': match.groups.map((g) => {
      'name': g.name ?? 'group_${g.index}',
      'value': g.value,
      'position': {'start': g.start, 'end': g.end},
    }).toList(),
  }).toList(),
  'statistics': {
    'total_matches': matches.length,
    'coverage_percentage': coveragePercentage,
    'pattern_efficiency': efficiencyScore,
  },
};

ShareEnvelope.share(
  data: jsonEncode(extractionResult),
  type: SharedDataType.json,
  source: 'regex_tester',
  metadata: {
    'extraction_type': 'validated_matches',
    'data_schema': 'regex_results_v2',
  }
);
```

**Structured Data to JSON Doctor**

```dart
// Share complex extraction results for JSON processing
final structuredData = {
  'validation_report': {
    'pattern': currentPattern,
    'test_cases': testCases.map((test) => {
      'input': test.text,
      'expected_matches': test.expectedMatches,
      'actual_matches': test.actualMatches,
      'success': test.isValid,
      'performance_ms': test.executionTime,
    }).toList(),
    'overall_success_rate': successRate,
    'performance_analysis': performanceMetrics,
  },
};

ShareEnvelope.share(
  data: jsonEncode(structuredData),
  type: SharedDataType.json,
  source: 'regex_tester',
  metadata: {
    'content_type': 'validation_report',
    'format': 'comprehensive_analysis',
  }
);
```

#### Inbound Data Processing

**Text Data from File Processing Tools**

```dart
// Receive text files for pattern validation
@override
void handleSharedData(SharedData data) {
  if (data.type == SharedDataType.text &&
      data.metadata['processing_context'] == 'validation_needed') {

    _processTextForValidation(
      data.content,
      suggestedPatterns: data.metadata['suggested_patterns'],
      validationRules: data.metadata['validation_rules'],
    );
  }
}
```

**Configuration Patterns from Other Tools**

```dart
// Import regex patterns from development workflows
if (data.type == SharedDataType.config &&
    data.metadata['config_type'] == 'regex_pattern') {

  final pattern = RegexPattern.fromJson(data.content);

  _importPattern(pattern, {
    'source_tool': data.source,
    'confidence_score': data.metadata['confidence'],
    'test_required': data.metadata['requires_validation'],
  });
}
```

**Structured Data for Pattern Testing**

```dart
// Receive structured data for regex validation
if (data.type == SharedDataType.json &&
    data.metadata['requires_pattern_validation'] == true) {

  final jsonData = jsonDecode(data.content);

  _validateJsonStructure(jsonData, {
    'validation_patterns': data.metadata['patterns'],
    'strict_mode': data.metadata['strict_validation'],
    'report_format': 'detailed',
  });
}
```

## Cross-Tool Workflow Integration

### Development Workflow Integration

**Code Generation Pipeline**

1. **Regex Tester**: Develop and validate patterns
2. **Text Tools**: Format patterns for code integration
3. **File Merger**: Combine patterns into validation libraries
4. **Code Export**: Generate validation code for applications

```dart
// Orchestrated development workflow
class ValidationCodeWorkflow {
  static Future<void> generateValidationLibrary(
    List<RegexPattern> patterns
  ) async {
    // Step 1: Validate all patterns comprehensively
    final validationResults = await RegexTester.batchValidate(patterns);

    // Step 2: Share validated patterns for code generation
    await ShareEnvelope.share(
      data: jsonEncode(validationResults),
      type: SharedDataType.config,
      source: 'regex_tester',
      workflow: 'validation_library_generation'
    );

    // Workflow continues in other tools for code generation...
  }
}
```

### Data Processing Pipeline

**Text Analysis and Extraction**

```dart
// Multi-stage data processing with regex validation
class DataProcessingPipeline {
  static Future<void> processStructuredData(String rawData) async {
    // Stage 1: Pattern validation and optimization
    final patterns = await RegexTester.analyzeDataStructure(rawData);

    // Stage 2: Extract structured information
    final extractedData = await RegexTester.extractWithPatterns(
      rawData,
      patterns
    );

    // Stage 3: Share extracted data for further processing
    await ShareEnvelope.share(
      data: jsonEncode(extractedData),
      type: SharedDataType.json,
      source: 'regex_tester',
      metadata: {
        'processing_stage': 'structured_extraction',
        'confidence_scores': extractedData.confidenceMetrics,
        'validation_status': 'complete'
      }
    );
  }
}
```

## Advanced Integration Patterns

### Pattern Library Management

**Centralized Pattern Repository**

```dart
class RegexPatternLibrary {
  static final Map<String, PatternDefinition> _patterns = {};

  static Future<void> registerPattern(
    String id,
    PatternDefinition pattern
  ) async {
    _patterns[id] = pattern;

    // Share pattern registration across ecosystem
    await ShareEnvelope.broadcast(
      data: pattern.toJson(),
      type: SharedDataType.config,
      event: 'pattern_registered',
      metadata: {
        'pattern_id': id,
        'category': pattern.category,
        'complexity': pattern.complexityScore,
      }
    );
  }

  static Stream<PatternDefinition> watchPatternUpdates() {
    return ShareEnvelope.events
      .where((event) => event.type == 'pattern_registered')
      .map((event) => PatternDefinition.fromJson(event.data));
  }
}
```

**Pattern Versioning and Distribution**

```dart
class PatternVersionControl {
  static Future<void> updatePattern(
    String patternId,
    PatternDefinition newVersion
  ) async {
    final versionInfo = {
      'pattern_id': patternId,
      'version': newVersion.version,
      'changes': newVersion.changeLog,
      'compatibility': newVersion.compatibility,
      'migration_notes': newVersion.migrationNotes,
    };

    // Notify all tools using this pattern
    await ShareEnvelope.broadcast(
      data: jsonEncode(versionInfo),
      type: SharedDataType.config,
      event: 'pattern_updated',
      metadata: {
        'update_type': 'breaking_change',
        'affected_tools': newVersion.dependentTools,
      }
    );
  }
}
```

### Real-Time Collaboration

**Collaborative Pattern Development**

```dart
class CollaborativePatternSession {
  final String sessionId;
  late StreamSubscription _patternUpdates;

  void startCollaboration() {
    _patternUpdates = ShareEnvelope.realTimeChannel(sessionId)
      .listen((update) {
        _handleCollaborativeUpdate(update);
      });
  }

  Future<void> sharePatternChange(
    String pattern,
    List<TestCase> testResults
  ) async {
    await ShareEnvelope.sendToChannel(
      sessionId,
      data: jsonEncode({
        'pattern': pattern,
        'test_results': testResults.map((t) => t.toJson()).toList(),
        'timestamp': DateTime.now().toIso8601String(),
        'author': UserSession.currentUser.id,
      }),
      type: SharedDataType.config,
    );
  }
}
```

### Performance Monitoring Integration

**Cross-Tool Performance Tracking**

```dart
class RegexPerformanceMonitor {
  static Future<void> trackPatternPerformance(
    String pattern,
    String context,
    Duration executionTime,
    int textLength,
  ) async {
    final performanceData = {
      'pattern_hash': _hashPattern(pattern),
      'context': context,
      'execution_time_ms': executionTime.inMilliseconds,
      'text_length': textLength,
      'efficiency_score': _calculateEfficiency(executionTime, textLength),
      'memory_usage': await _measureMemoryUsage(),
      'timestamp': DateTime.now().toIso8601String(),
    };

    await ShareEnvelope.share(
      data: jsonEncode(performanceData),
      type: SharedDataType.json,
      source: 'regex_tester',
      metadata: {
        'data_type': 'performance_metrics',
        'analysis_context': context,
      }
    );
  }
}
```

## API Integration Layer

### RESTful Pattern Validation Service

```dart
class RegexValidationAPI {
  static Future<ValidationResult> validatePattern({
    required String pattern,
    required List<String> testCases,
    Map<String, dynamic>? options,
  }) async {
    final request = {
      'pattern': pattern,
      'test_cases': testCases,
      'options': options ?? {},
      'validation_level': 'comprehensive',
    };

    final response = await http.post(
      Uri.parse('${Config.apiBase}/regex/validate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request),
    );

    return ValidationResult.fromJson(response.data);
  }

  static Future<OptimizationSuggestions> optimizePattern(
    String pattern
  ) async {
    final response = await http.post(
      Uri.parse('${Config.apiBase}/regex/optimize'),
      body: jsonEncode({'pattern': pattern}),
    );

    return OptimizationSuggestions.fromJson(response.data);
  }
}
```

### WebSocket Real-Time Testing

```dart
class RealtimeRegexTester {
  late WebSocketChannel _channel;

  Future<void> connect() async {
    _channel = WebSocketChannel.connect(
      Uri.parse('${Config.wsBase}/regex/test')
    );

    _channel.stream.listen((message) {
      final result = TestResult.fromJson(jsonDecode(message));
      _handleTestResult(result);
    });
  }

  void testPatternRealtime(String pattern, String text) {
    _channel.sink.add(jsonEncode({
      'action': 'test',
      'pattern': pattern,
      'text': text,
      'session_id': SessionManager.currentSession.id,
    }));
  }
}
```

## Testing Integration Framework

### Automated Pattern Testing

```dart
class AutomatedRegexTesting {
  static Future<void> runTestSuite(List<PatternTestCase> testCases) async {
    final results = <TestResult>[];

    for (final testCase in testCases) {
      final result = await RegexEngine.test(
        testCase.pattern,
        testCase.testText,
        caseSensitive: testCase.caseSensitive,
        multiline: testCase.multiline,
      );

      final testResult = TestResult(
        pattern: testCase.pattern,
        expectedMatches: testCase.expectedMatches,
        actualMatches: result.matches.length,
        executionTime: result.executionTime,
        success: result.matches.length == testCase.expectedMatches,
      );

      results.add(testResult);
    }

    // Share test results for analysis
    await ShareEnvelope.share(
      data: jsonEncode(results.map((r) => r.toJson()).toList()),
      type: SharedDataType.json,
      source: 'regex_tester',
      metadata: {
        'test_type': 'automated_pattern_validation',
        'test_count': results.length,
        'success_rate': _calculateSuccessRate(results),
      }
    );
  }
}
```

### Integration Test Scenarios

```dart
void main() {
  group('Regex Tester Integration Tests', () {
    testWidgets('should share validated patterns', (tester) async {
      await tester.pumpWidget(const TestApp());

      // Enter a test pattern
      await tester.enterText(
        find.byKey(const Key('pattern_input')),
        r'\d{3}-\d{3}-\d{4}'
      );

      // Enter test text
      await tester.enterText(
        find.byKey(const Key('test_text')),
        'Call me at 555-123-4567'
      );

      // Wait for pattern validation
      await tester.pumpAndSettle();

      // Trigger sharing
      await tester.tap(find.byIcon(Icons.share));
      await tester.pump();

      // Verify share data
      final sharedData = ShareEnvelope.getLastSharedData();
      expect(sharedData.type, equals(SharedDataType.config));
      expect(sharedData.metadata['pattern_type'], isNotNull);
    });

    testWidgets('should import text data for testing', (tester) async {
      await tester.pumpWidget(const TestApp());

      // Simulate receiving shared text data
      final mockTextData = SharedData(
        type: SharedDataType.text,
        content: 'Test email: user@example.com',
        source: 'text_tools',
        metadata: {'requires_validation': 'email'},
      );

      final regexTester = tester.state<RegexTesterScreenState>(
        find.byType(RegexTesterScreen)
      );

      regexTester.handleSharedData(mockTextData);
      await tester.pump();

      // Verify text was imported
      expect(find.text('Test email: user@example.com'), findsOneWidget);
    });
  });
}
```

## Documentation Integration

### Pattern Documentation Generation

```dart
class RegexDocumentationGenerator {
  static Future<String> generatePatternDoc(
    RegexPattern pattern,
    List<TestCase> testCases,
  ) async {
    final doc = StringBuffer();

    doc.writeln('# Regex Pattern Documentation\n');
    doc.writeln('**Pattern**: `${pattern.pattern}`\n');
    doc.writeln('**Purpose**: ${pattern.description}\n');
    doc.writeln('**Complexity**: ${pattern.complexityScore}/10\n');

    doc.writeln('## Test Cases\n');
    for (final testCase in testCases) {
      doc.writeln('- Input: `${testCase.input}`');
      doc.writeln('  - Expected: ${testCase.expectedMatch}');
      doc.writeln('  - Result: ${testCase.actualMatch}');
      doc.writeln('  - Status: ${testCase.success ? "✅" : "❌"}\n');
    }

    doc.writeln('## Performance Metrics\n');
    doc.writeln('- Average execution time: ${pattern.avgExecutionTime}ms');
    doc.writeln('- Memory usage: ${pattern.memoryUsage}KB');
    doc.writeln('- Success rate: ${pattern.successRate}%');

    return doc.toString();
  }
}
```

### API Documentation Integration

```dart
class APIDocumentationIntegration {
  static Future<void> updateAPIDocumentation(
    List<RegexPattern> validatedPatterns
  ) async {
    final apiExamples = validatedPatterns.map((pattern) => {
      'endpoint': '/api/validate/${pattern.id}',
      'method': 'POST',
      'pattern': pattern.pattern,
      'example_request': {
        'text': pattern.sampleText,
        'options': pattern.defaultOptions,
      },
      'example_response': {
        'matches': pattern.sampleMatches,
        'valid': true,
        'performance': pattern.performanceMetrics,
      }
    }).toList();

    await ShareEnvelope.share(
      data: jsonEncode(apiExamples),
      type: SharedDataType.json,
      source: 'regex_tester',
      metadata: {
        'documentation_type': 'api_examples',
        'format': 'openapi_compatible',
      }
    );
  }
}
```

## Security Integration

### Pattern Security Analysis

```dart
class RegexSecurityAnalyzer {
  static SecurityAnalysisResult analyzePattern(String pattern) {
    final risks = <SecurityRisk>[];

    // Check for ReDoS vulnerabilities
    if (_hasReDoSRisk(pattern)) {
      risks.add(SecurityRisk(
        type: 'redos_vulnerability',
        severity: 'high',
        description: 'Pattern may be vulnerable to ReDoS attacks',
        mitigation: 'Consider using atomic groups or possessive quantifiers',
      ));
    }

    // Check for injection risks
    if (_hasInjectionRisk(pattern)) {
      risks.add(SecurityRisk(
        type: 'injection_risk',
        severity: 'medium',
        description: 'Pattern may allow code injection',
        mitigation: 'Validate and sanitize input before pattern matching',
      ));
    }

    return SecurityAnalysisResult(
      pattern: pattern,
      risks: risks,
      overallRisk: _calculateOverallRisk(risks),
      recommendations: _generateSecurityRecommendations(risks),
    );
  }
}
```

This comprehensive integration guide ensures the Regex Tester functions as a powerful validation and pattern development hub within the Toolspace ecosystem, enabling sophisticated text processing workflows that maintain security, performance, and reliability standards.

---

**Integration Architect**: Marcus Chen, Staff Software Engineer  
**Last Updated**: October 11, 2025  
**Integration Version**: 1.4.0
