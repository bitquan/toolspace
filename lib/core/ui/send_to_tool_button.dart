import 'package:flutter/material.dart';
import '../services/tool_navigation.dart';

/// Button widget for sending data to another tool
///
/// Provides a dropdown menu to select a target tool and navigate with data
class SendToToolButton extends StatelessWidget {
  final String data;
  final String? label;
  final IconData? icon;
  final List<ToolDestination> destinations;

  const SendToToolButton({
    super.key,
    required this.data,
    this.label,
    this.icon,
    this.destinations = const [
      ToolDestination.textTools,
      ToolDestination.jsonDoctor,
      ToolDestination.qrMaker,
      ToolDestination.textDiff,
    ],
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox.shrink();
    }

    return PopupMenuButton<ToolDestination>(
      icon: Icon(icon ?? Icons.send),
      tooltip: label ?? 'Send to tool',
      onSelected: (destination) => _sendToTool(context, destination),
      itemBuilder: (context) => destinations.map((dest) {
        return PopupMenuItem<ToolDestination>(
          value: dest,
          child: Row(
            children: [
              Icon(dest.icon, size: 20),
              const SizedBox(width: 12),
              Text(dest.label),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _sendToTool(BuildContext context, ToolDestination destination) {
    switch (destination) {
      case ToolDestination.textTools:
        ToolNavigation.toTextTools(context, initialText: data);
        break;
      case ToolDestination.jsonDoctor:
        ToolNavigation.toJsonDoctor(context, initialJson: data);
        break;
      case ToolDestination.qrMaker:
        ToolNavigation.toQrMaker(context, qrData: data);
        break;
      case ToolDestination.textDiff:
        ToolNavigation.toTextDiff(context, text1: data);
        break;
    }
  }
}

/// Available tool destinations for data sharing
enum ToolDestination {
  textTools('Text Tools', Icons.text_fields),
  jsonDoctor('JSON Doctor', Icons.healing),
  qrMaker('QR Maker', Icons.qr_code),
  textDiff('Text Diff', Icons.compare_arrows);

  final String label;
  final IconData icon;

  const ToolDestination(this.label, this.icon);
}
