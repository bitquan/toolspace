# File Merger

**Route:** `/tools/file-merger`  
**Category:** Heavy  
**Billing:** Pro  
**Status:** ✅ Production Ready  
**Heavy Op:** PDF Processing  
**Owner Code:** `lib/tools/file_merger/file_merger_screen.dart`

## 1. Overview

File Merger is a professional-grade document combination tool that merges multiple PDF documents and images (PNG, JPG, JPEG) into a single, organized PDF file. It targets professionals, students, and businesses needing to consolidate documents for presentations, reports, or document management workflows.

**Problem it solves:** Eliminates the need for expensive desktop PDF software or unreliable online services by providing secure, high-quality PDF merging with Pro-grade features and quota management.

**Target users:**

- Business professionals consolidating reports and presentations
- Students merging research documents and assignments
- Legal professionals combining case documents
- Administrative staff organizing document collections

**Typical inputs:** Multiple PDF files, PNG/JPG images, scanned documents, reports
**Typical outputs:** Single consolidated PDF with preserved quality and proper page ordering

# File Merger

**Route:** `/tools/file-merger`  
**Category:** Heavy  
**Billing:** Pro  
**Status:** ✅ Production Ready  
**Heavy Op:** PDF Processing  
**Owner Code:** `lib/tools/file_merger/file_merger_screen.dart`

## 1. Overview

File Merger is a professional-grade document combination tool that merges multiple PDF documents and images (PNG, JPG, JPEG) into a single, organized PDF file. It targets professionals, students, and businesses needing to consolidate documents for presentations, reports, or document management workflows.

**Problem it solves:** Eliminates the need for expensive desktop PDF software or unreliable online services by providing secure, high-quality PDF merging with Pro-grade features and quota management.

**Target users:**

- Business professionals consolidating reports and presentations
- Students merging research documents and assignments
- Legal professionals combining case documents
- Administrative staff organizing document collections

**Typical inputs:** Multiple PDF files, PNG/JPG images, scanned documents, reports
**Typical outputs:** Single consolidated PDF with preserved quality and proper page ordering

## 2. Features

### Core Merging Operations

- **Multi-Format Support** - PDF + Image combination into unified PDF
- **Drag-and-Drop Interface** - Intuitive file selection and reordering
- **Real-Time Progress** - Live upload and merge status tracking
- **Professional Output** - High-quality merged PDFs with optimization
- **Secure Processing** - Cloud-based processing with automatic cleanup

### File Management

- **File Validation** - Automatic format and size checking
- **Batch Upload** - Multiple file selection and processing
- **File Reordering** - Drag-and-drop sequence adjustment
- **Individual Removal** - Selective file removal before merge
- **Progress Tracking** - Granular upload and processing status

### Pro Features

- **Unlimited Merges** - No monthly operation limits (Pro)
- **Large File Support** - 50MB file size limit (Pro vs 10MB free)
- **Priority Processing** - Faster queue priority (Pro)
- **Extended Downloads** - 30-day link validity (Pro vs 7-day free)
- **Advanced Formats** - TIFF and BMP support (Pro)

## 3. UX Flow

### Primary Workflow

1. **Tool Access** - Navigate from home grid or direct route
2. **File Selection** - Drag-and-drop or click to browse files
3. **File Management** - Reorder, remove, or add additional files
4. **Merge Initiation** - Click "Merge Files" to start processing
5. **Progress Monitoring** - Watch upload and merge progress
6. **Download Result** - Download merged PDF or copy shareable link

### File Upload Experience

```
[Empty State] → [File Selection] → [Upload Progress] → [File List]
     ↓               ↓                ↓                 ↓
"Drop files here" → Native picker → Progress bars → Reorderable list
```

### Merge Processing Flow

```
[File Validation] → [Quota Check] → [Upload to Cloud] → [Merge Processing] → [Download Ready]
        ↓               ↓               ↓                   ↓                    ↓
   Format/size → Pro plan/quota → Firebase Storage → pdf-merger-js → Signed URL
```

### Error Handling Flows

- **Invalid Files** - Show format/size errors with suggestions
- **Quota Exceeded** - Display upgrade prompt with Pro benefits
- **Processing Failure** - Retry options with error details
- **Network Issues** - Auto-retry with offline detection

## 4. Data & Types

### Core Data Models

#### FileUpload Model

```dart
class FileUpload {
  final String name;
  final int size;
  final String contentType;
  final bool isValid;
  final String? validationError;
  final Uint8List? bytes;

  // Content type inference
  static String inferContentType(String fileName);

  // Validation logic
  bool get isValidFormat => ['pdf', 'png', 'jpg', 'jpeg'].contains(extension);
  bool get isValidSize => size <= (10 * 1024 * 1024); // 10MB free tier
}
```

#### QuotaStatus Model

```dart
class QuotaStatus {
  final int mergesUsed;
  final int mergesRemaining;
  final DateTime resetDate;
  final String planType; // 'free' | 'pro'

  bool get isQuotaExceeded => mergesRemaining <= 0;
  bool get isPro => planType == 'pro';
}
```

#### MergeResult Model

```dart
class MergeResult {
  final String downloadUrl;
  final DateTime expiresAt;
  final int fileSize;
  final int pageCount;
  final String mergeId;
}
```

### API Response Types

#### Firebase Function Responses

```typescript
interface MergePdfsResponse {
  downloadUrl: string;
  expiresAt: Timestamp;
  fileSize: number;
  mergeId: string;
}

interface QuotaStatusResponse {
  mergesUsed: number;
  mergesRemaining: number;
  resetDate: Timestamp;
  planType: "free" | "pro";
}
```

## 5. Integration

### Firebase Integration

- **Functions** - `mergePdfs()` callable for server-side processing
- **Storage** - User-specific file upload and temporary storage
- **Auth** - User authentication and quota tracking
- **Firestore** - Quota status and usage history

### Billing Integration

```dart
// Pro plan verification
final billingService = BillingService();
final planStatus = await billingService.getCurrentPlan();
final isProUser = planStatus.isPro;
```

### ShareBus Integration

```dart
// Share merged PDF with other tools
await ShareBus.instance.shareData(
  type: ShareDataType.pdfDocument,
  data: {
    'url': mergeResult.downloadUrl,
    'fileName': 'merged_document.pdf',
    'source': 'file_merger',
  },
);
```

### Storage Integration

```dart
// Upload manager for file handling
final uploadManager = UploadManager();
final uploadPath = await uploadManager.uploadFile(
  platformFile,
  onProgress: (progress) => updateUI(progress),
);
```

## 6. Billing & Quotas

### Free Tier Limits

- **Monthly Merges**: 3 operations per user per month
- **File Size**: 10 MB maximum per file
- **Files per Merge**: 20 files maximum
- **Download Links**: 7-day validity
- **Supported Formats**: PDF, PNG, JPG, JPEG

### Pro Tier Benefits

- **Unlimited Merges**: No monthly limits
- **Large Files**: 50 MB per file
- **Batch Processing**: 100 files per merge
- **Extended Links**: 30-day validity
- **Priority Processing**: Jump ahead in queue
- **Advanced Formats**: TIFF, BMP support

### Quota Enforcement

```typescript
// Server-side quota checking
export async function incrementQuota(userId: string): Promise<void> {
  const quotaDoc = await db.collection("user_quotas").doc(userId).get();
  const quota = quotaDoc.data() as QuotaStatus;

  if (quota.mergesRemaining <= 0) {
    throw new functions.https.HttpsError(
      "resource-exhausted",
      "Monthly merge quota exceeded. Upgrade to Pro for unlimited merges."
    );
  }

  // Increment usage counter
  await quotaDoc.ref.update({
    mergesUsed: quota.mergesUsed + 1,
    mergesRemaining: quota.mergesRemaining - 1,
  });
}
```

## 7. Validation & Error Handling

### File Validation

```dart
class FileValidator {
  static const maxFileSizeFree = 10 * 1024 * 1024; // 10MB
  static const maxFileSizePro = 50 * 1024 * 1024; // 50MB
  static const supportedFormats = ['pdf', 'png', 'jpg', 'jpeg'];

  static ValidationResult validateFile(PlatformFile file, bool isPro) {
    // Size validation
    final maxSize = isPro ? maxFileSizePro : maxFileSizeFree;
    if (file.size > maxSize) {
      return ValidationResult.error(
        'File too large. Maximum size: ${_formatBytes(maxSize)}'
      );
    }

    // Format validation
    final extension = file.extension?.toLowerCase();
    if (!supportedFormats.contains(extension)) {
      return ValidationResult.error(
        'Unsupported format. Supported: ${supportedFormats.join(", ")}'
      );
    }

    return ValidationResult.success();
  }
}
```

### Error Types & Messages

- **`quota-exceeded`** - "Monthly merge quota exceeded. Upgrade to Pro for unlimited merges."
- **`file-too-large`** - "File exceeds 10 MB limit. Compress file or upgrade to Pro for 50 MB limit."
- **`invalid-format`** - "Unsupported file format. Please use PDF, PNG, or JPG files."
- **`processing-failed`** - "Failed to merge files. Please try again or contact support."
- **`upload-failed`** - "File upload failed. Check your connection and try again."

### Recovery Patterns

```dart
class ErrorRecovery {
  static void handleMergeError(FirebaseFunctionsException error) {
    switch (error.code) {
      case 'quota-exceeded':
        showUpgradeDialog();
        break;
      case 'file-too-large':
        showCompressionSuggestions();
        break;
      case 'invalid-format':
        showFormatConversionTips();
        break;
      default:
        showGenericRetryDialog();
    }
  }
}
```

## 8. Accessibility

### Keyboard Navigation

- **Tab Order** - Logical flow through upload zone, file list, merge button
- **Focus Management** - Clear focus indicators and proper focus trapping
- **Keyboard Shortcuts** - Space/Enter for file selection, Delete for removal
- **Skip Links** - Quick navigation for screen reader users

### Screen Reader Support

- **ARIA Labels** - Comprehensive labeling for all interactive elements
- **Live Regions** - Dynamic announcements for progress updates
- **Semantic Markup** - Proper heading hierarchy and landmark regions
- **Status Updates** - Announced progress changes and completion states

### Visual Accessibility

- **High Contrast** - Strong color contrast meeting WCAG AA standards
- **Scalable Text** - Support for 200% zoom without horizontal scrolling
- **Color Independence** - No color-only information conveyance
- **Focus Indicators** - Clear visual focus states for all controls

### Mobile Accessibility

- **Touch Targets** - Minimum 44px touch targets for all controls
- **Gesture Support** - Swipe-to-delete and long-press-to-reorder
- **Voice Control** - Compatibility with device voice navigation
- **Motor Assistance** - Single-handed operation support

## 9. Test Plan (Manual)

### Core Functionality Tests

1. **File Upload Validation**

   - Upload supported formats (PDF, PNG, JPG)
   - Test file size limits (10MB free, 50MB Pro)
   - Verify unsupported format rejection
   - Test batch file selection

2. **Merge Operation Testing**

   - Single PDF merge (2 files)
   - Mixed format merge (PDF + images)
   - Large batch merge (10+ files)
   - Progress tracking verification

3. **Quota System Testing**
   - Free tier: Verify 3-merge limit
   - Quota exceeded state handling
   - Pro plan unlimited access
   - Monthly quota reset verification

### Error Scenario Testing

1. **File Validation Errors**

   - Oversized file handling
   - Unsupported format rejection
   - Corrupted file detection
   - Empty file handling

2. **Network Error Testing**

   - Upload interruption recovery
   - Processing timeout handling
   - Connection loss scenarios
   - Retry mechanism verification

3. **Quota Limit Testing**
   - Free tier quota exhaustion
   - Upgrade flow from quota exceeded
   - Pro plan verification
   - Usage tracking accuracy

### User Experience Testing

1. **Interface Interaction**

   - Drag-and-drop functionality
   - File reordering accuracy
   - Remove file operations
   - Progress indicator clarity

2. **Cross-Device Testing**

   - Desktop browser compatibility
   - Mobile responsiveness
   - Tablet optimization
   - Touch interaction quality

3. **Accessibility Verification**
   - Screen reader navigation
   - Keyboard-only operation
   - High contrast mode
   - Voice control compatibility

## 10. Automation Hooks

### ShareBus Integration

```dart
// Listen for PDFs from other tools
ShareBus.instance.listen<List<ShareData>>(
  type: ShareDataType.fileList,
  callback: (files) {
    final pdfFiles = files.where((f) => f.isPDF).toList();
    if (pdfFiles.isNotEmpty) {
      _showImportDialog(pdfFiles);
    }
  },
);
```

### Webhook Support (Pro)

```typescript
// Webhook notifications for completed merges
interface WebhookPayload {
  eventType: "merge_completed" | "merge_failed";
  userId: string;
  mergeId: string;
  downloadUrl?: string;
  errorMessage?: string;
  timestamp: string;
}
```

### API Integration (Future)

```typescript
// RESTful API for programmatic access
POST /api/v1/merge
{
  "files": ["file1.pdf", "file2.png"],
  "options": {
    "outputName": "merged_document.pdf",
    "quality": "high",
    "webhookUrl": "https://example.com/webhook"
  }
}
```

### Automation Triggers

- **Batch Processing** - Scheduled merge operations
- **File Monitoring** - Auto-merge when files added to folder
- **Workflow Integration** - Connect with document management systems
- **Email Notifications** - Completion alerts and download links

## 11. Release Notes

### v1.0 (October 6, 2025) - Production Launch

- ✅ Multi-format PDF merging (PDF, PNG, JPG, JPEG)
- ✅ Drag-and-drop file management interface
- ✅ Real-time progress tracking
- ✅ Pro plan quota system (3 free merges/month)
- ✅ Secure cloud processing with automatic cleanup
- ✅ Responsive design with mobile optimization
- ✅ Comprehensive error handling and validation
- ✅ Accessibility compliance (WCAG 2.1 AA)

### v1.1 (Q1 2026) - Pro Plan Enhancement

- 🔄 Complete Stripe payment integration
- 🔄 50MB file size limit for Pro users
- 🔄 100 files per merge operation (Pro)
- 🔄 Priority processing queue for Pro users
- 🔄 Extended download links (30 days Pro vs 7 days free)
- 🔄 TIFF and BMP format support (Pro only)

### v1.2 (Q2 2026) - Advanced Features

- 📋 Batch processing for multiple merge operations
- 📋 ZIP file input and output support
- 📋 Custom page range selection from PDFs
- 📋 Bookmark and metadata preservation
- 📋 API access for programmatic integration

### v1.3 (Q3 2026) - Enterprise Features

- 📋 Team management and role-based access
- 📋 SSO integration for enterprise customers
- 📋 White-label customization options
- 📋 Advanced analytics and usage reporting
- 📋 SLA guarantees and priority support

---

**Last Updated**: December 29, 2024  
**Next Review**: January 15, 2025  
**Document Version**: 1.0
