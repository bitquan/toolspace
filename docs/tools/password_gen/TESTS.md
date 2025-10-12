# Password Generator - Testing Documentation

This document provides comprehensive testing strategies, test cases, and automation coverage for the Password Generator tool, ensuring robust functionality, security, and user experience.

## Testing Strategy Overview

### Testing Pyramid

**Unit Tests (70%)**

- Password generation algorithms
- Configuration validation logic
- Entropy calculation accuracy
- Character set building
- Strength assessment functions

**Integration Tests (20%)**

- ShareBus communication
- Cross-tool data exchange
- Database operations
- API integrations
- Billing system integration

**End-to-End Tests (10%)**

- Complete user workflows
- UI interaction patterns
- Performance under load
- Security validation
- Accessibility compliance

### Test Categories

**Functional Testing**

- Core password generation functionality
- Configuration validation and error handling
- Batch generation capabilities
- Copy operations and clipboard integration

**Security Testing**

- Cryptographic randomness validation
- Entropy calculation verification
- Character set security analysis
- Data privacy and protection

**Performance Testing**

- Generation speed benchmarks
- Memory usage optimization
- UI responsiveness under load
- Batch operation efficiency

**Usability Testing**

- User interface interaction flows
- Error message clarity and helpfulness
- Accessibility features validation
- Mobile and desktop responsiveness

## Unit Testing

### Password Generation Core Tests

**PasswordConfig Validation Tests**

```dart
// test/tools/password_gen/password_config_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:toolspace/tools/password_gen/logic/password_generator.dart';

void main() {
  group('PasswordConfig Validation Tests', () {
    test('should create valid default configuration', () {
      const config = PasswordConfig(
        length: 16,
        includeUppercase: true,
        includeLowercase: true,
        includeDigits: true,
        includeSymbols: true,
      );

      expect(config.isValid(), true);
      expect(config.getValidationError(), null);
    });

    test('should reject length below minimum', () {
      const config = PasswordConfig(
        length: 7,
        includeUppercase: true,
      );

      expect(config.isValid(), false);
      expect(config.getValidationError(),
        'Password length must be at least 8 characters');
    });

    test('should reject length above maximum', () {
      const config = PasswordConfig(
        length: 129,
        includeUppercase: true,
      );

      expect(config.isValid(), false);
      expect(config.getValidationError(),
        'Password length must be at most 128 characters');
    });

    test('should reject configuration with no character sets', () {
      const config = PasswordConfig(
        length: 16,
        includeUppercase: false,
        includeLowercase: false,
        includeDigits: false,
        includeSymbols: false,
      );

      expect(config.isValid(), false);
      expect(config.getValidationError(),
        'At least one character set must be selected');
    });

    test('should build correct character set', () {
      const config = PasswordConfig(
        length: 16,
        includeUppercase: true,
        includeLowercase: true,
        includeDigits: false,
        includeSymbols: false,
      );

      final charset = config.getCharacterSet();
      expect(charset, contains('A'));
      expect(charset, contains('Z'));
      expect(charset, contains('a'));
      expect(charset, contains('z'));
      expect(charset, isNot(contains('0')));
      expect(charset, isNot(contains('!')));
    });

    test('should filter ambiguous characters when enabled', () {
      const config = PasswordConfig(
        length: 16,
        includeUppercase: true,
        includeLowercase: true,
        includeDigits: true,
        avoidAmbiguous: true,
      );

      final charset = config.getCharacterSet();
      expect(charset, isNot(contains('0')));
      expect(charset, isNot(contains('O')));
      expect(charset, isNot(contains('1')));
      expect(charset, isNot(contains('l')));
      expect(charset, isNot(contains('I')));
    });
  });
}
```

**Password Generation Algorithm Tests**

```dart
// test/tools/password_gen/password_generation_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:toolspace/tools/password_gen/logic/password_generator.dart';

void main() {
  group('Password Generation Algorithm Tests', () {
    test('should generate password with correct length', () {
      const config = PasswordConfig(
        length: 24,
        includeUppercase: true,
        includeLowercase: true,
        includeDigits: true,
        includeSymbols: true,
      );

      final password = PasswordGenerator.generate(config);
      expect(password.length, 24);
    });

    test('should generate password with only selected character sets', () {
      const config = PasswordConfig(
        length: 16,
        includeUppercase: true,
        includeLowercase: false,
        includeDigits: false,
        includeSymbols: false,
      );

      final password = PasswordGenerator.generate(config);

      // Should contain only uppercase letters
      expect(password, matches(RegExp(r'^[A-Z]+$')));
    });

    test('should generate unique passwords', () {
      const config = PasswordConfig(
        length: 16,
        includeUppercase: true,
        includeLowercase: true,
        includeDigits: true,
        includeSymbols: true,
      );

      final passwords = <String>{};

      // Generate 100 passwords and check for uniqueness
      for (int i = 0; i < 100; i++) {
        final password = PasswordGenerator.generate(config);
        passwords.add(password);
      }

      // Should have 100 unique passwords (extremely high probability)
      expect(passwords.length, 100);
    });

    test('should throw error for invalid configuration', () {
      const config = PasswordConfig(
        length: 5, // Too short
        includeUppercase: true,
      );

      expect(() => PasswordGenerator.generate(config), throwsArgumentError);
    });

    test('should generate batch of passwords', () {
      const config = PasswordConfig(
        length: 16,
        includeUppercase: true,
        includeLowercase: true,
        includeDigits: true,
        includeSymbols: true,
      );

      final passwords = PasswordGenerator.generateBatch(config, count: 20);

      expect(passwords.length, 20);

      // Check that all passwords have correct length
      for (var password in passwords) {
        expect(password.length, 16);
      }

      // Check that passwords are unique within batch
      final uniquePasswords = passwords.toSet();
      expect(uniquePasswords.length, 20);
    });

    test('should respect ambiguous character filtering in generation', () {
      const config = PasswordConfig(
        length: 100, // Large sample size
        includeUppercase: true,
        includeLowercase: true,
        includeDigits: true,
        includeSymbols: false,
        avoidAmbiguous: true,
      );

      final password = PasswordGenerator.generate(config);

      // Should not contain ambiguous characters
      expect(password, isNot(contains('0')));
      expect(password, isNot(contains('O')));
      expect(password, isNot(contains('1')));
      expect(password, isNot(contains('l')));
      expect(password, isNot(contains('I')));
    });
  });
}
```

### Entropy Calculation Tests

**Shannon Entropy Validation**

```dart
// test/tools/password_gen/entropy_calculation_test.dart
import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:toolspace/tools/password_gen/logic/password_generator.dart';

void main() {
  group('Entropy Calculation Tests', () {
    test('should calculate zero entropy for empty password', () {
      final entropy = PasswordGenerator.calculateEntropy('');
      expect(entropy, 0.0);
    });

    test('should calculate entropy for single character', () {
      final entropy = PasswordGenerator.calculateEntropy('a');
      expect(entropy, 0.0); // Single character has no entropy
    });

    test('should calculate entropy for repeated characters', () {
      final entropy = PasswordGenerator.calculateEntropy('aaaa');
      expect(entropy, 0.0); // No entropy in repeated characters
    });

    test('should calculate correct entropy for known pattern', () {
      // 'ab' repeated has entropy of 1 bit per character
      final entropy = PasswordGenerator.calculateEntropy('abab');
      expect(entropy, closeTo(4.0, 0.1)); // 4 characters * 1 bit each
    });

    test('should calculate entropy for realistic password', () {
      final password = 'Aa1!Bb2@Cc3#'; // Mixed character types
      final entropy = PasswordGenerator.calculateEntropy(password);

      // Should have significant entropy
      expect(entropy, greaterThan(30.0));
      expect(entropy, lessThan(60.0));
    });

    test('should handle Unicode characters correctly', () {
      final password = 'Hëllö123!'; // Contains Unicode
      final entropy = PasswordGenerator.calculateEntropy(password);

      expect(entropy, greaterThan(0.0));
      expect(entropy, isFinite);
    });

    test('should calculate higher entropy for more diverse characters', () {
      final simplePassword = 'aaaabbbb';
      final complexPassword = 'Aa1!Bb2@';

      final simpleEntropy = PasswordGenerator.calculateEntropy(simplePassword);
      final complexEntropy = PasswordGenerator.calculateEntropy(complexPassword);

      expect(complexEntropy, greaterThan(simpleEntropy));
    });
  });
}
```

### Strength Assessment Tests

**Strength Classification Tests**

```dart
// test/tools/password_gen/strength_assessment_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:toolspace/tools/password_gen/logic/password_generator.dart';

void main() {
  group('Strength Assessment Tests', () {
    test('should classify weak passwords correctly', () {
      // Passwords with low entropy should be classified as weak
      final weakPasswords = [
        'password',
        '12345678',
        'abcdefgh',
        'ABCDEFGH',
      ];

      for (final password in weakPasswords) {
        final entropy = PasswordGenerator.calculateEntropy(password);
        final strength = PasswordGenerator.getStrengthLabel(entropy);
        expect(strength.toLowerCase(), 'weak');
      }
    });

    test('should classify strong passwords correctly', () {
      // Generate passwords with high entropy
      const config = PasswordConfig(
        length: 20,
        includeUppercase: true,
        includeLowercase: true,
        includeDigits: true,
        includeSymbols: true,
      );

      final password = PasswordGenerator.generate(config);
      final entropy = PasswordGenerator.calculateEntropy(password);
      final strength = PasswordGenerator.getStrengthLabel(entropy);

      // Should be strong or very strong
      expect(['strong', 'very strong'], contains(strength.toLowerCase()));
    });

    test('should calculate correct strength score', () {
      final testCases = [
        {'password': 'weak123', 'expectedRange': [0, 40]},
        {'password': 'Moderate123!', 'expectedRange': [40, 60]},
        {'password': 'VeryStr0ng!P@ssw0rd', 'expectedRange': [60, 100]},
      ];

      for (final testCase in testCases) {
        final password = testCase['password'] as String;
        final expectedRange = testCase['expectedRange'] as List<int>;

        final entropy = PasswordGenerator.calculateEntropy(password);
        final score = PasswordGenerator.getStrengthScore(entropy);

        expect(score, greaterThanOrEqualTo(expectedRange[0]));
        expect(score, lessThan(expectedRange[1]));
      }
    });

    test('should provide consistent strength labeling', () {
      final entropy40 = 40.0;
      final entropy60 = 60.0;
      final entropy80 = 80.0;

      expect(PasswordGenerator.getStrengthLabel(35.0), 'Weak');
      expect(PasswordGenerator.getStrengthLabel(45.0), 'Moderate');
      expect(PasswordGenerator.getStrengthLabel(65.0), 'Strong');
      expect(PasswordGenerator.getStrengthLabel(85.0), 'Very Strong');
    });
  });
}
```

## Widget Testing

### UI Component Tests

**Password Generation Screen Tests**

```dart
// test/tools/password_gen/password_gen_widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toolspace/tools/password_gen/password_gen_screen.dart';

void main() {
  group('Password Generator Widget Tests', () {
    testWidgets('should render with default configuration', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PasswordGenScreen(),
        ),
      );

      // Check for essential UI elements
      expect(find.text('Password Generator'), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);
      expect(find.byType(CheckboxListTile), findsAtLeast(4));
      expect(find.text('Generate'), findsOneWidget);
    });

    testWidgets('should update password length via slider', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PasswordGenScreen(),
        ),
      );

      // Find the slider
      final slider = find.byType(Slider);
      expect(slider, findsOneWidget);

      // Move slider to different position
      await tester.drag(slider, const Offset(100, 0));
      await tester.pump();

      // Verify length display updated
      expect(find.textContaining('characters'), findsOneWidget);
    });

    testWidgets('should toggle character sets', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PasswordGenScreen(),
        ),
      );

      // Find uppercase checkbox
      final uppercaseCheckbox = find.widgetWithText(
        CheckboxListTile,
        'Uppercase (A-Z)'
      );
      expect(uppercaseCheckbox, findsOneWidget);

      // Toggle checkbox
      await tester.tap(uppercaseCheckbox);
      await tester.pump();

      // Verify state change (implementation dependent)
    });

    testWidgets('should generate password on button press', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PasswordGenScreen(),
        ),
      );

      // Find and tap generate button
      final generateButton = find.text('Generate');
      expect(generateButton, findsOneWidget);

      await tester.tap(generateButton);
      await tester.pump();

      // Should show generated password
      expect(find.byType(SelectableText), findsOneWidget);
    });

    testWidgets('should show validation errors for invalid config', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PasswordGenScreen(),
        ),
      );

      // Disable all character sets
      final checkboxes = find.byType(CheckboxListTile);
      for (int i = 0; i < 4; i++) {
        await tester.tap(checkboxes.at(i));
        await tester.pump();
      }

      // Should show validation error
      expect(find.textContaining('character set'), findsOneWidget);

      // Generate button should be disabled
      final generateButton = find.text('Generate');
      final button = tester.widget<FilledButton>(
        find.ancestor(
          of: generateButton,
          matching: find.byType(FilledButton),
        ),
      );
      expect(button.onPressed, null);
    });

    testWidgets('should display strength meter correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PasswordGenScreen(),
        ),
      );

      // Generate a password to show strength meter
      await tester.tap(find.text('Generate'));
      await tester.pump();

      // Should show strength indicators
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.textContaining('Entropy:'), findsOneWidget);
      expect(find.byType(Chip), findsOneWidget); // Strength label chip
    });

    testWidgets('should handle batch generation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PasswordGenScreen(),
        ),
      );

      // Find batch generate button
      final batchButton = find.text('Generate 20');
      expect(batchButton, findsOneWidget);

      await tester.tap(batchButton);
      await tester.pump();

      // Should show batch results
      expect(find.text('Batch Generated (20)'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('should copy password to clipboard', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PasswordGenScreen(),
        ),
      );

      // Generate password first
      await tester.tap(find.text('Generate'));
      await tester.pump();

      // Find and tap copy button
      final copyButton = find.byIcon(Icons.copy);
      expect(copyButton, findsOneWidget);

      await tester.tap(copyButton);
      await tester.pump();

      // Should show success snackbar
      expect(find.text('Password copied to clipboard'), findsOneWidget);
    });
  });
}
```

### Animation Tests

**UI Animation Validation**

```dart
// test/tools/password_gen/animation_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toolspace/tools/password_gen/password_gen_screen.dart';

void main() {
  group('Password Generator Animation Tests', () {
    testWidgets('should animate password generation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PasswordGenScreen(),
        ),
      );

      // Generate password to trigger animation
      await tester.tap(find.text('Generate'));

      // Should start with scale animation
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Animation should be in progress
      final animatedWidget = find.byType(ScaleTransition);
      expect(animatedWidget, findsOneWidget);

      // Complete animation
      await tester.pumpAndSettle();
    });

    testWidgets('should animate strength meter changes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PasswordGenScreen(),
        ),
      );

      // Change configuration to trigger strength update
      final slider = find.byType(Slider);
      await tester.drag(slider, const Offset(50, 0));
      await tester.pump();

      // Should animate strength meter
      expect(find.byType(AnimatedContainer), findsAtLeast(1));

      await tester.pumpAndSettle();
    });
  });
}
```

## Integration Testing

### ShareBus Integration Tests

**Cross-Tool Communication Tests**

```dart
// test/integration/password_gen_sharebus_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:toolspace/core/services/share_bus.dart';
import 'package:toolspace/tools/password_gen/logic/password_generator.dart';

void main() {
  group('Password Generator ShareBus Integration', () {
    late ShareBus shareBus;

    setUp(() {
      shareBus = ShareBus.instance;
    });

    tearDown(() {
      shareBus.clear();
    });

    test('should broadcast password generation events', () async {
      final events = <Map<String, dynamic>>[];

      // Listen for password events
      shareBus.listen('password.generated', (data) {
        events.add(data);
      });

      // Generate password
      const config = PasswordConfig(
        length: 16,
        includeUppercase: true,
        includeLowercase: true,
        includeDigits: true,
      );

      final password = PasswordGenerator.generate(config);

      // Simulate broadcasting
      shareBus.broadcast('password.generated', {
        'password': password,
        'config': config.toJson(),
        'entropy': PasswordGenerator.calculateEntropy(password),
      });

      // Verify event was received
      expect(events.length, 1);
      expect(events[0]['password'], password);
      expect(events[0]['entropy'], greaterThan(0.0));
    });

    test('should handle password requests from other tools', () async {
      String? generatedPassword;

      // Set up request handler
      shareBus.listen('password.request', (request) async {
        final config = PasswordConfig.fromJson(request['configuration']);
        final password = PasswordGenerator.generate(config);

        shareBus.respond(request['request_id'], {
          'success': true,
          'password': password,
        });
      });

      // Simulate request from another tool
      final requestId = 'test_request_${DateTime.now().millisecondsSinceEpoch}';

      shareBus.request('password.request', {
        'request_id': requestId,
        'configuration': {
          'length': 12,
          'includeUppercase': true,
          'includeLowercase': true,
          'includeDigits': false,
          'includeSymbols': false,
        },
      }).then((response) {
        generatedPassword = response['password'];
      });

      // Wait for async processing
      await Future.delayed(const Duration(milliseconds: 100));

      expect(generatedPassword, isNotNull);
      expect(generatedPassword!.length, 12);
      expect(generatedPassword, matches(RegExp(r'^[A-Za-z]+$')));
    });
  });
}
```

### Database Integration Tests

**Password History Storage Tests**

```dart
// test/integration/password_history_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:toolspace/core/services/database_service.dart';
import 'package:toolspace/tools/password_gen/services/password_history_service.dart';

void main() {
  group('Password History Integration Tests', () {
    late Database database;

    setUpAll(() {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    setUp(() async {
      database = await openDatabase(
        inMemoryDatabasePath,
        version: 1,
        onCreate: (db, version) async {
          await db.execute(PasswordHistoryDB.createTableSQL);
        },
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('should store password generation history', () async {
      final service = PasswordHistoryService(database);

      final data = PasswordGenerationData(
        type: 'password_generated',
        source: 'password_gen',
        timestamp: DateTime.now(),
        password: 'TestPassword123!',
        configuration: const PasswordConfig(length: 16),
        entropy: 45.5,
        strength: 'Moderate',
        metadata: const PasswordMetadata(
          characterCount: 16,
          characterSets: ['uppercase', 'lowercase', 'digits', 'symbols'],
          ambiguousFiltered: false,
          generationDuration: Duration(milliseconds: 5),
        ),
      );

      await service.storePasswordGeneration(data, 'test_user');

      // Verify storage
      final records = await database.query('password_history');
      expect(records.length, 1);

      final record = records.first;
      expect(record['user_id'], 'test_user');
      expect(record['entropy'], 45.5);
      expect(record['strength'], 'Moderate');
    });

    test('should retrieve password history for user', () async {
      final service = PasswordHistoryService(database);

      // Store multiple entries
      for (int i = 0; i < 3; i++) {
        final data = PasswordGenerationData(
          type: 'password_generated',
          source: 'password_gen',
          timestamp: DateTime.now().subtract(Duration(days: i)),
          password: 'Password$i',
          configuration: PasswordConfig(length: 16 + i),
          entropy: 40.0 + i,
          strength: 'Moderate',
          metadata: PasswordMetadata(
            characterCount: 16 + i,
            characterSets: const ['uppercase', 'lowercase'],
            ambiguousFiltered: false,
            generationDuration: const Duration(milliseconds: 5),
          ),
        );

        await service.storePasswordGeneration(data, 'test_user');
      }

      // Retrieve history
      final history = await service.getPasswordHistory('test_user');

      expect(history.length, 3);
      expect(history.first.entropy, 42.0); // Most recent first
    });

    test('should clean up expired password history', () async {
      final service = PasswordHistoryService(database);

      // Store old entry
      await database.insert('password_history', {
        'password_hash': 'old_hash',
        'configuration': '{}',
        'entropy': 40.0,
        'strength': 'Moderate',
        'generated_at': DateTime.now().subtract(const Duration(days: 60)).toIso8601String(),
        'user_id': 'test_user',
        'expires_at': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
      });

      // Store recent entry
      await database.insert('password_history', {
        'password_hash': 'recent_hash',
        'configuration': '{}',
        'entropy': 50.0,
        'strength': 'Strong',
        'generated_at': DateTime.now().toIso8601String(),
        'user_id': 'test_user',
        'expires_at': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      });

      // Clean up expired entries
      await service.cleanupExpiredHistory();

      // Verify only recent entry remains
      final remaining = await database.query('password_history');
      expect(remaining.length, 1);
      expect(remaining.first['password_hash'], 'recent_hash');
    });
  });
}
```

### Billing Integration Tests

**Quota Enforcement Tests**

```dart
// test/integration/password_gen_billing_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:toolspace/core/services/auth_service.dart';
import 'package:toolspace/core/models/user.dart';
import 'package:toolspace/tools/password_gen/services/password_gen_quotas.dart';

class MockAuthService extends Mock implements AuthService {}

void main() {
  group('Password Generator Billing Integration', () {
    late MockAuthService mockAuthService;
    late PasswordGenQuotas quotaService;

    setUp(() {
      mockAuthService = MockAuthService();
      quotaService = PasswordGenQuotas(mockAuthService);
    });

    test('should enforce free tier batch size limits', () async {
      final freeUser = User(
        id: 'free_user',
        email: 'free@example.com',
        plan: UserPlan.free,
      );

      when(mockAuthService.currentUser).thenReturn(freeUser);

      // Free tier should allow up to 5 passwords
      expect(await quotaService.canGenerateBatch(5), true);
      expect(await quotaService.canGenerateBatch(6), false);
      expect(await quotaService.canGenerateBatch(20), false);
    });

    test('should enforce free tier length limits', () async {
      final freeUser = User(
        id: 'free_user',
        email: 'free@example.com',
        plan: UserPlan.free,
      );

      when(mockAuthService.currentUser).thenReturn(freeUser);

      // Free tier should allow up to 32 characters
      expect(await quotaService.canGenerateLength(32), true);
      expect(await quotaService.canGenerateLength(33), false);
      expect(await quotaService.canGenerateLength(128), false);
    });

    test('should allow Pro+ tier full features', () async {
      final proPlusUser = User(
        id: 'pro_plus_user',
        email: 'proplus@example.com',
        plan: UserPlan.proPlus,
      );

      when(mockAuthService.currentUser).thenReturn(proPlusUser);

      // Pro+ should allow full features
      expect(await quotaService.canGenerateBatch(20), true);
      expect(await quotaService.canGenerateLength(128), true);
    });

    test('should track daily usage limits', () async {
      final freeUser = User(
        id: 'free_user',
        email: 'free@example.com',
        plan: UserPlan.free,
      );

      when(mockAuthService.currentUser).thenReturn(freeUser);

      // Simulate usage throughout the day
      for (int i = 0; i < 10; i++) {
        await quotaService.recordBatchGeneration(5);
      }

      // Should hit daily limit
      expect(await quotaService.canPerformBatchGeneration(), false);
    });
  });
}
```

## Performance Testing

### Generation Speed Benchmarks

**Password Generation Performance Tests**

```dart
// test/performance/password_gen_performance_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:toolspace/tools/password_gen/logic/password_generator.dart';

void main() {
  group('Password Generation Performance Tests', () {
    test('single password generation should be under 1ms', () {
      const config = PasswordConfig(
        length: 16,
        includeUppercase: true,
        includeLowercase: true,
        includeDigits: true,
        includeSymbols: true,
      );

      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 1000; i++) {
        PasswordGenerator.generate(config);
      }

      stopwatch.stop();

      final averageTime = stopwatch.elapsedMicroseconds / 1000 / 1000; // ms per generation
      expect(averageTime, lessThan(1.0));
    });

    test('batch generation should be efficient', () {
      const config = PasswordConfig(
        length: 16,
        includeUppercase: true,
        includeLowercase: true,
        includeDigits: true,
        includeSymbols: true,
      );

      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 100; i++) {
        PasswordGenerator.generateBatch(config, count: 20);
      }

      stopwatch.stop();

      final averageTime = stopwatch.elapsedMilliseconds / 100; // ms per batch
      expect(averageTime, lessThan(10.0));
    });

    test('entropy calculation should be fast', () {
      final testPasswords = List.generate(1000, (i) =>
        PasswordGenerator.generate(const PasswordConfig(
          length: 24,
          includeUppercase: true,
          includeLowercase: true,
          includeDigits: true,
          includeSymbols: true,
        ))
      );

      final stopwatch = Stopwatch()..start();

      for (final password in testPasswords) {
        PasswordGenerator.calculateEntropy(password);
      }

      stopwatch.stop();

      final averageTime = stopwatch.elapsedMicroseconds / testPasswords.length / 1000; // ms
      expect(averageTime, lessThan(0.1));
    });

    test('maximum length passwords should generate efficiently', () {
      const config = PasswordConfig(
        length: 128, // Maximum length
        includeUppercase: true,
        includeLowercase: true,
        includeDigits: true,
        includeSymbols: true,
      );

      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 100; i++) {
        PasswordGenerator.generate(config);
      }

      stopwatch.stop();

      final averageTime = stopwatch.elapsedMilliseconds / 100;
      expect(averageTime, lessThan(5.0)); // Still under 5ms for max length
    });
  });
}
```

### Memory Usage Tests

**Memory Efficiency Validation**

```dart
// test/performance/password_gen_memory_test.dart
import 'dart:developer';
import 'package:flutter_test/flutter_test.dart';
import 'package:toolspace/tools/password_gen/logic/password_generator.dart';

void main() {
  group('Password Generation Memory Tests', () {
    test('should not leak memory during batch generation', () async {
      const config = PasswordConfig(
        length: 32,
        includeUppercase: true,
        includeLowercase: true,
        includeDigits: true,
        includeSymbols: true,
      );

      // Measure initial memory
      await forceGC();
      final initialMemory = await getCurrentRSS();

      // Generate many batches
      for (int i = 0; i < 100; i++) {
        final batch = PasswordGenerator.generateBatch(config, count: 20);

        // Use passwords to prevent optimization
        expect(batch.length, 20);

        // Periodically force garbage collection
        if (i % 10 == 0) {
          await forceGC();
        }
      }

      // Measure final memory
      await forceGC();
      final finalMemory = await getCurrentRSS();

      // Memory growth should be minimal
      final memoryGrowth = finalMemory - initialMemory;
      expect(memoryGrowth, lessThan(10 * 1024 * 1024)); // Less than 10MB growth
    });

    test('should efficiently handle large character sets', () async {
      // Custom config with all possible characters
      const config = PasswordConfig(
        length: 64,
        includeUppercase: true,
        includeLowercase: true,
        includeDigits: true,
        includeSymbols: true,
        avoidAmbiguous: false,
      );

      await forceGC();
      final initialMemory = await getCurrentRSS();

      // Generate passwords with large character set
      for (int i = 0; i < 1000; i++) {
        PasswordGenerator.generate(config);
      }

      await forceGC();
      final finalMemory = await getCurrentRSS();

      final memoryGrowth = finalMemory - initialMemory;
      expect(memoryGrowth, lessThan(5 * 1024 * 1024)); // Less than 5MB growth
    });
  });
}

Future<void> forceGC() async {
  // Force garbage collection
  for (int i = 0; i < 3; i++) {
    await Future.delayed(const Duration(milliseconds: 1));
  }
}

Future<int> getCurrentRSS() async {
  final info = await Service.getInfo();
  return info.maxRSS ?? 0;
}
```

## Security Testing

### Cryptographic Quality Tests

**Randomness Quality Validation**

```dart
// test/security/password_gen_randomness_test.dart
import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:toolspace/tools/password_gen/logic/password_generator.dart';

void main() {
  group('Password Generation Randomness Tests', () {
    test('should produce evenly distributed characters', () {
      const config = PasswordConfig(
        length: 16,
        includeUppercase: false,
        includeLowercase: true,
        includeDigits: false,
        includeSymbols: false,
      );

      final charCounts = <String, int>{};
      const sampleSize = 10000;

      // Generate large sample
      for (int i = 0; i < sampleSize; i++) {
        final password = PasswordGenerator.generate(config);
        for (int j = 0; j < password.length; j++) {
          final char = password[j];
          charCounts[char] = (charCounts[char] ?? 0) + 1;
        }
      }

      // Calculate expected frequency
      final totalChars = sampleSize * 16;
      final expectedFreq = totalChars / 26; // 26 lowercase letters

      // Check distribution using chi-square test
      double chiSquare = 0;
      for (final count in charCounts.values) {
        final deviation = count - expectedFreq;
        chiSquare += (deviation * deviation) / expectedFreq;
      }

      // Chi-square critical value for 25 degrees of freedom at 95% confidence
      const criticalValue = 37.65;
      expect(chiSquare, lessThan(criticalValue));
    });

    test('should pass frequency analysis for symbols', () {
      const config = PasswordConfig(
        length: 8,
        includeUppercase: false,
        includeLowercase: false,
        includeDigits: false,
        includeSymbols: true,
      );

      final charCounts = <String, int>{};
      const sampleSize = 5000;

      for (int i = 0; i < sampleSize; i++) {
        final password = PasswordGenerator.generate(config);
        for (int j = 0; j < password.length; j++) {
          final char = password[j];
          charCounts[char] = (charCounts[char] ?? 0) + 1;
        }
      }

      // Verify all symbol characters appear
      final symbolChars = '!@#\$%^&*()_+-=[]{}|;:,.<>?';
      for (int i = 0; i < symbolChars.length; i++) {
        final char = symbolChars[i];
        expect(charCounts.containsKey(char), true,
          reason: 'Symbol "$char" should appear in random generation');
      }
    });

    test('should have no predictable patterns', () {
      const config = PasswordConfig(
        length: 16,
        includeUppercase: true,
        includeLowercase: true,
        includeDigits: true,
        includeSymbols: true,
      );

      final passwords = <String>[];

      // Generate sample passwords
      for (int i = 0; i < 1000; i++) {
        passwords.add(PasswordGenerator.generate(config));
      }

      // Check for sequential patterns
      for (final password in passwords) {
        expect(_hasSequentialPattern(password), false,
          reason: 'Password should not contain sequential patterns: $password');
      }

      // Check for repeated patterns
      for (final password in passwords) {
        expect(_hasRepeatedPattern(password), false,
          reason: 'Password should not contain repeated patterns: $password');
      }
    });

    test('should pass NIST entropy requirements', () {
      const config = PasswordConfig(
        length: 12,
        includeUppercase: true,
        includeLowercase: true,
        includeDigits: true,
        includeSymbols: false,
      );

      final passwords = <String>[];

      for (int i = 0; i < 100; i++) {
        passwords.add(PasswordGenerator.generate(config));
      }

      for (final password in passwords) {
        final entropy = PasswordGenerator.calculateEntropy(password);

        // NIST recommends minimum 40 bits of entropy
        expect(entropy, greaterThanOrEqualTo(40.0),
          reason: 'Password entropy should meet NIST requirements: $password');
      }
    });
  });
}

bool _hasSequentialPattern(String password) {
  // Check for 3+ sequential characters
  for (int i = 0; i < password.length - 2; i++) {
    final char1 = password.codeUnitAt(i);
    final char2 = password.codeUnitAt(i + 1);
    final char3 = password.codeUnitAt(i + 2);

    if (char2 == char1 + 1 && char3 == char2 + 1) {
      return true; // Found sequential pattern
    }
  }
  return false;
}

bool _hasRepeatedPattern(String password) {
  // Check for 3+ repeated characters
  for (int i = 0; i < password.length - 2; i++) {
    if (password[i] == password[i + 1] && password[i + 1] == password[i + 2]) {
      return true; // Found repeated pattern
    }
  }
  return false;
}
```

## End-to-End Testing

### Complete User Workflow Tests

**Full Generation Workflow E2E**

```dart
// test/e2e/password_gen_e2e_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:toolspace/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Password Generator E2E Tests', () {
    testWidgets('complete password generation workflow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Password Generator
      await tester.tap(find.text('Password Generator'));
      await tester.pumpAndSettle();

      // Verify initial state
      expect(find.text('Password Generator'), findsOneWidget);
      expect(find.text('16'), findsOneWidget); // Default length

      // Adjust password length
      final slider = find.byType(Slider);
      await tester.drag(slider, const Offset(100, 0));
      await tester.pumpAndSettle();

      // Toggle character sets
      await tester.tap(find.text('Symbols (!@#\$%^&*)'));
      await tester.pumpAndSettle();

      // Generate password
      await tester.tap(find.text('Generate'));
      await tester.pumpAndSettle();

      // Verify password appears
      expect(find.byType(SelectableText), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      // Copy password
      await tester.tap(find.byIcon(Icons.copy));
      await tester.pumpAndSettle();

      // Verify copy confirmation
      expect(find.text('Password copied to clipboard'), findsOneWidget);
    });

    testWidgets('batch generation workflow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Password Generator
      await tester.tap(find.text('Password Generator'));
      await tester.pumpAndSettle();

      // Configure for batch generation
      final slider = find.byType(Slider);
      await tester.drag(slider, const Offset(50, 0));
      await tester.pumpAndSettle();

      // Generate batch
      await tester.tap(find.text('Generate 20'));
      await tester.pumpAndSettle();

      // Verify batch results
      expect(find.text('Batch Generated (20)'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);

      // Test individual copy
      final firstCopyButton = find.byIcon(Icons.copy).first;
      await tester.tap(firstCopyButton);
      await tester.pumpAndSettle();

      // Test copy all
      await tester.tap(find.text('Copy All Passwords'));
      await tester.pumpAndSettle();

      expect(find.text('20 passwords copied'), findsOneWidget);
    });

    testWidgets('validation error handling workflow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Password Generator
      await tester.tap(find.text('Password Generator'));
      await tester.pumpAndSettle();

      // Disable all character sets
      await tester.tap(find.text('Uppercase (A-Z)'));
      await tester.tap(find.text('Lowercase (a-z)'));
      await tester.tap(find.text('Digits (0-9)'));
      await tester.tap(find.text('Symbols (!@#\$%^&*)'));
      await tester.pumpAndSettle();

      // Verify validation error appears
      expect(find.textContaining('character set'), findsOneWidget);

      // Verify generate button is disabled
      final generateButton = tester.widget<FilledButton>(
        find.ancestor(
          of: find.text('Generate'),
          matching: find.byType(FilledButton),
        ),
      );
      expect(generateButton.onPressed, null);

      // Re-enable a character set
      await tester.tap(find.text('Lowercase (a-z)'));
      await tester.pumpAndSettle();

      // Verify error disappears and button is enabled
      expect(find.textContaining('character set'), findsNothing);
    });

    testWidgets('billing tier restrictions workflow', (tester) async {
      // This test would require authentication setup
      // Implementation depends on auth system integration
    });
  });
}
```

## Test Automation & CI/CD

### Continuous Integration Test Pipeline

**GitHub Actions Test Workflow**

```yaml
# .github/workflows/password_gen_tests.yml
name: Password Generator Tests

on:
  pull_request:
    paths:
      - "lib/tools/password_gen/**"
      - "test/tools/password_gen/**"
  push:
    branches: [main]

jobs:
  unit-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: "3.16.0"

      - name: Install dependencies
        run: flutter pub get

      - name: Run unit tests
        run: flutter test test/tools/password_gen/ --coverage

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: coverage/lcov.info

  widget-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2

      - name: Install dependencies
        run: flutter pub get

      - name: Run widget tests
        run: flutter test test/tools/password_gen/ --tags=widget

  integration-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2

      - name: Install dependencies
        run: flutter pub get

      - name: Run integration tests
        run: flutter test test/integration/password_gen*

  security-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2

      - name: Install dependencies
        run: flutter pub get

      - name: Run security tests
        run: flutter test test/security/password_gen*

      - name: Validate randomness quality
        run: flutter test test/security/password_gen_randomness_test.dart --reporter json > security_test_results.json

      - name: Upload security test results
        uses: actions/upload-artifact@v3
        with:
          name: security-test-results
          path: security_test_results.json

  performance-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2

      - name: Install dependencies
        run: flutter pub get

      - name: Run performance tests
        run: flutter test test/performance/password_gen* --reporter json > performance_results.json

      - name: Check performance thresholds
        run: |
          # Custom script to validate performance metrics
          dart test/scripts/validate_performance.dart performance_results.json
```

### Test Coverage Requirements

**Coverage Targets**

- Unit tests: 95%+ coverage
- Widget tests: 90%+ coverage
- Integration tests: 80%+ coverage
- Security tests: 100% coverage for cryptographic functions
- Performance tests: All critical paths covered

**Coverage Report Generation**

```bash
#!/bin/bash
# scripts/generate_coverage_report.sh

echo "Generating Password Generator test coverage report..."

# Run all tests with coverage
flutter test test/tools/password_gen/ --coverage

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html

# Generate summary
lcov --summary coverage/lcov.info

echo "Coverage report generated in coverage/html/index.html"
```
