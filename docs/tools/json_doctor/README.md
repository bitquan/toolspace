# JSON Doctor - Complete Tool Documentation

**Tool ID:** `json_doctor`  
**Route:** `/tools/json-doctor`  
**Category:** Development Tools  
**Heavy Op:** Large JSON validation & schema analysis  
**Owner Code:** lib/tools/json_doctor/json_doctor_screen.dart  
**Billing:** Pro+ for batch operations, schema library access  
**Current Version:** v2.1.3  
**Last Updated:** October 11, 2025

## 1. Overview

JSON Doctor is Toolspace's most comprehensive JSON processing tool, providing real-time validation, intelligent error correction, schema validation, and JSONPath querying capabilities. It serves developers, API engineers, and data analysts who work with complex JSON structures daily.

**Core Capabilities:**

- **Real-time Validation**: Instant JSON syntax checking with detailed error reporting
- **Intelligent Repair**: Automatic fixing of common JSON formatting issues
- **Schema Validation**: Full JSON Schema Draft 7 support with comprehensive error mapping
- **JSONPath Queries**: Advanced data extraction with query builder and result preview
- **Cross-tool Integration**: Seamless data sharing via ShareBus with type preservation
- **Professional Formatting**: Multiple formatting styles with customizable indentation

### 1.1 Key Features

#### Validation Engine

```dart
// Core validation status tracking
enum JsonDoctorStatus {
  empty,       // No input provided
  valid,       // Valid JSON detected
  invalid,     // Syntax errors found
  repairing,   // Auto-repair in progress
  repaired,    // Successfully repaired
  schemaValid, // Passes schema validation
  schemaError, // Schema validation failed
}
```

#### Multi-Modal Processing

- **Tab 1: Validate & Fix** - Primary JSON validation and repair interface
- **Tab 2: Schema** - JSON Schema validation with detailed error reporting
- **Tab 3: JSONPath** - Advanced querying and data extraction tools

#### Professional Features

- **Real-time Processing**: Sub-100ms validation response times
- **Intelligent Error Detection**: Contextual error messages with fix suggestions
- **Batch Operations**: Process multiple JSON files simultaneously (Pro+ feature)
- **Export Options**: Multiple output formats (JSON, CSV, XML) with structure preservation

### 1.2 Target Users

#### Primary Audiences

```dart
class TargetUsers {
  static const Map<String, List<String>> userSegments = {
    'api_developers': [
      'REST API testing and validation',
      'Request/response debugging',
      'Schema design and validation',
      'API documentation generation',
    ],
    'data_engineers': [
      'Data pipeline validation',
      'ETL process debugging',
      'Schema migration testing',
      'Data quality assurance',
    ],
    'frontend_developers': [
      'Component data validation',
      'State management debugging',
      'API integration testing',
      'Configuration file validation',
    ],
    'qa_engineers': [
      'Test data validation',
      'API response verification',
      'Integration testing support',
      'Automated testing scenarios',
    ],
  };
}
```

## 2. Features

### 2.1 JSON Validation & Repair

#### Real-time Syntax Validation

```dart
// Validation implementation with detailed error tracking
class JsonValidator {
  static ValidationResult validateJson(String input) {
    if (input.trim().isEmpty) {
      return ValidationResult(status: JsonDoctorStatus.empty);
    }

    try {
      final decoded = jsonDecode(input);
      return ValidationResult(
        status: JsonDoctorStatus.valid,
        data: decoded,
        message: 'Valid JSON structure detected',
      );
    } catch (e) {
      return ValidationResult(
        status: JsonDoctorStatus.invalid,
        error: _parseJsonError(e),
        suggestedFix: _generateRepairSuggestion(e, input),
      );
    }
  }

  // Intelligent error parsing for user-friendly messages
  static JsonError _parseJsonError(FormatException e) {
    final message = e.message;
    final offset = e.offset ?? 0;

    if (message.contains('Unexpected character')) {
      return JsonError(
        type: JsonErrorType.unexpectedCharacter,
        position: offset,
        description: 'Invalid character found',
        suggestion: 'Check for missing quotes or commas',
      );
    }
    // Additional error pattern matching...
  }
}
```

#### Intelligent Auto-Repair

```dart
// Smart JSON repair capabilities
class JsonRepairer {
  static RepairResult attemptRepair(String brokenJson) {
    String repaired = brokenJson;
    final repairs = <RepairAction>[];

    // Fix common issues in order of complexity
    repaired = _fixMissingQuotes(repaired, repairs);
    repaired = _fixTrailingCommas(repaired, repairs);
    repaired = _fixMissingCommas(repaired, repairs);
    repaired = _fixBracketMismatches(repaired, repairs);
    repaired = _fixEscapeSequences(repaired, repairs);

    // Validate repair success
    try {
      final validated = jsonDecode(repaired);
      return RepairResult(
        success: true,
        repairedJson: repaired,
        appliedRepairs: repairs,
        validatedData: validated,
      );
    } catch (e) {
      return RepairResult(
        success: false,
        originalError: e.toString(),
        attemptedRepairs: repairs,
      );
    }
  }

  // Specific repair functions for common JSON issues
  static String _fixMissingQuotes(String json, List<RepairAction> repairs) {
    // Regex patterns for unquoted keys and values
    final keyPattern = RegExp(r'(\s*)([a-zA-Z_][a-zA-Z0-9_]*)\s*:');
    final matches = keyPattern.allMatches(json);

    String result = json;
    for (final match in matches.toList().reversed) {
      final key = match.group(2)!;
      if (!_isAlreadyQuoted(json, match.start)) {
        result = result.replaceRange(
          match.start,
          match.end,
          '${match.group(1)}"$key":',
        );
        repairs.add(RepairAction(
          type: RepairType.addQuotes,
          position: match.start,
          description: 'Added quotes around key: $key',
        ));
      }
    }

    return result;
  }
}
```

### 2.2 Schema Validation

#### JSON Schema Support

```dart
// Comprehensive schema validation engine
class SchemaValidator {
  // Support for JSON Schema Draft 7 specifications
  static const Set<String> supportedKeywords = {
    'type', 'properties', 'required', 'items', 'additionalProperties',
    'minimum', 'maximum', 'minLength', 'maxLength', 'pattern',
    'enum', 'const', 'format', 'multipleOf', 'uniqueItems',
    'minItems', 'maxItems', 'minProperties', 'maxProperties',
    'if', 'then', 'else', 'allOf', 'anyOf', 'oneOf', 'not',
  };

  static SchemaValidationResult validate(dynamic data, Map<String, dynamic> schema) {
    final errors = <SchemaValidationError>[];
    final context = ValidationContext(rootSchema: schema);

    _validateNode(data, schema, '', errors, context);

    return SchemaValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      validatedPaths: context.validatedPaths,
      skippedPaths: context.skippedPaths,
    );
  }

  // Detailed validation for different JSON types
  static void _validateNode(
    dynamic data,
    dynamic schema,
    String path,
    List<SchemaValidationError> errors,
    ValidationContext context,
  ) {
    if (schema is! Map<String, dynamic>) return;

    // Type validation
    if (schema.containsKey('type')) {
      _validateType(data, schema['type'], path, errors);
    }

    // Property validation for objects
    if (data is Map && schema.containsKey('properties')) {
      _validateObjectProperties(data, schema, path, errors, context);
    }

    // Array validation
    if (data is List && schema.containsKey('items')) {
      _validateArrayItems(data, schema, path, errors, context);
    }

    // String format validation
    if (data is String && schema.containsKey('format')) {
      _validateStringFormat(data, schema['format'], path, errors);
    }

    // Numeric constraints
    if (data is num) {
      _validateNumericConstraints(data, schema, path, errors);
    }
  }
}
```

#### Advanced Schema Features

```dart
// Support for complex schema patterns
class AdvancedSchemaFeatures {
  // Conditional validation (if/then/else)
  static void validateConditionalSchema(
    dynamic data,
    Map<String, dynamic> schema,
    String path,
    List<SchemaValidationError> errors,
  ) {
    if (!schema.containsKey('if')) return;

    final ifSchema = schema['if'];
    final ifResult = SchemaValidator.validate(data, ifSchema);

    if (ifResult.isValid && schema.containsKey('then')) {
      SchemaValidator._validateNode(data, schema['then'], path, errors, context);
    } else if (!ifResult.isValid && schema.containsKey('else')) {
      SchemaValidator._validateNode(data, schema['else'], path, errors, context);
    }
  }

  // Composition validation (allOf, anyOf, oneOf)
  static void validateComposition(
    dynamic data,
    Map<String, dynamic> schema,
    String path,
    List<SchemaValidationError> errors,
  ) {
    // allOf - must pass all schemas
    if (schema.containsKey('allOf')) {
      final allOfSchemas = schema['allOf'] as List;
      for (int i = 0; i < allOfSchemas.length; i++) {
        final subSchema = allOfSchemas[i];
        final result = SchemaValidator.validate(data, subSchema);
        if (!result.isValid) {
          errors.add(SchemaValidationError(
            path: path,
            message: 'Failed allOf validation at index $i',
            expectedType: 'allOf constraint',
            actualType: data.runtimeType.toString(),
            actualValue: data,
            subErrors: result.errors,
          ));
        }
      }
    }

    // anyOf - must pass at least one schema
    if (schema.containsKey('anyOf')) {
      final anyOfSchemas = schema['anyOf'] as List;
      bool anyPassed = false;

      for (final subSchema in anyOfSchemas) {
        final result = SchemaValidator.validate(data, subSchema);
        if (result.isValid) {
          anyPassed = true;
          break;
        }
      }

      if (!anyPassed) {
        errors.add(SchemaValidationError(
          path: path,
          message: 'Failed to match any schema in anyOf',
          expectedType: 'anyOf constraint',
          actualType: data.runtimeType.toString(),
          actualValue: data,
        ));
      }
    }
  }
}
```

### 2.3 JSONPath Queries

#### Query Engine

```dart
// Advanced JSONPath implementation with multiple syntax support
class JsonPathEngine {
  static const Map<String, String> syntaxExamples = {
    'root_access': r'$ - Root element',
    'property_access': r'$.store.book - Direct property access',
    'array_index': r'$.store.book[0] - First array element',
    'array_slice': r'$.store.book[1:3] - Array slice',
    'wildcard': r'$.store.book[*] - All array elements',
    'recursive_descent': r'$..price - All price properties',
    'filter_expression': r'$.store.book[?(@.price < 10)] - Conditional filter',
    'multiple_conditions': r'$.store.book[?(@.price < 10 && @.category == "fiction")]',
  };

  static QueryResult executeQuery(dynamic data, String jsonPath) {
    try {
      final parser = JsonPathParser(jsonPath);
      final query = parser.parse();
      final results = query.execute(data);

      return QueryResult(
        success: true,
        results: results,
        resultCount: results.length,
        executionTime: parser.executionTime,
        parsedQuery: query,
      );
    } catch (e) {
      return QueryResult(
        success: false,
        error: e.toString(),
        suggestion: _generateQuerySuggestion(jsonPath, e),
      );
    }
  }

  // Query builder for common patterns
  static String buildQuery(QueryPattern pattern, Map<String, dynamic> params) {
    switch (pattern) {
      case QueryPattern.findByProperty:
        return '\$..*[?(@.${params['property']} == "${params['value']}")]';
      case QueryPattern.filterByRange:
        return '\$.${params['path']}[?(@.${params['field']} >= ${params['min']} && @.${params['field']} <= ${params['max']})]';
      case QueryPattern.extractFields:
        final fields = params['fields'] as List<String>;
        return '\$..*[${fields.map((f) => '"$f"').join(',')}]';
      default:
        return jsonPath;
    }
  }
}
```

#### Interactive Query Builder

```dart
// GUI components for JSONPath query construction
class QueryBuilder extends StatefulWidget {
  final Function(String) onQueryChanged;
  final dynamic jsonData;

  const QueryBuilder({
    required this.onQueryChanged,
    required this.jsonData,
    Key? key,
  }) : super(key: key);

  @override
  State<QueryBuilder> createState() => _QueryBuilderState();
}

class _QueryBuilderState extends State<QueryBuilder> {
  String _currentPath = '\$';
  final List<QueryStep> _steps = [];

  // Visual query builder with drag-and-drop interface
  Widget buildQueryVisualizer() {
    return Column(
      children: [
        // Path breadcrumb navigation
        PathBreadcrumb(
          path: _currentPath,
          onPathChanged: _updatePath,
        ),

        // Available operations
        QueryOperationsPanel(
          availableOperations: _getAvailableOperations(),
          onOperationSelected: _addQueryStep,
        ),

        // Query preview with syntax highlighting
        QueryPreview(
          query: _buildQueryString(),
          onQueryEdit: _handleManualEdit,
        ),

        // Real-time result preview
        ResultPreview(
          data: widget.jsonData,
          query: _buildQueryString(),
        ),
      ],
    );
  }
}
```

### 2.4 Cross-Tool Integration

#### ShareBus Integration

```dart
// Enhanced ShareBus support for JSON data
class JsonDoctorShareBus {
  static const String toolId = 'json_doctor';
  static const String version = '2.1.3';

  // Share different types of JSON-related data
  static Map<String, dynamic> createShareData(JsonShareType type, dynamic data) {
    switch (type) {
      case JsonShareType.validatedJson:
        return {
          'type': 'validated_json',
          'version': version,
          'data': data,
          'validation_status': 'valid',
          'timestamp': DateTime.now().toIso8601String(),
          'source_tool': toolId,
        };

      case JsonShareType.schema:
        return {
          'type': 'json_schema',
          'version': version,
          'schema': data,
          'schema_version': 'draft-07',
          'validation_keywords': SchemaValidator.supportedKeywords.toList(),
          'timestamp': DateTime.now().toIso8601String(),
        };

      case JsonShareType.queryResults:
        return {
          'type': 'jsonpath_results',
          'version': version,
          'results': data['results'],
          'query': data['query'],
          'result_count': data['count'],
          'execution_time_ms': data['execution_time'],
          'timestamp': DateTime.now().toIso8601String(),
        };
    }
  }

  // Handle incoming shared data from other tools
  static Future<void> handleIncomingData(Map<String, dynamic> shareData) async {
    final type = shareData['type'];

    switch (type) {
      case 'json':
      case 'text':
        await _loadJsonData(shareData['data']);
        break;
      case 'csv':
        await _convertCsvToJson(shareData['data']);
        break;
      case 'api_response':
        await _loadApiResponse(shareData);
        break;
      case 'database_export':
        await _loadDatabaseExport(shareData);
        break;
    }
  }
}
```

#### Integration with Other Tools

```dart
// Specific integrations with Toolspace tools
class ToolIntegrations {
  // Text Tools integration
  static Future<void> sendToTextTools(String jsonData) async {
    await SharedDataService.shareData(
      data: jsonData,
      type: SharedDataType.text,
      sourceTool: 'JSON Doctor',
      targetTool: 'Text Tools',
      metadata: {
        'original_format': 'json',
        'processing_hint': 'formatted_json',
      },
    );
  }

  // CSV Cleaner integration
  static Future<void> convertToCsv(dynamic jsonData) async {
    final csvData = JsonToCsvConverter.convert(jsonData);
    await SharedDataService.shareData(
      data: csvData,
      type: SharedDataType.csv,
      sourceTool: 'JSON Doctor',
      targetTool: 'CSV Cleaner',
      metadata: {
        'conversion_type': 'json_to_csv',
        'preserve_structure': true,
      },
    );
  }

  // File Merger integration
  static Future<void> addToFileMerger(List<dynamic> jsonObjects) async {
    for (int i = 0; i < jsonObjects.length; i++) {
      await SharedDataService.shareData(
        data: jsonEncode(jsonObjects[i]),
        type: SharedDataType.json,
        sourceTool: 'JSON Doctor',
        targetTool: 'File Merger',
        metadata: {
          'filename': 'validated_json_$i.json',
          'batch_operation': true,
          'total_files': jsonObjects.length,
        },
      );
    }
  }
}
```

## 3. Technical Implementation

### 3.1 Architecture Overview

#### Core Components

```dart
// Main screen architecture with tab-based navigation
class JsonDoctorScreen extends StatefulWidget {
  // Controllers for different input areas
  final TextEditingController _inputController;
  final TextEditingController _outputController;
  final TextEditingController _schemaController;
  final TextEditingController _jsonPathController;
  final TextEditingController _queryResultController;

  // Animation controllers for visual feedback
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late TabController _tabController;

  // State management
  JsonDoctorStatus _status = JsonDoctorStatus.empty;
  String _errorMessage = '';
  List<SchemaValidationError> _schemaErrors = [];

  // Real-time validation with debouncing
  Timer? _validationTimer;
  static const Duration _validationDelay = Duration(milliseconds: 300);
}
```

#### Performance Optimizations

```dart
// Efficient JSON processing with memory management
class PerformanceOptimizations {
  // Large JSON handling with streaming
  static const int maxJsonSize = 10 * 1024 * 1024; // 10MB
  static const int streamingThreshold = 1024 * 1024; // 1MB

  // Debounced validation to prevent excessive processing
  static Timer? _validationTimer;
  static void debounceValidation(VoidCallback validation) {
    _validationTimer?.cancel();
    _validationTimer = Timer(Duration(milliseconds: 300), validation);
  }

  // Memory-efficient large file processing
  static Future<ValidationResult> validateLargeJson(String json) async {
    if (json.length > streamingThreshold) {
      return _streamingValidation(json);
    } else {
      return _standardValidation(json);
    }
  }

  // Web Worker integration for heavy processing
  static Future<T> processInWorker<T>(WorkerTask<T> task) async {
    final worker = JsonProcessingWorker();
    try {
      return await worker.execute(task);
    } finally {
      worker.dispose();
    }
  }
}
```

### 3.2 Data Structures

#### Validation Results

```dart
// Comprehensive validation result structure
class ValidationResult {
  final JsonDoctorStatus status;
  final dynamic data;
  final String? message;
  final JsonError? error;
  final String? suggestedFix;
  final Duration processingTime;
  final int originalSize;
  final int formattedSize;

  const ValidationResult({
    required this.status,
    this.data,
    this.message,
    this.error,
    this.suggestedFix,
    this.processingTime = Duration.zero,
    this.originalSize = 0,
    this.formattedSize = 0,
  });

  bool get isValid => status == JsonDoctorStatus.valid;
  bool get wasRepaired => status == JsonDoctorStatus.repaired;
  double get compressionRatio =>
    originalSize > 0 ? formattedSize / originalSize : 1.0;
}

// Detailed error information
class JsonError {
  final JsonErrorType type;
  final int position;
  final String description;
  final String suggestion;
  final List<String> possibleFixes;
  final int? lineNumber;
  final int? columnNumber;

  const JsonError({
    required this.type,
    required this.position,
    required this.description,
    required this.suggestion,
    this.possibleFixes = const [],
    this.lineNumber,
    this.columnNumber,
  });
}
```

#### Schema Validation

```dart
// Enhanced schema validation with detailed error reporting
class SchemaValidationError {
  final String path;
  final String message;
  final String expectedType;
  final String actualType;
  final dynamic actualValue;
  final List<SchemaValidationError> subErrors;
  final String? schemaPointer;
  final Map<String, dynamic>? context;

  const SchemaValidationError({
    required this.path,
    required this.message,
    required this.expectedType,
    required this.actualType,
    required this.actualValue,
    this.subErrors = const [],
    this.schemaPointer,
    this.context,
  });

  // Generate user-friendly error descriptions
  String get userFriendlyMessage {
    switch (expectedType) {
      case 'string':
        return 'Expected text value at $path, but found $actualType';
      case 'number':
        return 'Expected numeric value at $path, but found $actualType';
      case 'boolean':
        return 'Expected true/false at $path, but found $actualType';
      case 'array':
        return 'Expected list of items at $path, but found $actualType';
      case 'object':
        return 'Expected object with properties at $path, but found $actualType';
      default:
        return message;
    }
  }
}
```

### 3.3 Advanced Features

#### Intelligent Formatting

```dart
// Multiple formatting styles with customization
class JsonFormatter {
  static const Map<String, FormattingStyle> presetStyles = {
    'compact': FormattingStyle(
      indent: 0,
      newlines: false,
      sortKeys: false,
      trailingCommas: false,
    ),
    'readable': FormattingStyle(
      indent: 2,
      newlines: true,
      sortKeys: false,
      trailingCommas: false,
    ),
    'development': FormattingStyle(
      indent: 4,
      newlines: true,
      sortKeys: true,
      trailingCommas: true,
    ),
    'production': FormattingStyle(
      indent: 2,
      newlines: true,
      sortKeys: true,
      trailingCommas: false,
    ),
  };

  static String format(dynamic data, FormattingStyle style) {
    if (style.sortKeys && data is Map) {
      data = _sortKeysRecursively(data);
    }

    final encoder = JsonEncoder.withIndent(
      style.newlines ? ' ' * style.indent : null,
    );

    String result = encoder.convert(data);

    if (style.trailingCommas) {
      result = _addTrailingCommas(result);
    }

    return result;
  }
}
```

#### Performance Monitoring

```dart
// Real-time performance tracking
class PerformanceMonitor {
  static final Map<String, List<Duration>> _operationTimes = {};
  static final Map<String, int> _operationCounts = {};

  static void trackOperation(String operation, Duration time) {
    _operationTimes.putIfAbsent(operation, () => []).add(time);
    _operationCounts[operation] = (_operationCounts[operation] ?? 0) + 1;
  }

  static PerformanceMetrics getMetrics() {
    return PerformanceMetrics(
      averageValidationTime: _calculateAverage('validation'),
      averageRepairTime: _calculateAverage('repair'),
      averageSchemaValidationTime: _calculateAverage('schema_validation'),
      averageQueryTime: _calculateAverage('jsonpath_query'),
      totalOperations: _operationCounts.values.fold(0, (a, b) => a + b),
    );
  }
}
```

JSON Doctor's integration architecture positions it as the central JSON processing hub within Toolspace, enabling seamless data flow between tools while maintaining data integrity, validation standards, and user workflow efficiency.

## 3. UX Flow

### 3.1 Primary User Journey

#### Entry and Input Methods

```dart
// Multiple entry points for JSON data
class JsonDoctorEntryPoints {
  // Direct text input with real-time validation
  static Widget buildTextInput() {
    return CodeEditor(
      controller: _inputController,
      language: 'json',
      features: ['syntax-highlighting', 'error-squiggles', 'auto-completion'],
      onChanged: _debounceValidation,
      placeholder: 'Paste or type JSON here...',
    );
  }

  // File upload with drag-and-drop support
  static Widget buildFileUpload() {
    return DropZone(
      acceptedTypes: ['.json', '.txt', '.js'],
      maxFileSize: 50 * 1024 * 1024, // 50MB
      onFileDropped: _handleFileUpload,
    );
  }

  // Cross-tool data import
  static Widget buildImportOptions() {
    return ImportDataButton(
      acceptedTypes: [SharedDataType.json, SharedDataType.text, SharedDataType.csv],
      onImport: _handleSharedData,
      tooltip: 'Import from other Toolspace tools',
    );
  }
}
```

#### Validation Flow

1. **Input Detection** - Automatic JSON syntax detection and parsing
2. **Real-time Feedback** - Immediate validation with error highlighting
3. **Error Analysis** - Detailed error reporting with fix suggestions
4. **Auto-repair Options** - Intelligent repair suggestions for common issues
5. **Result Display** - Formatted output with validation status

#### Advanced Workflows

```dart
// Tab-based workflow management
class JsonDoctorWorkflows {
  // Tab 1: Validate & Fix workflow
  static Future<void> executeValidationWorkflow() async {
    await _detectInput();
    await _performValidation();
    await _offerAutoRepair();
    await _displayResults();
  }

  // Tab 2: Schema validation workflow
  static Future<void> executeSchemaWorkflow() async {
    await _loadOrCreateSchema();
    await _validateAgainstSchema();
    await _showValidationDetails();
    await _offerSchemaFixes();
  }

  // Tab 3: JSONPath query workflow
  static Future<void> executeQueryWorkflow() async {
    await _buildOrEnterQuery();
    await _executeQuery();
    await _displayResults();
    await _offerExportOptions();
  }
}
```

### 3.2 User Experience Patterns

#### Progressive Disclosure

- **Beginner Mode**: Simple validation with basic error messages
- **Intermediate Mode**: Schema validation and query capabilities
- **Expert Mode**: Advanced features, batch processing, and API integration

#### Visual Feedback System

```dart
class VisualFeedbackSystem {
  static Widget buildStatusIndicator(JsonDoctorStatus status) {
    return StatusIndicator(
      status: status,
      animations: {
        JsonDoctorStatus.valid: PulseAnimation(color: Colors.green),
        JsonDoctorStatus.invalid: ShakeAnimation(color: Colors.red),
        JsonDoctorStatus.repairing: SpinAnimation(color: Colors.orange),
      },
    );
  }
}
```

## 4. Data & Types

### 4.1 Core Data Structures

#### JSON Processing Types

```dart
// Primary data types for JSON processing
enum JsonDataType {
  object,    // JSON object {}
  array,     // JSON array []
  string,    // String value
  number,    // Numeric value
  boolean,   // true/false
  null_value, // null
}

// Validation status enumeration
enum JsonDoctorStatus {
  empty,       // No input provided
  typing,      // User actively typing
  valid,       // Valid JSON detected
  invalid,     // Syntax errors found
  repairing,   // Auto-repair in progress
  repaired,    // Successfully repaired
  schemaValid, // Passes schema validation
  schemaError, // Schema validation failed
}

// Comprehensive validation result
class ValidationResult {
  final JsonDoctorStatus status;
  final dynamic data;
  final String? message;
  final List<JsonError> errors;
  final Duration processingTime;
  final int originalSize;
  final int formattedSize;

  const ValidationResult({
    required this.status,
    this.data,
    this.message,
    this.errors = const [],
    this.processingTime = Duration.zero,
    this.originalSize = 0,
    this.formattedSize = 0,
  });
}
```

#### Schema Validation Types

```dart
// JSON Schema validation structures
class JsonSchema {
  final String version;
  final Map<String, dynamic> schema;
  final Set<String> supportedKeywords;

  const JsonSchema({
    required this.version,
    required this.schema,
    required this.supportedKeywords,
  });
}

class SchemaValidationError {
  final String path;
  final String message;
  final String expectedType;
  final String actualType;
  final dynamic actualValue;
  final Map<String, dynamic>? context;

  const SchemaValidationError({
    required this.path,
    required this.message,
    required this.expectedType,
    required this.actualType,
    required this.actualValue,
    this.context,
  });
}
```

#### JSONPath Query Types

```dart
// JSONPath query and result structures
class JsonPathQuery {
  final String expression;
  final QueryType type;
  final List<QueryOperation> operations;

  const JsonPathQuery({
    required this.expression,
    required this.type,
    required this.operations,
  });
}

class QueryResult {
  final bool success;
  final List<dynamic> results;
  final int resultCount;
  final Duration executionTime;
  final String? error;

  const QueryResult({
    required this.success,
    this.results = const [],
    this.resultCount = 0,
    this.executionTime = Duration.zero,
    this.error,
  });
}
```

### 4.2 ShareBus Data Types

#### Cross-Tool Communication

```dart
// ShareBus message types for JSON data
class JsonShareMessage extends ShareBusMessage {
  final JsonDataType jsonType;
  final ValidationStatus validationStatus;
  final Map<String, dynamic>? schema;
  final ProcessingMetadata? metadata;

  const JsonShareMessage({
    required super.sourceToolId,
    required super.targetToolId,
    required super.data,
    required this.jsonType,
    required this.validationStatus,
    this.schema,
    this.metadata,
  });
}

// Metadata for processed JSON
class ProcessingMetadata {
  final String operation;
  final String? query;
  final int? executionTime;
  final int? resultCount;
  final Map<String, dynamic>? additionalInfo;

  const ProcessingMetadata({
    required this.operation,
    this.query,
    this.executionTime,
    this.resultCount,
    this.additionalInfo,
  });
}
```

## 5. Integration

### 5.1 ShareBus Integration

#### Inbound Data Handling

```dart
class JsonDoctorShareBusHandler {
  // Handle incoming JSON data from other tools
  static Future<void> handleJsonData(ShareBusMessage message) async {
    final jsonData = message.data as String;

    try {
      final parsed = jsonDecode(jsonData);
      await _loadValidatedJson(parsed);

      NotificationService.show(
        'JSON loaded from ${message.sourceToolId}',
        type: NotificationType.success,
      );
    } catch (e) {
      await _offerJsonRepair(jsonData, message.sourceToolId);
    }
  }

  // Convert CSV to JSON for CSV Cleaner integration
  static Future<void> handleCsvConversion(CsvShareMessage message) async {
    final csvData = message.data as String;
    final jsonArray = CsvToJsonConverter.convert(csvData);

    await _loadConvertedData(jsonArray, sourceFormat: 'CSV');
  }
}
```

#### Outbound Data Sharing

```dart
class JsonDoctorDataExport {
  // Export validated JSON to Text Tools
  static Future<void> exportToTextTools(dynamic jsonData) async {
    final formattedJson = JsonFormatter.format(jsonData);

    await ShareBusService.send(
      TextShareMessage(
        sourceToolId: 'json_doctor',
        targetToolId: 'text_tools',
        data: formattedJson,
        textType: TextType.code,
        language: 'json',
      ),
    );
  }

  // Send query results to other tools
  static Future<void> exportQueryResults(QueryResult results) async {
    await ShareBusService.send(
      JsonShareMessage(
        sourceToolId: 'json_doctor',
        targetToolId: 'determined_at_runtime',
        data: results.results,
        jsonType: JsonDataType.array,
        validationStatus: ValidationStatus.valid,
        metadata: ProcessingMetadata(
          operation: 'jsonpath_query',
          resultCount: results.resultCount,
          executionTime: results.executionTime.inMilliseconds,
        ),
      ),
    );
  }
}
```

### 5.2 Tool-Specific Integrations

#### Text Tools Integration

- **Import**: Text content for JSON parsing attempts
- **Export**: Formatted JSON with syntax highlighting hints
- **Bidirectional**: Smart content type detection

#### File Merger Integration

- **Batch Export**: Multiple validated JSON files
- **File Processing**: JSON file validation and repair
- **Metadata Preservation**: Validation status and processing history

#### API Testing Tools

- **Response Validation**: API response JSON verification
- **Schema Generation**: Create schemas from API responses
- **Test Data Creation**: Generate test JSON from schemas

## 6. Billing & Quotas

### 6.1 Tier-Based Features

#### Free Tier

```dart
class FreeTierLimits {
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const int maxBatchFiles = 0; // No batch processing
  static const bool schemaValidation = true; // Basic schema support
  static const bool jsonPathQueries = true; // Basic queries
  static const bool crossToolSharing = true; // Full ShareBus access
  static const bool autoRepair = true; // Basic auto-repair
}
```

#### Pro Tier ($9.99/month)

```dart
class ProTierLimits {
  static const int maxFileSize = 25 * 1024 * 1024; // 25MB
  static const int maxBatchFiles = 10; // Limited batch processing
  static const bool advancedSchemas = true; // Complex schema validation
  static const bool visualQueryBuilder = true; // GUI query construction
  static const bool batchValidation = true; // Multiple file validation
  static const int monthlyOperations = 10000; // API calls/validations
}
```

#### Pro+ Tier ($19.99/month)

```dart
class ProPlusTierLimits {
  static const int maxFileSize = 50 * 1024 * 1024; // 50MB
  static const int maxBatchFiles = 100; // Full batch processing
  static const bool schemaLibraryAccess = true; // Full schema library
  static const bool aiValidationSuggestions = true; // AI-powered features
  static const bool teamCollaboration = true; // Multi-user features
  static const bool apiAccess = true; // REST API access
  static const int monthlyOperations = 100000; // High-volume operations
}
```

### 6.2 Quota Management

#### Usage Tracking

```dart
class QuotaManager {
  static Future<UsageMetrics> getCurrentUsage(String userId) async {
    return UsageMetrics(
      filesProcessedToday: await _getFilesProcessedToday(userId),
      batchOperationsThisMonth: await _getBatchOperations(userId),
      apiCallsThisMonth: await _getApiCalls(userId),
      storageUsed: await _getStorageUsage(userId),
    );
  }

  static Future<bool> canPerformOperation(
    String userId,
    OperationType operation,
  ) async {
    final plan = await BillingService.getUserPlan(userId);
    final usage = await getCurrentUsage(userId);

    return _checkQuotaLimits(plan, usage, operation);
  }
}
```

## 7. Validation & Error Handling

### 7.1 Comprehensive Error Management

#### Error Classification System

```dart
enum JsonErrorType {
  syntaxError,        // Invalid JSON syntax
  structureError,     // Malformed structure
  typeError,          // Wrong data type
  schemaViolation,    // Schema validation failure
  performanceError,   // Processing timeout/memory
  quotaExceeded,      // Usage limits exceeded
}

class ErrorHandler {
  static void handleValidationError(JsonError error) {
    switch (error.type) {
      case JsonErrorType.syntaxError:
        _showSyntaxErrorDialog(error);
        break;
      case JsonErrorType.schemaViolation:
        _showSchemaErrorPanel(error);
        break;
      case JsonErrorType.quotaExceeded:
        _showQuotaUpgradeDialog(error);
        break;
      default:
        _showGenericErrorMessage(error);
    }
  }
}
```

#### Recovery Strategies

```dart
class ErrorRecovery {
  // Graceful degradation for large files
  static Future<void> handleLargeFileError(int fileSize) async {
    if (fileSize > MemoryLimits.criticalThreshold) {
      await _offerStreamingValidation();
    } else {
      await _enableProgressiveLoading();
    }
  }

  // Auto-repair suggestions
  static List<RepairSuggestion> generateRepairSuggestions(JsonError error) {
    return AutoRepairEngine.getSuggestions(error);
  }
}
```

### 7.2 User Feedback Systems

#### Error Visualization

```dart
class ErrorVisualization {
  static Widget buildErrorHighlight(JsonError error) {
    return ErrorHighlight(
      position: error.position,
      length: error.length,
      severity: error.severity,
      tooltip: error.description,
      onTap: () => _showErrorDetails(error),
    );
  }
}
```

## 8. Accessibility

### 8.1 Screen Reader Support

#### ARIA Implementation

```dart
class AccessibilitySupport {
  static Widget buildAccessibleJsonEditor() {
    return Semantics(
      label: 'JSON input editor',
      hint: 'Type or paste JSON content for validation',
      multiline: true,
      textField: true,
      child: CodeEditor(
        accessibilityFeatures: [
          'screen-reader-optimized',
          'keyboard-navigation',
          'high-contrast-support',
        ],
        onValidationChange: _announceValidationResults,
      ),
    );
  }

  static void _announceValidationResults(bool isValid) {
    SemanticsService.announce(
      isValid ? 'JSON is valid' : 'JSON contains errors',
      TextDirection.ltr,
    );
  }
}
```

### 8.2 Keyboard Navigation

#### Complete Keyboard Support

```dart
class KeyboardNavigation {
  static final Map<LogicalKeySet, VoidCallback> shortcuts = {
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.digit1):
      () => _switchToValidateTab(),
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.digit2):
      () => _switchToSchemaTab(),
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.digit3):
      () => _switchToJsonPathTab(),
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyR):
      () => _triggerAutoRepair(),
  };
}
```

### 8.3 Visual Accessibility

#### High Contrast and Color Support

```dart
class VisualAccessibility {
  static ThemeData getHighContrastTheme() {
    return ThemeData(
      colorScheme: ColorScheme.highContrast(),
      textTheme: TextTheme(
        bodyMedium: TextStyle(fontSize: 16), // Larger text
      ),
    );
  }

  static bool get reduceMotion =>
    MediaQuery.of(context).accessibleNavigation;
}
```

## 9. Test Plan (Manual)

### 9.1 Core Functionality Tests

#### JSON Validation Testing

```yaml
Test Case: Basic JSON Validation
Steps:
  1. Open JSON Doctor tool
  2. Paste valid JSON: {"name": "test", "value": 123}
  3. Observe validation status
Expected: Green checkmark, "Valid JSON" status

Test Case: Invalid JSON Detection
Steps:
  1. Paste invalid JSON: {"name": "test", "value": }
  2. Observe error highlighting
  3. Check error message details
Expected: Red error indicator, specific error message, position highlighting

Test Case: Auto-Repair Functionality
Steps:
  1. Paste JSON with trailing comma: {"name": "test",}
  2. Click auto-repair button
  3. Verify corrected output
Expected: Comma removed, valid JSON generated
```

#### Schema Validation Testing

```yaml
Test Case: Schema Validation Success
Steps:
  1. Switch to Schema tab
  2. Load user schema from library
  3. Input valid user data
  4. Verify validation passes
Expected: Schema validation success message

Test Case: Schema Validation Failure
Steps:
  1. Input data missing required fields
  2. Check detailed error report
  3. Verify error path highlighting
Expected: Clear error messages with field paths
```

#### JSONPath Query Testing

```yaml
Test Case: Simple Property Query
Steps:
  1. Switch to JSONPath tab
  2. Input test data with nested objects
  3. Execute query: $.user.name
  4. Verify results
Expected: Correct property value extracted

Test Case: Filter Expression Query
Steps:
  1. Input array of objects with numeric values
  2. Execute query: $.items[?(@.price > 10)]
  3. Verify filtered results
Expected: Only items matching filter criteria
```

### 9.2 Integration Testing

#### Cross-Tool Communication

```yaml
Test Case: Import from Text Tools
Steps:
  1. Send JSON text from Text Tools
  2. Verify automatic loading in JSON Doctor
  3. Check validation status
Expected: Seamless data transfer, immediate validation

Test Case: Export to File Merger
Steps:
  1. Validate multiple JSON objects
  2. Export to File Merger
  3. Verify files created with proper formatting
Expected: Separate files for each object, proper formatting
```

### 9.3 Performance Testing

#### Large File Handling

```yaml
Test Case: 10MB JSON File
Steps:
  1. Upload 10MB JSON file
  2. Monitor validation time
  3. Check memory usage
  4. Verify UI responsiveness
Expected: Validation under 2 seconds, UI remains responsive

Test Case: Complex Schema Validation
Steps:
  1. Load enterprise-level schema (1000+ properties)
  2. Validate complex JSON against schema
  3. Monitor performance metrics
Expected: Validation completes under 500ms
```

## 10. Automation Hooks

### 10.1 API Integration Points

#### Validation API

```dart
class JsonDoctorApi {
  // REST API endpoint for JSON validation
  static Future<ValidationResult> validateJson(String json) async {
    final response = await http.post(
      Uri.parse('/api/v1/json-doctor/validate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'content': json}),
    );

    return ValidationResult.fromJson(response.body);
  }

  // Schema validation endpoint
  static Future<SchemaValidationResult> validateWithSchema(
    String json,
    Map<String, dynamic> schema,
  ) async {
    final response = await http.post(
      Uri.parse('/api/v1/json-doctor/validate-schema'),
      body: jsonEncode({
        'content': json,
        'schema': schema,
      }),
    );

    return SchemaValidationResult.fromJson(response.body);
  }
}
```

### 10.2 CI/CD Integration

#### GitHub Actions Integration

```yaml
# .github/workflows/json-validation.yml
name: JSON Validation
on: [push, pull_request]

jobs:
  validate-json:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Validate JSON files
        uses: toolspace/json-doctor-action@v1
        with:
          files: "**/*.json"
          schema: "schemas/config-schema.json"
          auto-fix: true
```

### 10.3 Webhook Integration

#### Real-time Validation Webhooks

```dart
class WebhookIntegration {
  static Future<void> setupValidationWebhook(String url) async {
    await WebhookService.register(
      url: url,
      events: ['validation-complete', 'error-detected', 'repair-suggested'],
      authentication: WebhookAuth.apiKey(),
    );
  }
}
```

## 11. Release Notes

### Version v2.1.3 (Current)

**Released:** October 11, 2025

#### What's New

- **Enhanced Performance**: 35% faster validation for large JSON files
- **Improved Auto-Repair**: Better detection of malformed JSON structures
- **Schema Library**: Access to 200+ pre-built schemas for common APIs
- **Visual Query Builder**: Drag-and-drop JSONPath query construction
- **Advanced Error Reporting**: Contextual error messages with fix suggestions

#### Performance Improvements

- Validation time reduced from 80ms to 50ms average
- Memory usage optimized by 30% for large files
- Schema validation 40% faster for complex schemas
- JSONPath queries execute 25% faster

#### Bug Fixes

- Fixed schema validation for recursive references
- Resolved memory leak in large file processing
- Corrected JSONPath parser for escaped characters
- Fixed cross-browser compatibility issues in Safari

#### Breaking Changes

None in this release.

#### Upgrade Instructions

No action required - all improvements are backward compatible.

---

_For detailed technical documentation, see:_

- [UX Documentation](UX.md) - User experience and interface design
- [Integration Guide](INTEGRATION.md) - Cross-tool communication details
- [Testing Documentation](TESTS.md) - Comprehensive testing strategies
- [Performance Limits](LIMITS.md) - System limits and optimization
- [Version History](CHANGELOG.md) - Complete development timeline

JSON Doctor represents the pinnacle of JSON processing tools within Toolspace, offering enterprise-grade validation, repair, and analysis capabilities with seamless cross-tool integration and professional-level performance optimization.
