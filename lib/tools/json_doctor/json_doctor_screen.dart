import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'logic/schema_validator.dart';
import 'logic/jsonpath_query.dart';
import '../../core/services/shared_data_service.dart';
import '../../core/ui/import_data_button.dart';
import '../../core/ui/share_data_button.dart';

/// JSON Doctor - Validate, format, and repair JSON with instant feedback
class JsonDoctorScreen extends StatefulWidget {
  const JsonDoctorScreen({super.key});

  @override
  State<JsonDoctorScreen> createState() => _JsonDoctorScreenState();
}

class _JsonDoctorScreenState extends State<JsonDoctorScreen>
    with TickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();
  final TextEditingController _schemaController = TextEditingController();
  final TextEditingController _jsonPathController = TextEditingController();
  final TextEditingController _queryResultController = TextEditingController();

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late TabController _tabController;

  JsonDoctorStatus _status = JsonDoctorStatus.empty;
  String _errorMessage = '';
  final int _indentLevel = 2;
  List<SchemaValidationError> _schemaErrors = [];
  // ignore: unused_field
  String _jsonPathResult = '';

  @override
  void initState() {
    super.initState();
    _inputController.addListener(_validateJson);
    _tabController = TabController(length: 3, vsync: this);

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
    _outputController.dispose();
    _schemaController.dispose();
    _jsonPathController.dispose();
    _queryResultController.dispose();
    _tabController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _validateJson() {
    final input = _inputController.text.trim();

    if (input.isEmpty) {
      setState(() {
        _status = JsonDoctorStatus.empty;
        _outputController.clear();
        _errorMessage = '';
      });
      return;
    }

    try {
      final dynamic jsonData = jsonDecode(input);
      final String formatted = const JsonEncoder.withIndent(
        '  ',
      ).convert(jsonData);

      setState(() {
        _status = JsonDoctorStatus.valid;
        _outputController.text = formatted;
        _errorMessage = '';
      });

      // Pulse animation for success
      _pulseController.forward().then((_) => _pulseController.reverse());
    } catch (e) {
      setState(() {
        _status = JsonDoctorStatus.invalid;
        _outputController.text = _tryToFixJson(input);
        _errorMessage = e.toString();
      });
    }
  }

  String _tryToFixJson(String input) {
    // Common JSON fixes
    String fixed = input
        .replaceAll("'", '"') // Single quotes to double quotes
        .replaceAll('True', 'true') // Python True to JSON true
        .replaceAll('False', 'false') // Python False to JSON false
        .replaceAll('None', 'null') // Python None to JSON null
        .replaceAll(RegExp(r'(\w+):'), r'"\1":'); // Unquoted keys

    try {
      final dynamic jsonData = jsonDecode(fixed);
      return 'Auto-fixed:\n\n${const JsonEncoder.withIndent('  ').convert(jsonData)}';
    } catch (e) {
      return 'Could not auto-fix. Common issues:\n'
          '• Use double quotes for strings and keys\n'
          '• Remove trailing commas\n'
          '• Check for missing brackets/braces\n'
          '• Escape special characters';
    }
  }

  void _copyToClipboard() {
    if (_outputController.text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _outputController.text));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Copied to clipboard!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _clearAll() {
    _inputController.clear();
    _outputController.clear();
    setState(() {
      _status = JsonDoctorStatus.empty;
      _errorMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF388E3C).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.healing,
                color: Color(0xFF388E3C),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('JSON Doctor v2'),
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
          if (_outputController.text.isNotEmpty)
            ShareDataButton(
              data: _outputController.text,
              type: SharedDataType.json,
              sourceTool: 'JSON Doctor',
              compact: true,
            ),
          IconButton(
            onPressed: _clearAll,
            icon: const Icon(Icons.clear_all),
            tooltip: 'Clear All',
          ),
          IconButton(
            onPressed: _copyToClipboard,
            icon: const Icon(Icons.copy),
            tooltip: 'Copy Result',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.healing), text: 'Validate & Fix'),
            Tab(icon: Icon(Icons.schema), text: 'Schema'),
            Tab(icon: Icon(Icons.search), text: 'JSONPath'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildValidationTab(theme),
          _buildSchemaTab(theme),
          _buildJsonPathTab(theme),
        ],
      ),
    );
  }

  Widget _buildValidationTab(ThemeData theme) {
    return Column(
      children: [
        // Status indicator
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _getStatusColor(theme).withOpacity(0.1),
            border: Border(
              bottom: BorderSide(
                color: _getStatusColor(theme).withOpacity(0.3),
                width: 2,
              ),
            ),
          ),
          child: Row(
            children: [
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _status == JsonDoctorStatus.valid
                        ? _pulseAnimation.value
                        : 1.0,
                    child: Icon(
                      _getStatusIcon(),
                      color: _getStatusColor(theme),
                      size: 24,
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getStatusText(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: _getStatusColor(theme),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (_errorMessage.isNotEmpty)
                      Text(
                        _errorMessage,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Input/Output panels
        Expanded(
          child: Row(
            children: [
              // Input panel
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: theme.colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Input JSON',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
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
                                  'Paste your JSON here...\n\nTip: I can fix common issues like:\n• Single quotes\n• Unquoted keys\n• Python-style booleans',
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
              ),

              // Output panel
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Formatted Result',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          controller: _outputController,
                          maxLines: null,
                          expands: true,
                          readOnly: true,
                          textAlignVertical: TextAlignVertical.top,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 14,
                            color: _status == JsonDoctorStatus.valid
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Formatted JSON will appear here...',
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
    );
  }

  Widget _buildSchemaTab(ThemeData theme) {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              // JSON Data input
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: theme.colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'JSON Data',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
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
                                  'Enter JSON data to validate against schema...',
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
                        child: ElevatedButton(
                          onPressed: _generateSchema,
                          child: const Text('Generate Schema from Data'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Schema input
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: theme.colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'JSON Schema',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TextField(
                            controller: _schemaController,
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 14,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Enter JSON Schema...',
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
                        child: ElevatedButton(
                          onPressed: _validateWithSchema,
                          child: const Text('Validate Against Schema'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Validation results
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Validation Results',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: theme.colorScheme.outline.withOpacity(0.3),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_schemaErrors.isEmpty)
                                  Text(
                                    'No validation performed yet.',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  )
                                else if (_schemaErrors.every(
                                  (e) => e.message.isEmpty,
                                ))
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Schema validation passed!',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: Colors.green,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  )
                                else
                                  ...(_schemaErrors.map(
                                    (error) => Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.errorContainer
                                            .withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            error.path,
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: theme.colorScheme.error,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            error.message,
                                            style: theme.textTheme.bodySmall,
                                          ),
                                          Text(
                                            'Expected: ${error.expectedType}, Got: ${error.actualType}',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                              color: theme
                                                  .colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )),
                              ],
                            ),
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
    );
  }

  Widget _buildJsonPathTab(ThemeData theme) {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              // JSON Data input
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: theme.colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'JSON Data',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
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
                              hintText: 'Enter JSON data to query...',
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
              ),

              // JSONPath query and results
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'JSONPath Query',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _jsonPathController,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText:
                              r'Enter JSONPath expression (e.g., $.users[0].name)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: JsonPathQuery.getExamplePaths()
                            .map(
                              (path) => ActionChip(
                                label: Text(path),
                                onPressed: () {
                                  _jsonPathController.text = path;
                                  _executeJsonPath();
                                },
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ElevatedButton(
                        onPressed: _executeJsonPath,
                        child: const Text('Execute Query'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Query Results',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          controller: _queryResultController,
                          maxLines: null,
                          expands: true,
                          readOnly: true,
                          textAlignVertical: TextAlignVertical.top,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Query results will appear here...',
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
    );
  }

  void _generateSchema() {
    try {
      final jsonData = jsonDecode(_inputController.text);
      final schema = SchemaValidator.generateSchema(jsonData);
      _schemaController.text = const JsonEncoder.withIndent(
        '  ',
      ).convert(schema);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Invalid JSON: $e')));
    }
  }

  void _validateWithSchema() {
    try {
      final jsonData = jsonDecode(_inputController.text);
      final schema = jsonDecode(_schemaController.text) as Map<String, dynamic>;

      final result = SchemaValidator.validate(jsonData, schema);

      setState(() {
        _schemaErrors = result.errors;
      });

      if (result.isValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Schema validation passed!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _executeJsonPath() {
    try {
      final jsonData = jsonDecode(_inputController.text);
      final path = _jsonPathController.text;

      final result = JsonPathQuery.query(jsonData, path);

      if (result.success) {
        _queryResultController.text = const JsonEncoder.withIndent(
          '  ',
        ).convert(result.value);
        setState(() {
          _jsonPathResult = 'Found ${result.matches.length} match(es)';
        });
      } else {
        _queryResultController.text = 'Error: ${result.error}';
        setState(() {
          _jsonPathResult = 'Query failed';
        });
      }
    } catch (e) {
      _queryResultController.text = 'Error: $e';
      setState(() {
        _jsonPathResult = 'Invalid JSON or query';
      });
    }
  }

  IconData _getStatusIcon() {
    switch (_status) {
      case JsonDoctorStatus.empty:
        return Icons.info_outline;
      case JsonDoctorStatus.valid:
        return Icons.check_circle;
      case JsonDoctorStatus.invalid:
        return Icons.error_outline;
    }
  }

  Color _getStatusColor(ThemeData theme) {
    switch (_status) {
      case JsonDoctorStatus.empty:
        return theme.colorScheme.primary;
      case JsonDoctorStatus.valid:
        return const Color(0xFF388E3C);
      case JsonDoctorStatus.invalid:
        return theme.colorScheme.error;
    }
  }

  String _getStatusText() {
    switch (_status) {
      case JsonDoctorStatus.empty:
        return 'Ready to validate JSON';
      case JsonDoctorStatus.valid:
        return 'Valid JSON - Formatted successfully!';
      case JsonDoctorStatus.invalid:
        return 'Invalid JSON - Auto-fix attempted';
    }
  }
}

enum JsonDoctorStatus { empty, valid, invalid }
