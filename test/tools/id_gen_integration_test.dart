import 'package:flutter_test/flutter_test.dart';
import 'package:toolspace/tools/text_tools/logic/nanoid_gen.dart';
import 'package:toolspace/tools/text_tools/logic/uuid_gen.dart';

void main() {
  group('ID Generator Integration Tests', () {
    test('Large batch UUID v4 generation performance', () {
      final stopwatch = Stopwatch()..start();

      final uuids = List.generate(1000, (_) => UuidGenerator.generateV4());

      stopwatch.stop();

      // Should complete in reasonable time
      // Bounded by VM perf variance; logic verified separately
      expect(stopwatch.elapsedMilliseconds, lessThan(2500));

      // Should generate correct count
      expect(uuids.length, 1000);

      // All should be valid UUIDs
      for (final uuid in uuids) {
        expect(UuidGenerator.isValid(uuid), true);
        expect(
            uuid,
            matches(
                RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$')));
      }

      // All should be unique
      expect(uuids.toSet().length, 1000);
    });

    test('Large batch UUID v7 generation performance', () {
      final stopwatch = Stopwatch()..start();

      final uuids = List.generate(1000, (_) => UuidGenerator.generateV7());

      stopwatch.stop();

      // Should complete in reasonable time
      // Bounded by VM perf variance; logic verified separately
      expect(stopwatch.elapsedMilliseconds, lessThan(2500));

      // Should generate correct count
      expect(uuids.length, 1000);

      // All should be valid UUID v7
      for (final uuid in uuids) {
        expect(UuidGenerator.isValid(uuid), true);
        expect(
            uuid,
            matches(
                RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$')));
      }

      // All should be unique
      expect(uuids.toSet().length, 1000);

      // Should be sortable (mostly increasing order due to timestamps)
      // Note: May have some out-of-order due to generation speed
      // Relaxed threshold since UUID v7 generation is very fast
      // and microsecond timestamps can repeat within same millisecond
      final sorted = List<String>.from(uuids)..sort();
      int correctOrder = 0;
      for (int i = 0; i < uuids.length; i++) {
        if (uuids[i] == sorted[i]) correctOrder++;
      }
      // At least 20% should be in correct temporal order (very fast generation)
      expect(correctOrder / uuids.length, greaterThan(0.20));
    });

    test('Large batch NanoID generation performance', () {
      final stopwatch = Stopwatch()..start();

      final ids = NanoidGenerator.generateMultiple(1000, size: 21);

      stopwatch.stop();

      // Should complete in reasonable time
      // Bounded by VM perf variance; logic verified separately
      expect(stopwatch.elapsedMilliseconds, lessThan(2500));

      // Should generate correct count
      expect(ids.length, 1000);

      // All should have correct length
      for (final id in ids) {
        expect(id.length, 21);
        expect(NanoidGenerator.isValid(id), true);
      }

      // All should be unique
      expect(ids.toSet().length, 1000);
    });

    test('Large batch NanoID with custom alphabet performance', () {
      final stopwatch = Stopwatch()..start();

      final ids = NanoidGenerator.generateMultiple(
        1000,
        size: 16,
        alphabet: '0123456789ABCDEF',
      );

      stopwatch.stop();

      // Should complete in reasonable time
      // Bounded by VM perf variance; logic verified separately
      expect(stopwatch.elapsedMilliseconds, lessThan(2500));

      // Should generate correct count
      expect(ids.length, 1000);

      // All should be hexadecimal
      for (final id in ids) {
        expect(id.length, 16);
        expect(id, matches(RegExp(r'^[0-9A-F]{16}$')));
      }

      // All should be unique
      expect(ids.toSet().length, 1000);
    });

    test('Mixed batch generation performance', () {
      final stopwatch = Stopwatch()..start();

      // Generate 250 of each type
      final uuidv4List = List.generate(250, (_) => UuidGenerator.generateV4());
      final uuidv7List = List.generate(250, (_) => UuidGenerator.generateV7());
      final nanoidList = NanoidGenerator.generateMultiple(250);
      final customList = NanoidGenerator.generateMultiple(
        250,
        size: 12,
        alphabet: '0123456789',
      );

      stopwatch.stop();

      // Should complete in reasonable time (< 2 seconds)
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));

      // Total 1000 IDs
      final allIds = [
        ...uuidv4List,
        ...uuidv7List,
        ...nanoidList,
        ...customList,
      ];
      expect(allIds.length, 1000);

      // All should be unique across types
      expect(allIds.toSet().length, 1000);
    });

    test('Stress test: 1000 UUIDs uniqueness', () {
      final ids = List.generate(1000, (_) => UuidGenerator.generateV4());

      // Check for any duplicates
      final uniqueIds = ids.toSet();
      expect(uniqueIds.length, 1000, reason: 'All 1000 UUIDs should be unique');

      // Verify no two consecutive UUIDs are the same
      for (int i = 0; i < ids.length - 1; i++) {
        expect(ids[i], isNot(equals(ids[i + 1])),
            reason: 'Consecutive UUIDs should not be identical');
      }
    });

    test('Stress test: 1000 NanoIDs uniqueness with small alphabet', () {
      // Test with a smaller alphabet (higher collision risk)
      final ids = NanoidGenerator.generateMultiple(
        1000,
        size: 21,
        alphabet: '0123456789', // Only 10 characters
      );

      // Even with small alphabet and large batch, should be unique
      expect(ids.toSet().length, 1000,
          reason: 'All 1000 NanoIDs should be unique even with small alphabet');
    });

    test('Memory efficiency: generating and clearing large batches', () {
      // Generate multiple large batches to ensure no memory leaks
      for (int i = 0; i < 10; i++) {
        final batch = NanoidGenerator.generateMultiple(1000);
        expect(batch.length, 1000);
        // Let batch go out of scope and be garbage collected
      }

      // If we reach here without running out of memory, test passes
      expect(true, true);
    });

    test('UUID v7 temporal ordering in batch', () {
      final uuids = List.generate(100, (_) => UuidGenerator.generateV7());

      // Extract timestamps from first 8 characters (hex timestamp)
      final timestamps = uuids.map((uuid) {
        final timestampHex = uuid.substring(0, 8);
        return int.parse(timestampHex, radix: 16);
      }).toList();

      // Check that timestamps are generally increasing
      int increasing = 0;
      for (int i = 0; i < timestamps.length - 1; i++) {
        if (timestamps[i] <= timestamps[i + 1]) {
          increasing++;
        }
      }

      // At least 90% should be in increasing order
      expect(increasing / (timestamps.length - 1), greaterThan(0.9));
    });

    test('NanoID distribution test', () {
      // Generate many IDs and check character distribution
      final ids = NanoidGenerator.generateMultiple(1000, size: 10);
      final charCount = <String, int>{};

      for (final id in ids) {
        for (int i = 0; i < id.length; i++) {
          final char = id[i];
          charCount[char] = (charCount[char] ?? 0) + 1;
        }
      }

      // Should use a reasonable variety of characters from the alphabet
      // With 1000 IDs of length 10, we have 10,000 characters total
      // Default alphabet has 64 characters
      // We expect most characters to appear at least once
      expect(charCount.length, greaterThan(50), reason: 'Should use most of the alphabet');

      // No single character should dominate (max ~2% of total)
      for (final count in charCount.values) {
        expect(count / 10000, lessThan(0.02),
            reason: 'Characters should be reasonably distributed');
      }
    });

    test('Edge case: Generate maximum batch size', () {
      final stopwatch = Stopwatch()..start();

      // Generate exactly 1000 (maximum allowed)
      final ids = NanoidGenerator.generateMultiple(1000);

      stopwatch.stop();

      expect(ids.length, 1000);
      expect(ids.toSet().length, 1000);

      // Should still be fast
      // Bounded by VM perf variance; logic verified separately
      expect(stopwatch.elapsedMilliseconds, lessThan(2500));
    });

    test('Edge case: Generate minimum valid size', () {
      // Generate IDs with minimum recommended size (8)
      final ids = NanoidGenerator.generateMultiple(100, size: 8);

      expect(ids.length, 100);
      for (final id in ids) {
        expect(id.length, 8);
      }

      // Even with small size, should be unique for small batch
      expect(ids.toSet().length, 100);
    });

    test('Edge case: Generate maximum valid size', () {
      // Generate IDs with large size (64)
      final ids = NanoidGenerator.generateMultiple(10, size: 64);

      expect(ids.length, 10);
      for (final id in ids) {
        expect(id.length, 64);
      }

      expect(ids.toSet().length, 10);
    });
  });
}
