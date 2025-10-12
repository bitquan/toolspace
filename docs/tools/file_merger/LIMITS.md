# File Merger - Limits & Performance

**Last Updated**: December 29, 2024  
**Performance Version**: 1.0  
**Infrastructure**: Firebase + Stripe

## Limits Overview

File Merger operates within carefully designed technical and business constraints that ensure reliable service delivery, fair resource allocation, and sustainable operation. These limits protect system performance while providing clear upgrade paths for users requiring enhanced capabilities.

### Limit Categories

- **File Processing Limits**: Size, format, and quantity restrictions for reliable merging
- **User Quota Limits**: Monthly usage restrictions with Pro plan upgrade options
- **Technical Performance Limits**: System resource and processing time boundaries
- **Security & Access Limits**: Authentication and data protection constraints
- **Billing Tier Limits**: Feature access based on subscription level

## File Processing Limits

### File Size Constraints

#### Free Tier Limitations

```typescript
const FREE_TIER_FILE_LIMITS = {
  MAX_FILE_SIZE: 10 * 1024 * 1024, // 10 MB per file
  MAX_TOTAL_BATCH_SIZE: 200 * 1024 * 1024, // 200 MB total per merge
  MAX_FILES_PER_MERGE: 20, // Maximum files in single operation
  SUPPORTED_FORMATS: ["pdf", "png", "jpg", "jpeg"],
  CONCURRENT_UPLOADS: 3, // Simultaneous file uploads
};
```

#### Pro Tier Enhancements

```typescript
const PRO_TIER_FILE_LIMITS = {
  MAX_FILE_SIZE: 50 * 1024 * 1024, // 50 MB per file
  MAX_TOTAL_BATCH_SIZE: 1 * 1024 * 1024 * 1024, // 1 GB total per merge
  MAX_FILES_PER_MERGE: 100, // Enhanced batch processing
  SUPPORTED_FORMATS: ["pdf", "png", "jpg", "jpeg", "tiff", "bmp"],
  CONCURRENT_UPLOADS: 10, // Increased parallelism
  PRIORITY_PROCESSING: true, // Faster queue priority
};
```

### Format Support Matrix

#### Supported Input Formats

| Format       | Free Tier | Pro Tier | Max Size (Free) | Max Size (Pro) | Notes                             |
| ------------ | --------- | -------- | --------------- | -------------- | --------------------------------- |
| **PDF**      | ✅ Full   | ✅ Full  | 10 MB           | 50 MB          | Native format, optimal processing |
| **PNG**      | ✅ Full   | ✅ Full  | 10 MB           | 50 MB          | Lossless conversion to PDF        |
| **JPG/JPEG** | ✅ Full   | ✅ Full  | 10 MB           | 50 MB          | Optimized compression handling    |
| **TIFF**     | ❌        | ✅ Full  | -               | 50 MB          | Pro-only high-quality format      |
| **BMP**      | ❌        | ✅ Full  | -               | 25 MB          | Pro-only uncompressed format      |

#### Output Format Specifications

- **Output Format**: PDF only (Adobe PDF 1.4+ compatibility)
- **Quality Preservation**: Original image quality maintained
- **Compression**: Smart compression without quality loss
- **Metadata**: Basic document properties preserved
- **Page Sizing**: Auto-fit with aspect ratio preservation

### Processing Time Limits

#### Timeout Constraints

```typescript
const PROCESSING_TIMEOUTS = {
  FILE_UPLOAD: 5 * 60 * 1000, // 5 minutes per file
  MERGE_OPERATION: 10 * 60 * 1000, // 10 minutes for merge
  TOTAL_OPERATION: 15 * 60 * 1000, // 15 minutes end-to-end
  QUEUE_WAIT_TIME: 3 * 60 * 1000, // 3 minutes queue wait
};
```

#### Performance Expectations

- **Small Files** (<1 MB each): 30-60 seconds total processing
- **Medium Files** (1-5 MB each): 1-3 minutes total processing
- **Large Files** (5-10 MB each): 3-8 minutes total processing
- **Pro Large Files** (10-50 MB each): 5-15 minutes total processing

## User Quota System

### Free Tier Quotas

#### Monthly Usage Limits

```typescript
const FREE_TIER_QUOTAS = {
  MERGES_PER_MONTH: 3, // Three merge operations monthly
  RESET_DAY: 1, // Quota resets on 1st of each month
  STORAGE_DURATION: 7 * 24 * 60 * 60 * 1000, // 7 days download link
  BANDWIDTH_LIMIT: 500 * 1024 * 1024, // 500 MB monthly download
};
```

#### Usage Tracking Implementation

```typescript
interface QuotaStatus {
  userId: string;
  mergesUsed: number;
  mergesRemaining: number;
  bandwidthUsed: number; // bytes
  resetDate: Timestamp;
  planType: "free" | "pro";
}

// Quota enforcement in merge function
async function enforceQuota(userId: string): Promise<void> {
  const quotaDoc = await db.collection("user_quotas").doc(userId).get();
  const quota = quotaDoc.data() as QuotaStatus;

  if (quota.mergesRemaining <= 0) {
    throw new functions.https.HttpsError(
      "resource-exhausted",
      "Monthly merge quota exceeded. Upgrade to Pro for unlimited merges.",
      { upgradeUrl: "/billing/upgrade" }
    );
  }
}
```

### Pro Tier Benefits

#### Unlimited Processing

```typescript
const PRO_TIER_BENEFITS = {
  UNLIMITED_MERGES: true, // No monthly merge limits
  EXTENDED_STORAGE: 30 * 24 * 60 * 60 * 1000, // 30 days download links
  PRIORITY_QUEUE: true, // Jump ahead in processing queue
  PREMIUM_SUPPORT: true, // Priority customer support
  BANDWIDTH_LIMIT: 10 * 1024 * 1024 * 1024, // 10 GB monthly download
  CONCURRENT_OPERATIONS: 3, // Multiple simultaneous merges
};
```

#### Pro Plan Pricing Structure

```json
{
  "file_merger_pro": {
    "monthly": {
      "price": 999, // $9.99/month in cents
      "currency": "usd",
      "features": [
        "unlimited_merges",
        "50mb_file_limit",
        "100_files_per_merge",
        "priority_processing",
        "extended_download_links",
        "premium_support"
      ]
    },
    "annual": {
      "price": 9999, // $99.99/year in cents
      "currency": "usd",
      "discount": "17%", // 2 months free
      "features": ["all_monthly_features"]
    }
  }
}
```

## Technical Performance Limits

### System Resource Constraints

#### Firebase Function Limits

```typescript
const FIREBASE_FUNCTION_LIMITS = {
  MEMORY_ALLOCATION: 2048, // MB per function instance
  CPU_TIMEOUT: 540, // 9 minutes maximum execution
  CONCURRENT_INSTANCES: 1000, // Auto-scaling limit
  COLD_START_TIME: 5, // seconds for initialization
  PAYLOAD_SIZE: 32 * 1024 * 1024, // 32 MB request payload
};
```

#### Memory Management

```typescript
// Memory-efficient file processing
class MemoryManagedMerger {
  private readonly CHUNK_SIZE = 1024 * 1024; // 1 MB chunks
  private readonly MAX_MEMORY_USAGE = 512 * 1024 * 1024; // 512 MB limit

  async mergeFiles(filePaths: string[]): Promise<Buffer> {
    const merger = new PDFMerger();

    for (const filePath of filePaths) {
      // Process files in chunks to manage memory
      const fileStream = this.createFileStream(filePath);
      await merger.add(fileStream);

      // Force garbage collection if memory usage high
      if (process.memoryUsage().heapUsed > this.MAX_MEMORY_USAGE) {
        global.gc?.();
      }
    }

    return merger.saveAsBuffer();
  }
}
```

### Storage System Limits

#### Firebase Storage Constraints

```typescript
const STORAGE_LIMITS = {
  UPLOAD_SIZE_LIMIT: 32 * 1024 * 1024 * 1024, // 32 GB theoretical limit
  DOWNLOAD_BANDWIDTH: 1024 * 1024 * 1024, // 1 GB/day free tier
  OPERATIONS_PER_DAY: 50000, // Free tier operations
  CONCURRENT_UPLOADS: 100, // Per-user concurrent limit
  FILE_NAME_LENGTH: 255, // characters maximum
};
```

#### Temporary File Management

```typescript
// Automatic cleanup system
class TempFileManager {
  private static readonly CLEANUP_INTERVAL = 60 * 60 * 1000; // 1 hour
  private static readonly MAX_FILE_AGE = 24 * 60 * 60 * 1000; // 24 hours

  static async scheduleCleanup(): Promise<void> {
    setInterval(async () => {
      await this.cleanupExpiredFiles();
    }, this.CLEANUP_INTERVAL);
  }

  static async cleanupExpiredFiles(): Promise<void> {
    const bucket = admin.storage().bucket();
    const [files] = await bucket.getFiles({
      prefix: "processing/file_merger/",
    });

    const now = Date.now();
    const expiredFiles = files.filter((file) => {
      const createdTime = new Date(file.metadata.timeCreated).getTime();
      return now - createdTime > this.MAX_FILE_AGE;
    });

    await Promise.all(expiredFiles.map((file) => file.delete()));
  }
}
```

## Security & Access Limits

### Authentication Requirements

#### User Authentication Constraints

```typescript
const AUTH_LIMITS = {
  REQUIRED_AUTH_LEVEL: "verified_email", // Email verification required
  SESSION_TIMEOUT: 24 * 60 * 60 * 1000, // 24 hours
  MAX_FAILED_ATTEMPTS: 5, // Account lockout threshold
  LOCKOUT_DURATION: 15 * 60 * 1000, // 15 minutes lockout
  ANONYMOUS_ACCESS: false, // No anonymous file merging
};
```

#### File Access Control

```typescript
// Security validation for file access
async function validateFileAccess(
  userId: string,
  filePath: string
): Promise<boolean> {
  // Ensure user can only access their own files
  const userPrefix = `uploads/${userId}/`;
  if (!filePath.startsWith(userPrefix)) {
    throw new functions.https.HttpsError(
      "permission-denied",
      "Access denied: Cannot access files from other users"
    );
  }

  // Validate file path format
  const pathRegex =
    /^uploads\/[a-zA-Z0-9_-]+\/file_merger\/[a-zA-Z0-9_-]+\/[^\/]+\.(pdf|png|jpg|jpeg)$/;
  if (!pathRegex.test(filePath)) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Invalid file path format"
    );
  }

  return true;
}
```

### Data Protection Limits

#### Privacy Enforcement

```typescript
const PRIVACY_LIMITS = {
  FILE_RETENTION: 7 * 24 * 60 * 60 * 1000, // 7 days maximum
  METADATA_RETENTION: 30 * 24 * 60 * 60 * 1000, // 30 days for analytics
  AUDIT_LOG_RETENTION: 90 * 24 * 60 * 60 * 1000, // 90 days compliance
  GDPR_DELETION_TIMELINE: 30 * 24 * 60 * 60 * 1000, // 30 days deletion
  NO_CONTENT_ANALYSIS: true, // No file content scanning
};
```

## Error Handling & Rate Limiting

### Rate Limiting Implementation

#### Per-User Rate Limits

```typescript
const RATE_LIMITS = {
  MERGES_PER_HOUR: 10, // Free tier hourly limit
  MERGES_PER_DAY: 20, // Free tier daily limit (beyond monthly quota)
  UPLOADS_PER_MINUTE: 30, // File upload rate limit
  API_CALLS_PER_MINUTE: 100, // General API rate limit
  PRO_MULTIPLIER: 5, // Pro tier gets 5x higher limits
};

// Rate limiting middleware
class RateLimiter {
  private static limits = new Map<string, number[]>();

  static async checkLimit(
    userId: string,
    action: string,
    limit: number,
    windowMs: number
  ): Promise<void> {
    const key = `${userId}:${action}`;
    const now = Date.now();
    const windowStart = now - windowMs;

    // Get recent actions
    const actions = this.limits.get(key) || [];
    const recentActions = actions.filter((time) => time > windowStart);

    if (recentActions.length >= limit) {
      throw new functions.https.HttpsError(
        "resource-exhausted",
        `Rate limit exceeded: Maximum ${limit} ${action} operations per ${
          windowMs / 1000
        } seconds`
      );
    }

    // Record this action
    recentActions.push(now);
    this.limits.set(key, recentActions);
  }
}
```

### Error Response Patterns

#### Standardized Error Messages

```typescript
const ERROR_MESSAGES = {
  QUOTA_EXCEEDED: {
    code: "quota-exceeded",
    message: "Monthly merge quota exceeded",
    action: "upgrade_to_pro",
    details:
      "You have used all 3 free merges this month. Upgrade to Pro for unlimited merges.",
  },
  FILE_TOO_LARGE: {
    code: "file-too-large",
    message: "File size exceeds limit",
    action: "compress_or_upgrade",
    details:
      "File exceeds 10 MB limit. Try compressing the file or upgrade to Pro for 50 MB limit.",
  },
  INVALID_FORMAT: {
    code: "invalid-format",
    message: "Unsupported file format",
    action: "convert_format",
    details:
      "Only PDF, PNG, and JPG files are supported. Convert your file to a supported format.",
  },
  PROCESSING_TIMEOUT: {
    code: "processing-timeout",
    message: "Processing took too long",
    action: "retry_smaller_batch",
    details:
      "Operation exceeded 15-minute limit. Try merging fewer files or smaller files.",
  },
};
```

## Performance Monitoring

### Key Performance Indicators

#### System Metrics Tracking

```typescript
interface PerformanceMetrics {
  processingTime: number; // milliseconds
  fileCount: number;
  totalSize: number; // bytes
  memoryUsage: number; // bytes
  queueWaitTime: number; // milliseconds
  userTier: "free" | "pro";
  timestamp: number;
}

class PerformanceMonitor {
  static async trackOperation(metrics: PerformanceMetrics): Promise<void> {
    // Log to analytics service
    await analytics.track("file_merge_performance", metrics);

    // Check for performance degradation
    if (metrics.processingTime > 10 * 60 * 1000) {
      // 10 minutes
      await this.alertSlowProcessing(metrics);
    }

    // Update performance baselines
    await this.updatePerformanceBaselines(metrics);
  }
}
```

#### Performance Alerts

```typescript
const PERFORMANCE_THRESHOLDS = {
  SLOW_PROCESSING_THRESHOLD: 8 * 60 * 1000, // 8 minutes warning
  HIGH_MEMORY_THRESHOLD: 1.5 * 1024 * 1024 * 1024, // 1.5 GB warning
  QUEUE_BACKUP_THRESHOLD: 5 * 60 * 1000, // 5 minutes queue wait
  ERROR_RATE_THRESHOLD: 0.05, // 5% error rate warning
};
```

## Optimization Strategies

### Performance Optimization

#### File Processing Optimization

```typescript
class OptimizedProcessor {
  // Parallel processing for multiple files
  async processFilesInParallel(files: string[]): Promise<Buffer[]> {
    const BATCH_SIZE = 3; // Process 3 files concurrently
    const results: Buffer[] = [];

    for (let i = 0; i < files.length; i += BATCH_SIZE) {
      const batch = files.slice(i, i + BATCH_SIZE);
      const batchResults = await Promise.all(
        batch.map((file) => this.processFile(file))
      );
      results.push(...batchResults);
    }

    return results;
  }

  // Memory-efficient streaming for large files
  async processLargeFile(filePath: string): Promise<Buffer> {
    const stream = this.createOptimizedStream(filePath);
    return this.processStream(stream);
  }
}
```

### Scaling Considerations

#### Auto-Scaling Configuration

```typescript
const SCALING_CONFIG = {
  MIN_INSTANCES: 1, // Always-warm instance
  MAX_INSTANCES: 100, // Maximum concurrent instances
  TARGET_UTILIZATION: 0.7, // 70% CPU utilization target
  SCALE_UP_THRESHOLD: 0.8, // Scale up at 80% utilization
  SCALE_DOWN_THRESHOLD: 0.3, // Scale down at 30% utilization
  COOLDOWN_PERIOD: 300, // 5 minutes between scaling events
};
```

---

**Performance Review**: Monthly optimization assessment  
**Limit Adjustments**: Quarterly business requirement review  
**Scaling Analysis**: Continuous usage pattern monitoring  
**Optimization Updates**: Bi-annual infrastructure improvements
