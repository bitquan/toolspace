import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A reusable button component for copying text to clipboard
class ClipboardButton extends StatefulWidget {
  final String text;
  final String? label;
  final IconData? icon;
  final VoidCallback? onCopied;
  final bool compact;

  const ClipboardButton({
    super.key,
    required this.text,
    this.label,
    this.icon,
    this.onCopied,
    this.compact = false,
  });

  @override
  State<ClipboardButton> createState() => _ClipboardButtonState();
}

class _ClipboardButtonState extends State<ClipboardButton> {
  bool _copied = false;

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: widget.text));

    setState(() {
      _copied = true;
    });

    // Show feedback
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Copied to clipboard!'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    // Call optional callback
    widget.onCopied?.call();

    // Reset copied state after delay
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _copied = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final icon = _copied ? Icons.check : (widget.icon ?? Icons.copy);

    if (widget.compact) {
      return IconButton(
        onPressed: widget.text.isEmpty ? null : _copyToClipboard,
        icon: Icon(icon),
        tooltip: _copied ? 'Copied!' : 'Copy to clipboard',
      );
    }

    return FilledButton.icon(
      onPressed: widget.text.isEmpty ? null : _copyToClipboard,
      icon: Icon(icon),
      label: Text(_copied ? 'Copied!' : (widget.label ?? 'Copy')),
    );
  }
}
