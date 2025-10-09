import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import '../../shared/shared_data_service.dart';

// Conditional import for web-only functionality
import 'csv_cleaner_web_stub.dart'
    if (dart.library.html) 'csv_cleaner_web.dart' as web_helper;

class CsvCleanerScreen extends StatefulWidget {
  const CsvCleanerScreen({super.key});

  @override
  State<CsvCleanerScreen> createState() => _CsvCleanerScreenState();
}

class _CsvCleanerScreenState extends State<CsvCleanerScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  List<List<String>> _csvData = [];
  List<String> _headers = [];
  String? _selectedDedupeColumn;
  bool _isLoading = false;
  String? _fileName;
  String _statusMessage = '';

  // Operation states
  bool _trimWhitespace = true;
  bool _lowercaseHeaders = true;
  bool _removeDuplicates = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _pickFile() async {
    try {
      web_helper.pickCsvFile((content, fileName) {
        _fileName = fileName;
        _processCsvContent(content);
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'File picking not supported on this platform';
      });
    }
  }

  void _processCsvContent(String content) async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Processing CSV file...';
    });

    try {
      await Future.delayed(const Duration(milliseconds: 500)); // UX delay

      final List<List<dynamic>> rawData =
          const CsvToListConverter().convert(content);

      if (rawData.isEmpty) {
        throw Exception('CSV file is empty');
      }

      _headers = rawData[0].map((e) => e.toString()).toList();
      _csvData = rawData
          .skip(1)
          .map((row) => row.map((cell) => cell.toString()).toList())
          .toList();

      setState(() {
        _isLoading = false;
        _statusMessage =
            'CSV loaded successfully! ${_csvData.length} rows found.';
        _selectedDedupeColumn = _headers.isNotEmpty ? _headers[0] : null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error processing CSV: ${e.toString()}';
        _csvData.clear();
        _headers.clear();
      });
    }
  }

  void _applyCleaningOperations() async {
    if (_csvData.isEmpty) return;

    setState(() {
      _isLoading = true;
      _statusMessage = 'Applying cleaning operations...';
    });

    await Future.delayed(const Duration(milliseconds: 300));

    try {
      List<List<String>> cleanedData = List.from(_csvData);
      List<String> cleanedHeaders = List.from(_headers);

      // Trim whitespace
      if (_trimWhitespace) {
        cleanedData = cleanedData
            .map((row) => row.map((cell) => cell.trim()).toList())
            .toList();
      }

      // Lowercase headers
      if (_lowercaseHeaders) {
        cleanedHeaders =
            cleanedHeaders.map((header) => header.toLowerCase()).toList();
      }

      // Remove duplicates
      if (_removeDuplicates && _selectedDedupeColumn != null) {
        final columnIndex = _headers.indexOf(_selectedDedupeColumn!);
        if (columnIndex != -1) {
          final seen = <String>{};
          cleanedData = cleanedData.where((row) {
            if (row.length > columnIndex) {
              final value = row[columnIndex];
              if (seen.contains(value)) {
                return false;
              }
              seen.add(value);
            }
            return true;
          }).toList();
        }
      }

      setState(() {
        _csvData = cleanedData;
        _headers = cleanedHeaders;
        _isLoading = false;
        _statusMessage =
            'Cleaning operations applied! ${cleanedData.length} rows remaining.';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error during cleaning: ${e.toString()}';
      });
    }
  }

  void _exportCsv() {
    if (_csvData.isEmpty) return;

    try {
      final List<List<String>> exportData = [_headers, ..._csvData];
      final String csvContent = const ListToCsvConverter().convert(exportData);

      // Download using platform-specific helper
      final downloadFileName =
          _fileName?.replaceAll('.csv', '_cleaned.csv') ?? 'cleaned_data.csv';
      web_helper.downloadCsv(csvContent, downloadFileName);

      setState(() {
        _statusMessage = 'CSV exported successfully!';
      });

      // Save to shared data for cross-tool use
      SharedDataService.instance.setSharedData('csv_cleaner_export', {
        'headers': _headers,
        'data': _csvData,
        'filename': _fileName,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error exporting CSV: ${e.toString()}';
      });
    }
  }

  void _resetData() {
    setState(() {
      _csvData.clear();
      _headers.clear();
      _fileName = null;
      _statusMessage = '';
      _selectedDedupeColumn = null;
      _trimWhitespace = true;
      _lowercaseHeaders = true;
      _removeDuplicates = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CSV Cleaner'),
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundColor: theme.colorScheme.onPrimaryContainer,
        elevation: 0,
        actions: [
          if (_csvData.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _resetData,
              tooltip: 'Reset',
            ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.cleaning_services,
                            color: theme.colorScheme.primary,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CSV Data Cleaner',
                                  style:
                                      theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Trim whitespace, normalize headers, and remove duplicates',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_csvData.isEmpty)
                        Center(
                          child: Column(
                            children: [
                              FilledButton.icon(
                                onPressed: _isLoading ? null : _pickFile,
                                icon: _isLoading
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      )
                                    : const Icon(Icons.upload_file),
                                label: Text(_isLoading
                                    ? 'Processing...'
                                    : 'Upload CSV File'),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Drag and drop a CSV file or click to browse',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Status Message
              if (_statusMessage.isNotEmpty)
                Card(
                  color: _statusMessage.contains('Error')
                      ? theme.colorScheme.errorContainer
                      : theme.colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(
                          _statusMessage.contains('Error')
                              ? Icons.error_outline
                              : Icons.info_outline,
                          color: _statusMessage.contains('Error')
                              ? theme.colorScheme.onErrorContainer
                              : theme.colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _statusMessage,
                            style: TextStyle(
                              color: _statusMessage.contains('Error')
                                  ? theme.colorScheme.onErrorContainer
                                  : theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Operations Panel
              if (_csvData.isNotEmpty) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cleaning Operations',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        CheckboxListTile(
                          title: const Text('Trim Whitespace'),
                          subtitle: const Text(
                              'Remove leading and trailing spaces from all cells'),
                          value: _trimWhitespace,
                          onChanged: (value) =>
                              setState(() => _trimWhitespace = value ?? false),
                        ),
                        CheckboxListTile(
                          title: const Text('Lowercase Headers'),
                          subtitle: const Text(
                              'Convert all column headers to lowercase'),
                          value: _lowercaseHeaders,
                          onChanged: (value) => setState(
                              () => _lowercaseHeaders = value ?? false),
                        ),
                        CheckboxListTile(
                          title: const Text('Remove Duplicates'),
                          subtitle: const Text(
                              'Remove duplicate rows based on selected column'),
                          value: _removeDuplicates,
                          onChanged: (value) => setState(
                              () => _removeDuplicates = value ?? false),
                        ),
                        if (_removeDuplicates && _headers.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 56, top: 8),
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Duplicate Detection Column',
                                border: OutlineInputBorder(),
                              ),
                              initialValue: _selectedDedupeColumn,
                              items: _headers.map((header) {
                                return DropdownMenuItem(
                                  value: header,
                                  child: Text(header),
                                );
                              }).toList(),
                              onChanged: (value) =>
                                  setState(() => _selectedDedupeColumn = value),
                            ),
                          ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            FilledButton.icon(
                              onPressed:
                                  _isLoading ? null : _applyCleaningOperations,
                              icon: const Icon(Icons.auto_fix_high),
                              label: const Text('Apply Operations'),
                            ),
                            const SizedBox(width: 12),
                            FilledButton.tonalIcon(
                              onPressed: _isLoading ? null : _exportCsv,
                              icon: const Icon(Icons.download),
                              label: const Text('Export CSV'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Data Preview
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Data Preview',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Chip(
                              label: Text('${_csvData.length} rows'),
                              backgroundColor:
                                  theme.colorScheme.primaryContainer,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          constraints: const BoxConstraints(maxHeight: 400),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: _headers.map((header) {
                                return DataColumn(
                                  label: Text(
                                    header,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                );
                              }).toList(),
                              rows: _csvData.take(10).map((row) {
                                return DataRow(
                                  cells: row.map((cell) {
                                    return DataCell(
                                      Container(
                                        constraints:
                                            const BoxConstraints(maxWidth: 150),
                                        child: Text(
                                          cell,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        if (_csvData.length > 10)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Showing first 10 rows of ${_csvData.length} total rows',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
