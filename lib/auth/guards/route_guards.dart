import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

/// Route guard that requires user authentication
class RequireAuthGuard extends StatelessWidget {
  final Widget child;
  final String? redirectPath;

  const RequireAuthGuard({
    super.key,
    required this.child,
    this.redirectPath,
  });

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

        final user = snapshot.data;

        // Redirect to sign-in if not authenticated
        if (user == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed(
              redirectPath ?? '/auth/signin',
            );
          });
          return const SizedBox.shrink();
        }

        // User is authenticated, show protected content
        return child;
      },
    );
  }
}

/// Route guard that requires verified email
class RequireVerifiedEmailGuard extends StatelessWidget {
  final Widget child;
  final bool showVerificationPrompt;

  const RequireVerifiedEmailGuard({
    super.key,
    required this.child,
    this.showVerificationPrompt = true,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: AuthService().isVerifiedStream,
      builder: (context, snapshot) {
        // Show loading while checking verification state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final isVerified = snapshot.data ?? false;

        // Show verification prompt if email not verified
        if (!isVerified && showVerificationPrompt) {
          return const EmailVerificationPrompt();
        }

        // Email is verified, show protected content
        return child;
      },
    );
  }
}

/// Prompt shown when email verification is required
class EmailVerificationPrompt extends StatefulWidget {
  const EmailVerificationPrompt({super.key});

  @override
  State<EmailVerificationPrompt> createState() =>
      _EmailVerificationPromptState();
}

class _EmailVerificationPromptState extends State<EmailVerificationPrompt> {
  bool _isResending = false;

  Future<void> _resendVerification() async {
    if (_isResending) return;

    setState(() {
      _isResending = true;
    });

    try {
      await AuthService().sendEmailVerification();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email sent!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send verification: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  Future<void> _checkVerification() async {
    try {
      await AuthService().reloadUser();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to check verification: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF1A1A2E),
                    const Color(0xFF16213E),
                    const Color(0xFF0F3460),
                  ]
                : [
                    const Color(0xFFE8F4FD),
                    const Color(0xFFF3E8FF),
                    const Color(0xFFFFE8F3),
                  ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.white.withOpacity(0.1),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Email verification icon
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.orange.withOpacity(0.1),
                        ),
                        child: const Icon(
                          Icons.mark_email_unread,
                          size: 48,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Title
                      Text(
                        'Verify Your Email',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),

                      // Description
                      Text(
                        'Please check your email and click the verification link to access premium features.',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.white70 : Colors.black54,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Resend verification button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isResending ? null : _resendVerification,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          child: _isResending
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Resend Verification Email',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Check verification button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: _checkVerification,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: isDark
                                  ? Colors.white.withOpacity(0.3)
                                  : Colors.black.withOpacity(0.3),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'I\'ve Verified My Email',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Sign out option
                      TextButton(
                        onPressed: () async {
                          await AuthService().signOut();
                          if (mounted) {
                            Navigator.of(context)
                                .pushReplacementNamed('/auth/signin');
                          }
                        },
                        child: Text(
                          'Sign Out',
                          style: TextStyle(
                            color: isDark ? Colors.white54 : Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Utility class for applying route guards
class RouteGuard {
  /// Create a route that requires authentication
  static Route<T> requireAuth<T extends Object?>(
    String routeName,
    Widget Function(BuildContext) builder, {
    String? redirectPath,
  }) {
    return MaterialPageRoute<T>(
      settings: RouteSettings(name: routeName),
      builder: (context) => RequireAuthGuard(
        redirectPath: redirectPath,
        child: builder(context),
      ),
    );
  }

  /// Create a route that requires verified email
  static Route<T> requireVerified<T extends Object?>(
    String routeName,
    Widget Function(BuildContext) builder, {
    bool showVerificationPrompt = true,
  }) {
    return MaterialPageRoute<T>(
      settings: RouteSettings(name: routeName),
      builder: (context) => RequireAuthGuard(
        child: RequireVerifiedEmailGuard(
          showVerificationPrompt: showVerificationPrompt,
          child: builder(context),
        ),
      ),
    );
  }

  /// Create a route that requires both auth and verified email
  static Route<T> requireAuthAndVerified<T extends Object?>(
    String routeName,
    Widget Function(BuildContext) builder, {
    String? redirectPath,
    bool showVerificationPrompt = true,
  }) {
    return MaterialPageRoute<T>(
      settings: RouteSettings(name: routeName),
      builder: (context) => RequireAuthGuard(
        redirectPath: redirectPath,
        child: RequireVerifiedEmailGuard(
          showVerificationPrompt: showVerificationPrompt,
          child: builder(context),
        ),
      ),
    );
  }
}
