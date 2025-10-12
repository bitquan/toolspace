# Text Tools - Test Documentation

**Last Updated:** October 11, 2025  
**Version:** 2.3.0  
**Owner:** Text Tools Team

## 1. Manual Test Scenarios

### Test Case Matrix

| ID    | Category            | Pre-requisites         | Steps                                               | Expected Result                  | Priority |
| ----- | ------------------- | ---------------------- | --------------------------------------------------- | -------------------------------- | -------- |
| TT001 | Case Conversion     | Text Tools open        | Enter "hello world", click Title Case               | ✅ Output shows "Hello World"    | High     |
| TT002 | Case Conversion     | Text Tools open        | Enter "HELLO WORLD", click lower case               | ✅ Output shows "hello world"    | High     |
| TT003 | Case Conversion     | Text Tools open        | Enter "hello world", click snake_case               | ✅ Output shows "hello_world"    | Medium   |
| TT004 | Case Conversion     | Text Tools open        | Enter "hello world", click camelCase                | ✅ Output shows "helloWorld"     | Medium   |
| TT005 | Case Conversion     | Text Tools open        | Enter "HelloWorld", click kebab-case                | ✅ Output shows "hello-world"    | Medium   |
| TT006 | Input Validation    | Text Tools open        | Clear input, click any operation                    | ❌ Operation buttons disabled    | High     |
| TT007 | Large Text          | Text Tools open        | Paste 2MB text file                                 | ❌ Shows "Text too large" error  | High     |
| TT008 | Text Cleaning       | Text with extra spaces | Enter "hello world ", click Remove Spaces           | ✅ Output shows "hello world"    | High     |
| TT009 | Text Cleaning       | Multi-line text        | Enter text with empty lines, click Remove Lines     | ✅ Empty lines removed           | Medium   |
| TT010 | Text Cleaning       | HTML content           | Enter "&lt;p&gt;Hello&lt;/p&gt;", click Remove HTML | ✅ Output shows "Hello"          | Medium   |
| TT011 | JSON Processing     | Valid JSON             | Enter {"test": true}, click Format                  | ✅ Pretty-printed JSON           | High     |
| TT012 | JSON Processing     | Invalid JSON           | Enter {"test":}, click Format                       | ❌ Shows error with line number  | High     |
| TT013 | JSON Processing     | Valid JSON             | Enter formatted JSON, click Minify                  | ✅ Compact JSON output           | Medium   |
| TT014 | Text Generation     | UUID tab               | Click Generate UUID                                 | ✅ Valid UUID in output          | Medium   |
| TT015 | Text Generation     | NanoID tab             | Set length 10, click Generate                       | ✅ 10-character NanoID           | Medium   |
| TT016 | Text Generation     | Password tab           | Set length 12, click Generate                       | ✅ 12-character password         | Medium   |
| TT017 | Text Analysis       | Paragraph text         | Enter multi-paragraph text                          | ✅ Accurate word/character count | Medium   |
| TT018 | Text Analysis       | Complex text           | Enter text with punctuation                         | ✅ Sentence count accurate       | Low      |
| TT019 | URL Processing      | Text with URLs         | Enter "Visit https://example.com today"             | ✅ URL extracted correctly       | Medium   |
| TT020 | URL Processing      | Invalid URL            | Enter "not-a-url", use URL tools                    | ❌ Shows URL format error        | Medium   |
| TT021 | Copy Function       | Text in output         | Process text, click Copy                            | ✅ Text copied to clipboard      | High     |
| TT022 | Share Function      | Text in output         | Process text, click Share                           | ✅ Share menu appears            | High     |
| TT023 | Tab Navigation      | Text Tools open        | Click through all 6 tabs                            | ✅ All tabs load correctly       | Medium   |
| TT024 | Multiple Operations | Text input             | Apply Title Case, then Upper Case                   | ✅ Chained operations work       | Medium   |
| TT025 | Keyboard Shortcuts  | Text input             | Press Ctrl+Shift+U                                  | ✅ Converts to uppercase         | Low      |

### Error Handling Test Cases

| ID     | Scenario            | Steps                         | Expected Error Message                                 | Recovery Action          |
| ------ | ------------------- | ----------------------------- | ------------------------------------------------------ | ------------------------ |
| TTE001 | Malformed JSON      | Enter `{"test":}` in JSON tab | "JSON syntax error on line 1: Expected property value" | Fix automatically option |
| TTE002 | Empty Input         | Click operation with no text  | "Please enter some text to process"                    | Show examples            |
| TTE003 | Oversized Input     | Paste >1MB text               | "Text exceeds 1MB limit. Please reduce size."          | Split text option        |
| TTE004 | Invalid URL         | Enter "not-a-url" in URL tab  | "Please enter a valid URL starting with http://"       | Format suggestion        |
| TTE005 | Generation Overflow | Request 10,000 UUIDs          | "Maximum 1,000 items can be generated at once"         | Reduce quantity          |
| TTE006 | Network Timeout     | Large operation timeout       | "Operation timed out. Please try again."               | Retry button             |
| TTE007 | Browser Memory      | Extremely large text          | "Browser memory limit reached. Try smaller text."      | Split operation          |
| TTE008 | Corrupted Clipboard | Copy operation fails          | "Failed to copy to clipboard. Try manual selection."   | Manual copy              |

### Cross-Tool Integration Test Cases

| ID     | Integration      | Steps                              | Expected Result                        | Data Validation            |
| ------ | ---------------- | ---------------------------------- | -------------------------------------- | -------------------------- |
| TTI001 | From JSON Doctor | Share formatted JSON to Text Tools | ✅ JSON appears in text input          | Content matches source     |
| TTI002 | To QR Maker      | Share processed text to QR tool    | ✅ QR tool opens with text             | Text pre-filled correctly  |
| TTI003 | To Regex Tester  | Share text pattern to Regex tool   | ✅ Pattern pre-filled in regex         | Pattern syntax valid       |
| TTI004 | From CSV Cleaner | Share CSV data as text             | ✅ CSV content in text format          | Headers and data preserved |
| TTI005 | Round-trip Data  | Text → QR → back to Text Tools     | ✅ Data preserved through chain        | No data corruption         |
| TTI006 | Multiple Formats | Share as both text and JSON        | ✅ Target tool receives correct format | Format validation          |
| TTI007 | Deep Link Share  | Open with share parameter          | ✅ Tool opens with shared data         | Deep link parsing works    |
| TTI008 | Large Data Share | Share 100KB text to another tool   | ✅ Large data transfer works           | Performance acceptable     |

### Performance Test Cases

| ID     | Scenario            | Input Size         | Expected Time | Acceptance Criteria     |
| ------ | ------------------- | ------------------ | ------------- | ----------------------- |
| TTP001 | Small Text          | 1KB                | <50ms         | Instant response        |
| TTP002 | Medium Text         | 100KB              | <200ms        | Responsive feel         |
| TTP003 | Large Text          | 1MB                | <1000ms       | Acceptable delay        |
| TTP004 | UUID Generation     | 100 items          | <100ms        | Batch efficiency        |
| TTP005 | UUID Generation     | 1000 items         | <500ms        | Maximum batch           |
| TTP006 | JSON Formatting     | 10KB JSON          | <100ms        | Complex parsing         |
| TTP007 | Text Analysis       | 50KB text          | <300ms        | Statistical computation |
| TTP008 | Multiple Operations | Chain 5 operations | <500ms        | Workflow efficiency     |

### Accessibility Test Cases

| ID     | Feature             | Test Method                | Expected Result           |
| ------ | ------------------- | -------------------------- | ------------------------- |
| TTA001 | Keyboard Navigation | Tab through interface      | All controls reachable    |
| TTA002 | Screen Reader       | Use VoiceOver/NVDA         | All content announced     |
| TTA003 | Focus Indicators    | Tab navigation             | Clear focus visibility    |
| TTA004 | Keyboard Shortcuts  | Press Ctrl+Shift+T         | Title case applied        |
| TTA005 | High Contrast       | Enable high contrast mode  | All text readable         |
| TTA006 | Large Text          | Increase browser text size | Interface scales properly |
| TTA007 | ARIA Labels         | Screen reader testing      | Button purposes clear     |
| TTA008 | Error Announcements | Trigger validation error   | Error read immediately    |

## 2. Automated Test Coverage

### Unit Test Files

```
test/tools/text_tools/
├── logic/
│   ├── case_convert_test.dart
│   ├── clean_text_test.dart
│   ├── json_tools_test.dart
│   ├── counters_test.dart
│   ├── uuid_gen_test.dart
│   ├── nanoid_gen_test.dart
│   └── slugify_test.dart
├── text_tools_screen_test.dart
└── widgets/
    ├── case_tab_test.dart
    ├── clean_tab_test.dart
    ├── generate_tab_test.dart
    ├── analyze_tab_test.dart
    ├── json_tab_test.dart
    └── url_tab_test.dart
```

### Key Test Functions

#### Case Conversion Tests

```dart
group('CaseConverter', () {
  test('converts to title case correctly', () {
    expect(CaseConverter.toTitleCase('hello world'), 'Hello World');
    expect(CaseConverter.toTitleCase('HELLO WORLD'), 'Hello World');
    expect(CaseConverter.toTitleCase('hELLo WoRLd'), 'Hello World');
  });

  test('converts to snake_case correctly', () {
    expect(CaseConverter.toSnakeCase('Hello World'), 'hello_world');
    expect(CaseConverter.toSnakeCase('helloWorld'), 'hello_world');
    expect(CaseConverter.toSnakeCase('HelloWorldTest'), 'hello_world_test');
  });

  test('handles edge cases', () {
    expect(CaseConverter.toTitleCase(''), '');
    expect(CaseConverter.toTitleCase('a'), 'A');
    expect(CaseConverter.toTitleCase('  hello  world  '), '  Hello  World  ');
  });
});
```

#### Text Cleaning Tests

```dart
group('TextCleaner', () {
  test('removes extra spaces correctly', () {
    expect(TextCleaner.removeExtraSpaces('hello    world'), 'hello world');
    expect(TextCleaner.removeExtraSpaces('  hello  world  '), ' hello world ');
  });

  test('removes empty lines', () {
    final input = 'line1\n\n\nline2\n\nline3';
    final expected = 'line1\nline2\nline3';
    expect(TextCleaner.removeEmptyLines(input), expected);
  });

  test('removes HTML tags', () {
    expect(TextCleaner.removeHtmlTags('<p>Hello</p>'), 'Hello');
    expect(TextCleaner.removeHtmlTags('<div><span>Test</span></div>'), 'Test');
  });
});
```

#### JSON Processing Tests

```dart
group('JsonProcessor', () {
  test('validates JSON correctly', () {
    expect(JsonProcessor.isValid('{"test": true}'), true);
    expect(JsonProcessor.isValid('{"test":}'), false);
    expect(JsonProcessor.isValid('invalid'), false);
  });

  test('formats JSON properly', () {
    final input = '{"name":"John","age":30}';
    final result = JsonProcessor.format(input);
    expect(result, contains('  "name": "John"'));
    expect(result, contains('  "age": 30'));
  });
});
```

#### Text Analysis Tests

```dart
group('TextAnalyzer', () {
  test('counts words accurately', () {
    expect(TextAnalyzer.countWords('hello world'), 2);
    expect(TextAnalyzer.countWords('hello,world.test'), 3);
    expect(TextAnalyzer.countWords(''), 0);
  });

  test('counts characters correctly', () {
    expect(TextAnalyzer.countCharacters('hello'), 5);
    expect(TextAnalyzer.countCharacters('hello world'), 11);
    expect(TextAnalyzer.countCharacters(''), 0);
  });

  test('calculates reading time', () {
    final text = List.generate(200, (i) => 'word').join(' ');
    final time = TextAnalyzer.estimateReadingTime(text);
    expect(time.inMinutes, greaterThan(0));
  });
});
```

### Widget Test Coverage

#### Screen Widget Tests

```dart
testWidgets('TextToolsScreen loads correctly', (tester) async {
  await tester.pumpWidget(MaterialApp(
    home: TextToolsScreen(),
  ));

  expect(find.byType(TabBar), findsOneWidget);
  expect(find.byType(TextField), findsNWidgets(2)); // Input and output
  expect(find.text('Text Tools'), findsOneWidget);
});

testWidgets('Tab navigation works', (tester) async {
  await tester.pumpWidget(MaterialApp(home: TextToolsScreen()));

  // Test all tabs are present
  expect(find.byIcon(Icons.text_format), findsOneWidget); // Case tab
  expect(find.byIcon(Icons.cleaning_services), findsOneWidget); // Clean tab
  expect(find.byIcon(Icons.auto_awesome), findsOneWidget); // Generate tab

  // Test tab switching
  await tester.tap(find.byIcon(Icons.cleaning_services));
  await tester.pumpAndSettle();

  // Verify clean tab content loaded
  expect(find.text('Remove Spaces'), findsOneWidget);
});
```

#### Operation Button Tests

```dart
testWidgets('Case conversion buttons work', (tester) async {
  await tester.pumpWidget(MaterialApp(home: TextToolsScreen()));

  // Enter test text
  await tester.enterText(find.byType(TextField).first, 'hello world');

  // Click title case button
  await tester.tap(find.text('Title Case'));
  await tester.pumpAndSettle();

  // Verify output
  final outputField = find.byType(TextField).last;
  expect(tester.widget<TextField>(outputField).controller?.text, 'Hello World');
});
```

### Integration Test Coverage

#### Cross-Tool Integration Tests

```dart
testWidgets('Share to QR Maker works', (tester) async {
  await tester.pumpWidget(TestApp()); // Full app context

  // Navigate to Text Tools
  await tester.tap(find.text('Text Tools'));
  await tester.pumpAndSettle();

  // Process some text
  await tester.enterText(find.byType(TextField).first, 'test content');
  await tester.tap(find.text('Title Case'));
  await tester.pumpAndSettle();

  // Share to QR Maker
  await tester.tap(find.byIcon(Icons.share));
  await tester.pumpAndSettle();
  await tester.tap(find.text('QR Maker'));
  await tester.pumpAndSettle();

  // Verify navigation and data transfer
  expect(find.text('QR Maker'), findsOneWidget);
  expect(find.text('Test Content'), findsOneWidget); // Title case applied
});
```

### Performance Test Coverage

#### Load Testing

```dart
group('Performance Tests', () {
  test('handles large text efficiently', () async {
    final largeText = 'word ' * 10000; // ~50KB text
    final stopwatch = Stopwatch()..start();

    final result = CaseConverter.toTitleCase(largeText);

    stopwatch.stop();
    expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    expect(result, startsWith('Word '));
  });

  test('batch generation performs well', () async {
    final stopwatch = Stopwatch()..start();

    final uuids = UuidGenerator.generateBatch(1000);

    stopwatch.stop();
    expect(stopwatch.elapsedMilliseconds, lessThan(500));
    expect(uuids.length, 1000);
    expect(uuids.toSet().length, 1000); // All unique
  });
});
```

## 3. Test Data & Fixtures

### Sample Text Files

```
test/fixtures/text_tools/
├── sample_texts.dart
├── json_samples.dart
├── html_samples.dart
├── csv_samples.dart
└── expected_outputs.dart
```

#### Sample Text Data

```dart
class SampleTexts {
  static const simple = 'hello world';
  static const mixed_case = 'HeLLo WoRLd';
  static const with_numbers = 'hello123world456';
  static const with_special = 'hello@world#test';
  static const multiline = '''
Line 1
Line 2

Line 4
''';

  static const large_text = '''
Lorem ipsum dolor sit amet, consectetur adipiscing elit...
[Generated 10KB+ text for performance testing]
''';
}
```

#### JSON Test Samples

```dart
class JsonSamples {
  static const valid_simple = '{"name": "John", "age": 30}';
  static const valid_complex = '''
{
  "users": [
    {"id": 1, "name": "John", "active": true},
    {"id": 2, "name": "Jane", "active": false}
  ],
  "meta": {"count": 2, "page": 1}
}
''';

  static const invalid_syntax = '{"name": "John",}';
  static const invalid_structure = '{"name":}';
  static const malformed = '{name: John}';
}
```

### Expected Output Validation

```dart
class ExpectedOutputs {
  static const case_conversions = {
    'hello world': {
      'title': 'Hello World',
      'upper': 'HELLO WORLD',
      'lower': 'hello world',
      'snake': 'hello_world',
      'camel': 'helloWorld',
      'pascal': 'HelloWorld',
      'kebab': 'hello-world',
      'constant': 'HELLO_WORLD',
    }
  };

  static const text_cleaning = {
    'hello    world   ': {
      'remove_spaces': 'hello world',
      'trim': 'hello    world',
    },
    '<p>Hello</p>': {
      'remove_html': 'Hello',
    }
  };
}
```

## 4. Test Execution & CI/CD

### Local Test Execution

```bash
# Run all text tools tests
flutter test test/tools/text_tools/

# Run specific test file
flutter test test/tools/text_tools/logic/case_convert_test.dart

# Run with coverage
flutter test --coverage test/tools/text_tools/
```

### CI/CD Integration

```yaml
# GitHub Actions workflow snippet
- name: Run Text Tools Tests
  run: flutter test test/tools/text_tools/ --reporter=github

- name: Upload Test Results
  uses: actions/upload-artifact@v3
  with:
    name: text-tools-test-results
    path: test-results.xml
```

### Test Coverage Requirements

- **Unit Tests:** >95% code coverage for logic functions
- **Widget Tests:** >90% coverage for UI components
- **Integration Tests:** 100% of cross-tool workflows
- **Performance Tests:** All operations under target times

This comprehensive test documentation ensures Text Tools maintains high quality and reliability across all features and integrations.
