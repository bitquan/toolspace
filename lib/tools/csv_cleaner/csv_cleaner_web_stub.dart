// Stub implementation for non-web platforms
// This file provides no-op implementations for web-specific functionality

/// Pick a CSV file (stub - does nothing on non-web platforms)
void pickCsvFile(Function(String content, String fileName) onFileLoaded) {
  throw UnsupportedError('File picking is only supported on web platform');
}

/// Download CSV file (stub - does nothing on non-web platforms)
void downloadCsv(String csvContent, String fileName) {
  throw UnsupportedError('File download is only supported on web platform');
}
