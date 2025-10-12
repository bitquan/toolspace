# QR Maker - Limits & Performance Documentation

**Tool ID:** `qr_maker`  
**Route:** `/tools/qr-maker`  
**Performance Architect:** Toolspace Platform Team  
**Last Updated:** October 11, 2025

## 1. Overview

QR Maker implements comprehensive limits to ensure optimal performance, prevent abuse, and maintain service quality across all user tiers. These limits balance functionality with system resources while providing clear upgrade paths for power users.

**Limit Categories:**

- **Content Limits** - QR data size and format restrictions
- **Generation Limits** - Rate limiting and quota enforcement
- **Resource Limits** - Memory, processing, and storage constraints
- **Feature Limits** - Tier-based feature access restrictions
- **Performance Targets** - Response time and throughput requirements

## 2. Content Limits

### 2.1 QR Data Size Limits

#### Universal QR Content Limit

**Maximum Characters:** 2,953 characters per QR code  
**Rationale:** QR Code specification maximum for optimal scanning reliability  
**Enforcement:** Real-time validation with character counter

```dart
class QrContentLimits {
  static const int maxQrCharacters = 2953;
  static const int recommendedMaxChars = 1000; // For reliable scanning

  static bool isWithinLimit(String content) {
    return content.length <= maxQrCharacters;
  }

  static bool isRecommendedSize(String content) {
    return content.length <= recommendedMaxChars;
  }
}
```

#### Type-Specific Optimizations

```dart
class TypeSpecificLimits {
  // URL QRs - Shorter URLs scan more reliably
  static const int recommendedUrlLength = 200;
  static const int maxUrlLength = 2000;

  // Email QRs - Including subject and body
  static const int maxEmailTotal = 500;
  static const int maxSubjectLength = 100;
  static const int maxBodyLength = 300;

  // WiFi QRs - Network credentials
  static const int maxSsidLength = 32; // WiFi standard
  static const int maxPasswordLength = 63; // WPA standard

  // Text QRs - General content
  static const int recommendedTextLength = 500;
  static const int maxTextLength = 2953;
}
```

### 2.2 File Format Limits

#### QR Image Output Limits

```dart
class QrImageLimits {
  // Size constraints
  static const int minSize = 100; // pixels
  static const int maxSize = 500; // pixels
  static const int defaultSize = 200; // pixels

  // File size estimates (PNG format)
  static const int estimatedBytesPerPixel = 4; // RGBA
  static const int compressionRatio = 10; // PNG compression

  static int estimateFileSize(int pixelSize) {
    final totalPixels = pixelSize * pixelSize;
    final uncompressedBytes = totalPixels * estimatedBytesPerPixel;
    return uncompressedBytes ~/ compressionRatio;
  }

  // Example calculations:
  // 100x100 = ~4KB
  // 200x200 = ~16KB
  // 500x500 = ~100KB
}
```

#### Batch Export Limits

```dart
class BatchExportLimits {
  static const int maxZipSize = 100 * 1024 * 1024; // 100MB
  static const int maxFilesInZip = 1000;
  static const Duration maxZipGenerationTime = Duration(minutes: 5);

  static bool canCreateZip(int fileCount, int averageFileSize) {
    final estimatedSize = fileCount * averageFileSize;
    return estimatedSize <= maxZipSize && fileCount <= maxFilesInZip;
  }
}
```

## 3. Generation Rate Limits

### 3.1 Free Tier Limits

#### Single QR Generation (Unlimited)

**Rate Limit:** None - unlimited single QR generation  
**Rationale:** Core functionality should be freely accessible  
**Monitoring:** Track for abuse detection only

```dart
class FreeTierLimits {
  // No rate limits on single QR generation
  static const int singleQrRateLimit = -1; // Unlimited

  // Memory-based limits to prevent abuse
  static const int maxConcurrentGenerations = 5;
  static const Duration maxGenerationTime = Duration(seconds: 10);

  // Batch features not available
  static const int batchQrLimit = 0; // No batch access
  static const bool advancedCustomization = false;
}
```

#### Abuse Prevention

```dart
class AbusePreventionLimits {
  // Rapid-fire protection
  static const int maxQrsPerSecond = 10;
  static const Duration cooldownPeriod = Duration(seconds: 5);

  // Memory protection
  static const int maxQrCacheSize = 20;
  static const int maxMemoryUsage = 50 * 1024 * 1024; // 50MB

  static bool isAbusivePattern(List<DateTime> recentRequests) {
    final now = DateTime.now();
    final recentCount = recentRequests
        .where((time) => now.difference(time) < Duration(seconds: 1))
        .length;

    return recentCount > maxQrsPerSecond;
  }
}
```

### 3.2 Pro Tier Limits

#### Batch Generation Quotas

```dart
class ProTierLimits {
  // Batch processing limits
  static const int maxBatchSize = 100; // QRs per batch
  static const int maxBatchesPerHour = 10; // Batches per hour
  static const int maxBatchesPerDay = 100; // Batches per day
  static const int maxBatchesPerMonth = 1000; // Monthly quota

  // Advanced features
  static const bool advancedCustomization = true;
  static const bool logoEmbedding = false; // Pro+ feature
  static const bool apiAccess = false; // Pro+ feature

  // Performance targets
  static const Duration maxBatchTime = Duration(minutes: 2);
  static const Duration targetBatchTime = Duration(seconds: 30);
}
```

#### Pro Usage Tracking

```dart
class ProUsageTracker {
  static Future<bool> canPerformBatch(String userId, int batchSize) async {
    final usage = await _getCurrentUsage(userId);

    // Check hourly limit
    if (usage.batchesThisHour >= ProTierLimits.maxBatchesPerHour) {
      return false;
    }

    // Check daily limit
    if (usage.batchesToday >= ProTierLimits.maxBatchesPerDay) {
      return false;
    }

    // Check monthly limit
    if (usage.batchesThisMonth >= ProTierLimits.maxBatchesPerMonth) {
      return false;
    }

    // Check batch size
    if (batchSize > ProTierLimits.maxBatchSize) {
      return false;
    }

    return true;
  }
}
```

### 3.3 Pro+ Tier Limits

#### Enterprise-Level Quotas

```dart
class ProPlusLimits {
  // Enhanced batch processing
  static const int maxBatchSize = 500; // QRs per batch
  static const int maxBatchesPerHour = 50; // Batches per hour
  static const int maxBatchesPerDay = 500; // Batches per day
  static const int maxBatchesPerMonth = 10000; // Monthly quota

  // Advanced features
  static const bool logoEmbedding = true;
  static const bool apiAccess = true;
  static const bool webhooks = true;
  static const bool analytics = true;

  // API rate limits
  static const int apiRequestsPerMinute = 100;
  static const int apiRequestsPerHour = 5000;
  static const int apiRequestsPerDay = 50000;

  // Performance targets
  static const Duration maxBatchTime = Duration(minutes: 10);
  static const Duration targetBatchTime = Duration(minutes: 2);
}
```

## 4. Performance Targets

### 4.1 Response Time Targets

#### Single QR Generation Performance

```dart
class SingleQrPerformanceTargets {
  // Generation time targets
  static const Duration targetGenerationTime = Duration(milliseconds: 50);
  static const Duration maxGenerationTime = Duration(milliseconds: 100);
  static const Duration criticalGenerationTime = Duration(milliseconds: 500);

  // UI responsiveness targets
  static const Duration targetUiResponse = Duration(milliseconds: 16); // 60fps
  static const Duration maxUiResponse = Duration(milliseconds: 32); // 30fps

  // Debounce timing
  static const Duration inputDebounce = Duration(milliseconds: 300);
  static const Duration colorChangeDebounce = Duration(milliseconds: 100);
}
```

#### Batch Processing Performance

```dart
class BatchPerformanceTargets {
  // Throughput targets
  static const int targetQrsPerSecond = 10;
  static const int minQrsPerSecond = 5;
  static const int maxQrsPerSecond = 20;

  // Progress update frequency
  static const Duration progressUpdateInterval = Duration(milliseconds: 500);
  static const int minItemsPerUpdate = 5;

  // Memory constraints during batch processing
  static const int maxConcurrentQrGeneration = 10;
  static const int maxMemoryPerBatch = 200 * 1024 * 1024; // 200MB

  static Duration estimateBatchTime(int itemCount) {
    final secondsRequired = itemCount / targetQrsPerSecond;
    return Duration(seconds: secondsRequired.ceil());
  }
}
```

### 4.2 Resource Usage Targets

#### Memory Usage Limits

```dart
class MemoryLimits {
  // Browser memory limits
  static const int maxTotalMemory = 100 * 1024 * 1024; // 100MB
  static const int maxQrCacheMemory = 20 * 1024 * 1024; // 20MB
  static const int maxImageCacheMemory = 50 * 1024 * 1024; // 50MB

  // Cache size limits
  static const int maxCachedQrs = 50;
  static const int maxCachedImages = 20;
  static const Duration cacheExpiration = Duration(hours: 1);

  // Memory cleanup thresholds
  static const double memoryCleanupThreshold = 0.8; // 80%
  static const double memoryAlarmThreshold = 0.9; // 90%
}
```

#### CPU Usage Targets

```dart
class CpuLimits {
  // Processing time limits
  static const Duration maxCpuTimePerQr = Duration(milliseconds: 50);
  static const Duration maxCpuTimePerBatch = Duration(minutes: 2);

  // Concurrency limits
  static const int maxConcurrentOperations = 3;
  static const int maxWorkerThreads = 2;

  // Throttling parameters
  static const Duration throttleDelay = Duration(milliseconds: 10);
  static const int throttleThreshold = 10; // Requests before throttling
}
```

## 5. Error Handling & Limits

### 5.1 Error Response Limits

#### Error Rate Thresholds

```dart
class ErrorLimits {
  // Error rate monitoring
  static const double maxErrorRate = 0.05; // 5% error rate
  static const double warningErrorRate = 0.02; // 2% warning threshold

  // Consecutive error limits
  static const int maxConsecutiveErrors = 3;
  static const Duration errorCooldown = Duration(minutes: 1);

  // Error retry limits
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 1);
  static const Duration maxRetryDelay = Duration(seconds: 5);
}
```

#### Graceful Degradation

```dart
class DegradationLimits {
  // Quality reduction thresholds
  static const double highLoadThreshold = 0.8; // 80% capacity
  static const double criticalLoadThreshold = 0.95; // 95% capacity

  // Degradation actions
  static const int reducedQrSize = 150; // From default 200
  static const QrErrorCorrection reducedErrorCorrection = QrErrorCorrection.low;
  static const bool disableAnimations = true;

  static QrGenerationSettings getDegradedSettings(double currentLoad) {
    if (currentLoad > criticalLoadThreshold) {
      return QrGenerationSettings(
        size: reducedQrSize,
        errorCorrection: reducedErrorCorrection,
        enableAnimations: false,
      );
    } else if (currentLoad > highLoadThreshold) {
      return QrGenerationSettings(
        errorCorrection: reducedErrorCorrection,
        enableAnimations: false,
      );
    }

    return QrGenerationSettings.standard();
  }
}
```

### 5.2 User Feedback on Limits

#### Limit Notification Messages

```dart
class LimitNotifications {
  static String getContentTooLongMessage(int currentLength) {
    final over = currentLength - QrContentLimits.maxQrCharacters;
    return 'Content is too long by $over characters. '
           'Maximum QR code length is ${QrContentLimits.maxQrCharacters} characters.';
  }

  static String getBatchSizeLimitMessage(String userPlan, int attemptedSize) {
    switch (userPlan) {
      case 'free':
        return 'Batch generation requires a Pro subscription. '
               'Upgrade to generate up to 100 QR codes at once.';
      case 'pro':
        return 'Pro subscription allows up to ${ProTierLimits.maxBatchSize} QR codes per batch. '
               'You attempted $attemptedSize. Upgrade to Pro+ for batches up to ${ProPlusLimits.maxBatchSize}.';
      case 'pro_plus':
        return 'Maximum batch size is ${ProPlusLimits.maxBatchSize} QR codes. '
               'You attempted $attemptedSize.';
      default:
        return 'Batch size limit exceeded.';
    }
  }

  static String getQuotaExceededMessage(String userPlan, String quotaType) {
    switch (quotaType) {
      case 'hourly':
        return 'You\'ve reached your hourly batch limit. Please try again next hour.';
      case 'daily':
        return 'You\'ve reached your daily batch limit. Please try again tomorrow.';
      case 'monthly':
        return 'You\'ve reached your monthly batch limit. Your quota resets next month.';
      default:
        return 'Usage quota exceeded. Please try again later.';
    }
  }
}
```

## 6. Browser & Platform Limits

### 6.1 Browser-Specific Constraints

#### Memory Limits by Browser

```dart
class BrowserLimits {
  static const Map<String, int> browserMemoryLimits = {
    'chrome': 100 * 1024 * 1024,   // 100MB
    'firefox': 80 * 1024 * 1024,   // 80MB
    'safari': 60 * 1024 * 1024,    // 60MB
    'edge': 100 * 1024 * 1024,     // 100MB
    'mobile': 50 * 1024 * 1024,    // 50MB for mobile browsers
  };

  static const Map<String, int> browserBatchLimits = {
    'chrome': 100,
    'firefox': 80,
    'safari': 50,
    'edge': 100,
    'mobile': 25,
  };

  static int getMemoryLimit(String browser) {
    return browserMemoryLimits[browser] ?? browserMemoryLimits['mobile']!;
  }

  static int getBatchLimit(String browser) {
    return browserBatchLimits[browser] ?? browserBatchLimits['mobile']!;
  }
}
```

#### Mobile Platform Constraints

```dart
class MobileLimits {
  // iOS constraints
  static const int iosMaxMemory = 50 * 1024 * 1024; // 50MB
  static const int iosMaxBatchSize = 25;
  static const Duration iosMaxProcessingTime = Duration(minutes: 1);

  // Android constraints
  static const int androidMaxMemory = 60 * 1024 * 1024; // 60MB
  static const int androidMaxBatchSize = 30;
  static const Duration androidMaxProcessingTime = Duration(minutes: 1);

  // General mobile constraints
  static const int mobileMaxConcurrentQrs = 2;
  static const int mobileMaxQrSize = 300; // pixels
  static const bool mobileAdvancedFeatures = false;
}
```

### 6.2 Network & Connectivity Limits

#### Offline Capability Limits

```dart
class OfflineLimits {
  // Offline functionality
  static const bool offlineQrGeneration = true; // QR gen works offline
  static const bool offlineBatchProcessing = true;
  static const bool offlineCrossToolSharing = false; // Requires connection

  // Cached data limits
  static const int maxOfflineCacheSize = 10 * 1024 * 1024; // 10MB
  static const int maxCachedQrs = 100;
  static const Duration offlineCacheExpiry = Duration(days: 7);
}
```

#### Network Timeout Limits

```dart
class NetworkLimits {
  // API request timeouts
  static const Duration apiRequestTimeout = Duration(seconds: 30);
  static const Duration batchUploadTimeout = Duration(minutes: 5);
  static const Duration webhookTimeout = Duration(seconds: 10);

  // Retry configuration
  static const int maxNetworkRetries = 3;
  static const Duration retryBackoffBase = Duration(seconds: 1);
  static const double retryBackoffMultiplier = 2.0;
}
```

## 7. Security & Abuse Limits

### 7.1 Content Security Limits

#### Input Sanitization Limits

```dart
class SecurityLimits {
  // Dangerous content patterns
  static const List<String> blockedPatterns = [
    'javascript:',
    'data:',
    'vbscript:',
    'file://',
  ];

  // URL validation
  static const List<String> allowedProtocols = [
    'http',
    'https',
    'mailto',
    'tel',
    'sms',
  ];

  // Content filtering
  static const int maxUrlLength = 2048;
  static const bool allowExecutableContent = false;
  static const bool strictModeEnabled = true;

  static bool isContentSafe(String content) {
    final lowercaseContent = content.toLowerCase();

    for (final pattern in blockedPatterns) {
      if (lowercaseContent.contains(pattern)) {
        return false;
      }
    }

    return true;
  }
}
```

### 7.2 Rate Limiting for Abuse Prevention

#### Suspicious Activity Detection

```dart
class AbuseLimits {
  // Suspicious patterns
  static const int maxIdenticalQrs = 10; // Same content
  static const Duration suspiciousWindow = Duration(minutes: 5);
  static const int maxRapidRequests = 50; // Requests per minute

  // Automated detection
  static const double automationThreshold = 0.95; // 95% identical requests
  static const int minRequestsForAnalysis = 20;

  // Response to abuse
  static const Duration tempBanDuration = Duration(hours: 1);
  static const Duration permanentBanThreshold = Duration(days: 1);
  static const int maxWarningsBeforeBan = 3;

  static bool isSuspiciousActivity(List<QrRequest> recentRequests) {
    if (recentRequests.length < minRequestsForAnalysis) {
      return false;
    }

    // Check for too many identical requests
    final contentGroups = <String, int>{};
    for (final request in recentRequests) {
      contentGroups[request.content] = (contentGroups[request.content] ?? 0) + 1;
    }

    final maxDuplicates = contentGroups.values.reduce(math.max);
    return maxDuplicates > maxIdenticalQrs;
  }
}
```

## 8. Monitoring & Alerting Limits

### 8.1 Performance Monitoring Thresholds

#### System Health Metrics

```dart
class MonitoringLimits {
  // Performance thresholds
  static const Duration responseTimeWarning = Duration(milliseconds: 200);
  static const Duration responseTimeAlert = Duration(milliseconds: 500);
  static const Duration responseTimeCritical = Duration(seconds: 1);

  // Error rate thresholds
  static const double errorRateWarning = 0.01; // 1%
  static const double errorRateAlert = 0.05; // 5%
  static const double errorRateCritical = 0.1; // 10%

  // Resource usage thresholds
  static const double memoryWarning = 0.7; // 70%
  static const double memoryAlert = 0.85; // 85%
  static const double memoryCritical = 0.95; // 95%

  // Throughput thresholds
  static const int minQrsPerSecond = 5;
  static const int targetQrsPerSecond = 10;
  static const int maxSustainableQrsPerSecond = 15;
}
```

### 8.2 User Experience Metrics

#### UX Performance Targets

```dart
class UxLimits {
  // Time to first QR
  static const Duration timeToFirstQr = Duration(milliseconds: 100);

  // Interaction responsiveness
  static const Duration inputResponseTime = Duration(milliseconds: 50);
  static const Duration animationFrameTime = Duration(milliseconds: 16); // 60fps

  // Loading states
  static const Duration showLoadingAfter = Duration(milliseconds: 200);
  static const Duration maxLoadingTime = Duration(seconds: 5);

  // User patience thresholds
  static const Duration userImpatience = Duration(seconds: 3);
  static const Duration userAbandonThreshold = Duration(seconds: 10);
}
```

## 9. Configuration & Tuning

### 9.1 Dynamic Limit Adjustment

#### Load-Based Scaling

```dart
class DynamicLimits {
  static QrLimitsConfig adjustLimitsForLoad(double currentLoad) {
    if (currentLoad > 0.9) {
      // Critical load - severely restrict
      return QrLimitsConfig(
        maxBatchSize: 10,
        maxConcurrentOperations: 1,
        enableAdvancedFeatures: false,
        responseTimeTarget: Duration(seconds: 2),
      );
    } else if (currentLoad > 0.7) {
      // High load - moderate restrictions
      return QrLimitsConfig(
        maxBatchSize: 50,
        maxConcurrentOperations: 2,
        enableAdvancedFeatures: true,
        responseTimeTarget: Duration(milliseconds: 500),
      );
    } else {
      // Normal load - standard limits
      return QrLimitsConfig.standard();
    }
  }
}
```

### 9.2 A/B Testing Parameters

#### Limit Experimentation

```dart
class LimitExperiments {
  // Test different batch sizes
  static const Map<String, int> batchSizeExperiments = {
    'control': 100,
    'variant_a': 150,
    'variant_b': 75,
  };

  // Test different timeout values
  static const Map<String, Duration> timeoutExperiments = {
    'control': Duration(milliseconds: 100),
    'variant_a': Duration(milliseconds: 150),
    'variant_b': Duration(milliseconds: 75),
  };

  static int getBatchSizeForExperiment(String experimentGroup) {
    return batchSizeExperiments[experimentGroup] ?? batchSizeExperiments['control']!;
  }
}
```

## 10. Future Scaling Considerations

### 10.1 Planned Limit Increases

#### Roadmap for Higher Limits

```dart
class FutureLimits {
  // 2025 Q4 targets
  static const int futureBatchSizeTarget = 1000; // Up from 500
  static const Duration futureResponseTarget = Duration(milliseconds: 25); // Down from 50ms

  // 2026 targets
  static const int enterpriseBatchSize = 5000;
  static const bool realTimeCollaboration = true;
  static const bool aiOptimization = true;

  // Infrastructure scaling requirements
  static const double expectedGrowth = 10.0; // 10x growth
  static const int scalingFactor = 5; // 5x capacity increase needed
}
```

### 10.2 Technology Evolution Impact

#### Next-Generation Capabilities

```dart
class NextGenLimits {
  // WebAssembly optimization
  static const bool wasmAcceleration = true;
  static const int wasmPerformanceGain = 3; // 3x faster

  // Edge computing
  static const bool edgeProcessing = true;
  static const Duration edgeLatencyReduction = Duration(milliseconds: 50);

  // AI-powered optimization
  static const bool aiSizeOptimization = true;
  static const bool aiErrorCorrection = true;
  static const double aiPerformanceGain = 2.0; // 2x improvement
}
```

The QR Maker tool implements comprehensive limits that balance user needs with system performance, providing clear upgrade paths while maintaining service quality across all user tiers and usage patterns.
