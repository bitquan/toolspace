import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../logic/color_utils.dart';

/// A card displaying a color swatch with copy functionality
class ColorSwatchCard extends StatefulWidget {
  final Color color;
  final int index;
  final double? percentage;
  final VoidCallback? onTap;

  const ColorSwatchCard({
    super.key,
    required this.color,
    required this.index,
    this.percentage,
    this.onTap,
  });

  @override
  State<ColorSwatchCard> createState() => _ColorSwatchCardState();
}

class _ColorSwatchCardState extends State<ColorSwatchCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _copyHex() {
    final hex = ColorUtils.toHex(widget.color);
    Clipboard.setData(ClipboardData(text: hex));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied $hex to clipboard'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _copyRgb() {
    final rgb = ColorUtils.toRgb(widget.color);
    Clipboard.setData(ClipboardData(text: rgb));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied $rgb to clipboard'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hex = ColorUtils.toHex(widget.color);
    final rgb = ColorUtils.toRgb(widget.color);
    final textColor = ColorUtils.getContrastColor(widget.color);

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Card(
          elevation: _isHovered ? 8 : 2,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onTap ?? _copyHex,
            child: Container(
              decoration: BoxDecoration(
                color: widget.color,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Color number
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: textColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '#${widget.index + 1}',
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        if (widget.percentage != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: textColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${widget.percentage!.toStringAsFixed(1)}%',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const Spacer(),
                    // Hex value
                    Text(
                      hex,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // RGB value
                    Text(
                      rgb,
                      style: TextStyle(
                        color: textColor.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Action buttons
                    Row(
                      children: [
                        _ActionButton(
                          icon: Icons.copy,
                          label: 'HEX',
                          color: textColor,
                          onPressed: _copyHex,
                        ),
                        const SizedBox(width: 8),
                        _ActionButton(
                          icon: Icons.copy,
                          label: 'RGB',
                          color: textColor,
                          onPressed: _copyRgb,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Small action button for color swatch
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
