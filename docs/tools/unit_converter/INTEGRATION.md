# Unit Converter - Integration Guide

> **Tool ID**: `unit-converter`  
> **Integration Version**: 1.0.0  
> **Last Updated**: October 11, 2025  
> **ShareEnvelope API**: v3.2.0

## Integration Overview

The **Unit Converter** serves as a universal measurement transformation hub within the Toolspace ecosystem, providing seamless unit conversion capabilities through the ShareEnvelope framework. This tool integrates with multiple applications to standardize measurements, normalize data formats, and enable cross-tool measurement workflows.

### Core Integration Philosophy

#### 1. **Universal Measurement Hub**

Centralizes all unit conversion needs across the ecosystem, eliminating redundant conversion logic in individual tools.

#### 2. **Format Standardization**

Automatically detects and converts between different measurement formats, ensuring data consistency across applications.

#### 3. **Quality-Preserved Transformations**

Maintains conversion accuracy metadata and precision information through the ShareEnvelope quality chain system.

#### 4. **Context-Aware Processing**

Intelligently determines appropriate conversion targets based on source tool context and user workflow patterns.

---

## ShareEnvelope Framework Integration

### Data Exchange Architecture

#### Input Data Structures

```dart
// Standard conversion request format
class ConversionRequest {
  final double value;
  final String fromUnit;
  final String? toUnit;          // Optional: auto-detect if not provided
  final String? category;        // Optional: infer from units if available
  final int precision;           // Decimal places (default: 2)
  final String sourceToolId;     // Originating tool identifier
  final Map<String, dynamic> metadata; // Additional context

  ConversionRequest({
    required this.value,
    required this.fromUnit,
    this.toUnit,
    this.category,
    this.precision = 2,
    required this.sourceToolId,
    this.metadata = const {},
  });
}

// Multi-value conversion request
class BatchConversionRequest {
  final List<ConversionRequest> conversions;
  final String targetUnit;      // Common target unit for all conversions
  final bool preserveSource;    // Keep original values alongside conversions
  final String workflowId;      // Workflow tracking identifier

  BatchConversionRequest({
    required this.conversions,
    required this.targetUnit,
    this.preserveSource = true,
    required this.workflowId,
  });
}
```

#### Output Data Structures

```dart
// Standard conversion response format
class ConversionResponse {
  final double originalValue;
  final String originalUnit;
  final double convertedValue;
  final String convertedUnit;
  final String category;
  final int precision;
  final double conversionFactor;
  final DateTime timestamp;
  final String conversionId;
  final QualityChain qualityChain;

  ConversionResponse({
    required this.originalValue,
    required this.originalUnit,
    required this.convertedValue,
    required this.convertedUnit,
    required this.category,
    required this.precision,
    required this.conversionFactor,
    required this.timestamp,
    required this.conversionId,
    required this.qualityChain,
  });
}

// Quality chain metadata for conversions
class QualityChain {
  final String sourceToolId;
  final String conversionAlgorithm;
  final double accuracyLevel;        // Conversion accuracy (0.0-1.0)
  final String standardReference;    // NIST, ISO, etc.
  final List<String> transformationSteps;
  final Map<String, dynamic> validationData;

  QualityChain({
    required this.sourceToolId,
    required this.conversionAlgorithm,
    required this.accuracyLevel,
    required this.standardReference,
    required this.transformationSteps,
    required this.validationData,
  });
}
```

### ShareEnvelope Protocol Implementation

#### Event-Driven Integration

```dart
class UnitConverterIntegration {
  static const String TOOL_ID = 'unit-converter';

  // Register integration capabilities
  static void registerCapabilities() {
    ShareEnvelope.registerHandler(
      toolId: TOOL_ID,
      capabilities: [
        'convert_measurement',
        'normalize_units',
        'batch_convert',
        'detect_units',
        'validate_dimensions',
      ],
    );
  }

  // Handle incoming conversion requests
  static Future<ShareEnvelopeResponse> handleRequest(
    ShareEnvelopeRequest request,
  ) async {
    switch (request.action) {
      case 'convert_measurement':
        return await _handleConversion(request);
      case 'normalize_units':
        return await _handleNormalization(request);
      case 'batch_convert':
        return await _handleBatchConversion(request);
      case 'detect_units':
        return await _handleUnitDetection(request);
      case 'validate_dimensions':
        return await _handleDimensionValidation(request);
      default:
        return ShareEnvelopeResponse.error('Unknown action: ${request.action}');
    }
  }

  // Send conversion results to requesting tools
  static Future<void> sendConversionResult(
    ConversionResponse result,
    String targetToolId,
  ) async {
    final envelope = ShareEnvelope(
      sourceToolId: TOOL_ID,
      targetToolId: targetToolId,
      action: 'conversion_complete',
      data: result.toJson(),
      qualityChain: result.qualityChain,
      timestamp: DateTime.now(),
    );

    await ShareEnvelopeMessenger.send(envelope);
  }
}
```

---

## Cross-Tool Integration Patterns

### JSON Doctor Integration

#### Measurement Field Processing

```dart
// JSON Doctor sends measurement extraction requests
class JsonMeasurementExtraction {
  static Future<void> extractAndConvert(
    Map<String, dynamic> jsonData,
    String targetUnit,
  ) async {
    final request = ShareEnvelopeRequest(
      sourceToolId: 'json-doctor',
      targetToolId: 'unit-converter',
      action: 'extract_and_convert_measurements',
      data: {
        'json_data': jsonData,
        'target_unit': targetUnit,
        'extraction_patterns': [
          r'(\d+(?:\.\d+)?)\s*(km|kilometers?|miles?|m|meters?)',
          r'(\d+(?:\.\d+)?)\s*(kg|kilograms?|lbs?|pounds?)',
          r'(\d+(?:\.\d+)?)\s*°?([CF]|celsius|fahrenheit)',
        ],
      },
    );

    final response = await ShareEnvelopeMessenger.send(request);

    if (response.success) {
      final convertedData = response.data as Map<String, dynamic>;
      // Update JSON with standardized measurements
      await JsonDoctor.updateMeasurements(convertedData);
    }
  }
}

// Example JSON transformation
// Input JSON:
{
  "product": "Racing Bike",
  "weight": "15 kg",
  "top_speed": "45 mph",
  "wheel_diameter": "26 inches"
}

// Unit Converter processes and standardizes to metric:
{
  "product": "Racing Bike",
  "weight": "15 kg",
  "weight_original": "15 kg",
  "top_speed": "72.42 km/h",
  "top_speed_original": "45 mph",
  "wheel_diameter": "66.04 cm",
  "wheel_diameter_original": "26 inches",
  "_conversion_metadata": {
    "converted_by": "unit-converter",
    "conversion_timestamp": "2025-01-15T10:30:00Z",
    "accuracy_level": 0.9999
  }
}
```

#### Nested Measurement Processing

```dart
// Handle complex JSON structures with nested measurements
class NestedMeasurementProcessor {
  static Future<Map<String, dynamic>> processNestedJson(
    Map<String, dynamic> data,
    ConversionConfig config,
  ) async {
    final processedData = Map<String, dynamic>.from(data);

    await _traverseAndConvert(processedData, config, []);

    return processedData;
  }

  static Future<void> _traverseAndConvert(
    dynamic node,
    ConversionConfig config,
    List<String> path,
  ) async {
    if (node is Map<String, dynamic>) {
      for (final entry in node.entries) {
        final newPath = [...path, entry.key];

        if (entry.value is String) {
          final convertedValue = await _attemptConversion(
            entry.value as String,
            config,
            newPath,
          );
          if (convertedValue != null) {
            node[entry.key] = convertedValue.convertedValue;
            node['${entry.key}_original'] = entry.value;
            node['${entry.key}_unit'] = convertedValue.convertedUnit;
          }
        } else {
          await _traverseAndConvert(entry.value, config, newPath);
        }
      }
    } else if (node is List) {
      for (int i = 0; i < node.length; i++) {
        await _traverseAndConvert(node[i], config, [...path, i.toString()]);
      }
    }
  }
}
```

### Text Tools Integration

#### Measurement Text Processing

```dart
// Text Tools integration for measurement standardization
class TextMeasurementProcessor {
  static Future<String> standardizeMeasurements(
    String text,
    MeasurementStandard standard,
  ) async {
    final measurementPatterns = [
      // Length measurements
      RegExp(r'(\d+(?:\.\d+)?)\s*(km|kilometers?|miles?|mi|m|meters?|ft|feet|in|inches?)',
        caseSensitive: false),

      // Weight measurements
      RegExp(r'(\d+(?:\.\d+)?)\s*(kg|kilograms?|g|grams?|lbs?|pounds?|oz|ounces?)',
        caseSensitive: false),

      // Temperature measurements
      RegExp(r'(\d+(?:\.\d+)?)\s*°?([CF]|celsius|fahrenheit|kelvin)',
        caseSensitive: false),

      // Volume measurements
      RegExp(r'(\d+(?:\.\d+)?)\s*(l|liters?|ml|milliliters?|gal|gallons?|fl\s*oz)',
        caseSensitive: false),
    ];

    String processedText = text;

    for (final pattern in measurementPatterns) {
      final matches = pattern.allMatches(processedText);

      for (final match in matches.toList().reversed) {
        final value = double.tryParse(match.group(1) ?? '');
        final unit = match.group(2)?.toLowerCase() ?? '';

        if (value != null) {
          final conversion = await _convertToStandard(value, unit, standard);
          if (conversion != null) {
            final replacement = _formatConversion(conversion, standard);
            processedText = processedText.replaceRange(
              match.start,
              match.end,
              replacement,
            );
          }
        }
      }
    }

    return processedText;
  }

  // Format conversion based on standard preference
  static String _formatConversion(
    ConversionResponse conversion,
    MeasurementStandard standard,
  ) {
    switch (standard) {
      case MeasurementStandard.metric:
        return '${conversion.convertedValue.toStringAsFixed(2)} ${conversion.convertedUnit}';
      case MeasurementStandard.imperial:
        return '${conversion.convertedValue.toStringAsFixed(2)} ${conversion.convertedUnit}';
      case MeasurementStandard.scientific:
        return '${conversion.convertedValue.toStringAsExponential(3)} ${conversion.convertedUnit}';
      case MeasurementStandard.dual:
        return '${conversion.convertedValue.toStringAsFixed(2)} ${conversion.convertedUnit} '
               '(${conversion.originalValue} ${conversion.originalUnit})';
    }
  }
}

// Example text transformation
// Input text:
"The marathon distance is 26.2 miles, and the temperature was 75°F."

// Standardized to metric:
"The marathon distance is 42.16 km (26.2 miles), and the temperature was 23.89°C (75°F)."
```

### API Tools Integration

#### Request/Response Standardization

```dart
// API Tools integration for measurement standardization in requests/responses
class ApiMeasurementStandardizer {
  static Future<Map<String, dynamic>> standardizeApiData(
    Map<String, dynamic> apiData,
    ApiConversionConfig config,
  ) async {
    final standardizedData = Map<String, dynamic>.from(apiData);

    // Process request data
    if (config.standardizeRequests) {
      await _standardizeRequestFields(standardizedData, config);
    }

    // Process response data
    if (config.standardizeResponses) {
      await _standardizeResponseFields(standardizedData, config);
    }

    return standardizedData;
  }

  static Future<void> _standardizeRequestFields(
    Map<String, dynamic> data,
    ApiConversionConfig config,
  ) async {
    for (final field in config.requestFields) {
      if (data.containsKey(field.sourceField)) {
        final originalValue = data[field.sourceField];

        if (originalValue is num) {
          final conversion = await UnitConverter.convert(
            originalValue.toDouble(),
            field.sourceUnit,
            field.targetUnit,
            field.category,
          );

          data[field.targetField ?? field.sourceField] = conversion.convertedValue;

          if (config.preserveOriginals) {
            data['${field.sourceField}_original'] = originalValue;
            data['${field.sourceField}_unit'] = field.sourceUnit;
          }
        }
      }
    }
  }
}

// Example API data transformation
// Input API request:
{
  "location": "New York",
  "search_radius": 5,  // miles
  "search_radius_unit": "miles",
  "max_weight": 50,    // pounds
  "max_weight_unit": "lbs"
}

// Standardized API request (metric):
{
  "location": "New York",
  "search_radius": 8.05,
  "search_radius_unit": "km",
  "search_radius_original": 5,
  "max_weight": 22.68,
  "max_weight_unit": "kg",
  "max_weight_original": 50,
  "_conversion_metadata": {
    "standardized_by": "unit-converter",
    "conversion_timestamp": "2025-01-15T10:30:00Z"
  }
}
```

### Calculator Integration

#### Mathematical Expression Unit Support

```dart
// Calculator integration for unit-aware calculations
class UnitAwareCalculator {
  static Future<CalculationResult> evaluateWithUnits(
    String expression,
  ) async {
    // Parse expression for unit components
    final unitParser = UnitExpressionParser();
    final parsedExpression = await unitParser.parse(expression);

    // Example: "5 km + 3 miles * 2"
    // Parsed: [
    //   {value: 5, unit: "km", operation: "+"},
    //   {value: 3, unit: "miles", operation: "*", operand: 2}
    // ]

    // Convert all measurements to common base units
    final normalizedTerms = <CalculationTerm>[];
    String commonUnit = _determineCommonUnit(parsedExpression);

    for (final term in parsedExpression) {
      if (term.hasUnit) {
        final conversion = await UnitConverter.convert(
          term.value,
          term.unit,
          commonUnit,
          term.category,
        );

        normalizedTerms.add(CalculationTerm(
          value: conversion.convertedValue,
          unit: conversion.convertedUnit,
          operation: term.operation,
          operand: term.operand,
        ));
      } else {
        normalizedTerms.add(term);
      }
    }

    // Perform calculation with normalized values
    final result = await Calculator.evaluate(normalizedTerms);

    return CalculationResult(
      value: result.value,
      unit: commonUnit,
      expression: expression,
      normalizedExpression: _formatNormalizedExpression(normalizedTerms),
      conversionSteps: result.conversionSteps,
    );
  }
}

// Example calculation
// Input: "5 km + 3 miles"
// Conversion: "5 km + 4.83 km"
// Result: "9.83 km"
```

---

## Database Integration Patterns

### Multi-Database Unit Standardization

#### Database Schema Harmonization

```dart
// Database Tools integration for unit standardization across different databases
class DatabaseUnitHarmonizer {
  static Future<void> harmonizeUnits(
    List<DatabaseConnection> databases,
    UnitHarmonizationConfig config,
  ) async {
    for (final db in databases) {
      final tables = await db.getTablesWithMeasurements();

      for (final table in tables) {
        await _harmonizeTableUnits(db, table, config);
      }
    }
  }

  static Future<void> _harmonizeTableUnits(
    DatabaseConnection db,
    TableInfo table,
    UnitHarmonizationConfig config,
  ) async {
    final measurementColumns = table.columns
        .where((col) => config.measurementPatterns.any(
            (pattern) => pattern.hasMatch(col.name)))
        .toList();

    for (final column in measurementColumns) {
      await _standardizeColumn(db, table, column, config);
    }
  }

  static Future<void> _standardizeColumn(
    DatabaseConnection db,
    TableInfo table,
    ColumnInfo column,
    UnitHarmonizationConfig config,
  ) async {
    // Read existing data with units
    final query = '''
      SELECT id, ${column.name}, ${column.name}_unit
      FROM ${table.name}
      WHERE ${column.name}_unit IS NOT NULL
    ''';

    final rows = await db.query(query);

    for (final row in rows) {
      final value = row[column.name] as double;
      final unit = row['${column.name}_unit'] as String;
      final targetUnit = config.getTargetUnit(column.name);

      if (unit != targetUnit) {
        final conversion = await UnitConverter.convert(
          value,
          unit,
          targetUnit,
          config.getCategory(column.name),
        );

        // Update with converted value
        await db.update(
          table.name,
          {
            column.name: conversion.convertedValue,
            '${column.name}_unit': conversion.convertedUnit,
            '${column.name}_original': value,
            '${column.name}_original_unit': unit,
          },
          where: 'id = ?',
          whereArgs: [row['id']],
        );
      }
    }
  }
}
```

#### Cross-Database Unit Queries

```dart
// Enable unit-aware queries across different database systems
class CrossDatabaseUnitQueries {
  static Future<List<Map<String, dynamic>>> queryWithUnitConversion(
    String query,
    String targetUnit,
    List<DatabaseConnection> databases,
  ) async {
    final results = <Map<String, dynamic>>[];

    for (final db in databases) {
      final dbResults = await db.query(query);

      for (final row in dbResults) {
        final convertedRow = await _convertRowUnits(row, targetUnit);
        results.add({
          ...convertedRow,
          '_source_database': db.identifier,
          '_conversion_timestamp': DateTime.now().toIso8601String(),
        });
      }
    }

    return results;
  }

  static Future<Map<String, dynamic>> _convertRowUnits(
    Map<String, dynamic> row,
    String targetUnit,
  ) async {
    final convertedRow = Map<String, dynamic>.from(row);

    // Detect measurement fields
    for (final entry in row.entries) {
      if (entry.key.endsWith('_unit')) {
        final valueField = entry.key.replaceAll('_unit', '');
        final unit = entry.value as String;
        final value = row[valueField];

        if (value is num && unit != targetUnit) {
          final conversion = await UnitConverter.convert(
            value.toDouble(),
            unit,
            targetUnit,
            _inferCategory(unit),
          );

          convertedRow[valueField] = conversion.convertedValue;
          convertedRow[entry.key] = conversion.convertedUnit;
          convertedRow['${valueField}_original'] = value;
        }
      }
    }

    return convertedRow;
  }
}
```

---

## Workflow Automation Integration

### Automated Measurement Workflows

#### Batch Processing Pipeline

```dart
// Automated workflow for batch measurement processing
class MeasurementWorkflowAutomation {
  static Future<WorkflowResult> processMeasurementWorkflow(
    WorkflowDefinition workflow,
  ) async {
    final steps = <WorkflowStep>[];

    for (final step in workflow.steps) {
      switch (step.type) {
        case 'data_ingestion':
          final data = await _ingestMeasurementData(step);
          steps.add(WorkflowStep.completed(step.id, data));
          break;

        case 'unit_standardization':
          final standardizedData = await _standardizeUnits(step);
          steps.add(WorkflowStep.completed(step.id, standardizedData));
          break;

        case 'validation':
          final validationResult = await _validateMeasurements(step);
          steps.add(WorkflowStep.completed(step.id, validationResult));
          break;

        case 'output_generation':
          final output = await _generateOutput(step);
          steps.add(WorkflowStep.completed(step.id, output));
          break;
      }
    }

    return WorkflowResult(
      workflowId: workflow.id,
      steps: steps,
      status: WorkflowStatus.completed,
      completedAt: DateTime.now(),
    );
  }

  static Future<Map<String, dynamic>> _standardizeUnits(
    WorkflowStep step,
  ) async {
    final config = StandardizationConfig.fromJson(step.configuration);
    final inputData = step.inputData as List<Map<String, dynamic>>;
    final standardizedData = <Map<String, dynamic>>[];

    for (final record in inputData) {
      final standardizedRecord = Map<String, dynamic>.from(record);

      for (final field in config.measurementFields) {
        if (record.containsKey(field.name)) {
          final value = record[field.name];
          final sourceUnit = record[field.unitField] ?? field.defaultUnit;

          if (value is num && sourceUnit != field.targetUnit) {
            final conversion = await UnitConverter.convert(
              value.toDouble(),
              sourceUnit,
              field.targetUnit,
              field.category,
            );

            standardizedRecord[field.name] = conversion.convertedValue;
            standardizedRecord[field.unitField] = conversion.convertedUnit;
            standardizedRecord['${field.name}_conversion_metadata'] = {
              'original_value': value,
              'original_unit': sourceUnit,
              'conversion_factor': conversion.conversionFactor,
              'accuracy': conversion.qualityChain.accuracyLevel,
            };
          }
        }
      }

      standardizedData.add(standardizedRecord);
    }

    return {
      'standardized_records': standardizedData,
      'standardization_summary': {
        'total_records': inputData.length,
        'conversions_performed': _countConversions(standardizedData),
        'standardization_timestamp': DateTime.now().toIso8601String(),
      },
    };
  }
}
```

#### Real-Time Measurement Streams

```dart
// Real-time measurement data processing with unit conversion
class RealTimeMeasurementProcessor {
  static Stream<ConvertedMeasurement> processMeasurementStream(
    Stream<RawMeasurement> inputStream,
    ConversionConfig config,
  ) async* {
    await for (final measurement in inputStream) {
      try {
        final conversion = await UnitConverter.convert(
          measurement.value,
          measurement.unit,
          config.targetUnit,
          measurement.category,
        );

        yield ConvertedMeasurement(
          id: measurement.id,
          timestamp: measurement.timestamp,
          originalValue: measurement.value,
          originalUnit: measurement.unit,
          convertedValue: conversion.convertedValue,
          convertedUnit: conversion.convertedUnit,
          conversionFactor: conversion.conversionFactor,
          quality: conversion.qualityChain,
          sourceDevice: measurement.sourceDevice,
        );
      } catch (e) {
        // Log conversion error and emit error measurement
        yield ConvertedMeasurement.error(
          measurement.id,
          measurement.timestamp,
          'Conversion failed: $e',
        );
      }
    }
  }

  // Aggregate converted measurements for analytics
  static Future<MeasurementAnalytics> analyzeMeasurementStream(
    Stream<ConvertedMeasurement> stream,
    Duration windowSize,
  ) async {
    final measurements = <ConvertedMeasurement>[];
    final subscription = stream.listen(measurements.add);

    await Future.delayed(windowSize);
    await subscription.cancel();

    return MeasurementAnalytics(
      totalMeasurements: measurements.length,
      averageValue: _calculateAverage(measurements),
      standardDeviation: _calculateStandardDeviation(measurements),
      conversionAccuracy: _calculateConversionAccuracy(measurements),
      unitDistribution: _analyzeUnitDistribution(measurements),
      timeRange: DateTimeRange(
        start: measurements.first.timestamp,
        end: measurements.last.timestamp,
      ),
    );
  }
}
```

---

## Enterprise Integration Features

### Multi-Tenant Unit Management

#### Organization-Specific Unit Systems

```dart
// Enterprise-grade multi-tenant unit management
class EnterpriseUnitManager {
  static Future<void> configureOrganizationUnits(
    String organizationId,
    OrganizationUnitConfig config,
  ) async {
    await _validateUnitConfig(config);

    final unitSystem = UnitSystem(
      organizationId: organizationId,
      preferredUnits: config.preferredUnits,
      customUnits: config.customUnits,
      conversionRules: config.conversionRules,
      precisionSettings: config.precisionSettings,
      validationRules: config.validationRules,
    );

    await UnitSystemRepository.save(unitSystem);

    // Notify all organization tools about unit system update
    await ShareEnvelopeMessenger.broadcast(
      organizationId: organizationId,
      message: ShareEnvelope(
        sourceToolId: 'unit-converter',
        targetToolId: 'all',
        action: 'unit_system_updated',
        data: unitSystem.toJson(),
      ),
    );
  }

  static Future<ConversionResponse> convertWithOrganizationRules(
    ConversionRequest request,
    String organizationId,
  ) async {
    final unitSystem = await UnitSystemRepository.getByOrganization(organizationId);

    // Apply organization-specific conversion rules
    final effectiveRequest = _applyOrganizationRules(request, unitSystem);

    // Perform conversion with custom rules
    final conversion = await UnitConverter.convertWithCustomRules(
      effectiveRequest,
      unitSystem.conversionRules,
    );

    // Apply organization precision settings
    final precisionAdjustedResult = _applyPrecisionRules(
      conversion,
      unitSystem.precisionSettings,
    );

    return precisionAdjustedResult;
  }
}
```

#### Custom Unit Definition System

```dart
// Custom unit definition for specialized organizations
class CustomUnitDefinition {
  final String name;
  final String symbol;
  final String category;
  final double conversionFactor;  // Factor to base unit
  final String baseUnit;
  final List<String> aliases;
  final String description;
  final Map<String, dynamic> metadata;

  CustomUnitDefinition({
    required this.name,
    required this.symbol,
    required this.category,
    required this.conversionFactor,
    required this.baseUnit,
    this.aliases = const [],
    required this.description,
    this.metadata = const {},
  });

  // Example: Oil industry barrel unit
  static CustomUnitDefinition createOilBarrel() {
    return CustomUnitDefinition(
      name: 'oil barrel',
      symbol: 'bbl',
      category: 'volume',
      conversionFactor: 158.987294928, // Liters per barrel
      baseUnit: 'liter',
      aliases: ['barrel', 'bbl', 'oil bbl'],
      description: 'Standard oil industry barrel (42 US gallons)',
      metadata: {
        'industry': 'oil_and_gas',
        'standard': 'API',
        'precision_recommendation': 3,
      },
    );
  }

  // Example: Engineering slug unit
  static CustomUnitDefinition createSlug() {
    return CustomUnitDefinition(
      name: 'slug',
      symbol: 'slug',
      category: 'mass',
      conversionFactor: 14.5939029372, // Kilograms per slug
      baseUnit: 'kilogram',
      aliases: ['slug', 'slugs'],
      description: 'Imperial unit of mass (1 slug = 32.174 lbm)',
      metadata: {
        'industry': 'engineering',
        'system': 'imperial',
        'precision_recommendation': 4,
      },
    );
  }
}

class CustomUnitManager {
  static Future<void> registerCustomUnit(
    CustomUnitDefinition unit,
    String organizationId,
  ) async {
    // Validate unit definition
    await _validateCustomUnit(unit);

    // Register with conversion engine
    await UnitConverter.registerCustomUnit(unit);

    // Store in organization unit system
    final unitSystem = await UnitSystemRepository.getByOrganization(organizationId);
    unitSystem.addCustomUnit(unit);
    await UnitSystemRepository.save(unitSystem);

    // Update search index
    await UnitSearchIndex.addCustomUnit(unit, organizationId);
  }
}
```

### Audit Trail & Compliance

#### Conversion Audit System

```dart
// Comprehensive audit trail for unit conversions
class ConversionAuditTrail {
  static Future<void> logConversion(
    ConversionRequest request,
    ConversionResponse response,
    AuditContext context,
  ) async {
    final auditEntry = ConversionAuditEntry(
      auditId: generateUuid(),
      timestamp: DateTime.now(),
      userId: context.userId,
      organizationId: context.organizationId,
      sourceToolId: request.sourceToolId,
      conversionRequest: request,
      conversionResponse: response,
      sessionId: context.sessionId,
      ipAddress: context.ipAddress,
      userAgent: context.userAgent,
      complianceFlags: _generateComplianceFlags(request, response),
    );

    await AuditRepository.store(auditEntry);

    // Trigger compliance checks
    await ComplianceChecker.validateConversion(auditEntry);
  }

  static Future<List<ConversionAuditEntry>> getAuditTrail(
    AuditQueryParameters params,
  ) async {
    final query = AuditQuery()
      ..organizationId = params.organizationId
      ..startDate = params.startDate
      ..endDate = params.endDate
      ..userId = params.userId
      ..sourceToolIds = params.sourceToolIds;

    return await AuditRepository.query(query);
  }

  static Future<ComplianceReport> generateComplianceReport(
    String organizationId,
    DateTimeRange period,
  ) async {
    final auditEntries = await getAuditTrail(
      AuditQueryParameters(
        organizationId: organizationId,
        startDate: period.start,
        endDate: period.end,
      ),
    );

    return ComplianceReport(
      organizationId: organizationId,
      period: period,
      totalConversions: auditEntries.length,
      accuracyStatistics: _calculateAccuracyStats(auditEntries),
      standardsCompliance: _checkStandardsCompliance(auditEntries),
      unitUsageStatistics: _analyzeUnitUsage(auditEntries),
      anomalies: _detectAnomalies(auditEntries),
      recommendations: _generateRecommendations(auditEntries),
    );
  }
}
```

---

## Performance & Scalability

### High-Volume Conversion Processing

#### Batch Processing Optimization

```dart
// Optimized batch conversion processing for high-volume scenarios
class HighVolumeConversionProcessor {
  static Future<BatchConversionResult> processBatch(
    List<ConversionRequest> requests,
    BatchProcessingConfig config,
  ) async {
    final results = <ConversionResponse>[];
    final errors = <ConversionError>[];

    // Group conversions by category for optimization
    final groupedRequests = _groupByCategory(requests);

    // Process each category in parallel
    final futures = groupedRequests.entries.map((entry) async {
      final category = entry.key;
      final categoryRequests = entry.value;

      return await _processCategoryBatch(category, categoryRequests, config);
    });

    final categoryResults = await Future.wait(futures);

    // Merge results
    for (final categoryResult in categoryResults) {
      results.addAll(categoryResult.successfulConversions);
      errors.addAll(categoryResult.errors);
    }

    return BatchConversionResult(
      totalRequests: requests.length,
      successfulConversions: results,
      errors: errors,
      processingDuration: DateTime.now().difference(config.startTime),
      throughput: results.length / config.startTime.difference(DateTime.now()).inSeconds,
    );
  }

  static Future<CategoryBatchResult> _processCategoryBatch(
    String category,
    List<ConversionRequest> requests,
    BatchProcessingConfig config,
  ) async {
    final results = <ConversionResponse>[];
    final errors = <ConversionError>[];

    // Pre-load conversion factors for the category
    final conversionFactors = await UnitConverter.getConversionFactors(category);

    // Process requests in chunks to manage memory
    final chunks = _chunkList(requests, config.chunkSize);

    for (final chunk in chunks) {
      final chunkFutures = chunk.map((request) async {
        try {
          final response = await UnitConverter.convertWithPreloadedFactors(
            request,
            conversionFactors,
          );
          return Either<ConversionResponse, ConversionError>.left(response);
        } catch (e) {
          return Either<ConversionResponse, ConversionError>.right(
            ConversionError(request: request, error: e.toString()),
          );
        }
      });

      final chunkResults = await Future.wait(chunkFutures);

      for (final result in chunkResults) {
        result.fold(
          (response) => results.add(response),
          (error) => errors.add(error),
        );
      }

      // Yield control to prevent blocking
      if (config.yielding) {
        await Future.delayed(Duration.zero);
      }
    }

    return CategoryBatchResult(
      category: category,
      successfulConversions: results,
      errors: errors,
    );
  }
}
```

#### Caching Strategy

```dart
// Advanced caching for improved conversion performance
class ConversionCacheManager {
  static final _conversionCache = LRUCache<String, ConversionResponse>(1000);
  static final _factorCache = LRUCache<String, double>(5000);

  static Future<ConversionResponse> getCachedConversion(
    ConversionRequest request,
  ) async {
    final cacheKey = _generateCacheKey(request);

    // Check cache first
    final cachedResult = _conversionCache.get(cacheKey);
    if (cachedResult != null) {
      return cachedResult.copyWith(
        timestamp: DateTime.now(),
        qualityChain: cachedResult.qualityChain.copyWith(
          sourceToolId: 'unit-converter-cache',
        ),
      );
    }

    // Perform conversion and cache result
    final result = await UnitConverter.convert(
      request.value,
      request.fromUnit,
      request.toUnit!,
      request.category!,
    );

    _conversionCache.put(cacheKey, result);

    return result;
  }

  static Future<double> getCachedConversionFactor(
    String fromUnit,
    String toUnit,
    String category,
  ) async {
    final factorKey = '${category}_${fromUnit}_${toUnit}';

    final cachedFactor = _factorCache.get(factorKey);
    if (cachedFactor != null) {
      return cachedFactor;
    }

    final factor = await UnitConverter.getConversionFactor(
      fromUnit,
      toUnit,
      category,
    );

    _factorCache.put(factorKey, factor);

    return factor;
  }

  static String _generateCacheKey(ConversionRequest request) {
    return '${request.category}_${request.fromUnit}_${request.toUnit}_'
           '${request.value}_${request.precision}';
  }

  static void invalidateCache() {
    _conversionCache.clear();
    _factorCache.clear();
  }

  static CacheStatistics getCacheStatistics() {
    return CacheStatistics(
      conversionCacheSize: _conversionCache.length,
      conversionCacheHitRate: _conversionCache.hitRate,
      factorCacheSize: _factorCache.length,
      factorCacheHitRate: _factorCache.hitRate,
      totalMemoryUsage: _estimateMemoryUsage(),
    );
  }
}
```

---

## Error Handling & Recovery

### Comprehensive Error Management

#### Error Classification System

```dart
// Structured error handling for integration scenarios
enum ConversionErrorType {
  invalidInput,
  unknownUnit,
  categoryMismatch,
  precisionOverflow,
  conversionFactorMissing,
  customUnitError,
  networkTimeout,
  authenticationFailure,
  quotaExceeded,
  systemError,
}

class ConversionError {
  final ConversionErrorType type;
  final String message;
  final ConversionRequest? originalRequest;
  final Map<String, dynamic> metadata;
  final DateTime timestamp;
  final String errorId;

  ConversionError({
    required this.type,
    required this.message,
    this.originalRequest,
    this.metadata = const {},
    DateTime? timestamp,
    String? errorId,
  }) :
    timestamp = timestamp ?? DateTime.now(),
    errorId = errorId ?? generateUuid();

  // Create specific error types
  static ConversionError invalidInput(
    ConversionRequest request,
    String details,
  ) {
    return ConversionError(
      type: ConversionErrorType.invalidInput,
      message: 'Invalid input value: $details',
      originalRequest: request,
      metadata: {
        'input_value': request.value,
        'from_unit': request.fromUnit,
        'validation_details': details,
      },
    );
  }

  static ConversionError unknownUnit(
    ConversionRequest request,
    String unknownUnit,
  ) {
    return ConversionError(
      type: ConversionErrorType.unknownUnit,
      message: 'Unknown unit: $unknownUnit',
      originalRequest: request,
      metadata: {
        'unknown_unit': unknownUnit,
        'suggested_units': UnitSearch.findSimilarUnits(unknownUnit),
        'available_categories': UnitConverter.getCategories(),
      },
    );
  }
}
```

#### Error Recovery Strategies

```dart
// Automatic error recovery and fallback mechanisms
class ConversionErrorRecovery {
  static Future<ConversionResponse?> attemptRecovery(
    ConversionError error,
  ) async {
    switch (error.type) {
      case ConversionErrorType.unknownUnit:
        return await _attemptUnitCorrection(error);

      case ConversionErrorType.categoryMismatch:
        return await _attemptCategoryInference(error);

      case ConversionErrorType.precisionOverflow:
        return await _attemptPrecisionReduction(error);

      case ConversionErrorType.customUnitError:
        return await _attemptStandardUnitFallback(error);

      default:
        return null; // No recovery possible
    }
  }

  static Future<ConversionResponse?> _attemptUnitCorrection(
    ConversionError error,
  ) async {
    if (error.originalRequest == null) return null;

    final request = error.originalRequest!;
    final suggestions = error.metadata['suggested_units'] as List<String>?;

    if (suggestions != null && suggestions.isNotEmpty) {
      // Try the most likely suggestion
      final correctedRequest = request.copyWith(
        fromUnit: suggestions.first,
      );

      try {
        return await UnitConverter.convert(
          correctedRequest.value,
          correctedRequest.fromUnit,
          correctedRequest.toUnit!,
          correctedRequest.category!,
        );
      } catch (e) {
        // Recovery failed
        return null;
      }
    }

    return null;
  }

  static Future<ConversionResponse?> _attemptCategoryInference(
    ConversionError error,
  ) async {
    if (error.originalRequest == null) return null;

    final request = error.originalRequest!;

    // Attempt to infer category from units
    final inferredCategory = UnitCategoryInference.inferFromUnits(
      request.fromUnit,
      request.toUnit,
    );

    if (inferredCategory != null) {
      final correctedRequest = request.copyWith(category: inferredCategory);

      try {
        return await UnitConverter.convert(
          correctedRequest.value,
          correctedRequest.fromUnit,
          correctedRequest.toUnit!,
          correctedRequest.category!,
        );
      } catch (e) {
        return null;
      }
    }

    return null;
  }
}
```

---

## Security & Compliance Integration

### Data Security Measures

#### Secure Conversion Processing

```dart
// Security measures for sensitive measurement data
class SecureConversionProcessor {
  static Future<ConversionResponse> processSecureConversion(
    ConversionRequest request,
    SecurityContext context,
  ) async {
    // Validate security context
    await SecurityValidator.validateContext(context);

    // Apply data sanitization
    final sanitizedRequest = await DataSanitizer.sanitize(request);

    // Perform conversion with audit logging
    final response = await UnitConverter.convert(
      sanitizedRequest.value,
      sanitizedRequest.fromUnit,
      sanitizedRequest.toUnit!,
      sanitizedRequest.category!,
    );

    // Log security event
    await SecurityLogger.logConversion(
      request: sanitizedRequest,
      response: response,
      context: context,
    );

    // Apply output sanitization
    return await OutputSanitizer.sanitize(response, context);
  }

  // Handle personally identifiable information (PII) in measurements
  static Future<ConversionResponse> processPIIAwareConversion(
    ConversionRequest request,
    PIIContext piiContext,
  ) async {
    // Check for PII in measurement metadata
    final piiDetection = await PIIDetector.analyze(request.metadata);

    if (piiDetection.containsPII) {
      // Apply PII protection measures
      final protectedRequest = await PIIProtector.protect(request, piiContext);

      // Process with enhanced audit trail
      final response = await processSecureConversion(
        protectedRequest,
        piiContext.securityContext,
      );

      // Remove PII from response if necessary
      return await PIIProtector.sanitizeResponse(response, piiContext);
    }

    // Standard processing for non-PII data
    return await UnitConverter.convert(
      request.value,
      request.fromUnit,
      request.toUnit!,
      request.category!,
    );
  }
}
```

#### Compliance Framework Integration

```dart
// Integration with various compliance frameworks
class ComplianceIntegration {
  static Future<ComplianceValidationResult> validateForCompliance(
    ConversionRequest request,
    List<ComplianceStandard> standards,
  ) async {
    final validationResults = <StandardValidationResult>[];

    for (final standard in standards) {
      final result = await _validateAgainstStandard(request, standard);
      validationResults.add(result);
    }

    return ComplianceValidationResult(
      overallCompliance: validationResults.every((r) => r.isCompliant),
      standardResults: validationResults,
      recommendations: _generateComplianceRecommendations(validationResults),
    );
  }

  static Future<StandardValidationResult> _validateAgainstStandard(
    ConversionRequest request,
    ComplianceStandard standard,
  ) async {
    switch (standard.type) {
      case ComplianceType.iso:
        return await ISOValidator.validate(request, standard);

      case ComplianceType.nist:
        return await NISTValidator.validate(request, standard);

      case ComplianceType.fda:
        return await FDAValidator.validate(request, standard);

      case ComplianceType.gdpr:
        return await GDPRValidator.validate(request, standard);

      default:
        return StandardValidationResult.notApplicable(standard);
    }
  }
}

// Example: FDA compliance for pharmaceutical measurements
class FDAValidator {
  static Future<StandardValidationResult> validate(
    ConversionRequest request,
    ComplianceStandard standard,
  ) async {
    final validations = <ValidationCheck>[];

    // Check measurement precision requirements
    if (request.category == 'mass' && _isPharmaceuticalContext(request)) {
      final precisionCheck = _validatePrecision(request, standard);
      validations.add(precisionCheck);
    }

    // Check unit standardization requirements
    final unitCheck = _validateUnitStandardization(request, standard);
    validations.add(unitCheck);

    // Check traceability requirements
    final traceabilityCheck = _validateTraceability(request, standard);
    validations.add(traceabilityCheck);

    return StandardValidationResult(
      standard: standard,
      isCompliant: validations.every((v) => v.passed),
      validationChecks: validations,
      complianceScore: _calculateComplianceScore(validations),
    );
  }
}
```

---

**Unit Converter Integration Guide** - Comprehensive measurement standardization across the Toolspace ecosystem with enterprise-grade accuracy, security, and compliance features.

_Integration Version 1.0.0 • Updated October 11, 2025 • ShareEnvelope Framework v3.2.0_
