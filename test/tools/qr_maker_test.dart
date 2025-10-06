import 'package:flutter_test/flutter_test.dart';
import 'package:toolspace/tools/qr_maker/logic/batch_generator.dart';

void main() {
  group('QrBatchGenerator Tests', () {
    test('generateBatch creates QR codes from list', () {
      final dataList = ['Hello', 'World', 'Test'];
      final result = QrBatchGenerator.generateBatch(dataList);

      expect(result.success, true);
      expect(result.totalGenerated, 3);
      expect(result.qrCodes.length, 3);
      expect(result.error, isNull);
    });

    test('generateBatch handles empty list', () {
      final result = QrBatchGenerator.generateBatch([]);

      expect(result.success, false);
      expect(result.totalGenerated, 0);
      expect(result.error, isNotNull);
    });

    test('generateBatch skips empty strings', () {
      final dataList = ['Hello', '', 'World', '  ', 'Test'];
      final result = QrBatchGenerator.generateBatch(dataList);

      expect(result.success, true);
      expect(result.totalGenerated, 3);
      expect(result.qrCodes.every((qr) => qr.data.isNotEmpty), true);
    });

    test('generateBatch includes metadata', () {
      final dataList = ['Hello', 'World'];
      final metadata = {'source': 'test', 'batch': 1};
      final result = QrBatchGenerator.generateBatch(
        dataList,
        commonMetadata: metadata,
      );

      expect(result.success, true);
      expect(result.qrCodes.first.metadata, equals(metadata));
    });

    test('generateBatch sets correct type', () {
      final dataList = ['https://example.com'];
      final result = QrBatchGenerator.generateBatch(
        dataList,
        type: 'url',
      );

      expect(result.success, true);
      expect(result.qrCodes.first.type, 'url');
    });
  });

  group('CSV Generation Tests', () {
    test('generateFromCsv parses simple CSV', () {
      final csvContent = 'Name,Email\nJohn,john@example.com\nJane,jane@example.com';
      final result = QrBatchGenerator.generateFromCsv(csvContent);

      expect(result.success, true);
      expect(result.totalGenerated, 2);
      expect(result.qrCodes.first.data, 'John');
      expect(result.qrCodes.last.data, 'Jane');
    });

    test('generateFromCsv handles specified column', () {
      final csvContent = 'Name,Email\nJohn,john@example.com\nJane,jane@example.com';
      final result = QrBatchGenerator.generateFromCsv(
        csvContent,
        dataColumnIndex: 1,
      );

      expect(result.success, true);
      expect(result.qrCodes.first.data, 'john@example.com');
      expect(result.qrCodes.last.data, 'jane@example.com');
    });

    test('generateFromCsv handles no header', () {
      final csvContent = 'John,john@example.com\nJane,jane@example.com';
      final result = QrBatchGenerator.generateFromCsv(
        csvContent,
        hasHeader: false,
      );

      expect(result.success, true);
      expect(result.totalGenerated, 2);
    });

    test('generateFromCsv handles empty lines', () {
      final csvContent = 'Name\nJohn\n\nJane\n\n';
      final result = QrBatchGenerator.generateFromCsv(csvContent);

      expect(result.success, true);
      expect(result.totalGenerated, 2);
    });

    test('generateFromCsv handles quoted fields', () {
      final csvContent = 'Name,Data\n"John Doe","test,data"\n"Jane Smith","more,data"';
      final result = QrBatchGenerator.generateFromCsv(csvContent);

      expect(result.success, true);
      expect(result.totalGenerated, 2);
    });
  });

  group('Sequential Generation Tests', () {
    test('generateSequential creates numbered sequence', () {
      final result = QrBatchGenerator.generateSequential(
        prefix: 'TICKET-',
        count: 5,
      );

      expect(result.success, true);
      expect(result.totalGenerated, 5);
      expect(result.qrCodes.first.data, 'TICKET-1');
      expect(result.qrCodes.last.data, 'TICKET-5');
    });

    test('generateSequential respects start number', () {
      final result = QrBatchGenerator.generateSequential(
        prefix: 'ID-',
        count: 3,
        startNumber: 100,
      );

      expect(result.success, true);
      expect(result.qrCodes.first.data, 'ID-100');
      expect(result.qrCodes.last.data, 'ID-102');
    });

    test('generateSequential includes suffix', () {
      final result = QrBatchGenerator.generateSequential(
        prefix: 'ITEM-',
        count: 2,
        suffix: '-END',
      );

      expect(result.success, true);
      expect(result.qrCodes.first.data, 'ITEM-1-END');
      expect(result.qrCodes.last.data, 'ITEM-2-END');
    });

    test('generateSequential rejects zero count', () {
      final result = QrBatchGenerator.generateSequential(
        prefix: 'TEST-',
        count: 0,
      );

      expect(result.success, false);
      expect(result.error, isNotNull);
    });

    test('generateSequential rejects excessive count', () {
      final result = QrBatchGenerator.generateSequential(
        prefix: 'TEST-',
        count: 1001,
      );

      expect(result.success, false);
      expect(result.error, contains('Maximum'));
    });
  });

  group('Template Generation Tests', () {
    test('generateFromTemplate replaces variables', () {
      final template = 'Hello {{name}}, your code is {{code}}';
      final variables = {
        'name': ['John', 'Jane'],
        'code': ['ABC', 'XYZ'],
      };
      final result = QrBatchGenerator.generateFromTemplate(
        template: template,
        variables: variables,
      );

      expect(result.success, true);
      expect(result.totalGenerated, 2);
      expect(result.qrCodes.first.data, 'Hello John, your code is ABC');
      expect(result.qrCodes.last.data, 'Hello Jane, your code is XYZ');
    });

    test('generateFromTemplate handles single variable', () {
      final template = 'User: {{username}}';
      final variables = {
        'username': ['alice', 'bob', 'charlie'],
      };
      final result = QrBatchGenerator.generateFromTemplate(
        template: template,
        variables: variables,
      );

      expect(result.success, true);
      expect(result.totalGenerated, 3);
      expect(result.qrCodes.map((qr) => qr.data).toList(), [
        'User: alice',
        'User: bob',
        'User: charlie',
      ]);
    });

    test('generateFromTemplate rejects empty template', () {
      final template = 'No variables here';
      final variables = {'name': ['test']};
      final result = QrBatchGenerator.generateFromTemplate(
        template: template,
        variables: variables,
      );

      expect(result.success, false);
      expect(result.error, contains('No variables'));
    });

    test('generateFromTemplate rejects missing variable', () {
      final template = 'Hello {{name}}';
      final variables = {'other': ['test']};
      final result = QrBatchGenerator.generateFromTemplate(
        template: template,
        variables: variables,
      );

      expect(result.success, false);
      expect(result.error, contains('not provided'));
    });
  });

  group('Export and Stats Tests', () {
    test('exportToJson creates valid JSON', () {
      final dataList = ['Hello', 'World'];
      final result = QrBatchGenerator.generateBatch(dataList);
      final json = QrBatchGenerator.exportToJson(result);

      expect(json, contains('"success": true'));
      expect(json, contains('"totalGenerated": 2'));
      expect(json, contains('"qrCodes": ['));
    });

    test('exportToJson handles errors', () {
      final result = QrBatchResult(
        success: false,
        qrCodes: [],
        error: 'Test error',
        totalGenerated: 0,
      );
      final json = QrBatchGenerator.exportToJson(result);

      expect(json, contains('"success": false'));
      expect(json, contains('Test error'));
    });

    test('exportToJson escapes special characters', () {
      final dataList = ['Test "quoted" string\nwith newline'];
      final result = QrBatchGenerator.generateBatch(dataList);
      final json = QrBatchGenerator.exportToJson(result);

      expect(json, contains('\\"'));
      expect(json, contains('\\n'));
    });

    test('getBatchStats provides statistics', () {
      final dataList = ['Hello', 'World', 'Test'];
      final result = QrBatchGenerator.generateBatch(dataList);
      final stats = QrBatchGenerator.getBatchStats(result);

      expect(stats['success'], true);
      expect(stats['totalGenerated'], 3);
      expect(stats['typeBreakdown'], isNotNull);
      expect(stats['avgDataLength'], isA<num>());
    });

    test('getBatchStats handles errors', () {
      final result = QrBatchResult(
        success: false,
        qrCodes: [],
        error: 'Test error',
        totalGenerated: 0,
      );
      final stats = QrBatchGenerator.getBatchStats(result);

      expect(stats['success'], false);
      expect(stats['error'], 'Test error');
    });

    test('getBatchStats calculates type breakdown', () {
      final result1 = QrBatchGenerator.generateBatch(['A', 'B'], type: 'text');
      final result2 = QrBatchGenerator.generateBatch(['C'], type: 'url');

      final combinedResult = QrBatchResult(
        success: true,
        qrCodes: [...result1.qrCodes, ...result2.qrCodes],
        totalGenerated: 3,
      );

      final stats = QrBatchGenerator.getBatchStats(combinedResult);
      final breakdown = stats['typeBreakdown'] as Map<String, int>;

      expect(breakdown['text'], 2);
      expect(breakdown['url'], 1);
    });
  });

  group('QrCodeData Tests', () {
    test('toJson serializes correctly', () {
      final qrCode = QrCodeData(
        id: 'test123',
        data: 'Hello World',
        type: 'text',
        metadata: {'key': 'value'},
      );
      final json = qrCode.toJson();

      expect(json['id'], 'test123');
      expect(json['data'], 'Hello World');
      expect(json['type'], 'text');
      expect(json['metadata'], {'key': 'value'});
    });

    test('toJson handles null metadata', () {
      final qrCode = QrCodeData(
        id: 'test123',
        data: 'Hello',
        type: 'text',
      );
      final json = qrCode.toJson();

      expect(json['metadata'], isNull);
    });
  });

  group('Edge Cases', () {
    test('handles very long data strings', () {
      final longString = 'A' * 10000;
      final result = QrBatchGenerator.generateBatch([longString]);

      expect(result.success, true);
      expect(result.qrCodes.first.data.length, 10000);
    });

    test('handles special characters in data', () {
      final dataList = ['!@#\$%^&*()', '©®™', '🎉🎊'];
      final result = QrBatchGenerator.generateBatch(dataList);

      expect(result.success, true);
      expect(result.totalGenerated, 3);
    });

    test('handles unicode characters', () {
      final dataList = ['Hello 世界', 'مرحبا', 'Привет'];
      final result = QrBatchGenerator.generateBatch(dataList);

      expect(result.success, true);
      expect(result.totalGenerated, 3);
    });
  });
}
