import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AudioTranscriberScreen extends StatefulWidget {
  const AudioTranscriberScreen({super.key});

  @override
  State<AudioTranscriberScreen> createState() => _AudioTranscriberScreenState();
}

class _AudioTranscriberScreenState extends State<AudioTranscriberScreen> {
  bool _isProcessing = false;
  double _progress = 0.0;
  String? _selectedFileName;
  Uint8List? _selectedFileBytes;
  String? _transcriptText;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Transcriber'),
        backgroundColor: Colors.orange.shade600,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildInputSection()),
            const SizedBox(width: 24),
            Expanded(child: _buildOutputSection()),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.mic, color: Colors.orange.shade600),
                const SizedBox(width: 8),
                const Text(
                  'Audio Input',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_selectedFileName == null) ...[
              _buildUploadArea(),
            ] else ...[
              _buildSelectedFile(),
            ],
            if (_isProcessing) ...[
              const SizedBox(height: 24),
              _buildProgress(),
            ],
            if (_errorMessage != null) ...[
              const SizedBox(height: 24),
              _buildError(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOutputSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.text_fields, color: Colors.orange.shade600),
                const SizedBox(width: 8),
                const Text(
                  'Transcript Output',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              height: 400,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: _transcriptText != null
                  ? SingleChildScrollView(
                      child: Text(
                        _transcriptText!,
                        style: const TextStyle(height: 1.5),
                      ),
                    )
                  : const Center(
                      child: Text(
                        'Transcript will appear here after processing',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _transcriptText != null ? _copyToClipboard : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade600,
                    ),
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Copy Transcript'),
                  ),
                ),
              ],
            ),
          ],
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
              Icons.audiotrack,
              size: 48,
              color: Colors.orange.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'Click to select audio file',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Supports MP3, WAV, M4A, OGG (Max 50MB)',
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
            Icon(Icons.audiotrack, color: Colors.orange.shade600),
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
            onPressed: _isProcessing ? null : _transcribeAudio,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(_isProcessing ? 'Transcribing...' : 'Transcribe Audio'),
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
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange.shade600),
              ),
            ),
            const SizedBox(width: 12),
            Text('Transcribing... ${(_progress * 100).toInt()}%'),
          ],
        ),
        const SizedBox(height: 16),
        LinearProgressIndicator(
          value: _progress,
          backgroundColor: Colors.grey.shade300,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.orange.shade600),
        ),
      ],
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
        allowedExtensions: ['mp3', 'wav', 'm4a', 'ogg'],
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        if (file.size > 50 * 1024 * 1024) {
          setState(() => _errorMessage = 'File size exceeds 50MB limit');
          return;
        }

        setState(() {
          _selectedFileName = file.name;
          _selectedFileBytes = file.bytes;
          _errorMessage = null;
          _transcriptText = null;
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
      _transcriptText = null;
      _progress = 0.0;
      _errorMessage = null;
    });
  }

  Future<void> _transcribeAudio() async {
    if (_selectedFileBytes == null) return;

    setState(() {
      _isProcessing = true;
      _progress = 0.0;
      _errorMessage = null;
    });

    try {
      // Simulate transcription progress
      for (int i = 0; i <= 100; i += 5) {
        await Future.delayed(const Duration(milliseconds: 100));
        setState(() => _progress = i / 100);
      }

      // Mock transcript
      const mockTranscript =
          '''Welcome to our audio transcription service. This is a demonstration of how speech recognition technology works. The system processes your audio file and converts spoken words into accurate text.

Our AI-powered transcription service supports multiple languages and accents. You can use this transcript for meeting notes, interviews, lectures, or any other audio content.

The accuracy of transcription depends on audio quality, speaker clarity, and background noise levels. For best results, ensure your audio is recorded in a quiet environment with clear speech.

This technology uses advanced machine learning models to understand natural language patterns. The transcription includes proper punctuation and formatting for readability.

Thank you for using our audio transcription tool.''';

      setState(() {
        _isProcessing = false;
        _transcriptText = mockTranscript;
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _copyToClipboard() async {
    if (_transcriptText == null) return;

    try {
      await Clipboard.setData(ClipboardData(text: _transcriptText!));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transcript copied to clipboard'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _errorMessage = 'Failed to copy to clipboard: $e');
    }
  }
}
