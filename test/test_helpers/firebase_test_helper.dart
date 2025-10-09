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

  // Mock Firebase Core - This is the most critical one
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/firebase_core'),
    (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'Firebase#initializeCore':
          // Return the default app configuration
          return [
            {
              'name': '[DEFAULT]',
              'options': {
                'apiKey': 'fake-api-key',
                'appId': '1:123456789:web:abc123',
                'messagingSenderId': '123456789',
                'projectId': 'test-project',
                'storageBucket': 'test-project.appspot.com',
              },
              'pluginConstants': <String, dynamic>{},
            }
          ];
        case 'Firebase#initializeApp':
          final String appName =
              (methodCall.arguments as Map)['appName'] as String? ??
                  '[DEFAULT]';
          final options = (methodCall.arguments as Map)['options'];
          return {
            'name': appName,
            'options': options,
            'pluginConstants': <String, dynamic>{},
          };
        default:
          return null;
      }
    },
  );

  // Mock Cloud Firestore
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/cloud_firestore'),
    (MethodCall methodCall) async {
      // Return empty/default responses for Firestore calls
      switch (methodCall.method) {
        case 'Firestore#settings':
          return null;
        case 'DocumentReference#get':
          return null;
        case 'Query#get':
          return {'documents': <Map>[], 'metadata': {}};
        case 'Query#snapshots':
          // Return a stream controller for snapshots
          return null;
        default:
          return null;
      }
    },
  );

  // Mock Firebase Auth
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/firebase_auth'),
    (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'Auth#registerIdTokenListener':
        case 'Auth#registerAuthStateListener':
          // Return a dummy subscription ID
          return {'name': 'test-listener'};
        case 'Auth#currentUser':
          return null; // Not authenticated
        case 'Auth#applyActionCode':
        case 'Auth#checkActionCode':
        case 'Auth#confirmPasswordReset':
        case 'Auth#createUserWithEmailAndPassword':
        case 'Auth#fetchSignInMethodsForEmail':
        case 'Auth#sendPasswordResetEmail':
        case 'Auth#sendSignInLinkToEmail':
        case 'Auth#setLanguageCode':
        case 'Auth#setSettings':
        case 'Auth#signInAnonymously':
        case 'Auth#signInWithCredential':
        case 'Auth#signInWithCustomToken':
        case 'Auth#signInWithEmailAndPassword':
        case 'Auth#signInWithEmailLink':
        case 'Auth#signOut':
        case 'Auth#useEmulator':
        case 'Auth#verifyPasswordResetCode':
        case 'Auth#verifyPhoneNumber':
          return null;
        default:
          return null;
      }
    },
  );

  // Mock Firebase Storage
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/firebase_storage'),
    (MethodCall methodCall) async {
      return null;
    },
  );

  // Mock Firebase Functions
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/cloud_functions'),
    (MethodCall methodCall) async {
      return null;
    },
  );
}
