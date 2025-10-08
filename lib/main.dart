import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app_shell.dart';
import 'core/services/debug_logger.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Suppress VM service null errors in debug mode
  if (kDebugMode) {
    // Override Flutter error handler to filter VM service errors
    FlutterError.onError = (FlutterErrorDetails details) {
      final errorStr = details.exception.toString();
      // Filter out known VM service errors
      if (!errorStr.contains('Cannot send Null') &&
          !errorStr.contains('DebugService') &&
          !errorStr.contains('Error serving requests')) {
        FlutterError.presentError(details);
      }
    };

    // Set up debug logger to suppress VM service errors
    DebugLogger.setSuppressVMServiceErrors(true);
  }

  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Use Firebase emulators in debug mode
    if (kDebugMode) {
      // Connect to emulators
      FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
      FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
      FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);

      DebugLogger.info('🔧 Using Firebase emulators (Auth:9099, Firestore:8080, Functions:5001)');
    }

    // Sign in anonymously for testing
    final auth = FirebaseAuth.instance;
    if (auth.currentUser == null) {
      await auth.signInAnonymously();
      DebugLogger.info('✅ Signed in anonymously for testing');
    }
  } catch (e) {
    // Firebase initialization failed - continue with app but Firebase features won't work
    DebugLogger.warning('Firebase initialization failed: $e');
  }

  runApp(const ToolspaceApp());
}
