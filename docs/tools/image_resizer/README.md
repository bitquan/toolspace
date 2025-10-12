# Image Resizer

**Route:** `/tools/image-resizer`  
**Category:** Heavy  
**Billing:** Pro  
**Status:** ✅ Production Ready  
**Heavy Op:** Image Processing  
**Owner Code:** `lib/tools/image_resizer/image_resizer_screen.dart`

## 1. Overview

Image Resizer is a professional-grade batch image processing tool that provides intelligent resizing, format conversion, and optimization for multiple images simultaneously. It targets web developers, content creators, photographers, and businesses needing efficient image processing workflows for responsive web design, social media optimization, and digital asset management.

**Problem it solves:** Eliminates the need for expensive desktop image editing software or time-consuming manual processing by providing cloud-based batch image resizing with preset configurations, custom dimensions, and automatic format optimization.

**Target users:**

- Web developers creating responsive image sets and optimizing site performance
- Content creators preparing images for social media platforms and marketing materials
- Photographers generating thumbnails, previews, and web-optimized versions
- E-commerce businesses creating product images in multiple sizes for catalogs

**Typical inputs:** High-resolution images (PNG, JPG, JPEG, WebP, GIF, BMP), batch collections up to 10 files
**Typical outputs:** Resized images with preserved aspect ratios, optimized file sizes, converted formats (JPG, PNG, WebP)

## 2. Features

### Batch Processing Operations

- **Multi-File Upload** - Process up to 10 images simultaneously with progress tracking
- **Preset Size Configurations** - Thumbnail (150×150), Small (640×480), Medium (1280×720), Large (1920×1080)
- **Custom Dimensions** - User-defined width and/or height with intelligent aspect ratio preservation
- **Format Conversion** - Convert between JPG, PNG, and WebP with quality optimization
- **Progressive Processing** - Real-time progress indicators with individual file status

### Advanced Image Processing

- **Smart Resizing** - Sharp library integration for high-quality results without artifacts
- **Aspect Ratio Preservation** - Automatic letterboxing and intelligent fitting
- **No Upscaling** - Prevents quality degradation by avoiding enlargement of smaller images
- **Quality Optimization** - 90% quality setting for balanced file size and visual fidelity
- **Memory Efficient** - Streaming processing for large files without memory overflow

### Professional Features

- **Secure Processing** - User-isolated storage paths with automatic cleanup
- **Download Management** - Individual download links with 7-day validity
- **Progress Tracking** - Real-time upload and processing status with estimated completion
- **Error Recovery** - Comprehensive validation and graceful error handling
- **Mobile Optimization** - Responsive interface optimized for touch devices

## 3. UX Flow

### Primary Workflow

1. **Tool Access** - Navigate from home grid (`image-resizer` card) or direct route
2. **Image Selection** - Upload via drag-and-drop or file picker (max 10 files, 20MB each)
3. **Settings Configuration** - Choose preset sizes or set custom dimensions and output format
4. **Processing Initiation** - Click "Resize Images" to start batch processing
5. **Progress Monitoring** - Watch real-time upload and processing progress
6. **Result Download** - Download individual resized images with metadata display

### Image Upload Experience

```
[Upload Zone] → [File Validation] → [Image Preview] → [Settings Panel]
     ↓              ↓                 ↓                ↓
Drop/Browse → Size/Format Check → Thumbnail Grid → Resize Config
```

### Batch Processing Flow

```
[Upload Complete] → [Settings Apply] → [Cloud Processing] → [Download Ready]
        ↓                ↓                  ↓                 ↓
   Files Staged → Sharp Processing → Individual Results → Download Links
```

### Error Handling Flows

- **Invalid Files** - Format/size validation with specific error messages
- **Oversized Batches** - Clear limits communication with Pro upgrade suggestions
- **Processing Failures** - Retry mechanisms with error details and recovery options
- **Network Issues** - Auto-retry with offline detection and queue management

## 4. Data & Types

### Core Data Models

#### ImageUpload Model

```dart
class ImageUpload {
  final String name;
  final Uint8List bytes;
  final String contentType;
  final bool isValid;
  final String? validationError;

  // Size validation
  bool get isValidSize => bytes.length <= (20 * 1024 * 1024); // 20MB

  // Format validation
  static const supportedFormats = ['png', 'jpg', 'jpeg', 'webp', 'gif', 'bmp'];
  bool get isValidFormat => supportedFormats.contains(extension.toLowerCase());
}
```

#### ResizedImage Model

```dart
class ResizedImage {
  final String originalName;
  final String downloadUrl;
  final int size;
  final ImageDimensions dimensions;
  final String format;
  final DateTime expiresAt;
}

class ImageDimensions {
  final int width;
  final int height;

  double get aspectRatio => width / height;
  String get displayString => '${width}×${height}';
}
```

#### ResizeSettings Model

```dart
class ResizeSettings {
  final String preset; // 'thumbnail' | 'small' | 'medium' | 'large' | 'custom'
  final int? customWidth;
  final int? customHeight;
  final String outputFormat; // 'jpeg' | 'png' | 'webp'

  bool get isCustom => preset == 'custom';
  bool get hasValidDimensions =>
    (customWidth != null && customWidth! >= 1 && customWidth! <= 10000) ||
    (customHeight != null && customHeight! >= 1 && customHeight! <= 10000);
}
```

### API Response Types

#### ResizeImages Function Response

```typescript
interface ResizeResponse {
  success: boolean;
  results: ResizeResult[];
  totalFiles: number;
  processingTime: number;
}

interface ResizeResult {
  originalName: string;
  downloadUrl: string;
  size: number;
  dimensions: { width: number; height: number };
  format: string;
}
```

#### Preset Configurations

```typescript
const PRESET_SIZES = {
  thumbnail: { width: 150, height: 150 }, // Square thumbnails
  small: { width: 640, height: 480 }, // SD resolution
  medium: { width: 1280, height: 720 }, // HD resolution
  large: { width: 1920, height: 1080 }, // Full HD resolution
};
```

## 5. Integration

### Firebase Functions Integration

```dart
// Cloud function call for batch processing
final resizeRequest = {
  'files': uploadedFilePaths,
  'format': _selectedFormat,
};

// Add dimensions based on settings
if (_selectedPreset != 'custom') {
  resizeRequest['preset'] = _selectedPreset;
} else {
  if (_customWidth != null) resizeRequest['customWidth'] = _customWidth!;
  if (_customHeight != null) resizeRequest['customHeight'] = _customHeight!;
}

final result = await _functions.httpsCallable('resizeImages').call(resizeRequest);
```

### Upload Manager Integration

```dart
class UploadManager {
  Future<List<String>> uploadMultipleFiles(List<ImageUpload> images) async {
    final uploadTasks = images.map((image) =>
      _uploadSingleImage(image, onProgress: _updateProgress)
    ).toList();

    return await Future.wait(uploadTasks);
  }
}
```

### Billing Service Integration

```dart
// Pro plan validation for batch processing
final permission = ToolPermission(
  toolId: 'image_resizer',
  requiresHeavyOp: true,
  fileSize: maxFileBytes,
  batchSize: _images.length,
);

return PaywallGuard(
  billingService: _billingService,
  permission: permission,
  child: ImageResizerInterface(),
);
```

### ShareBus Integration

```dart
// Share processed images with other tools
await ShareBus.instance.shareData(
  type: ShareDataType.imageCollection,
  data: {
    'images': resizedResults.map((img) => {
      'url': img.downloadUrl,
      'dimensions': img.dimensions,
      'format': img.format,
    }).toList(),
    'source': 'image_resizer',
  },
);
```

## 6. Billing & Quotas

### Pro Plan Requirements

Image Resizer is exclusively available to Pro plan subscribers, providing professional-grade image processing capabilities as a premium service differentiator.

### Processing Limits

- **Batch Size**: 10 images maximum per operation
- **File Size**: 20 MB maximum per individual image
- **Dimensions**: 1-10,000 pixels for custom width/height
- **Concurrent Operations**: Pro users can run multiple resize operations simultaneously
- **Download Validity**: 7-day signed URL expiration for processed images

### Resource Allocation

```typescript
const PRO_TIER_LIMITS = {
  MAX_BATCH_SIZE: 10,
  MAX_FILE_SIZE_MB: 20,
  MAX_DIMENSION_PX: 10000,
  MIN_DIMENSION_PX: 1,
  CONCURRENT_OPERATIONS: 3,
  DOWNLOAD_VALIDITY_DAYS: 7,
  SUPPORTED_FORMATS: ["png", "jpg", "jpeg", "webp", "gif", "bmp"],
  OUTPUT_FORMATS: ["jpeg", "png", "webp"],
};
```

### Usage Tracking

```dart
// Pro plan feature usage analytics
class ResizeUsageTracker {
  static Future<void> trackBatchResize({
    required int fileCount,
    required int totalSizeBytes,
    required String outputFormat,
    required Duration processingTime,
  }) async {
    await Analytics.track('image_resize_batch', {
      'file_count': fileCount,
      'total_size_mb': totalSizeBytes / (1024 * 1024),
      'output_format': outputFormat,
      'processing_time_ms': processingTime.inMilliseconds,
      'user_tier': 'pro',
    });
  }
}
```

## 7. Validation & Error Handling

### File Validation

```dart
class ImageFileValidator {
  static const maxFileSize = 20 * 1024 * 1024; // 20MB
  static const maxBatchSize = 10;
  static const supportedFormats = ['png', 'jpg', 'jpeg', 'webp', 'gif', 'bmp'];

  static ValidationResult validateBatch(List<PlatformFile> files) {
    if (files.length > maxBatchSize) {
      return ValidationResult.error(
        'Maximum $maxBatchSize images allowed per batch'
      );
    }

    for (final file in files) {
      final sizeValidation = _validateFileSize(file);
      if (!sizeValidation.isValid) return sizeValidation;

      final formatValidation = _validateFileFormat(file);
      if (!formatValidation.isValid) return formatValidation;
    }

    return ValidationResult.success();
  }
}
```

### Dimension Validation

```dart
class DimensionValidator {
  static const minDimension = 1;
  static const maxDimension = 10000;

  static ValidationResult validateCustomDimensions(int? width, int? height) {
    if (width == null && height == null) {
      return ValidationResult.error('At least width or height must be specified');
    }

    if (width != null && (width < minDimension || width > maxDimension)) {
      return ValidationResult.error(
        'Width must be between $minDimension and $maxDimension pixels'
      );
    }

    if (height != null && (height < minDimension || height > maxDimension)) {
      return ValidationResult.error(
        'Height must be between $minDimension and $maxDimension pixels'
      );
    }

    return ValidationResult.success();
  }
}
```

### Error Types & Recovery

- **`file-too-large`** - "File exceeds 20 MB limit. Compress image or split batch."
- **`invalid-format`** - "Unsupported image format. Use PNG, JPG, WebP, GIF, or BMP."
- **`batch-too-large`** - "Maximum 10 images per batch. Process in smaller batches."
- **`invalid-dimensions`** - "Custom dimensions must be between 1 and 10,000 pixels."
- **`processing-failed`** - "Image processing failed. Verify file integrity and try again."

### Recovery Mechanisms

```dart
class ImageResizerErrorHandler {
  static void handleResizeError(Exception error) {
    if (error is FirebaseFunctionsException) {
      switch (error.code) {
        case 'file-too-large':
          _showFileSizeHelp();
          break;
        case 'batch-too-large':
          _showBatchSizeHelp();
          break;
        case 'invalid-dimensions':
          _showDimensionHelp();
          break;
        default:
          _showGenericRetryDialog();
      }
    }
  }
}
```

## 8. Accessibility

### Keyboard Navigation

- **Upload Zone**: Spacebar/Enter to trigger file picker
- **Image List**: Arrow keys for navigation, Delete key for removal
- **Settings Panel**: Tab navigation through presets and custom inputs
- **Resize Button**: Clear focus indication and keyboard activation

### Screen Reader Support

- **Upload Progress**: Live region announcements for batch upload status
- **Processing Status**: Real-time processing updates with file-specific progress
- **Result Announcements**: Completion notifications with download availability
- **Error Messages**: Clear, actionable error descriptions with recovery guidance

### Visual Accessibility

- **High Contrast**: Strong color differentiation for upload zones and progress indicators
- **Scalable Interface**: Responsive layout supporting 200% zoom without horizontal scrolling
- **Color-Independent Information**: Success/error states communicated through icons and text
- **Motion Sensitivity**: Reduced animation options for vestibular disorder considerations

### Mobile Accessibility

- **Touch Targets**: 44px minimum touch areas for all interactive elements
- **Gesture Support**: Long-press for image removal, swipe for batch management
- **Voice Control**: Compatible with device voice navigation systems
- **Haptic Feedback**: Tactile responses for upload completion and error states

## 9. Test Plan (Manual)

### Core Functionality Tests

1. **Single Image Resize**

   - Upload single PNG/JPG image
   - Apply preset size (medium)
   - Verify output dimensions and quality
   - Test download functionality

2. **Batch Processing**

   - Upload 10 different format images
   - Apply custom dimensions (800×600)
   - Monitor progress accuracy
   - Verify all outputs download correctly

3. **Format Conversion**
   - Upload PNG with transparency
   - Convert to JPG format
   - Verify transparency handling
   - Test WebP output quality

### Validation Testing

1. **File Size Limits**

   - Attempt upload of 25MB image
   - Verify rejection with helpful error
   - Test batch with mixed valid/invalid sizes
   - Confirm partial processing behavior

2. **Batch Size Limits**

   - Attempt upload of 15 images
   - Verify 10-image limit enforcement
   - Test progressive batch building
   - Confirm clear limit communication

3. **Dimension Validation**
   - Test custom width of 15,000 pixels
   - Verify dimension limit errors
   - Test edge cases (1px, 10,000px)
   - Confirm aspect ratio preservation

### User Experience Testing

1. **Upload Interface**

   - Test drag-and-drop functionality
   - Verify file picker integration
   - Test progress indicator accuracy
   - Validate error state display

2. **Settings Configuration**

   - Test preset selection
   - Verify custom dimension inputs
   - Test format selection
   - Confirm setting persistence

3. **Results Management**
   - Test individual downloads
   - Verify metadata display
   - Test batch completion notification
   - Confirm download link expiration

### Performance Testing

1. **Large File Handling**

   - Process 10x 20MB images
   - Monitor memory usage
   - Verify processing speed
   - Test timeout handling

2. **Concurrent Operations**
   - Start multiple resize operations
   - Verify resource allocation
   - Test queue management
   - Confirm completion order

## 10. Automation Hooks

### ShareBus Integration

```dart
// Listen for images from other tools
ShareBus.instance.listen<List<ShareData>>(
  type: ShareDataType.imageCollection,
  callback: (images) {
    final validImages = images.where((img) => img.isImageType).toList();
    if (validImages.isNotEmpty) {
      _showImportDialog(validImages);
    }
  },
);
```

### Batch Processing Automation

```dart
// Automated preset application
class BatchProcessor {
  static Future<void> processWithPreset({
    required List<ImageUpload> images,
    required String preset,
    required String format,
  }) async {
    final settings = ResizeSettings(
      preset: preset,
      outputFormat: format,
    );

    await _processBatch(images, settings);
  }
}
```

### Webhook Integration (Future)

```typescript
// Webhook notifications for completed batches
interface ImageResizeWebhookPayload {
  eventType: "batch_completed" | "batch_failed";
  userId: string;
  batchId: string;
  results?: ResizeResult[];
  error?: string;
  processingTime: number;
  timestamp: string;
}
```

### API Automation (Future)

```typescript
// RESTful API for programmatic access
POST /api/v1/images/resize
{
  "images": ["image1.jpg", "image2.png"],
  "settings": {
    "preset": "medium",
    "format": "webp"
  },
  "webhookUrl": "https://example.com/webhook"
}
```

## 11. Release Notes

### v1.0 (January 6, 2025) - Production Launch

- ✅ Batch image processing (up to 10 images, 20MB each)
- ✅ Preset size configurations (thumbnail, small, medium, large)
- ✅ Custom dimension support with aspect ratio preservation
- ✅ Format conversion (JPG, PNG, WebP) with quality optimization
- ✅ Sharp library integration for high-performance processing
- ✅ Pro plan integration with PaywallGuard protection
- ✅ Responsive design with mobile touch optimization
- ✅ Comprehensive error handling and validation
- ✅ Real-time progress tracking and status updates

### v1.1 (Q2 2025) - Feature Enhancement

- 🔄 ZIP download for batch results
- 🔄 Image rotation options (90°, 180°, 270°)
- 🔄 Quality adjustment slider for fine-tuned control
- 🔄 Advanced format support (TIFF, AVIF)
- 🔄 Watermark overlay functionality
- 🔄 Batch rename with templates

### v1.2 (Q3 2025) - Advanced Processing

- 📋 Image cropping interface with selection tools
- 📋 Automatic optimization algorithms
- 📋 Smart cropping with AI-powered focal point detection
- 📋 Background removal for product images
- 📋 Color palette extraction and adjustment
- 📋 Metadata preservation and editing

### v1.3 (Q4 2025) - Professional Features

- 📋 Template-based processing workflows
- 📋 REST API for developer integration
- 📋 Webhook support for automated workflows
- 📋 Advanced analytics and usage reporting
- 📋 Team collaboration features
- 📋 Enterprise-grade security and compliance

### v2.0 (2026) - AI-Powered Enhancement

- 📋 AI-powered image enhancement and noise reduction
- 📋 Intelligent format recommendations based on content
- 📋 Automatic SEO optimization for web images
- 📋 Advanced compression algorithms with ML
- 📋 Content-aware resizing with smart cropping
- 📋 Batch processing with machine learning optimization

---

**Last Updated**: December 29, 2024  
**Next Review**: January 15, 2025  
**Document Version**: 1.0
