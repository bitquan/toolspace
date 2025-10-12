# File Merger - Testing Documentation

**Last Updated**: December 29, 2024  
**Test Framework**: Flutter Test + Jest  
**Coverage Target**: >90%  
**Test Environment**: CI/CD Pipeline

## Testing Overview

File Merger employs comprehensive testing strategies across frontend Flutter components, backend Firebase Functions, integration workflows, and end-to-end user scenarios. The testing approach ensures reliability, security, and performance across all merge operations while maintaining seamless user experience.

### Testing Philosophy

- **Comprehensive Coverage**: Unit, widget, integration, and E2E testing layers
- **Security-First**: Extensive testing of authentication, authorization, and data protection
- **Performance Validation**: Load testing and memory management verification
- **User-Centric**: Real-world scenario testing with diverse file types and sizes
- **Continuous Integration**: Automated testing pipeline with quality gates

## Test Structure Overview

### Frontend Testing (`test/tools/file_merger/`)

```
test/tools/file_merger/
├── file_merger_test.dart              # Unit tests for core logic
├── file_merger_widget_test.dart       # Widget tests for UI components
├── file_merger_integration_test.dart  # Integration tests for workflows
├── models/
│   ├── file_upload_test.dart          # FileUpload model tests
│   └── quota_status_test.dart         # QuotaStatus model tests
├── widgets/
│   ├── file_upload_zone_test.dart     # Upload zone widget tests
│   ├── file_list_test.dart            # File list widget tests
│   ├── merge_progress_test.dart       # Progress widget tests
│   └── quota_banner_test.dart         # Quota banner widget tests
└── logic/
    ├── upload_manager_test.dart       # Upload logic tests
    └── validation_test.dart           # File validation tests
```

### Backend Testing (`functions/src/tools/file_merger/__tests__/`)

```
functions/src/tools/file_merger/__tests__/
├── merge_pdfs.test.ts                 # Main merge function tests
├── quota.test.ts                      # Quota management tests
├── validation.test.ts                 # File validation tests
├── storage.test.ts                    # Storage operations tests
├── billing_integration.test.ts       # Billing system tests
└── performance.test.ts                # Performance and load tests
```

## Unit Testing

### Frontend Unit Tests

#### Core Model Testing

**File**: `test/tools/file_merger/models/file_upload_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:toolspace/tools/file_merger/models/file_upload.dart';

void main() {
  group('FileUpload Model Tests', () {
    test('should create valid FileUpload from PlatformFile', () {
      // Arrange
      final mockFile = MockPlatformFile(
        name: 'test.pdf',
        size: 1024 * 1024, // 1MB
        bytes: Uint8List(1024),
      );

      // Act
      final fileUpload = FileUpload.fromPlatformFile(mockFile);

      // Assert
      expect(fileUpload.name, equals('test.pdf'));
      expect(fileUpload.size, equals(1024 * 1024));
      expect(fileUpload.isValid, isTrue);
      expect(fileUpload.contentType, equals('application/pdf'));
    });

    test('should reject files larger than 10MB', () {
      // Arrange
      final largeMockFile = MockPlatformFile(
        name: 'large.pdf',
        size: 11 * 1024 * 1024, // 11MB
        bytes: Uint8List(1024),
      );

      // Act
      final fileUpload = FileUpload.fromPlatformFile(largeMockFile);

      // Assert
      expect(fileUpload.isValid, isFalse);
      expect(fileUpload.validationError, contains('File size exceeds 10 MB limit'));
    });

    test('should reject unsupported file formats', () {
      // Arrange
      final unsupportedFile = MockPlatformFile(
        name: 'document.docx',
        size: 1024,
        bytes: Uint8List(1024),
      );

      // Act
      final fileUpload = FileUpload.fromPlatformFile(unsupportedFile);

      // Assert
      expect(fileUpload.isValid, isFalse);
      expect(fileUpload.validationError, contains('Unsupported file format'));
    });

    test('should infer correct content types', () {
      // Test cases for content type inference
      final testCases = [
        {'fileName': 'doc.pdf', 'expectedType': 'application/pdf'},
        {'fileName': 'image.png', 'expectedType': 'image/png'},
        {'fileName': 'photo.jpg', 'expectedType': 'image/jpeg'},
        {'fileName': 'picture.jpeg', 'expectedType': 'image/jpeg'},
      ];

      for (final testCase in testCases) {
        // Act
        final contentType = FileUpload.inferContentType(testCase['fileName']!);

        // Assert
        expect(contentType, equals(testCase['expectedType']),
            reason: 'Failed for file: ${testCase['fileName']}');
      }
    });
  });

  group('QuotaStatus Model Tests', () {
    test('should parse quota status from Firebase response', () {
      // Arrange
      final mockResponse = {
        'mergesUsed': 2,
        'mergesRemaining': 1,
        'resetDate': Timestamp.fromDate(DateTime(2025, 1, 1)),
        'planType': 'free',
      };

      // Act
      final quotaStatus = QuotaStatus.fromMap(mockResponse);

      // Assert
      expect(quotaStatus.mergesUsed, equals(2));
      expect(quotaStatus.mergesRemaining, equals(1));
      expect(quotaStatus.planType, equals('free'));
      expect(quotaStatus.isQuotaExceeded, isFalse);
    });

    test('should detect quota exceeded state', () {
      // Arrange
      final quotaExceeded = QuotaStatus(
        mergesUsed: 3,
        mergesRemaining: 0,
        resetDate: DateTime(2025, 1, 1),
        planType: 'free',
      );

      // Assert
      expect(quotaExceeded.isQuotaExceeded, isTrue);
    });
  });
}
```

#### Upload Manager Testing

**File**: `test/tools/file_merger/logic/upload_manager_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:toolspace/tools/file_merger/logic/upload_manager.dart';

void main() {
  group('UploadManager Tests', () {
    late UploadManager uploadManager;
    late MockFirebaseStorage mockStorage;

    setUp(() {
      mockStorage = MockFirebaseStorage();
      uploadManager = UploadManager(storage: mockStorage);
    });

    test('should upload file with progress tracking', () async {
      // Arrange
      final mockFile = MockPlatformFile(name: 'test.pdf', size: 1024);
      final progressValues = <double>[];

      when(mockStorage.ref(any)).thenReturn(MockReference());
      when(mockStorage.ref(any).putData(any)).thenAnswer((_) {
        return MockUploadTask()..progressStream = Stream.fromIterable([
          MockTaskSnapshot(bytesTransferred: 256, totalBytes: 1024),
          MockTaskSnapshot(bytesTransferred: 512, totalBytes: 1024),
          MockTaskSnapshot(bytesTransferred: 1024, totalBytes: 1024),
        ]);
      });

      // Act
      await uploadManager.uploadFile(
        mockFile,
        onProgress: (progress) => progressValues.add(progress),
      );

      // Assert
      expect(progressValues, hasLength(3));
      expect(progressValues.last, equals(1.0));
    });

    test('should generate unique upload paths', () {
      // Arrange
      const userId = 'test-user-123';
      const fileName = 'document.pdf';

      // Act
      final path1 = uploadManager.generateUploadPath(userId, fileName);
      final path2 = uploadManager.generateUploadPath(userId, fileName);

      // Assert
      expect(path1, isNot(equals(path2)));
      expect(path1, startsWith('uploads/$userId/file_merger/'));
      expect(path1, endsWith('_document.pdf'));
    });

    test('should handle upload failures gracefully', () async {
      // Arrange
      final mockFile = MockPlatformFile(name: 'test.pdf', size: 1024);

      when(mockStorage.ref(any).putData(any))
          .thenThrow(FirebaseException(plugin: 'storage', code: 'upload-failed'));

      // Act & Assert
      expect(
        () => uploadManager.uploadFile(mockFile, onProgress: (_) {}),
        throwsA(isA<UploadException>()),
      );
    });
  });
}
```

### Backend Unit Tests

#### Merge Function Testing

**File**: `functions/src/tools/file_merger/__tests__/merge_pdfs.test.ts`

```typescript
import { mergePdfs } from "../merge_pdfs";
import * as admin from "firebase-admin";
import { CallableContext } from "firebase-functions/v1/https";

describe("mergePdfs Function", () => {
  let mockContext: CallableContext;
  let mockStorage: any;

  beforeEach(() => {
    mockContext = {
      auth: { uid: "test-user-123" },
      rawRequest: {},
    } as CallableContext;

    mockStorage = {
      bucket: jest.fn().mockReturnValue({
        file: jest.fn().mockReturnValue({
          exists: jest.fn().mockResolvedValue([true]),
          download: jest
            .fn()
            .mockResolvedValue([Buffer.from("mock-pdf-content")]),
        }),
      }),
    };

    jest.spyOn(admin, "storage").mockReturnValue(mockStorage);
  });

  afterEach(() => {
    jest.restoreAllMocks();
  });

  test("should merge PDF files successfully", async () => {
    // Arrange
    const testData = {
      files: [
        "uploads/test-user-123/file_merger/session1/file1.pdf",
        "uploads/test-user-123/file_merger/session1/file2.pdf",
      ],
    };

    // Mock quota check
    jest.mock("../quota", () => ({
      incrementQuota: jest.fn().mockResolvedValue(undefined),
    }));

    // Act
    const result = await mergePdfs(testData, mockContext);

    // Assert
    expect(result).toHaveProperty("downloadUrl");
    expect(result).toHaveProperty("expiresAt");
    expect(result.downloadUrl).toMatch(/^https:\/\//);
  });

  test("should reject unauthenticated requests", async () => {
    // Arrange
    const unauthenticatedContext = { ...mockContext, auth: null };
    const testData = { files: ["test.pdf"] };

    // Act & Assert
    await expect(mergePdfs(testData, unauthenticatedContext)).rejects.toThrow(
      "Authentication required"
    );
  });

  test("should enforce 20 file limit", async () => {
    // Arrange
    const tooManyFiles = Array.from({ length: 21 }, (_, i) => `file${i}.pdf`);
    const testData = { files: tooManyFiles };

    // Act & Assert
    await expect(mergePdfs(testData, mockContext)).rejects.toThrow(
      "Maximum 20 files allowed per merge"
    );
  });

  test("should handle quota exceeded error", async () => {
    // Arrange
    const testData = { files: ["test.pdf"] };

    // Mock quota exceeded
    jest.mock("../quota", () => ({
      incrementQuota: jest
        .fn()
        .mockRejectedValue(new Error("Monthly merge quota exceeded")),
    }));

    // Act & Assert
    await expect(mergePdfs(testData, mockContext)).rejects.toThrow(
      "quota exceeded"
    );
  });
});
```

#### Quota Management Testing

**File**: `functions/src/tools/file_merger/__tests__/quota.test.ts`

```typescript
import { incrementQuota, getQuotaStatus, QUOTA_LIMITS } from "../quota";
import * as admin from "firebase-admin";

describe("Quota Management", () => {
  let mockFirestore: any;

  beforeEach(() => {
    mockFirestore = {
      collection: jest.fn().mockReturnThis(),
      doc: jest.fn().mockReturnThis(),
      get: jest.fn(),
      runTransaction: jest.fn(),
    };

    jest.spyOn(admin, "firestore").mockReturnValue(mockFirestore);
  });

  test("should increment quota for valid user", async () => {
    // Arrange
    const userId = "test-user-123";
    const mockQuotaData = {
      mergesUsed: 1,
      mergesRemaining: 2,
      resetDate: new Date("2025-01-01"),
      planType: "free",
    };

    mockFirestore.runTransaction.mockImplementation(async (callback) => {
      const mockTransaction = {
        get: jest.fn().mockResolvedValue({
          data: () => mockQuotaData,
        }),
        update: jest.fn(),
      };
      return callback(mockTransaction);
    });

    // Act
    await incrementQuota(userId);

    // Assert
    expect(mockFirestore.runTransaction).toHaveBeenCalled();
  });

  test("should throw error when quota exceeded", async () => {
    // Arrange
    const userId = "test-user-123";
    const mockQuotaData = {
      mergesUsed: 3,
      mergesRemaining: 0,
      resetDate: new Date("2025-01-01"),
      planType: "free",
    };

    mockFirestore.runTransaction.mockImplementation(async (callback) => {
      const mockTransaction = {
        get: jest.fn().mockResolvedValue({
          data: () => mockQuotaData,
        }),
        update: jest.fn(),
      };
      return callback(mockTransaction);
    });

    // Act & Assert
    await expect(incrementQuota(userId)).rejects.toThrow(
      "Monthly merge quota exceeded"
    );
  });

  test("should get quota status correctly", async () => {
    // Arrange
    const userId = "test-user-123";
    const mockQuotaData = {
      mergesUsed: 2,
      mergesRemaining: 1,
      resetDate: admin.firestore.Timestamp.fromDate(new Date("2025-01-01")),
      planType: "free",
    };

    mockFirestore.get.mockResolvedValue({
      exists: true,
      data: () => mockQuotaData,
    });

    // Act
    const quotaStatus = await getQuotaStatus(userId);

    // Assert
    expect(quotaStatus.mergesUsed).toBe(2);
    expect(quotaStatus.mergesRemaining).toBe(1);
    expect(quotaStatus.planType).toBe("free");
  });
});
```

## Widget Testing

### Component Widget Tests

#### File Upload Zone Testing

**File**: `test/tools/file_merger/widgets/file_upload_zone_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toolspace/tools/file_merger/widgets/file_upload_zone.dart';

void main() {
  group('FileUploadZone Widget Tests', () {
    testWidgets('should display upload guidance when enabled', (tester) async {
      // Arrange
      bool filePickerCalled = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FileUploadZone(
              onFilesSelected: () { filePickerCalled = true; },
              isEnabled: true,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Drag files here or click to browse'), findsOneWidget);
      expect(find.text('Supports: PDF, PNG, JPG, JPEG'), findsOneWidget);
      expect(find.text('Max size: 10 MB per file'), findsOneWidget);
    });

    testWidgets('should show disabled state when not enabled', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FileUploadZone(
              onFilesSelected: () {},
              isEnabled: false,
            ),
          ),
        ),
      );

      // Assert
      final uploadZone = tester.widget<Container>(find.byType(Container));
      expect((uploadZone.decoration as BoxDecoration).color,
             equals(Colors.grey.shade200));
    });

    testWidgets('should handle tap to select files', (tester) async {
      // Arrange
      bool filePickerCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FileUploadZone(
              onFilesSelected: () { filePickerCalled = true; },
              isEnabled: true,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(FileUploadZone));
      await tester.pump();

      // Assert
      expect(filePickerCalled, isTrue);
    });
  });
}
```

#### File List Widget Testing

**File**: `test/tools/file_merger/widgets/file_list_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toolspace/tools/file_merger/widgets/file_list.dart';
import 'package:toolspace/tools/file_merger/models/file_upload.dart';

void main() {
  group('FileList Widget Tests', () {
    late List<FileUpload> testFiles;

    setUp(() {
      testFiles = [
        FileUpload(
          name: 'document1.pdf',
          size: 1024 * 1024,
          contentType: 'application/pdf',
          isValid: true,
        ),
        FileUpload(
          name: 'image.png',
          size: 512 * 1024,
          contentType: 'image/png',
          isValid: true,
        ),
      ];
    });

    testWidgets('should display all files in list', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FileList(
              files: testFiles,
              onRemove: (index) {},
              onReorder: (oldIndex, newIndex) {},
              isEnabled: true,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('document1.pdf'), findsOneWidget);
      expect(find.text('image.png'), findsOneWidget);
      expect(find.text('1.0 MB'), findsOneWidget);
      expect(find.text('512.0 KB'), findsOneWidget);
    });

    testWidgets('should handle file removal', (tester) async {
      // Arrange
      int removedIndex = -1;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FileList(
              files: testFiles,
              onRemove: (index) { removedIndex = index; },
              onReorder: (oldIndex, newIndex) {},
              isEnabled: true,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byIcon(Icons.close).first);
      await tester.pump();

      // Assert
      expect(removedIndex, equals(0));
    });

    testWidgets('should show validation errors for invalid files', (tester) async {
      // Arrange
      final invalidFile = FileUpload(
        name: 'invalid.txt',
        size: 1024,
        contentType: 'text/plain',
        isValid: false,
        validationError: 'Unsupported file format',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FileList(
              files: [invalidFile],
              onRemove: (index) {},
              onReorder: (oldIndex, newIndex) {},
              isEnabled: true,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.error), findsOneWidget);
      expect(find.text('Unsupported file format'), findsOneWidget);
    });
  });
}
```

## Integration Testing

### End-to-End Workflow Testing

**File**: `test/tools/file_merger/file_merger_integration_test.dart`

```dart
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:toolspace/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('File Merger Integration Tests', () {
    testWidgets('complete merge workflow with valid files', (tester) async {
      // Initialize app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to File Merger
      await tester.tap(find.text('File Merger'));
      await tester.pumpAndSettle();

      // Mock file selection
      const mockPdfBytes = [0x25, 0x50, 0x44, 0x46]; // PDF header
      const mockImageBytes = [0x89, 0x50, 0x4E, 0x47]; // PNG header

      // Simulate file picker response
      TestDefaultBinaryMessengerBinding.instance?.defaultBinaryMessenger
          .setMockMessageHandler('plugins.flutter.io/file_picker', (message) async {
        return const StandardMethodCodec().encodeSuccessEnvelope([
          {
            'files': [
              {
                'name': 'test1.pdf',
                'size': 1024,
                'bytes': mockPdfBytes,
              },
              {
                'name': 'test2.png',
                'size': 512,
                'bytes': mockImageBytes,
              },
            ]
          }
        ]);
      });

      // Upload files
      await tester.tap(find.text('Drag files here or click to browse'));
      await tester.pumpAndSettle();

      // Verify files appear in list
      expect(find.text('test1.pdf'), findsOneWidget);
      expect(find.text('test2.png'), findsOneWidget);

      // Start merge operation
      await tester.tap(find.text('Merge Files'));
      await tester.pumpAndSettle();

      // Wait for processing to complete (with timeout)
      await tester.pumpAndSettle(const Duration(seconds: 30));

      // Verify success state
      expect(find.text('Merge Complete!'), findsOneWidget);
      expect(find.text('Download'), findsOneWidget);
    });

    testWidgets('quota exceeded scenario', (tester) async {
      // Mock quota exceeded response
      TestDefaultBinaryMessengerBinding.instance?.defaultBinaryMessenger
          .setMockMessageHandler('firebase_functions', (message) async {
        throw PlatformException(
          code: 'quota-exceeded',
          message: 'Monthly merge quota exceeded',
        );
      });

      // Initialize app and navigate to File Merger
      app.main();
      await tester.pumpAndSettle();
      await tester.tap(find.text('File Merger'));
      await tester.pumpAndSettle();

      // Attempt to merge files (assuming files already uploaded)
      await tester.tap(find.text('Merge Files'));
      await tester.pumpAndSettle();

      // Verify quota exceeded message
      expect(find.text('Monthly merge quota exceeded'), findsOneWidget);
      expect(find.text('Upgrade to Pro'), findsOneWidget);
    });
  });
}
```

## Performance Testing

### Load Testing

**File**: `functions/src/tools/file_merger/__tests__/performance.test.ts`

```typescript
import { mergePdfs } from "../merge_pdfs";
import { performance } from "perf_hooks";

describe("File Merger Performance Tests", () => {
  test("should handle large file merges within time limits", async () => {
    // Arrange
    const largeFiles = Array.from(
      { length: 10 },
      (_, i) => `uploads/test-user/large_file_${i}.pdf`
    );

    const mockContext = {
      auth: { uid: "test-user-123" },
    };

    // Act
    const startTime = performance.now();
    await mergePdfs({ files: largeFiles }, mockContext);
    const endTime = performance.now();

    // Assert
    const processingTime = endTime - startTime;
    expect(processingTime).toBeLessThan(300000); // 5 minutes max
  });

  test("should handle concurrent merge operations", async () => {
    // Arrange
    const concurrentOperations = Array.from({ length: 5 }, (_, i) => ({
      files: [`test_file_${i}.pdf`],
      context: { auth: { uid: `user-${i}` } },
    }));

    // Act
    const startTime = performance.now();
    const results = await Promise.all(
      concurrentOperations.map((op) => mergePdfs(op, op.context))
    );
    const endTime = performance.now();

    // Assert
    expect(results).toHaveLength(5);
    expect(endTime - startTime).toBeLessThan(60000); // 1 minute max
  });

  test("should maintain memory usage within limits", async () => {
    // Arrange
    const memoryBefore = process.memoryUsage().heapUsed;

    // Act
    await mergePdfs(
      {
        files: ["large_test_file.pdf"],
      },
      { auth: { uid: "test-user" } }
    );

    // Force garbage collection
    if (global.gc) {
      global.gc();
    }

    const memoryAfter = process.memoryUsage().heapUsed;

    // Assert
    const memoryIncrease = memoryAfter - memoryBefore;
    expect(memoryIncrease).toBeLessThan(100 * 1024 * 1024); // 100MB max increase
  });
});
```

## Security Testing

### Authentication & Authorization Tests

**File**: `functions/src/tools/file_merger/__tests__/security.test.ts`

```typescript
import { mergePdfs } from "../merge_pdfs";
import { CallableContext } from "firebase-functions/v1/https";

describe("File Merger Security Tests", () => {
  test("should reject unauthenticated requests", async () => {
    // Arrange
    const data = { files: ["test.pdf"] };
    const context = {} as CallableContext; // No auth

    // Act & Assert
    await expect(mergePdfs(data, context)).rejects.toThrow(
      "Authentication required"
    );
  });

  test("should prevent path traversal attacks", async () => {
    // Arrange
    const maliciousData = {
      files: ["../../../etc/passwd", "../../../../system/files"],
    };
    const context = { auth: { uid: "test-user" } } as CallableContext;

    // Act & Assert
    await expect(mergePdfs(maliciousData, context)).rejects.toThrow(
      "Invalid file path"
    );
  });

  test("should validate file ownership", async () => {
    // Arrange
    const otherUserFile = "uploads/other-user-123/file.pdf";
    const data = { files: [otherUserFile] };
    const context = { auth: { uid: "current-user-456" } } as CallableContext;

    // Act & Assert
    await expect(mergePdfs(data, context)).rejects.toThrow("Access denied");
  });

  test("should sanitize file inputs", async () => {
    // Arrange
    const maliciousInputs = [
      'uploads/user/file<script>alert("xss")</script>.pdf',
      "uploads/user/file${process.env.SECRET}.pdf",
      "uploads/user/file`rm -rf /`.pdf",
    ];

    // Act & Assert
    for (const maliciousInput of maliciousInputs) {
      await expect(
        mergePdfs({ files: [maliciousInput] }, { auth: { uid: "test-user" } })
      ).rejects.toThrow();
    }
  });
});
```

## Test Automation & CI/CD

### GitHub Actions Integration

**File**: `.github/workflows/file_merger_tests.yml`

```yaml
name: File Merger Tests

on:
  push:
    paths:
      - "lib/tools/file_merger/**"
      - "functions/src/tools/file_merger/**"
      - "test/tools/file_merger/**"

jobs:
  frontend_tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: "3.16.0"

      - name: Install dependencies
        run: flutter pub get

      - name: Run unit tests
        run: flutter test test/tools/file_merger/ --coverage

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: coverage/lcov.info
          flags: frontend,file_merger

  backend_tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: "18"

      - name: Install dependencies
        run: |
          cd functions
          npm ci

      - name: Run Jest tests
        run: |
          cd functions
          npm test -- --testPathPattern=file_merger --coverage

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: functions/coverage/lcov.info
          flags: backend,file_merger

  integration_tests:
    runs-on: ubuntu-latest
    needs: [frontend_tests, backend_tests]
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2

      - name: Run integration tests
        run: flutter test integration_test/file_merger_test.dart
```

### Quality Gates

**Coverage Requirements**:

- Unit Tests: >90% code coverage
- Widget Tests: >85% widget coverage
- Integration Tests: >80% user flow coverage
- Backend Tests: >95% function coverage

**Performance Benchmarks**:

- File merge processing: <5 minutes for 20 files
- UI responsiveness: <100ms for user interactions
- Memory usage: <100MB increase per operation
- Concurrent operations: Support 10+ simultaneous users

---

**Test Execution Schedule**: Every commit to file_merger paths  
**Performance Testing**: Weekly automated benchmarks  
**Security Testing**: Monthly penetration testing  
**User Acceptance Testing**: Quarterly usability studies
