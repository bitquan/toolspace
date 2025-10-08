import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'screens/neo_home_screen.dart';
import 'screens/billing/billing_success_screen.dart';
import 'screens/billing/billing_cancel_screen.dart';
import 'core/ui/neo_playground_theme.dart';
import 'core/routes.dart';
import 'auth/screens/signin_screen.dart';
import 'auth/services/auth_service.dart';

class ToolspaceApp extends StatelessWidget {
  const ToolspaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Toolspace ⚙️ - Neo Playground',
      theme: NeoPlaygroundTheme.lightTheme(),
      darkTheme: NeoPlaygroundTheme.darkTheme(),
      themeMode: ThemeMode.system,
      initialRoute: '/',
      onGenerateRoute: ToolspaceRouter.generateRoute,
      routes: {
        '/billing/success': (context) => const BillingSuccessScreen(),
        '/billing/cancel': (context) => const BillingCancelScreen(),
      },
      home: const AuthGate(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Ensures user is authenticated before showing the app
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    // Initialize the auth service
    AuthService().initialize();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().userStream,
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // If not authenticated, show sign in screen
        if (!snapshot.hasData || snapshot.data == null) {
          return const SignInScreen();
        }

        // User is authenticated, show the main app
        return const NeoHomeScreen();
      },
    );
  }
}
