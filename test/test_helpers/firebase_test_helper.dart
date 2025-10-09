/// Firebase test helper - sets up mock method channels for Firebase
library;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Sets up fake Firebase method channels for testing
///
/// Call this in setUpAll() for tests that render widgets using Firebase services.
/// This mocks the platform method channels so Firebase calls don't crash tests.
void setupFirebaseAuthMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock Firebase Core
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/firebase_core'),
    (MethodCall methodCall) async {
      if (methodCall.method == 'Firebase#initializeCore') {
        return [
          {
            'name': '[DEFAULT]',
            'options': {
              'apiKey': 'test-api-key',
              'appId': 'test-app-id',
              'messagingSenderId': 'test-sender-id',
              'projectId': 'test-project',
              'storageBucket': 'test-bucket',
            },
            'pluginConstants': <String, dynamic>{},
          }
        ];
      }
      if (methodCall.method == 'Firebase#initializeApp') {
        return {
          'name': methodCall.arguments['appName'] ?? '[DEFAULT]',
          'options': methodCall.arguments['options'],
          'pluginConstants': <String, dynamic>{},
        };
      }
      return null;
    },
  );

  // Mock Cloud Firestore
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/firebase_firestore'),
    (MethodCall methodCall) async {
      // Return empty/default responses for Firestore calls
      if (methodCall.method == 'DocumentReference#get') {
        return null;
      }
      if (methodCall.method == 'Query#get') {
        return {'documents': []};
      }
      return null;
    },
  );

  // Mock Firebase Auth
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/firebase_auth'),
    (MethodCall methodCall) async {
      if (methodCall.method == 'Auth#currentUser') {
        return null; // Not authenticated
      }
      return null;
    },
  );
}
