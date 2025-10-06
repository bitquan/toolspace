import 'package:flutter/material.dart';
import '../../theme/playful_theme.dart';

/// Consistent page transitions for tool navigation
class ToolTransition {
  /// Create a slide transition route for navigating between tools
  static PageRoute<T> createRoute<T>(Widget screen) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: PlayfulTheme.mediumAnimation,
    );
  }
}
