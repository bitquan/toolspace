import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app_shell.dart';
import 'firebase_options.dart';
import 'core/services/debug_logger.dart';

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
  } catch (e) {
    // Firebase initialization failed - continue with app but Firebase features won't work
    DebugLogger.warning('Firebase initialization failed: $e');
  }

  runApp(const ToolspaceApp());
}
