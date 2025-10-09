/// Hero Section - Main landing page hero with gradient background
///
/// Features:
/// - Animated gradient background
/// - Bold headline and subheadline
/// - Primary and secondary CTAs
/// - Floating icon animations
library;

import 'package:flutter/material.dart';

import 'cta_button.dart';

class HeroSection extends StatefulWidget {
  const HeroSection({super.key});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: size.height * 0.9),
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
      child: Stack(
        children: [
          // Floating icons animation
          _buildFloatingIcons(),

          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),

                  // Headline
                  Text(
                    'Build Smarter,\nShip Faster',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: size.width < 600 ? 40 : 64,
                      height: 1.1,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Subheadline
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: Text(
                      'Professional dev tools for modern teams. '
                      'From invoice generation to code merging.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: size.width < 600 ? 18 : 22,
                        height: 1.6,
                        color: isDark
                            ? Colors.white.withOpacity(0.8)
                            : Colors.black.withOpacity(0.7),
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // CTAs
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: [
                      Semantics(
                        label: 'btn-get-started',
                        button: true,
                        child: CTAButton(
                          key: const Key('btn-get-started'),
                          label: 'Get Started Free',
                          onPressed: () {
                            Navigator.of(context).pushNamed('/signup');
                          },
                          isPrimary: true,
                        ),
                      ),
                      Semantics(
                        label: 'btn-view-pricing',
                        button: true,
                        child: CTAButton(
                          key: const Key('btn-view-pricing'),
                          label: 'View Pricing',
                          onPressed: () {
                            Navigator.of(context).pushNamed('/pricing');
                          },
                          isPrimary: false,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 60),

                  // Trust indicators
                  _buildTrustIndicators(theme, isDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingIcons() {
    // Capture size OUTSIDE AnimatedBuilder to avoid layout loops
    final size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final offset = _controller.value * 20 - 10;
        // Wrap Stack in SizedBox to give it explicit size constraints
        return SizedBox(
          width: size.width,
          height: size.height,
          child: Stack(
            children: [
              _buildFloatingIcon(Icons.receipt_long, 0.1, 0.2, size, offset),
              _buildFloatingIcon(Icons.merge_type, 0.8, 0.3, size, offset),
              _buildFloatingIcon(Icons.palette, 0.15, 0.7, size, offset),
              _buildFloatingIcon(Icons.text_fields, 0.85, 0.6, size, offset),
              _buildFloatingIcon(Icons.article, 0.5, 0.1, size, offset),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFloatingIcon(
      IconData icon, double left, double top, Size size, double offset) {
    return Positioned(
      left: size.width * left,
      top: size.height * top + offset,
      child: Opacity(
        opacity: 0.1,
        child: Icon(
          icon,
          size: 48,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildTrustIndicators(ThemeData theme, bool isDark) {
    return Wrap(
      spacing: 32,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: [
        _buildTrustBadge(
            'No Credit Card Required', Icons.credit_card_off, theme, isDark),
        _buildTrustBadge(
            'Free Plan Available', Icons.free_breakfast, theme, isDark),
        _buildTrustBadge('Cancel Anytime', Icons.close, theme, isDark),
      ],
    );
  }

  Widget _buildTrustBadge(
      String label, IconData icon, ThemeData theme, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 20,
          color: isDark ? Colors.white70 : Colors.black54,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
      ],
    );
  }
}
