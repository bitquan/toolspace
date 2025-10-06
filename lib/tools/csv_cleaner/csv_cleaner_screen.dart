import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'logic/csv_processor.dart';

/// CSV Cleaner tool for trimming, deduplicating, and normalizing CSV files
class CsvCleanerScreen extends StatefulWidget {
  const CsvCleanerScreen({super.key});

  @override
  State<CsvCleanerScreen> createState() => _CsvCleanerScreenState();
}

class _CsvCleanerScreenState extends State<CsvCleanerScreen> {
  List<List<String>> _csvData = [];
  String _fileName = '';
  bool _isLoading = false;
  String? _errorMessage;
  int? _selectedKeyColumn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CSV Cleaner'),
        elevation: 0,
      ),
      body: _csvData.isEmpty && !_isLoading
          ? _buildEmptyState(theme)
          : _isLoading
              ? _buildLoadingState()
              : _buildDataView(theme),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.table_chart_outlined,
              size: 64,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No CSV file loaded',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload a CSV file to get started',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: _pickFile,
            icon: const Icon(Icons.upload_file),
            label: const Text('Upload CSV File'),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: theme.colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      _errorMessage!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading CSV file...'),
        ],
      ),
    );
  }

  Widget _buildDataView(ThemeData theme) {
    final headers = CsvProcessor.getHeaders(_csvData);
    
    return Column(
      children: [
        // Header with file info and actions
        Container(
          padding: const EdgeInsets.all(16),
          color: theme.colorScheme.surfaceContainerHighest,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.table_chart,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _fileName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _clearData,
                    tooltip: 'Clear data',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${_csvData.length} rows × ${headers.length} columns',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              
              // Operation buttons
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildActionChip(
                    context,
                    label: 'Trim Whitespace',
                    icon: Icons.format_clear,
                    onPressed: _trimWhitespace,
                  ),
                  _buildActionChip(
                    context,
                    label: 'Lowercase Headers',
                    icon: Icons.text_fields,
                    onPressed: _lowercaseHeaders,
                  ),
                  _buildActionChip(
                    context,
                    label: 'Remove Duplicates',
                    icon: Icons.content_copy,
                    onPressed: _showDedupeDialog,
                  ),
                  _buildActionChip(
                    context,
                    label: 'Export CSV',
                    icon: Icons.download,
                    onPressed: _exportCsv,
                    isPrimary: true,
                  ),
                  _buildActionChip(
                    context,
                    label: 'Upload New',
                    icon: Icons.upload_file,
                    onPressed: _pickFile,
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // CSV table preview
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: _buildDataTable(theme),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionChip(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    final theme = Theme.of(context);
    
    if (isPrimary) {
      return FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      );
    }
    
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildDataTable(ThemeData theme) {
    if (_csvData.isEmpty) return const SizedBox();

    final headers = _csvData[0];
    final dataRows = _csvData.skip(1).toList();

    return DataTable(
      headingRowColor: WidgetStateProperty.all(
        theme.colorScheme.primaryContainer.withOpacity(0.5),
      ),
      columns: headers
          .map((header) => DataColumn(
                label: Text(
                  header,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ))
          .toList(),
      rows: dataRows
          .map((row) => DataRow(
                cells: row
                    .map((cell) => DataCell(
                          Text(
                            cell,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                    .toList(),
              ))
          .toList(),
    );
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });

        final bytes = result.files.single.bytes!;
        final content = utf8.decode(bytes);
        
        await Future.delayed(const Duration(milliseconds: 300));
        
        final rows = CsvProcessor.parseCsv(content);
        final validation = CsvProcessor.validate(rows);

        setState(() {
          _isLoading = false;
          if (validation.isValid) {
            _csvData = rows;
            _fileName = result.files.single.name;
            _errorMessage = null;
          } else {
            _errorMessage = validation.error ?? 'Invalid CSV format';
          }
        });

        if (validation.isValid) {
          _showSuccessSnackBar('CSV file loaded successfully');
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load CSV file: $e';
      });
    }
  }

  void _trimWhitespace() {
    setState(() {
      _csvData = CsvProcessor.trimWhitespace(_csvData);
    });
    _showSuccessSnackBar('Whitespace trimmed from all cells');
  }

  void _lowercaseHeaders() {
    setState(() {
      _csvData = CsvProcessor.lowercaseHeaders(_csvData);
    });
    _showSuccessSnackBar('Headers converted to lowercase');
  }

  Future<void> _showDedupeDialog() async {
    final headers = CsvProcessor.getHeaders(_csvData);
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Duplicates'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select column to use as key for deduplication:'),
            const SizedBox(height: 16),
            DropdownButton<int?>(
              value: _selectedKeyColumn,
              isExpanded: true,
              hint: const Text('Use entire row'),
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('Entire row (all columns)'),
                ),
                ...List.generate(
                  headers.length,
                  (index) => DropdownMenuItem<int?>(
                    value: index,
                    child: Text(headers[index]),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedKeyColumn = value;
                });
                Navigator.of(context).pop();
                _removeDuplicates(value);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _removeDuplicates(int? keyColumn) {
    final beforeCount = _csvData.length;
    setState(() {
      _csvData = CsvProcessor.removeDuplicates(_csvData, keyColumnIndex: keyColumn);
    });
    final afterCount = _csvData.length;
    final removed = beforeCount - afterCount;
    _showSuccessSnackBar('Removed $removed duplicate row${removed == 1 ? '' : 's'}');
  }

  void _exportCsv() {
    final csvContent = CsvProcessor.toCsv(_csvData);
    
    // Copy to clipboard
    Clipboard.setData(ClipboardData(text: csvContent));
    
    _showSuccessSnackBar('CSV exported to clipboard');
  }

  void _clearData() {
    setState(() {
      _csvData = [];
      _fileName = '';
      _errorMessage = null;
      _selectedKeyColumn = null;
    });
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
