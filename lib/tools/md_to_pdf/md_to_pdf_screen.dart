import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../billing/billing_service.dart';
import '../../billing/widgets/paywall_guard.dart';
import 'logic/pdf_exporter.dart';
import 'widgets/export_options_dialog.dart';

class MdToPdfScreen extends StatefulWidget {
  const MdToPdfScreen({super.key});

  @override
  State<MdToPdfScreen> createState() => _MdToPdfScreenState();
}

class _MdToPdfScreenState extends State<MdToPdfScreen> {
  final TextEditingController _markdownController = TextEditingController();
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final BillingService _billingService = BillingService();

  bool _isExporting = false;
  String? _downloadUrl;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _markdownController.text = '''# Markdown to PDF

Welcome to the **Markdown to PDF** converter!

## Features

- Live preview
- Multiple themes
- Customizable page settings
- Easy export

## How to use

1. Edit your markdown in the left panel
2. See live preview on the right
3. Click Export to PDF
4. Choose your options
5. Download your PDF!

### Code Example

```dart
void main() {
  print('Hello, World!');
}
```

### Lists

- Item 1
- Item 2
  - Nested item
  - Another nested item

### Quote

> This is a blockquote
>
> It can span multiple lines

**Enjoy your PDF export!**
''';
  }

  @override
  void dispose() {
    _markdownController.dispose();
    super.dispose();
  }

  Future<void> _showExportDialog() async {
    final options = await showDialog<ExportOptions>(
      context: context,
      builder: (context) => const ExportOptionsDialog(),
    );

    if (options != null && mounted) {
      await _exportToPdf(options);
    }
  }

  Future<void> _exportToPdf(ExportOptions options) async {
    setState(() {
      _isExporting = true;
      _errorMessage = null;
      _downloadUrl = null;
    });

    try {
      final result =
          await _functions.httpsCallable('generatePdfFromMarkdown').call({
        'markdown': _markdownController.text,
        'theme': options.theme,
        'pageSize': options.pageSize,
        'margins': options.margins.toMap(),
        'includePageNumbers': options.includePageNumbers,
      });

      setState(() {
        _downloadUrl = result.data['downloadUrl'] as String;
      });

      // Track heavy operation
      await _billingService.trackHeavyOp();

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to export PDF: $e';
      });
      if (mounted) {
        _showErrorSnackBar(_errorMessage!);
      }
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('PDF Ready'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your PDF has been generated successfully!'),
            SizedBox(height: 16),
            Text('The download link is valid for 7 days.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          FilledButton.icon(
            onPressed: _downloadPdf,
            icon: const Icon(Icons.download),
            label: const Text('Download'),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadPdf() async {
    if (_downloadUrl != null) {
      final uri = Uri.parse(_downloadUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          _showErrorSnackBar('Could not open download link');
        }
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Calculate file size (markdown content size in bytes)
    final markdownBytes = _markdownController.text.length;

    return PaywallGuard(
      billingService: _billingService,
      permission: ToolPermission(
        toolId: 'md_to_pdf',
        requiresHeavyOp: true,
        fileSize: markdownBytes > 0 ? markdownBytes : null,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Markdown to PDF'),
          backgroundColor: theme.colorScheme.inversePrimary,
          actions: [
            if (_isExporting)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilledButton.icon(
                  onPressed: _showExportDialog,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Export to PDF'),
                ),
              ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 800;

            if (isWide) {
              return _buildSplitPane(theme);
            } else {
              return _buildSinglePane(theme);
            }
          },
        ),
      ), // Scaffold
    ); // PaywallGuard
  }

  Widget _buildSplitPane(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: _buildEditor(theme),
        ),
        VerticalDivider(
          width: 1,
          thickness: 1,
          color: theme.colorScheme.outlineVariant,
        ),
        Expanded(
          flex: 1,
          child: _buildPreview(theme),
        ),
      ],
    );
  }

  Widget _buildSinglePane(ThemeData theme) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: const [
              Tab(icon: Icon(Icons.edit), text: 'Edit'),
              Tab(icon: Icon(Icons.preview), text: 'Preview'),
            ],
            labelColor: theme.colorScheme.primary,
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildEditor(theme),
                _buildPreview(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditor(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Markdown Editor',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TextField(
              controller: _markdownController,
              maxLines: null,
              expands: true,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Enter your markdown here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Live Preview',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant,
                ),
              ),
              child: Markdown(
                data: _markdownController.text,
                selectable: true,
                styleSheet: MarkdownStyleSheet.fromTheme(theme),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
