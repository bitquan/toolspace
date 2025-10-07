import 'package:flutter/material.dart';

/// Shows progress during upload and resize operations
class ResizeProgress extends StatelessWidget {
  final bool isUploading;
  final bool isResizing;

  const ResizeProgress({
    super.key,
    required this.isUploading,
    required this.isResizing,
  });

  @override
  Widget build(BuildContext context) {
    if (!isUploading && !isResizing) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                Text(
                  isUploading ? 'Uploading images...' : 'Resizing images...',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const LinearProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
