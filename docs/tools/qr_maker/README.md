# QR Maker - Instant QR Code Generation

**Tool ID:** `qr_maker`  
**Route:** `/tools/qr-maker`  
**Category:** Generation Tools  
**Billing:** (Free | Pro | Pro+) - Core features free, advanced features Pro-gated  
**Heavy Op:** Batch QR generation (Pro feature)  
**Owner Code:** `lib/tools/qr_maker/qr_maker_screen.dart`  
**Dependencies:** `qr_flutter: ^4.1.0`, ShareBus, BillingService

## 1. Overview

QR Maker provides instant QR code generation with extensive customization options and batch processing capabilities. Users can create QR codes for text, URLs, emails, phone numbers, WiFi credentials, and more with real-time preview and download functionality.

**Core Capabilities:**

- **6 QR Code Types** - Text, URL, email, phone, SMS, WiFi
- **Visual Customization** - Size, colors, foreground/background control
- **Batch Generation** - Create multiple QR codes from lists (Pro feature)
- **Real-time Preview** - Live QR code preview as you type
- **Cross-Tool Sharing** - Import/export data with other Toolspace tools
- **Download Options** - Save as PNG images with custom names

**Use Cases:**

- Business cards and contact sharing
- Website and social media links
- WiFi password sharing
- Event tickets and check-ins
- Product labeling and inventory
- Marketing campaigns and promotions

## 2. Features

### 2.1 Core QR Generation (Free)

#### Six QR Code Types

- **Text QR Codes** - Any plain text up to 2,953 characters
- **URL QR Codes** - Web URLs with automatic http:// prepending
- **Email QR Codes** - Email addresses with optional subject and body
- **Phone QR Codes** - Phone numbers with country code support
- **SMS QR Codes** - Phone number and pre-filled message
- **WiFi QR Codes** - Network credentials (SSID, password, security type)

#### Real-Time Customization

- **Size Control** - Adjustable from 100px to 500px
- **Color Customization** - Full foreground and background color control
- **Live Preview** - QR code updates instantly as user types
- **Bounce Animation** - Visual feedback when QR data changes

#### Download & Sharing

- **PNG Export** - High-resolution image download
- **Clipboard Copy** - One-click copying to clipboard
- **Cross-Tool Sharing** - ShareBus integration for data transfer

### 2.2 Advanced Features (Pro)

#### Batch QR Generation

- **Bulk Processing** - Generate up to 100 QR codes at once
- **Progress Tracking** - Visual progress bar with count updates
- **ZIP Export** - Organized download with custom naming
- **Error Handling** - Skip invalid entries with detailed error reporting

#### Enhanced Customization

- **Logo Embedding** - Add custom logos to QR code centers (Pro+ feature)
- **Error Correction Levels** - Choose L, M, Q, H error correction
- **Advanced Patterns** - Custom module shapes and styles
- **Border Controls** - Adjust quiet zones and margins

### 2.3 Pro+ Business Features

#### High-Volume Processing

- **500 QR Batch Limit** - Large-scale QR generation
- **API Integration** - Connect with external systems
- **Webhook Support** - Automated QR generation triggers
- **Usage Analytics** - Detailed statistics and performance metrics

## 3. UX Flow

### 3.1 Single QR Generation Flow

```
1. User selects QR type from dropdown (Text, URL, Email, Phone, SMS, WiFi)
   ↓
2. Dynamic form appears with relevant input fields
   ↓
3. User enters content (text, URL, email, etc.)
   ↓
4. QR code appears instantly in preview area with bounce animation
   ↓
5. User adjusts size and colors using sliders and color pickers
   ↓
6. Live preview updates with each change
   ↓
7. User downloads PNG or copies to clipboard
   ↓
8. Optional: Share QR data to other Toolspace tools
```

### 3.2 Batch QR Generation Flow (Pro)

```
1. User switches to "Batch QR" tab
   ↓
2. PaywallGuard checks Pro subscription status
   ↓
3. User pastes or types multiple items (one per line)
   ↓
4. Live count shows number of items detected
   ↓
5. User clicks "Generate Batch" button
   ↓
6. Progress bar shows generation status
   ↓
7. Results summary displays successful/failed counts
   ↓
8. ZIP file download with organized QR images
```

### 3.3 Cross-Tool Integration Flow

```
1. User works in Text Tools to process content
   ↓
2. Clicks "Share" button to send data via ShareBus
   ↓
3. Navigates to QR Maker
   ↓
4. QR Maker auto-detects shared data and pre-fills form
   ↓
5. QR type auto-selected based on content type
   ↓
6. User customizes and generates QR code
   ↓
7. Shares QR image to File Merger for document inclusion
```

## 4. Data & Types

### 4.1 QR Data Formats

#### Text QR Data

```dart
class TextQrData {
  final String content;
  final int maxLength = 2953; // QR code character limit

  String get qrData => content;

  bool get isValid => content.isNotEmpty && content.length <= maxLength;
}
```

#### URL QR Data

```dart
class UrlQrData {
  final String url;

  String get qrData {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    return 'https://$url';
  }

  bool get isValid => _isValidUrl(url);
}
```

#### Email QR Data

```dart
class EmailQrData {
  final String email;
  final String? subject;
  final String? body;

  String get qrData {
    String mailto = 'mailto:$email';
    List<String> params = [];

    if (subject?.isNotEmpty == true) {
      params.add('subject=${Uri.encodeComponent(subject!)}');
    }
    if (body?.isNotEmpty == true) {
      params.add('body=${Uri.encodeComponent(body!)}');
    }

    if (params.isNotEmpty) {
      mailto += '?${params.join('&')}';
    }

    return mailto;
  }
}
```

#### WiFi QR Data

```dart
class WifiQrData {
  final String ssid;
  final String password;
  final String security; // WPA, WEP, or nopass
  final bool hidden;

  String get qrData {
    return 'WIFI:T:$security;S:$ssid;P:$password;H:$hidden;;';
  }

  bool get isValid => ssid.isNotEmpty;
}
```

### 4.2 QR Generation Models

#### QR Generation Request

```dart
class QrGenerationRequest {
  final QrType type;
  final String content;
  final int size;
  final Color foregroundColor;
  final Color backgroundColor;
  final QrErrorCorrection errorCorrection;

  const QrGenerationRequest({
    required this.type,
    required this.content,
    this.size = 200,
    this.foregroundColor = Colors.black,
    this.backgroundColor = Colors.white,
    this.errorCorrection = QrErrorCorrection.medium,
  });
}
```

#### QR Generation Result

```dart
class QrGenerationResult {
  final bool success;
  final String? qrData;
  final Uint8List? imageData;
  final String? error;
  final Duration generationTime;
  final int? imageSizeBytes;
  final Map<String, dynamic> metadata;

  const QrGenerationResult({
    required this.success,
    this.qrData,
    this.imageData,
    this.error,
    required this.generationTime,
    this.imageSizeBytes,
    this.metadata = const {},
  });
}
```

### 4.3 Batch Processing Models

#### Batch QR Request

```dart
class BatchQrRequest {
  final List<String> items;
  final QrType qrType;
  final QrGenerationSettings settings;
  final String? customPrefix;

  const BatchQrRequest({
    required this.items,
    required this.qrType,
    required this.settings,
    this.customPrefix,
  });

  bool get isValid => items.isNotEmpty && items.length <= maxBatchSize;
  int get maxBatchSize => BillingService.instance.getMaxBatchSize();
}
```

#### Batch QR Result

```dart
class BatchQrResult {
  final int totalItems;
  final int successfulItems;
  final int failedItems;
  final List<QrGenerationResult> results;
  final List<BatchError> errors;
  final Duration totalTime;
  final String zipFilePath;

  double get successRate => successfulItems / totalItems;
  bool get hasErrors => errors.isNotEmpty;
}
```

## 5. Integration

### 5.1 ShareBus Data Flow

#### Incoming Data Handling

```dart
class QrMakerDataHandler implements ShareBusConsumer {
  @override
  bool canHandle(SharedData data) {
    return [
      SharedDataType.text,
      SharedDataType.url,
      SharedDataType.email,
      SharedDataType.phone,
      SharedDataType.list,
      SharedDataType.json,
    ].contains(data.type);
  }

  @override
  Future<void> handleSharedData(SharedData data) async {
    switch (data.type) {
      case SharedDataType.text:
        await _handleTextData(data);
        break;
      case SharedDataType.url:
        await _handleUrlData(data);
        break;
      case SharedDataType.list:
        await _handleBatchData(data);
        break;
    }
  }
}
```

#### Outgoing Data Sharing

```dart
void shareQrData(QrGenerationResult result) {
  final shareData = SharedData(
    type: _mapQrTypeToShareType(result.qrType),
    content: result.qrData!,
    metadata: {
      'qr_type': result.qrType.toString(),
      'size': result.size,
      'colors': {
        'foreground': result.foregroundColor.value,
        'background': result.backgroundColor.value,
      },
    },
    source: 'qr_maker',
    timestamp: DateTime.now(),
  );

  ShareBus.instance.shareData(shareData);
}

void shareQrImage(QrGenerationResult result) {
  final imageShare = SharedData(
    type: SharedDataType.image,
    content: base64Encode(result.imageData!),
    metadata: {
      'format': 'png',
      'width': result.size,
      'height': result.size,
      'qr_data': result.qrData,
    },
    source: 'qr_maker',
    timestamp: DateTime.now(),
  );

  ShareBus.instance.shareData(imageShare);
}
```

### 5.2 Tool Integration Examples

#### Text Tools Integration

- **Receive:** Processed text from Text Tools cleaning operations
- **Auto-Detection:** Automatically detect URLs, emails, phone numbers in text
- **Share Back:** Send QR data as text for further processing

#### JSON Doctor Integration

- **Receive:** Formatted JSON data for encoding in QR codes
- **API Endpoint QRs:** Generate QR codes for API documentation
- **Share Back:** Send QR data as JSON for API testing

#### File Merger Integration

- **Receive:** Document metadata for QR generation
- **Share Images:** Send QR images for document inclusion
- **Batch Processing:** Generate multiple QRs for document series

#### Invoice Lite Integration

- **Payment QRs:** Generate payment link QR codes
- **Invoice Details:** Create QR codes with invoice information
- **Business Cards:** Generate contact QR codes for invoices

## 6. Billing & Quotas

### 6.1 Free Tier Limitations

#### Core Features (Unlimited)

- **Single QR Generation** - Unlimited individual QR codes
- **All QR Types** - Access to all 6 QR code types
- **Basic Customization** - Size and color controls
- **Standard Download** - PNG image export
- **Cross-Tool Sharing** - ShareBus integration

#### No Usage Tracking Required

```dart
// Free features require no billing checks
Future<void> generateSingleQr(QrGenerationRequest request) async {
  // No billing validation needed for core features
  final result = await QrGenerator.generate(request);
  _displayResult(result);
}
```

### 6.2 Pro Tier Features

#### Batch Generation Limits

```dart
Future<void> generateBatchQr(BatchQrRequest request) async {
  // Check Pro access
  final hasAccess = await BillingService.instance.canAccessFeature('batch_qr_generation');
  if (!hasAccess) {
    _showProUpgradeDialog();
    return;
  }

  // Validate batch size for Pro tier
  if (request.items.length > 100) {
    _showBatchSizeError('Pro tier limited to 100 QR codes per batch');
    return;
  }

  // Track usage
  await BillingService.instance.trackUsage('batch_qr_generation', {
    'batch_size': request.items.length,
    'qr_type': request.qrType.toString(),
  });

  // Process batch
  final result = await QrBatchGenerator.generate(request);
  _displayBatchResult(result);
}
```

#### Advanced Customization

```dart
Widget buildAdvancedCustomization() {
  return PaywallGuard(
    feature: 'advanced_qr_customization',
    child: Column(
      children: [
        LogoUploadWidget(),
        ErrorCorrectionSelector(),
        PatternStyleSelector(),
      ],
    ),
    fallback: ProFeatureTeaser(
      featureName: 'Advanced QR Customization',
      benefits: [
        'Logo embedding',
        'Error correction control',
        'Custom patterns',
        'Advanced styling',
      ],
    ),
  );
}
```

### 6.3 Pro+ Tier Features

#### High-Volume Processing

- **Batch Limit:** 500 QR codes per batch (vs 100 for Pro)
- **API Access:** RESTful API for automated QR generation
- **Webhook Integration:** Automated triggers and notifications
- **Advanced Analytics:** Usage statistics and performance metrics

#### Enterprise Features

```dart
Future<void> generateEnterpriseQrBatch(EnterpriseQrRequest request) async {
  final hasProPlus = await BillingService.instance.hasProPlusAccess();
  if (!hasProPlus) {
    _showProPlusUpgradeDialog();
    return;
  }

  // Enterprise-level processing
  final result = await EnterpriseQrProcessor.generate(request);

  // Advanced analytics tracking
  await AnalyticsService.trackEnterpriseUsage({
    'batch_size': request.items.length,
    'processing_time': result.totalTime.inMilliseconds,
    'success_rate': result.successRate,
  });
}
```

### 6.4 Quota Enforcement

#### Usage Tracking

```dart
class QrUsageTracker {
  static const int proMonthlyBatchLimit = 1000; // 1000 batches per month
  static const int proPlusMonthlyBatchLimit = 10000; // 10k batches per month

  Future<bool> canPerformBatch(int batchSize) async {
    final currentUsage = await _getCurrentMonthUsage();
    final userPlan = await BillingService.instance.getCurrentPlan();

    switch (userPlan) {
      case BillingPlan.pro:
        return currentUsage.batchCount < proMonthlyBatchLimit;
      case BillingPlan.proPlus:
        return currentUsage.batchCount < proPlusMonthlyBatchLimit;
      default:
        return false; // Free users can't access batch features
    }
  }

  Future<void> recordBatchUsage(int batchSize) async {
    await FirestoreService.recordUsage('qr_batch_generation', {
      'batch_size': batchSize,
      'timestamp': FieldValue.serverTimestamp(),
      'user_id': AuthService.instance.currentUser?.uid,
    });
  }
}
```

## 7. Validation & Error Handling

### 7.1 Input Validation

#### QR Data Validation

```dart
class QrDataValidator {
  static ValidationResult validateQrData(String data, QrType type) {
    // Check length limits
    if (data.isEmpty) {
      return ValidationResult.error('Content cannot be empty');
    }

    if (data.length > 2953) {
      return ValidationResult.error('Content too long (max 2,953 characters)');
    }

    // Type-specific validation
    switch (type) {
      case QrType.url:
        return _validateUrl(data);
      case QrType.email:
        return _validateEmail(data);
      case QrType.phone:
        return _validatePhone(data);
      case QrType.wifi:
        return _validateWifi(data);
      default:
        return ValidationResult.valid();
    }
  }

  static ValidationResult _validateUrl(String url) {
    try {
      final uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
      if (!uri.hasScheme || !uri.hasAuthority) {
        return ValidationResult.error('Invalid URL format');
      }
      return ValidationResult.valid();
    } catch (e) {
      return ValidationResult.error('Invalid URL: ${e.toString()}');
    }
  }

  static ValidationResult _validateEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return ValidationResult.error('Invalid email format');
    }
    return ValidationResult.valid();
  }

  static ValidationResult _validatePhone(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleanPhone.length < 10 || cleanPhone.length > 15) {
      return ValidationResult.error('Invalid phone number length');
    }
    return ValidationResult.valid();
  }
}
```

### 7.2 QR Generation Error Handling

#### Generation Error Recovery

```dart
class QrGenerationErrorHandler {
  static Future<QrGenerationResult> generateWithErrorRecovery(
    QrGenerationRequest request,
  ) async {
    try {
      // Primary generation attempt
      return await QrGenerator.generate(request);
    } catch (e) {
      // Try error recovery strategies
      return await _attemptErrorRecovery(request, e);
    }
  }

  static Future<QrGenerationResult> _attemptErrorRecovery(
    QrGenerationRequest request,
    dynamic error,
  ) async {
    // Strategy 1: Reduce error correction level
    if (request.errorCorrection != QrErrorCorrection.low) {
      final reducedRequest = request.copyWith(
        errorCorrection: QrErrorCorrection.low,
      );

      try {
        return await QrGenerator.generate(reducedRequest);
      } catch (e) {
        // Continue to next strategy
      }
    }

    // Strategy 2: Reduce content size
    if (request.content.length > 1000) {
      final truncatedRequest = request.copyWith(
        content: request.content.substring(0, 1000) + '...',
      );

      try {
        return await QrGenerator.generate(truncatedRequest);
      } catch (e) {
        // Continue to next strategy
      }
    }

    // Strategy 3: Use minimal settings
    final minimalRequest = request.copyWith(
      size: 200,
      errorCorrection: QrErrorCorrection.low,
      foregroundColor: Colors.black,
      backgroundColor: Colors.white,
    );

    try {
      return await QrGenerator.generate(minimalRequest);
    } catch (e) {
      return QrGenerationResult.failure(
        error: 'QR generation failed after all recovery attempts: ${e.toString()}',
        request: request,
      );
    }
  }
}
```

### 7.3 User Error Feedback

#### Error Message Display

```dart
void showErrorMessage(String error, QrGenerationRequest request) {
  String userFriendlyMessage;
  String? suggestion;

  if (error.contains('too large')) {
    userFriendlyMessage = 'Content is too large for QR code';
    suggestion = 'Try reducing the text length or use a URL shortener';
  } else if (error.contains('invalid')) {
    userFriendlyMessage = 'Invalid content format';
    suggestion = 'Please check your ${request.type.name} format';
  } else {
    userFriendlyMessage = 'QR code generation failed';
    suggestion = 'Please try again or contact support';
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(userFriendlyMessage, style: TextStyle(fontWeight: FontWeight.bold)),
          if (suggestion != null) ...[
            SizedBox(height: 4),
            Text(suggestion, style: TextStyle(fontSize: 12)),
          ],
        ],
      ),
      backgroundColor: Colors.red,
      action: SnackBarAction(
        label: 'Help',
        textColor: Colors.white,
        onPressed: () => _showHelpDialog(request.type),
      ),
      duration: Duration(seconds: 5),
    ),
  );
}
```

## 8. Performance

### 8.1 QR Generation Optimization

#### Debounced Generation

```dart
class DebouncedQrGenerator {
  Timer? _debounceTimer;
  static const Duration debounceDuration = Duration(milliseconds: 300);

  void generateQrDebounced(String content, QrType type) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounceDuration, () {
      _generateQr(content, type);
    });
  }

  void _generateQr(String content, QrType type) {
    final request = QrGenerationRequest(
      type: type,
      content: content,
      size: _qrSize,
      foregroundColor: _foregroundColor,
      backgroundColor: _backgroundColor,
    );

    QrGenerator.generate(request).then((result) {
      if (mounted) {
        setState(() {
          _qrResult = result;
          if (result.success) {
            _triggerBounceAnimation();
          }
        });
      }
    });
  }
}
```

#### Memory Management

```dart
class QrMemoryManager {
  static const int maxCachedQrs = 20;
  static final Map<String, QrGenerationResult> _qrCache = {};

  static String _generateCacheKey(QrGenerationRequest request) {
    return '${request.type}_${request.content.hashCode}_${request.size}_${request.foregroundColor.value}_${request.backgroundColor.value}';
  }

  static QrGenerationResult? getCachedQr(QrGenerationRequest request) {
    final key = _generateCacheKey(request);
    return _qrCache[key];
  }

  static void cacheQr(QrGenerationRequest request, QrGenerationResult result) {
    final key = _generateCacheKey(request);

    if (_qrCache.length >= maxCachedQrs) {
      // Remove oldest entry
      final oldestKey = _qrCache.keys.first;
      _qrCache.remove(oldestKey);
    }

    _qrCache[key] = result;
  }

  static void clearCache() {
    _qrCache.clear();
  }
}
```

### 8.2 Batch Processing Performance

#### Chunked Batch Processing

```dart
class OptimizedBatchProcessor {
  static const int chunkSize = 10;
  static const Duration chunkDelay = Duration(milliseconds: 50);

  Future<BatchQrResult> processBatch(BatchQrRequest request) async {
    final chunks = _createChunks(request.items, chunkSize);
    final results = <QrGenerationResult>[];
    final errors = <BatchError>[];

    for (int i = 0; i < chunks.length; i++) {
      final chunk = chunks[i];

      // Process chunk in parallel
      final chunkResults = await Future.wait(
        chunk.map((item) => _processItem(item, request.qrType, request.settings)),
        eagerError: false,
      );

      results.addAll(chunkResults.where((r) => r.success));
      errors.addAll(chunkResults.where((r) => !r.success).map((r) =>
        BatchError(item: r.request.content, error: r.error!)
      ));

      // Update progress
      _updateProgress(results.length, request.items.length);

      // Brief pause to prevent UI blocking
      if (i < chunks.length - 1) {
        await Future.delayed(chunkDelay);
      }
    }

    return BatchQrResult(
      totalItems: request.items.length,
      successfulItems: results.length,
      failedItems: errors.length,
      results: results,
      errors: errors,
    );
  }

  List<List<String>> _createChunks(List<String> items, int chunkSize) {
    final chunks = <List<String>>[];
    for (int i = 0; i < items.length; i += chunkSize) {
      chunks.add(items.sublist(i, math.min(i + chunkSize, items.length)));
    }
    return chunks;
  }
}
```

## 9. Test Plan (Manual)

### 9.1 Single QR Generation Tests

#### Test Case: Basic Text QR

```
1. Navigate to QR Maker tool
2. Verify "Plain Text" is selected by default
3. Enter "Hello World!" in text field
4. Verify QR code appears immediately
5. Verify QR code bounces when text changes
6. Scan QR code with phone - should read "Hello World!"
7. Download PNG image
8. Verify downloaded image is correct size and content
```

#### Test Case: URL QR with Auto-Protocol

```
1. Select "Website URL" from dropdown
2. Enter "example.com" (without protocol)
3. Verify QR data shows "https://example.com"
4. Scan QR code - should open website
5. Enter "http://test.com" (with protocol)
6. Verify QR data preserves original protocol
```

#### Test Case: WiFi QR

```
1. Select "WiFi Network" from dropdown
2. Fill in SSID: "TestNetwork"
3. Fill in Password: "testpass123"
4. Select Security: "WPA/WPA2"
5. Verify QR code generates correctly
6. Scan with phone - should prompt to join network
```

### 9.2 Customization Tests

#### Test Case: Size Adjustment

```
1. Generate any QR code
2. Adjust size slider from 100px to 500px
3. Verify QR code resizes smoothly
4. Verify size label updates correctly
5. Download at different sizes
6. Verify image file dimensions match selected size
```

#### Test Case: Color Customization

```
1. Generate QR code with default colors (black/white)
2. Change foreground to red
3. Verify QR code updates immediately
4. Change background to blue
5. Verify contrast warning appears if contrast is low
6. Test scanning with custom colors
```

#### Test Case: Contrast Validation

```
1. Set foreground to light gray (#CCCCCC)
2. Set background to white (#FFFFFF)
3. Verify "Low contrast" warning appears
4. Verify warning icon is orange/red
5. Change to high contrast colors
6. Verify "Good contrast" message appears with green icon
```

### 9.3 Batch Processing Tests (Pro Required)

#### Test Case: Batch QR Generation

```
Prerequisites: Pro subscription active

1. Switch to "Batch QR" tab
2. Verify Pro badge is visible
3. Enter 5 URLs (one per line):
   https://example1.com
   https://example2.com
   https://example3.com
   invalid-url
   https://example5.com
4. Verify "5 items" counter appears
5. Click "Generate Batch"
6. Verify progress bar appears and updates
7. Verify completion message shows "4 successful, 1 error"
8. Download ZIP file
9. Verify ZIP contains 4 PNG files with correct names
```

#### Test Case: Batch Size Limits

```
Prerequisites: Pro subscription

1. Enter 101 URLs in batch textarea
2. Verify error message about Pro limit (100 items)
3. Reduce to 100 URLs
4. Verify generation proceeds normally
5. Test with Pro+ account and 500 URLs
6. Verify Pro+ limit enforcement
```

### 9.4 Cross-Tool Integration Tests

#### Test Case: Import from Text Tools

```
1. Open Text Tools in new tab
2. Process text: "Visit our website at https://example.com"
3. Click "Share" button
4. Navigate to QR Maker
5. Verify text is auto-imported
6. Verify "Website URL" type is auto-selected
7. Verify QR code is generated automatically
```

#### Test Case: Share to File Merger

```
1. Generate QR code in QR Maker
2. Click "Share" button
3. Navigate to File Merger
4. Verify QR image is available for import
5. Import QR image into document
6. Verify image maintains quality and scannability
```

### 9.5 Error Handling Tests

#### Test Case: Invalid Email Format

```
1. Select "Email Address" type
2. Enter "invalid-email-format"
3. Verify error message appears
4. Verify error icon shows in input field
5. Correct to "test@example.com"
6. Verify error disappears and QR generates
```

#### Test Case: Content Too Long

```
1. Select "Plain Text" type
2. Paste text longer than 2,953 characters
3. Verify error message about content length
4. Verify character counter shows limit exceeded
5. Reduce text to under limit
6. Verify QR generation resumes
```

#### Test Case: Generation Failure Recovery

```
1. Generate QR with complex content
2. Simulate generation failure (disconnect network if needed)
3. Verify error message displays clearly
4. Verify "Retry" or "Help" options are available
5. Restore connection and retry
6. Verify successful generation
```

### 9.6 Performance Tests

#### Test Case: Large Batch Performance

```
Prerequisites: Pro+ subscription

1. Prepare 500 unique URLs
2. Paste into batch textarea
3. Start batch generation
4. Monitor generation time (should complete within 2 minutes)
5. Verify UI remains responsive during generation
6. Verify progress updates smoothly
7. Verify memory usage doesn't spike excessively
```

#### Test Case: Rapid Input Changes

```
1. Select text QR type
2. Type rapidly in text field
3. Verify QR updates smoothly without lag
4. Verify no visual glitches or flashing
5. Stop typing and verify final QR is correct
6. Test with long text content
7. Verify debouncing prevents excessive generation
```

### 9.7 Mobile/Touch Tests

#### Test Case: Mobile Interface

```
1. Open QR Maker on mobile device
2. Verify all controls are touch-friendly (44px+ touch targets)
3. Test QR type dropdown on mobile
4. Test color pickers with touch
5. Test size slider with touch gestures
6. Verify QR code is clearly visible on small screen
7. Test download functionality on mobile
```

#### Test Case: Orientation Changes

```
1. Open QR Maker in portrait mode
2. Generate QR code
3. Rotate to landscape
4. Verify layout adapts appropriately
5. Verify QR code maintains aspect ratio
6. Verify all controls remain accessible
7. Test input fields after rotation
```

### 9.8 Accessibility Tests

#### Test Case: Keyboard Navigation

```
1. Open QR Maker without mouse
2. Tab through all controls in logical order
3. Verify focus indicators are clearly visible
4. Use keyboard to select QR type
5. Use keyboard to navigate form fields
6. Verify QR generation can be triggered with keyboard
7. Test escape key behaviors
```

#### Test Case: Screen Reader Compatibility

```
1. Enable screen reader (VoiceOver/NVDA)
2. Navigate through interface
3. Verify all controls are announced correctly
4. Verify QR code status is announced
5. Verify error messages are read aloud
6. Test form field labels and hints
7. Verify batch progress is announced
```

## 10. Automation Hooks

### 10.1 API Integration Points

#### QR Generation API

```dart
class QrMakerApi {
  static const String baseUrl = '/api/tools/qr-maker';

  // Generate single QR code
  static Future<QrGenerationResult> generateQr(QrGenerationRequest request) async {
    final response = await http.post(
      Uri.parse('$baseUrl/generate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return QrGenerationResult.fromJson(jsonDecode(response.body));
    } else {
      throw QrGenerationException('API request failed: ${response.statusCode}');
    }
  }

  // Generate batch QR codes
  static Future<BatchQrResult> generateBatch(BatchQrRequest request) async {
    final response = await http.post(
      Uri.parse('$baseUrl/batch'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return BatchQrResult.fromJson(jsonDecode(response.body));
    } else {
      throw QrGenerationException('Batch API request failed: ${response.statusCode}');
    }
  }

  // Get generation status
  static Future<GenerationStatus> getStatus(String jobId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/status/$jobId'),
    );

    return GenerationStatus.fromJson(jsonDecode(response.body));
  }
}
```

### 10.2 Webhook Integration

#### QR Generation Webhooks

```dart
class QrWebhookHandler {
  // Register webhook for batch completion
  static Future<void> registerBatchWebhook(String url, String batchId) async {
    await WebhookService.register(
      event: 'qr_batch_complete',
      url: url,
      data: {'batch_id': batchId},
    );
  }

  // Handle incoming webhook
  static Future<void> handleWebhook(WebhookEvent event) async {
    switch (event.type) {
      case 'qr_batch_complete':
        await _handleBatchComplete(event.data);
        break;
      case 'qr_generation_error':
        await _handleGenerationError(event.data);
        break;
    }
  }

  static Future<void> _handleBatchComplete(Map<String, dynamic> data) async {
    final batchId = data['batch_id'] as String;
    final result = await QrBatchService.getBatchResult(batchId);

    // Notify user or trigger next automation step
    await NotificationService.sendBatchCompleteNotification(result);
  }
}
```

### 10.3 Automation Workflows

#### Automated QR Campaign Generation

```dart
class QrCampaignAutomation {
  // Generate QR codes for marketing campaign
  static Future<CampaignResult> generateCampaignQrs(CampaignData campaign) async {
    final qrTasks = <Future<QrGenerationResult>>[];

    // Generate landing page QRs
    for (final page in campaign.landingPages) {
      qrTasks.add(QrMakerApi.generateQr(QrGenerationRequest(
        type: QrType.url,
        content: page.url,
        size: campaign.qrSize,
        foregroundColor: campaign.brandColor,
        backgroundColor: Colors.white,
      )));
    }

    // Generate contact QRs
    for (final contact in campaign.contacts) {
      qrTasks.add(QrMakerApi.generateQr(QrGenerationRequest(
        type: QrType.email,
        content: contact.email,
        size: campaign.qrSize,
        foregroundColor: campaign.brandColor,
        backgroundColor: Colors.white,
      )));
    }

    final results = await Future.wait(qrTasks);

    return CampaignResult(
      campaignId: campaign.id,
      qrCodes: results,
      generatedAt: DateTime.now(),
    );
  }

  // Automated event QR generation
  static Future<EventQrSuite> generateEventQrs(EventData event) async {
    final tasks = await Future.wait([
      // Event info QR
      QrMakerApi.generateQr(QrGenerationRequest(
        type: QrType.text,
        content: _formatEventInfo(event),
        size: 300,
      )),

      // Registration QR
      QrMakerApi.generateQr(QrGenerationRequest(
        type: QrType.url,
        content: event.registrationUrl,
        size: 300,
      )),

      // WiFi QR
      if (event.wifiCredentials != null)
        QrMakerApi.generateQr(QrGenerationRequest(
          type: QrType.wifi,
          content: _formatWifiData(event.wifiCredentials!),
          size: 300,
        )),
    ]);

    return EventQrSuite(
      eventId: event.id,
      infoQr: tasks[0],
      registrationQr: tasks[1],
      wifiQr: tasks.length > 2 ? tasks[2] : null,
    );
  }
}
```

### 10.4 Integration Testing Automation

#### Automated Cross-Tool Testing

```dart
class QrIntegrationTestSuite {
  // Test data flow from Text Tools
  static Future<void> testTextToolsIntegration() async {
    // Step 1: Simulate Text Tools data sharing
    final textData = SharedData(
      type: SharedDataType.text,
      content: 'Processed text content',
      source: 'text_tools',
    );
    ShareBus.instance.shareData(textData);

    // Step 2: Verify QR Maker receives data
    final qrMaker = QrMakerScreen();
    await tester.pumpWidget(TestApp(child: qrMaker));

    // Verify data import
    expect(find.text('Processed text content'), findsOneWidget);

    // Step 3: Generate QR and verify sharing back
    await tester.tap(find.byIcon(Icons.share));
    final sharedQr = ShareBus.instance.getLastSharedData();
    expect(sharedQr?.source, equals('qr_maker'));
  }

  // Test File Merger image integration
  static Future<void> testFileMergerIntegration() async {
    // Generate QR image
    final qrResult = await QrMakerApi.generateQr(QrGenerationRequest(
      type: QrType.url,
      content: 'https://test.com',
      size: 200,
    ));

    // Share image data
    final imageData = SharedData(
      type: SharedDataType.image,
      content: base64Encode(qrResult.imageData!),
      metadata: {'format': 'png', 'source_tool': 'qr_maker'},
      source: 'qr_maker',
    );
    ShareBus.instance.shareData(imageData);

    // Verify File Merger can import
    final fileMerger = FileMergerScreen();
    // ... test File Merger import logic
  }

  // Performance testing automation
  static Future<void> testBatchPerformance() async {
    final batchSizes = [10, 50, 100, 500];
    final performanceResults = <int, Duration>{};

    for (final size in batchSizes) {
      final items = List.generate(size, (i) => 'https://test$i.com');
      final request = BatchQrRequest(
        items: items,
        qrType: QrType.url,
        settings: QrGenerationSettings.standard(),
      );

      final stopwatch = Stopwatch()..start();
      final result = await QrMakerApi.generateBatch(request);
      stopwatch.stop();

      performanceResults[size] = stopwatch.elapsed;

      // Assert performance requirements
      expect(result.successRate, greaterThan(0.95)); // 95% success rate
      expect(stopwatch.elapsed.inSeconds, lessThan(size ~/ 5)); // 5 QRs per second minimum
    }

    // Log performance metrics
    Logger.logPerformanceMetrics('qr_batch_generation', performanceResults);
  }
}
```

### 10.5 Monitoring and Analytics Hooks

#### Usage Analytics

```dart
class QrAnalyticsHooks {
  // Track QR generation patterns
  static void trackQrGeneration(QrGenerationResult result) {
    AnalyticsService.track('qr_generated', {
      'qr_type': result.qrType.toString(),
      'size': result.size,
      'generation_time_ms': result.generationTime.inMilliseconds,
      'success': result.success,
      'content_length': result.qrData?.length,
      'has_custom_colors': _hasCustomColors(result),
    });
  }

  // Track batch processing metrics
  static void trackBatchGeneration(BatchQrResult result) {
    AnalyticsService.track('qr_batch_generated', {
      'total_items': result.totalItems,
      'successful_items': result.successfulItems,
      'success_rate': result.successRate,
      'total_time_ms': result.totalTime.inMilliseconds,
      'average_time_per_qr_ms': result.totalTime.inMilliseconds / result.totalItems,
    });
  }

  // Monitor error patterns
  static void trackGenerationError(String error, QrGenerationRequest request) {
    AnalyticsService.track('qr_generation_error', {
      'error_type': _categorizeError(error),
      'qr_type': request.type.toString(),
      'content_length': request.content.length,
      'error_message': error,
    });
  }

  // Track cross-tool integration usage
  static void trackCrossToolUsage(String sourceToolX, SharedDataType dataType) {
    AnalyticsService.track('qr_cross_tool_integration', {
      'source_tool': sourceTool,
      'data_type': dataType.toString(),
      'integration_success': true,
    });
  }
}
```

The QR Maker tool provides comprehensive functionality for instant QR code generation with extensive customization, cross-tool integration, and enterprise-grade batch processing capabilities.

## 3. User Interface Design

### 3.1 Layout Architecture

#### Tab-Based Interface

- **Single QR Tab:** Individual QR code generation
- **Batch QR Tab:** Bulk generation (Pro feature)
- **Tab Animation:** Smooth transitions with bounce effects
- **Tab State:** Preserves input data when switching tabs

#### Input Section

- **QR Type Selector:** Dropdown with 6 QR types
- **Dynamic Fields:** Form fields change based on selected type
- **Input Validation:** Real-time validation with error messages
- **Character Counter:** Shows character limits and remaining space

#### Preview Section

- **Live Preview:** QR code updates as user types
- **Size Slider:** Interactive size adjustment with immediate feedback
- **Color Controls:** Color pickers for foreground and background
- **Bounce Animation:** QR code bounces when data changes

### 3.2 Interactive Elements

#### QR Type Selector

```dart
DropdownButtonFormField<QrType>(
  value: _selectedType,
  items: [
    DropdownMenuItem(value: QrType.text, child: Text('📝 Plain Text')),
    DropdownMenuItem(value: QrType.url, child: Text('🌐 Website URL')),
    DropdownMenuItem(value: QrType.email, child: Text('📧 Email Address')),
    DropdownMenuItem(value: QrType.phone, child: Text('📞 Phone Number')),
    DropdownMenuItem(value: QrType.sms, child: Text('💬 SMS Message')),
    DropdownMenuItem(value: QrType.wifi, child: Text('📶 WiFi Network')),
  ],
  onChanged: (QrType? newType) => _onTypeChanged(newType),
)
```

#### Dynamic Input Forms

**Text QR Input:**

```dart
TextFormField(
  controller: _textController,
  decoration: InputDecoration(
    labelText: 'Enter text to encode',
    hintText: 'Hello World!',
    suffixText: '${_textController.text.length}/2953',
  ),
  maxLength: 2953,
  maxLines: 4,
  onChanged: _onTextChanged,
)
```

**WiFi QR Input:**

```dart
Column(
  children: [
    TextFormField(
      decoration: InputDecoration(labelText: 'Network Name (SSID)'),
      onChanged: (value) => _wifiSSID = value,
    ),
    TextFormField(
      decoration: InputDecoration(labelText: 'Password'),
      obscureText: true,
      onChanged: (value) => _wifiPassword = value,
    ),
    DropdownButtonFormField<String>(
      value: _wifiSecurity,
      items: ['WPA', 'WEP', 'None'].map((security) =>
        DropdownMenuItem(value: security, child: Text(security))
      ).toList(),
      onChanged: (value) => _wifiSecurity = value,
    ),
  ],
)
```

#### Size and Color Controls

```dart
Row(
  children: [
    Expanded(
      child: Slider(
        value: _qrSize.toDouble(),
        min: 100,
        max: 500,
        divisions: 40,
        label: '${_qrSize}px',
        onChanged: (double value) => setState(() => _qrSize = value.round()),
      ),
    ),
    ColorPicker(
      color: _foregroundColor,
      onColorChanged: (Color color) => setState(() => _foregroundColor = color),
    ),
    ColorPicker(
      color: _backgroundColor,
      onColorChanged: (Color color) => setState(() => _backgroundColor = color),
    ),
  ],
)
```

### 3.3 QR Code Preview

#### Live QR Generation

```dart
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: _backgroundColor,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 8,
        offset: Offset(0, 4),
      ),
    ],
  ),
  child: AnimatedBuilder(
    animation: _bounceAnimation,
    builder: (context, child) {
      return Transform.scale(
        scale: _bounceAnimation.value,
        child: QrImageView(
          data: _qrData,
          version: QrVersions.auto,
          size: _qrSize.toDouble(),
          foregroundColor: _foregroundColor,
          backgroundColor: _backgroundColor,
          errorStateBuilder: (context, error) => Container(
            width: _qrSize.toDouble(),
            height: _qrSize.toDouble(),
            child: Center(
              child: Text('Invalid QR data', style: TextStyle(color: Colors.red)),
            ),
          ),
        ),
      );
    },
  ),
)
```

#### Animation Controller

```dart
void _onTextChanged() {
  setState(() => _qrData = _buildQrData());

  if (_qrData.isNotEmpty) {
    _bounceController.forward().then((_) => _bounceController.reverse());
  }
}

String _buildQrData() {
  switch (_selectedType) {
    case QrType.text:
      return _textController.text;
    case QrType.url:
      String url = _textController.text.trim();
      if (url.isNotEmpty && !url.startsWith('http')) {
        url = 'https://$url';
      }
      return url;
    case QrType.email:
      return 'mailto:${_textController.text}';
    case QrType.phone:
      return 'tel:${_textController.text}';
    case QrType.sms:
      return 'sms:${_phoneController.text}?body=${_messageController.text}';
    case QrType.wifi:
      return 'WIFI:T:$_wifiSecurity;S:$_wifiSSID;P:$_wifiPassword;H:false;;';
  }
}
```

## 4. Cross-Tool Integration

### 4.1 ShareBus Implementation

#### Data Reception

```dart
@override
void initState() {
  super.initState();

  // Check for incoming shared data
  final sharedData = SharedDataService.instance.getImportedData();
  if (sharedData != null) {
    _handleImportedData(sharedData);
  }
}

void _handleImportedData(SharedData data) {
  switch (data.type) {
    case SharedDataType.text:
      _selectedType = QrType.text;
      _textController.text = data.content;
      break;
    case SharedDataType.url:
      _selectedType = QrType.url;
      _textController.text = data.content;
      break;
    case SharedDataType.email:
      _selectedType = QrType.email;
      _textController.text = data.content;
      break;
    case SharedDataType.phone:
      _selectedType = QrType.phone;
      _textController.text = data.content;
      break;
    case SharedDataType.list:
      _tabController.animateTo(1); // Switch to batch tab
      _batchTextController.text = data.content;
      break;
  }
  setState(() => _onTextChanged());
}
```

#### Data Sharing

```dart
void _shareQrData() {
  final shareData = SharedData(
    type: _getShareDataType(),
    content: _qrData,
    metadata: {
      'qr_type': _selectedType.toString(),
      'size': _qrSize,
      'foreground_color': _foregroundColor.value,
      'background_color': _backgroundColor.value,
    },
    source: 'qr_maker',
    timestamp: DateTime.now(),
  );

  SharedDataService.instance.shareData(shareData);
  _showShareSuccessMessage();
}

SharedDataType _getShareDataType() {
  switch (_selectedType) {
    case QrType.text:
      return SharedDataType.text;
    case QrType.url:
      return SharedDataType.url;
    case QrType.email:
      return SharedDataType.email;
    case QrType.phone:
      return SharedDataType.phone;
    default:
      return SharedDataType.text;
  }
}
```

### 4.2 Import/Export Buttons

#### Import Data Button

```dart
ImportDataButton(
  onDataImported: _handleImportedData,
  supportedTypes: [
    SharedDataType.text,
    SharedDataType.url,
    SharedDataType.email,
    SharedDataType.phone,
    SharedDataType.list,
  ],
  tooltip: 'Import data from other tools',
)
```

#### Share Data Button

```dart
ShareDataButton(
  onPressed: _shareQrData,
  data: SharedData(
    type: _getShareDataType(),
    content: _qrData,
    source: 'qr_maker',
  ),
  tooltip: 'Share QR data with other tools',
)
```

### 4.3 Tool Integration Examples

#### From Text Tools

1. **User Action:** Generate QR code from processed text
2. **Flow:** Text Tools → Share processed text → QR Maker receives text → Auto-generates QR
3. **Use Case:** Clean text formatting, then create QR code for sharing

#### To File Merger

1. **User Action:** Batch generate QRs, merge into document
2. **Flow:** QR Maker batch → Export as images → File Merger imports images
3. **Use Case:** Create event tickets with unique QR codes

#### From JSON Doctor

1. **User Action:** Share formatted JSON as QR code
2. **Flow:** JSON Doctor → Format JSON → Share → QR Maker → Generate QR
3. **Use Case:** Share API endpoints or configuration data

## 5. Billing Integration

### 5.1 Free Tier Features

#### Core QR Generation

- **Single QR Codes:** Unlimited individual QR generation
- **All QR Types:** Access to all 6 QR code types
- **Basic Customization:** Size and color controls
- **Download:** Save individual QR codes as PNG

#### Usage Tracking

```dart
// Free tier has no usage limits for basic QR generation
Future<void> _generateQr() async {
  // No billing check needed - completely free
  setState(() => _qrData = _buildQrData());
}
```

### 5.2 Pro Features (Paywall-Gated)

#### Batch Generation

```dart
Future<void> _generateBatchQrs() async {
  final hasAccess = await _billingService.canAccessFeature('batch_qr_generation');

  if (!hasAccess) {
    _showProUpgradeDialog();
    return;
  }

  await _billingService.trackUsage('batch_qr_generation');
  _processBatchGeneration();
}

void _showProUpgradeDialog() {
  showDialog(
    context: context,
    builder: (context) => UpgradeDialog(
      feature: 'Batch QR Generation',
      description: 'Generate up to 100 QR codes at once',
      benefits: [
        'Bulk QR code creation',
        'ZIP file export',
        'Custom naming',
        'Progress tracking',
      ],
    ),
  );
}
```

#### Advanced Customization

```dart
Widget _buildAdvancedOptions() {
  return PaywallGuard(
    feature: 'advanced_qr_customization',
    child: Column(
      children: [
        _buildLogoUpload(),
        _buildErrorCorrectionSelector(),
        _buildPatternStyleSelector(),
        _buildBorderControls(),
      ],
    ),
    fallback: ProFeatureTeaser(
      featureName: 'Advanced QR Customization',
      description: 'Add logos, adjust error correction, and customize patterns',
    ),
  );
}
```

### 5.3 Pro+ Features

#### High-Volume Batch Processing

- **Batch Size:** Up to 500 QR codes per batch (vs 100 for Pro)
- **API Integration:** Connect with external systems
- **Webhook Support:** Automated QR generation triggers
- **Advanced Analytics:** Usage tracking and statistics

## 6. Error Handling & Validation

### 6.1 Input Validation

#### QR Data Validation

```dart
String? _validateQrData(String data, QrType type) {
  if (data.isEmpty) {
    return 'Content cannot be empty';
  }

  switch (type) {
    case QrType.text:
      if (data.length > 2953) {
        return 'Text too long (max 2,953 characters)';
      }
      break;

    case QrType.url:
      if (!_isValidUrl(data)) {
        return 'Please enter a valid URL';
      }
      break;

    case QrType.email:
      if (!_isValidEmail(data)) {
        return 'Please enter a valid email address';
      }
      break;

    case QrType.phone:
      if (!_isValidPhone(data)) {
        return 'Please enter a valid phone number';
      }
      break;
  }

  return null;
}

bool _isValidUrl(String url) {
  try {
    final uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
    return uri.hasScheme && uri.hasAuthority;
  } catch (e) {
    return false;
  }
}

bool _isValidEmail(String email) {
  return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
}

bool _isValidPhone(String phone) {
  final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
  return cleaned.length >= 10 && cleaned.length <= 15;
}
```

#### Color Contrast Validation

```dart
bool _hasValidContrast(Color foreground, Color background) {
  final fLuminance = foreground.computeLuminance();
  final bLuminance = background.computeLuminance();

  final ratio = (max(fLuminance, bLuminance) + 0.05) /
                (min(fLuminance, bLuminance) + 0.05);

  return ratio >= 3.0; // WCAG AA standard
}

void _validateColors() {
  if (!_hasValidContrast(_foregroundColor, _backgroundColor)) {
    _showColorWarning();
  }
}
```

### 6.2 QR Generation Error Handling

#### QR Library Error Handling

```dart
Widget _buildQrCode() {
  return QrImageView(
    data: _qrData,
    version: QrVersions.auto,
    size: _qrSize.toDouble(),
    foregroundColor: _foregroundColor,
    backgroundColor: _backgroundColor,
    errorStateBuilder: (context, error) {
      return Container(
        width: _qrSize.toDouble(),
        height: _qrSize.toDouble(),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, color: Colors.red, size: 48),
            SizedBox(height: 8),
            Text(
              'QR Generation Failed',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            Text(
              _getErrorMessage(error),
              style: TextStyle(color: Colors.red.shade700, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    },
  );
}

String _getErrorMessage(dynamic error) {
  if (error.toString().contains('too large')) {
    return 'Data too large for QR code';
  } else if (error.toString().contains('invalid')) {
    return 'Invalid characters in data';
  } else {
    return 'Please check your input data';
  }
}
```

#### Batch Processing Error Handling

```dart
Future<void> _processBatchGeneration() async {
  final lines = _batchTextController.text.split('\n')
    .where((line) => line.trim().isNotEmpty)
    .toList();

  setState(() {
    _batchItems = lines;
    _generatedCount = 0;
    _batchErrors.clear();
  });

  for (int i = 0; i < lines.length; i++) {
    try {
      final qrData = _buildQrDataForBatch(lines[i], i);
      final validation = _validateQrData(qrData, _selectedType);

      if (validation != null) {
        _batchErrors.add('Line ${i + 1}: $validation');
        continue;
      }

      await _generateAndSaveBatchQr(qrData, i);
      setState(() => _generatedCount++);

    } catch (e) {
      _batchErrors.add('Line ${i + 1}: Generation failed - ${e.toString()}');
    }
  }

  _showBatchResults();
}
```

### 6.3 User Feedback

#### Success Messages

```dart
void _showCopySuccessMessage() {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.white),
          SizedBox(width: 8),
          Text('QR code copied to clipboard'),
        ],
      ),
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
}
```

#### Error Messages

```dart
void _showGenerationError(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(Icons.error, color: Colors.white),
          SizedBox(width: 8),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: Colors.red,
      duration: Duration(seconds: 4),
      action: SnackBarAction(
        label: 'Help',
        textColor: Colors.white,
        onPressed: _showHelpDialog,
      ),
    ),
  );
}
```

## 7. Performance Optimization

### 7.1 QR Generation Performance

#### Debounced Updates

```dart
Timer? _debounceTimer;

void _onTextChanged() {
  _debounceTimer?.cancel();
  _debounceTimer = Timer(Duration(milliseconds: 300), () {
    setState(() => _qrData = _buildQrData());

    if (_qrData.isNotEmpty) {
      _bounceController.forward().then((_) => _bounceController.reverse());
    }
  });
}
```

#### Memory Management

```dart
@override
void dispose() {
  _textController.dispose();
  _batchTextController.dispose();
  _tabController.dispose();
  _bounceController.dispose();
  _debounceTimer?.cancel();
  _billingService.dispose();
  super.dispose();
}
```

### 7.2 Batch Processing Optimization

#### Chunked Processing

```dart
Future<void> _processBatchInChunks() async {
  const chunkSize = 10;
  final chunks = _createChunks(_batchItems, chunkSize);

  for (final chunk in chunks) {
    await Future.wait(
      chunk.map((item) => _generateSingleQr(item)),
      eagerError: false,
    );

    // Update progress
    setState(() => _generatedCount += chunk.length);

    // Brief pause to prevent UI blocking
    await Future.delayed(Duration(milliseconds: 10));
  }
}

List<List<String>> _createChunks(List<String> items, int chunkSize) {
  final chunks = <List<String>>[];
  for (int i = 0; i < items.length; i += chunkSize) {
    chunks.add(items.sublist(i, min(i + chunkSize, items.length)));
  }
  return chunks;
}
```

#### Background Processing

```dart
Future<void> _generateBatchInBackground() async {
  final isolateResult = await compute(_generateQrBatch, {
    'items': _batchItems,
    'type': _selectedType.index,
    'size': _qrSize,
    'foregroundColor': _foregroundColor.value,
    'backgroundColor': _backgroundColor.value,
  });

  setState(() {
    _generatedQrCodes = isolateResult['qrCodes'];
    _batchErrors = isolateResult['errors'];
  });
}
```

## 8. Accessibility Features

### 8.1 Screen Reader Support

#### Semantic Labels

```dart
Semantics(
  label: 'QR code preview for ${_getQrTypeDescription()}',
  child: QrImageView(data: _qrData, size: _qrSize.toDouble()),
)

String _getQrTypeDescription() {
  switch (_selectedType) {
    case QrType.text:
      return 'text content: ${_qrData.length > 50 ? _qrData.substring(0, 50) + "..." : _qrData}';
    case QrType.url:
      return 'website URL: $_qrData';
    case QrType.email:
      return 'email address: $_qrData';
    case QrType.phone:
      return 'phone number: $_qrData';
    case QrType.sms:
      return 'SMS message to phone number';
    case QrType.wifi:
      return 'WiFi network configuration';
  }
}
```

#### Focus Management

```dart
final FocusNode _qrTypeFocus = FocusNode();
final FocusNode _inputFocus = FocusNode();
final FocusNode _sizeFocus = FocusNode();

void _handleQrTypeChange(QrType? newType) {
  if (newType != null) {
    _selectedType = newType;
    // Move focus to input field after type selection
    _inputFocus.requestFocus();
    _onTextChanged();
  }
}
```

### 8.2 Keyboard Navigation

#### Tab Order

```dart
Widget _buildInputSection() {
  return Column(
    children: [
      DropdownButtonFormField<QrType>(
        focusNode: _qrTypeFocus,
        // ... dropdown configuration
      ),
      TextFormField(
        focusNode: _inputFocus,
        // ... input configuration
      ),
      Focus(
        focusNode: _sizeFocus,
        child: Slider(
          // ... slider configuration
        ),
      ),
    ],
  );
}
```

#### Keyboard Shortcuts

```dart
@override
Widget build(BuildContext context) {
  return Shortcuts(
    shortcuts: {
      LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS): SaveQrIntent(),
      LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyC): CopyQrIntent(),
      LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyN): NewQrIntent(),
    },
    child: Actions(
      actions: {
        SaveQrIntent: CallbackAction<SaveQrIntent>(onInvoke: (_) => _downloadQr()),
        CopyQrIntent: CallbackAction<CopyQrIntent>(onInvoke: (_) => _copyToClipboard()),
        NewQrIntent: CallbackAction<NewQrIntent>(onInvoke: (_) => _clearInputs()),
      },
      child: _buildMainContent(),
    ),
  );
}
```

### 8.3 High Contrast Support

#### Color Validation

```dart
void _ensureAccessibleColors() {
  if (!_hasValidContrast(_foregroundColor, _backgroundColor)) {
    // Auto-adjust colors for better contrast
    if (_backgroundColor.computeLuminance() > 0.5) {
      _foregroundColor = Colors.black;
    } else {
      _foregroundColor = Colors.white;
    }
    setState(() {});
  }
}
```

#### Visual Indicators

```dart
Widget _buildContrastIndicator() {
  final hasGoodContrast = _hasValidContrast(_foregroundColor, _backgroundColor);

  return Row(
    children: [
      Icon(
        hasGoodContrast ? Icons.check_circle : Icons.warning,
        color: hasGoodContrast ? Colors.green : Colors.orange,
      ),
      SizedBox(width: 4),
      Text(
        hasGoodContrast ? 'Good contrast' : 'Low contrast',
        style: TextStyle(
          color: hasGoodContrast ? Colors.green : Colors.orange,
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  );
}
```

## 9. Testing Scenarios

### 9.1 QR Code Generation Tests

#### Basic Generation Test

```dart
testWidgets('generates QR code for text input', (tester) async {
  await tester.pumpWidget(TestApp(child: QrMakerScreen()));

  // Enter text
  await tester.enterText(find.byType(TextFormField), 'Test QR Code');
  await tester.pump(Duration(milliseconds: 500)); // Wait for debounce

  // Verify QR code is generated
  expect(find.byType(QrImageView), findsOneWidget);

  final qrWidget = tester.widget<QrImageView>(find.byType(QrImageView));
  expect(qrWidget.data, equals('Test QR Code'));
});
```

#### QR Type Switching Test

```dart
testWidgets('switches QR type and updates form fields', (tester) async {
  await tester.pumpWidget(TestApp(child: QrMakerScreen()));

  // Select email type
  await tester.tap(find.byType(DropdownButtonFormField<QrType>));
  await tester.pumpAndSettle();
  await tester.tap(find.text('📧 Email Address'));
  await tester.pumpAndSettle();

  // Verify email input field
  expect(find.text('Enter email address'), findsOneWidget);

  // Enter email
  await tester.enterText(find.byType(TextFormField), 'test@example.com');
  await tester.pump(Duration(milliseconds: 500));

  // Verify QR data format
  final qrWidget = tester.widget<QrImageView>(find.byType(QrImageView));
  expect(qrWidget.data, equals('mailto:test@example.com'));
});
```

### 9.2 Validation Tests

#### Input Validation Test

```dart
testWidgets('validates email input format', (tester) async {
  await tester.pumpWidget(TestApp(child: QrMakerScreen()));

  // Select email type
  await tester.tap(find.byType(DropdownButtonFormField<QrType>));
  await tester.pumpAndSettle();
  await tester.tap(find.text('📧 Email Address'));
  await tester.pumpAndSettle();

  // Enter invalid email
  await tester.enterText(find.byType(TextFormField), 'invalid-email');
  await tester.pump(Duration(milliseconds: 500));

  // Verify error message
  expect(find.text('Please enter a valid email address'), findsOneWidget);
});
```

#### Color Contrast Test

```dart
testWidgets('warns about low color contrast', (tester) async {
  await tester.pumpWidget(TestApp(child: QrMakerScreen()));

  // Set low contrast colors (both light)
  final qrMakerState = tester.state<_QrMakerScreenState>(find.byType(QrMakerScreen));
  qrMakerState._foregroundColor = Colors.grey.shade300;
  qrMakerState._backgroundColor = Colors.grey.shade200;
  await tester.pump();

  // Verify contrast warning
  expect(find.text('Low contrast'), findsOneWidget);
  expect(find.byIcon(Icons.warning), findsOneWidget);
});
```

### 9.3 Batch Processing Tests

#### Batch Generation Test

```dart
testWidgets('generates batch QR codes for Pro users', (tester) async {
  // Mock Pro subscription
  final mockBillingService = MockBillingService();
  when(mockBillingService.canAccessFeature('batch_qr_generation'))
      .thenAnswer((_) async => true);

  await tester.pumpWidget(TestApp(
    child: QrMakerScreen(),
    billingService: mockBillingService,
  ));

  // Switch to batch tab
  await tester.tap(find.text('Batch QR'));
  await tester.pumpAndSettle();

  // Enter batch data
  await tester.enterText(
    find.byType(TextFormField).last,
    'https://example1.com\nhttps://example2.com\nhttps://example3.com'
  );

  // Generate batch
  await tester.tap(find.text('Generate Batch'));
  await tester.pumpAndSettle();

  // Verify progress tracking
  expect(find.byType(LinearProgressIndicator), findsOneWidget);

  // Wait for completion
  await tester.pumpAndSettle(Duration(seconds: 2));

  // Verify results
  expect(find.text('Generated 3 QR codes'), findsOneWidget);
});
```

### 9.4 Integration Tests

#### ShareBus Import Test

```dart
testWidgets('imports data from ShareBus', (tester) async {
  // Setup shared data
  final sharedData = SharedData(
    type: SharedDataType.url,
    content: 'https://toolspace.app',
    source: 'text_tools',
  );
  SharedDataService.instance.shareData(sharedData);

  await tester.pumpWidget(TestApp(child: QrMakerScreen()));

  // Verify data imported
  final textField = tester.widget<TextFormField>(find.byType(TextFormField));
  expect(textField.controller?.text, equals('https://toolspace.app'));

  // Verify QR type set correctly
  expect(find.text('🌐 Website URL'), findsOneWidget);
});
```

#### Cross-Tool Navigation Test

```dart
testWidgets('shares QR data with other tools', (tester) async {
  await tester.pumpWidget(TestApp(child: QrMakerScreen()));

  // Generate QR code
  await tester.enterText(find.byType(TextFormField), 'Shared content');
  await tester.pump(Duration(milliseconds: 500));

  // Share data
  await tester.tap(find.byIcon(Icons.share));
  await tester.pumpAndSettle();

  // Verify data in ShareBus
  final sharedData = SharedDataService.instance.getLastSharedData();
  expect(sharedData?.content, equals('Shared content'));
  expect(sharedData?.source, equals('qr_maker'));
});
```

## 10. Security Considerations

### 10.1 Input Sanitization

#### QR Data Sanitization

```dart
String _sanitizeQrData(String input) {
  // Remove potentially harmful characters
  String sanitized = input
    .replaceAll(RegExp(r'[^\x20-\x7E\u00A0-\uFFFF]'), '') // Keep printable chars
    .trim();

  // Limit length
  if (sanitized.length > 2953) {
    sanitized = sanitized.substring(0, 2953);
  }

  return sanitized;
}
```

#### URL Validation

```dart
bool _isSafeUrl(String url) {
  try {
    final uri = Uri.parse(url);

    // Block potentially malicious schemes
    final blockedSchemes = ['javascript', 'data', 'file', 'ftp'];
    if (blockedSchemes.contains(uri.scheme.toLowerCase())) {
      return false;
    }

    // Ensure reasonable length
    if (url.length > 2048) {
      return false;
    }

    return true;
  } catch (e) {
    return false;
  }
}
```

### 10.2 Privacy Protection

#### Data Handling

```dart
class QrMakerScreen extends StatefulWidget {
  // No persistent storage of user QR data
  // All data cleared on dispose

  @override
  void dispose() {
    // Clear sensitive data
    _textController.clear();
    _batchTextController.clear();
    _wifiPassword = '';
    super.dispose();
  }
}
```

#### Analytics

```dart
void _trackQrGeneration() {
  // Only track usage patterns, not content
  AnalyticsService.trackEvent('qr_generated', {
    'type': _selectedType.toString().split('.').last,
    'size': _qrSize,
    'has_custom_colors': _foregroundColor != Colors.black || _backgroundColor != Colors.white,
    // Never track actual QR content
  });
}
```

### 10.3 Rate Limiting

#### Generation Throttling

```dart
class QrGenerationThrottle {
  static const int maxPerMinute = 60;
  static const int maxBatchSize = 100;

  final List<DateTime> _recentGenerations = [];

  bool canGenerate() {
    final now = DateTime.now();
    final oneMinuteAgo = now.subtract(Duration(minutes: 1));

    // Remove old entries
    _recentGenerations.removeWhere((time) => time.isBefore(oneMinuteAgo));

    return _recentGenerations.length < maxPerMinute;
  }

  void recordGeneration() {
    _recentGenerations.add(DateTime.now());
  }
}
```

## 11. Release Notes

### Version 2.1.0 - Current Release

#### 🎉 New Features

- **6 QR Code Types** - Text, URL, email, phone, SMS, WiFi support
- **Real-time Preview** - Live QR code generation with bounce animations
- **Batch Generation** - Pro feature for bulk QR creation (up to 100 codes)
- **Color Customization** - Full foreground and background color control
- **Size Adjustment** - Slider control from 100px to 500px
- **Cross-Tool Integration** - ShareBus support for importing/exporting data

#### ⚡ Performance Features

- **Debounced Updates** - Smooth typing experience with 300ms debounce
- **Memory Management** - Proper disposal of controllers and animations
- **Error Recovery** - Graceful handling of invalid QR data

#### 🎨 User Experience

- **Tab Interface** - Separate tabs for single and batch generation
- **Input Validation** - Real-time validation for all QR types
- **Visual Feedback** - Success/error messages and progress indicators
- **Accessibility** - Full keyboard navigation and screen reader support

#### 🔧 Technical Implementation

- **Flutter Integration** - Built with `qr_flutter` package
- **Animation System** - Smooth bounce effects and tab transitions
- **Billing Integration** - PaywallGuard for Pro features
- **Error Handling** - Comprehensive validation and error recovery

### Future Roadmap

#### Version 2.2.0 (Planned - Next Release)

- **Logo Embedding** - Add custom logos to QR code centers (Pro+ feature)
- **Batch Export Options** - Custom naming and folder organization
- **Advanced Error Correction** - Selectable error correction levels
- **Pattern Customization** - Rounded corners and custom shapes

#### Version 2.3.0 (Planned)

- **QR Code Scanner** - Camera-based QR code reading functionality
- **Template System** - Save and reuse QR configurations
- **API Integration** - Connect with external QR services
- **Analytics Dashboard** - Usage statistics and performance metrics

## 12. Support & Documentation

### 12.1 User Help

#### Common Issues

1. **"QR code not scanning"** - Check color contrast and size
2. **"Invalid URL error"** - Ensure URL includes http:// or https://
3. **"Batch generation failed"** - Verify Pro subscription status
4. **"WiFi QR not working"** - Check network name and password accuracy

#### Best Practices

- Use high contrast colors (black on white recommended)
- Keep QR codes at least 200px for reliable scanning
- Test QR codes with multiple scanner apps
- Use error correction level M or higher for logos

### 12.2 Developer Reference

#### Widget Integration

```dart
// Basic QR Maker integration
Navigator.pushNamed(context, '/tools/qr-maker');

// With pre-filled data
Navigator.pushNamed(
  context,
  '/tools/qr-maker',
  arguments: {
    'type': 'url',
    'content': 'https://example.com'
  }
);
```

#### ShareBus Integration

```dart
// Share data to QR Maker
SharedDataService.instance.shareData(SharedData(
  type: SharedDataType.url,
  content: 'https://toolspace.app',
  source: 'your_tool',
));

Navigator.pushNamed(context, '/tools/qr-maker');
```

### 12.3 API Reference

#### QR Type Enumeration

```dart
enum QrType {
  text,    // Plain text QR codes
  url,     // Website URLs
  email,   // Email addresses
  phone,   // Phone numbers
  sms,     // SMS messages
  wifi,    // WiFi network credentials
}
```

#### Data Models

```dart
class QrGenerationRequest {
  final QrType type;
  final String content;
  final int size;
  final Color foregroundColor;
  final Color backgroundColor;

  const QrGenerationRequest({
    required this.type,
    required this.content,
    this.size = 200,
    this.foregroundColor = Colors.black,
    this.backgroundColor = Colors.white,
  });
}
```

For additional support or feature requests, please contact the Toolspace development team.
