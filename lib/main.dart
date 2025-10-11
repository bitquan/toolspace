import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'auth/screens/email_verification_screen.dart';
import 'billing/billing_service.dart';
import 'billing/billing_types.dart';
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

    // PRODUCTION MODE: Using production Firebase services only
    DebugLogger.info('🌐 Using production Firebase services');

    // Ensure we're NOT using any emulators - completely disabled
    // No emulator configuration at all

    // 🚫 DO NOT sign in anonymously here in production
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
  StreamSubscription<User?>? _authStateSubscription;
  StreamSubscription<BillingProfile>? _billingSubscription;
  User? _previousUser;
  PlanId? _previousPlan;

  @override
  void initState() {
    super.initState();
    // NOTE: Removed _clearCachedAuth() - it was signing out users on every app load
    // This was causing the "sign in but stay on landing page" bug in production

    // AUTO-REFRESH TOKEN: Listen for auth state changes to detect email verification
    _authStateSubscription =
        FirebaseAuth.instance.authStateChanges().listen(_handleAuthStateChange);
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    _billingSubscription?.cancel();
    super.dispose();
  }

  /// Setup billing profile listener for auto-refresh on upgrade
  void _setupBillingListener() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final billingService = BillingService();
      billingService.startListening();
      _billingSubscription =
          billingService.billingProfileStream.listen(_handleBillingChange);
    }
  }

  /// Handle billing profile changes and auto-refresh token when plan changes
  void _handleBillingChange(BillingProfile profile) async {
    final currentPlan = profile.planId;

    if (_previousPlan != null && _previousPlan != currentPlan) {
      // Plan changed - likely an upgrade or downgrade
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await user.reload();
          await user.getIdToken(true); // Force token refresh
          DebugLogger.info(
              '🔄 Auto-refreshed token after plan change: ${_previousPlan?.id} → ${currentPlan.id}');
        }
      } catch (e) {
        DebugLogger.warning('Token refresh failed after plan change: $e');
      }
    }

    _previousPlan = currentPlan;
  }

  /// Handle auth state changes and auto-refresh token when email becomes verified
  void _handleAuthStateChange(User? user) async {
    if (user != null && _previousUser != null) {
      // Check if email verification status changed from false to true
      final wasUnverified = !_previousUser!.emailVerified;
      final nowVerified = user.emailVerified;

      if (wasUnverified && nowVerified) {
        try {
          // Auto-refresh token when email verification is detected
          await user.reload();
          await user.getIdToken(true); // Force token refresh
          DebugLogger.info('🔄 Auto-refreshed token after email verification');
        } catch (e) {
          DebugLogger.warning('Token refresh failed: $e');
        }
      }
    }

    _previousUser = user;

    // Setup billing listener when user logs in
    if (user != null && _previousUser == null) {
      _setupBillingListener();
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
