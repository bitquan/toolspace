# Text Tools - Integration Documentation

**Last Updated:** October 11, 2025  
**Version:** 2.3.0  
**Owner:** Text Tools Team

## 1. Deep Link Integration

### Route Structure

**Base Route:** `/tools/text-tools`

### Query Parameters

#### Content Parameter

```
/tools/text-tools?content=Hello%20World
```

Pre-fills the input area with decoded content.

**Implementation:**

```dart
void _handleDeepLink() {
  final uri = Uri.base;
  final content = uri.queryParameters['content'];
  if (content != null) {
    _inputController.text = Uri.decodeComponent(content);
    _processInput();
  }
}
```

#### Operation Parameter

```
/tools/text-tools?content=hello%20world&operation=title_case
```

Pre-fills content and automatically applies the specified operation.

**Supported Operations:**

- `title_case` - Apply title case transformation
- `upper_case` - Convert to uppercase
- `lower_case` - Convert to lowercase
- `snake_case` - Convert to snake_case
- `camel_case` - Convert to camelCase
- `format_json` - Format JSON content
- `minify_json` - Minify JSON content
- `analyze` - Show analysis tab with statistics

#### Tab Parameter

```
/tools/text-tools?tab=json&content={"test":true}
```

Opens specific tab and pre-fills content.

**Supported Tabs:**

- `case` - Case conversion tab (default)
- `clean` - Text cleaning tab
- `generate` - Text generation tab
- `analyze` - Text analysis tab
- `json` - JSON processing tab
- `url` - URL and encoding tab

#### Share Parameter

```
/tools/text-tools?share=abc123&intent=replace
```

Retrieves shared data from HandoffStore and applies with specified intent.

**Share Implementation:**

```dart
void _handleShareParameter() {
  final uri = Uri.base;
  final shareKey = uri.queryParameters['share'];
  final intentStr = uri.queryParameters['intent'];

  if (shareKey != null) {
    final envelope = HandoffStore.retrieve(shareKey);
    if (envelope != null) {
      final intent = ShareIntent.values.firstWhere(
        (i) => i.name == intentStr,
        orElse: () => ShareIntent.replace,
      );
      _handleIncomingShare(ShareEvent(envelope));
    }
  }
}
```

## 2. ShareBus Integration

### Outgoing Data Types

#### Text Data Type

**Used when:** Sharing processed text to other tools

```dart
ShareEnvelope textEnvelope = ShareEnvelope(
  sourceToolId: 'text_tools',
  targetToolId: null, // User selects target
  dataType: 'text',
  data: {
    'content': _outputController.text,
    'format': 'plain',
    'encoding': 'utf8',
    'operation': _lastOperation,
    'originalLength': _inputController.text.length,
    'transformedLength': _outputController.text.length,
    'timestamp': DateTime.now().toIso8601String(),
  },
  intent: ShareIntent.replace,
  timestamp: DateTime.now(),
  userId: FirebaseAuth.instance.currentUser?.uid,
);
```

**Compatible Target Tools:**

- `qr_maker` - Generate QR codes from processed text
- `regex_tester` - Test patterns against processed text
- `json_doctor` - Validate if text is JSON
- `url_short` - Shorten URLs found in text
- `md_to_pdf` - Convert markdown text to PDF

#### JSON Data Type

**Used when:** Sharing formatted JSON to JSON-specific tools

```dart
ShareEnvelope jsonEnvelope = ShareEnvelope(
  sourceToolId: 'text_tools',
  targetToolId: 'json_doctor',
  dataType: 'json',
  data: {
    'object': jsonObject,
    'formatted': _outputController.text,
    'minified': jsonEncode(jsonObject),
    'isValid': true,
    'schema': null, // Generated if available
    'size': _outputController.text.length,
  },
  intent: ShareIntent.replace,
  timestamp: DateTime.now(),
);
```

**Compatible Target Tools:**

- `json_doctor` - Advanced JSON processing
- `json_flatten` - Flatten JSON structure
- `csv_cleaner` - Convert JSON to CSV

#### Regex Pattern Data Type

**Used when:** Sharing generated patterns to regex tester

```dart
ShareEnvelope regexEnvelope = ShareEnvelope(
  sourceToolId: 'text_tools',
  targetToolId: 'regex_tester',
  dataType: 'regex_pattern',
  data: {
    'pattern': generatedPattern,
    'flags': ['g', 'i'],
    'testString': _inputController.text,
    'description': 'Pattern generated from text analysis',
  },
  intent: ShareIntent.replace,
  timestamp: DateTime.now(),
);
```

### Incoming Data Types

#### Text from Any Tool

```dart
void _handleTextShare(ShareEnvelope envelope) {
  final content = envelope.data['content'] as String;
  final format = envelope.data['format'] as String?;

  switch (envelope.intent) {
    case ShareIntent.replace:
      _inputController.text = content;
      break;
    case ShareIntent.append:
      _inputController.text += '\n$content';
      break;
    case ShareIntent.template:
      _showTemplateDialog(content);
      break;
  }

  // Auto-select appropriate tab based on format
  if (format == 'json') {
    _tabController.animateTo(4); // JSON tab
  } else if (format == 'url') {
    _tabController.animateTo(5); // URL tab
  }
}
```

#### JSON from JSON Doctor

```dart
void _handleJsonShare(ShareEnvelope envelope) {
  final formatted = envelope.data['formatted'] as String;
  final isValid = envelope.data['isValid'] as bool;

  _inputController.text = formatted;
  _tabController.animateTo(4); // Switch to JSON tab

  if (!isValid) {
    _showJsonValidationWarning();
  }
}
```

#### CSV from CSV Cleaner

```dart
void _handleCsvShare(ShareEnvelope envelope) {
  final headers = envelope.data['headers'] as List<String>;
  final rows = envelope.data['rows'] as List<List<String>>;

  // Convert CSV to text format
  final csvText = [headers, ...rows]
    .map((row) => row.join(','))
    .join('\n');

  _inputController.text = csvText;
  _tabController.animateTo(1); // Switch to clean tab for processing
}
```

#### Markdown from Markdown to PDF

```dart
void _handleMarkdownShare(ShareEnvelope envelope) {
  final content = envelope.data['content'] as String;
  final frontmatter = envelope.data['frontmatter'] as Map<String, dynamic>?;

  _inputController.text = content;

  // Show frontmatter if present
  if (frontmatter != null) {
    _showFrontmatterInfo(frontmatter);
  }
}
```

## 3. Cross-Tool Workflow Examples

### Text Processing Chain

1. **CSV Cleaner** → cleans data file
2. **Share as Text** → sends to Text Tools
3. **Text Tools** → processes and formats data
4. **Share to QR** → generates QR for processed text

**Flow Implementation:**

```dart
// Step 1: Receive from CSV Cleaner
void _receiveCsvData(ShareEnvelope envelope) {
  _handleCsvShare(envelope);
  _showWorkflowTip('Data received from CSV Cleaner. Try cleaning operations!');
}

// Step 2: Process text
void _applyCleanOperations() {
  // Apply multiple cleaning operations
  _removeExtraSpaces();
  _removeEmptyLines();
  _sortLines();
}

// Step 3: Share to QR Maker
void _shareToQR() {
  final envelope = ShareEnvelope(
    sourceToolId: 'text_tools',
    targetToolId: 'qr_maker',
    dataType: 'text',
    data: {'content': _outputController.text},
    intent: ShareIntent.replace,
  );

  ShareBus.instance.shareToTool('qr_maker', envelope);
  Navigator.pushNamed(context, '/tools/qr-maker');
}
```

### JSON Processing Workflow

1. **Text Tools** → receives raw JSON text
2. **JSON formatting** → validates and formats
3. **Share to JSON Doctor** → advanced processing
4. **JSON Doctor** → transforms structure
5. **Share back to Text Tools** → final text formatting

### Document Preparation Workflow

1. **Text Tools** → formats and cleans content
2. **Share to Markdown** → structures as markdown
3. **Markdown to PDF** → generates final document
4. **Share file to merger** → combines with other docs

## 4. Handoff Store Integration

### Storing Data for Later Retrieval

```dart
void _storeForLaterRetrieval(String targetTool) {
  final dataKey = 'text_tools_${DateTime.now().millisecondsSinceEpoch}';
  final envelope = ShareEnvelope(
    sourceToolId: 'text_tools',
    targetToolId: targetTool,
    dataType: 'text',
    data: {'content': _outputController.text},
    intent: ShareIntent.replace,
    timestamp: DateTime.now(),
  );

  HandoffStore.store(dataKey, envelope);

  // Create deep link
  final deepLink = '/tools/$targetTool?share=$dataKey';
  _showDeepLinkDialog(deepLink);
}
```

### Retrieving Stored Data

```dart
void _checkForStoredData() {
  final uri = Uri.base;
  final shareKey = uri.queryParameters['share'];

  if (shareKey != null && HandoffStore.hasData(shareKey)) {
    final envelope = HandoffStore.retrieve(shareKey);
    if (envelope != null) {
      _handleIncomingShare(ShareEvent(envelope));
      _showRestoredDataNotification();
    }
  }
}
```

## 5. External App Integration

### Web Share API

```dart
void _handleWebShare() async {
  if (kIsWeb) {
    try {
      await html.window.navigator.share({
        'title': 'Processed Text from Toolspace',
        'text': _outputController.text,
        'url': 'https://toolspace.app/tools/text-tools',
      });
    } catch (e) {
      // Fallback to clipboard
      _copyToClipboard();
    }
  }
}
```

### File System Integration

```dart
void _handleFileInput() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['txt', 'json', 'md', 'csv'],
    withData: true,
  );

  if (result != null && result.files.single.bytes != null) {
    final content = utf8.decode(result.files.single.bytes!);
    _inputController.text = content;

    // Auto-detect format and switch tab
    _autoDetectFormat(content);
  }
}

void _autoDetectFormat(String content) {
  if (_isValidJson(content)) {
    _tabController.animateTo(4); // JSON tab
  } else if (_containsUrls(content)) {
    _tabController.animateTo(5); // URL tab
  } else if (_needsCleaning(content)) {
    _tabController.animateTo(1); // Clean tab
  }
}
```

### Clipboard Integration

```dart
void _handleClipboardData() async {
  final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
  if (clipboardData?.text != null) {
    _inputController.text = clipboardData!.text!;
    _autoDetectFormat(clipboardData.text!);
    _showPasteConfirmation();
  }
}
```

## 6. Error Handling & Recovery

### Share Errors

```dart
void _handleShareError(ShareException error) {
  switch (error.errorCode) {
    case 'UNSUPPORTED_TYPE':
      _showConversionOptions(error.message);
      break;
    case 'SIZE_EXCEEDED':
      _showSizeReductionOptions();
      break;
    case 'INVALID_DATA':
      _showDataValidationHelp();
      break;
    default:
      _showGenericShareError(error.message);
  }
}

void _showConversionOptions(String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Data Type Not Supported'),
      content: Text('$message\n\nWould you like to share as plain text instead?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            _shareAsPlainText();
          },
          child: Text('Share as Text'),
        ),
      ],
    ),
  );
}
```

### Deep Link Errors

```dart
void _handleDeepLinkError(String error) {
  switch (error) {
    case 'EXPIRED_SHARE':
      _showExpiredShareDialog();
      break;
    case 'INVALID_CONTENT':
      _showInvalidContentDialog();
      break;
    case 'CORRUPTED_DATA':
      _showCorruptedDataDialog();
      break;
  }
}
```

## 7. Analytics & Tracking

### Share Event Tracking

```dart
void _trackShareEvent(String targetTool, String dataType) {
  FirebaseAnalytics.instance.logEvent(
    name: 'tool_share',
    parameters: {
      'source_tool': 'text_tools',
      'target_tool': targetTool,
      'data_type': dataType,
      'content_length': _outputController.text.length,
      'operation_used': _lastOperation,
      'timestamp': DateTime.now().toIso8601String(),
    },
  );
}
```

### Integration Performance Tracking

```dart
void _trackIntegrationPerformance() {
  final loadTime = DateTime.now().difference(_shareStartTime);

  FirebaseAnalytics.instance.logEvent(
    name: 'integration_performance',
    parameters: {
      'tool_id': 'text_tools',
      'operation': 'share_data',
      'load_time_ms': loadTime.inMilliseconds,
      'data_size_kb': (_outputController.text.length / 1024).round(),
      'success': true,
    },
  );
}
```

This integration documentation provides complete cross-tool communication patterns and external integration capabilities for Text Tools with zero placeholders.
