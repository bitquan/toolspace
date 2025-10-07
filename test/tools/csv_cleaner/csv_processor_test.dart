import 'package:flutter_test/flutter_test.dart';
import 'package:toolspace/tools/csv_cleaner/logic/csv_processor.dart';

void main() {
  group('CsvProcessor Tests', () {
    group('parseCsv', () {
      test('parses simple CSV correctly', () {
        const csv = 'Name,Age,City\nJohn,30,NYC\nJane,25,LA';
        final result = CsvProcessor.parseCsv(csv);

        expect(result.length, 3);
        expect(result[0], ['Name', 'Age', 'City']);
        expect(result[1], ['John', '30', 'NYC']);
        expect(result[2], ['Jane', '25', 'LA']);
      });

      test('handles quoted values with commas', () {
        const csv = 'Name,Address\n"John Doe","123 Main St, NYC"';
        final result = CsvProcessor.parseCsv(csv);

        expect(result.length, 2);
        expect(result[1][0], 'John Doe');
        expect(result[1][1], '123 Main St, NYC');
      });

      test('handles escaped quotes', () {
        const csv = 'Name,Quote\n"John","He said ""Hello"""';
        final result = CsvProcessor.parseCsv(csv);

        expect(result.length, 2);
        expect(result[1][1], 'He said "Hello"');
      });

      test('handles empty CSV', () {
        const csv = '';
        final result = CsvProcessor.parseCsv(csv);

        expect(result.length, 0);
      });

      test('skips empty lines', () {
        const csv = 'Name,Age\nJohn,30\n\nJane,25';
        final result = CsvProcessor.parseCsv(csv);

        expect(result.length, 3);
        expect(result[0], ['Name', 'Age']);
        expect(result[1], ['John', '30']);
        expect(result[2], ['Jane', '25']);
      });
    });

    group('toCsv', () {
      test('converts rows to CSV string', () {
        final rows = [
          ['Name', 'Age', 'City'],
          ['John', '30', 'NYC'],
          ['Jane', '25', 'LA'],
        ];
        final result = CsvProcessor.toCsv(rows);

        expect(result, 'Name,Age,City\nJohn,30,NYC\nJane,25,LA');
      });

      test('escapes cells with commas', () {
        final rows = [
          ['Name', 'Address'],
          ['John', '123 Main St, NYC'],
        ];
        final result = CsvProcessor.toCsv(rows);

        expect(result, 'Name,Address\nJohn,"123 Main St, NYC"');
      });

      test('escapes cells with quotes', () {
        final rows = [
          ['Name', 'Quote'],
          ['John', 'He said "Hello"'],
        ];
        final result = CsvProcessor.toCsv(rows);

        expect(result, 'Name,Quote\nJohn,"He said ""Hello"""');
      });

      test('handles empty rows', () {
        final rows = <List<String>>[];
        final result = CsvProcessor.toCsv(rows);

        expect(result, '');
      });
    });

    group('trimWhitespace', () {
      test('trims whitespace from all cells', () {
        final rows = [
          ['  Name  ', ' Age ', 'City  '],
          ['  John  ', ' 30 ', '  NYC'],
        ];
        final result = CsvProcessor.trimWhitespace(rows);

        expect(result[0][0], 'Name');
        expect(result[0][1], 'Age');
        expect(result[0][2], 'City');
        expect(result[1][0], 'John');
        expect(result[1][1], '30');
        expect(result[1][2], 'NYC');
      });

      test('handles empty rows', () {
        final rows = <List<String>>[];
        final result = CsvProcessor.trimWhitespace(rows);

        expect(result.length, 0);
      });
    });

    group('lowercaseHeaders', () {
      test('converts headers to lowercase', () {
        final rows = [
          ['NAME', 'AGE', 'City'],
          ['John', '30', 'NYC'],
        ];
        final result = CsvProcessor.lowercaseHeaders(rows);

        expect(result[0][0], 'name');
        expect(result[0][1], 'age');
        expect(result[0][2], 'city');
        expect(result[1][0], 'John'); // Data rows unchanged
      });

      test('handles empty rows', () {
        final rows = <List<String>>[];
        final result = CsvProcessor.lowercaseHeaders(rows);

        expect(result.length, 0);
      });
    });

    group('removeDuplicates', () {
      test('removes duplicate rows (entire row)', () {
        final rows = [
          ['Name', 'Age'],
          ['John', '30'],
          ['Jane', '25'],
          ['John', '30'], // Duplicate
        ];
        final result = CsvProcessor.removeDuplicates(rows);

        expect(result.length, 3);
        expect(result[0], ['Name', 'Age']);
        expect(result[1], ['John', '30']);
        expect(result[2], ['Jane', '25']);
      });

      test('removes duplicates by key column', () {
        final rows = [
          ['Name', 'Age', 'City'],
          ['John', '30', 'NYC'],
          ['Jane', '25', 'LA'],
          ['John', '31', 'Boston'], // Same name, different age
        ];
        final result = CsvProcessor.removeDuplicates(rows, keyColumnIndex: 0);

        expect(result.length, 3);
        expect(result[0], ['Name', 'Age', 'City']);
        expect(result[1], ['John', '30', 'NYC']);
        expect(result[2], ['Jane', '25', 'LA']);
      });

      test('keeps all rows if no duplicates', () {
        final rows = [
          ['Name', 'Age'],
          ['John', '30'],
          ['Jane', '25'],
        ];
        final result = CsvProcessor.removeDuplicates(rows);

        expect(result.length, 3);
      });

      test('handles empty rows', () {
        final rows = <List<String>>[];
        final result = CsvProcessor.removeDuplicates(rows);

        expect(result.length, 0);
      });
    });

    group('getHeaders', () {
      test('returns first row as headers', () {
        final rows = [
          ['Name', 'Age', 'City'],
          ['John', '30', 'NYC'],
        ];
        final result = CsvProcessor.getHeaders(rows);

        expect(result, ['Name', 'Age', 'City']);
      });

      test('returns empty list for empty rows', () {
        final rows = <List<String>>[];
        final result = CsvProcessor.getHeaders(rows);

        expect(result, []);
      });
    });

    group('validate', () {
      test('validates correct CSV', () {
        final rows = [
          ['Name', 'Age', 'City'],
          ['John', '30', 'NYC'],
          ['Jane', '25', 'LA'],
        ];
        final result = CsvProcessor.validate(rows);

        expect(result.isValid, true);
        expect(result.error, null);
      });

      test('detects empty CSV', () {
        final rows = <List<String>>[];
        final result = CsvProcessor.validate(rows);

        expect(result.isValid, false);
        expect(result.error, 'CSV is empty');
      });

      test('detects inconsistent column count', () {
        final rows = [
          ['Name', 'Age', 'City'],
          ['John', '30'], // Missing column
        ];
        final result = CsvProcessor.validate(rows);

        expect(result.isValid, false);
        expect(result.error, contains('Row 2'));
        expect(result.rowNumber, 2);
      });
    });

    group('cleanAll', () {
      test('applies all operations', () {
        final rows = [
          ['  NAME  ', '  AGE  '],
          ['  John  ', '  30  '],
          ['  Jane  ', '  25  '],
          ['  John  ', '  30  '], // Duplicate
        ];
        final result = CsvProcessor.cleanAll(
          rows,
          trimWhitespace: true,
          lowercaseHeaders: true,
          dedupeKeyColumn: -1, // Dedupe by entire row
        );

        expect(result.length, 3); // Removed 1 duplicate
        expect(result[0][0], 'name'); // Lowercased
        expect(result[1][0], 'John'); // Trimmed
      });

      test('applies selective operations', () {
        final rows = [
          ['  NAME  ', '  AGE  '],
          ['  John  ', '  30  '],
        ];
        final result = CsvProcessor.cleanAll(
          rows,
          trimWhitespace: true,
          lowercaseHeaders: false,
        );

        expect(result[0][0], 'NAME'); // Not lowercased
        expect(result[1][0], 'John'); // Trimmed
      });
    });
  });
}
