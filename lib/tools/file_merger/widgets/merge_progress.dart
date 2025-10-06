import 'package:flutter/material.dart';

/// Progress indicator for upload and merge operations
class MergeProgress extends StatelessWidget {
  final bool isUploading;
  final bool isMerging;

  const MergeProgress({
    super.key,
    required this.isUploading,
    required this.isMerging,
  });

  @override
  Widget build(BuildContext context) {
    String message;
    IconData icon;
    Color color;

    if (isUploading) {
      message = 'Uploading files to secure storage...';
      icon = Icons.cloud_upload;
      color = Colors.blue;
    } else if (isMerging) {
      message = 'Merging files into PDF...';
      icon = Icons.merge_type;
      color = Colors.orange;
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              const SizedBox(width: 12),
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: color.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(color),
            backgroundColor: color.withOpacity(0.2),
          ),
        ],
      ),
    );
  }
}
