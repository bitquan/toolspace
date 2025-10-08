import 'package:cloud_functions/cloud_functions.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../billing/billing_service.dart';
import '../../billing/widgets/paywall_guard.dart';
import 'logic/upload_manager.dart';
import 'widgets/image_list.dart';
import 'widgets/image_upload_zone.dart';
import 'widgets/resize_progress.dart';

/// Main screen for the Image Resizer tool
class ImageResizerScreen extends StatefulWidget {
  const ImageResizerScreen({super.key});

  @override
  State<ImageResizerScreen> createState() => _ImageResizerScreenState();
}

class _ImageResizerScreenState extends State<ImageResizerScreen> {
  final UploadManager _uploadManager = UploadManager();
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final BillingService _billingService = BillingService();

  List<ImageUpload> _images = [];
  bool _isUploading = false;
  bool _isResizing = false;
  List<ResizedImage> _resizedImages = [];

  // Resize settings
  String _selectedPreset = 'medium';
  String _selectedFormat = 'jpeg';
  int? _customWidth;
  int? _customHeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Calculate max file size and batch size for paywall guard
    final maxFileBytes = _images.isEmpty
        ? null
        : _images.map((img) => img.bytes.length).reduce((a, b) => a > b ? a : b);
    final batchSize = _images.length;

    return PaywallGuard(
      billingService: _billingService,
      permission: ToolPermission(
        toolId: 'image_resizer',
        requiresHeavyOp: true,
        fileSize: maxFileBytes,
        batchSize: batchSize > 0 ? batchSize : null,
      ),
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          title: const Text('Image Resizer'),
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Upload zone
              ImageUploadZone(
                onImagesSelected: _pickImages,
                isEnabled: !_isUploading && !_isResizing,
              ),

              const SizedBox(height: 16),

              // Resize settings
              if (_images.isNotEmpty) ...[
                _buildResizeSettings(theme),
                const SizedBox(height: 16),
              ],

              // Progress indicator
              ResizeProgress(
                isUploading: _isUploading,
                isResizing: _isResizing,
              ),

              // Image list
              if (_images.isNotEmpty) ...[
                Text(
                  'Selected Images (${_images.length})',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ImageList(
                    images: _images,
                    onRemove: _removeImage,
                    isEnabled: !_isUploading && !_isResizing,
                  ),
                ),
              ] else if (_resizedImages.isEmpty) ...[
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.photo_size_select_large,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No images selected',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Upload images to resize them',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // Resized images results
              if (_resizedImages.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Resized Images (${_resizedImages.length})',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _buildResizedImagesList(),
                ),
              ],

              // Action buttons
              if (_images.isNotEmpty && !_isUploading && !_isResizing)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _clearImages,
                          child: const Text('Clear All'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FilledButton(
                          onPressed: _resizeImages,
                          child: const Text('Resize Images'),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ), // Column
        ), // Padding (body)
      ), // Scaffold
    ); // PaywallGuard
  }

  Widget _buildResizeSettings(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resize Settings',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),

            // Preset sizes
            Text(
              'Preset Size',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Thumbnail (150×150)'),
                  selected: _selectedPreset == 'thumbnail',
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedPreset = 'thumbnail';
                        _customWidth = null;
                        _customHeight = null;
                      });
                    }
                  },
                ),
                ChoiceChip(
                  label: const Text('Small (640×480)'),
                  selected: _selectedPreset == 'small',
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedPreset = 'small';
                        _customWidth = null;
                        _customHeight = null;
                      });
                    }
                  },
                ),
                ChoiceChip(
                  label: const Text('Medium (1280×720)'),
                  selected: _selectedPreset == 'medium',
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedPreset = 'medium';
                        _customWidth = null;
                        _customHeight = null;
                      });
                    }
                  },
                ),
                ChoiceChip(
                  label: const Text('Large (1920×1080)'),
                  selected: _selectedPreset == 'large',
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedPreset = 'large';
                        _customWidth = null;
                        _customHeight = null;
                      });
                    }
                  },
                ),
                ChoiceChip(
                  label: const Text('Custom'),
                  selected: _customWidth != null || _customHeight != null,
                  onSelected: (selected) {
                    if (selected) {
                      _showCustomDimensionsDialog();
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Output format
            Text(
              'Output Format',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('JPG'),
                  selected: _selectedFormat == 'jpeg',
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedFormat = 'jpeg');
                    }
                  },
                ),
                ChoiceChip(
                  label: const Text('PNG'),
                  selected: _selectedFormat == 'png',
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedFormat = 'png');
                    }
                  },
                ),
                ChoiceChip(
                  label: const Text('WebP'),
                  selected: _selectedFormat == 'webp',
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedFormat = 'webp');
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResizedImagesList() {
    return ListView.builder(
      itemCount: _resizedImages.length,
      itemBuilder: (context, index) {
        final image = _resizedImages[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: Icon(
              Icons.check_circle,
              color: Colors.green.shade600,
            ),
            title: Text(
              image.originalName,
              style: const TextStyle(fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
                '${image.dimensions.width}×${image.dimensions.height} • ${_formatBytes(image.size)}'),
            trailing: IconButton(
              icon: const Icon(Icons.download),
              onPressed: () => _downloadImage(image.downloadUrl),
              tooltip: 'Download',
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImages() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final newImages = result.files
            .where((file) => file.bytes != null)
            .map((file) => ImageUpload.fromBytes(
                  bytes: file.bytes!,
                  name: file.name,
                ))
            .toList();

        // Validate file count
        if (_images.length + newImages.length > 10) {
          _showErrorSnackBar('Maximum 10 images allowed');
          return;
        }

        // Validate all files
        final invalidFiles = newImages.where((file) => !file.isValid).toList();
        if (invalidFiles.isNotEmpty) {
          _showErrorSnackBar('Some files are invalid or exceed 20MB limit');
          return;
        }

        setState(() {
          _images.addAll(newImages);
          _resizedImages = []; // Clear previous results
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick images: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  void _clearImages() {
    setState(() {
      _images = [];
      _resizedImages = [];
    });
  }

  Future<void> _resizeImages() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showErrorSnackBar('Please sign in to resize images');
      return;
    }

    setState(() {
      _isUploading = true;
      _resizedImages = [];
    });

    try {
      // Upload images
      final filePaths = await _uploadManager.uploadMultipleFiles(_images);

      setState(() {
        _isUploading = false;
        _isResizing = true;
      });

      // Resize images
      final requestData = {
        'files': filePaths,
        'format': _selectedFormat,
      };

      // Add preset or custom dimensions
      if (_customWidth != null || _customHeight != null) {
        if (_customWidth != null) requestData['customWidth'] = _customWidth!;
        if (_customHeight != null) requestData['customHeight'] = _customHeight!;
      } else {
        requestData['preset'] = _selectedPreset;
      }

      final result = await _functions.httpsCallable('resizeImages').call(
            requestData,
          );

      final results =
          (result.data['results'] as List).map((r) => ResizedImage.fromJson(r)).toList();

      setState(() {
        _isResizing = false;
        _resizedImages = results;
        _images = []; // Clear uploaded images
      });

      // Track heavy operation (one per image resized)
      for (var i = 0; i < results.length; i++) {
        await _billingService.trackHeavyOp();
      }

      _showSuccessSnackBar('Images resized successfully!');
    } catch (e) {
      setState(() {
        _isUploading = false;
        _isResizing = false;
      });
      _showErrorSnackBar('Failed to resize images: $e');
    }
  }

  Future<void> _downloadImage(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackBar('Could not open download URL');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to download: $e');
    }
  }

  void _showCustomDimensionsDialog() {
    final widthController = TextEditingController(text: _customWidth?.toString() ?? '');
    final heightController = TextEditingController(text: _customHeight?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Custom Dimensions'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: widthController,
              decoration: const InputDecoration(
                labelText: 'Width (px)',
                hintText: 'Leave empty to maintain aspect ratio',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: heightController,
              decoration: const InputDecoration(
                labelText: 'Height (px)',
                hintText: 'Leave empty to maintain aspect ratio',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final width = int.tryParse(widthController.text);
              final height = int.tryParse(heightController.text);

              if (width == null && height == null) {
                _showErrorSnackBar('Please enter at least one dimension');
                return;
              }

              setState(() {
                _customWidth = width;
                _customHeight = height;
                _selectedPreset = '';
              });

              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
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

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// Represents a resized image result
class ResizedImage {
  final String originalName;
  final String downloadUrl;
  final int size;
  final ImageDimensions dimensions;

  ResizedImage({
    required this.originalName,
    required this.downloadUrl,
    required this.size,
    required this.dimensions,
  });

  factory ResizedImage.fromJson(Map<String, dynamic> json) {
    return ResizedImage(
      originalName: json['originalName'] as String,
      downloadUrl: json['downloadUrl'] as String,
      size: json['size'] as int,
      dimensions: ImageDimensions.fromJson(json['dimensions']),
    );
  }
}

/// Represents image dimensions
class ImageDimensions {
  final int width;
  final int height;

  ImageDimensions({required this.width, required this.height});

  factory ImageDimensions.fromJson(Map<String, dynamic> json) {
    return ImageDimensions(
      width: json['width'] as int,
      height: json['height'] as int,
    );
  }
}
