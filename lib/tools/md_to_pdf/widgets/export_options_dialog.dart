import 'package:flutter/material.dart';
import '../logic/pdf_exporter.dart';

class ExportOptionsDialog extends StatefulWidget {
  const ExportOptionsDialog({super.key});

  @override
  State<ExportOptionsDialog> createState() => _ExportOptionsDialogState();
}

class _ExportOptionsDialogState extends State<ExportOptionsDialog> {
  String _selectedTheme = 'github';
  String _selectedPageSize = 'a4';
  bool _includePageNumbers = true;
  double _topMargin = 20.0;
  double _bottomMargin = 20.0;
  double _leftMargin = 20.0;
  double _rightMargin = 20.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Export Options'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Theme Selection
              Text(
                'Theme',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'github',
                    label: Text('GitHub'),
                    icon: Icon(Icons.code),
                  ),
                  ButtonSegment(
                    value: 'clean',
                    label: Text('Clean'),
                    icon: Icon(Icons.auto_awesome),
                  ),
                  ButtonSegment(
                    value: 'academic',
                    label: Text('Academic'),
                    icon: Icon(Icons.school),
                  ),
                ],
                selected: {_selectedTheme},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _selectedTheme = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Page Size Selection
              Text(
                'Page Size',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedPageSize,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: const [
                  DropdownMenuItem(value: 'a4', child: Text('A4')),
                  DropdownMenuItem(value: 'letter', child: Text('Letter')),
                  DropdownMenuItem(value: 'legal', child: Text('Legal')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedPageSize = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Page Numbers
              CheckboxListTile(
                title: const Text('Include Page Numbers'),
                value: _includePageNumbers,
                onChanged: (value) {
                  setState(() {
                    _includePageNumbers = value ?? true;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),

              // Margins
              Text(
                'Margins (mm)',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildMarginField(
                      label: 'Top',
                      value: _topMargin,
                      onChanged: (value) => setState(() => _topMargin = value),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMarginField(
                      label: 'Bottom',
                      value: _bottomMargin,
                      onChanged: (value) => setState(() => _bottomMargin = value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildMarginField(
                      label: 'Left',
                      value: _leftMargin,
                      onChanged: (value) => setState(() => _leftMargin = value),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMarginField(
                      label: 'Right',
                      value: _rightMargin,
                      onChanged: (value) => setState(() => _rightMargin = value),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: () {
            final options = ExportOptions(
              theme: _selectedTheme,
              pageSize: _selectedPageSize,
              includePageNumbers: _includePageNumbers,
              margins: PageMargins(
                top: _topMargin,
                bottom: _bottomMargin,
                left: _leftMargin,
                right: _rightMargin,
              ),
            );
            Navigator.of(context).pop(options);
          },
          icon: const Icon(Icons.check),
          label: const Text('Export'),
        ),
      ],
    );
  }

  Widget _buildMarginField({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      keyboardType: TextInputType.number,
      controller: TextEditingController(text: value.toString()),
      onChanged: (text) {
        final parsed = double.tryParse(text);
        if (parsed != null && parsed >= 0 && parsed <= 100) {
          onChanged(parsed);
        }
      },
    );
  }
}
