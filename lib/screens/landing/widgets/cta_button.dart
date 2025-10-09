/// CTA Button - Reusable call-to-action button
///
/// Features:
/// - Primary and secondary styles
/// - Hover and press animations
/// - Responsive sizing
library;

import 'package:flutter/material.dart';

class CTAButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;

  const CTAButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isPrimary = true,
  });

  @override
  State<CTAButton> createState() => _CTAButtonState();
}

class _CTAButtonState extends State<CTAButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: ElevatedButton(
          onPressed: widget.onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.isPrimary
                ? theme.colorScheme.primary
                : Colors.transparent,
            foregroundColor:
                widget.isPrimary ? Colors.white : theme.colorScheme.primary,
            padding: EdgeInsets.symmetric(
              horizontal: size.width < 600 ? 32 : 48,
              vertical: size.width < 600 ? 16 : 20,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: widget.isPrimary
                  ? BorderSide.none
                  : BorderSide(
                      color: theme.colorScheme.primary,
                      width: 2,
                    ),
            ),
            elevation: widget.isPrimary ? 4 : 0,
            shadowColor: theme.colorScheme.primary.withValues(alpha: 0.4),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: size.width < 600 ? 16 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
