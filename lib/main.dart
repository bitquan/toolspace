import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app_shell.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Firebase initialization failed - continue with app but Firebase features won't work
    debugPrint('Firebase initialization failed: $e');
  }

  runApp(const ToolspaceApp());
}
