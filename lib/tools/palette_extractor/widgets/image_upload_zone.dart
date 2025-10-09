import 'package:flutter/material.dart';

/// Drag-and-drop zone for image upload
class ImageUploadZone extends StatefulWidget {
  final VoidCallback onImageSelected;
  final bool isEnabled;
  final bool hasImage;

  const ImageUploadZone({
    super.key,
    required this.onImageSelected,
    this.isEnabled = true,
    this.hasImage = false,
  });

  @override
  State<ImageUploadZone> createState() => _ImageUploadZoneState();
}

class _ImageUploadZoneState extends State<ImageUploadZone> {
  final bool _isDragOver = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: widget.isEnabled ? widget.onImageSelected : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: widget.hasImage ? 80 : 160,
        decoration: BoxDecoration(
          border: Border.all(
            color: _isDragOver
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
          borderRadius: BorderRadius.circular(12),
          color: _isDragOver
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : widget.isEnabled
                  ? theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.3)
                  : theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.1),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.hasImage ? Icons.refresh : Icons.image_outlined,
                size: widget.hasImage ? 24 : 48,
                color: widget.isEnabled
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 12),
              Text(
                widget.hasImage
                    ? 'Tap to select a different image'
                    : widget.isEnabled
                        ? 'Tap to select an image or drag & drop'
                        : 'Extracting colors...',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: widget.isEnabled
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.5),
                ),
                textAlign: TextAlign.center,
              ),
              if (!widget.hasImage) ...[
                const SizedBox(height: 4),
                Text(
                  'PNG, JPG, WebP • Max 10MB',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.7),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
