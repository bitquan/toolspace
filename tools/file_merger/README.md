# File Merger Tool

A production-ready tool for merging PDF files and images into a single PDF document.

## Features ✅ Implemented

- Multiple file upload and merging (PDF, PNG, JPG, JPEG)
- Drag-and-drop file selection interface
- Reorderable file list with remove functionality
- Real-time upload and merge progress tracking
- Secure cloud processing with Firebase Functions
- Quota management (3 free merges, unlimited for Pro)
- 7-day download links with copy-to-clipboard
- Comprehensive error handling and validation

## Architecture

- **Frontend**: Flutter web interface (`lib/tools/file_merger/`)
- **Backend**: Firebase Functions for server-side PDF processing (`functions/src/tools/file_merger/`)
- **Storage**: Cloud Storage for temporary file storage with automatic cleanup
- **Processing**: pdf-merger-js for PDF manipulation
- **Database**: Firestore for quota tracking

## Status

✅ **Production Ready** - v1 completed October 6, 2025

See **[Epic Summary](../../docs/epics/file-merger-v1-summary.md)** for complete implementation details.

## Usage

Access the File Merger tool from the main Toolspace app home screen. Users can:

1. Select files via drag-and-drop or file picker
2. Reorder files as needed
3. Click "Merge Files" to process
4. Download the merged PDF (link valid for 7 days)

## Technical Specifications

- **Max file size**: 10MB per file
- **Max files per merge**: 20 files
- **Supported formats**: PDF, PNG, JPG, JPEG
- **Free tier quota**: 3 merges per user
- **Download link validity**: 7 days

## Documentation

- **User Guide**: `docs/tools/file_merger.md`
- **Epic Summary**: `docs/epics/file-merger-v1-summary.md`
- **Implementation Log**: `docs/dev-log/features/2025-10-06-file-merger-v1.md`

## Testing

- Unit tests: `test/tools/file_merger_test.dart`
- Widget tests: `test/tools/file_merger_widget_test.dart`
- Backend tests: `functions/src/tools/file_merger/__tests__/quota.test.ts`
