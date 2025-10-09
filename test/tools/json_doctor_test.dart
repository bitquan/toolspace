import 'package:flutter_test/flutter_test.dart';
import 'package:toolspace/tools/json_doctor/logic/schema_validator.dart';
import 'package:toolspace/tools/json_doctor/logic/jsonpath_query.dart';

void main() {
  group('SchemaValidator Tests', () {
    test('validates correct data type', () {
      final schema = {'type': 'string'};
      final result = SchemaValidator.validate('test', schema);

      expect(result.isValid, true);
      expect(result.errors, isEmpty);
    });

    test('detects type mismatch', () {
      final schema = {'type': 'string'};
      final result = SchemaValidator.validate(123, schema);

      expect(result.isValid, false);
      expect(result.errors, isNotEmpty);
      expect(result.errors.first.expectedType, 'string');
      expect(result.errors.first.actualType, 'integer');
    });

    test('validates required properties', () {
      final schema = {
        'type': 'object',
        'required': ['name', 'age'],
        'properties': {
          'name': {'type': 'string'},
          'age': {'type': 'integer'},
        }
      };

      final validData = {'name': 'John', 'age': 30};
      final result1 = SchemaValidator.validate(validData, schema);
      expect(result1.isValid, true);

      final invalidData = {'name': 'John'};
      final result2 = SchemaValidator.validate(invalidData, schema);
      expect(result2.isValid, false);
      expect(result2.errors.any((e) => e.message.contains('Required')), true);
    });

    test('validates array items', () {
      final schema = {
        'type': 'array',
        'items': {'type': 'integer'}
      };

      final validData = [1, 2, 3];
      final result1 = SchemaValidator.validate(validData, schema);
      expect(result1.isValid, true);

      final invalidData = [1, 'two', 3];
      final result2 = SchemaValidator.validate(invalidData, schema);
      expect(result2.isValid, false);
    });

    test('validates string length constraints', () {
      final schema = {'type': 'string', 'minLength': 3, 'maxLength': 10};

      final result1 = SchemaValidator.validate('test', schema);
      expect(result1.isValid, true);

      final result2 = SchemaValidator.validate('ab', schema);
      expect(result2.isValid, false);
      expect(result2.errors.first.message.contains('too short'), true);

      final result3 = SchemaValidator.validate('verylongstring', schema);
      expect(result3.isValid, false);
      expect(result3.errors.first.message.contains('too long'), true);
    });

    test('validates number constraints', () {
      final schema = {'type': 'integer', 'minimum': 0, 'maximum': 100};

      final result1 = SchemaValidator.validate(50, schema);
      expect(result1.isValid, true);

      final result2 = SchemaValidator.validate(-1, schema);
      expect(result2.isValid, false);

      final result3 = SchemaValidator.validate(101, schema);
      expect(result3.isValid, false);
    });

    test('validates enum values', () {
      final schema = {
        'type': 'string',
        'enum': ['red', 'green', 'blue']
      };

      final result1 = SchemaValidator.validate('red', schema);
      expect(result1.isValid, true);

      final result2 = SchemaValidator.validate('yellow', schema);
      expect(result2.isValid, false);
      expect(result2.errors.first.message.contains('enum'), true);
    });

    test('generates schema from data', () {
      final data = {
        'name': 'John',
        'age': 30,
        'active': true,
        'tags': ['developer', 'designer']
      };

      final schema = SchemaValidator.generateSchema(data);

      expect(schema['type'], 'object');
      expect(schema['properties'], isNotNull);
      expect(schema['properties']['name']['type'], 'string');
      expect(schema['properties']['age']['type'], 'integer');
      expect(schema['properties']['active']['type'], 'boolean');
      expect(schema['properties']['tags']['type'], 'array');
      expect(schema['required'], contains('name'));
    });
  });

  group('JsonPathQuery Tests', () {
    test('queries root element', () {
      final data = {'name': 'test'};
      final result = JsonPathQuery.query(data, r'$');

      expect(result.success, true);
      expect(result.value, equals(data));
    });

    test('queries simple property', () {
      final data = {'name': 'John', 'age': 30};
      final result = JsonPathQuery.query(data, r'$.name');

      expect(result.success, true);
      expect(result.value, 'John');
    });

    test('queries nested property', () {
      final data = {
        'user': {
          'name': 'John',
          'address': {'city': 'New York'}
        }
      };
      final result = JsonPathQuery.query(data, r'$.user.address.city');

      expect(result.success, true);
      expect(result.value, 'New York');
    });

    test('queries array index', () {
      final data = {
        'users': ['Alice', 'Bob', 'Charlie']
      };
      final result = JsonPathQuery.query(data, r'$.users[1]');

      expect(result.success, true);
      expect(result.value, 'Bob');
    });

    test('queries with wildcard in array', () {
      final data = {
        'users': [
          {'name': 'Alice'},
          {'name': 'Bob'}
        ]
      };
      final result = JsonPathQuery.query(data, r'$.users[*].name');

      expect(result.success, true);
      expect(result.matches.length, 2);
      expect(result.matches, containsAll(['Alice', 'Bob']));
    });

    test('queries with wildcard in object', () {
      final data = {
        'user1': {'name': 'Alice'},
        'user2': {'name': 'Bob'}
      };
      final result = JsonPathQuery.query(data, r'$.*. name');

      expect(result.success, true);
      expect(result.matches.length, 2);
    });

    test('handles invalid path gracefully', () {
      final data = {'name': 'test'};
      final result = JsonPathQuery.query(data, r'$.nonexistent');

      expect(result.success, true);
      expect(result.matches, isEmpty);
    });

    test('validates JSONPath syntax', () {
      expect(JsonPathQuery.isValidPath(r'$.name'), true);
      expect(JsonPathQuery.isValidPath(r'$.users[0]'), true);
      expect(JsonPathQuery.isValidPath(r'$.users[*].name'), true);
      expect(JsonPathQuery.isValidPath(''), false);
      expect(JsonPathQuery.isValidPath(r'$.users['), false);
      expect(JsonPathQuery.isValidPath(r'$.users]'), false);
    });

    test('gets all paths in JSON object', () {
      final data = {
        'name': 'John',
        'age': 30,
        'address': {'city': 'NYC', 'zip': '10001'}
      };

      final paths = JsonPathQuery.getAllPaths(data);

      expect(paths, contains(r'$.name'));
      expect(paths, contains(r'$.age'));
      expect(paths, contains(r'$.address'));
      expect(paths, contains(r'$.address.city'));
      expect(paths, contains(r'$.address.zip'));
    });

    test('gets example paths', () {
      final examples = JsonPathQuery.getExamplePaths();

      expect(examples, isNotEmpty);
      expect(examples, contains(r'$'));
      expect(examples, contains(r'$.name'));
      expect(examples.any((p) => p.contains('[*]')), true);
    });
  });
}
