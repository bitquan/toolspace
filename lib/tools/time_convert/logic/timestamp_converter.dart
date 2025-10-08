/// Timestamp conversion logic for Time Converter tool
/// Handles epoch/human conversions, natural language parsing, and timezones
class TimestampConverter {
  /// Parse natural language time inputs like "now", "yesterday", "5 minutes ago"
  static DateTime? parseNaturalLanguage(
    String input, {
    String timezone = 'UTC',
  }) {
    final normalized = input.trim().toLowerCase();
    final now = DateTime.now();

    if (normalized.isEmpty) return null;

    // Current time
    if (normalized == 'now' || normalized == 'today') {
      return now;
    }

    // Yesterday/Tomorrow
    if (normalized == 'yesterday') {
      return now.subtract(const Duration(days: 1));
    }
    if (normalized == 'tomorrow') {
      return now.add(const Duration(days: 1));
    }

    // Relative time patterns: "X units ago" or "in X units"
    final relativePattern = RegExp(
      r'^(?:in\s+)?(\d+)\s+(second|minute|hour|day|week|month|year)s?\s*(?:ago)?$',
    );
    final match = relativePattern.firstMatch(normalized);

    if (match != null) {
      final amount = int.tryParse(match.group(1) ?? '0') ?? 0;
      final unit = match.group(2) ?? '';
      final isAgo = normalized.contains('ago');

      Duration duration;
      switch (unit) {
        case 'second':
          duration = Duration(seconds: amount);
          break;
        case 'minute':
          duration = Duration(minutes: amount);
          break;
        case 'hour':
          duration = Duration(hours: amount);
          break;
        case 'day':
          duration = Duration(days: amount);
          break;
        case 'week':
          duration = Duration(days: amount * 7);
          break;
        case 'month':
          duration = Duration(days: amount * 30); // Approximate
          break;
        case 'year':
          duration = Duration(days: amount * 365); // Approximate
          break;
        default:
          return null;
      }

      return isAgo ? now.subtract(duration) : now.add(duration);
    }

    // Try parsing as Unix timestamp first (numbers only)
    final timestamp = int.tryParse(input);
    if (timestamp != null) {
      // If timestamp is too large, assume milliseconds; otherwise seconds
      if (timestamp > 10000000000) {
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      } else {
        return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
      }
    }

    // Try parsing as ISO 8601 or other standard formats
    try {
      return DateTime.parse(input);
    } catch (_) {
      // Not a valid date format
    }

    return null;
  }

  /// Convert DateTime to Unix epoch (seconds)
  static int toUnixSeconds(DateTime dateTime) {
    return dateTime.millisecondsSinceEpoch ~/ 1000;
  }

  /// Convert DateTime to Unix epoch (milliseconds)
  static int toUnixMilliseconds(DateTime dateTime) {
    return dateTime.millisecondsSinceEpoch;
  }

  /// Convert Unix epoch seconds to DateTime
  static DateTime fromUnixSeconds(int seconds) {
    return DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true);
  }

  /// Convert Unix epoch milliseconds to DateTime
  static DateTime fromUnixMilliseconds(int milliseconds) {
    return DateTime.fromMillisecondsSinceEpoch(milliseconds, isUtc: true);
  }

  /// Format DateTime to ISO 8601 string
  static String toISO8601(DateTime dateTime) {
    return dateTime.toIso8601String();
  }

  /// Format DateTime to RFC 3339 string
  static String toRFC3339(DateTime dateTime) {
    return dateTime.toUtc().toIso8601String();
  }

  /// Format DateTime to human-readable string
  static String toHumanReadable(DateTime dateTime, {bool includeTime = true}) {
    final year = dateTime.year.toString();
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');

    if (!includeTime) {
      return '$year-$month-$day';
    }

    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');

    return '$year-$month-$day $hour:$minute:$second';
  }

  /// Format DateTime with custom format
  static String formatCustom(DateTime dateTime, TimeFormat format) {
    switch (format) {
      case TimeFormat.iso8601:
        return toISO8601(dateTime);
      case TimeFormat.rfc3339:
        return toRFC3339(dateTime);
      case TimeFormat.unixSeconds:
        return toUnixSeconds(dateTime).toString();
      case TimeFormat.unixMilliseconds:
        return toUnixMilliseconds(dateTime).toString();
      case TimeFormat.humanReadable:
        return toHumanReadable(dateTime);
      case TimeFormat.dateOnly:
        return toHumanReadable(dateTime, includeTime: false);
      case TimeFormat.timeOnly:
        final hour = dateTime.hour.toString().padLeft(2, '0');
        final minute = dateTime.minute.toString().padLeft(2, '0');
        final second = dateTime.second.toString().padLeft(2, '0');
        return '$hour:$minute:$second';
    }
  }

  /// Get relative time description (e.g., "5 minutes ago", "in 2 hours")
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);
    final absDifference = difference.abs();

    final isFuture = difference.isNegative == false;
    final suffix = isFuture ? 'from now' : 'ago';

    if (absDifference.inSeconds < 60) {
      return isFuture ? 'in a few seconds' : 'a few seconds ago';
    } else if (absDifference.inMinutes < 60) {
      final minutes = absDifference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} $suffix';
    } else if (absDifference.inHours < 24) {
      final hours = absDifference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} $suffix';
    } else if (absDifference.inDays < 7) {
      final days = absDifference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} $suffix';
    } else if (absDifference.inDays < 30) {
      final weeks = absDifference.inDays ~/ 7;
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} $suffix';
    } else if (absDifference.inDays < 365) {
      final months = absDifference.inDays ~/ 30;
      return '$months ${months == 1 ? 'month' : 'months'} $suffix';
    } else {
      final years = absDifference.inDays ~/ 365;
      return '$years ${years == 1 ? 'year' : 'years'} $suffix';
    }
  }

  /// List of common timezones
  static const List<String> commonTimezones = [
    'UTC',
    'Local',
    'America/New_York',
    'America/Los_Angeles',
    'America/Chicago',
    'America/Denver',
    'Europe/London',
    'Europe/Paris',
    'Europe/Berlin',
    'Asia/Tokyo',
    'Asia/Shanghai',
    'Asia/Dubai',
    'Australia/Sydney',
  ];
}

/// Time format options
enum TimeFormat {
  iso8601,
  rfc3339,
  unixSeconds,
  unixMilliseconds,
  humanReadable,
  dateOnly,
  timeOnly,
}
