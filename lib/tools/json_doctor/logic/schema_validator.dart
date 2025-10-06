/// Error found during schema validation
class SchemaValidationError {
  final String path;
  final String message;
  final String expectedType;
  final String actualType;
  final dynamic actualValue;

  const SchemaValidationError({
    required this.path,
    required this.message,
    required this.expectedType,
    required this.actualType,
    required this.actualValue,
  });

  @override
  String toString() {
    return 'Path: $path - $message (Expected: $expectedType, Got: $actualType)';
  }
}

/// JSON Schema validation result
class SchemaValidationResult {
  final bool isValid;
  final List<SchemaValidationError> errors;

  const SchemaValidationResult({required this.isValid, required this.errors});
}

/// Simple JSON Schema validator
class SchemaValidator {
  /// Validate JSON data against a schema
  static SchemaValidationResult validate(
    dynamic data,
    Map<String, dynamic> schema,
  ) {
    final errors = <SchemaValidationError>[];
    _validateNode(data, schema, '', errors);

    return SchemaValidationResult(isValid: errors.isEmpty, errors: errors);
  }

  static void _validateNode(
    dynamic data,
    dynamic schema,
    String path,
    List<SchemaValidationError> errors,
  ) {
    if (schema is! Map<String, dynamic>) return;

    // Type validation
    final expectedType = schema['type'] as String?;
    if (expectedType != null) {
      final actualType = _getJsonType(data);
      if (actualType != expectedType) {
        errors.add(
          SchemaValidationError(
            path: path.isEmpty ? 'root' : path,
            message: 'Type mismatch',
            expectedType: expectedType,
            actualType: actualType,
            actualValue: data,
          ),
        );
        return; // Skip further validation if type is wrong
      }
    }

    // Required properties validation
    final required = schema['required'] as List<dynamic>?;
    if (required != null && data is Map<String, dynamic>) {
      for (final prop in required) {
        if (!data.containsKey(prop)) {
          errors.add(
            SchemaValidationError(
              path: path.isEmpty ? prop.toString() : '$path.$prop',
              message: 'Required property missing',
              expectedType: 'property',
              actualType: 'missing',
              actualValue: null,
            ),
          );
        }
      }
    }

    // Properties validation
    final properties = schema['properties'] as Map<String, dynamic>?;
    if (properties != null && data is Map<String, dynamic>) {
      for (final entry in properties.entries) {
        final key = entry.key;
        final propSchema = entry.value;
        final propPath = path.isEmpty ? key : '$path.$key';

        if (data.containsKey(key)) {
          _validateNode(data[key], propSchema, propPath, errors);
        }
      }
    }

    // Array items validation
    final items = schema['items'];
    if (items != null && data is List) {
      for (int i = 0; i < data.length; i++) {
        final itemPath = path.isEmpty ? '[$i]' : '$path[$i]';
        _validateNode(data[i], items, itemPath, errors);
      }
    }

    // Min/Max length validation
    final minLength = schema['minLength'] as int?;
    final maxLength = schema['maxLength'] as int?;
    if (data is String) {
      if (minLength != null && data.length < minLength) {
        errors.add(
          SchemaValidationError(
            path: path.isEmpty ? 'root' : path,
            message: 'String too short',
            expectedType: 'string(min: $minLength)',
            actualType: 'string(${data.length})',
            actualValue: data,
          ),
        );
      }
      if (maxLength != null && data.length > maxLength) {
        errors.add(
          SchemaValidationError(
            path: path.isEmpty ? 'root' : path,
            message: 'String too long',
            expectedType: 'string(max: $maxLength)',
            actualType: 'string(${data.length})',
            actualValue: data,
          ),
        );
      }
    }

    // Minimum/Maximum validation
    final minimum = schema['minimum'] as num?;
    final maximum = schema['maximum'] as num?;
    if (data is num) {
      if (minimum != null && data < minimum) {
        errors.add(
          SchemaValidationError(
            path: path.isEmpty ? 'root' : path,
            message: 'Number below minimum',
            expectedType: 'number(min: $minimum)',
            actualType: 'number($data)',
            actualValue: data,
          ),
        );
      }
      if (maximum != null && data > maximum) {
        errors.add(
          SchemaValidationError(
            path: path.isEmpty ? 'root' : path,
            message: 'Number above maximum',
            expectedType: 'number(max: $maximum)',
            actualType: 'number($data)',
            actualValue: data,
          ),
        );
      }
    }

    // Enum validation
    final enumValues = schema['enum'] as List<dynamic>?;
    if (enumValues != null && !enumValues.contains(data)) {
      errors.add(
        SchemaValidationError(
          path: path.isEmpty ? 'root' : path,
          message: 'Value not in enum',
          expectedType: 'enum(${enumValues.join(', ')})',
          actualType: _getJsonType(data),
          actualValue: data,
        ),
      );
    }
  }

  static String _getJsonType(dynamic value) {
    if (value == null) return 'null';
    if (value is bool) return 'boolean';
    if (value is int) return 'integer';
    if (value is double) return 'number';
    if (value is String) return 'string';
    if (value is List) return 'array';
    if (value is Map) return 'object';
    return 'unknown';
  }

  /// Generate a sample schema from JSON data
  static Map<String, dynamic> generateSchema(dynamic data) {
    if (data == null) {
      return {'type': 'null'};
    }

    if (data is bool) {
      return {'type': 'boolean'};
    }

    if (data is int) {
      return {'type': 'integer'};
    }

    if (data is double) {
      return {'type': 'number'};
    }

    if (data is String) {
      return {
        'type': 'string',
        'minLength': 0,
        'maxLength': data.length * 2, // Allow some flexibility
      };
    }

    if (data is List) {
      final schema = <String, dynamic>{'type': 'array'};
      if (data.isNotEmpty) {
        schema['items'] = generateSchema(data.first);
      }
      return schema;
    }

    if (data is Map<String, dynamic>) {
      final properties = <String, dynamic>{};
      final required = <String>[];

      for (final entry in data.entries) {
        properties[entry.key] = generateSchema(entry.value);
        required.add(entry.key);
      }

      return {'type': 'object', 'properties': properties, 'required': required};
    }

    return {'type': 'unknown'};
  }
}
