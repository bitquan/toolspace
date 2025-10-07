import 'package:flutter_test/flutter_test.dart';
import 'package:toolspace/tools/json_flatten/logic/json_flattener.dart';

void main() {
  group('JsonFlattener Tests', () {
    group('Flatten Simple Object', () {
      test('flattens simple flat object', () {
        const json = '{"name": "Alice", "age": 30}';
        final result = JsonFlattener.flatten(json);

        expect(result.success, true);
        expect(result.rows.length, 1);
        expect(result.rows[0]['name'], 'Alice');
        expect(result.rows[0]['age'], 30);
        expect(result.allKeys, containsAll(['name', 'age']));
      });

      test('flattens nested object with dot notation', () {
        const json = '{"user": {"name": "Alice", "age": 30}}';
        final result = JsonFlattener.flatten(json, notation: NotationStyle.dot);

        expect(result.success, true);
        expect(result.rows.length, 1);
        expect(result.rows[0]['user.name'], 'Alice');
        expect(result.rows[0]['user.age'], 30);
      });

      test('flattens nested object with bracket notation', () {
        const json = '{"user": {"name": "Alice", "age": 30}}';
        final result =
            JsonFlattener.flatten(json, notation: NotationStyle.bracket);

        expect(result.success, true);
        expect(result.rows.length, 1);
        expect(result.rows[0]['user[name]'], 'Alice');
        expect(result.rows[0]['user[age]'], 30);
      });

      test('flattens deeply nested object', () {
        const json =
            '{"user": {"profile": {"address": {"city": "NYC", "zip": "10001"}}}}';
        final result = JsonFlattener.flatten(json);

        expect(result.success, true);
        expect(result.rows[0]['user.profile.address.city'], 'NYC');
        expect(result.rows[0]['user.profile.address.zip'], '10001');
      });

      test('handles null values', () {
        const json = '{"name": "Alice", "email": null}';
        final result = JsonFlattener.flatten(json);

        expect(result.success, true);
        expect(result.rows[0]['name'], 'Alice');
        expect(result.rows[0]['email'], null);
      });
    });

    group('Flatten Arrays', () {
      test('flattens array of objects', () {
        const json = '[{"name": "Alice"}, {"name": "Bob"}]';
        final result = JsonFlattener.flatten(json);

        expect(result.success, true);
        expect(result.rows.length, 2);
        expect(result.rows[0]['name'], 'Alice');
        expect(result.rows[1]['name'], 'Bob');
      });

      test('flattens array of primitive values', () {
        const json = '[1, 2, 3]';
        final result = JsonFlattener.flatten(json);

        expect(result.success, true);
        expect(result.rows.length, 3);
        expect(result.rows[0]['value'], 1);
        expect(result.rows[1]['value'], 2);
        expect(result.rows[2]['value'], 3);
      });

      test('flattens nested arrays with dot notation', () {
        const json = '{"users": [{"name": "Alice"}, {"name": "Bob"}]}';
        final result = JsonFlattener.flatten(json, notation: NotationStyle.dot);

        expect(result.success, true);
        expect(result.rows.length, 1);
        expect(result.rows[0]['users.0.name'], 'Alice');
        expect(result.rows[0]['users.1.name'], 'Bob');
      });

      test('flattens nested arrays with bracket notation', () {
        const json = '{"users": [{"name": "Alice"}, {"name": "Bob"}]}';
        final result =
            JsonFlattener.flatten(json, notation: NotationStyle.bracket);

        expect(result.success, true);
        expect(result.rows.length, 1);
        expect(result.rows[0]['users[0][name]'], 'Alice');
        expect(result.rows[0]['users[1][name]'], 'Bob');
      });

      test('handles empty arrays', () {
        const json = '{"users": []}';
        final result = JsonFlattener.flatten(json);

        expect(result.success, true);
        expect(result.rows[0]['users'], '[]');
      });

      test('handles arrays with mixed types', () {
        const json = '{"data": [1, "text", true, null]}';
        final result = JsonFlattener.flatten(json);

        expect(result.success, true);
        expect(result.rows[0]['data.0'], 1);
        expect(result.rows[0]['data.1'], 'text');
        expect(result.rows[0]['data.2'], true);
        expect(result.rows[0]['data.3'], null);
      });
    });

    group('Complex Structures', () {
      test('flattens complex nested structure', () {
        const json = '''
        {
          "users": [
            {
              "name": "Alice",
              "age": 30,
              "address": {
                "city": "NYC",
                "zip": "10001"
              }
            },
            {
              "name": "Bob",
              "age": 25,
              "address": {
                "city": "LA",
                "zip": "90001"
              }
            }
          ]
        }
        ''';
        final result = JsonFlattener.flatten(json);

        expect(result.success, true);
        expect(result.rows.length, 1);
        expect(result.rows[0]['users.0.name'], 'Alice');
        expect(result.rows[0]['users.0.address.city'], 'NYC');
        expect(result.rows[0]['users.1.name'], 'Bob');
        expect(result.rows[0]['users.1.address.city'], 'LA');
      });

      test('flattens array of complex objects as separate rows', () {
        const json = '''
        [
          {
            "name": "Alice",
            "address": {"city": "NYC"}
          },
          {
            "name": "Bob",
            "address": {"city": "LA"}
          }
        ]
        ''';
        final result = JsonFlattener.flatten(json);

        expect(result.success, true);
        expect(result.rows.length, 2);
        expect(result.rows[0]['name'], 'Alice');
        expect(result.rows[0]['address.city'], 'NYC');
        expect(result.rows[1]['name'], 'Bob');
        expect(result.rows[1]['address.city'], 'LA');
      });

      test('respects max depth limit', () {
        const json = '{"a": {"b": {"c": {"d": {"e": "deep"}}}}}';
        final result = JsonFlattener.flatten(json, maxDepth: 3);

        expect(result.success, true);
        // Should stop flattening at depth 3
        expect(result.rows[0].keys.length, lessThanOrEqualTo(5));
      });
    });

    group('CSV Generation', () {
      test('generates CSV with header', () {
        final rows = [
          {'name': 'Alice', 'age': 30},
          {'name': 'Bob', 'age': 25},
        ];
        final csv = JsonFlattener.toCSV(rows, ['name', 'age']);

        expect(csv, contains('name,age'));
        expect(csv, contains('Alice,30'));
        expect(csv, contains('Bob,25'));
      });

      test('generates CSV without header', () {
        final rows = [
          {'name': 'Alice', 'age': 30},
        ];
        final csv =
            JsonFlattener.toCSV(rows, ['name', 'age'], includeHeader: false);

        expect(csv, isNot(contains('name,age')));
        expect(csv, contains('Alice,30'));
      });

      test('escapes CSV values with commas', () {
        final rows = [
          {'name': 'Alice, Bob', 'city': 'New York'},
        ];
        final csv = JsonFlattener.toCSV(rows, ['name', 'city']);

        expect(csv, contains('"Alice, Bob"'));
      });

      test('escapes CSV values with quotes', () {
        final rows = [
          {'text': 'She said "hello"'},
        ];
        final csv = JsonFlattener.toCSV(rows, ['text']);

        expect(csv, contains('She said ""hello""'));
      });

      test('escapes CSV values with newlines', () {
        final rows = [
          {'text': 'Line 1\nLine 2'},
        ];
        final csv = JsonFlattener.toCSV(rows, ['text']);

        expect(csv, contains('"Line 1\nLine 2"'));
      });

      test('handles null values in CSV', () {
        final rows = [
          {'name': 'Alice', 'email': null},
        ];
        final csv = JsonFlattener.toCSV(rows, ['name', 'email']);

        expect(csv, contains('Alice,'));
      });

      test('handles missing keys in CSV', () {
        final rows = [
          {'name': 'Alice', 'age': 30},
          {'name': 'Bob'}, // missing age
        ];
        final csv = JsonFlattener.toCSV(rows, ['name', 'age']);

        expect(csv, contains('Bob,'));
      });
    });

    group('Statistics', () {
      test('calculates correct statistics', () {
        const json = '''
        [
          {"name": "Alice", "age": 30, "city": "NYC"},
          {"name": "Bob", "age": null, "city": "LA"}
        ]
        ''';
        final result = JsonFlattener.flatten(json);
        final stats = JsonFlattener.getStatistics(result);

        expect(stats['rows'], 2);
        expect(stats['columns'], 3);
        expect(stats['totalCells'], 6);
        expect(stats['nullCells'], 1);
      });

      test('calculates max depth', () {
        const json = '{"a": {"b": {"c": "value"}}}';
        final result = JsonFlattener.flatten(json);
        final stats = JsonFlattener.getStatistics(result);

        expect(stats['maxDepth'], greaterThan(1));
      });
    });

    group('Field Filtering', () {
      test('filters rows to selected keys', () {
        final rows = [
          {'name': 'Alice', 'age': 30, 'city': 'NYC'},
          {'name': 'Bob', 'age': 25, 'city': 'LA'},
        ];
        final filtered = JsonFlattener.filterKeys(rows, ['name', 'city']);

        expect(filtered.length, 2);
        expect(filtered[0].keys, containsAll(['name', 'city']));
        expect(filtered[0].keys, isNot(contains('age')));
        expect(filtered[0]['name'], 'Alice');
        expect(filtered[0]['city'], 'NYC');
      });

      test('handles missing keys when filtering', () {
        final rows = [
          {'name': 'Alice', 'age': 30},
          {'name': 'Bob'}, // missing age
        ];
        final filtered = JsonFlattener.filterKeys(rows, ['name', 'age']);

        expect(filtered.length, 2);
        expect(filtered[0]['age'], 30);
        expect(filtered[1]['age'], null);
      });
    });

    group('Validation', () {
      test('validates valid JSON', () {
        const json = '{"name": "Alice"}';
        final result = JsonFlattener.validateJson(json);

        expect(result.isValid, true);
        expect(result.error, null);
      });

      test('detects invalid JSON', () {
        const json = '{"name": invalid}';
        final result = JsonFlattener.validateJson(json);

        expect(result.isValid, false);
        expect(result.error, isNotNull);
      });

      test('handles empty string', () {
        const json = '';
        final result = JsonFlattener.validateJson(json);

        expect(result.isValid, false);
        expect(result.error, 'JSON string is empty');
      });

      test('handles whitespace-only string', () {
        const json = '   \n  ';
        final result = JsonFlattener.validateJson(json);

        expect(result.isValid, false);
      });
    });

    group('Error Handling', () {
      test('handles empty string gracefully', () {
        const json = '';
        final result = JsonFlattener.flatten(json);

        expect(result.success, false);
        expect(result.error, 'JSON string is empty');
      });

      test('handles invalid JSON gracefully', () {
        const json = '{"invalid": json}';
        final result = JsonFlattener.flatten(json);

        expect(result.success, false);
        expect(result.error, isNotNull);
        expect(result.error, contains('Invalid JSON'));
      });

      test('handles malformed JSON gracefully', () {
        const json = '{unclosed';
        final result = JsonFlattener.flatten(json);

        expect(result.success, false);
        expect(result.error, isNotNull);
      });
    });

    group('Edge Cases', () {
      test('handles single primitive value', () {
        const json = '42';
        final result = JsonFlattener.flatten(json);

        expect(result.success, true);
        expect(result.rows.length, 1);
        expect(result.rows[0]['value'], 42);
      });

      test('handles boolean value', () {
        const json = 'true';
        final result = JsonFlattener.flatten(json);

        expect(result.success, true);
        expect(result.rows[0]['value'], true);
      });

      test('handles string value', () {
        const json = '"hello"';
        final result = JsonFlattener.flatten(json);

        expect(result.success, true);
        expect(result.rows[0]['value'], 'hello');
      });

      test('handles null value', () {
        const json = 'null';
        final result = JsonFlattener.flatten(json);

        expect(result.success, true);
        expect(result.rows[0]['value'], null);
      });

      test('handles empty object', () {
        const json = '{}';
        final result = JsonFlattener.flatten(json);

        expect(result.success, true);
        expect(result.rows.length, 1);
        expect(result.rows[0].isEmpty, true);
      });

      test('handles empty array', () {
        const json = '[]';
        final result = JsonFlattener.flatten(json);

        expect(result.success, true);
        expect(result.rows.length, 0);
      });

      test('handles unicode characters', () {
        const json = '{"name": "Café", "emoji": "😀"}';
        final result = JsonFlattener.flatten(json);

        expect(result.success, true);
        expect(result.rows[0]['name'], 'Café');
        expect(result.rows[0]['emoji'], '😀');
      });

      test('handles large numbers', () {
        const json = '{"big": 9007199254740991}';
        final result = JsonFlattener.flatten(json);

        expect(result.success, true);
        expect(result.rows[0]['big'], 9007199254740991);
      });
    });
  });
}
