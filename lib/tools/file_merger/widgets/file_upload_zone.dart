import 'package:flutter/material.dart';

/// Drag-and-drop upload zone for file selection
class FileUploadZone extends StatefulWidget {
  final VoidCallback onFilesSelected;
  final bool isEnabled;

  const FileUploadZone({
    super.key,
    required this.onFilesSelected,
    this.isEnabled = true,
  });

  @override
  State<FileUploadZone> createState() => _FileUploadZoneState();
}

class _FileUploadZoneState extends State<FileUploadZone> {
  final bool _isDragOver = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isEnabled ? widget.onFilesSelected : null,
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
              ? Theme.of(context).primaryColor.withOpacity(0.1)
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
                    ? 'Tap to select files or drag & drop'
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
                'PDF, PNG, JPG files • Max 10MB each • Up to 20 files',
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
