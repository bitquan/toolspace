import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'subtitle_maker_service.dart';

class SubtitleMakerScreen extends StatefulWidget {
  const SubtitleMakerScreen({super.key});

  @override
  State<SubtitleMakerScreen> createState() => _SubtitleMakerScreenState();
}

class _SubtitleMakerScreenState extends State<SubtitleMakerScreen> {
  final SubtitleMakerService _service = SubtitleMakerService();
  final TextEditingController _transcriptController = TextEditingController();

  String? _srtContent;
  String? _vttContent;
  String _selectedFormat = 'SRT';
  String? _errorMessage;

  @override
  void dispose() {
    _transcriptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subtitle Maker'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildInputSection(theme)),
            const SizedBox(width: 24),
            Expanded(child: _buildOutputSection(theme)),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection(ThemeData theme) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme),
            const SizedBox(height: 24),
            _buildFormatSelector(theme),
            const SizedBox(height: 24),
            _buildTextInput(theme),
            const SizedBox(height: 24),
            _buildGenerateButton(theme),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              _buildErrorSection(theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Icon(
                Icons.subtitles,
                color: Colors.blue.shade600,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Subtitle Maker',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Convert text transcripts into properly formatted subtitle files',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormatSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Output Format',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildFormatChip(theme, 'SRT'),
            const SizedBox(width: 12),
            _buildFormatChip(theme, 'VTT'),
          ],
        ),
      ],
    );
  }

  Widget _buildFormatChip(ThemeData theme, String format) {
    final isSelected = _selectedFormat == format;
    return FilterChip(
      label: Text(format),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedFormat = format;
          });
        }
      },
      backgroundColor: isSelected ? Colors.blue.shade100 : null,
      selectedColor: Colors.blue.shade200,
      checkmarkColor: Colors.blue.shade800,
    );
  }

  Widget _buildTextInput(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Text Content',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 300,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _transcriptController,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            decoration: const InputDecoration(
              hintText:
                  'Paste or type your text content here...\n\nThe tool will automatically split text into subtitle segments with proper timing.',
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
            onChanged: (value) {
              setState(() {
                _srtContent = null;
                _vttContent = null;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGenerateButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _transcriptController.text.isEmpty ? null : _generateSubtitles,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade600,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text('Generate Subtitles'),
      ),
    );
  }

  Widget _buildOutputSection(ThemeData theme) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Generated Subtitles',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_getCurrentContent() != null)
                  DropdownButton<String>(
                    value: _selectedFormat,
                    items: ['SRT', 'VTT'].map((format) {
                      return DropdownMenuItem(
                        value: format,
                        child: Text(format),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedFormat = newValue;
                        });
                      }
                    },
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _getCurrentContent() != null
                  ? _buildSubtitlePreview(theme)
                  : _buildEmptyState(theme),
            ),
            if (_getCurrentContent() != null) ...[
              const SizedBox(height: 16),
              _buildActionButtons(theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSubtitlePreview(ThemeData theme) {
    final content = _getCurrentContent();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        child: Text(
          content!,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.subtitles_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No subtitles generated yet',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter text content and click "Generate Subtitles"',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _copyToClipboard,
            icon: const Icon(Icons.copy),
            label: const Text('Copy'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _downloadSubtitles,
            icon: const Icon(Icons.download),
            label: Text('Download $_selectedFormat'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _errorMessage = null;
              });
            },
            icon: Icon(Icons.close, color: Colors.red.shade600),
            iconSize: 20,
          ),
        ],
      ),
    );
  }

  String? _getCurrentContent() {
    switch (_selectedFormat) {
      case 'SRT':
        return _srtContent;
      case 'VTT':
        return _vttContent;
      default:
        return _srtContent;
    }
  }

  void _generateSubtitles() async {
    final transcript = _transcriptController.text.trim();

    try {
      final result = _service.generateSubtitles(transcript);
      setState(() {
        _srtContent = result.srtContent;
        _vttContent = result.vttContent;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to generate subtitles: $e';
      });
    }
  }

  void _downloadSubtitles() async {
    final content = _getCurrentContent();
    if (content == null) return;

    try {
      // For web, we'll copy to clipboard as download isn't easily available
      await Clipboard.setData(ClipboardData(text: content));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$_selectedFormat content copied to clipboard'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to download subtitles: $e';
      });
    }
  }

  void _copyToClipboard() async {
    final content = _getCurrentContent();
    if (content == null) return;

    try {
      await Clipboard.setData(ClipboardData(text: content));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$_selectedFormat content copied to clipboard'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to copy to clipboard: $e';
      });
    }
  }
}
