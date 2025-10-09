/// Features Grid - Showcase of 5 premium tools with hover effects
library;

import 'package:flutter/material.dart';
import '../../../core/routes.dart';

class FeaturesGrid extends StatelessWidget {
  const FeaturesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Container(
      padding: const EdgeInsets.all(24),
      constraints: const BoxConstraints(maxWidth: 1200),
      child: Column(
        children: [
          Text(
            'Powerful Tools for Every Need',
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: size.width < 600 ? 1 : (size.width < 900 ? 2 : 3),
            mainAxisSpacing: 24,
            crossAxisSpacing: 24,
            childAspectRatio: 1.2,
            children: [
              _buildFeatureCard(
                context,
                Icons.palette,
                'Palette Extractor',
                'Extract color schemes from images',
                Colors.pink,
                ToolspaceRouter.paletteExtractor,
              ),
              _buildFeatureCard(
                context,
                Icons.merge_type,
                'File Merger',
                'Combine multiple files intelligently',
                Colors.purple,
                ToolspaceRouter.fileMerger,
              ),
              _buildFeatureCard(
                context,
                Icons.text_fields,
                'Text Tools',
                'Transform text with powerful utilities',
                Colors.green,
                ToolspaceRouter.textTools,
              ),
              _buildFeatureCard(
                context,
                Icons.article,
                'Markdown to PDF',
                'Convert markdown to beautiful PDFs',
                Colors.orange,
                ToolspaceRouter.mdToPdf,
              ),
              _buildFeatureCard(
                context,
                Icons.password,
                'Password Generator',
                'Create secure passwords instantly',
                Colors.blue,
                ToolspaceRouter.passwordGen,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    IconData icon,
    String title,
    String description,
    Color color,
    String route,
  ) {
    return _AnimatedFeatureCard(
      icon: icon,
      title: title,
      description: description,
      color: color,
      route: route,
    );
  }
}

/// Animated feature card with hover effects
class _AnimatedFeatureCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final String route;

  const _AnimatedFeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.route,
  });

  @override
  State<_AnimatedFeatureCard> createState() => _AnimatedFeatureCardState();
}

class _AnimatedFeatureCardState extends State<_AnimatedFeatureCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, _isHovered ? -8 : 0, 0),
        child: Card(
          elevation: _isHovered ? 12 : 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: _isHovered
                  ? widget.color.withValues(alpha: 0.5)
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: InkWell(
            onTap: () => Navigator.pushNamed(context, widget.route),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: widget.color
                          .withValues(alpha: _isHovered ? 0.2 : 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.icon,
                      size: 48,
                      color: widget.color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _isHovered ? widget.color : null,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_isHovered) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: widget.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: widget.color, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Try it now',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: widget.color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward,
                            size: 16,
                            color: widget.color,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
