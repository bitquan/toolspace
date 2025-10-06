import 'package:flutter_test/flutter_test.dart';
import 'package:toolspace/tools/file_merger/logic/upload_manager.dart';
import 'dart:typed_data';

void main() {
  group('UploadManager', () {
    group('FileUpload', () {
      test('should create FileUpload from bytes with correct properties', () {
        // Arrange
        final bytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        const fileName = 'test.pdf';

        // Act
        final fileUpload = FileUpload.fromBytes(
          bytes: bytes,
          name: fileName,
        );

        // Assert
        expect(fileUpload.bytes, equals(bytes));
        expect(fileUpload.name, equals(fileName));
        expect(fileUpload.contentType, equals('application/pdf'));
        expect(fileUpload.size, equals(5));
      });

      test('should infer correct content type from file extension', () {
        // Test PDF
        expect(FileUpload.inferContentType('document.pdf'),
            equals('application/pdf'));

        // Test PNG
        expect(FileUpload.inferContentType('image.png'), equals('image/png'));

        // Test JPEG variants
        expect(FileUpload.inferContentType('photo.jpg'), equals('image/jpeg'));
        expect(
            FileUpload.inferContentType('picture.jpeg'), equals('image/jpeg'));

        // Test unknown extension
        expect(FileUpload.inferContentType('file.unknown'),
            equals('application/octet-stream'));
      });

      test('should use provided content type over inferred', () {
        // Arrange
        final bytes = Uint8List.fromList([1, 2, 3]);
        const fileName = 'test.pdf';
        const providedType = 'custom/type';

        // Act
        final fileUpload = FileUpload.fromBytes(
          bytes: bytes,
          name: fileName,
          contentType: providedType,
        );

        // Assert
        expect(fileUpload.contentType, equals(providedType));
      });

      test('should format file size correctly', () {
        // Test bytes
        final smallFile = FileUpload(
          bytes: Uint8List(500),
          name: 'small.pdf',
          contentType: 'application/pdf',
          size: 500,
        );
        expect(smallFile.formattedSize, equals('500 B'));

        // Test KB
        final mediumFile = FileUpload(
          bytes: Uint8List(1536), // 1.5 KB
          name: 'medium.pdf',
          contentType: 'application/pdf',
          size: 1536,
        );
        expect(mediumFile.formattedSize, equals('1.5 KB'));

        // Test MB
        final largeFile = FileUpload(
          bytes: Uint8List(2621440), // 2.5 MB
          name: 'large.pdf',
          contentType: 'application/pdf',
          size: 2621440,
        );
        expect(largeFile.formattedSize, equals('2.5 MB'));
      });

      test('should validate file types correctly', () {
        // Valid PDF
        final pdfFile = FileUpload(
          bytes: Uint8List(1000),
          name: 'test.pdf',
          contentType: 'application/pdf',
          size: 1000,
        );
        expect(pdfFile.isValid, isTrue);

        // Valid PNG
        final pngFile = FileUpload(
          bytes: Uint8List(1000),
          name: 'test.png',
          contentType: 'image/png',
          size: 1000,
        );
        expect(pngFile.isValid, isTrue);

        // Valid JPEG
        final jpegFile = FileUpload(
          bytes: Uint8List(1000),
          name: 'test.jpg',
          contentType: 'image/jpeg',
          size: 1000,
        );
        expect(jpegFile.isValid, isTrue);

        // Invalid type
        final invalidFile = FileUpload(
          bytes: Uint8List(1000),
          name: 'test.txt',
          contentType: 'text/plain',
          size: 1000,
        );
        expect(invalidFile.isValid, isFalse);

        // Too large file (>10MB)
        final tooLargeFile = FileUpload(
          bytes: Uint8List(11 * 1024 * 1024), // 11MB
          name: 'large.pdf',
          contentType: 'application/pdf',
          size: 11 * 1024 * 1024,
        );
        expect(tooLargeFile.isValid, isFalse);
      });
    });

    group('UploadManager validation', () {
      test('should validate file types correctly', () {
        // This tests the validation logic through FileUpload.isValid

        // Valid types
        const validTypes = [
          'application/pdf',
          'image/png',
          'image/jpeg',
        ];

        for (final type in validTypes) {
          final file = FileUpload(
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
          'image/gif',
          'video/mp4',
        ];

        for (final type in invalidTypes) {
          final file = FileUpload(
            bytes: Uint8List(1000),
            name: 'test.file',
            contentType: type,
            size: 1000,
          );
          expect(file.isValid, isFalse, reason: 'Type $type should be invalid');
        }
      });

      test('should validate file size limits', () {
        // Valid size (exactly 10MB)
        final validFile = FileUpload(
          bytes: Uint8List(10 * 1024 * 1024),
          name: 'valid.pdf',
          contentType: 'application/pdf',
          size: 10 * 1024 * 1024,
        );
        expect(validFile.isValid, isTrue);

        // Invalid size (over 10MB)
        final invalidFile = FileUpload(
          bytes: Uint8List(10 * 1024 * 1024 + 1),
          name: 'invalid.pdf',
          contentType: 'application/pdf',
          size: 10 * 1024 * 1024 + 1,
        );
        expect(invalidFile.isValid, isFalse);
      });
    });

    group('File name sanitization', () {
      test('should handle various file names correctly', () {
        // Test with valid characters
        final validFile = FileUpload.fromBytes(
          bytes: Uint8List(100),
          name: 'valid_file-name.pdf',
        );
        expect(validFile.name, equals('valid_file-name.pdf'));

        // Test with special characters that should be replaced
        final specialCharsFile = FileUpload.fromBytes(
          bytes: Uint8List(100),
          name: 'file@#\$%^&*()+={}[]|\\:";\'<>?,/.pdf',
        );
        // The actual sanitization happens in the upload method, not in FileUpload
        // This test verifies the file name is preserved as-is in FileUpload
        expect(specialCharsFile.name,
            equals('file@#\$%^&*()+={}[]|\\:";\'<>?,/.pdf'));
      });

      test('should preserve original file name in FileUpload', () {
        const originalName = 'My Document (2023).pdf';
        final file = FileUpload.fromBytes(
          bytes: Uint8List(100),
          name: originalName,
        );
        expect(file.name, equals(originalName));
      });
    });
  });
}
