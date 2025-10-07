import 'package:flutter_test/flutter_test.dart';
import 'package:toolspace/tools/json_doctor/logic/jsonpath_query.dart';

void main() {
  group('JsonPathQuery Tests', () {
    group('Basic Path Queries', () {
      test('queries root element', () {
        final data = {'name': 'John', 'age': 30};

        final result = JsonPathQuery.query(data, r'$');
        expect(result.success, true);
        expect(result.value, equals(data));
        expect(result.matches.length, 1);
      });

      test('queries root with empty path', () {
        final data = {'name': 'John'};

        final result = JsonPathQuery.query(data, '');
        expect(result.success, true);
        expect(result.value, equals(data));
      });

      test('queries simple property', () {
        final data = {'name': 'Alice', 'age': 25};

        final result = JsonPathQuery.query(data, r'$.name');
        expect(result.success, true);
        expect(result.value, 'Alice');
        expect(result.matches.length, 1);
      });

      test('queries property without leading dollar', () {
        final data = {'name': 'Bob', 'age': 30};

        final result = JsonPathQuery.query(data, '.name');
        expect(result.success, true);
        expect(result.value, 'Bob');
      });

      test('queries nested property', () {
        final data = {
          'user': {'name': 'Charlie', 'email': 'charlie@example.com'},
        };

        final result = JsonPathQuery.query(data, r'$.user.name');
        expect(result.success, true);
        expect(result.value, 'Charlie');
      });

      test('queries deeply nested property', () {
        final data = {
          'company': {
            'department': {
              'team': {'lead': 'Diana'},
            },
          },
        };

        final result = JsonPathQuery.query(
          data,
          r'$.company.department.team.lead',
        );
        expect(result.success, true);
        expect(result.value, 'Diana');
      });

      test('returns empty list for non-existent property', () {
        final data = {'name': 'Eve'};

        final result = JsonPathQuery.query(data, r'$.nonexistent');
        expect(result.success, true);
        expect(result.matches, isEmpty);
      });
    });

    group('Array Queries', () {
      test('queries array element by index', () {
        final data = {
          'items': ['apple', 'banana', 'cherry'],
        };

        final result = JsonPathQuery.query(data, r'$.items[0]');
        expect(result.success, true);
        expect(result.value, 'apple');
      });

      test('queries array element by different index', () {
        final data = {
          'items': [10, 20, 30, 40],
        };

        final result = JsonPathQuery.query(data, r'$.items[2]');
        expect(result.success, true);
        expect(result.value, 30);
      });

      test('returns empty for out-of-bounds array index', () {
        final data = {
          'items': ['a', 'b', 'c'],
        };

        final result = JsonPathQuery.query(data, r'$.items[10]');
        expect(result.success, true);
        expect(result.matches, isEmpty);
      });

      test('returns empty for negative array index', () {
        final data = {
          'items': ['x', 'y', 'z'],
        };

        final result = JsonPathQuery.query(data, r'$.items[-1]');
        expect(result.success, true);
        expect(result.matches, isEmpty);
      });

      test('queries property from array element', () {
        final data = {
          'users': [
            {'name': 'Alice', 'age': 30},
            {'name': 'Bob', 'age': 25},
          ],
        };

        final result = JsonPathQuery.query(data, r'$.users[0].name');
        expect(result.success, true);
        expect(result.value, 'Alice');
      });

      test('queries nested property in array element', () {
        final data = {
          'companies': [
            {
              'name': 'TechCorp',
              'address': {'city': 'Seattle', 'zip': '98101'},
            },
          ],
        };

        final result = JsonPathQuery.query(
          data,
          r'$.companies[0].address.city',
        );
        expect(result.success, true);
        expect(result.value, 'Seattle');
      });
    });

    group('Wildcard Queries', () {
      test('queries all properties in object', () {
        final data = {
          'user1': {'name': 'Alice'},
          'user2': {'name': 'Bob'},
          'user3': {'name': 'Charlie'},
        };

        final result = JsonPathQuery.query(data, r'$.*');
        expect(result.success, true);
        expect(result.matches.length, 3);
      });

      test('queries all array elements', () {
        final data = {
          'items': [1, 2, 3, 4, 5],
        };

        final result = JsonPathQuery.query(data, r'$.items[*]');
        expect(result.success, true);
        expect(result.matches.length, 5);
        expect(result.value, equals([1, 2, 3, 4, 5]));
      });

      test('queries property from all array elements', () {
        final data = {
          'users': [
            {'name': 'Alice', 'age': 30},
            {'name': 'Bob', 'age': 25},
            {'name': 'Charlie', 'age': 35},
          ],
        };

        final result = JsonPathQuery.query(data, r'$.users[*].name');
        expect(result.success, true);
        expect(result.matches.length, 3);
        expect(result.value, equals(['Alice', 'Bob', 'Charlie']));
      });

      test('queries nested property from all array elements', () {
        final data = {
          'companies': [
            {
              'name': 'TechCorp',
              'location': {'city': 'Seattle'},
            },
            {
              'name': 'DataInc',
              'location': {'city': 'Portland'},
            },
          ],
        };

        final result = JsonPathQuery.query(
          data,
          r'$.companies[*].location.city',
        );
        expect(result.success, true);
        expect(result.matches, equals(['Seattle', 'Portland']));
      });

      test('wildcard on non-collection returns empty', () {
        final data = {'name': 'Alice'};

        final result = JsonPathQuery.query(data, r'$.name[*]');
        expect(result.success, true);
        expect(result.matches, isEmpty);
      });
    });

    group('Complex Path Scenarios', () {
      test('handles mixed array indices and property access', () {
        final data = {
          'departments': [
            {
              'name': 'Engineering',
              'employees': [
                {'name': 'Alice', 'role': 'Engineer'},
                {'name': 'Bob', 'role': 'Manager'},
              ],
            },
            {
              'name': 'Sales',
              'employees': [
                {'name': 'Charlie', 'role': 'Sales Rep'},
              ],
            },
          ],
        };

        final result = JsonPathQuery.query(
          data,
          r'$.departments[0].employees[1].name',
        );
        expect(result.success, true);
        expect(result.value, 'Bob');
      });

      test('queries with wildcard in middle of path', () {
        final data = {
          'teams': [
            {
              'members': [
                {'name': 'Alice'},
              ],
            },
            {
              'members': [
                {'name': 'Bob'},
              ],
            },
            {
              'members': [
                {'name': 'Charlie'},
              ],
            },
          ],
        };

        final result = JsonPathQuery.query(data, r'$.teams[*].members[0].name');
        expect(result.success, true);
        expect(result.matches, equals(['Alice', 'Bob', 'Charlie']));
      });

      test('handles path with multiple wildcards', () {
        final data = {
          'groups': [
            {
              'users': [
                {'id': 1},
                {'id': 2},
              ],
            },
            {
              'users': [
                {'id': 3},
                {'id': 4},
              ],
            },
          ],
        };

        final result = JsonPathQuery.query(data, r'$.groups[*].users[*].id');
        expect(result.success, true);
        expect(result.matches, equals([1, 2, 3, 4]));
      });
    });

    group('Edge Cases', () {
      test('handles empty object', () {
        final data = {};

        final result = JsonPathQuery.query(data, r'$.anything');
        expect(result.success, true);
        expect(result.matches, isEmpty);
      });

      test('handles empty array', () {
        final data = {'items': []};

        final result = JsonPathQuery.query(data, r'$.items[0]');
        expect(result.success, true);
        expect(result.matches, isEmpty);
      });

      test('handles null values', () {
        final data = {'value': null};

        final result = JsonPathQuery.query(data, r'$.value');
        expect(result.success, true);
        expect(result.value, null);
      });

      test('handles numeric keys in map', () {
        final data = {
          'data': {'1': 'first', '2': 'second'},
        };

        final result = JsonPathQuery.query(data, r'$.data.1');
        expect(result.success, true);
        expect(result.value, 'first');
      });

      test('handles quoted strings', () {
        final data = {
          'user': {'first-name': 'Alice'},
        };

        // Should work with the property name directly
        final result = JsonPathQuery.query(data, r'$.user.first-name');
        expect(result.success, true);
      });

      test('handles special characters in property names', () {
        final data = {'user@email': 'test@example.com'};

        final result = JsonPathQuery.query(data, r'$.user@email');
        expect(result.success, true);
        expect(result.value, 'test@example.com');
      });

      test('handles boolean values', () {
        final data = {'active': true, 'verified': false};

        final result1 = JsonPathQuery.query(data, r'$.active');
        expect(result1.success, true);
        expect(result1.value, true);

        final result2 = JsonPathQuery.query(data, r'$.verified');
        expect(result2.success, true);
        expect(result2.value, false);
      });

      test('handles numeric values', () {
        final data = {'count': 42, 'price': 99.99};

        final result1 = JsonPathQuery.query(data, r'$.count');
        expect(result1.success, true);
        expect(result1.value, 42);

        final result2 = JsonPathQuery.query(data, r'$.price');
        expect(result2.success, true);
        expect(result2.value, 99.99);
      });

      test('handles top-level array', () {
        final data = [1, 2, 3, 4, 5];

        final result = JsonPathQuery.query(data, r'$[2]');
        expect(result.success, true);
        expect(result.value, 3);
      });
    });

    group('getAllPaths', () {
      test('gets all paths in simple object', () {
        final data = {'name': 'Alice', 'age': 30};

        final paths = JsonPathQuery.getAllPaths(data);
        expect(paths, contains(r'$.name'));
        expect(paths, contains(r'$.age'));
      });

      test('gets all paths in nested object', () {
        final data = {
          'user': {
            'name': 'Bob',
            'profile': {'age': 25},
          },
        };

        final paths = JsonPathQuery.getAllPaths(data);
        expect(paths, contains(r'$.user'));
        expect(paths, contains(r'$.user.name'));
        expect(paths, contains(r'$.user.profile'));
        expect(paths, contains(r'$.user.profile.age'));
      });

      test('gets all paths in array', () {
        final data = {
          'items': ['a', 'b', 'c'],
        };

        final paths = JsonPathQuery.getAllPaths(data);
        expect(paths, contains(r'$.items'));
        expect(paths, contains(r'$.items[0]'));
        expect(paths, contains(r'$.items[1]'));
        expect(paths, contains(r'$.items[2]'));
      });

      test('gets all paths in array of objects', () {
        final data = {
          'users': [
            {'name': 'Alice'},
            {'name': 'Bob'},
          ],
        };

        final paths = JsonPathQuery.getAllPaths(data);
        expect(paths, contains(r'$.users'));
        expect(paths, contains(r'$.users[0]'));
        expect(paths, contains(r'$.users[0].name'));
        expect(paths, contains(r'$.users[1]'));
        expect(paths, contains(r'$.users[1].name'));
      });

      test('returns empty list for primitive values', () {
        final paths = JsonPathQuery.getAllPaths('simple string');
        expect(paths, isEmpty);
      });
    });

    group('isValidPath', () {
      test('validates simple paths', () {
        expect(JsonPathQuery.isValidPath(r'$.name'), true);
        expect(JsonPathQuery.isValidPath(r'$.user.name'), true);
      });

      test('validates paths with array indices', () {
        expect(JsonPathQuery.isValidPath(r'$.items[0]'), true);
        expect(JsonPathQuery.isValidPath(r'$.users[5].name'), true);
      });

      test('validates paths with wildcards', () {
        expect(JsonPathQuery.isValidPath(r'$.items[*]'), true);
        expect(JsonPathQuery.isValidPath(r'$.*'), true);
      });

      test('rejects empty path', () {
        expect(JsonPathQuery.isValidPath(''), false);
      });

      test('rejects paths with unbalanced brackets', () {
        expect(JsonPathQuery.isValidPath(r'$.items[0'), false);
        expect(JsonPathQuery.isValidPath(r'$.items0]'), false);
        expect(JsonPathQuery.isValidPath(r'$.items[[0]]'), false);
      });

      test('validates nested brackets', () {
        expect(JsonPathQuery.isValidPath(r'$.data[0][1]'), true);
      });
    });

    group('getExamplePaths', () {
      test('returns list of example paths', () {
        final examples = JsonPathQuery.getExamplePaths();

        expect(examples, isNotEmpty);
        expect(examples, contains(r'$'));
        expect(examples, contains(r'$.name'));
        expect(examples, contains(r'$.users[0]'));
        expect(examples, contains(r'$.users[*]'));
        expect(examples, contains(r'$.users[*].name'));
      });

      test('all example paths are valid', () {
        final examples = JsonPathQuery.getExamplePaths();

        for (final example in examples) {
          // Note: Some examples like recursive descent are marked as not implemented
          // We only validate the basic syntax
          if (!example.contains('..') && !example.contains(':')) {
            expect(
              JsonPathQuery.isValidPath(example),
              true,
              reason: 'Path $example should be valid',
            );
          }
        }
      });
    });

    group('Error Handling', () {
      test('handles malformed path gracefully', () {
        final data = {'name': 'Test'};

        // This should still work or return appropriate result
        final result = JsonPathQuery.query(data, r'$...name');
        expect(result.success, true);
      });

      test('handles path on non-object data', () {
        const data = 'simple string';

        final result = JsonPathQuery.query(data, r'$.property');
        expect(result.success, true);
        expect(result.matches, isEmpty);
      });

      test('handles path on numeric data', () {
        const data = 42;

        final result = JsonPathQuery.query(data, r'$.property');
        expect(result.success, true);
        expect(result.matches, isEmpty);
      });
    });

    group('JsonPathResult', () {
      test('result contains correct fields', () {
        const result = JsonPathResult(
          success: true,
          value: 'test',
          matches: ['test'],
        );

        expect(result.success, true);
        expect(result.value, 'test');
        expect(result.matches, ['test']);
        expect(result.error, null);
      });

      test('result can contain error', () {
        const result = JsonPathResult(
          success: false,
          error: 'Something went wrong',
        );

        expect(result.success, false);
        expect(result.error, 'Something went wrong');
      });
    });
  });
}
