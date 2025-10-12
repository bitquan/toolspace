/// VATS Screen - Video → Audio → Transcript processing interface.
///
/// Allows users to:
/// - Upload video files (.mp4, .mov, .webm)
/// - Monitor processing progress
/// - View and export transcripts
/// - Manage credits usage
library;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../billing/billing_service.dart';
import '../../billing/billing_types.dart';
import '../../billing/credits_service.dart';
import '../../billing/widgets/paywall_guard.dart';
import '../../core/services/debug_logger.dart';
import '../../core/ui/neo_playground_theme.dart';
import 'vats_service.dart';

class VATSScreen extends StatefulWidget {
  const VATSScreen({super.key});

  @override
  State<VATSScreen> createState() => _VATSScreenState();
}

class _VATSScreenState extends State<VATSScreen> {
  late final VATSService _vatsService;
  late final CreditsService _creditsService;
  late final BillingService _billingService;
  
  List<VATSJob> _jobs = [];
  bool _loading = false;
  VATSJob? _selectedJob;

  @override
  void initState() {
    super.initState();
    _creditsService = CreditsService();
    _billingService = BillingService();
    _vatsService = VATSService(creditsService: _creditsService);
    _loadJobs();
    _creditsService.startListening();
  }

  @override
  void dispose() {
    _creditsService.dispose();
    _vatsService.dispose();
    super.dispose();
  }

  Future<void> _loadJobs() async {
    setState(() => _loading = true);
    try {
      final jobs = await _vatsService.getUserJobs();
      setState(() => _jobs = jobs);
    } catch (e) {
      DebugLogger.error('Failed to load jobs: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _pickAndProcessVideo() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp4', 'mov', 'webm'],
        allowMultiple: false,
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      if (file.bytes == null) {
        _showError('Failed to read file data');
        return;
      }

      // Check file size (max 100MB for demo)
      if (file.size > 100 * 1024 * 1024) {
        _showError('File too large. Maximum size is 100MB.');
        return;
      }

      // Start processing
      final jobId = await _vatsService.processVideo(
        file.bytes!,
        file.name,
      );

      if (jobId != null) {
        _showSuccess('Video processing started: ${file.name}');
        _loadJobs(); // Refresh jobs list
      } else {
        _showError('Failed to start video processing');
      }
    } catch (e) {
      DebugLogger.error('Video pick failed: $e');
      _showError('Failed to process video: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return PaywallGuard(
      permission: const ToolPermission(
        toolId: 'vats',
        requiresHeavyOp: true,
      ),
      billingService: _billingService,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('VATS - Video Transcription'),
          backgroundColor: NeoPlaygroundTheme.primaryPurple,
          foregroundColor: Colors.white,
        ),
        body: Column(
          children: [
            // Credits HUD
            StreamBuilder<CreditsBilling>(
              stream: _creditsService.creditsStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return CreditsHUD(
                    credits: snapshot.data!,
                    creditsService: _creditsService,
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            
            // Main content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Upload section
                    Container(
                      decoration: NeoPlaygroundTheme.cardDecoration(
                        baseColor: NeoPlaygroundTheme.primaryBlue,
                        borderRadius: 16,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Upload Video',
                              style: NeoPlaygroundTheme.headingSmall.copyWith(
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Upload .mp4, .mov, or .webm files to generate transcripts',
                              style: NeoPlaygroundTheme.bodyMedium.copyWith(
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _pickAndProcessVideo,
                              icon: const Icon(Icons.upload_file_rounded),
                              label: const Text('Choose Video File'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: NeoPlaygroundTheme.primaryBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Jobs section
                    Text(
                      'Processing Jobs',
                      style: NeoPlaygroundTheme.headingSmall.copyWith(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Expanded(
                      child: _loading
                          ? const Center(child: CircularProgressIndicator())
                          : _jobs.isEmpty
                              ? Center(
                                  child: Text(
                                    'No video processing jobs yet',
                                    style: NeoPlaygroundTheme.bodyMedium.copyWith(
                                      color: isDark ? Colors.white60 : Colors.black54,
                                    ),
                                  ),
                                )
                              : ListView.separated(
                                  itemCount: _jobs.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final job = _jobs[index];
                                    return JobStatusCard(
                                      job: job,
                                      onTap: () => _selectJob(job),
                                      selected: _selectedJob?.id == job.id,
                                    );
                                  },
                                ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        
        // Transcript viewer
        bottomSheet: _selectedJob != null
            ? TranscriptViewer(
                job: _selectedJob!,
                onClose: () => setState(() => _selectedJob = null),
                onExport: _exportTranscript,
              )
            : null,
      ),
    );
  }

  void _selectJob(VATSJob job) {
    setState(() => _selectedJob = job);
  }

  Future<void> _exportTranscript(VATSJob job, String format) async {
    try {
      String content;
      
      switch (format) {
        case 'srt':
          content = job.srtContent ?? 'No SRT content available';
          break;
        case 'markdown':
          content = _vatsService.exportAsMarkdown(job);
          break;
        case 'txt':
          content = job.transcriptText ?? 'No transcript available';
          break;
        default:
          throw ArgumentError('Unknown format: $format');
      }

      // Copy to clipboard for web platform
      if (kIsWeb) {
        await Clipboard.setData(ClipboardData(text: content));
        _showSuccess('$format content copied to clipboard');
      } else {
        // For mobile/desktop, you would implement file saving
        await Clipboard.setData(ClipboardData(text: content));
        _showSuccess('$format content copied to clipboard');
      }
    } catch (e) {
      DebugLogger.error('Export failed: $e');
      _showError('Failed to export: $e');
    }
  }
}
