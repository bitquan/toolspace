import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('URL Validation Tests', () {
    test('validates correct URLs', () {
      final validUrls = [
        'https://example.com',
        'http://example.com',
        'https://example.com/path',
        'https://sub.example.com',
        'https://example.com/path?query=value',
        'https://example.com:8080/path',
      ];

      for (final url in validUrls) {
        expect(isValidUrl(url), true, reason: '$url should be valid');
      }
    });

    test('rejects invalid URLs', () {
      final invalidUrls = [
        'not-a-url',
        'example.com', // Missing protocol in strict validation
        'htp://example.com',
        'https:/example.com',
        'https://example',
        'javascript:alert(1)',
      ];

      for (final url in invalidUrls) {
        expect(isValidUrl(url), false, reason: '$url should be invalid');
      }
    });

    test('rejects too long URLs', () {
      final longUrl = 'https://example.com/${'a' * 2500}';
      expect(isValidUrl(longUrl), false);
    });

    test('accepts empty URL as valid (no error shown)', () {
      expect(getValidationError(''), null);
    });
  });

  group('Short Code Generation Tests', () {
    test('generates codes of correct length', () {
      for (int i = 0; i < 10; i++) {
        final code = generateShortCode();
        expect(code.length, 6);
      }
    });

    test('generates alphanumeric codes', () {
      final code = generateShortCode();
      final alphanumericRegex = RegExp(r'^[a-zA-Z0-9]+$');
      expect(alphanumericRegex.hasMatch(code), true);
    });

    test('generates unique codes', () {
      final codes = <String>{};
      for (int i = 0; i < 100; i++) {
        codes.add(generateShortCode());
      }
      // With 6 characters and 62 possible chars (a-z, A-Z, 0-9),
      // we should get mostly unique values in 100 attempts
      expect(codes.length, greaterThan(90));
    });
  });

  group('Date Formatting Tests', () {
    test('formats recent dates correctly', () {
      final now = DateTime.now();

      expect(formatTimeAgo(now), 'Just now');
      expect(
        formatTimeAgo(now.subtract(const Duration(minutes: 30))),
        '30m ago',
      );
      expect(
        formatTimeAgo(now.subtract(const Duration(hours: 2))),
        '2h ago',
      );
      expect(
        formatTimeAgo(now.subtract(const Duration(days: 3))),
        '3d ago',
      );
    });
  });

  group('ShortUrl Model Tests', () {
    test('creates valid ShortUrl instance', () {
      final url = TestShortUrl(
        id: 'test-id',
        originalUrl: 'https://example.com',
        shortCode: 'abc123',
        createdAt: DateTime.now(),
      );

      expect(url.id, 'test-id');
      expect(url.originalUrl, 'https://example.com');
      expect(url.shortCode, 'abc123');
      expect(url.createdAt, isA<DateTime>());
    });
  });
}

// Helper functions for testing (these would normally be in the actual code)

bool isValidUrl(String url) {
  if (url.isEmpty) {
    return true; // Empty is considered valid (no error state)
  }

  // Require protocol (https or http)
  if (!url.startsWith('http://') && !url.startsWith('https://')) {
    return false;
  }

  // Use Uri.parse for robust validation
  try {
    final uri = Uri.parse(url);

    // Must have scheme and host
    if (!uri.hasScheme || uri.host.isEmpty) {
      return false;
    }

    // Must be http or https
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      return false;
    }

    // Must have valid TLD (at least one dot in host)
    if (!uri.host.contains('.')) {
      return false;
    }

    // Check length
    if (url.length > 2048) {
      return false;
    }

    return true;
  } catch (e) {
    return false;
  }
}

String? getValidationError(String url) {
  if (url.isEmpty) {
    return null;
  }

  if (!isValidUrl(url)) {
    return 'Please enter a valid URL';
  }

  if (url.length > 2048) {
    return 'URL is too long (max 2048 characters)';
  }

  return null;
}

String generateShortCode() {
  const chars =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final random = Random();
  return String.fromCharCodes(
    Iterable.generate(
      6,
      (_) => chars.codeUnitAt(random.nextInt(chars.length)),
    ),
  );
}

String formatTimeAgo(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inDays > 0) {
    return '${difference.inDays}d ago';
  } else if (difference.inHours > 0) {
    return '${difference.inHours}h ago';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes}m ago';
  } else {
    return 'Just now';
  }
}

// Test model
class TestShortUrl {
  final String id;
  final String originalUrl;
  final String shortCode;
  final DateTime createdAt;

  TestShortUrl({
    required this.id,
    required this.originalUrl,
    required this.shortCode,
    required this.createdAt,
  });
}
