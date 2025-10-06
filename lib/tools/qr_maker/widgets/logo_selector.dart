import 'package:flutter/material.dart';

/// Logo selection and configuration widget
class LogoSelector extends StatefulWidget {
  final String? selectedLogoPath;
  final double logoSize;
  final ValueChanged<String?> onLogoChanged;
  final ValueChanged<double> onLogoSizeChanged;

  const LogoSelector({
    super.key,
    required this.selectedLogoPath,
    required this.logoSize,
    required this.onLogoChanged,
    required this.onLogoSizeChanged,
  });

  @override
  State<LogoSelector> createState() => _LogoSelectorState();
}

class _LogoSelectorState extends State<LogoSelector> {
  static const List<String> _predefinedLogos = [
    'flutter',
    'github',
    'google',
    'apple',
    'twitter',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Logo',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (widget.selectedLogoPath != null)
              TextButton.icon(
                onPressed: () => widget.onLogoChanged(null),
                icon: const Icon(Icons.close, size: 16),
                label: const Text('Remove'),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // Predefined logos
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _predefinedLogos.map((logo) {
            final isSelected = widget.selectedLogoPath == logo;
            return GestureDetector(
              onTap: () => widget.onLogoChanged(logo),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFFF5722).withOpacity(0.1)
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFFF5722)
                        : theme.colorScheme.outline.withOpacity(0.3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: Icon(
                    _getIconForLogo(logo),
                    size: 32,
                    color: isSelected
                        ? const Color(0xFFFF5722)
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 16),

        // Custom logo upload (placeholder)
        OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Custom logo upload coming soon!'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          icon: const Icon(Icons.upload_file),
          label: const Text('Upload Custom Logo'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFFF5722),
          ),
        ),

        if (widget.selectedLogoPath != null) ...[
          const SizedBox(height: 16),

          // Logo size slider
          Text('Logo Size: ${widget.logoSize.round()}%'),
          Slider(
            value: widget.logoSize,
            min: 10,
            max: 40,
            divisions: 6,
            label: '${widget.logoSize.round()}%',
            onChanged: widget.onLogoSizeChanged,
          ),
        ],
      ],
    );
  }

  IconData _getIconForLogo(String logo) {
    switch (logo) {
      case 'flutter':
        return Icons.flutter_dash;
      case 'github':
        return Icons.code;
      case 'google':
        return Icons.search;
      case 'apple':
        return Icons.apple;
      case 'twitter':
        return Icons.alternate_email;
      default:
        return Icons.image;
    }
  }
}
