# JSON Doctor - Integration Documentation

**Tool ID:** `json_doctor`  
**Route:** `/tools/json-doctor`  
**Integration Architect:** Toolspace Platform Team  
**Last Updated:** October 11, 2025

## 1. Integration Overview

JSON Doctor serves as a central hub for JSON data processing within Toolspace, providing seamless bidirectional integration with all tools through the ShareBus system. It acts as both a data validator/transformer and a distribution point for JSON content across the platform.

**Integration Categories:**

- **Data Import Integration** - Receiving data from other tools for validation/processing
- **Data Export Integration** - Sending validated/processed data to target tools
- **Real-time Collaboration** - Live data sharing and synchronization
- **API Integration** - External service connectivity for schema validation
- **Development Workflow** - IDE and development tool integration

### 1.1 ShareBus Architecture

#### Core Integration Framework

```dart
// JSON Doctor's ShareBus implementation
class JsonDoctorShareBus extends ShareBusIntegration {
  static const String toolId = 'json_doctor';
  static const String version = '2.1.3';

  // Supported data types for import
  static const Set<SharedDataType> acceptedTypes = {
    SharedDataType.json,      // Direct JSON data
    SharedDataType.text,      // Text that might be JSON
    SharedDataType.csv,       // Convert to JSON array
    SharedDataType.xml,       // Convert to JSON object
    SharedDataType.api_response, // API response data
    SharedDataType.database_export, // Database query results
    SharedDataType.configuration, // Config files
  };

  // Data types we can export
  static const Set<SharedDataType> exportedTypes = {
    SharedDataType.json,           // Validated JSON
    SharedDataType.schema,         // JSON Schema definitions
    SharedDataType.query_results,  // JSONPath query results
    SharedDataType.validation_report, // Validation summaries
    SharedDataType.typescript_interface, // Generated TS types
  };

  @override
  Future<void> handleIncomingData(ShareBusMessage message) async {
    switch (message.dataType) {
      case SharedDataType.json:
        await _loadJsonData(message);
        break;
      case SharedDataType.text:
        await _attemptJsonParsing(message);
        break;
      case SharedDataType.csv:
        await _convertCsvToJson(message);
        break;
      case SharedDataType.api_response:
        await _loadApiResponse(message);
        break;
      default:
        await _handleGenericData(message);
    }
  }
}
```

#### Message Protocol

```dart
// Standardized message format for JSON data sharing
class JsonShareMessage extends ShareBusMessage {
  final JsonDataType jsonType;
  final ValidationStatus validationStatus;
  final Map<String, dynamic>? schema;
  final List<ValidationError>? errors;
  final ProcessingMetadata? metadata;

  const JsonShareMessage({
    required super.sourceToolId,
    required super.targetToolId,
    required super.data,
    required this.jsonType,
    required this.validationStatus,
    this.schema,
    this.errors,
    this.metadata,
    super.timestamp,
  });

  // Create different types of JSON messages
  factory JsonShareMessage.validatedJson({
    required String sourceToolId,
    required String targetToolId,
    required Map<String, dynamic> data,
    Map<String, dynamic>? schema,
  }) {
    return JsonShareMessage(
      sourceToolId: sourceToolId,
      targetToolId: targetToolId,
      data: data,
      jsonType: JsonDataType.object,
      validationStatus: ValidationStatus.valid,
      schema: schema,
    );
  }

  factory JsonShareMessage.queryResults({
    required String sourceToolId,
    required String targetToolId,
    required List<dynamic> results,
    required String query,
    required int executionTimeMs,
  }) {
    return JsonShareMessage(
      sourceToolId: sourceToolId,
      targetToolId: targetToolId,
      data: results,
      jsonType: JsonDataType.array,
      validationStatus: ValidationStatus.valid,
      metadata: ProcessingMetadata(
        operation: 'jsonpath_query',
        query: query,
        executionTime: executionTimeMs,
        resultCount: results.length,
      ),
    );
  }
}
```

### 1.2 Cross-Tool Data Flow

#### Inbound Integrations

```dart
// Tools that send data to JSON Doctor
class InboundIntegrations {
  // Text Tools → JSON Doctor
  static Future<void> receiveFromTextTools(TextShareMessage message) async {
    final content = message.data as String;

    // Attempt to parse as JSON
    try {
      final jsonData = jsonDecode(content);
      await _loadValidatedJson(jsonData);

      // If successful, show success notification
      NotificationService.show(
        'JSON detected and loaded from Text Tools',
        type: NotificationType.success,
      );
    } catch (e) {
      // If not JSON, offer to help fix it
      await _offerJsonRepair(content, 'Text Tools');
    }
  }

  // CSV Cleaner → JSON Doctor
  static Future<void> receiveFromCsvCleaner(CsvShareMessage message) async {
    final csvData = message.data as String;
    final headers = message.metadata?['headers'] as List<String>?;

    // Convert CSV to JSON array
    final jsonArray = CsvToJsonConverter.convert(
      csvData,
      headers: headers,
      preserveTypes: true,
    );

    await _loadConvertedData(
      jsonArray,
      sourceFormat: 'CSV',
      sourceTool: 'CSV Cleaner',
    );
  }

  // API testing tools → JSON Doctor
  static Future<void> receiveApiResponse(ApiResponseMessage message) async {
    final response = message.data as Map<String, dynamic>;

    // Load API response data with metadata
    await _loadApiResponseData(
      response['body'],
      metadata: ApiResponseMetadata(
        statusCode: response['statusCode'],
        headers: response['headers'],
        url: response['url'],
        method: response['method'],
        timestamp: message.timestamp,
      ),
    );
  }
}
```

#### Outbound Integrations

```dart
// JSON Doctor sending data to other tools
class OutboundIntegrations {
  // JSON Doctor → Text Tools
  static Future<void> sendToTextTools(dynamic jsonData, {
    JsonFormattingOptions? formatting,
  }) async {
    final formattedJson = JsonFormatter.format(
      jsonData,
      formatting ?? JsonFormattingOptions.readable(),
    );

    await ShareBusService.send(
      TextShareMessage(
        sourceToolId: 'json_doctor',
        targetToolId: 'text_tools',
        data: formattedJson,
        textType: TextType.code,
        language: 'json',
        metadata: TextMetadata(
          originalFormat: 'json',
          formattingApplied: true,
          sourceOperation: 'json_validation',
        ),
      ),
    );
  }

  // JSON Doctor → File Merger
  static Future<void> sendToFileMerger(List<dynamic> jsonObjects) async {
    for (int i = 0; i < jsonObjects.length; i++) {
      final jsonString = jsonEncode(jsonObjects[i]);

      await ShareBusService.send(
        FileShareMessage(
          sourceToolId: 'json_doctor',
          targetToolId: 'file_merger',
          data: jsonString,
          fileName: 'validated_json_${i + 1}.json',
          fileType: FileType.json,
          metadata: FileMetadata(
            originalSource: 'json_doctor',
            validationStatus: 'passed',
            generatedAt: DateTime.now(),
          ),
        ),
      );
    }
  }

  // JSON Doctor → Database tools
  static Future<void> sendToDatabaseTool(dynamic jsonData, {
    required String tableName,
    required DatabaseOperation operation,
  }) async {
    await ShareBusService.send(
      DatabaseShareMessage(
        sourceToolId: 'json_doctor',
        targetToolId: 'database_tool',
        data: jsonData,
        operation: operation,
        tableName: tableName,
        metadata: DatabaseMetadata(
          dataType: 'json',
          validationPassed: true,
          schemaInferred: _inferDatabaseSchema(jsonData),
        ),
      ),
    );
  }
}
```

## 2. Tool-Specific Integrations

### 2.1 Text Tools Integration

#### Bidirectional Text Processing

```dart
class TextToolsIntegration {
  // JSON to formatted text
  static Future<void> exportAsFormattedText(dynamic jsonData) async {
    final options = await _getUserFormattingPreferences();

    final formattedText = JsonFormatter.format(jsonData, options);

    await ShareBusService.send(
      TextShareMessage.create(
        targetTool: 'text_tools',
        content: formattedText,
        contentType: 'formatted_json',
        suggestions: [
          'Use regex operations to find patterns',
          'Apply text transformations',
          'Export to documentation format',
        ],
      ),
    );
  }

  // Text to JSON conversion assistance
  static Future<void> assistJsonConversion(String textContent) async {
    final conversionSuggestions = JsonConversionAnalyzer.analyze(textContent);

    if (conversionSuggestions.isNotEmpty) {
      await _showConversionDialog(
        content: textContent,
        suggestions: conversionSuggestions,
        onApplyConversion: (convertedJson) {
          _loadJsonData(convertedJson);
        },
      );
    }
  }
}
```

### 2.2 CSV Cleaner Integration

#### CSV to JSON Conversion

```dart
class CsvCleanerIntegration {
  static Future<void> convertCsvToJson(CsvShareMessage message) async {
    final csvContent = message.data as String;
    final options = message.metadata?['conversionOptions'] as CsvConversionOptions?;

    try {
      // Parse CSV with error handling
      final csvData = CsvParser.parse(
        csvContent,
        hasHeader: options?.hasHeader ?? true,
        delimiter: options?.delimiter ?? ',',
        encoding: options?.encoding ?? 'utf-8',
      );

      // Convert to JSON with type inference
      final jsonArray = CsvToJsonConverter.convert(
        csvData,
        inferTypes: true,
        handleEmptyValues: CsvEmptyValueHandling.null_value,
        dateFormat: options?.dateFormat,
      );

      // Load into JSON Doctor with conversion metadata
      await _loadConvertedData(
        jsonArray,
        conversionInfo: ConversionInfo(
          sourceFormat: 'CSV',
          sourceTool: 'CSV Cleaner',
          recordCount: jsonArray.length,
          fieldCount: jsonArray.isNotEmpty ?
            (jsonArray.first as Map).keys.length : 0,
          conversionOptions: options,
        ),
      );

      // Offer additional processing
      await _offerPostConversionActions([
        'Validate against a schema',
        'Generate TypeScript interfaces',
        'Create sample data',
        'Export to database format',
      ]);

    } catch (e) {
      await _handleConversionError(e, csvContent);
    }
  }
}
```

### 2.3 File Merger Integration

#### JSON File Processing

```dart
class FileMergerIntegration {
  // Send validated JSON files to File Merger
  static Future<void> exportToFileMerger({
    required List<dynamic> jsonObjects,
    required FileMergerExportOptions options,
  }) async {
    for (int i = 0; i < jsonObjects.length; i++) {
      final jsonObject = jsonObjects[i];
      final fileName = options.generateFileName(i, jsonObject);

      // Format JSON according to options
      final formattedJson = JsonFormatter.format(
        jsonObject,
        options.formattingStyle,
      );

      await ShareBusService.send(
        FileShareMessage(
          sourceToolId: 'json_doctor',
          targetToolId: 'file_merger',
          data: formattedJson,
          fileName: fileName,
          fileType: FileType.json,
          metadata: FileMergerMetadata(
            validationStatus: 'passed',
            originalIndex: i,
            totalFiles: jsonObjects.length,
            batchId: options.batchId,
          ),
        ),
      );
    }

    // Send batch completion notification
    await ShareBusService.send(
      BatchCompletionMessage(
        sourceToolId: 'json_doctor',
        targetToolId: 'file_merger',
        batchId: options.batchId,
        totalFiles: jsonObjects.length,
        operation: 'json_export',
      ),
    );
  }

  // Receive JSON files from File Merger
  static Future<void> receiveFromFileMerger(FileShareMessage message) async {
    final jsonContent = message.data as String;
    final fileName = message.fileName;

    try {
      final jsonData = jsonDecode(jsonContent);

      // Load with file context
      await _loadJsonWithFileContext(
        jsonData,
        fileInfo: FileInfo(
          name: fileName,
          source: 'File Merger',
          size: jsonContent.length,
          lastModified: message.timestamp,
        ),
      );

    } catch (e) {
      // Offer repair for malformed JSON files
      await _offerFileRepair(
        fileName: fileName,
        content: jsonContent,
        error: e,
      );
    }
  }
}
```

### 2.4 API Testing Tool Integration

#### API Response Validation

```dart
class ApiTestingIntegration {
  // Validate API responses
  static Future<void> validateApiResponse(ApiResponseMessage message) async {
    final response = message.data as ApiResponse;

    // Parse response body
    dynamic responseData;
    try {
      responseData = jsonDecode(response.body);
    } catch (e) {
      await _handleNonJsonApiResponse(response, e);
      return;
    }

    // Load with API context
    await _loadApiResponseData(
      responseData,
      apiInfo: ApiInfo(
        endpoint: response.url,
        method: response.method,
        statusCode: response.statusCode,
        headers: response.headers,
        requestTimestamp: response.requestTimestamp,
        responseTime: response.responseTime,
      ),
    );

    // Offer API-specific validations
    await _offerApiValidations([
      'Validate against OpenAPI schema',
      'Check response structure consistency',
      'Generate client code interfaces',
      'Create test data templates',
    ]);
  }

  // Generate test data for API testing
  static Future<void> generateTestData(JsonSchema schema) async {
    final testDataGenerator = ApiTestDataGenerator(schema);

    final testCases = [
      testDataGenerator.generateValidData(),
      testDataGenerator.generateBoundaryData(),
      testDataGenerator.generateInvalidData(),
    ];

    for (final testCase in testCases) {
      await ShareBusService.send(
        TestDataMessage(
          sourceToolId: 'json_doctor',
          targetToolId: 'api_testing_tool',
          data: testCase.data,
          testType: testCase.type,
          expectedResult: testCase.expectedResult,
          metadata: testCase.metadata,
        ),
      );
    }
  }
}
```

### 2.5 Database Tool Integration

#### Schema Generation and Data Export

```dart
class DatabaseIntegration {
  // Generate database schema from JSON
  static Future<void> generateDatabaseSchema(dynamic jsonData) async {
    final schemaGenerator = DatabaseSchemaGenerator();

    // Analyze JSON structure for database mapping
    final analysis = schemaGenerator.analyzeJsonStructure(jsonData);

    // Generate schema for different database types
    final schemas = {
      'postgresql': schemaGenerator.generatePostgreSQLSchema(analysis),
      'mysql': schemaGenerator.generateMySQLSchema(analysis),
      'mongodb': schemaGenerator.generateMongoDBSchema(analysis),
      'sqlite': schemaGenerator.generateSQLiteSchema(analysis),
    };

    await ShareBusService.send(
      DatabaseSchemaMessage(
        sourceToolId: 'json_doctor',
        targetToolId: 'database_tool',
        schemas: schemas,
        sourceData: jsonData,
        analysisResults: analysis,
        recommendations: schemaGenerator.getRecommendations(analysis),
      ),
    );
  }

  // Export JSON data for database import
  static Future<void> exportForDatabaseImport({
    required dynamic jsonData,
    required DatabaseTarget target,
  }) async {
    final converter = DatabaseDataConverter(target);

    final convertedData = converter.convertJsonData(
      jsonData,
      options: DatabaseConversionOptions(
        flattenNestedObjects: target.supportsNesting ? false : true,
        handleArrays: target.arrayHandling,
        generateKeys: target.requiresPrimaryKeys,
        dataTypeMapping: target.dataTypeMapping,
      ),
    );

    await ShareBusService.send(
      DatabaseImportMessage(
        sourceToolId: 'json_doctor',
        targetToolId: 'database_tool',
        data: convertedData.data,
        tableName: convertedData.suggestedTableName,
        schema: convertedData.schema,
        importOptions: convertedData.importOptions,
      ),
    );
  }
}
```

## 3. Advanced Integration Features

### 3.1 Real-time Collaboration

#### Live Data Synchronization

```dart
class RealtimeCollaboration {
  static Stream<JsonCollaborationEvent> setupCollaborationStream(String sessionId) {
    return CollaborationService.createSession(sessionId).map((event) {
      switch (event.type) {
        case CollaborationEventType.dataChanged:
          return JsonDataChangedEvent(
            sessionId: sessionId,
            userId: event.userId,
            newData: event.data,
            timestamp: event.timestamp,
          );

        case CollaborationEventType.validationUpdated:
          return ValidationUpdatedEvent(
            sessionId: sessionId,
            userId: event.userId,
            validationResults: event.validationResults,
            timestamp: event.timestamp,
          );

        case CollaborationEventType.cursorMoved:
          return CursorMovedEvent(
            sessionId: sessionId,
            userId: event.userId,
            position: event.cursorPosition,
            timestamp: event.timestamp,
          );
      }
    });
  }

  // Broadcast changes to all session participants
  static Future<void> broadcastChange({
    required String sessionId,
    required JsonCollaborationEvent event,
  }) async {
    await CollaborationService.broadcast(
      sessionId: sessionId,
      event: event,
      excludeUser: event.userId, // Don't send back to originator
    );
  }
}
```

### 3.2 External API Integration

#### Schema Registry Integration

```dart
class SchemaRegistryIntegration {
  // Connect to external schema registries
  static Future<List<JsonSchema>> fetchSchemasFromRegistry({
    required String registryUrl,
    String? schemaName,
    List<String>? tags,
  }) async {
    final client = SchemaRegistryClient(registryUrl);

    try {
      final schemas = await client.searchSchemas(
        name: schemaName,
        tags: tags,
        format: 'json-schema',
      );

      return schemas.map((schema) => JsonSchema.fromRegistry(schema)).toList();
    } catch (e) {
      await _handleRegistryError(e, registryUrl);
      return [];
    }
  }

  // Publish validated schemas to registry
  static Future<void> publishSchemaToRegistry({
    required JsonSchema schema,
    required String registryUrl,
    required SchemaMetadata metadata,
  }) async {
    final client = SchemaRegistryClient(registryUrl);

    await client.publishSchema(
      schema: schema.toJson(),
      metadata: metadata,
      version: _generateSchemaVersion(),
    );
  }
}
```

### 3.3 Development Tool Integration

#### IDE Integration

```dart
class IdeIntegration {
  // Generate TypeScript interfaces
  static Future<void> generateTypeScriptInterfaces(dynamic jsonData) async {
    final generator = TypeScriptInterfaceGenerator();
    final interfaces = generator.generateFromJson(jsonData);

    await ShareBusService.send(
      CodeGenerationMessage(
        sourceToolId: 'json_doctor',
        targetToolId: 'ide_integration',
        language: 'typescript',
        code: interfaces,
        metadata: CodeMetadata(
          generationType: 'interface_generation',
          sourceFormat: 'json',
          timestamp: DateTime.now(),
        ),
      ),
    );
  }

  // Generate code documentation
  static Future<void> generateDocumentation(JsonSchema schema) async {
    final docGenerator = JsonSchemaDocumentationGenerator();
    final documentation = docGenerator.generateMarkdown(schema);

    await ShareBusService.send(
      DocumentationMessage(
        sourceToolId: 'json_doctor',
        targetToolId: 'documentation_tool',
        content: documentation,
        format: 'markdown',
        metadata: DocumentationMetadata(
          title: schema.title ?? 'JSON Schema Documentation',
          generatedFrom: 'json_schema',
          timestamp: DateTime.now(),
        ),
      ),
    );
  }
}
```

## 4. Integration Configuration

### 4.1 User Preferences

#### Integration Settings

```dart
class IntegrationSettings {
  // User-configurable integration preferences
  static Future<void> configureIntegrationPreferences({
    required Map<String, bool> enabledIntegrations,
    required Map<String, dynamic> integrationOptions,
  }) async {
    final settings = IntegrationPreferences(
      enabledTools: enabledIntegrations,
      autoExportOptions: integrationOptions['auto_export'] ?? {},
      dataFormatPreferences: integrationOptions['data_formats'] ?? {},
      notificationSettings: integrationOptions['notifications'] ?? {},
    );

    await SettingsService.saveIntegrationPreferences(settings);
  }

  // Auto-export configuration
  static Widget buildAutoExportSettings() {
    return AutoExportSettings(
      availableTargets: [
        'text_tools',
        'file_merger',
        'csv_cleaner',
        'database_tool',
      ],
      onSettingsChanged: (settings) {
        _updateAutoExportSettings(settings);
      },
    );
  }
}
```

### 4.2 Enterprise Integration

#### SSO and Permission Integration

```dart
class EnterpriseIntegration {
  // Single Sign-On integration
  static Future<void> configureSsoIntegration({
    required SsoProvider provider,
    required Map<String, dynamic> config,
  }) async {
    await SsoService.configure(
      provider: provider,
      config: config,
      permissionMapping: {
        'json_doctor.view': ['user', 'admin'],
        'json_doctor.edit': ['user', 'admin'],
        'json_doctor.share': ['user', 'admin'],
        'json_doctor.admin': ['admin'],
      },
    );
  }

  // Enterprise audit logging
  static Future<void> logIntegrationActivity({
    required String userId,
    required String action,
    required Map<String, dynamic> context,
  }) async {
    await AuditService.log(
      AuditEvent(
        userId: userId,
        toolId: 'json_doctor',
        action: action,
        context: context,
        timestamp: DateTime.now(),
        severity: AuditSeverity.info,
      ),
    );
  }
}
```

JSON Doctor's integration architecture positions it as the central JSON processing hub within Toolspace, enabling seamless data flow between tools while maintaining data integrity, validation standards, and user workflow efficiency.
