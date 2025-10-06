import 'package:flutter_test/flutter_test.dart';
import 'package:toolspace/tools/json_doctor/logic/jsonpath_query.dart';
import 'package:toolspace/tools/json_doctor/logic/schema_validator.dart';

void main() {
  group('JsonPathQuery Tests', () {
    test('query root returns entire data', () {
      final data = {'name': 'test', 'value': 123};
      final result = JsonPathQuery.query(data, r'$');
      
      expect(result.success, true);
      expect(result.value, equals(data));
      expect(result.matches.length, 1);
    });

    test('query property returns property value', () {
      final data = {'name': 'test', 'value': 123};
      final result = JsonPathQuery.query(data, r'$.name');
      
      expect(result.success, true);
      expect(result.value, 'test');
    });

    test('query nested property', () {
      final data = {
        'user': {'name': 'John', 'age': 30}
      };
      final result = JsonPathQuery.query(data, r'$.user.name');
      
      expect(result.success, true);
      expect(result.value, 'John');
    });

    test('query array index', () {
      final data = {
        'users': [
          {'name': 'Alice'},
          {'name': 'Bob'},
        ]
      };
      final result = JsonPathQuery.query(data, r'$.users[0]');
      
      expect(result.success, true);
      expect(result.value, {'name': 'Alice'});
    });

    test('query array index property', () {
      final data = {
        'users': [
          {'name': 'Alice'},
          {'name': 'Bob'},
        ]
      };
      final result = JsonPathQuery.query(data, r'$.users[1].name');
      
      expect(result.success, true);
      expect(result.value, 'Bob');
    });

    test('query wildcard returns all values', () {
      final data = {
        'users': [
          {'name': 'Alice'},
          {'name': 'Bob'},
          {'name': 'Charlie'},
        ]
      };
      final result = JsonPathQuery.query(data, r'$.users[*].name');
      
      expect(result.success, true);
      expect(result.matches, ['Alice', 'Bob', 'Charlie']);
    });

    test('query invalid path returns error', () {
      final data = {'name': 'test'};
      final result = JsonPathQuery.query(data, r'$.invalid.path');
      
      expect(result.success, true);
      expect(result.matches, isEmpty);
    });

    test('getAllPaths returns all paths in object', () {
      final data = {
        'user': {
          'name': 'John',
          'age': 30,
        },
        'items': [1, 2, 3]
      };
      final paths = JsonPathQuery.getAllPaths(data);
      
      expect(paths, contains(r'$.user'));
      expect(paths, contains(r'$.user.name'));
      expect(paths, contains(r'$.user.age'));
      expect(paths, contains(r'$.items'));
    });

    test('isValidPath validates JSONPath syntax', () {
      expect(JsonPathQuery.isValidPath(r'$'), true);
      expect(JsonPathQuery.isValidPath(r'$.name'), true);
      expect(JsonPathQuery.isValidPath(r'$.users[0]'), true);
      expect(JsonPathQuery.isValidPath(r'$.users[*]'), true);
      expect(JsonPathQuery.isValidPath(''), false);
      expect(JsonPathQuery.isValidPath(r'$.invalid['), false);
    });
  });

  group('SchemaValidator Tests', () {
    test('validate type mismatch', () {
      final data = 'string value';
      final schema = {'type': 'number'};
      final result = SchemaValidator.validate(data, schema);
      
      expect(result.isValid, false);
      expect(result.errors.length, 1);
      expect(result.errors.first.expectedType, 'number');
      expect(result.errors.first.actualType, 'string');
    });

    test('validate correct type', () {
      final data = 123;
      final schema = {'type': 'integer'};
      final result = SchemaValidator.validate(data, schema);
      
      expect(result.isValid, true);
      expect(result.errors, isEmpty);
    });

    test('validate required properties', () {
      final data = {'name': 'test'};
      final schema = {
        'type': 'object',
        'required': ['name', 'age']
      };
      final result = SchemaValidator.validate(data, schema);
      
      expect(result.isValid, false);
      expect(result.errors.length, 1);
      expect(result.errors.first.message, 'Required property missing');
    });

    test('validate object properties', () {
      final data = {'name': 'test', 'age': 'invalid'};
      final schema = {
        'type': 'object',
        'properties': {
          'name': {'type': 'string'},
          'age': {'type': 'integer'},
        }
      };
      final result = SchemaValidator.validate(data, schema);
      
      expect(result.isValid, false);
      expect(result.errors.length, 1);
      expect(result.errors.first.path, 'age');
    });

    test('validate array items', () {
      final data = [1, 2, 'invalid'];
      final schema = {
        'type': 'array',
        'items': {'type': 'integer'}
      };
      final result = SchemaValidator.validate(data, schema);
      
      expect(result.isValid, false);
      expect(result.errors.length, 1);
      expect(result.errors.first.path, '[2]');
    });

    test('validate string length constraints', () {
      final data = 'short';
      final schema = {
        'type': 'string',
        'minLength': 10,
      };
      final result = SchemaValidator.validate(data, schema);
      
      expect(result.isValid, false);
      expect(result.errors.first.message, 'String too short');
    });

    test('validate number range constraints', () {
      final data = 150;
      final schema = {
        'type': 'integer',
        'minimum': 0,
        'maximum': 100,
      };
      final result = SchemaValidator.validate(data, schema);
      
      expect(result.isValid, false);
      expect(result.errors.first.message, 'Number above maximum');
    });

    test('validate enum values', () {
      final data = 'invalid';
      final schema = {
        'type': 'string',
        'enum': ['red', 'green', 'blue']
      };
      final result = SchemaValidator.validate(data, schema);
      
      expect(result.isValid, false);
      expect(result.errors.first.message, 'Value not in enum');
    });

    test('generateSchema creates schema from data', () {
      final data = {
        'name': 'test',
        'age': 30,
        'active': true,
        'tags': ['tag1', 'tag2'],
      };
      final schema = SchemaValidator.generateSchema(data);
      
      expect(schema['type'], 'object');
      expect(schema['properties'], isNotNull);
      expect(schema['required'], isNotNull);
      expect((schema['properties'] as Map)['name']['type'], 'string');
      expect((schema['properties'] as Map)['age']['type'], 'integer');
      expect((schema['properties'] as Map)['active']['type'], 'boolean');
      expect((schema['properties'] as Map)['tags']['type'], 'array');
    });

    test('validate complex nested structure', () {
      final data = {
        'user': {
          'name': 'John',
          'email': 'john@example.com',
          'roles': ['admin', 'user']
        },
        'settings': {
          'theme': 'dark',
          'notifications': true
        }
      };
      final schema = {
        'type': 'object',
        'required': ['user', 'settings'],
        'properties': {
          'user': {
            'type': 'object',
            'required': ['name', 'email'],
            'properties': {
              'name': {'type': 'string'},
              'email': {'type': 'string'},
              'roles': {
                'type': 'array',
                'items': {'type': 'string'}
              }
            }
          },
          'settings': {
            'type': 'object',
            'properties': {
              'theme': {'type': 'string'},
              'notifications': {'type': 'boolean'}
            }
          }
        }
      };
      final result = SchemaValidator.validate(data, schema);
      
      expect(result.isValid, true);
      expect(result.errors, isEmpty);
    });
  });
}
