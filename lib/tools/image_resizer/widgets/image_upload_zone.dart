import 'package:flutter/material.dart';

/// Drag-and-drop upload zone for image selection
class ImageUploadZone extends StatefulWidget {
  final VoidCallback onImagesSelected;
  final bool isEnabled;

  const ImageUploadZone({
    super.key,
    required this.onImagesSelected,
    this.isEnabled = true,
  });

  @override
  State<ImageUploadZone> createState() => _ImageUploadZoneState();
}

class _ImageUploadZoneState extends State<ImageUploadZone> {
  final bool _isDragOver = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isEnabled ? widget.onImagesSelected : null,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          border: Border.all(
            color: _isDragOver
                ? Theme.of(context).primaryColor
                : Colors.grey.shade300,
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
          borderRadius: BorderRadius.circular(8),
          color: _isDragOver
              ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
              : widget.isEnabled
                  ? Colors.grey.shade50
                  : Colors.grey.shade100,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                size: 32,
                color: widget.isEnabled
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
              ),
              const SizedBox(height: 8),
              Text(
                widget.isEnabled
                    ? 'Tap to select images or drag & drop'
                    : 'Upload in progress...',
                style: TextStyle(
                  fontSize: 16,
                  color: widget.isEnabled
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'PNG, JPG, WebP, GIF, BMP • Max 20MB each • Up to 10 images',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
