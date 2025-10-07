import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:file_picker/file_picker.dart';

import 'logic/upload_manager.dart';
import 'widgets/file_upload_zone.dart';
import 'widgets/file_list.dart';
import 'widgets/quota_banner.dart';
import 'widgets/merge_progress.dart';
import '../../billing/billing_service.dart';
import '../../billing/widgets/paywall_guard.dart';

/// Main screen for the File Merger tool
class FileMergerScreen extends StatefulWidget {
  const FileMergerScreen({super.key});

  @override
  State<FileMergerScreen> createState() => _FileMergerScreenState();
}

class _FileMergerScreenState extends State<FileMergerScreen> {
  final UploadManager _uploadManager = UploadManager();
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final BillingService _billingService = BillingService();

  final List<FileUpload> _files = [];
  bool _isUploading = false;
  bool _isMerging = false;
  String? _downloadUrl;
  QuotaStatus? _quotaStatus;

  @override
  void initState() {
    super.initState();
    _loadQuotaStatus();
  }

  Future<void> _loadQuotaStatus() async {
    try {
      final result = await _functions.httpsCallable('getQuotaStatus').call();
      setState(() {
        _quotaStatus = QuotaStatus.fromMap(result.data);
      });
    } catch (e) {
      print('Failed to load quota status: $e');
    }
  }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
        withData: true,
      );

      if (result != null) {
        final newFiles = result.files
            .where((file) => file.bytes != null)
            .map((file) => FileUpload.fromBytes(
                  bytes: file.bytes!,
                  name: file.name,
                  contentType: FileUpload.inferContentType(file.name),
                ))
            .where((file) => file.isValid)
            .toList();

        setState(() {
          _files.addAll(newFiles);
        });

        // Show error for invalid files
        final invalidCount = result.files.length - newFiles.length;
        if (invalidCount > 0) {
          _showErrorSnackBar(
            '$invalidCount file(s) were invalid or too large (max 10MB)',
          );
        }
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick files: $e');
    }
  }

  void _removeFile(int index) {
    setState(() {
      _files.removeAt(index);
    });
  }

  void _reorderFiles(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _files.removeAt(oldIndex);
      _files.insert(newIndex, item);
    });
  }

  Future<void> _mergeFiles() async {
    if (_files.isEmpty) {
      _showErrorSnackBar('Please add files to merge');
      return;
    }

    if (FirebaseAuth.instance.currentUser == null) {
      _showErrorSnackBar('Please sign in to merge files');
      return;
    }

    // Check quota
    if (_quotaStatus != null &&
        !_quotaStatus!.isPro &&
        _quotaStatus!.mergesRemaining <= 0) {
      _showErrorSnackBar('Free quota exceeded. Please upgrade to Pro.');
      return;
    }

    setState(() {
      _isUploading = true;
      _downloadUrl = null;
    });

    try {
      // Upload files
      final filePaths = await _uploadManager.uploadMultipleFiles(_files);

      setState(() {
        _isUploading = false;
        _isMerging = true;
      });

      // Merge files
      final result = await _functions.httpsCallable('mergePdfs').call({
        'files': filePaths,
      });

      setState(() {
        _isMerging = false;
        _downloadUrl = result.data['downloadUrl'];
      });

      // Track heavy operation
      await _billingService.trackHeavyOp();

      // Refresh quota status
      await _loadQuotaStatus();

      _showSuccessSnackBar('Files merged successfully!');
    } catch (e) {
      setState(() {
        _isUploading = false;
        _isMerging = false;
      });
      _showErrorSnackBar('Failed to merge files: $e');
    }
  }

  void _copyLink() {
    if (_downloadUrl != null) {
      Clipboard.setData(ClipboardData(text: _downloadUrl!));
      _showSuccessSnackBar('Download link copied to clipboard');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PaywallGuard(
      billingService: _billingService,
      permission: const ToolPermission(
        toolId: 'file_merger',
        requiresHeavyOp: true,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('File Merger'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Column(
          children: [
            // Quota banner
            if (_quotaStatus != null &&
                !_quotaStatus!.isPro &&
                _quotaStatus!.mergesRemaining <= 0)
              QuotaBanner(quotaStatus: _quotaStatus!),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Upload zone
                    FileUploadZone(
                      onFilesSelected: _pickFiles,
                      isEnabled: !_isUploading && !_isMerging,
                    ),

                    const SizedBox(height: 16),

                    // File list
                    if (_files.isNotEmpty) ...[
                      Text(
                        'Files to Merge (${_files.length})',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: FileList(
                          files: _files,
                          onRemove: _removeFile,
                          onReorder: _reorderFiles,
                          isEnabled: !_isUploading && !_isMerging,
                        ),
                      ),
                    ] else ...[
                      const Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.file_copy_outlined,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No files selected',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Tap the upload zone above to add PDF or image files',
                                style: TextStyle(color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Progress indicator
                    if (_isUploading || _isMerging)
                      MergeProgress(
                        isUploading: _isUploading,
                        isMerging: _isMerging,
                      ),

                    // Download section
                    if (_downloadUrl != null) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green),
                                SizedBox(width: 8),
                                Text(
                                  'Merge Complete',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _launchUrl(_downloadUrl!),
                                    icon: const Icon(Icons.download),
                                    label: const Text('Download PDF'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: _copyLink,
                                  icon: const Icon(Icons.copy),
                                  label: const Text('Copy Link'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey.shade100,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Merge button
                    ElevatedButton(
                      onPressed:
                          _files.isNotEmpty && !_isUploading && !_isMerging
                              ? _mergeFiles
                              : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        _isUploading
                            ? 'Uploading...'
                            : _isMerging
                                ? 'Merging...'
                                : 'Merge Files',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),

                    // Quota status
                    if (_quotaStatus != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _quotaStatus!.isPro
                            ? 'Pro account: Unlimited merges'
                            : 'Free: ${_quotaStatus!.mergesRemaining} merges remaining',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ), // Scaffold
    ); // PaywallGuard
  }

  void _launchUrl(String url) async {
    // For web, we can use html.window.open
    // For mobile, use url_launcher package
    // This is a placeholder implementation
    print('Would open URL: $url');
    _showSuccessSnackBar('Download started');
  }
}

/// Quota status model
class QuotaStatus {
  final int mergesUsed;
  final int mergesRemaining;
  final bool isPro;

  const QuotaStatus({
    required this.mergesUsed,
    required this.mergesRemaining,
    required this.isPro,
  });

  factory QuotaStatus.fromMap(Map<String, dynamic> map) {
    return QuotaStatus(
      mergesUsed: map['mergesUsed'] ?? 0,
      mergesRemaining: map['mergesRemaining'] ?? 0,
      isPro: map['isPro'] ?? false,
    );
  }
}
