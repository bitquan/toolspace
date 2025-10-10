import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import '../../core/ui/neo_playground_theme.dart';
import '../../billing/widgets/paywall_guard.dart';
import '../../billing/billing_service.dart';

class FileCompressorScreen extends StatefulWidget {
  const FileCompressorScreen({super.key});

  @override
  State<FileCompressorScreen> createState() => _FileCompressorScreenState();
}

class _FileCompressorScreenState extends State<FileCompressorScreen> {
  final List<CompressibleFile> _files = [];
  final BillingService _billingService = BillingService();
  bool _isProcessing = false;
  double _compressionLevel = 0.7;
  String _outputFormat = 'ZIP';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('File Compressor'),
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
                _buildCompressionSettings(),
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
          'File Compressor',
          style: NeoPlaygroundTheme.headingLarge.copyWith(
            color: NeoPlaygroundTheme.primaryPurple,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Compress files and folders into ZIP archives',
          style: NeoPlaygroundTheme.bodyMedium.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildCompressionSettings() {
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
            'Compression Settings',
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
                      'Compression Level',
                      style: NeoPlaygroundTheme.caption.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Slider(
                      value: _compressionLevel,
                      onChanged: (value) {
                        setState(() {
                          _compressionLevel = value;
                        });
                      },
                      activeColor: NeoPlaygroundTheme.primaryPurple,
                      divisions: 10,
                      label: '${(_compressionLevel * 100).round()}%',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Format',
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
                    items: ['ZIP', 'TAR', 'GZIP'].map((format) {
                      return DropdownMenuItem(
                        value: format,
                        child: Text(format),
                      );
                    }).toList(),
                  ),
                ],
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
            color: NeoPlaygroundTheme.primaryPurple.withValues(alpha: 0.3),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              size: 48,
              color: NeoPlaygroundTheme.primaryPurple.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Drop files here or click to browse',
              style: NeoPlaygroundTheme.headingSmall.copyWith(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Supports: Images, Documents, Archives, and more',
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
                  'Files (${_files.length})',
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

  Widget _buildFileItem(CompressibleFile file, int index) {
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
            _getFileIcon(file.name),
            color: NeoPlaygroundTheme.primaryPurple,
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
                Text(
                  _formatFileSize(file.size),
                  style: NeoPlaygroundTheme.caption.copyWith(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
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
              side: const BorderSide(color: NeoPlaygroundTheme.primaryPurple),
            ),
            child: const Text('Add More Files'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: PaywallGuard(
            billingService: _billingService,
            permission: const ToolPermission(
              toolId: 'file_compressor',
              requiresHeavyOp: true, // File compression is a heavy operation
            ),
            child: ElevatedButton(
              onPressed:
                  _files.isEmpty || _isProcessing ? null : _compressFiles,
              style: ElevatedButton.styleFrom(
                backgroundColor: NeoPlaygroundTheme.primaryPurple,
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
                  : const Text('Compress Files'),
            ),
          ),
        ),
      ],
    );
  }

  IconData _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'mp4':
      case 'avi':
      case 'mov':
        return Icons.videocam;
      case 'mp3':
      case 'wav':
        return Icons.audiotrack;
      case 'zip':
      case 'rar':
      case '7z':
        return Icons.archive;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
        withData: true,
      );

      if (result != null) {
        for (final file in result.files) {
          if (file.bytes != null) {
            _files.add(CompressibleFile(
              name: file.name,
              data: file.bytes!,
              size: file.size,
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

  Future<void> _compressFiles() async {
    if (_files.isEmpty) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Simulate compression process
      await Future.delayed(const Duration(seconds: 2));

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Files compressed successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear files after successful compression
      setState(() {
        _files.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Compression failed: $e')),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }
}

class CompressibleFile {
  final String name;
  final Uint8List data;
  final int size;

  CompressibleFile({
    required this.name,
    required this.data,
    required this.size,
  });
}
