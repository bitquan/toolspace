import 'package:flutter/material.dart';
import '../logic/batch_generator.dart';

/// Batch generation panel widget
class BatchPanel extends StatefulWidget {
  final Function(List<QrBatchItem>) onGenerate;
  final BatchConfig config;

  const BatchPanel({
    super.key,
    required this.onGenerate,
    required this.config,
  });

  @override
  State<BatchPanel> createState() => _BatchPanelState();
}

class _BatchPanelState extends State<BatchPanel> {
  final TextEditingController _batchTextController = TextEditingController();
  String _inputFormat = 'csv';
  List<QrBatchItem> _parsedItems = [];
  List<BatchError> _parseErrors = [];
  bool _isParsing = false;

  @override
  void dispose() {
    _batchTextController.dispose();
    super.dispose();
  }

  void _parseBatchInput() {
    setState(() {
      _isParsing = true;
      _parseErrors.clear();
    });

    final content = _batchTextController.text.trim();
    if (content.isEmpty) {
      setState(() {
        _parsedItems = [];
        _isParsing = false;
      });
      return;
    }

    List<QrBatchItem> items;
    try {
      if (_inputFormat == 'csv') {
        items = BatchQrGenerator.parseCsv(content);
      } else {
        items = BatchQrGenerator.parseJson(content);
      }

      final validationErrors = BatchQrGenerator.validateItems(items);

      setState(() {
        _parsedItems = items;
        _parseErrors = validationErrors;
        _isParsing = false;
      });
    } catch (e) {
      setState(() {
        _parsedItems = [];
        _parseErrors = [
          BatchError(
            item: const QrBatchItem(content: ''),
            errorMessage: 'Parse error: $e',
          ),
        ];
        _isParsing = false;
      });
    }
  }

  void _generateBatch() {
    if (_parsedItems.isEmpty) return;
    widget.onGenerate(_parsedItems);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Format selector
          Text(
            'Input Format',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'csv',
                label: Text('CSV'),
                icon: Icon(Icons.table_chart),
              ),
              ButtonSegment(
                value: 'json',
                label: Text('JSON'),
                icon: Icon(Icons.code),
              ),
            ],
            selected: {_inputFormat},
            onSelectionChanged: (Set<String> newSelection) {
              setState(() {
                _inputFormat = newSelection.first;
              });
            },
          ),

          const SizedBox(height: 24),

          // Input field
          Text(
            'Batch Data',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _inputFormat == 'csv'
                ? 'Format: content,filename (one per line)'
                : 'Format: [{"content":"...","filename":"..."}]',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _batchTextController,
            maxLines: 10,
            decoration: InputDecoration(
              hintText: _inputFormat == 'csv'
                  ? 'https://example.com,qr1\nhttps://github.com,qr2'
                  : '[{"content":"https://example.com","filename":"qr1"}]',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            onChanged: (_) => _parseBatchInput(),
          ),

          const SizedBox(height: 16),

          // Parse status
          if (_isParsing)
            const Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 8),
                Text('Parsing...'),
              ],
            ),

          if (!_isParsing && _parsedItems.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Parsed ${_parsedItems.length} item${_parsedItems.length != 1 ? 's' : ''}',
                    style: const TextStyle(color: Colors.green),
                  ),
                ],
              ),
            ),

          if (!_isParsing && _parseErrors.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${_parseErrors.length} validation error${_parseErrors.length != 1 ? 's' : ''}',
                        style: const TextStyle(color: Colors.orange),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...(_parseErrors.take(3).map((error) => Padding(
                        padding: const EdgeInsets.only(left: 28, top: 4),
                        child: Text(
                          '• ${error.errorMessage}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.orange,
                          ),
                        ),
                      ))),
                  if (_parseErrors.length > 3)
                    Padding(
                      padding: const EdgeInsets.only(left: 28, top: 4),
                      child: Text(
                        '...and ${_parseErrors.length - 3} more',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.orange,
                        ),
                      ),
                    ),
                ],
              ),
            ),

          const SizedBox(height: 24),

          // Generate button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _parsedItems.isEmpty ? null : _generateBatch,
              icon: const Icon(Icons.qr_code_scanner),
              label: Text(
                  'Generate ${_parsedItems.length} QR Code${_parsedItems.length != 1 ? 's' : ''}'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5722),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                disabledBackgroundColor: Colors.grey.withOpacity(0.3),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Example templates
          Text(
            'Examples',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ExampleChip(
                label: 'URLs',
                onTap: () {
                  _batchTextController.text = _inputFormat == 'csv'
                      ? 'https://example.com,example\nhttps://github.com,github\nhttps://flutter.dev,flutter'
                      : '[{"content":"https://example.com","filename":"example"},{"content":"https://github.com","filename":"github"}]';
                  _parseBatchInput();
                },
              ),
              _ExampleChip(
                label: 'Text',
                onTap: () {
                  _batchTextController.text = _inputFormat == 'csv'
                      ? 'Hello World,hello\nWelcome,welcome\nThank you,thanks'
                      : '[{"content":"Hello World","filename":"hello"},{"content":"Welcome","filename":"welcome"}]';
                  _parseBatchInput();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Example chip widget
class _ExampleChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ExampleChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      avatar: const Icon(Icons.lightbulb_outline, size: 16),
    );
  }
}
