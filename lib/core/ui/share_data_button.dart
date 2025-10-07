import 'package:flutter/material.dart';
import '../services/shared_data_service.dart';

/// A reusable button for sharing data to other tools
class ShareDataButton extends StatelessWidget {
  final String data;
  final SharedDataType type;
  final String sourceTool;
  final String? label;
  final IconData? icon;
  final bool compact;
  final VoidCallback? onShared;

  const ShareDataButton({
    super.key,
    required this.data,
    required this.type,
    required this.sourceTool,
    this.label,
    this.icon,
    this.compact = false,
    this.onShared,
  });

  void _shareData(BuildContext context) {
    if (data.isEmpty) return;

    final sharedData = SharedData(
      type: type,
      data: data,
      label: label,
      sourceTool: sourceTool,
    );

    SharedDataService.instance.shareData(sharedData);

    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Data shared! You can now use it in other tools.'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );

    onShared?.call();
  }

  @override
  Widget build(BuildContext context) {
    final displayIcon = icon ?? Icons.share;

    if (compact) {
      return IconButton(
        onPressed: data.isEmpty ? null : () => _shareData(context),
        icon: Icon(displayIcon),
        tooltip: 'Share with other tools',
      );
    }

    return FilledButton.icon(
      onPressed: data.isEmpty ? null : () => _shareData(context),
      icon: Icon(displayIcon),
      label: Text(label ?? 'Share'),
    );
  }
}
