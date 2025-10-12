# JSON Doctor - Testing Documentation

**Tool ID:** `json_doctor`  
**Route:** `/tools/json-doctor`  
**QA Engineer:** Toolspace Testing Team  
**Last Updated:** October 11, 2025

## 1. Testing Overview

JSON Doctor requires comprehensive testing across multiple dimensions: JSON validation accuracy, schema compliance, JSONPath query execution, cross-tool integration, and performance under various data loads. Our testing strategy encompasses unit tests, integration tests, performance benchmarks, and real-world scenario validation.

**Testing Categories:**

- **Functional Testing** - Core JSON processing capabilities
- **Integration Testing** - ShareBus and cross-tool communication
- **Performance Testing** - Large file handling and response times
- **Security Testing** - Input validation and sanitization
- **Accessibility Testing** - Screen reader and keyboard navigation
- **Browser Compatibility** - Cross-platform functionality validation

### 1.1 Test Environment Setup

#### Test Data Fixtures

```dart
// Comprehensive test data for various scenarios
class JsonDoctorTestFixtures {
  // Valid JSON samples
  static const Map<String, String> validJsonSamples = {
    'simple_object': '{"name": "John", "age": 30, "city": "New York"}',
    'nested_object': '''
    {
      "user": {
        "personal": {
          "name": "Jane Doe",
          "age": 25
        },
        "professional": {
          "title": "Developer",
          "company": "TechCorp"
        }
      }
    }
    ''',
    'array_of_objects': '''
    [
      {"id": 1, "name": "Alice", "score": 95.5},
      {"id": 2, "name": "Bob", "score": 87.2},
      {"id": 3, "name": "Charlie", "score": 92.8}
    ]
    ''',
    'complex_mixed': '''
    {
      "metadata": {
        "version": "1.0",
        "created": "2025-10-11T10:00:00Z",
        "tags": ["production", "validated"]
      },
      "data": [
        {
          "id": "uuid-123",
          "properties": {
            "enabled": true,
            "config": {
              "timeout": 5000,
              "retries": 3
            }
          },
          "values": [1, 2, 3, null, 5]
        }
      ]
    }
    ''',
  };

  // Invalid JSON samples for error testing
  static const Map<String, String> invalidJsonSamples = {
    'missing_quote': '{"name": John, "age": 30}',
    'trailing_comma': '{"name": "John", "age": 30,}',
    'missing_comma': '{"name": "John" "age": 30}',
    'unmatched_bracket': '{"name": "John", "age": 30',
    'invalid_escape': '{"message": "Hello\\world"}',
    'duplicate_keys': '{"name": "John", "name": "Jane"}',
    'invalid_number': '{"age": 030}',
    'invalid_boolean': '{"active": True}',
  };

  // Large data samples for performance testing
  static String generateLargeJsonObject(int size) {
    final buffer = StringBuffer('{"data": [');
    for (int i = 0; i < size; i++) {
      if (i > 0) buffer.write(',');
      buffer.write('{"id": $i, "value": "item_$i", "timestamp": ${DateTime.now().millisecondsSinceEpoch + i}}');
    }
    buffer.write(']}');
    return buffer.toString();
  }
}
```

#### Schema Test Fixtures

```dart
class SchemaTestFixtures {
  // JSON Schema samples for validation testing
  static const Map<String, Map<String, dynamic>> schemas = {
    'user_schema': {
      'type': 'object',
      'properties': {
        'name': {'type': 'string', 'minLength': 1},
        'age': {'type': 'integer', 'minimum': 0, 'maximum': 150},
        'email': {'type': 'string', 'format': 'email'},
        'active': {'type': 'boolean'},
      },
      'required': ['name', 'age'],
      'additionalProperties': false,
    },
    'api_response_schema': {
      'type': 'object',
      'properties': {
        'status': {'type': 'string', 'enum': ['success', 'error']},
        'data': {'type': 'object'},
        'message': {'type': 'string'},
        'timestamp': {'type': 'string', 'format': 'date-time'},
      },
      'required': ['status'],
      'if': {
        'properties': {'status': {'const': 'error'}},
      },
      'then': {
        'required': ['message'],
      },
    },
    'configuration_schema': {
      'type': 'object',
      'properties': {
        'database': {
          'type': 'object',
          'properties': {
            'host': {'type': 'string'},
            'port': {'type': 'integer', 'minimum': 1, 'maximum': 65535},
            'ssl': {'type': 'boolean', 'default': true},
          },
          'required': ['host', 'port'],
        },
        'features': {
          'type': 'array',
          'items': {'type': 'string'},
          'uniqueItems': true,
        },
      },
    },
  };
}
```

## 2. Functional Testing

### 2.1 JSON Validation Tests

#### Core Validation Functionality

```dart
class JsonValidationTests {
  group('JSON Validation', () {
    testWidgets('validates correct JSON syntax', (tester) async {
      await tester.pumpWidget(JsonDoctorScreen());

      // Input valid JSON
      await tester.enterText(
        find.byKey(Key('json-input')),
        JsonDoctorTestFixtures.validJsonSamples['simple_object']!,
      );

      await tester.pump(Duration(milliseconds: 400)); // Wait for debounce

      // Verify validation status
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.text('Valid JSON'), findsOneWidget);

      // Verify parsed data is displayed
      expect(find.text('"name": "John"'), findsOneWidget);
    });

    testWidgets('detects and reports syntax errors', (tester) async {
      await tester.pumpWidget(JsonDoctorScreen());

      // Input invalid JSON
      await tester.enterText(
        find.byKey(Key('json-input')),
        JsonDoctorTestFixtures.invalidJsonSamples['missing_quote']!,
      );

      await tester.pump(Duration(milliseconds: 400));

      // Verify error status
      expect(find.byIcon(Icons.error), findsOneWidget);
      expect(find.text('Syntax errors found'), findsOneWidget);

      // Verify error details are shown
      expect(find.textContaining('Expected string'), findsOneWidget);
    });

    testWidgets('provides intelligent error positioning', (tester) async {
      await tester.pumpWidget(JsonDoctorScreen());

      const invalidJson = '{"name": "John",\n  "age": 30,\n  "invalid": }';
      await tester.enterText(find.byKey(Key('json-input')), invalidJson);
      await tester.pump(Duration(milliseconds: 400));

      // Verify error position is identified
      final errorWidget = tester.widget<ErrorLocationWidget>(
        find.byType(ErrorLocationWidget),
      );
      expect(errorWidget.line, equals(3));
      expect(errorWidget.column, greaterThan(10));
    });
  });
}
```

#### Auto-Repair Functionality

```dart
class AutoRepairTests {
  group('Auto-Repair', () {
    testWidgets('fixes missing quotes around keys', (tester) async {
      await tester.pumpWidget(JsonDoctorScreen());

      const brokenJson = '{name: "John", age: 30}';
      await tester.enterText(find.byKey(Key('json-input')), brokenJson);
      await tester.pump(Duration(milliseconds: 400));

      // Trigger auto-repair
      await tester.tap(find.byKey(Key('auto-repair-button')));
      await tester.pump();

      // Verify repair was applied
      final outputText = tester.widget<TextField>(
        find.byKey(Key('json-output')),
      ).controller!.text;

      expect(outputText, contains('"name": "John"'));
      expect(outputText, contains('"age": 30'));
    });

    testWidgets('removes trailing commas', (tester) async {
      await tester.pumpWidget(JsonDoctorScreen());

      const brokenJson = '{"name": "John", "age": 30,}';
      await tester.enterText(find.byKey(Key('json-input')), brokenJson);
      await tester.pump(Duration(milliseconds: 400));

      await tester.tap(find.byKey(Key('auto-repair-button')));
      await tester.pump();

      final outputText = tester.widget<TextField>(
        find.byKey(Key('json-output')),
      ).controller!.text;

      expect(outputText, isNot(contains(',}')));
      expect(jsonDecode(outputText), isA<Map<String, dynamic>>());
    });

    testWidgets('reports unfixable errors', (tester) async {
      await tester.pumpWidget(JsonDoctorScreen());

      const unfixableJson = '{"name": "John", "age":}';
      await tester.enterText(find.byKey(Key('json-input')), unfixableJson);
      await tester.pump(Duration(milliseconds: 400));

      await tester.tap(find.byKey(Key('auto-repair-button')));
      await tester.pump();

      // Verify repair failure is communicated
      expect(find.text('Unable to auto-repair'), findsOneWidget);
      expect(find.textContaining('manual correction required'), findsOneWidget);
    });
  });
}
```

### 2.2 Schema Validation Tests

#### Schema Compliance Validation

```dart
class SchemaValidationTests {
  group('Schema Validation', () {
    testWidgets('validates data against basic schema', (tester) async {
      await tester.pumpWidget(JsonDoctorScreen());

      // Switch to schema tab
      await tester.tap(find.text('Schema'));
      await tester.pump();

      // Input schema
      await tester.enterText(
        find.byKey(Key('schema-input')),
        jsonEncode(SchemaTestFixtures.schemas['user_schema']!),
      );

      // Input valid data
      const validUserData = '{"name": "John Doe", "age": 30, "email": "john@example.com", "active": true}';
      await tester.enterText(find.byKey(Key('json-input')), validUserData);
      await tester.pump(Duration(milliseconds: 400));

      // Verify schema validation passes
      expect(find.byIcon(Icons.verified), findsOneWidget);
      expect(find.text('Schema validation passed'), findsOneWidget);
    });

    testWidgets('reports schema validation errors', (tester) async {
      await tester.pumpWidget(JsonDoctorScreen());
      await tester.tap(find.text('Schema'));
      await tester.pump();

      await tester.enterText(
        find.byKey(Key('schema-input')),
        jsonEncode(SchemaTestFixtures.schemas['user_schema']!),
      );

      // Input invalid data (missing required field)
      const invalidUserData = '{"name": "John Doe", "email": "john@example.com"}';
      await tester.enterText(find.byKey(Key('json-input')), invalidUserData);
      await tester.pump(Duration(milliseconds: 400));

      // Verify validation errors are shown
      expect(find.text('Schema validation failed'), findsOneWidget);
      expect(find.textContaining('Required property missing: age'), findsOneWidget);
    });

    testWidgets('handles complex schema conditions', (tester) async {
      await tester.pumpWidget(JsonDoctorScreen());
      await tester.tap(find.text('Schema'));
      await tester.pump();

      await tester.enterText(
        find.byKey(Key('schema-input')),
        jsonEncode(SchemaTestFixtures.schemas['api_response_schema']!),
      );

      // Test conditional schema (error status requires message)
      const errorResponse = '{"status": "error", "timestamp": "2025-10-11T10:00:00Z"}';
      await tester.enterText(find.byKey(Key('json-input')), errorResponse);
      await tester.pump(Duration(milliseconds: 400));

      expect(find.textContaining('Required property missing: message'), findsOneWidget);
    });
  });
}
```

### 2.3 JSONPath Query Tests

#### Query Execution and Results

```dart
class JsonPathQueryTests {
  group('JSONPath Queries', () {
    testWidgets('executes simple property queries', (tester) async {
      await tester.pumpWidget(JsonDoctorScreen());

      // Switch to JSONPath tab
      await tester.tap(find.text('JSONPath'));
      await tester.pump();

      // Input test data
      const testData = '{"store": {"book": [{"title": "Book 1", "price": 10}, {"title": "Book 2", "price": 15}]}}';
      await tester.enterText(find.byKey(Key('json-input')), testData);

      // Execute query
      await tester.enterText(find.byKey(Key('jsonpath-input')), r'$.store.book[*].title');
      await tester.tap(find.byKey(Key('execute-query-button')));
      await tester.pump();

      // Verify results
      final resultsText = tester.widget<TextField>(
        find.byKey(Key('query-results')),
      ).controller!.text;

      expect(resultsText, contains('"Book 1"'));
      expect(resultsText, contains('"Book 2"'));
    });

    testWidgets('handles filter expressions', (tester) async {
      await tester.pumpWidget(JsonDoctorScreen());
      await tester.tap(find.text('JSONPath'));
      await tester.pump();

      const testData = '{"items": [{"name": "A", "price": 5}, {"name": "B", "price": 15}, {"name": "C", "price": 25}]}';
      await tester.enterText(find.byKey(Key('json-input')), testData);

      // Query with filter
      await tester.enterText(find.byKey(Key('jsonpath-input')), r'$.items[?(@.price > 10)]');
      await tester.tap(find.byKey(Key('execute-query-button')));
      await tester.pump();

      final resultsText = tester.widget<TextField>(
        find.byKey(Key('query-results')),
      ).controller!.text;

      expect(resultsText, contains('"name": "B"'));
      expect(resultsText, contains('"name": "C"'));
      expect(resultsText, isNot(contains('"name": "A"')));
    });

    testWidgets('provides query syntax error feedback', (tester) async {
      await tester.pumpWidget(JsonDoctorScreen());
      await tester.tap(find.text('JSONPath'));
      await tester.pump();

      const testData = '{"test": "data"}';
      await tester.enterText(find.byKey(Key('json-input')), testData);

      // Invalid query syntax
      await tester.enterText(find.byKey(Key('jsonpath-input')), r'$.invalid[syntax');
      await tester.tap(find.byKey(Key('execute-query-button')));
      await tester.pump();

      expect(find.text('Query syntax error'), findsOneWidget);
      expect(find.textContaining('bracket'), findsOneWidget);
    });
  });
}
```

## 3. Integration Testing

### 3.1 ShareBus Integration Tests

#### Cross-Tool Data Sharing

```dart
class ShareBusIntegrationTests {
  group('ShareBus Integration', () {
    testWidgets('receives JSON data from Text Tools', (tester) async {
      await tester.pumpWidget(JsonDoctorScreen());

      // Simulate incoming ShareBus message
      final shareMessage = TextShareMessage(
        sourceToolId: 'text_tools',
        targetToolId: 'json_doctor',
        data: JsonDoctorTestFixtures.validJsonSamples['simple_object']!,
        textType: TextType.code,
        language: 'json',
      );

      // Trigger message handling
      await JsonDoctorShareBus().handleIncomingData(shareMessage.toMap());
      await tester.pump();

      // Verify data was loaded
      final inputText = tester.widget<TextField>(
        find.byKey(Key('json-input')),
      ).controller!.text;

      expect(inputText, equals(shareMessage.data));
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('sends validated JSON to other tools', (tester) async {
      await tester.pumpWidget(JsonDoctorScreen());

      // Input and validate JSON
      await tester.enterText(
        find.byKey(Key('json-input')),
        JsonDoctorTestFixtures.validJsonSamples['nested_object']!,
      );
      await tester.pump(Duration(milliseconds: 400));

      // Mock ShareBus service
      final shareBusService = MockShareBusService();
      when(() => shareBusService.send(any())).thenAnswer((_) async {});

      // Trigger export to Text Tools
      await tester.tap(find.byKey(Key('share-button')));
      await tester.pump();
      await tester.tap(find.text('Text Tools'));
      await tester.pump();

      // Verify message was sent
      verify(() => shareBusService.send(any<TextShareMessage>())).called(1);
    });

    testWidgets('handles CSV conversion from CSV Cleaner', (tester) async {
      await tester.pumpWidget(JsonDoctorScreen());

      // Simulate CSV data incoming
      final csvMessage = CsvShareMessage(
        sourceToolId: 'csv_cleaner',
        targetToolId: 'json_doctor',
        data: 'name,age,city\nJohn,30,NYC\nJane,25,LA',
        metadata: {'hasHeader': true},
      );

      await JsonDoctorShareBus().handleIncomingData(csvMessage.toMap());
      await tester.pump();

      // Verify CSV was converted to JSON
      final inputText = tester.widget<TextField>(
        find.byKey(Key('json-input')),
      ).controller!.text;

      final jsonData = jsonDecode(inputText);
      expect(jsonData, isA<List>());
      expect(jsonData[0]['name'], equals('John'));
      expect(jsonData[1]['name'], equals('Jane'));
    });
  });
}
```

### 3.2 File Import/Export Tests

#### File Handling Integration

```dart
class FileIntegrationTests {
  group('File Operations', () {
    testWidgets('imports JSON files via drag and drop', (tester) async {
      await tester.pumpWidget(JsonDoctorScreen());

      // Simulate file drop
      const jsonFileContent = '{"imported": true, "source": "file"}';
      await simulateFileDrop(
        tester,
        fileName: 'test.json',
        content: jsonFileContent,
        mimeType: 'application/json',
      );

      await tester.pump();

      // Verify file content was loaded
      final inputText = tester.widget<TextField>(
        find.byKey(Key('json-input')),
      ).controller!.text;

      expect(inputText, equals(jsonFileContent));
    });

    testWidgets('exports formatted JSON to file', (tester) async {
      await tester.pumpWidget(JsonDoctorScreen());

      // Input JSON
      await tester.enterText(
        find.byKey(Key('json-input')),
        '{"name":"John","age":30}',
      );
      await tester.pump(Duration(milliseconds: 400));

      // Mock file download service
      final fileService = MockFileDownloadService();
      when(() => fileService.downloadText(any(), any())).thenAnswer((_) async {});

      // Trigger export
      await tester.tap(find.byKey(Key('export-button')));
      await tester.pump();

      // Verify formatted JSON was prepared for download
      verify(() => fileService.downloadText(
        argThat(contains('{\n  "name": "John",\n  "age": 30\n}')),
        'formatted.json',
      )).called(1);
    });
  });
}
```

## 4. Performance Testing

### 4.1 Large Data Handling

#### Memory and Processing Performance

```dart
class PerformanceTests {
  group('Performance', () {
    testWidgets('handles large JSON files efficiently', (tester) async {
      await tester.pumpWidget(JsonDoctorScreen());

      // Generate large JSON (10MB+)
      final largeJson = JsonDoctorTestFixtures.generateLargeJsonObject(100000);

      // Measure validation time
      final stopwatch = Stopwatch()..start();

      await tester.enterText(find.byKey(Key('json-input')), largeJson);
      await tester.pump(Duration(milliseconds: 500));

      stopwatch.stop();

      // Verify performance targets
      expect(stopwatch.elapsedMilliseconds, lessThan(2000)); // Under 2 seconds
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('maintains UI responsiveness during processing', (tester) async {
      await tester.pumpWidget(JsonDoctorScreen());

      final largeJson = JsonDoctorTestFixtures.generateLargeJsonObject(50000);

      // Start processing
      await tester.enterText(find.byKey(Key('json-input')), largeJson);

      // Verify UI remains responsive
      await tester.pump(Duration(milliseconds: 100));
      expect(tester.binding.hasScheduledFrame, isFalse);

      // Verify loading indicator appears
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('handles memory efficiently for multiple operations', (tester) async {
      await tester.pumpWidget(JsonDoctorScreen());

      // Process multiple large JSONs in sequence
      for (int i = 0; i < 5; i++) {
        final json = JsonDoctorTestFixtures.generateLargeJsonObject(10000);
        await tester.enterText(find.byKey(Key('json-input')), json);
        await tester.pump(Duration(milliseconds: 200));

        // Clear input
        await tester.enterText(find.byKey(Key('json-input')), '');
        await tester.pump(Duration(milliseconds: 100));
      }

      // Verify no memory leaks (simplified check)
      expect(find.byType(OutOfMemoryError), findsNothing);
    });
  });
}
```

### 4.2 JSONPath Performance

#### Query Execution Benchmarks

```dart
class JsonPathPerformanceTests {
  group('JSONPath Performance', () {
    testWidgets('executes complex queries on large datasets', (tester) async {
      await tester.pumpWidget(JsonDoctorScreen());
      await tester.tap(find.text('JSONPath'));
      await tester.pump();

      // Create large nested dataset
      final largeData = {
        'users': List.generate(10000, (i) => {
          'id': i,
          'name': 'User $i',
          'profile': {
            'age': 20 + (i % 50),
            'department': 'Dept ${i % 10}',
            'active': i % 3 == 0,
          },
        }),
      };

      await tester.enterText(
        find.byKey(Key('json-input')),
        jsonEncode(largeData),
      );

      // Execute complex query
      final stopwatch = Stopwatch()..start();

      await tester.enterText(
        find.byKey(Key('jsonpath-input')),
        r'$.users[?(@.profile.age > 30 && @.profile.active == true)].name',
      );
      await tester.tap(find.byKey(Key('execute-query-button')));
      await tester.pump();

      stopwatch.stop();

      // Verify performance and accuracy
      expect(stopwatch.elapsedMilliseconds, lessThan(1000)); // Under 1 second
      expect(find.text('Query completed'), findsOneWidget);
    });
  });
}
```

## 5. Security Testing

### 5.1 Input Sanitization

#### Malicious Input Protection

```dart
class SecurityTests {
  group('Security', () {
    testWidgets('sanitizes potentially malicious JSON', (tester) async {
      await tester.pumpWidget(JsonDoctorScreen());

      // Test various malicious inputs
      final maliciousInputs = [
        '{"script": "<script>alert(\'xss\')</script>"}',
        '{"eval": "eval(\'malicious code\')"}',
        '{"__proto__": {"admin": true}}',
        '{"constructor": {"prototype": {"admin": true}}}',
      ];

      for (final input in maliciousInputs) {
        await tester.enterText(find.byKey(Key('json-input')), input);
        await tester.pump(Duration(milliseconds: 400));

        // Verify no script execution or prototype pollution
        expect(find.textContaining('<script>'), findsNothing);
        expect(find.textContaining('eval('), findsNothing);
      }
    });

    testWidgets('limits input size to prevent DoS', (tester) async {
      await tester.pumpWidget(JsonDoctorScreen());

      // Generate extremely large input (beyond reasonable limits)
      final oversizedInput = 'x' * (100 * 1024 * 1024); // 100MB

      await tester.enterText(find.byKey(Key('json-input')), oversizedInput);
      await tester.pump();

      // Verify size limit protection
      expect(find.textContaining('Input too large'), findsOneWidget);
      expect(find.text('Please reduce file size'), findsOneWidget);
    });
  });
}
```

## 6. Accessibility Testing

### 6.1 Screen Reader Compatibility

#### ARIA and Navigation Support

```dart
class AccessibilityTests {
  group('Accessibility', () {
    testWidgets('provides proper ARIA labels', (tester) async {
      await tester.pumpWidget(JsonDoctorScreen());

      // Verify semantic structure
      expect(find.bySemanticsLabel('JSON input editor'), findsOneWidget);
      expect(find.bySemanticsLabel('Validation status'), findsOneWidget);
      expect(find.bySemanticsLabel('JSON output area'), findsOneWidget);
    });

    testWidgets('supports keyboard navigation', (tester) async {
      await tester.pumpWidget(JsonDoctorScreen());

      // Test tab navigation
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      expect(tester.binding.focusManager.primaryFocus?.debugLabel,
             contains('json-input'));

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      expect(tester.binding.focusManager.primaryFocus?.debugLabel,
             contains('tab-navigation'));
    });

    testWidgets('announces validation results to screen readers', (tester) async {
      await tester.pumpWidget(JsonDoctorScreen());

      // Mock screen reader announcements
      final announcements = <String>[];
      mockScreenReaderAnnouncements(announcements);

      // Input valid JSON
      await tester.enterText(
        find.byKey(Key('json-input')),
        '{"valid": true}',
      );
      await tester.pump(Duration(milliseconds: 400));

      // Verify announcement was made
      expect(announcements, contains('JSON is valid'));
    });
  });
}
```

## 7. Browser Compatibility Testing

### 7.1 Cross-Browser Functionality

#### Multi-Browser Test Suite

```dart
class BrowserCompatibilityTests {
  group('Browser Compatibility', () {
    testWidgets('works in Chrome', (tester) async {
      await tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('browser_info'),
        (call) async => {'browser': 'chrome', 'version': '118.0'},
      );

      await tester.pumpWidget(JsonDoctorScreen());
      await _runBasicFunctionalityTests(tester);
    });

    testWidgets('works in Firefox', (tester) async {
      await tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('browser_info'),
        (call) async => {'browser': 'firefox', 'version': '119.0'},
      );

      await tester.pumpWidget(JsonDoctorScreen());
      await _runBasicFunctionalityTests(tester);
    });

    testWidgets('works in Safari', (tester) async {
      await tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('browser_info'),
        (call) async => {'browser': 'safari', 'version': '17.0'},
      );

      await tester.pumpWidget(JsonDoctorScreen());
      await _runBasicFunctionalityTests(tester);
    });
  });

  Future<void> _runBasicFunctionalityTests(WidgetTester tester) async {
    // Test core functionality across browsers
    await tester.enterText(
      find.byKey(Key('json-input')),
      '{"test": "cross-browser"}',
    );
    await tester.pump(Duration(milliseconds: 400));

    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  }
}
```

## 8. Manual Testing Scenarios

### 8.1 User Workflow Testing

#### Real-World Usage Scenarios

```yaml
# Manual Test Cases for JSON Doctor

## Scenario 1: API Response Validation
**Objective**: Validate API response structure and content
**Steps**:
1. Copy API response from network tab
2. Paste into JSON Doctor input area
3. Verify validation status and error highlighting
4. Apply auto-repair if needed
5. Export validated JSON to API testing tool

**Expected Results**:
- Immediate validation feedback
- Clear error identification if invalid
- Successful auto-repair for common issues
- Smooth export to target tool

## Scenario 2: Configuration File Processing
**Objective**: Process and validate configuration files
**Steps**:
1. Upload JSON configuration file
2. Load appropriate schema for validation
3. Identify schema violations
4. Generate corrected configuration
5. Save formatted output

**Expected Results**:
- File upload works smoothly
- Schema validation provides clear feedback
- Configuration errors are highlighted
- Output is properly formatted

## Scenario 3: Data Transformation Workflow
**Objective**: Transform data between different tools
**Steps**:
1. Import CSV data from CSV Cleaner
2. Convert to JSON format
3. Apply JSONPath queries to extract specific data
4. Export results to Text Tools for documentation
5. Share schema with development team

**Expected Results**:
- Seamless CSV to JSON conversion
- JSONPath queries execute accurately
- Cross-tool sharing works without data loss
- All operations complete within performance targets

## Scenario 4: Large Dataset Processing
**Objective**: Handle large JSON files efficiently
**Steps**:
1. Load 10MB+ JSON file
2. Perform validation without UI freezing
3. Execute complex JSONPath queries
4. Export subsets to other tools
5. Monitor memory usage throughout

**Expected Results**:
- Large files load within 2 seconds
- UI remains responsive during processing
- Query execution completes under 1 second
- Memory usage stays within limits
```

### 8.2 Edge Case Testing

#### Unusual Input Scenarios

```yaml
## Edge Case 1: Deeply Nested JSON
**Input**: JSON with 100+ nesting levels
**Expected**: Graceful handling with performance warnings

## Edge Case 2: Unicode and Special Characters
**Input**: JSON with emoji, CJK characters, and escape sequences
**Expected**: Proper parsing and display of all characters

## Edge Case 3: Very Large Numbers
**Input**: JSON with numbers exceeding JavaScript precision
**Expected**: Appropriate warnings about precision loss

## Edge Case 4: Mixed Data Types
**Input**: JSON with all possible value types in arrays
**Expected**: Correct type identification and validation

## Edge Case 5: Malformed Recovery
**Input**: Severely malformed JSON with multiple error types
**Expected**: Clear error prioritization and repair suggestions
```

## 9. Automated Test Execution

### 9.1 Continuous Integration

#### CI/CD Test Pipeline

```yaml
# .github/workflows/json-doctor-tests.yml
name: JSON Doctor Tests

on:
  push:
    paths:
      - "lib/tools/json_doctor/**"
      - "test/tools/json_doctor/**"
  pull_request:
    paths:
      - "lib/tools/json_doctor/**"

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        browser: [chrome, firefox]

    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: "3.16.0"

      - name: Install dependencies
        run: flutter pub get

      - name: Run unit tests
        run: flutter test test/tools/json_doctor/

      - name: Run integration tests
        run: |
          flutter drive \
            --driver=test_driver/integration_test.dart \
            --target=integration_test/json_doctor_test.dart \
            --browser-name=${{ matrix.browser }}

      - name: Run performance tests
        run: flutter test test/tools/json_doctor/performance/

      - name: Generate coverage report
        run: |
          flutter test --coverage
          genhtml coverage/lcov.info -o coverage/html

      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          file: coverage/lcov.info
```

### 9.2 Test Metrics and Monitoring

#### Quality Metrics Tracking

```dart
class TestMetrics {
  static const Map<String, double> qualityTargets = {
    'test_coverage': 95.0,           // 95% code coverage
    'performance_validation': 100.0,  // Under 100ms
    'large_file_processing': 2000.0, // Under 2 seconds
    'memory_efficiency': 100.0,      // Under 100MB peak
    'accessibility_score': 100.0,    // Perfect accessibility
    'cross_browser_compatibility': 100.0, // All major browsers
  };

  static Future<TestMetricsReport> generateReport() async {
    return TestMetricsReport(
      coveragePercentage: await _calculateCoverage(),
      performanceResults: await _runPerformanceBenchmarks(),
      accessibilityScore: await _runAccessibilityAudit(),
      browserCompatibility: await _runBrowserTests(),
      timestamp: DateTime.now(),
    );
  }
}
```

JSON Doctor's comprehensive testing strategy ensures reliability, performance, and usability across all supported platforms and use cases, maintaining the highest quality standards for this critical JSON processing tool.
