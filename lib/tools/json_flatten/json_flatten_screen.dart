import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../billing/billing_service.dart';
import '../../billing/widgets/paywall_guard.dart';
import '../../core/services/shared_data_service.dart';
import '../../core/ui/import_data_button.dart';
import '../../core/ui/share_data_button.dart';
import 'logic/json_flattener.dart';

/// JSON CSV Flattener - Flatten nested JSON to CSV with field selection
class JsonFlattenScreen extends StatefulWidget {
  const JsonFlattenScreen({super.key});

  @override
  State<JsonFlattenScreen> createState() => _JsonFlattenScreenState();
}

class _JsonFlattenScreenState extends State<JsonFlattenScreen>
    with TickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _csvController = TextEditingController();
  final BillingService _billingService = BillingService();

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  FlattenResult? _flattenResult;
  NotationStyle _notationStyle = NotationStyle.dot;
  List<String> _selectedKeys = [];
  String? _errorMessage;
  bool _isFlattening = false;

  @override
  void initState() {
    super.initState();
    _inputController.addListener(_onInputChanged);

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _csvController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onInputChanged() {
    // Debounce flattening to avoid excessive processing
    if (_inputController.text.trim().isEmpty) {
      setState(() {
        _flattenResult = null;
        _selectedKeys = [];
        _errorMessage = null;
        _csvController.clear();
      });
    }
  }

  Future<void> _flattenJson() async {
    setState(() {
      _isFlattening = true;
      _errorMessage = null;
    });

    // Simulate async processing for heavy JSON
    await Future.delayed(const Duration(milliseconds: 100));

    final result = JsonFlattener.flatten(
      _inputController.text,
      notation: _notationStyle,
    );

    setState(() {
      _flattenResult = result;
      _isFlattening = false;

      if (result.success) {
        // Select all keys by default
        _selectedKeys = List.from(result.allKeys);
        _generateCSV();
        _pulseController.forward().then((_) => _pulseController.reverse());
      } else {
        _errorMessage = result.error;
        _selectedKeys = [];
        _csvController.clear();
      }
    });
  }

  void _generateCSV() {
    if (_flattenResult == null || !_flattenResult!.success) {
      return;
    }

    final csv = JsonFlattener.toCSV(
      _flattenResult!.rows,
      _selectedKeys,
    );

    setState(() {
      _csvController.text = csv;
    });
  }

  void _toggleKey(String key) {
    setState(() {
      if (_selectedKeys.contains(key)) {
        _selectedKeys.remove(key);
      } else {
        _selectedKeys.add(key);
      }
      _generateCSV();
    });
  }

  void _selectAllKeys() {
    if (_flattenResult == null) return;
    setState(() {
      _selectedKeys = List.from(_flattenResult!.allKeys);
      _generateCSV();
    });
  }

  void _deselectAllKeys() {
    setState(() {
      _selectedKeys = [];
      _generateCSV();
    });
  }

  void _copyCSV() {
    if (_csvController.text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _csvController.text));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('CSV copied to clipboard!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _downloadCSV() async {
    if (_csvController.text.isNotEmpty) {
      // Track heavy operation (CSV export)
      await _billingService.trackHeavyOp();

      // On web, this would trigger a download
      // For now, we'll just copy to clipboard with a message
      Clipboard.setData(ClipboardData(text: _csvController.text));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('CSV ready! (Copied to clipboard)'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _clearAll() {
    _inputController.clear();
    _csvController.clear();
    setState(() {
      _flattenResult = null;
      _selectedKeys = [];
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stats = _flattenResult != null
        ? JsonFlattener.getStatistics(_flattenResult!)
        : null;

    // Calculate input size for paywall (large JSON exports are heavy ops)
    final inputBytes = _inputController.text.length;
    final outputRows = _flattenResult?.rows.length ?? 0;

    return PaywallGuard(
      billingService: _billingService,
      permission: ToolPermission(
        toolId: 'json_flatten',
        requiresHeavyOp: outputRows > 100, // Heavy if exporting >100 rows
        fileSize: inputBytes > 0 ? inputBytes : null,
        batchSize: outputRows > 0 ? outputRows : null,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6A1B9A).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.table_chart,
                  color: Color(0xFF6A1B9A),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text('JSON CSV Flattener'),
            ],
          ),
          actions: [
            ImportDataButton(
              acceptedTypes: const [SharedDataType.json, SharedDataType.text],
              onImport: (data, type, source) {
                setState(() {
                  _inputController.text = data;
                });
              },
              compact: true,
            ),
            if (_csvController.text.isNotEmpty)
              ShareDataButton(
                data: _csvController.text,
                type: SharedDataType.text,
                sourceTool: 'JSON Flatten',
                compact: true,
              ),
            IconButton(
              onPressed: _clearAll,
              icon: const Icon(Icons.clear_all),
              tooltip: 'Clear All',
            ),
            IconButton(
              onPressed: _copyCSV,
              icon: const Icon(Icons.copy),
              tooltip: 'Copy CSV',
            ),
            IconButton(
              onPressed: _downloadCSV,
              icon: const Icon(Icons.download),
              tooltip: 'Download CSV',
            ),
          ],
        ),
        body: Column(
          children: [
            // Status bar with stats
            if (_flattenResult != null && _flattenResult!.success)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                  border: Border(
                    bottom: BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Wrap(
                        spacing: 24,
                        runSpacing: 8,
                        children: [
                          _buildStatItem(
                            theme,
                            Icons.table_rows,
                            '${stats!['rows']} rows',
                          ),
                          _buildStatItem(
                            theme,
                            Icons.view_column,
                            '${stats['columns']} columns',
                          ),
                          _buildStatItem(
                            theme,
                            Icons.grid_on,
                            '${stats['totalCells']} cells',
                          ),
                          _buildStatItem(
                            theme,
                            Icons.layers,
                            'Depth: ${stats['maxDepth']}',
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

            // Error message
            if (_errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                  border: Border(
                    bottom: BorderSide(
                      color: theme.colorScheme.error.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Main content
            Expanded(
              child: Row(
                children: [
                  // Left panel: JSON Input
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: theme.colorScheme.outline
                                .withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Text(
                                  'JSON Input',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                SegmentedButton<NotationStyle>(
                                  segments: const [
                                    ButtonSegment(
                                      value: NotationStyle.dot,
                                      label: Text('Dot'),
                                      icon: Icon(Icons.circle, size: 8),
                                    ),
                                    ButtonSegment(
                                      value: NotationStyle.bracket,
                                      label: Text('Bracket'),
                                      icon: Icon(Icons.code, size: 16),
                                    ),
                                  ],
                                  selected: {_notationStyle},
                                  onSelectionChanged:
                                      (Set<NotationStyle> value) {
                                    setState(() {
                                      _notationStyle = value.first;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: TextField(
                                controller: _inputController,
                                maxLines: null,
                                expands: true,
                                textAlignVertical: TextAlignVertical.top,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 14,
                                ),
                                decoration: InputDecoration(
                                  hintText:
                                      'Paste your JSON here...\n\n[\n  {"name": "Alice", "age": 30, "address": {"city": "NYC"}},\n  {"name": "Bob", "age": 25, "address": {"city": "LA"}}\n]',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.all(16),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: _isFlattening ? null : _flattenJson,
                                icon: _isFlattening
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.transform),
                                label: Text(
                                  _isFlattening
                                      ? 'Flattening...'
                                      : 'Flatten to CSV',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Middle panel: Field Selector
                  if (_flattenResult != null && _flattenResult!.success)
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(
                              color: theme.colorScheme.outline
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Text(
                                    'Fields',
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${_selectedKeys.length}/${_flattenResult!.allKeys.length}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: _selectAllKeys,
                                      child: const Text('Select All'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: _deselectAllKeys,
                                      child: const Text('Deselect All'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: ListView.builder(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: _flattenResult!.allKeys.length,
                                itemBuilder: (context, index) {
                                  final key = _flattenResult!.allKeys[index];
                                  final isSelected =
                                      _selectedKeys.contains(key);
                                  return CheckboxListTile(
                                    value: isSelected,
                                    onChanged: (bool? value) {
                                      _toggleKey(key);
                                    },
                                    title: Text(
                                      key,
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 13,
                                      ),
                                    ),
                                    dense: true,
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Right panel: CSV Preview
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'CSV Preview',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: TextField(
                              controller: _csvController,
                              maxLines: null,
                              expands: true,
                              readOnly: true,
                              textAlignVertical: TextAlignVertical.top,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 14,
                              ),
                              decoration: InputDecoration(
                                hintText:
                                    'CSV output will appear here after flattening...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.all(16),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ), // Scaffold
    ); // PaywallGuard
  }

  Widget _buildStatItem(ThemeData theme, IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
