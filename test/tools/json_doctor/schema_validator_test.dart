import 'package:flutter_test/flutter_test.dart';
import 'package:toolspace/tools/json_doctor/logic/schema_validator.dart';

void main() {
  group('SchemaValidator Tests', () {
    group('Type Validation', () {
      test('validates string type correctly', () {
        final schema = {'type': 'string'};

        final validResult = SchemaValidator.validate('hello', schema);
        expect(validResult.isValid, true);
        expect(validResult.errors, isEmpty);

        final invalidResult = SchemaValidator.validate(123, schema);
        expect(invalidResult.isValid, false);
        expect(invalidResult.errors.length, 1);
        expect(invalidResult.errors.first.expectedType, 'string');
        expect(invalidResult.errors.first.actualType, 'integer');
      });

      test('validates integer type correctly', () {
        final schema = {'type': 'integer'};

        final validResult = SchemaValidator.validate(42, schema);
        expect(validResult.isValid, true);

        final invalidResult = SchemaValidator.validate('42', schema);
        expect(invalidResult.isValid, false);
        expect(invalidResult.errors.first.expectedType, 'integer');
      });

      test('validates boolean type correctly', () {
        final schema = {'type': 'boolean'};

        final validResult = SchemaValidator.validate(true, schema);
        expect(validResult.isValid, true);

        final invalidResult = SchemaValidator.validate('true', schema);
        expect(invalidResult.isValid, false);
      });

      test('validates array type correctly', () {
        final schema = {'type': 'array'};

        final validResult = SchemaValidator.validate([1, 2, 3], schema);
        expect(validResult.isValid, true);

        final invalidResult = SchemaValidator.validate('not an array', schema);
        expect(invalidResult.isValid, false);
      });

      test('validates object type correctly', () {
        final schema = {'type': 'object'};

        final validResult = SchemaValidator.validate({'key': 'value'}, schema);
        expect(validResult.isValid, true);

        final invalidResult = SchemaValidator.validate('not an object', schema);
        expect(invalidResult.isValid, false);
      });

      test('validates null type correctly', () {
        final schema = {'type': 'null'};

        final validResult = SchemaValidator.validate(null, schema);
        expect(validResult.isValid, true);

        final invalidResult = SchemaValidator.validate('not null', schema);
        expect(invalidResult.isValid, false);
      });

      test('validates number type correctly', () {
        final schema = {'type': 'number'};

        final validResult = SchemaValidator.validate(3.14, schema);
        expect(validResult.isValid, true);

        final invalidResult = SchemaValidator.validate('3.14', schema);
        expect(invalidResult.isValid, false);
      });
    });

    group('Required Properties', () {
      test('validates required properties are present', () {
        final schema = {
          'type': 'object',
          'required': ['name', 'age'],
        };

        final validData = {'name': 'John', 'age': 30};
        final result = SchemaValidator.validate(validData, schema);
        expect(result.isValid, true);
      });

      test('detects missing required properties', () {
        final schema = {
          'type': 'object',
          'required': ['name', 'age', 'email'],
        };

        final invalidData = {'name': 'John'};
        final result = SchemaValidator.validate(invalidData, schema);

        expect(result.isValid, false);
        expect(result.errors.length, 2); // Missing 'age' and 'email'
        expect(result.errors.any((e) => e.path.contains('age')), true);
        expect(result.errors.any((e) => e.path.contains('email')), true);
      });
    });

    group('Properties Validation', () {
      test('validates nested object properties', () {
        final schema = {
          'type': 'object',
          'properties': {
            'name': {'type': 'string'},
            'age': {'type': 'integer'},
            'active': {'type': 'boolean'},
          },
        };

        final validData = {'name': 'Alice', 'age': 25, 'active': true};

        final result = SchemaValidator.validate(validData, schema);
        expect(result.isValid, true);
      });

      test('detects type mismatches in properties', () {
        final schema = {
          'type': 'object',
          'properties': {
            'name': {'type': 'string'},
            'age': {'type': 'integer'},
          },
        };

        final invalidData = {
          'name': 'Alice',
          'age': '25', // Should be integer
        };

        final result = SchemaValidator.validate(invalidData, schema);
        expect(result.isValid, false);
        expect(result.errors.length, 1);
        expect(result.errors.first.path, 'age');
      });

      test('validates deeply nested properties', () {
        final schema = {
          'type': 'object',
          'properties': {
            'user': {
              'type': 'object',
              'properties': {
                'profile': {
                  'type': 'object',
                  'properties': {
                    'name': {'type': 'string'},
                  },
                },
              },
            },
          },
        };

        final validData = {
          'user': {
            'profile': {'name': 'Bob'},
          },
        };

        final result = SchemaValidator.validate(validData, schema);
        expect(result.isValid, true);
      });

      test('detects errors in deeply nested properties', () {
        final schema = {
          'type': 'object',
          'properties': {
            'user': {
              'type': 'object',
              'properties': {
                'name': {'type': 'string'},
              },
            },
          },
        };

        final invalidData = {
          'user': {
            'name': 123, // Should be string
          },
        };

        final result = SchemaValidator.validate(invalidData, schema);
        expect(result.isValid, false);
        expect(result.errors.first.path, 'user.name');
      });
    });

    group('Array Items Validation', () {
      test('validates array items with schema', () {
        final schema = {
          'type': 'array',
          'items': {'type': 'string'},
        };

        final validData = ['apple', 'banana', 'cherry'];
        final result = SchemaValidator.validate(validData, schema);
        expect(result.isValid, true);
      });

      test('detects invalid items in array', () {
        final schema = {
          'type': 'array',
          'items': {'type': 'string'},
        };

        final invalidData = ['apple', 123, 'cherry'];
        final result = SchemaValidator.validate(invalidData, schema);

        expect(result.isValid, false);
        expect(result.errors.length, 1);
        expect(result.errors.first.path, '[1]');
      });

      test('validates array of objects', () {
        final schema = {
          'type': 'array',
          'items': {
            'type': 'object',
            'properties': {
              'id': {'type': 'integer'},
              'name': {'type': 'string'},
            },
          },
        };

        final validData = [
          {'id': 1, 'name': 'Item 1'},
          {'id': 2, 'name': 'Item 2'},
        ];

        final result = SchemaValidator.validate(validData, schema);
        expect(result.isValid, true);
      });

      test('detects errors in array of objects', () {
        final schema = {
          'type': 'array',
          'items': {
            'type': 'object',
            'properties': {
              'id': {'type': 'integer'},
            },
          },
        };

        final invalidData = [
          {'id': 1},
          {'id': 'not a number'}, // Invalid
        ];

        final result = SchemaValidator.validate(invalidData, schema);
        expect(result.isValid, false);
        expect(result.errors.first.path, '[1].id');
      });
    });

    group('String Length Validation', () {
      test('validates minLength constraint', () {
        final schema = {'type': 'string', 'minLength': 5};

        final validResult = SchemaValidator.validate('hello', schema);
        expect(validResult.isValid, true);

        final invalidResult = SchemaValidator.validate('hi', schema);
        expect(invalidResult.isValid, false);
        expect(invalidResult.errors.first.message, contains('too short'));
      });

      test('validates maxLength constraint', () {
        final schema = {'type': 'string', 'maxLength': 5};

        final validResult = SchemaValidator.validate('hello', schema);
        expect(validResult.isValid, true);

        final invalidResult = SchemaValidator.validate('hello world', schema);
        expect(invalidResult.isValid, false);
        expect(invalidResult.errors.first.message, contains('too long'));
      });

      test('validates both minLength and maxLength', () {
        final schema = {'type': 'string', 'minLength': 3, 'maxLength': 10};

        final validResult = SchemaValidator.validate('hello', schema);
        expect(validResult.isValid, true);

        final tooShortResult = SchemaValidator.validate('hi', schema);
        expect(tooShortResult.isValid, false);

        final tooLongResult = SchemaValidator.validate(
          'hello world test',
          schema,
        );
        expect(tooLongResult.isValid, false);
      });
    });

    group('Number Range Validation', () {
      test('validates minimum constraint', () {
        final schema = {'type': 'integer', 'minimum': 0};

        final validResult = SchemaValidator.validate(5, schema);
        expect(validResult.isValid, true);

        final invalidResult = SchemaValidator.validate(-5, schema);
        expect(invalidResult.isValid, false);
        expect(invalidResult.errors.first.message, contains('below minimum'));
      });

      test('validates maximum constraint', () {
        final schema = {'type': 'integer', 'maximum': 100};

        final validResult = SchemaValidator.validate(50, schema);
        expect(validResult.isValid, true);

        final invalidResult = SchemaValidator.validate(150, schema);
        expect(invalidResult.isValid, false);
        expect(invalidResult.errors.first.message, contains('above maximum'));
      });

      test('validates both minimum and maximum', () {
        final schema = {'type': 'number', 'minimum': 0, 'maximum': 100};

        final validResult = SchemaValidator.validate(50.5, schema);
        expect(validResult.isValid, true);

        final belowResult = SchemaValidator.validate(-10.0, schema);
        expect(belowResult.isValid, false);

        final aboveResult = SchemaValidator.validate(150.0, schema);
        expect(aboveResult.isValid, false);
      });
    });

    group('Enum Validation', () {
      test('validates enum values', () {
        final schema = {
          'type': 'string',
          'enum': ['red', 'green', 'blue'],
        };

        final validResult = SchemaValidator.validate('red', schema);
        expect(validResult.isValid, true);

        final invalidResult = SchemaValidator.validate('yellow', schema);
        expect(invalidResult.isValid, false);
        expect(invalidResult.errors.first.message, contains('not in enum'));
      });

      test('validates enum with different types', () {
        final schema = {
          'enum': [1, 2, 3, 'four', 'five'],
        };

        final validIntResult = SchemaValidator.validate(1, schema);
        expect(validIntResult.isValid, true);

        final validStringResult = SchemaValidator.validate('four', schema);
        expect(validStringResult.isValid, true);

        final invalidResult = SchemaValidator.validate(10, schema);
        expect(invalidResult.isValid, false);
      });
    });

    group('Schema Generation', () {
      test('generates schema for string', () {
        final schema = SchemaValidator.generateSchema('hello');

        expect(schema['type'], 'string');
        expect(schema['minLength'], 0);
        expect(schema.containsKey('maxLength'), true);
      });

      test('generates schema for integer', () {
        final schema = SchemaValidator.generateSchema(42);
        expect(schema['type'], 'integer');
      });

      test('generates schema for boolean', () {
        final schema = SchemaValidator.generateSchema(true);
        expect(schema['type'], 'boolean');
      });

      test('generates schema for null', () {
        final schema = SchemaValidator.generateSchema(null);
        expect(schema['type'], 'null');
      });

      test('generates schema for number', () {
        final schema = SchemaValidator.generateSchema(3.14);
        expect(schema['type'], 'number');
      });

      test('generates schema for array', () {
        final schema = SchemaValidator.generateSchema([1, 2, 3]);

        expect(schema['type'], 'array');
        expect(schema.containsKey('items'), true);
        expect(schema['items']['type'], 'integer');
      });

      test('generates schema for empty array', () {
        final schema = SchemaValidator.generateSchema([]);

        expect(schema['type'], 'array');
        expect(schema.containsKey('items'), false);
      });

      test('generates schema for object', () {
        final data = {'name': 'John', 'age': 30, 'active': true};

        final schema = SchemaValidator.generateSchema(data);

        expect(schema['type'], 'object');
        expect(schema.containsKey('properties'), true);
        expect(schema.containsKey('required'), true);

        final properties = schema['properties'] as Map;
        expect(properties['name']['type'], 'string');
        expect(properties['age']['type'], 'integer');
        expect(properties['active']['type'], 'boolean');

        final required = schema['required'] as List;
        expect(required, containsAll(['name', 'age', 'active']));
      });

      test('generates schema for nested object', () {
        final data = {
          'user': {
            'name': 'Alice',
            'profile': {'age': 25},
          },
        };

        final schema = SchemaValidator.generateSchema(data);

        expect(schema['type'], 'object');
        final userSchema = (schema['properties'] as Map)['user'] as Map;
        expect(userSchema['type'], 'object');

        final profileSchema =
            (userSchema['properties'] as Map)['profile'] as Map;
        expect(profileSchema['type'], 'object');
      });

      test('generates schema for array of objects', () {
        final data = [
          {'id': 1, 'name': 'Item 1'},
          {'id': 2, 'name': 'Item 2'},
        ];

        final schema = SchemaValidator.generateSchema(data);

        expect(schema['type'], 'array');
        final itemsSchema = schema['items'] as Map;
        expect(itemsSchema['type'], 'object');

        final properties = itemsSchema['properties'] as Map;
        expect(properties['id']['type'], 'integer');
        expect(properties['name']['type'], 'string');
      });
    });

    group('Complex Validation Scenarios', () {
      test('validates complex nested structure', () {
        final schema = {
          'type': 'object',
          'required': ['users'],
          'properties': {
            'users': {
              'type': 'array',
              'items': {
                'type': 'object',
                'required': ['name', 'email'],
                'properties': {
                  'name': {'type': 'string', 'minLength': 2},
                  'email': {'type': 'string', 'minLength': 5},
                  'age': {'type': 'integer', 'minimum': 0, 'maximum': 150},
                },
              },
            },
          },
        };

        final validData = {
          'users': [
            {'name': 'Alice', 'email': 'alice@example.com', 'age': 30},
            {'name': 'Bob', 'email': 'bob@example.com', 'age': 25},
          ],
        };

        final result = SchemaValidator.validate(validData, schema);
        expect(result.isValid, true);
      });

      test('collects multiple errors in complex structure', () {
        final schema = {
          'type': 'object',
          'required': ['name', 'age'],
          'properties': {
            'name': {'type': 'string', 'minLength': 3},
            'age': {'type': 'integer', 'minimum': 0},
          },
        };

        final invalidData = {
          'name': 'AB', // Too short
          'age': -5, // Below minimum
        };

        final result = SchemaValidator.validate(invalidData, schema);
        expect(result.isValid, false);
        expect(result.errors.length, 2);
      });

      test('handles missing optional properties gracefully', () {
        final schema = {
          'type': 'object',
          'required': ['name'],
          'properties': {
            'name': {'type': 'string'},
            'age': {'type': 'integer'}, // Optional
            'email': {'type': 'string'}, // Optional
          },
        };

        final dataWithOnlyRequired = {'name': 'John'};
        final result = SchemaValidator.validate(dataWithOnlyRequired, schema);
        expect(result.isValid, true);
      });
    });

    group('SchemaValidationError', () {
      test('toString returns formatted error message', () {
        const error = SchemaValidationError(
          path: 'user.age',
          message: 'Type mismatch',
          expectedType: 'integer',
          actualType: 'string',
          actualValue: '25',
        );

        final errorString = error.toString();
        expect(errorString, contains('user.age'));
        expect(errorString, contains('Type mismatch'));
        expect(errorString, contains('Expected: integer'));
        expect(errorString, contains('Got: string'));
      });
    });
  });
}
