import 'package:flutter_test/flutter_test.dart';
import 'package:toolspace/core/services/tool_integration_service.dart';

void main() {
  late ToolIntegrationService service;

  setUp(() {
    service = ToolIntegrationService();
    service.clearAll(); // Clear any existing data before each test
  });

  group('ToolIntegrationService', () {
    test('should store and retrieve data', () {
      // Arrange
      const key = 'test_key';
      const value = 'test_value';

      // Act
      service.shareData(key, value);
      final retrieved = service.getData<String>(key);

      // Assert
      expect(retrieved, equals(value));
    });

    test('should return null for non-existent key', () {
      // Act
      final retrieved = service.getData<String>('non_existent');

      // Assert
      expect(retrieved, isNull);
    });

    test('should handle different data types', () {
      // Arrange & Act
      service.shareData('string', 'text');
      service.shareData('int', 42);
      service.shareData('list', [1, 2, 3]);
      service.shareData('map', {'key': 'value'});

      // Assert
      expect(service.getData<String>('string'), equals('text'));
      expect(service.getData<int>('int'), equals(42));
      expect(service.getData<List>('list'), equals([1, 2, 3]));
      expect(service.getData<Map>('map'), equals({'key': 'value'}));
    });

    test('should clear specific data', () {
      // Arrange
      service.shareData('key1', 'value1');
      service.shareData('key2', 'value2');

      // Act
      service.clearData('key1');

      // Assert
      expect(service.hasData('key1'), isFalse);
      expect(service.hasData('key2'), isTrue);
    });

    test('should clear all data', () {
      // Arrange
      service.shareData('key1', 'value1');
      service.shareData('key2', 'value2');
      service.shareData('key3', 'value3');

      // Act
      service.clearAll();

      // Assert
      expect(service.availableKeys, isEmpty);
    });

    test('should check if data exists', () {
      // Arrange
      service.shareData('existing', 'value');

      // Assert
      expect(service.hasData('existing'), isTrue);
      expect(service.hasData('non_existing'), isFalse);
    });

    test('should list available keys', () {
      // Arrange
      service.shareData('key1', 'value1');
      service.shareData('key2', 'value2');
      service.shareData('key3', 'value3');

      // Act
      final keys = service.availableKeys;

      // Assert
      expect(keys, hasLength(3));
      expect(keys, containsAll(['key1', 'key2', 'key3']));
    });

    test('should return same instance (singleton)', () {
      // Act
      final instance1 = ToolIntegrationService();
      final instance2 = ToolIntegrationService();

      // Assert
      expect(identical(instance1, instance2), isTrue);
    });

    test('should maintain data across instances', () {
      // Arrange
      final instance1 = ToolIntegrationService();
      instance1.shareData('shared', 'data');

      // Act
      final instance2 = ToolIntegrationService();
      final retrieved = instance2.getData<String>('shared');

      // Assert
      expect(retrieved, equals('data'));
    });

    test('should notify listeners when data changes', () {
      // Arrange
      var notificationCount = 0;
      service.addListener(() => notificationCount++);

      // Act
      service.shareData('key', 'value');
      service.clearData('key');
      service.clearAll();

      // Assert
      expect(notificationCount, equals(3));
    });
  });
}
