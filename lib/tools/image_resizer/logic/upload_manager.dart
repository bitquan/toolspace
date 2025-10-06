import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Represents an uploaded image file
class ImageUpload {
  final Uint8List bytes;
  final String name;
  final String contentType;
  final int size;

  ImageUpload({
    required this.bytes,
    required this.name,
    required this.contentType,
    required this.size,
  });

  /// Create ImageUpload from bytes
  factory ImageUpload.fromBytes({
    required Uint8List bytes,
    required String name,
    String? contentType,
  }) {
    final inferredType = contentType ?? inferContentType(name);
    return ImageUpload(
      bytes: bytes,
      name: name,
      contentType: inferredType,
      size: bytes.length,
    );
  }

  /// Infer content type from file extension
  static String inferContentType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      case 'bmp':
        return 'image/bmp';
      default:
        return 'application/octet-stream';
    }
  }

  /// Get human-readable file size
  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Check if file is valid for resizing
  bool get isValid {
    const validTypes = [
      'image/png',
      'image/jpeg',
      'image/webp',
      'image/gif',
      'image/bmp',
    ];
    return validTypes.contains(contentType) && size <= 20 * 1024 * 1024;
  }

  /// Sanitize file name for storage
  String get sanitizedName {
    return name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
  }
}

/// Manages image uploads to Firebase Storage
class UploadManager {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Upload a single image file
  Future<String> uploadFile(ImageUpload file) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User must be signed in to upload files.');
    }

    // Validate file type
    if (!file.isValid) {
      throw Exception(
          'Invalid file type. Only images (PNG, JPG, WebP, GIF, BMP) are allowed.');
    }

    // Validate file size (20MB limit)
    const maxSizeBytes = 20 * 1024 * 1024; // 20MB
    if (file.size > maxSizeBytes) {
      throw Exception('File too large. Maximum size is 20MB.');
    }

    // Create unique file path
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final sanitizedFileName = file.sanitizedName;
    final filePath = 'uploads/${user.uid}/$timestamp-$sanitizedFileName';

    try {
      // Upload to Firebase Storage
      final ref = _storage.ref().child(filePath);
      await ref.putData(
        file.bytes,
        SettableMetadata(
          contentType: file.contentType,
          customMetadata: {
            'originalFileName': file.name,
            'uploadedBy': user.uid,
            'uploadTimestamp': timestamp.toString(),
          },
        ),
      );

      return filePath;
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  /// Upload multiple image files
  Future<List<String>> uploadMultipleFiles(List<ImageUpload> files) async {
    final filePaths = <String>[];

    for (final file in files) {
      final path = await uploadFile(file);
      filePaths.add(path);
    }

    return filePaths;
  }
}
