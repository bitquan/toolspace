import 'package:flutter_test/flutter_test.dart';
import 'package:toolspace/shared/cross_tool/share_bus.dart';
import 'package:toolspace/shared/cross_tool/share_envelope.dart';

void main() {
  group('ShareBus', () {
    late ShareBus shareBus;

    setUp(() {
      shareBus = ShareBus.instance;
      shareBus.clear(); // Clear any existing data
    });

    tearDown(() {
      shareBus.clear();
    });

    group('Basic Operations', () {
      test('should start with empty data', () {
        expect(shareBus.count, equals(0));
        expect(shareBus.getAll(), isEmpty);
      });

      test('should publish and retrieve text data', () {
        const testData = 'Hello, World!';
        const sourceTool = 'text-tools';
        
        final envelope = ShareEnvelope(
          kind: ShareKind.text,
          value: testData,
          meta: {'sourceTool': sourceTool},
        );
        
        shareBus.publish(envelope);
        
        expect(shareBus.has(ShareKind.text), isTrue);
        expect(shareBus.count, equals(1));
        
        final retrieved = shareBus.getLatest(ShareKind.text);
        expect(retrieved, isNotNull);
        expect(retrieved!.kind, equals(ShareKind.text));
        expect(retrieved.value, equals(testData));
        expect(retrieved.meta['sourceTool'], equals(sourceTool));
      });

      test('should publish and retrieve JSON data', () {
        const testData = {'key': 'value', 'number': 42};
        const sourceTool = 'json-doctor';
        
        final envelope = ShareEnvelope(
          kind: ShareKind.json,
          value: testData,
          meta: {'sourceTool': sourceTool},
        );
        
        shareBus.publish(envelope);
        
        expect(shareBus.has(ShareKind.json), isTrue);
        final retrieved = shareBus.getLatest(ShareKind.json);
        expect(retrieved, isNotNull);
        expect(retrieved!.value, equals(testData));
      });

      test('should publish and retrieve CSV data', () {
        const testData = [
          ['Name', 'Age'],
          ['John', '30'],
          ['Jane', '25']
        ];
        const sourceTool = 'csv-cleaner';
        
        final envelope = ShareEnvelope(
          kind: ShareKind.csv,
          value: testData,
          meta: {'sourceTool': sourceTool},
        );
        
        shareBus.publish(envelope);
        
        expect(shareBus.has(ShareKind.csv), isTrue);
        final retrieved = shareBus.getLatest(ShareKind.csv);
        expect(retrieved, isNotNull);
        expect(retrieved!.value, equals(testData));
      });

      test('should handle multiple data types simultaneously', () {
        final textEnvelope = ShareEnvelope(
          kind: ShareKind.text,
          value: 'Text data',
          meta: {'sourceTool': 'tool1'},
        );
        
        final jsonEnvelope = ShareEnvelope(
          kind: ShareKind.json,
          value: {'key': 'value'},
          meta: {'sourceTool': 'tool2'},
        );
        
        final csvEnvelope = ShareEnvelope(
          kind: ShareKind.csv,
          value: [['col1', 'col2']],
          meta: {'sourceTool': 'tool3'},
        );
        
        shareBus.publish(textEnvelope);
        shareBus.publish(jsonEnvelope);
        shareBus.publish(csvEnvelope);
        
        expect(shareBus.count, equals(3));
        expect(shareBus.has(ShareKind.text), isTrue);
        expect(shareBus.has(ShareKind.json), isTrue);
        expect(shareBus.has(ShareKind.csv), isTrue);
      });
    });

    group('Get By Kind Operations', () {
      test('should retrieve all envelopes of specific kind', () {
        final envelope1 = ShareEnvelope(
          kind: ShareKind.text,
          value: 'First text',
          meta: {'sourceTool': 'tool1'},
        );
        
        final envelope2 = ShareEnvelope(
          kind: ShareKind.text,
          value: 'Second text',
          meta: {'sourceTool': 'tool2'},
        );
        
        shareBus.publish(envelope1);
        shareBus.publish(envelope2);
        
        final textEnvelopes = shareBus.getByKind(ShareKind.text);
        expect(textEnvelopes, hasLength(2));
        expect(textEnvelopes[0].value, equals('First text'));
        expect(textEnvelopes[1].value, equals('Second text'));
      });

      test('should get latest envelope of specific kind', () {
        final envelope1 = ShareEnvelope(
          kind: ShareKind.text,
          value: 'First',
          meta: {'sourceTool': 'tool1'},
        );
        
        final envelope2 = ShareEnvelope(
          kind: ShareKind.text,
          value: 'Latest',
          meta: {'sourceTool': 'tool2'},
        );
        
        shareBus.publish(envelope1);
        shareBus.publish(envelope2);
        
        final latest = shareBus.getLatest(ShareKind.text);
        expect(latest, isNotNull);
        expect(latest!.value, equals('Latest'));
        expect(latest.meta['sourceTool'], equals('tool2'));
      });
    });

    group('Consume Operations', () {
      test('should consume and remove envelope', () {
        final envelope = ShareEnvelope(
          kind: ShareKind.text,
          value: 'Test data',
          meta: {'sourceTool': 'test-tool'},
        );
        
        shareBus.publish(envelope);
        expect(shareBus.count, equals(1));
        
        final consumed = shareBus.consume(ShareKind.text);
        expect(consumed, isNotNull);
        expect(consumed!.value, equals('Test data'));
        expect(shareBus.count, equals(0));
        expect(shareBus.has(ShareKind.text), isFalse);
      });

      test('should consume specific envelope', () {
        final envelope1 = ShareEnvelope(
          kind: ShareKind.text,
          value: 'First',
          meta: {'sourceTool': 'tool1'},
        );
        
        final envelope2 = ShareEnvelope(
          kind: ShareKind.text,
          value: 'Second',
          meta: {'sourceTool': 'tool2'},
        );
        
        shareBus.publish(envelope1);
        shareBus.publish(envelope2);
        expect(shareBus.count, equals(2));
        
        final removed = shareBus.consumeEnvelope(envelope1);
        expect(removed, isTrue);
        expect(shareBus.count, equals(1));
        
        final remaining = shareBus.getAll();
        expect(remaining, hasLength(1));
        expect(remaining.first.value, equals('Second'));
      });

      test('should return null when consuming non-existent kind', () {
        final consumed = shareBus.consume(ShareKind.json);
        expect(consumed, isNull);
      });
    });

    group('Clear and Cleanup', () {
      test('should clear all envelopes', () {
        final envelope1 = ShareEnvelope(
          kind: ShareKind.text,
          value: 'Text',
          meta: {'sourceTool': 'tool1'},
        );
        
        final envelope2 = ShareEnvelope(
          kind: ShareKind.json,
          value: {'key': 'value'},
          meta: {'sourceTool': 'tool2'},
        );
        
        shareBus.publish(envelope1);
        shareBus.publish(envelope2);
        expect(shareBus.count, equals(2));
        
        shareBus.clear();
        expect(shareBus.count, equals(0));
        expect(shareBus.getAll(), isEmpty);
      });

      test('should handle TTL cleanup', () {
        // Create an envelope with test data
        // Note: We can't easily test TTL in unit tests without time manipulation
        // This test verifies the structure works
        final envelope = ShareEnvelope(
          kind: ShareKind.text,
          value: 'Test data',
          meta: {'sourceTool': 'tool'},
        );
        
        shareBus.publish(envelope);
        
        // TTL cleanup happens automatically in getAll(), getByKind(), etc.
        final allEnvelopes = shareBus.getAll();
        
        // Envelope should still be there (not expired in test time)
        expect(allEnvelopes, hasLength(1));
        expect(allEnvelopes.first.value, equals('Test data'));
      });
    });

    group('Notifications', () {
      test('should notify listeners on publish', () {
        bool notified = false;
        
        shareBus.addListener(() {
          notified = true;
        });
        
        final envelope = ShareEnvelope(
          kind: ShareKind.text,
          value: 'Test data',
          meta: {'sourceTool': 'tool'},
        );
        
        shareBus.publish(envelope);
        
        expect(notified, isTrue);
      });

      test('should notify listeners on consume', () {
        int notifications = 0;
        
        shareBus.addListener(() {
          notifications++;
        });
        
        final envelope = ShareEnvelope(
          kind: ShareKind.text,
          value: 'Test data',
          meta: {'sourceTool': 'tool'},
        );
        
        shareBus.publish(envelope); // First notification
        shareBus.consume(ShareKind.text); // Second notification
        
        expect(notifications, equals(2));
      });

      test('should notify listeners on clear', () {
        int notifications = 0;
        
        shareBus.addListener(() {
          notifications++;
        });
        
        final envelope = ShareEnvelope(
          kind: ShareKind.text,
          value: 'Test data',
          meta: {'sourceTool': 'tool'},
        );
        
        shareBus.publish(envelope); // First notification
        shareBus.clear(); // Second notification
        
        expect(notifications, equals(2));
      });
    });
  });

  group('ShareEnvelope', () {
    test('should create envelope with all properties', () {
      const kind = ShareKind.json;
      const value = {'test': 'data'};
      const sourceTool = 'test-tool';
      
      final envelope = ShareEnvelope(
        kind: kind,
        value: value,
        meta: {'sourceTool': sourceTool},
      );
      
      expect(envelope.kind, equals(kind));
      expect(envelope.value, equals(value));
      expect(envelope.meta['sourceTool'], equals(sourceTool));
      expect(envelope.timestamp, isNotNull);
    });

    test('should support different data types', () {
      final textEnvelope = ShareEnvelope(
        kind: ShareKind.text,
        value: 'String data',
        meta: {'sourceTool': 'tool1'},
      );
      
      final jsonEnvelope = ShareEnvelope(
        kind: ShareKind.json,
        value: {'key': 'value'},
        meta: {'sourceTool': 'tool2'},
      );
      
      final csvEnvelope = ShareEnvelope(
        kind: ShareKind.csv,
        value: [['a', 'b'], ['1', '2']],
        meta: {'sourceTool': 'tool3'},
      );
      
      expect(textEnvelope.value, isA<String>());
      expect(jsonEnvelope.value, isA<Map>());
      expect(csvEnvelope.value, isA<List>());
    });

    test('should handle null values', () {
      final envelope = ShareEnvelope(
        kind: ShareKind.text,
        value: null,
        meta: {'sourceTool': 'tool'},
      );
      
      expect(envelope.value, isNull);
      expect(envelope.kind, equals(ShareKind.text));
    });

    test('should handle empty meta', () {
      final envelope = ShareEnvelope(
        kind: ShareKind.text,
        value: 'Test data',
      );
      
      expect(envelope.meta, isNotNull);
      expect(envelope.meta, isEmpty);
    });
  });
}