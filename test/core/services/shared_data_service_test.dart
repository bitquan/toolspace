import 'package:flutter_test/flutter_test.dart';
import '../../../lib/core/services/shared_data_service.dart';

void main() {
  group('SharedDataService Tests', () {
    late SharedDataService service;

    setUp(() {
      service = SharedDataService.instance;
      service.clearData();
      service.clearHistory();
    });

    test('singleton returns same instance', () {
      final instance1 = SharedDataService.instance;
      final instance2 = SharedDataService();
      expect(instance1, same(instance2));
    });

    test('initially has no data', () {
      expect(service.hasData, false);
      expect(service.currentData, isNull);
      expect(service.history, isEmpty);
    });

    test('shareData sets current data', () {
      final data = SharedData(
        type: SharedDataType.text,
        data: 'Hello World',
        label: 'Test',
        sourceTool: 'text_tools',
      );

      service.shareData(data);

      expect(service.hasData, true);
      expect(service.currentData, isNotNull);
      expect(service.currentData?.data, 'Hello World');
      expect(service.currentData?.type, SharedDataType.text);
      expect(service.currentData?.sourceTool, 'text_tools');
    });

    test('shareData adds to history', () {
      final data1 = SharedData(
        type: SharedDataType.text,
        data: 'First',
        sourceTool: 'tool1',
      );
      final data2 = SharedData(
        type: SharedDataType.json,
        data: '{"key": "value"}',
        sourceTool: 'tool2',
      );

      service.shareData(data1);
      service.shareData(data2);

      expect(service.history.length, 2);
      expect(service.history[0].data, '{"key": "value"}'); // Most recent first
      expect(service.history[1].data, 'First');
    });

    test('clearData removes current data but keeps history', () {
      final data = SharedData(
        type: SharedDataType.text,
        data: 'Test',
        sourceTool: 'tool',
      );

      service.shareData(data);
      expect(service.hasData, true);
      expect(service.history.length, 1);

      service.clearData();

      expect(service.hasData, false);
      expect(service.currentData, isNull);
      expect(service.history.length, 1); // History preserved
    });

    test('consumeData returns and clears current data', () {
      final data = SharedData(
        type: SharedDataType.text,
        data: 'Consume me',
        sourceTool: 'tool',
      );

      service.shareData(data);
      final consumed = service.consumeData();

      expect(consumed, isNotNull);
      expect(consumed?.data, 'Consume me');
      expect(service.hasData, false);
      expect(service.currentData, isNull);
    });

    test('history is limited to max size', () {
      // Add more than max history size
      for (int i = 0; i < 15; i++) {
        service.shareData(SharedData(
          type: SharedDataType.text,
          data: 'Item $i',
          sourceTool: 'tool',
        ));
      }

      expect(service.history.length, 10); // Max size
      expect(service.history[0].data, 'Item 14'); // Most recent
      expect(service.history[9].data, 'Item 5'); // Oldest kept
    });

    test('getHistoryByType filters correctly', () {
      service.shareData(SharedData(
        type: SharedDataType.text,
        data: 'Text 1',
        sourceTool: 'tool',
      ));
      service.shareData(SharedData(
        type: SharedDataType.json,
        data: '{}',
        sourceTool: 'tool',
      ));
      service.shareData(SharedData(
        type: SharedDataType.text,
        data: 'Text 2',
        sourceTool: 'tool',
      ));

      final textHistory = service.getHistoryByType(SharedDataType.text);
      final jsonHistory = service.getHistoryByType(SharedDataType.json);

      expect(textHistory.length, 2);
      expect(jsonHistory.length, 1);
      expect(textHistory[0].data, 'Text 2');
      expect(textHistory[1].data, 'Text 1');
    });

    test('clearHistory removes all history but keeps current data', () {
      final data = SharedData(
        type: SharedDataType.text,
        data: 'Current',
        sourceTool: 'tool',
      );

      service.shareData(data);
      expect(service.history.length, 1);
      expect(service.hasData, true);

      service.clearHistory();

      expect(service.history, isEmpty);
      expect(service.hasData, true); // Current data still there
      expect(service.currentData?.data, 'Current');
    });

    test('SharedData has correct timestamp', () {
      final before = DateTime.now();
      final data = SharedData(
        type: SharedDataType.text,
        data: 'Test',
        sourceTool: 'tool',
      );
      final after = DateTime.now();

      expect(
        data.timestamp.isAfter(before.subtract(const Duration(seconds: 1))),
        true,
      );
      expect(data.timestamp.isBefore(after.add(const Duration(seconds: 1))),
          true);
    });

    test('SharedData toString includes key information', () {
      final data = SharedData(
        type: SharedDataType.json,
        data: '{}',
        label: 'My Data',
        sourceTool: 'json_tool',
      );

      final str = data.toString();
      expect(str, contains('json'));
      expect(str, contains('My Data'));
      expect(str, contains('json_tool'));
    });

    test('service notifies listeners on shareData', () {
      var notified = false;
      service.addListener(() {
        notified = true;
      });

      service.shareData(SharedData(
        type: SharedDataType.text,
        data: 'Test',
        sourceTool: 'tool',
      ));

      expect(notified, true);
    });

    test('service notifies listeners on clearData', () {
      service.shareData(SharedData(
        type: SharedDataType.text,
        data: 'Test',
        sourceTool: 'tool',
      ));

      var notified = false;
      service.addListener(() {
        notified = true;
      });

      service.clearData();
      expect(notified, true);
    });

    test('all SharedDataType values are accessible', () {
      expect(SharedDataType.values.length, 5);
      expect(SharedDataType.values.contains(SharedDataType.text), true);
      expect(SharedDataType.values.contains(SharedDataType.json), true);
      expect(SharedDataType.values.contains(SharedDataType.url), true);
      expect(SharedDataType.values.contains(SharedDataType.qrCode), true);
      expect(SharedDataType.values.contains(SharedDataType.file), true);
    });
  });
}
