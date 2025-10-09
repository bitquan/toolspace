import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'auth/screens/email_verification_screen.dart';
import 'core/services/debug_logger.dart';
import 'core/ui/neo_playground_theme.dart';
import 'core/routes.dart';
import 'firebase_options.dart';
import 'screens/landing/landing_page.dart';
import 'screens/neo_home_screen.dart';

Future<void> main() async {
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

      DebugLogger.info(
          '🔧 Using Firebase emulators (Auth:9099, Firestore:8080, Functions:5001)');
    }

    // 🚫 DO NOT sign in anonymously here (removed)
    // Anonymous auth prevents proper email verification flow
  } catch (e) {
    // Firebase initialization failed - continue with app but Firebase features won't work
    DebugLogger.warning('Firebase initialization failed: $e');
  }

  runApp(const ToolspaceApp());
}

class ToolspaceApp extends StatelessWidget {
  const ToolspaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Toolspace ⚙️ - Neo Playground',
      theme: NeoPlaygroundTheme.lightTheme(),
      darkTheme: NeoPlaygroundTheme.darkTheme(),
      themeMode: ThemeMode.system,
      // Use the centralized router for all navigation
      initialRoute: '/',
      onGenerateRoute: (settings) {
        // Special case: root route goes to AuthGate
        if (settings.name == '/') {
          return MaterialPageRoute(builder: (_) => const AuthGate());
        }
        // All other routes handled by ToolspaceRouter
        return ToolspaceRouter.generateRoute(settings);
      },
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _hasCheckedAndClearedBadAuth = false;

  @override
  void initState() {
    super.initState();
    // Clear any cached auth on startup (debugging - remove this later)
    _clearCachedAuth();
  }

  Future<void> _clearCachedAuth() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DebugLogger.info(
          '🧹 Clearing cached auth session for: ${user.email ?? "anonymous"}');
      await FirebaseAuth.instance.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        // Splash/loading
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snap.data;

        // Not signed in → show Landing (Sign in / Sign up)
        if (user == null) {
          return const LandingPage();
        }

        // Anonymous user or no email (old session) → sign out ONCE
        final hasInvalidEmail = user.email == null || user.email!.isEmpty;
        if ((user.isAnonymous || hasInvalidEmail) &&
            !_hasCheckedAndClearedBadAuth) {
          _hasCheckedAndClearedBadAuth = true;
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await FirebaseAuth.instance.signOut();
            DebugLogger.info('🚪 Signed out anonymous/incomplete user');
          });
          // Show landing page immediately while signing out
          return const LandingPage();
        }

        // Signed in but needs email verification
        if (!user.emailVerified) {
          return const EmailVerificationScreen();
        }

        // Fully authenticated → go to app home
        return const NeoHomeScreen();
      },
    );
  }
}
