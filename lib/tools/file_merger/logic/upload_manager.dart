import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Manages file uploads to Firebase Storage for the File Merger tool
class UploadManager {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Upload a file to Firebase Storage
  /// Returns the full path of the uploaded file
  Future<String> uploadFile({
    required Uint8List fileBytes,
    required String fileName,
    required String contentType,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User must be authenticated to upload files');
    }

    // Validate file type
    if (!_isValidFileType(contentType)) {
      throw Exception(
          'Invalid file type. Only PDF and images (PNG, JPG) are allowed.');
    }

    // Validate file size (10MB limit)
    const maxSizeBytes = 10 * 1024 * 1024; // 10MB
    if (fileBytes.length > maxSizeBytes) {
      throw Exception('File too large. Maximum size is 10MB.');
    }

    // Create unique file path
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final sanitizedFileName = _sanitizeFileName(fileName);
    final filePath = 'uploads/${user.uid}/$timestamp-$sanitizedFileName';

    try {
      // Upload to Firebase Storage
      final ref = _storage.ref().child(filePath);
      await ref.putData(
        fileBytes,
        SettableMetadata(
          contentType: contentType,
          customMetadata: {
            'originalFileName': fileName,
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

  /// Upload multiple files concurrently
  Future<List<String>> uploadMultipleFiles(List<FileUpload> files) async {
    if (files.isEmpty) {
      throw Exception('No files provided for upload');
    }

    if (files.length > 20) {
      throw Exception('Maximum 20 files allowed per merge');
    }

    // Upload all files concurrently
    final uploadFutures = files.map((file) => uploadFile(
          fileBytes: file.bytes,
          fileName: file.name,
          contentType: file.contentType,
        ));

    return await Future.wait(uploadFutures);
  }

  /// Check if the file type is valid for merging
  bool _isValidFileType(String contentType) {
    const validTypes = [
      'application/pdf',
      'image/png',
      'image/jpeg',
      'image/jpg',
    ];
    return validTypes.contains(contentType.toLowerCase());
  }

  /// Sanitize filename to remove invalid characters
  String _sanitizeFileName(String fileName) {
    // Remove invalid characters and limit length
    final sanitized = fileName
        .replaceAll(RegExp(r'[^\w\-_\.]'), '_')
        .replaceAll(RegExp(r'_+'), '_');

    // Limit to 100 characters
    return sanitized.length > 100 ? sanitized.substring(0, 100) : sanitized;
  }

  /// Delete uploaded files (cleanup on error)
  Future<void> deleteFiles(List<String> filePaths) async {
    try {
      final deleteFutures =
          filePaths.map((path) => _storage.ref().child(path).delete());
      await Future.wait(deleteFutures);
    } catch (e) {
      // Log error but don't throw - this is cleanup
      print('Warning: Failed to delete some uploaded files: $e');
    }
  }
}

/// Represents a file to be uploaded
class FileUpload {
  final Uint8List bytes;
  final String name;
  final String contentType;
  final int size;

  const FileUpload({
    required this.bytes,
    required this.name,
    required this.contentType,
    required this.size,
  });

  /// Create FileUpload from web file
  factory FileUpload.fromBytes({
    required Uint8List bytes,
    required String name,
    String? contentType,
  }) {
    // Infer content type from file extension if not provided
    final inferredType = contentType ?? _inferContentType(name);

    return FileUpload(
      bytes: bytes,
      name: name,
      contentType: inferredType,
      size: bytes.length,
    );
  }

  /// Infer content type from file extension
  static String _inferContentType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return 'application/pdf';
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
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

  /// Check if file is valid for merging
  bool get isValid {
    const validTypes = [
      'application/pdf',
      'image/png',
      'image/jpeg',
    ];
    return validTypes.contains(contentType) && size <= 10 * 1024 * 1024;
  }
}
