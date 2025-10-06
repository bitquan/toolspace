import 'package:flutter_test/flutter_test.dart';
import '../../lib/tools/qr_maker/logic/batch_generator.dart';

void main() {
  group('BatchQrGenerator - CSV Parsing', () {
    test('parseCsv handles simple content correctly', () {
      const csv = 'https://example.com,example\nhttps://github.com,github';
      final items = BatchQrGenerator.parseCsv(csv);

      expect(items.length, 2);
      expect(items[0].content, 'https://example.com');
      expect(items[0].filename, 'example');
      expect(items[1].content, 'https://github.com');
      expect(items[1].filename, 'github');
    });

    test('parseCsv handles content with quotes', () {
      const csv = '"Hello, World",hello\n"Test content, with comma",test';
      final items = BatchQrGenerator.parseCsv(csv);

      expect(items.length, 2);
      expect(items[0].content, 'Hello, World');
      expect(items[0].filename, 'hello');
    });

    test('parseCsv skips empty lines', () {
      const csv = 'https://example.com,example\n\nhttps://github.com,github';
      final items = BatchQrGenerator.parseCsv(csv);

      expect(items.length, 2);
    });

    test('parseCsv handles header row', () {
      const csv =
          'content,filename\nhttps://example.com,example\nhttps://github.com,github';
      final items = BatchQrGenerator.parseCsv(csv);

      expect(items.length, 2);
      expect(items[0].content, 'https://example.com');
    });

    test('parseCsv handles content without filename', () {
      const csv = 'https://example.com\nhttps://github.com';
      final items = BatchQrGenerator.parseCsv(csv);

      expect(items.length, 2);
      expect(items[0].content, 'https://example.com');
      expect(items[0].filename, isNull);
    });
  });

  group('BatchQrGenerator - JSON Parsing', () {
    test('parseJson handles array of objects', () {
      const json =
          '[{"content":"https://example.com","filename":"example"},{"content":"https://github.com","filename":"github"}]';
      final items = BatchQrGenerator.parseJson(json);

      expect(items.length, 2);
      expect(items[0].content, 'https://example.com');
      expect(items[0].filename, 'example');
      expect(items[1].content, 'https://github.com');
      expect(items[1].filename, 'github');
    });

    test('parseJson handles array of strings', () {
      const json = '["https://example.com","https://github.com"]';
      final items = BatchQrGenerator.parseJson(json);

      expect(items.length, 2);
      expect(items[0].content, 'https://example.com');
      expect(items[1].content, 'https://github.com');
    });

    test('parseJson handles single object', () {
      const json = '{"content":"https://example.com","filename":"example"}';
      final items = BatchQrGenerator.parseJson(json);

      expect(items.length, 1);
      expect(items[0].content, 'https://example.com');
      expect(items[0].filename, 'example');
    });

    test('parseJson handles wrapped items', () {
      const json =
          '{"items":[{"content":"https://example.com"},{"content":"https://github.com"}]}';
      final items = BatchQrGenerator.parseJson(json);

      expect(items.length, 2);
      expect(items[0].content, 'https://example.com');
      expect(items[1].content, 'https://github.com');
    });

    test('parseJson returns empty list for invalid JSON', () {
      const json = 'not valid json';
      final items = BatchQrGenerator.parseJson(json);

      expect(items, isEmpty);
    });
  });

  group('BatchQrGenerator - Validation', () {
    test('validateItems detects empty content', () {
      final items = [
        const QrBatchItem(content: ''),
        const QrBatchItem(content: 'valid'),
      ];

      final errors = BatchQrGenerator.validateItems(items);

      expect(errors.length, 1);
      expect(errors[0].errorMessage, contains('empty'));
    });

    test('validateItems detects content too long', () {
      final longContent = 'a' * 4001;
      final items = [
        QrBatchItem(content: longContent),
      ];

      final errors = BatchQrGenerator.validateItems(items);

      expect(errors.length, 1);
      expect(errors[0].errorMessage, contains('maximum length'));
    });

    test('validateItems passes valid items', () {
      final items = [
        const QrBatchItem(content: 'https://example.com'),
        const QrBatchItem(content: 'Hello World'),
      ];

      final errors = BatchQrGenerator.validateItems(items);

      expect(errors, isEmpty);
    });
  });

  group('BatchQrGenerator - Batch Generation', () {
    test('generateBatch processes valid items', () async {
      final items = [
        const QrBatchItem(content: 'https://example.com', filename: 'example'),
        const QrBatchItem(content: 'https://github.com', filename: 'github'),
      ];

      const config = BatchConfig();

      final result = await BatchQrGenerator.generateBatch(items, config);

      expect(result.successful.length, 2);
      expect(result.errors, isEmpty);
      expect(result.successRate, 1.0);
    });

    test('generateBatch filters out invalid items', () async {
      final items = [
        const QrBatchItem(content: ''), // Invalid: empty
        const QrBatchItem(content: 'valid'),
      ];

      const config = BatchConfig();

      final result = await BatchQrGenerator.generateBatch(items, config);

      expect(result.successful.length, 1);
      expect(result.errors.length, 1);
      expect(result.successRate, 0.5);
    });

    test('generateBatch calculates processing time', () async {
      final items = [
        const QrBatchItem(content: 'test1'),
        const QrBatchItem(content: 'test2'),
      ];

      const config = BatchConfig();

      final result = await BatchQrGenerator.generateBatch(items, config);

      expect(result.processingTime.inMilliseconds, greaterThan(0));
    });
  });

  group('QrBatchItem - JSON Serialization', () {
    test('fromJson creates item correctly', () {
      final json = {
        'content': 'https://example.com',
        'filename': 'example',
        'metadata': {'key': 'value'}
      };

      final item = QrBatchItem.fromJson(json);

      expect(item.content, 'https://example.com');
      expect(item.filename, 'example');
      expect(item.metadata, isNotNull);
    });

    test('toJson serializes item correctly', () {
      const item = QrBatchItem(
        content: 'https://example.com',
        filename: 'example',
        metadata: {'key': 'value'},
      );

      final json = item.toJson();

      expect(json['content'], 'https://example.com');
      expect(json['filename'], 'example');
      expect(json['metadata'], isNotNull);
    });
  });

  group('BatchResult - Statistics', () {
    test('totalProcessed calculates correctly', () {
      const result = BatchResult(
        successful: [
          QrBatchItem(content: 'test1'),
          QrBatchItem(content: 'test2')
        ],
        errors: [
          BatchError(
              item: QrBatchItem(content: 'test3'), errorMessage: 'error')
        ],
        processingTime: Duration(milliseconds: 100),
      );

      expect(result.totalProcessed, 3);
    });

    test('successRate calculates correctly', () {
      const result = BatchResult(
        successful: [
          QrBatchItem(content: 'test1'),
          QrBatchItem(content: 'test2')
        ],
        errors: [
          BatchError(
              item: QrBatchItem(content: 'test3'), errorMessage: 'error')
        ],
        processingTime: Duration(milliseconds: 100),
      );

      expect(result.successRate, closeTo(0.666, 0.01));
    });

    test('successRate handles zero processed', () {
      const result = BatchResult(
        successful: [],
        errors: [],
        processingTime: Duration(milliseconds: 100),
      );

      expect(result.successRate, 0.0);
    });
  });
}
