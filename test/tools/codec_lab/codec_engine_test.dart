import 'package:flutter_test/flutter_test.dart';
import 'dart:typed_data';
import '../../../lib/tools/codec_lab/logic/codec_engine.dart';

void main() {
  group('Base64 Encoding/Decoding Tests', () {
    test('encodes text to Base64 correctly', () {
      expect(CodecEngine.encodeBase64('Hello World'), 'SGVsbG8gV29ybGQ=');
      expect(CodecEngine.encodeBase64(''), '');
      expect(
        CodecEngine.encodeBase64('The quick brown fox'),
        'VGhlIHF1aWNrIGJyb3duIGZveA==',
      );
    });

    test('decodes Base64 to text correctly', () {
      expect(CodecEngine.decodeBase64('SGVsbG8gV29ybGQ='), 'Hello World');
      expect(CodecEngine.decodeBase64(''), '');
      expect(
        CodecEngine.decodeBase64('VGhlIHF1aWNrIGJyb3duIGZveA=='),
        'The quick brown fox',
      );
    });

    test('handles Base64 with whitespace', () {
      expect(
        CodecEngine.decodeBase64('SGVs bG8g V29y bGQ='),
        'Hello World',
      );
      expect(
        CodecEngine.decodeBase64('SGVsbG8g\nV29ybGQ='),
        'Hello World',
      );
    });

    test('roundtrip Base64 encoding/decoding', () {
      const testStrings = [
        'Hello World',
        'Special chars: !@#\$%^&*()',
        'Unicode: 你好世界 🌍',
        'Numbers: 1234567890',
        'Mixed: Hello123!@#',
      ];

      for (final str in testStrings) {
        final encoded = CodecEngine.encodeBase64(str);
        final decoded = CodecEngine.decodeBase64(encoded);
        expect(decoded, str, reason: 'Roundtrip failed for: $str');
      }
    });

    test('throws on invalid Base64', () {
      expect(
        () => CodecEngine.decodeBase64('Invalid!!!'),
        throwsA(isA<CodecException>()),
      );
      expect(
        () => CodecEngine.decodeBase64('SGVs=bG8'),
        throwsA(isA<CodecException>()),
      );
    });
  });

  group('Hexadecimal Encoding/Decoding Tests', () {
    test('encodes text to Hex correctly', () {
      expect(CodecEngine.encodeHex('Hello'), '48656c6c6f');
      expect(CodecEngine.encodeHex(''), '');
      expect(CodecEngine.encodeHex('ABC'), '414243');
    });

    test('decodes Hex to text correctly', () {
      expect(CodecEngine.decodeHex('48656c6c6f'), 'Hello');
      expect(CodecEngine.decodeHex(''), '');
      expect(CodecEngine.decodeHex('414243'), 'ABC');
    });

    test('handles Hex with separators', () {
      expect(CodecEngine.decodeHex('48:65:6c:6c:6f'), 'Hello');
      expect(CodecEngine.decodeHex('48-65-6c-6c-6f'), 'Hello');
      expect(CodecEngine.decodeHex('48 65 6c 6c 6f'), 'Hello');
      expect(CodecEngine.decodeHex('48,65,6c,6c,6f'), 'Hello');
    });

    test('handles uppercase and lowercase Hex', () {
      expect(CodecEngine.decodeHex('48656C6C6F'), 'Hello');
      expect(CodecEngine.decodeHex('48656c6c6f'), 'Hello');
      expect(CodecEngine.decodeHex('48656C6c6F'), 'Hello');
    });

    test('roundtrip Hex encoding/decoding', () {
      const testStrings = [
        'Hello World',
        'Test123',
        'Special: !@#',
        '你好',
      ];

      for (final str in testStrings) {
        final encoded = CodecEngine.encodeHex(str);
        final decoded = CodecEngine.decodeHex(encoded);
        expect(decoded, str, reason: 'Roundtrip failed for: $str');
      }
    });

    test('throws on invalid Hex', () {
      expect(
        () => CodecEngine.decodeHex('xyz'),
        throwsA(isA<CodecException>()),
      );
      expect(
        () => CodecEngine.decodeHex('48656c'),
        throwsA(isA<CodecException>()),
      );
      expect(
        () => CodecEngine.decodeHex('GG'),
        throwsA(isA<CodecException>()),
      );
    });
  });

  group('URL Encoding/Decoding Tests', () {
    test('encodes text with URL encoding correctly', () {
      expect(CodecEngine.encodeUrl('Hello World'), 'Hello%20World');
      expect(CodecEngine.encodeUrl('test@example.com'), 'test%40example.com');
      expect(CodecEngine.encodeUrl('a+b=c'), 'a%2Bb%3Dc');
    });

    test('decodes URL encoded text correctly', () {
      expect(CodecEngine.decodeUrl('Hello%20World'), 'Hello World');
      expect(CodecEngine.decodeUrl('test%40example.com'), 'test@example.com');
      expect(CodecEngine.decodeUrl('a%2Bb%3Dc'), 'a+b=c');
    });

    test('roundtrip URL encoding/decoding', () {
      const testStrings = [
        'Hello World',
        'test@example.com',
        'path/to/file',
        'query?key=value&other=123',
        'Special: !@#\$%^&*()',
      ];

      for (final str in testStrings) {
        final encoded = CodecEngine.encodeUrl(str);
        final decoded = CodecEngine.decodeUrl(encoded);
        expect(decoded, str, reason: 'Roundtrip failed for: $str');
      }
    });

    test('handles already encoded URLs correctly', () {
      expect(CodecEngine.decodeUrl('test'), 'test');
      expect(CodecEngine.decodeUrl('hello'), 'hello');
    });

    test('throws on invalid URL encoding', () {
      expect(
        () => CodecEngine.decodeUrl('%'),
        throwsA(isA<CodecException>()),
      );
      expect(
        () => CodecEngine.decodeUrl('%2'),
        throwsA(isA<CodecException>()),
      );
      expect(
        () => CodecEngine.decodeUrl('%ZZ'),
        throwsA(isA<CodecException>()),
      );
    });
  });

  group('Byte Encoding/Decoding Tests', () {
    test('encodes bytes to Base64 correctly', () {
      final bytes = Uint8List.fromList([72, 101, 108, 108, 111]);
      expect(CodecEngine.encodeBytesToBase64(bytes), 'SGVsbG8=');
    });

    test('decodes Base64 to bytes correctly', () {
      final bytes = CodecEngine.decodeBase64ToBytes('SGVsbG8=');
      expect(bytes, [72, 101, 108, 108, 111]);
    });

    test('encodes bytes to Hex correctly', () {
      final bytes = Uint8List.fromList([72, 101, 108, 108, 111]);
      expect(CodecEngine.encodeBytesToHex(bytes), '48656c6c6f');
    });

    test('decodes Hex to bytes correctly', () {
      final bytes = CodecEngine.decodeHexToBytes('48656c6c6f');
      expect(bytes, [72, 101, 108, 108, 111]);
    });

    test('roundtrip byte encoding/decoding for Base64', () {
      final testBytes = [
        Uint8List.fromList([1, 2, 3, 4, 5]),
        Uint8List.fromList([255, 254, 253]),
        Uint8List.fromList([0, 127, 255]),
      ];

      for (final bytes in testBytes) {
        final encoded = CodecEngine.encodeBytesToBase64(bytes);
        final decoded = CodecEngine.decodeBase64ToBytes(encoded);
        expect(decoded, bytes, reason: 'Roundtrip failed for bytes');
      }
    });

    test('roundtrip byte encoding/decoding for Hex', () {
      final testBytes = [
        Uint8List.fromList([1, 2, 3, 4, 5]),
        Uint8List.fromList([255, 254, 253]),
        Uint8List.fromList([0, 127, 255]),
      ];

      for (final bytes in testBytes) {
        final encoded = CodecEngine.encodeBytesToHex(bytes);
        final decoded = CodecEngine.decodeHexToBytes(encoded);
        expect(decoded, bytes, reason: 'Roundtrip failed for bytes');
      }
    });
  });

  group('Format Detection Tests', () {
    test('detects Base64 format', () {
      expect(
        CodecEngine.detectFormat('SGVsbG8gV29ybGQ='),
        CodecFormat.base64,
      );
      expect(
        CodecEngine.detectFormat('VGVzdA=='),
        CodecFormat.base64,
      );
    });

    test('detects Hex format', () {
      expect(
        CodecEngine.detectFormat('48656c6c6f'),
        CodecFormat.hex,
      );
      expect(
        CodecEngine.detectFormat('DEADBEEF'),
        CodecFormat.hex,
      );
      expect(
        CodecEngine.detectFormat('48:65:6c:6c:6f'),
        CodecFormat.hex,
      );
    });

    test('detects URL encoding format', () {
      expect(
        CodecEngine.detectFormat('Hello%20World'),
        CodecFormat.url,
      );
      expect(
        CodecEngine.detectFormat('test%40example.com'),
        CodecFormat.url,
      );
    });

    test('returns unknown for plain text', () {
      expect(
        CodecEngine.detectFormat('Hello World'),
        CodecFormat.unknown,
      );
      expect(
        CodecEngine.detectFormat('test@example.com'),
        CodecFormat.unknown,
      );
    });

    test('returns unknown for empty input', () {
      expect(
        CodecEngine.detectFormat(''),
        CodecFormat.unknown,
      );
      expect(
        CodecEngine.detectFormat('   '),
        CodecFormat.unknown,
      );
    });

    test('handles ambiguous cases correctly', () {
      // "abc" could be plain text or hex, but hex detection should work
      expect(
        CodecEngine.detectFormat('abc'),
        CodecFormat.unknown, // Odd length, so not valid hex
      );
      expect(
        CodecEngine.detectFormat('abcd'),
        CodecFormat.hex, // Even length, valid hex
      );
    });
  });

  group('Validation Tests', () {
    test('validates Base64 correctly', () {
      expect(
        CodecEngine.isValid('SGVsbG8gV29ybGQ=', CodecFormat.base64),
        true,
      );
      expect(
        CodecEngine.isValid('Invalid!!!', CodecFormat.base64),
        false,
      );
    });

    test('validates Hex correctly', () {
      expect(
        CodecEngine.isValid('48656c6c6f', CodecFormat.hex),
        true,
      );
      expect(
        CodecEngine.isValid('xyz', CodecFormat.hex),
        false,
      );
      expect(
        CodecEngine.isValid('48656c', CodecFormat.hex),
        false, // Odd length
      );
    });

    test('validates URL encoding correctly', () {
      expect(
        CodecEngine.isValid('Hello%20World', CodecFormat.url),
        true,
      );
      expect(
        CodecEngine.isValid('test', CodecFormat.url),
        true, // Plain text is valid
      );
      expect(
        CodecEngine.isValid('%ZZ', CodecFormat.url),
        false,
      );
    });

    test('returns false for unknown format', () {
      expect(
        CodecEngine.isValid('anything', CodecFormat.unknown),
        false,
      );
    });
  });

  group('CodecFormat Extension Tests', () {
    test('returns correct display names', () {
      expect(CodecFormat.base64.displayName, 'Base64');
      expect(CodecFormat.hex.displayName, 'Hexadecimal');
      expect(CodecFormat.url.displayName, 'URL Encoding');
      expect(CodecFormat.unknown.displayName, 'Unknown');
    });
  });

  group('Edge Cases and Error Handling', () {
    test('handles empty strings', () {
      expect(CodecEngine.encodeBase64(''), '');
      expect(CodecEngine.decodeBase64(''), '');
      expect(CodecEngine.encodeHex(''), '');
      expect(CodecEngine.decodeHex(''), '');
      expect(CodecEngine.encodeUrl(''), '');
    });

    test('handles special Unicode characters', () {
      const unicode = '你好世界 🌍 💻';
      final base64 = CodecEngine.encodeBase64(unicode);
      expect(CodecEngine.decodeBase64(base64), unicode);

      final hex = CodecEngine.encodeHex(unicode);
      expect(CodecEngine.decodeHex(hex), unicode);

      final url = CodecEngine.encodeUrl(unicode);
      expect(CodecEngine.decodeUrl(url), unicode);
    });

    test('handles very long strings', () {
      final longString = 'A' * 10000;
      final encoded = CodecEngine.encodeBase64(longString);
      final decoded = CodecEngine.decodeBase64(encoded);
      expect(decoded, longString);
    });

    test('CodecException has correct message', () {
      const exception = CodecException('Test error');
      expect(exception.toString(), 'Test error');
    });
  });
}
