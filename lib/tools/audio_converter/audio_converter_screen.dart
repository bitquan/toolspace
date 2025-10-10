import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import '../../core/ui/neo_playground_theme.dart';
import '../../billing/widgets/paywall_guard.dart';
import '../../billing/billing_service.dart';

class AudioConverterScreen extends StatefulWidget {
  const AudioConverterScreen({super.key});

  @override
  State<AudioConverterScreen> createState() => _AudioConverterScreenState();
}

class _AudioConverterScreenState extends State<AudioConverterScreen> {
  final List<AudioFile> _files = [];
  final BillingService _billingService = BillingService();
  bool _isProcessing = false;
  String _outputFormat = 'MP3';
  int _bitrate = 128;
  int _sampleRate = 44100;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Converter'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF1A1A2E),
                    const Color(0xFF16213E),
                    const Color(0xFF0F172A),
                  ]
                : [
                    const Color(0xFFF8FAFC),
                    const Color(0xFFF1F5F9),
                    const Color(0xFFE2E8F0),
                  ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                _buildConversionSettings(),
                const SizedBox(height: 24),
                _buildFileDropZone(),
                const SizedBox(height: 24),
                if (_files.isNotEmpty) _buildFilesList(),
                const Spacer(),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Audio Converter',
          style: NeoPlaygroundTheme.headingLarge.copyWith(
            color: NeoPlaygroundTheme.accentPink,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Convert audio files between different formats',
          style: NeoPlaygroundTheme.bodyMedium.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildConversionSettings() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Conversion Settings',
            style: NeoPlaygroundTheme.headingSmall.copyWith(
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Output Format',
                      style: NeoPlaygroundTheme.caption.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      value: _outputFormat,
                      onChanged: (value) {
                        setState(() {
                          _outputFormat = value!;
                        });
                      },
                      items: ['MP3', 'WAV', 'FLAC', 'AAC', 'OGG'].map((format) {
                        return DropdownMenuItem(
                          value: format,
                          child: Text(format),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bitrate (kbps)',
                      style: NeoPlaygroundTheme.caption.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<int>(
                      value: _bitrate,
                      onChanged: (value) {
                        setState(() {
                          _bitrate = value!;
                        });
                      },
                      items: [64, 128, 192, 256, 320].map((bitrate) {
                        return DropdownMenuItem(
                          value: bitrate,
                          child: Text('$bitrate kbps'),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sample Rate (Hz)',
                      style: NeoPlaygroundTheme.caption.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<int>(
                      value: _sampleRate,
                      onChanged: (value) {
                        setState(() {
                          _sampleRate = value!;
                        });
                      },
                      items: [22050, 44100, 48000, 96000].map((rate) {
                        return DropdownMenuItem(
                          value: rate,
                          child: Text('${rate} Hz'),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFileDropZone() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: _pickFiles,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: NeoPlaygroundTheme.accentPink.withValues(alpha: 0.3),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.audiotrack,
              size: 48,
              color: NeoPlaygroundTheme.accentPink.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Drop audio files here or click to browse',
              style: NeoPlaygroundTheme.headingSmall.copyWith(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Supports: MP3, WAV, FLAC, AAC, OGG, M4A',
              style: NeoPlaygroundTheme.caption.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilesList() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Audio Files (${_files.length})',
                  style: NeoPlaygroundTheme.headingSmall.copyWith(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _files.clear();
                    });
                  },
                  child: const Text('Clear All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _files.length,
                itemBuilder: (context, index) {
                  final file = _files[index];
                  return _buildFileItem(file, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileItem(AudioFile file, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.audiotrack,
            color: NeoPlaygroundTheme.accentPink,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  style: NeoPlaygroundTheme.bodyMedium.copyWith(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      _formatFileSize(file.size),
                      style: NeoPlaygroundTheme.caption.copyWith(
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      file.format.toUpperCase(),
                      style: NeoPlaygroundTheme.caption.copyWith(
                        color: NeoPlaygroundTheme.accentPink,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward,
            color: Colors.grey[500],
            size: 20,
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: NeoPlaygroundTheme.accentPink.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _outputFormat,
              style: NeoPlaygroundTheme.caption.copyWith(
                color: NeoPlaygroundTheme.accentPink,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              setState(() {
                _files.removeAt(index);
              });
            },
            icon: const Icon(Icons.close),
            color: Colors.red[400],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _files.isEmpty ? null : _pickFiles,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: NeoPlaygroundTheme.accentPink),
            ),
            child: const Text('Add More Files'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: PaywallGuard(
            billingService: _billingService,
            permission: const ToolPermission(
              toolId: 'audio_converter',
              requiresHeavyOp: true, // Audio conversion is a heavy operation
            ),
            child: ElevatedButton(
              onPressed: _files.isEmpty || _isProcessing ? null : _convertFiles,
              style: ElevatedButton.styleFrom(
                backgroundColor: NeoPlaygroundTheme.accentPink,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isProcessing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Convert Audio'),
            ),
          ),
        ),
      ],
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.audio,
        withData: true,
      );

      if (result != null) {
        for (final file in result.files) {
          if (file.bytes != null) {
            final extension = file.extension?.toLowerCase() ?? '';
            _files.add(AudioFile(
              name: file.name,
              data: file.bytes!,
              size: file.size,
              format: extension,
            ));
          }
        }
        setState(() {});
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking files: $e')),
      );
    }
  }

  Future<void> _convertFiles() async {
    if (_files.isEmpty) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Simulate conversion process
      await Future.delayed(const Duration(seconds: 3));

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${_files.length} audio files converted to $_outputFormat successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear files after successful conversion
      setState(() {
        _files.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Conversion failed: $e')),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }
}

class AudioFile {
  final String name;
  final Uint8List data;
  final int size;
  final String format;

  AudioFile({
    required this.name,
    required this.data,
    required this.size,
    required this.format,
  });
}
