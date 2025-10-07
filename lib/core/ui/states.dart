import 'package:flutter/material.dart';
import 'neo_playground_theme.dart';

/// Shared empty state widget for consistent UX across all tools
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with gradient background
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                gradient: NeoPlaygroundTheme.primaryGradient,
                borderRadius: BorderRadius.circular(32),
                boxShadow: NeoPlaygroundTheme.glassShadow,
              ),
              child: Icon(
                icon,
                size: 48,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 24),

            // Title
            Text(
              title,
              style: NeoPlaygroundTheme.headingMedium.copyWith(
                color: isDark ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Message
            Text(
              message,
              style: NeoPlaygroundTheme.bodyMedium.copyWith(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.6)
                    : Colors.black.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),

            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add_rounded),
                label: Text(actionLabel!),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Shared error state widget for consistent error handling
class ErrorState extends StatelessWidget {
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool showIcon;

  const ErrorState({
    super.key,
    this.title = 'Something went wrong',
    required this.message,
    this.actionLabel,
    this.onAction,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon) ...[
              // Error icon with gradient background
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFEF4444),
                      Color(0xFFF97316),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: NeoPlaygroundTheme.glassShadow,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Title
            Text(
              title,
              style: NeoPlaygroundTheme.headingMedium.copyWith(
                color: isDark ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Message
            Text(
              message,
              style: NeoPlaygroundTheme.bodyMedium.copyWith(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.6)
                    : Colors.black.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),

            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(actionLabel!),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Loading state with glass effect
class LoadingState extends StatelessWidget {
  final String? message;

  const LoadingState({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Glass container with loading indicator
          Container(
            padding: const EdgeInsets.all(32),
            decoration: NeoPlaygroundTheme.glassDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.05),
              borderRadius: 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      NeoPlaygroundTheme.primaryPurple,
                    ),
                  ),
                ),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    message!,
                    style: NeoPlaygroundTheme.bodyMedium.copyWith(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.8)
                          : Colors.black.withValues(alpha: 0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
