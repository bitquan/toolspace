import 'package:flutter_test/flutter_test.dart';
import 'package:toolspace/tools/time_convert/logic/timestamp_converter.dart';

void main() {
  group('TimestampConverter - Natural Language Parsing', () {
    test('parses "now" correctly', () {
      final result = TimestampConverter.parseNaturalLanguage('now');

      expect(result, isNotNull);
      expect(result!.difference(DateTime.now()).inSeconds.abs(), lessThan(2));
    });

    test('parses "today" correctly', () {
      final result = TimestampConverter.parseNaturalLanguage('today');

      expect(result, isNotNull);
      expect(result!.difference(DateTime.now()).inSeconds.abs(), lessThan(2));
    });

    test('parses "yesterday" correctly', () {
      final result = TimestampConverter.parseNaturalLanguage('yesterday');
      final expected = DateTime.now().subtract(const Duration(days: 1));

      expect(result, isNotNull);
      expect(result!.day, expected.day);
    });

    test('parses "tomorrow" correctly', () {
      final result = TimestampConverter.parseNaturalLanguage('tomorrow');
      final expected = DateTime.now().add(const Duration(days: 1));

      expect(result, isNotNull);
      expect(result!.day, expected.day);
    });

    test('parses "5 minutes ago" correctly', () {
      final result = TimestampConverter.parseNaturalLanguage('5 minutes ago');
      final expected = DateTime.now().subtract(const Duration(minutes: 5));

      expect(result, isNotNull);
      expect(result!.difference(expected).inSeconds.abs(), lessThan(2));
    });

    test('parses "in 2 hours" correctly', () {
      final result = TimestampConverter.parseNaturalLanguage('in 2 hours');
      final expected = DateTime.now().add(const Duration(hours: 2));

      expect(result, isNotNull);
      expect(result!.difference(expected).inSeconds.abs(), lessThan(2));
    });

    test('parses "3 days ago" correctly', () {
      final result = TimestampConverter.parseNaturalLanguage('3 days ago');
      final expected = DateTime.now().subtract(const Duration(days: 3));

      expect(result, isNotNull);
      expect(result!.difference(expected).inMinutes.abs(), lessThan(2));
    });

    test('parses "1 week ago" correctly', () {
      final result = TimestampConverter.parseNaturalLanguage('1 week ago');
      final expected = DateTime.now().subtract(const Duration(days: 7));

      expect(result, isNotNull);
      expect(result!.difference(expected).inMinutes.abs(), lessThan(2));
    });

    test('parses ISO 8601 date string', () {
      const input = '2024-01-15T10:30:00.000Z';
      final result = TimestampConverter.parseNaturalLanguage(input);

      expect(result, isNotNull);
      expect(result!.year, 2024);
      expect(result.month, 1);
      expect(result.day, 15);
    });

    test('parses Unix timestamp in seconds', () {
      const timestamp = 1234567890; // 2009-02-13
      final result = TimestampConverter.parseNaturalLanguage(
        timestamp.toString(),
      );

      expect(result, isNotNull);
      expect(result!.year, 2009);
      expect(result.month, 2);
      expect(result.day, 13);
    });

    test('parses Unix timestamp in milliseconds', () {
      const timestamp = 1234567890000; // 2009-02-13
      final result = TimestampConverter.parseNaturalLanguage(
        timestamp.toString(),
      );

      expect(result, isNotNull);
      expect(result!.year, 2009);
      expect(result.month, 2);
      expect(result.day, 13);
    });

    test('returns null for invalid input', () {
      final result = TimestampConverter.parseNaturalLanguage('invalid');

      expect(result, isNull);
    });

    test('returns null for empty input', () {
      final result = TimestampConverter.parseNaturalLanguage('');

      expect(result, isNull);
    });
  });

  group('TimestampConverter - Unix Conversions', () {
    test('converts DateTime to Unix seconds', () {
      final dateTime = DateTime(2024, 1, 1, 0, 0, 0);
      final result = TimestampConverter.toUnixSeconds(dateTime);

      expect(result, isA<int>());
      expect(result, greaterThan(0));
    });

    test('converts DateTime to Unix milliseconds', () {
      final dateTime = DateTime(2024, 1, 1, 0, 0, 0);
      final result = TimestampConverter.toUnixMilliseconds(dateTime);

      expect(result, isA<int>());
      expect(result, greaterThan(0));
      expect(result, greaterThan(TimestampConverter.toUnixSeconds(dateTime)));
    });

    test('converts Unix seconds to DateTime', () {
      const timestamp = 1704067200; // 2024-01-01 00:00:00 UTC
      final result = TimestampConverter.fromUnixSeconds(timestamp);

      expect(result.year, 2024);
      expect(result.month, 1);
      expect(result.day, 1);
    });

    test('converts Unix milliseconds to DateTime', () {
      const timestamp = 1704067200000; // 2024-01-01 00:00:00 UTC
      final result = TimestampConverter.fromUnixMilliseconds(timestamp);

      expect(result.year, 2024);
      expect(result.month, 1);
      expect(result.day, 1);
    });

    test('round-trip conversion Unix seconds', () {
      final original = DateTime.utc(2024, 6, 15, 12, 30, 45);
      final seconds = TimestampConverter.toUnixSeconds(original);
      final result = TimestampConverter.fromUnixSeconds(seconds);

      expect(result.year, original.year);
      expect(result.month, original.month);
      expect(result.day, original.day);
      expect(result.hour, original.hour);
      expect(result.minute, original.minute);
      // Seconds might differ slightly due to rounding
      expect((result.second - original.second).abs(), lessThan(2));
    });
  });

  group('TimestampConverter - Format Conversions', () {
    test('formats to ISO 8601', () {
      final dateTime = DateTime(2024, 1, 15, 10, 30, 45);
      final result = TimestampConverter.toISO8601(dateTime);

      expect(result, contains('2024'));
      expect(result, contains('01'));
      expect(result, contains('15'));
    });

    test('formats to RFC 3339', () {
      final dateTime = DateTime(2024, 1, 15, 10, 30, 45);
      final result = TimestampConverter.toRFC3339(dateTime);

      expect(result, contains('2024'));
      expect(result, contains('Z')); // UTC indicator
    });

    test('formats to human readable with time', () {
      final dateTime = DateTime(2024, 1, 15, 10, 30, 45);
      final result = TimestampConverter.toHumanReadable(dateTime);

      expect(result, '2024-01-15 10:30:45');
    });

    test('formats to human readable date only', () {
      final dateTime = DateTime(2024, 1, 15, 10, 30, 45);
      final result = TimestampConverter.toHumanReadable(
        dateTime,
        includeTime: false,
      );

      expect(result, '2024-01-15');
    });

    test('formats with custom TimeFormat enum', () {
      final dateTime = DateTime(2024, 1, 15, 10, 30, 45);

      final iso = TimestampConverter.formatCustom(dateTime, TimeFormat.iso8601);
      expect(iso, contains('2024'));

      final unix = TimestampConverter.formatCustom(
        dateTime,
        TimeFormat.unixSeconds,
      );
      expect(int.tryParse(unix), isNotNull);

      final timeOnly = TimestampConverter.formatCustom(
        dateTime,
        TimeFormat.timeOnly,
      );
      expect(timeOnly, '10:30:45');
    });
  });

  group('TimestampConverter - Relative Time', () {
    test('returns "a few seconds ago" for recent past', () {
      final dateTime = DateTime.now().subtract(const Duration(seconds: 5));
      final result = TimestampConverter.getRelativeTime(dateTime);

      expect(result, 'a few seconds ago');
    });

    test('returns "X minutes ago" for past minutes', () {
      final dateTime = DateTime.now().subtract(const Duration(minutes: 5));
      final result = TimestampConverter.getRelativeTime(dateTime);

      expect(result, '5 minutes ago');
    });

    test('returns "X hours ago" for past hours', () {
      final dateTime = DateTime.now().subtract(const Duration(hours: 3));
      final result = TimestampConverter.getRelativeTime(dateTime);

      expect(result, '3 hours ago');
    });

    test('returns "X days ago" for past days', () {
      final dateTime = DateTime.now().subtract(const Duration(days: 2));
      final result = TimestampConverter.getRelativeTime(dateTime);

      expect(result, '2 days ago');
    });

    test('returns "in X minutes" for future', () {
      final dateTime = DateTime.now().add(const Duration(minutes: 15));
      final result = TimestampConverter.getRelativeTime(dateTime);

      expect(result, '15 minutes from now');
    });

    test('returns "in X hours" for future hours', () {
      final dateTime = DateTime.now().add(const Duration(hours: 2));
      final result = TimestampConverter.getRelativeTime(dateTime);

      expect(result, '2 hours from now');
    });
  });

  group('TimestampConverter - Edge Cases', () {
    test('handles leap year dates', () {
      final result = TimestampConverter.parseNaturalLanguage('2024-02-29');

      expect(result, isNotNull);
      expect(result!.year, 2024);
      expect(result.month, 2);
      expect(result.day, 29);
    });

    test('handles end of year', () {
      final result = TimestampConverter.parseNaturalLanguage('2024-12-31');

      expect(result, isNotNull);
      expect(result!.month, 12);
      expect(result.day, 31);
    });

    test('handles midnight', () {
      final dateTime = DateTime(2024, 1, 1, 0, 0, 0);
      final formatted = TimestampConverter.toHumanReadable(dateTime);

      expect(formatted, contains('00:00:00'));
    });

    test('handles different timezone strings', () {
      // Should not throw, even with different timezone strings
      expect(
        () => TimestampConverter.parseNaturalLanguage(
          'now',
          timezone: 'America/New_York',
        ),
        returnsNormally,
      );
    });
  });
}
