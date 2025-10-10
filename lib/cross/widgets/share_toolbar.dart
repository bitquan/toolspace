import 'package:flutter/material.dart';
import '../../shared/cross_tool/share_bus.dart';
import '../../shared/cross_tool/share_envelope.dart';
import '../../shared/cross_tool/handoff_store.dart';
import '../../shared/cross_tool/share_intent.dart';

/// Share toolbar with Import, Export, and Send to actions for cross-tool integration
class ShareToolbar extends StatefulWidget {
  final String toolId;
  final List<ShareKind> acceptedTypes;
  final Map<ShareKind, dynamic> Function() exportData;
  final void Function(ShareEnvelope envelope, String sourceTool)? onImport;
  final bool compact;

  const ShareToolbar({
    super.key,
    required this.toolId,
    required this.acceptedTypes,
    required this.exportData,
    this.onImport,
    this.compact = false,
  });

  @override
  State<ShareToolbar> createState() => _ShareToolbarState();
}

class _ShareToolbarState extends State<ShareToolbar> {
  final ShareBus _shareBus = ShareBus.instance;
  final HandoffStore _handoffStore = HandoffStore.instance;

  List<ShareEnvelope> _availableEnvelopes = [];
  List<ShareEnvelope> _recentHandoffs = [];

  @override
  void initState() {
    super.initState();
    _loadAvailableData();
    _loadRecentHandoffs();
    _shareBus.addListener(_onShareBusUpdate);
  }

  @override
  void dispose() {
    _shareBus.removeListener(_onShareBusUpdate);
    super.dispose();
  }

  void _onShareBusUpdate() {
    _loadAvailableData();
  }

  void _loadAvailableData() {
    final allEnvelopes = _shareBus.getAll();
    setState(() {
      _availableEnvelopes = allEnvelopes
          .where((e) => widget.acceptedTypes.contains(e.kind))
          .toList();
    });
  }

  Future<void> _loadRecentHandoffs() async {
    try {
      final handoffs = await _handoffStore.getAll();
      setState(() {
        _recentHandoffs = handoffs
            .where((e) => widget.acceptedTypes.contains(e.kind))
            .take(5)
            .toList();
      });
    } catch (e) {
      // Handle auth or firestore errors silently
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildImportButton(),
          const SizedBox(width: 8),
          _buildExportButton(),
          const SizedBox(width: 8),
          _buildSendToButton(),
        ],
      );
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cross-Tool Actions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _buildImportButton(),
                _buildExportButton(),
                _buildSendToButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImportButton() {
    final hasData =
        _availableEnvelopes.isNotEmpty || _recentHandoffs.isNotEmpty;

    return PopupMenuButton<ShareEnvelope>(
      enabled: hasData,
      onSelected: _onImportSelected,
      itemBuilder: (context) => [
        if (_availableEnvelopes.isNotEmpty) ...[
          const PopupMenuItem<ShareEnvelope>(
            enabled: false,
            child: Text(
              'Recent Shares',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          ..._availableEnvelopes.map((envelope) => PopupMenuItem<ShareEnvelope>(
                value: envelope,
                child: ListTile(
                  dense: true,
                  leading: Icon(_getKindIcon(envelope.kind), size: 16),
                  title: Text(
                    _getKindLabel(envelope.kind),
                    style: const TextStyle(fontSize: 12),
                  ),
                  subtitle: Text(
                    _formatPreview(envelope.value),
                    style: const TextStyle(fontSize: 10),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )),
        ],
        if (_availableEnvelopes.isNotEmpty && _recentHandoffs.isNotEmpty)
          const PopupMenuDivider(),
        if (_recentHandoffs.isNotEmpty) ...[
          const PopupMenuItem<ShareEnvelope>(
            enabled: false,
            child: Text(
              'Recent Handoffs',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          ..._recentHandoffs.map((envelope) => PopupMenuItem<ShareEnvelope>(
                value: envelope,
                child: ListTile(
                  dense: true,
                  leading: Icon(_getKindIcon(envelope.kind), size: 16),
                  title: Text(
                    _getKindLabel(envelope.kind),
                    style: const TextStyle(fontSize: 12),
                  ),
                  subtitle: Text(
                    _formatPreview(envelope.value),
                    style: const TextStyle(fontSize: 10),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )),
        ],
      ],
      child: OutlinedButton.icon(
        onPressed: hasData ? null : null,
        icon: const Icon(Icons.download_outlined, size: 16),
        label: const Text('Import', style: TextStyle(fontSize: 12)),
      ),
    );
  }

  Widget _buildExportButton() {
    return PopupMenuButton<ShareKind>(
      onSelected: _onExportSelected,
      itemBuilder: (context) {
        final exportData = widget.exportData();
        return exportData.keys
            .map((kind) => PopupMenuItem<ShareKind>(
                  value: kind,
                  child: ListTile(
                    dense: true,
                    leading: Icon(_getKindIcon(kind), size: 16),
                    title: Text(
                      'Export as ${_getKindLabel(kind)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ))
            .toList();
      },
      child: OutlinedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.upload_outlined, size: 16),
        label: const Text('Export', style: TextStyle(fontSize: 12)),
      ),
    );
  }

  Widget _buildSendToButton() {
    return PopupMenuButton<String>(
      onSelected: _onSendToSelected,
      itemBuilder: (context) => _getTargetTools()
          .map((tool) => PopupMenuItem<String>(
                value: tool['id'] as String,
                child: ListTile(
                  dense: true,
                  leading: Icon(tool['icon'] as IconData, size: 16),
                  title: Text(
                    'Send to ${tool['name']}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ))
          .toList(),
      child: OutlinedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.send_outlined, size: 16),
        label: const Text('Send to...', style: TextStyle(fontSize: 12)),
      ),
    );
  }

  void _onImportSelected(ShareEnvelope envelope) {
    final sourceTool = envelope.meta['sourceTool'] as String? ?? 'Unknown';

    // Consume from ShareBus if it's a recent share
    if (_availableEnvelopes.contains(envelope)) {
      _shareBus.consumeEnvelope(envelope);
    }

    // Call the import callback
    widget.onImport?.call(envelope, sourceTool);

    // Show success feedback
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Imported from $sourceTool'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              // Re-publish the envelope for undo
              _shareBus.publish(envelope);
            },
          ),
        ),
      );
    }
  }

  void _onExportSelected(ShareKind kind) async {
    final exportData = widget.exportData();
    final data = exportData[kind];

    if (data == null) return;

    final envelope = ShareEnvelope(
      kind: kind,
      value: data,
      meta: {
        'sourceTool': widget.toolId,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    // Publish to ShareBus
    _shareBus.publish(envelope);

    // Save to HandoffStore for persistence
    try {
      await _handoffStore.save(envelope);
    } catch (e) {
      // Handle auth errors silently
    }

    // Show success feedback
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exported ${_getKindLabel(kind)} to share bus'),
        ),
      );
    }
  }

  void _onSendToSelected(String targetToolId) async {
    final exportData = widget.exportData();

    // Find the best export format for the target tool
    ShareKind? bestKind;
    dynamic bestData;

    final targetPreferences = _getToolPreferences(targetToolId);
    for (final preferredKind in targetPreferences) {
      if (exportData.containsKey(preferredKind)) {
        bestKind = preferredKind;
        bestData = exportData[preferredKind];
        break;
      }
    }

    if (bestKind == null || bestData == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No compatible data format for target tool'),
          ),
        );
      }
      return;
    }

    final envelope = ShareEnvelope(
      kind: bestKind,
      value: bestData,
      meta: {
        'sourceTool': widget.toolId,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    // Create share intent and navigate
    final intent = ShareIntent(
      targetTool: targetToolId,
      envelope: envelope,
    );

    // Publish to share bus first
    _shareBus.publish(envelope);

    // Navigate with intent
    if (mounted) {
      Navigator.of(context).pushNamed(intent.toUrl());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Sent ${_getKindLabel(bestKind)} to ${_getToolName(targetToolId)}'),
        ),
      );
    }
  }

  IconData _getKindIcon(ShareKind kind) {
    switch (kind) {
      case ShareKind.text:
        return Icons.text_snippet_outlined;
      case ShareKind.json:
        return Icons.data_object_outlined;
      case ShareKind.fileUrl:
        return Icons.file_download_outlined;
      case ShareKind.dataUrl:
        return Icons.image_outlined;
      case ShareKind.markdown:
        return Icons.description_outlined;
      case ShareKind.csv:
        return Icons.table_chart_outlined;
      case ShareKind.image:
        return Icons.image_outlined;
    }
  }

  String _getKindLabel(ShareKind kind) {
    switch (kind) {
      case ShareKind.text:
        return 'Text';
      case ShareKind.json:
        return 'JSON';
      case ShareKind.fileUrl:
        return 'File URL';
      case ShareKind.dataUrl:
        return 'Data URL';
      case ShareKind.markdown:
        return 'Markdown';
      case ShareKind.csv:
        return 'CSV';
      case ShareKind.image:
        return 'Image';
    }
  }

  String _formatPreview(dynamic value) {
    if (value is String) {
      return value.length > 50 ? '${value.substring(0, 50)}...' : value;
    }
    return value.toString();
  }

  List<Map<String, dynamic>> _getTargetTools() {
    return [
      {'id': 'text_tools', 'name': 'Text Tools', 'icon': Icons.text_fields},
      {'id': 'json_doctor', 'name': 'JSON Doctor', 'icon': Icons.data_object},
      {'id': 'qr_maker', 'name': 'QR Maker', 'icon': Icons.qr_code},
      {'id': 'csv_cleaner', 'name': 'CSV Cleaner', 'icon': Icons.table_chart},
      {'id': 'url_short', 'name': 'URL Shortener', 'icon': Icons.link},
      {'id': 'codec_lab', 'name': 'Codec Lab', 'icon': Icons.transform},
      {'id': 'file_merger', 'name': 'File Merger', 'icon': Icons.merge},
      {
        'id': 'image_resizer',
        'name': 'Image Resizer',
        'icon': Icons.photo_size_select_large
      },
      {'id': 'md_to_pdf', 'name': 'Markdown→PDF', 'icon': Icons.picture_as_pdf},
      {'id': 'json_flatten', 'name': 'JSON Flatten', 'icon': Icons.unfold_more},
      {
        'id': 'invoice_lite',
        'name': 'Invoice Lite',
        'icon': Icons.receipt_long
      },
    ];
  }

  String _getToolName(String toolId) {
    final tool = _getTargetTools().firstWhere(
      (t) => t['id'] == toolId,
      orElse: () => {'name': toolId},
    );
    return tool['name'] as String;
  }

  List<ShareKind> _getToolPreferences(String toolId) {
    switch (toolId) {
      case 'text_tools':
        return [ShareKind.text, ShareKind.markdown];
      case 'json_doctor':
        return [ShareKind.json, ShareKind.text];
      case 'qr_maker':
        return [ShareKind.text, ShareKind.fileUrl, ShareKind.dataUrl];
      case 'csv_cleaner':
        return [ShareKind.csv, ShareKind.text];
      case 'url_short':
        return [ShareKind.text, ShareKind.fileUrl];
      case 'codec_lab':
        return [ShareKind.text, ShareKind.dataUrl];
      case 'file_merger':
        return [ShareKind.fileUrl, ShareKind.text];
      case 'image_resizer':
        return [ShareKind.image, ShareKind.dataUrl, ShareKind.fileUrl];
      case 'md_to_pdf':
        return [ShareKind.markdown, ShareKind.text];
      case 'json_flatten':
        return [ShareKind.json, ShareKind.text];
      case 'invoice_lite':
        return [ShareKind.json, ShareKind.text];
      default:
        return [ShareKind.text, ShareKind.json];
    }
  }
}
