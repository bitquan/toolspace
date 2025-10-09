import 'package:flutter_test/flutter_test.dart';
import 'package:toolspace/tools/image_resizer/logic/upload_manager.dart';
import 'dart:typed_data';

void main() {
  group('ImageUpload', () {
    group('ImageUpload creation', () {
      test('should create ImageUpload from bytes with correct properties', () {
        // Arrange
        final bytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        const fileName = 'test.png';

        // Act
        final imageUpload = ImageUpload.fromBytes(
          bytes: bytes,
          name: fileName,
        );

        // Assert
        expect(imageUpload.bytes, equals(bytes));
        expect(imageUpload.name, equals(fileName));
        expect(imageUpload.contentType, equals('image/png'));
        expect(imageUpload.size, equals(5));
      });

      test('should infer correct content type from file extension', () {
        // Test PNG
        expect(ImageUpload.inferContentType('image.png'), equals('image/png'));

        // Test JPEG variants
        expect(ImageUpload.inferContentType('photo.jpg'), equals('image/jpeg'));
        expect(
            ImageUpload.inferContentType('picture.jpeg'), equals('image/jpeg'));

        // Test WebP
        expect(
            ImageUpload.inferContentType('image.webp'), equals('image/webp'));

        // Test GIF
        expect(
            ImageUpload.inferContentType('animation.gif'), equals('image/gif'));

        // Test BMP
        expect(ImageUpload.inferContentType('bitmap.bmp'), equals('image/bmp'));

        // Test unknown extension
        expect(ImageUpload.inferContentType('file.unknown'),
            equals('application/octet-stream'));
      });

      test('should use provided content type over inferred', () {
        // Arrange
        final bytes = Uint8List.fromList([1, 2, 3]);
        const fileName = 'test.png';
        const providedType = 'custom/type';

        // Act
        final imageUpload = ImageUpload.fromBytes(
          bytes: bytes,
          name: fileName,
          contentType: providedType,
        );

        // Assert
        expect(imageUpload.contentType, equals(providedType));
      });

      test('should format file size correctly', () {
        // Test bytes
        final smallFile = ImageUpload(
          bytes: Uint8List(500),
          name: 'small.png',
          contentType: 'image/png',
          size: 500,
        );
        expect(smallFile.formattedSize, equals('500 B'));

        // Test KB
        final mediumFile = ImageUpload(
          bytes: Uint8List(1536), // 1.5 KB
          name: 'medium.png',
          contentType: 'image/png',
          size: 1536,
        );
        expect(mediumFile.formattedSize, equals('1.5 KB'));

        // Test MB
        final largeFile = ImageUpload(
          bytes: Uint8List(2621440), // 2.5 MB
          name: 'large.png',
          contentType: 'image/png',
          size: 2621440,
        );
        expect(largeFile.formattedSize, equals('2.5 MB'));
      });

      test('should validate file types correctly', () {
        // Valid PNG
        final pngFile = ImageUpload(
          bytes: Uint8List(1000),
          name: 'test.png',
          contentType: 'image/png',
          size: 1000,
        );
        expect(pngFile.isValid, isTrue);

        // Valid JPEG
        final jpegFile = ImageUpload(
          bytes: Uint8List(1000),
          name: 'test.jpg',
          contentType: 'image/jpeg',
          size: 1000,
        );
        expect(jpegFile.isValid, isTrue);

        // Valid WebP
        final webpFile = ImageUpload(
          bytes: Uint8List(1000),
          name: 'test.webp',
          contentType: 'image/webp',
          size: 1000,
        );
        expect(webpFile.isValid, isTrue);

        // Valid GIF
        final gifFile = ImageUpload(
          bytes: Uint8List(1000),
          name: 'test.gif',
          contentType: 'image/gif',
          size: 1000,
        );
        expect(gifFile.isValid, isTrue);

        // Invalid type
        final invalidFile = ImageUpload(
          bytes: Uint8List(1000),
          name: 'test.txt',
          contentType: 'text/plain',
          size: 1000,
        );
        expect(invalidFile.isValid, isFalse);

        // File too large
        final tooLargeFile = ImageUpload(
          bytes: Uint8List(20 * 1024 * 1024 + 1),
          name: 'large.png',
          contentType: 'image/png',
          size: 20 * 1024 * 1024 + 1,
        );
        expect(tooLargeFile.isValid, isFalse);
      });
    });

    group('UploadManager validation', () {
      test('should validate file types correctly', () {
        // Valid types
        const validTypes = [
          'image/png',
          'image/jpeg',
          'image/webp',
          'image/gif',
          'image/bmp',
        ];

        for (final type in validTypes) {
          final file = ImageUpload(
            bytes: Uint8List(1000),
            name: 'test.file',
            contentType: type,
            size: 1000,
          );
          expect(file.isValid, isTrue, reason: 'Type $type should be valid');
        }

        // Invalid types
        const invalidTypes = [
          'text/plain',
          'application/zip',
          'application/pdf',
          'video/mp4',
        ];

        for (final type in invalidTypes) {
          final file = ImageUpload(
            bytes: Uint8List(1000),
            name: 'test.file',
            contentType: type,
            size: 1000,
          );
          expect(file.isValid, isFalse, reason: 'Type $type should be invalid');
        }
      });

      test('should validate file size limits', () {
        // Valid size (exactly 20MB)
        final validFile = ImageUpload(
          bytes: Uint8List(20 * 1024 * 1024),
          name: 'valid.png',
          contentType: 'image/png',
          size: 20 * 1024 * 1024,
        );
        expect(validFile.isValid, isTrue);

        // Invalid size (over 20MB)
        final invalidFile = ImageUpload(
          bytes: Uint8List(20 * 1024 * 1024 + 1),
          name: 'invalid.png',
          contentType: 'image/png',
          size: 20 * 1024 * 1024 + 1,
        );
        expect(invalidFile.isValid, isFalse);
      });
    });

    group('File name sanitization', () {
      test('should handle various file names correctly', () {
        // Test with valid characters
        final validFile = ImageUpload.fromBytes(
          bytes: Uint8List(100),
          name: 'valid-file_name.123.png',
        );
        expect(validFile.sanitizedName, equals('valid-file_name.123.png'));

        // Test with invalid characters
        final invalidCharsFile = ImageUpload.fromBytes(
          bytes: Uint8List(100),
          name: 'file with spaces & special!@#chars.png',
        );
        expect(invalidCharsFile.sanitizedName,
            equals('file_with_spaces___special___chars.png'));

        // Test with unicode
        final unicodeFile = ImageUpload.fromBytes(
          bytes: Uint8List(100),
          name: 'файл.png',
        );
        expect(unicodeFile.sanitizedName, equals('____.png'));
      });
    });
  });
}
