import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'neo_playground_theme.dart';

/// Animated gradient background with floating blobs
/// Provides smooth, looped motion effects for the Neo-Playground UI
class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: _BackgroundPainter(
            animation: _animation.value,
            isDark: isDark,
          ),
          child: child,
        );
      },
      child: Container(),
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  final double animation;
  final bool isDark;

  _BackgroundPainter({
    required this.animation,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Base gradient background
    final rect = Offset.zero & size;
    final gradient = LinearGradient(
      colors: isDark
          ? [
              NeoPlaygroundTheme.darkBackground,
              const Color(0xFF1E1B4B),
              const Color(0xFF312E81),
            ]
          : [
              NeoPlaygroundTheme.lightBackground,
              const Color(0xFFEDE9FE),
              const Color(0xFFDDD6FE),
            ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));

    // Animated blobs
    _drawBlob(
      canvas,
      size,
      size.width * 0.2,
      size.height * 0.3,
      animation,
      NeoPlaygroundTheme.primaryPurple,
      150,
    );

    _drawBlob(
      canvas,
      size,
      size.width * 0.8,
      size.height * 0.6,
      animation + 0.3,
      NeoPlaygroundTheme.primaryBlue,
      200,
    );

    _drawBlob(
      canvas,
      size,
      size.width * 0.5,
      size.height * 0.8,
      animation + 0.6,
      NeoPlaygroundTheme.accentPink,
      120,
    );
  }

  void _drawBlob(
    Canvas canvas,
    Size size,
    double baseX,
    double baseY,
    double phase,
    Color color,
    double radius,
  ) {
    final x = baseX + math.sin(phase * 2 * math.pi) * 50;
    final y = baseY + math.cos(phase * 2 * math.pi) * 30;

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: isDark ? 0.15 : 0.2),
          color.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(center: Offset(x, y), radius: radius));

    canvas.drawCircle(Offset(x, y), radius, paint);
  }

  @override
  bool shouldRepaint(_BackgroundPainter oldDelegate) {
    return oldDelegate.animation != animation || oldDelegate.isDark != isDark;
  }
}

/// Glass container with blur effect
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final Gradient? gradient;
  final bool showBorder;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.padding,
    this.width,
    this.height,
    this.gradient,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: NeoPlaygroundTheme.glassDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.7),
        gradient: gradient,
        borderRadius: borderRadius,
        showBorder: showBorder,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(
            sigmaX: NeoPlaygroundTheme.glassBlur,
            sigmaY: NeoPlaygroundTheme.glassBlur,
          ),
          child: child,
        ),
      ),
    );
  }
}
