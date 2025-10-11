import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class VideoConverterScreen extends StatefulWidget {
  const VideoConverterScreen({super.key});

  @override
  State<VideoConverterScreen> createState() => _VideoConverterScreenState();
}

class _VideoConverterScreenState extends State<VideoConverterScreen> {
  bool _isProcessing = false;
  double _progress = 0.0;
  String? _selectedFileName;
  Uint8List? _selectedFileBytes;
  bool _conversionComplete = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Converter'),
        backgroundColor: Colors.purple.shade600,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.video_file,
                      size: 64,
                      color: Colors.purple.shade600,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Video to Audio Converter',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Convert video files to high-quality audio formats',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    if (_selectedFileName == null) ...[
                      _buildUploadArea(),
                    ] else ...[
                      _buildSelectedFile(),
                    ],
                    if (_isProcessing) ...[
                      const SizedBox(height: 24),
                      _buildProgress(),
                    ],
                    if (_conversionComplete) ...[
                      const SizedBox(height: 24),
                      _buildSuccess(),
                    ],
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 24),
                      _buildError(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUploadArea() {
    return InkWell(
      onTap: _pickFile,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300, width: 2, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade50,
        ),
        child: Column(
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              size: 48,
              color: Colors.purple.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'Click to select video file',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Supports MP4, MOV, WEBM, AVI (Max 100MB)',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedFile() {
    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.video_file, color: Colors.purple.shade600),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedFileName!,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  if (_selectedFileBytes != null)
                    Text(
                      'Size: ${(_selectedFileBytes!.length / (1024 * 1024)).toStringAsFixed(1)} MB',
                      style: const TextStyle(color: Colors.grey),
                    ),
                ],
              ),
            ),
            if (!_isProcessing)
              IconButton(
                onPressed: _clearSelection,
                icon: const Icon(Icons.close),
              ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isProcessing ? null : _convertVideo,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(_isProcessing ? 'Converting...' : 'Convert to Audio'),
          ),
        ),
      ],
    );
  }

  Widget _buildProgress() {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                value: _progress,
                strokeWidth: 2,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.purple.shade600),
              ),
            ),
            const SizedBox(width: 12),
            Text('Converting... ${(_progress * 100).toInt()}%'),
          ],
        ),
        const SizedBox(height: 16),
        LinearProgressIndicator(
          value: _progress,
          backgroundColor: Colors.grey.shade300,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.purple.shade600),
        ),
      ],
    );
  }

  Widget _buildSuccess() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green.shade600),
              const SizedBox(width: 12),
              const Text(
                'Conversion Complete!',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.audiotrack, color: Colors.green.shade600),
              const SizedBox(width: 8),
              const Text('Audio file ready'),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Audio file downloaded!')),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade600),
                child: const Text('Download'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600),
          const SizedBox(width: 12),
          Expanded(child: Text(_errorMessage!)),
          TextButton(
            onPressed: () => setState(() => _errorMessage = null),
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp4', 'mov', 'webm', 'avi'],
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        if (file.size > 100 * 1024 * 1024) {
          setState(() => _errorMessage = 'File size exceeds 100MB limit');
          return;
        }

        setState(() {
          _selectedFileName = file.name;
          _selectedFileBytes = file.bytes;
          _errorMessage = null;
          _conversionComplete = false;
        });
      }
    } catch (e) {
      setState(() => _errorMessage = 'Failed to select file: $e');
    }
  }

  void _clearSelection() {
    setState(() {
      _selectedFileName = null;
      _selectedFileBytes = null;
      _conversionComplete = false;
      _progress = 0.0;
      _errorMessage = null;
    });
  }

  Future<void> _convertVideo() async {
    if (_selectedFileBytes == null) return;

    setState(() {
      _isProcessing = true;
      _progress = 0.0;
      _errorMessage = null;
    });

    try {
      // Simulate conversion progress
      for (int i = 0; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 200));
        setState(() => _progress = i / 100);
      }

      setState(() {
        _isProcessing = false;
        _conversionComplete = true;
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _errorMessage = e.toString();
      });
    }
  }
}
