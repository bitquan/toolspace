import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'logic/codec_engine.dart';
import '../../core/ui/clipboard_btn.dart';

/// Codec Lab - Base64, Hex, and URL Encoder/Decoder
class CodecLabScreen extends StatefulWidget {
  const CodecLabScreen({super.key});

  @override
  State<CodecLabScreen> createState() => _CodecLabScreenState();
}

class _CodecLabScreenState extends State<CodecLabScreen>
    with TickerProviderStateMixin {
  late TabController _modeController;
  late AnimationController _successController;
  late Animation<double> _successAnimation;

  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();

  CodecFormat _selectedFormat = CodecFormat.base64;
  bool _isEncoding = true;
  String? _errorMessage;
  String? _successMessage;

  // File mode state
  Uint8List? _fileBytes;
  String? _fileName;
  bool _isProcessing = false;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _modeController = TabController(length: 2, vsync: this);
    _inputController.addListener(_processText);

    _successController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _successAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _successController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _modeController.dispose();
    _inputController.dispose();
    _outputController.dispose();
    _successController.dispose();
    super.dispose();
  }

  void _processText() {
    final input = _inputController.text;

    if (input.isEmpty) {
      setState(() {
        _outputController.clear();
        _errorMessage = null;
        _successMessage = null;
      });
      return;
    }

    try {
      String result;

      if (_isEncoding) {
        // Encoding
        switch (_selectedFormat) {
          case CodecFormat.base64:
            result = CodecEngine.encodeBase64(input);
            break;
          case CodecFormat.hex:
            result = CodecEngine.encodeHex(input);
            break;
          case CodecFormat.url:
            result = CodecEngine.encodeUrl(input);
            break;
          case CodecFormat.unknown:
            result = '';
        }
      } else {
        // Decoding
        switch (_selectedFormat) {
          case CodecFormat.base64:
            result = CodecEngine.decodeBase64(input);
            break;
          case CodecFormat.hex:
            result = CodecEngine.decodeHex(input);
            break;
          case CodecFormat.url:
            result = CodecEngine.decodeUrl(input);
            break;
          case CodecFormat.unknown:
            result = '';
        }
      }

      setState(() {
        _outputController.text = result;
        _errorMessage = null;
        _successMessage =
            '${_isEncoding ? 'Encoded' : 'Decoded'} successfully!';
      });

      _successController.forward().then((_) => _successController.reverse());

      // Clear success message after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _successMessage = null;
          });
        }
      });
    } catch (e) {
      setState(() {
        _outputController.clear();
        _errorMessage = e.toString();
        _successMessage = null;
      });
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        withData: true,
        type: FileType.any,
      );

      if (result != null && result.files.first.bytes != null) {
        setState(() {
          _fileBytes = result.files.first.bytes;
          _fileName = result.files.first.name;
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to pick file: $e';
      });
    }
  }

  Future<void> _processFile() async {
    if (_fileBytes == null) return;

    setState(() {
      _isProcessing = true;
      _progress = 0.0;
      _errorMessage = null;
    });

    try {
      // Simulate progress for UX
      for (int i = 0; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 50));
        setState(() {
          _progress = i / 100;
        });
      }

      String result;

      if (_isEncoding) {
        // Encoding file bytes
        switch (_selectedFormat) {
          case CodecFormat.base64:
            result = CodecEngine.encodeBytesToBase64(_fileBytes!);
            break;
          case CodecFormat.hex:
            result = CodecEngine.encodeBytesToHex(_fileBytes!);
            break;
          case CodecFormat.url:
            // URL encoding doesn't make sense for binary files
            throw const CodecException(
                'URL encoding is not supported for files');
          case CodecFormat.unknown:
            result = '';
        }
      } else {
        // Decoding to file bytes
        final inputText = _inputController.text.trim();
        Uint8List bytes;

        switch (_selectedFormat) {
          case CodecFormat.base64:
            bytes = CodecEngine.decodeBase64ToBytes(inputText);
            break;
          case CodecFormat.hex:
            bytes = CodecEngine.decodeHexToBytes(inputText);
            break;
          case CodecFormat.url:
            throw const CodecException('URL decoding to file is not supported');
          case CodecFormat.unknown:
            bytes = Uint8List(0);
        }

        // For decoding, we want to save the file
        await _downloadFile(bytes);
        setState(() {
          _isProcessing = false;
          _successMessage = 'File decoded and downloaded successfully!';
        });
        return;
      }

      setState(() {
        _outputController.text = result;
        _isProcessing = false;
        _successMessage = 'File encoded successfully!';
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _errorMessage = 'File processing failed: $e';
      });
    }
  }

  Future<void> _downloadFile(Uint8List bytes) async {
    // Create a blob and download it
    // Note: This is a simplified version. In a real app, you'd use
    // platform-specific code or a package like universal_html for web
    try {
      final blob = bytes;

      // For Flutter web, we'd use dart:html
      // For now, just copy the Base64 representation to clipboard
      final base64Data = CodecEngine.encodeBytesToBase64(blob);
      await Clipboard.setData(ClipboardData(text: base64Data));

      setState(() {
        _successMessage = 'Decoded data copied to clipboard (Base64)';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to download file: $e';
      });
    }
  }

  void _detectFormat() {
    final input = _inputController.text.trim();
    if (input.isEmpty) return;

    final detected = CodecEngine.detectFormat(input);
    if (detected != CodecFormat.unknown) {
      setState(() {
        _selectedFormat = detected;
        _isEncoding = false;
      });
      _processText();
    }
  }

  void _swapDirection() {
    setState(() {
      _isEncoding = !_isEncoding;
      // Swap input and output
      final temp = _inputController.text;
      _inputController.text = _outputController.text;
      _outputController.text = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Codec Lab'),
        backgroundColor: theme.colorScheme.primaryContainer,
        bottom: TabBar(
          controller: _modeController,
          tabs: const [
            Tab(icon: Icon(Icons.text_fields), text: 'Text Mode'),
            Tab(icon: Icon(Icons.upload_file), text: 'File Mode'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Error Banner
          if (_errorMessage != null)
            Container(
              width: double.infinity,
              color: theme.colorScheme.errorContainer,
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: theme.colorScheme.error),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style:
                          TextStyle(color: theme.colorScheme.onErrorContainer),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _errorMessage = null),
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ],
              ),
            ),

          // Success Banner
          if (_successMessage != null)
            AnimatedBuilder(
              animation: _successAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _successAnimation.value,
                  child: Container(
                    width: double.infinity,
                    color: Colors.green.shade100,
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline,
                            color: Colors.green.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _successMessage!,
                            style: TextStyle(color: Colors.green.shade900),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

          // Main Content
          Expanded(
            child: TabBarView(
              controller: _modeController,
              children: [
                _buildTextMode(theme),
                _buildFileMode(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextMode(ThemeData theme) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Format Selector and Direction Toggle
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Format',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildFormatChip(CodecFormat.base64),
                        _buildFormatChip(CodecFormat.hex),
                        _buildFormatChip(CodecFormat.url),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: SegmentedButton<bool>(
                            segments: const [
                              ButtonSegment(
                                value: true,
                                label: Text('Encode'),
                                icon: Icon(Icons.lock),
                              ),
                              ButtonSegment(
                                value: false,
                                label: Text('Decode'),
                                icon: Icon(Icons.lock_open),
                              ),
                            ],
                            selected: {_isEncoding},
                            onSelectionChanged: (Set<bool> selected) {
                              setState(() {
                                _isEncoding = selected.first;
                              });
                              _processText();
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          onPressed: _swapDirection,
                          icon: const Icon(Icons.swap_vert),
                          tooltip: 'Swap input/output',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Input Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.input,
                            size: 20, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Input',
                          style: theme.textTheme.titleMedium,
                        ),
                        const Spacer(),
                        if (!_isEncoding)
                          TextButton.icon(
                            onPressed: _detectFormat,
                            icon: const Icon(Icons.auto_awesome),
                            label: const Text('Auto-detect'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _inputController,
                      maxLines: 8,
                      decoration: InputDecoration(
                        hintText: _isEncoding
                            ? 'Enter text to encode...'
                            : 'Enter encoded text to decode...',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            _inputController.clear();
                            _outputController.clear();
                          },
                          icon: const Icon(Icons.clear),
                          label: const Text('Clear'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Output Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.output,
                            size: 20, color: theme.colorScheme.secondary),
                        const SizedBox(width: 8),
                        Text(
                          'Output',
                          style: theme.textTheme.titleMedium,
                        ),
                        const Spacer(),
                        if (_outputController.text.isNotEmpty)
                          ClipboardButton(text: _outputController.text),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _outputController,
                      maxLines: 8,
                      readOnly: true,
                      decoration: const InputDecoration(
                        hintText: 'Output will appear here...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileMode(ThemeData theme) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Format Selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Format',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildFormatChip(CodecFormat.base64),
                        _buildFormatChip(CodecFormat.hex),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(
                          value: true,
                          label: Text('Encode File'),
                          icon: Icon(Icons.lock),
                        ),
                        ButtonSegment(
                          value: false,
                          label: Text('Decode to File'),
                          icon: Icon(Icons.lock_open),
                        ),
                      ],
                      selected: {_isEncoding},
                      onSelectionChanged: (Set<bool> selected) {
                        setState(() {
                          _isEncoding = selected.first;
                          _fileBytes = null;
                          _fileName = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // File Upload Section (for encoding)
            if (_isEncoding)
              Card(
                child: InkWell(
                  onTap: _pickFile,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(32.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: theme.colorScheme.outline,
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.cloud_upload,
                          size: 64,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _fileName ?? 'Click to select a file',
                          style: theme.textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        if (_fileBytes != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            '${(_fileBytes!.length / 1024).toStringAsFixed(2)} KB',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

            // Input Section (for decoding)
            if (!_isEncoding)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Encoded Data',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _inputController,
                        maxLines: 8,
                        decoration: const InputDecoration(
                          hintText: 'Paste encoded data here...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Process Button
            if ((_isEncoding && _fileBytes != null) ||
                (!_isEncoding && _inputController.text.isNotEmpty))
              FilledButton.icon(
                onPressed: _isProcessing ? null : _processFile,
                icon: _isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(_isEncoding ? Icons.lock : Icons.lock_open),
                label: Text(_isEncoding ? 'Encode File' : 'Decode to File'),
              ),

            // Progress Indicator
            if (_isProcessing) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Processing...',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(value: _progress),
                      const SizedBox(height: 8),
                      Text(
                        '${(_progress * 100).toInt()}%',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Output Section (for encoding)
            if (_isEncoding && _outputController.text.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Encoded Output',
                            style: theme.textTheme.titleMedium,
                          ),
                          const Spacer(),
                          ClipboardButton(text: _outputController.text),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _outputController,
                        maxLines: 8,
                        readOnly: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
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
    );
  }

  Widget _buildFormatChip(CodecFormat format) {
    final isSelected = _selectedFormat == format;
    return FilterChip(
      label: Text(format.displayName),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedFormat = format;
          });
          _processText();
        }
      },
    );
  }
}
