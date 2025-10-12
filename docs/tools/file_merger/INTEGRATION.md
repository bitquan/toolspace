# File Merger - Integration Architecture

**Last Updated**: December 29, 2024  
**Integration Version**: 1.0  
**System Architecture**: Microservices

## Integration Overview

File Merger operates as a comprehensive integration hub within the Toolspace ecosystem, seamlessly connecting frontend Flutter interfaces, backend Firebase Functions, cloud storage systems, billing infrastructure, and cross-tool data sharing mechanisms. The integration architecture prioritizes security, scalability, and seamless user experience across all system touchpoints.

### Core Integration Points

- **Frontend Integration**: Flutter widget system with shared component library
- **Backend Services**: Firebase Functions with secure callable interfaces
- **Storage Systems**: Firebase Storage with encrypted file handling
- **Billing Integration**: Stripe payment processing with quota enforcement
- **Cross-Tool Sharing**: ShareBus data exchange for workflow continuity
- **Authentication**: Unified Firebase Auth across tool ecosystem

## System Architecture

### Frontend Integration Stack

#### Flutter Widget Integration

**Primary Integration**: `lib/tools/file_merger/file_merger_screen.dart`

```dart
// Integration with shared billing services
import '../../billing/billing_service.dart';
import '../../billing/widgets/paywall_guard.dart';

// Integration with shared UI components
import '../../shared/widgets/loading_overlay.dart';
import '../../shared/widgets/error_display.dart';

// Tool-specific component imports
import 'logic/upload_manager.dart';
import 'widgets/file_list.dart';
import 'widgets/file_upload_zone.dart';
import 'widgets/merge_progress.dart';
import 'widgets/quota_banner.dart';
```

#### Shared Service Dependencies

```dart
class FileMergerScreen extends StatefulWidget {
  // Billing service integration
  final BillingService _billingService = BillingService();

  // Firebase services
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Tool-specific services
  final UploadManager _uploadManager = UploadManager();
}
```

#### Route Integration

**Navigation Configuration**: Integrated via `lib/screens/home_screen.dart`

```dart
Tool(
  id: 'file-merger',
  name: 'File Merger',
  description: 'Merge PDFs and images into a single PDF file',
  icon: Icons.merge_type,
  screen: const FileMergerScreen(),
  color: Colors.purple,
  category: ToolCategory.heavy,
  requiresPro: true,
)
```

### Backend Integration Architecture

#### Firebase Functions Integration

**Core Function**: `functions/src/tools/file_merger/merge_pdfs.ts`

```typescript
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import PDFMerger from "pdf-merger-js";
import { v4 as uuid } from "uuid";

// Integration with shared quota system
import { incrementQuota, getQuotaStatus } from "./quota";

// Integration with shared authentication
import { validateAuth } from "../../shared/auth_middleware";

// Integration with shared storage utilities
import {
  generateSignedUrl,
  cleanupTempFiles,
} from "../../shared/storage_utils";
```

#### Shared Service Dependencies

```typescript
// Billing service integration
import { verifyProPlan } from "../../billing/plan_verification";

// Logging and monitoring integration
import { logOperation, trackUsage } from "../../shared/analytics";

// Error handling integration
import { standardErrorResponse } from "../../shared/error_handling";
```

### Storage Integration

#### Firebase Storage Architecture

**File Organization Structure**:

```
/uploads/{userId}/file_merger/{sessionId}/
├── inputs/
│   ├── {fileId}_original.pdf
│   ├── {fileId}_image.png
│   └── {fileId}_document.pdf
├── processing/
│   ├── temp_merge_{timestamp}.pdf
│   └── conversion_cache/
└── outputs/
    └── merged_{sessionId}.pdf
```

#### Upload Management Integration

```dart
// lib/tools/file_merger/logic/upload_manager.dart
class UploadManager {
  // Integration with shared upload utilities
  final StorageService _storageService = StorageService();
  final ProgressTracker _progressTracker = ProgressTracker();

  Future<String> uploadFile(PlatformFile file, Function(double) onProgress) {
    return _storageService.uploadWithProgress(
      file: file,
      path: _generateUploadPath(file.name),
      onProgress: onProgress,
      validateFile: _validateFileForMerging,
    );
  }
}
```

### Billing System Integration

#### Pro Plan Enforcement

**Frontend Integration**:

```dart
// Billing service integration for quota checking
Future<void> _checkQuotaStatus() async {
  final billingStatus = await _billingService.getCurrentPlan();
  final quotaStatus = await _functions.httpsCallable('getQuotaStatus').call();

  setState(() {
    _canPerformMerge = billingStatus.isPro || quotaStatus.data.mergesRemaining > 0;
    _showUpgradePrompt = !billingStatus.isPro && quotaStatus.data.mergesRemaining == 0;
  });
}
```

**Backend Integration**:

```typescript
// functions/src/tools/file_merger/merge_pdfs.ts
export const mergePdfs = functions.https.onCall(async (data, context) => {
  // Authenticate user
  const userId = validateAuth(context);

  // Verify Pro plan or check quota
  const billingStatus = await verifyProPlan(userId);
  if (!billingStatus.isPro) {
    await incrementQuota(userId); // Will throw if quota exceeded
  }

  // Proceed with merge operation
  return await processMergeOperation(data.files, userId);
});
```

#### Quota Management Integration

```typescript
// functions/src/tools/file_merger/quota.ts
import { Timestamp } from "firebase-admin/firestore";

export interface QuotaStatus {
  mergesUsed: number;
  mergesRemaining: number;
  resetDate: Timestamp;
  planType: "free" | "pro";
}

export async function incrementQuota(userId: string): Promise<void> {
  const db = admin.firestore();
  const quotaDoc = db.collection("user_quotas").doc(userId);

  return db.runTransaction(async (transaction) => {
    const doc = await transaction.get(quotaDoc);
    const currentQuota = doc.data() as QuotaStatus;

    if (currentQuota.mergesRemaining <= 0) {
      throw new functions.https.HttpsError(
        "resource-exhausted",
        "Monthly merge quota exceeded. Upgrade to Pro for unlimited merges."
      );
    }

    transaction.update(quotaDoc, {
      mergesUsed: currentQuota.mergesUsed + 1,
      mergesRemaining: currentQuota.mergesRemaining - 1,
    });
  });
}
```

## Cross-Tool Integration

### ShareBus Data Exchange

#### Merged PDF Sharing

```dart
// Integration with ShareBus for cross-tool data sharing
import '../../shared/services/share_bus.dart';

class FileMergerScreen extends StatefulWidget {
  final ShareBus _shareBus = ShareBus.instance;

  Future<void> _shareMergedPDF(String downloadUrl, String fileName) async {
    await _shareBus.shareData(
      type: ShareDataType.pdfDocument,
      data: {
        'url': downloadUrl,
        'fileName': fileName,
        'source': 'file_merger',
        'fileSize': _calculateFileSize(),
        'pageCount': _getPageCount(),
        'expiresAt': DateTime.now().add(Duration(days: 7)),
      },
      metadata: {
        'tool': 'file_merger',
        'operation': 'merge_complete',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
}
```

#### Receiving External Files

```dart
// Integration for receiving files from other tools
Future<void> _handleExternalFiles() async {
  _shareBus.listen<List<ShareData>>(
    type: ShareDataType.fileList,
    callback: (sharedFiles) {
      final pdfFiles = sharedFiles
          .where((file) => file.data['mimeType']?.startsWith('application/pdf') == true)
          .toList();

      if (pdfFiles.isNotEmpty) {
        _showImportDialog(pdfFiles);
      }
    },
  );
}
```

### Tool Interoperability

#### Integration with Text Tools

```dart
// Workflow: Text Tools → PDF generation → File Merger input
class TextToolsIntegration {
  static Future<void> sendGeneratedPDF(String pdfPath) async {
    await ShareBus.instance.shareData(
      type: ShareDataType.pdfDocument,
      data: {
        'filePath': pdfPath,
        'source': 'text_tools',
        'suggestedWorkflow': 'merge_with_existing',
      },
    );
  }
}
```

#### Integration with QR Maker

```dart
// Workflow: QR Maker → PDF generation → File Merger batch processing
class QRMakerIntegration {
  static Future<void> sendQRBatch(List<String> qrPdfPaths) async {
    await ShareBus.instance.shareData(
      type: ShareDataType.batchFiles,
      data: {
        'files': qrPdfPaths,
        'source': 'qr_maker',
        'batchSize': qrPdfPaths.length,
        'recommendedAction': 'merge_qr_batch',
      },
    );
  }
}
```

### Authentication Integration

#### Unified Auth Flow

```dart
// Shared authentication state management
class AuthenticationIntegration {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  static Future<bool> ensureAuthenticated() async {
    final user = _auth.currentUser;
    if (user == null) {
      // Redirect to shared auth flow
      return await Navigator.pushNamed(context, '/auth');
    }
    return true;
  }
}
```

#### User Context Sharing

```dart
// Shared user context for quota and billing
class UserContextService {
  static UserContext? _currentContext;

  static Future<UserContext> getCurrentContext() async {
    if (_currentContext == null) {
      final user = FirebaseAuth.instance.currentUser!;
      final billingStatus = await BillingService().getCurrentPlan();
      final quotaStatus = await QuotaService().getStatus(user.uid);

      _currentContext = UserContext(
        userId: user.uid,
        email: user.email,
        billingPlan: billingStatus.planType,
        quotaStatus: quotaStatus,
      );
    }
    return _currentContext!;
  }
}
```

## API Integration Patterns

### Frontend-Backend Communication

#### Callable Function Integration

```dart
// Standardized callable function wrapper
class CloudFunctionService {
  static final FirebaseFunctions _functions = FirebaseFunctions.instance;

  static Future<T> callFunction<T>(
    String functionName,
    Map<String, dynamic> data, {
    Duration timeout = const Duration(minutes: 5),
  }) async {
    try {
      final callable = _functions.httpsCallable(
        functionName,
        options: HttpsCallableOptions(timeout: timeout),
      );

      final result = await callable.call(data);
      return result.data as T;
    } on FirebaseFunctionsException catch (e) {
      throw _handleFunctionError(e);
    }
  }
}
```

#### Error Handling Integration

```dart
// Shared error handling for consistent user experience
class ErrorHandlingService {
  static String getDisplayMessage(dynamic error) {
    if (error is FirebaseFunctionsException) {
      switch (error.code) {
        case 'quota-exceeded':
          return 'You\'ve reached your monthly merge limit. Upgrade to Pro for unlimited merges.';
        case 'file-too-large':
          return 'File size exceeds the 10 MB limit. Try compressing or upgrading to Pro.';
        case 'invalid-format':
          return 'File format not supported. Please use PDF, PNG, or JPG files.';
        default:
          return 'An error occurred during file processing. Please try again.';
      }
    }
    return 'An unexpected error occurred. Please contact support if this persists.';
  }
}
```

### External Service Integration

#### Stripe Billing Integration

```typescript
// Backend integration with Stripe for Pro plan verification
import Stripe from "stripe";

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, {
  apiVersion: "2023-10-16",
});

export async function verifyProPlan(userId: string): Promise<BillingStatus> {
  const db = admin.firestore();
  const userDoc = await db.collection("users").doc(userId).get();
  const userData = userDoc.data();

  if (!userData?.stripeSubscriptionId) {
    return { isPro: false, planType: "free" };
  }

  const subscription = await stripe.subscriptions.retrieve(
    userData.stripeSubscriptionId
  );

  return {
    isPro: subscription.status === "active",
    planType: subscription.status === "active" ? "pro" : "free",
    subscriptionStatus: subscription.status,
  };
}
```

#### PDF Processing Integration

```typescript
// Integration with pdf-merger-js library
import PDFMerger from "pdf-merger-js";

export async function mergeFilesToPDF(
  filePaths: string[],
  outputPath: string
): Promise<string> {
  const merger = new PDFMerger();

  for (const filePath of filePaths) {
    const fileBuffer = await downloadFileBuffer(filePath);
    await merger.add(fileBuffer);
  }

  const mergedPdfBuffer = await merger.saveAsBuffer();
  const outputUrl = await uploadProcessedFile(mergedPdfBuffer, outputPath);

  return outputUrl;
}
```

## Security Integration

### Authentication & Authorization

#### Security Layer Integration

```typescript
// Shared security middleware for all functions
export function validateAuth(context: functions.https.CallableContext): string {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Authentication required"
    );
  }

  return context.auth.uid;
}

export async function validateFileAccess(
  userId: string,
  filePath: string
): Promise<boolean> {
  // Ensure user can only access their own files
  return filePath.startsWith(`uploads/${userId}/`);
}
```

#### Data Protection Integration

```typescript
// Encryption utilities for sensitive data
import { encrypt, decrypt } from "../../shared/encryption";

export async function storeSecureFileMetadata(
  userId: string,
  fileMetadata: FileMetadata
): Promise<void> {
  const encryptedMetadata = encrypt(JSON.stringify(fileMetadata));

  await admin
    .firestore()
    .collection("file_metadata")
    .doc(`${userId}_${fileMetadata.fileId}`)
    .set({
      encryptedData: encryptedMetadata,
      createdAt: admin.firestore.Timestamp.now(),
    });
}
```

### Storage Security Integration

#### Access Control Integration

```typescript
// Storage security rules integration
export const storageSecurityRules = `
  rules_version = '2';
  service firebase.storage {
    match /b/{bucket}/o {
      // File Merger specific rules
      match /uploads/{userId}/file_merger/{allPaths=**} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
        allow delete: if request.auth != null && request.auth.uid == userId;
      }
      
      // Temporary processing files (auto-cleanup)
      match /processing/file_merger/{allPaths=**} {
        allow read, write: if request.auth != null;
        // Files automatically deleted after 24 hours
      }
    }
  }
`;
```

## Performance Integration

### Caching Strategy

#### Frontend Caching Integration

```dart
// Shared caching service for improved performance
class CacheService {
  static final Map<String, dynamic> _cache = {};

  static Future<T?> get<T>(String key) async {
    final cached = _cache[key];
    if (cached != null && cached['expiry'].isAfter(DateTime.now())) {
      return cached['data'] as T;
    }
    return null;
  }

  static void set<T>(String key, T data, Duration ttl) {
    _cache[key] = {
      'data': data,
      'expiry': DateTime.now().add(ttl),
    };
  }
}
```

#### Backend Caching Integration

```typescript
// Redis integration for function-level caching
import { Redis } from "ioredis";

const redis = new Redis(process.env.REDIS_URL!);

export async function getCachedQuotaStatus(
  userId: string
): Promise<QuotaStatus | null> {
  const cached = await redis.get(`quota:${userId}`);
  return cached ? JSON.parse(cached) : null;
}

export async function setCachedQuotaStatus(
  userId: string,
  status: QuotaStatus,
  ttlSeconds: number = 300
): Promise<void> {
  await redis.setex(`quota:${userId}`, ttlSeconds, JSON.stringify(status));
}
```

### Monitoring Integration

#### Analytics Integration

```typescript
// Shared analytics service for usage tracking
import { Analytics } from "../../shared/analytics";

export async function trackMergeOperation(
  userId: string,
  fileCount: number,
  totalSize: number,
  processingTime: number
): Promise<void> {
  await Analytics.track("file_merge_completed", {
    userId,
    fileCount,
    totalSizeMB: Math.round(totalSize / 1024 / 1024),
    processingTimeMs: processingTime,
    timestamp: Date.now(),
  });
}
```

#### Error Monitoring Integration

```typescript
// Integration with error tracking service
import * as Sentry from "@sentry/node";

export function setupErrorMonitoring(): void {
  Sentry.init({
    dsn: process.env.SENTRY_DSN,
    integrations: [new Sentry.Integrations.Firebase()],
  });
}

export function reportError(error: Error, context: Record<string, any>): void {
  Sentry.withScope((scope) => {
    scope.setContext("file_merger", context);
    Sentry.captureException(error);
  });
}
```

---

**Integration Review Schedule**: Quarterly architecture assessment  
**API Compatibility**: Semantic versioning with backward compatibility  
**Security Audit**: Monthly penetration testing and vulnerability assessment  
**Performance Optimization**: Continuous monitoring with automated scaling
