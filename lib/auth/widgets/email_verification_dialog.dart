/// Email Verification Dialog - prompts user to verify email before checkout.
///
/// Shows when user attempts billing actions without verified email.
/// Neo-Playground style with glassmorphism and playful animations.
library;

import 'dart:ui';

import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class EmailVerificationDialog extends StatefulWidget {
  final VoidCallback? onVerified;
  final AuthService? authService;

  const EmailVerificationDialog({
    super.key,
    this.onVerified,
    this.authService,
  });

  @override
  State<EmailVerificationDialog> createState() =>
      _EmailVerificationDialogState();

  static Future<void> show(
    BuildContext context, {
    VoidCallback? onVerified,
    AuthService? authService,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => EmailVerificationDialog(
        onVerified: onVerified,
        authService: authService,
      ),
    );
  }
}

class _EmailVerificationDialogState extends State<EmailVerificationDialog>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;
  bool _isResending = false;
  bool _isCheckingVerification = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _shimmerAnimation = Tween<double>(begin: -1, end: 1).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.linear),
    );
    _shimmerController.repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _resendVerification() async {
    if (_isResending) return;

    setState(() {
      _isResending = true;
      _errorMessage = null;
    });

    try {
      final authService = widget.authService ?? AuthService();
      await authService.sendEmailVerification();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email sent! Please check your inbox.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to send verification email: $e';
      });
    } finally {
      setState(() {
        _isResending = false;
      });
    }
  }

  Future<void> _checkVerification() async {
    if (_isCheckingVerification) return;

    setState(() {
      _isCheckingVerification = true;
      _errorMessage = null;
    });

    try {
      final authService = widget.authService ?? AuthService();
      await authService.reloadUser();

      final currentUser = authService.currentUser;
      if (currentUser?.emailVerified == true) {
        // Email is verified!
        if (mounted) {
          Navigator.of(context).pop();
          widget.onVerified?.call();
        }
        return;
      }

      // Still not verified
      setState(() {
        _errorMessage =
            'Email not yet verified. Please check your inbox and click the verification link.';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to check verification status: $e';
      });
    } finally {
      setState(() {
        _isCheckingVerification = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.surface.withValues(alpha: 0.9),
                theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with animated icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange.withValues(alpha: 0.2),
                      Colors.deepOrange.withValues(alpha: 0.2),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: AnimatedBuilder(
                  animation: _shimmerAnimation,
                  builder: (context, child) {
                    return Stack(
                      children: [
                        const Icon(
                          Icons.mark_email_unread,
                          size: 48,
                          color: Colors.orange,
                        ),
                        if (_shimmerAnimation.value > -0.5 &&
                            _shimmerAnimation.value < 0.5)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Colors.transparent,
                                    Colors.white.withValues(alpha: 0.3),
                                    Colors.transparent,
                                  ],
                                  stops: [
                                    0.0,
                                    _shimmerAnimation.value + 0.5,
                                    1.0,
                                  ],
                                ),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Title
              Text(
                'Email Verification Required',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Description
              Text(
                'Please verify your email address before purchasing a subscription. This helps us ensure account security and payment notifications reach you.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Error message
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: theme.colorScheme.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: theme.colorScheme.error,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Action buttons
              Row(
                children: [
                  // Resend button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isResending ? null : _resendVerification,
                      icon: _isResending
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: theme.colorScheme.primary,
                              ),
                            )
                          : const Icon(Icons.refresh),
                      label: Text(_isResending ? 'Sending...' : 'Resend Email'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Check verification button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed:
                          _isCheckingVerification ? null : _checkVerification,
                      icon: _isCheckingVerification
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: theme.colorScheme.onPrimary,
                              ),
                            )
                          : const Icon(Icons.check_circle),
                      label: Text(_isCheckingVerification
                          ? 'Checking...'
                          : 'I\'m Verified'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Cancel button
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
