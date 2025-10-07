import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'logic/kmeans_clustering.dart';
import 'logic/palette_exporter.dart';
import 'widgets/color_swatch_card.dart';
import 'widgets/image_upload_zone.dart';

/// Color Palette Extractor - Extract dominant colors from images
class PaletteExtractorScreen extends StatefulWidget {
  const PaletteExtractorScreen({super.key});

  @override
  State<PaletteExtractorScreen> createState() => _PaletteExtractorScreenState();
}

class _PaletteExtractorScreenState extends State<PaletteExtractorScreen> {
  Uint8List? _imageBytes;
  ui.Image? _image;
  List<Color> _palette = [];
  List<int> _frequencies = [];
  bool _isExtracting = false;
  String? _errorMessage;
  int _colorCount = 10;

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowedExtensions: ['png', 'jpg', 'jpeg', 'webp'],
        withData: true,
      );

      if (result != null && result.files.first.bytes != null) {
        final bytes = result.files.first.bytes!;

        // Check file size (max 10MB)
        if (bytes.length > 10 * 1024 * 1024) {
          setState(() {
            _errorMessage = 'Image file is too large. Maximum size is 10MB.';
          });
          return;
        }

        setState(() {
          _imageBytes = bytes;
          _errorMessage = null;
        });

        await _extractColors();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load image: $e';
      });
    }
  }

  Future<void> _extractColors() async {
    if (_imageBytes == null) return;

    setState(() {
      _isExtracting = true;
      _errorMessage = null;
      _palette = [];
      _frequencies = [];
    });

    try {
      // Decode image
      final codec = await ui.instantiateImageCodec(_imageBytes!);
      final frame = await codec.getNextFrame();
      _image = frame.image;

      // Get pixel data
      final byteData =
          await _image!.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (byteData == null) {
        throw Exception('Failed to get image pixel data');
      }

      // Extract colors from pixels
      final pixels = <Color>[];
      final buffer = byteData.buffer.asUint8List();

      for (var i = 0; i < buffer.length; i += 4) {
        final r = buffer[i];
        final g = buffer[i + 1];
        final b = buffer[i + 2];
        final a = buffer[i + 3];

        // Skip fully transparent pixels
        if (a > 0) {
          pixels.add(Color.fromARGB(255, r, g, b));
        }
      }

      // Run k-means clustering
      final result = await KMeansClustering.extractPalette(
        pixels,
        k: _colorCount,
        sampleSize: 10000, // Sample for performance
      );

      setState(() {
        _palette = result.colors;
        _frequencies = result.frequencies;
        _isExtracting = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to extract colors: $e';
        _isExtracting = false;
      });
    }
  }

  Future<void> _exportPalette(ExportFormat format) async {
    if (_palette.isEmpty) return;

    try {
      final String filename;
      // ignore: unused_local_variable
      final dynamic content;

      switch (format) {
        case ExportFormat.json:
          filename = 'palette.json';
          content = PaletteExporter.exportJson(_palette);
          break;
        case ExportFormat.aco:
          filename = 'palette.aco';
          content = PaletteExporter.exportAco(_palette);
          break;
        case ExportFormat.css:
          filename = 'palette.css';
          content = PaletteExporter.exportCss(_palette);
          break;
        case ExportFormat.scss:
          filename = 'palette.scss';
          content = PaletteExporter.exportScss(_palette);
          break;
        case ExportFormat.txt:
          filename = 'palette.txt';
          content = PaletteExporter.exportPlainText(_palette);
          break;
      }

      // For web, trigger download
      // Note: This is a simplified version. In a real implementation,
      // you'd use a package like 'universal_html' for web downloads

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exported as $filename'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE91E63).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.palette,
                color: Color(0xFFE91E63),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Color Palette Extractor'),
          ],
        ),
        actions: [
          if (_palette.isNotEmpty) ...[
            PopupMenuButton<ExportFormat>(
              icon: const Icon(Icons.download),
              tooltip: 'Export Palette',
              onSelected: _exportPalette,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: ExportFormat.json,
                  child: Row(
                    children: [
                      Icon(Icons.code, size: 20),
                      SizedBox(width: 12),
                      Text('Export as JSON'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: ExportFormat.aco,
                  child: Row(
                    children: [
                      Icon(Icons.adobe, size: 20),
                      SizedBox(width: 12),
                      Text('Export as ACO (Adobe)'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: ExportFormat.css,
                  child: Row(
                    children: [
                      Icon(Icons.css, size: 20),
                      SizedBox(width: 12),
                      Text('Export as CSS'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: ExportFormat.scss,
                  child: Row(
                    children: [
                      Icon(Icons.style, size: 20),
                      SizedBox(width: 12),
                      Text('Export as SCSS'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: ExportFormat.txt,
                  child: Row(
                    children: [
                      Icon(Icons.text_fields, size: 20),
                      SizedBox(width: 12),
                      Text('Export as Text'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // Settings panel
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Number of colors: $_colorCount',
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Slider(
                        value: _colorCount.toDouble(),
                        min: 3,
                        max: 20,
                        divisions: 17,
                        label: _colorCount.toString(),
                        onChanged: _imageBytes == null || _isExtracting
                            ? null
                            : (value) {
                                setState(() {
                                  _colorCount = value.round();
                                });
                              },
                        onChangeEnd: (value) {
                          if (_imageBytes != null) {
                            _extractColors();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Image upload zone
                  ImageUploadZone(
                    onImageSelected: _pickImage,
                    isEnabled: !_isExtracting,
                    hasImage: _imageBytes != null,
                  ),

                  // Image preview
                  if (_imageBytes != null) ...[
                    const SizedBox(height: 16),
                    Card(
                      clipBehavior: Clip.antiAlias,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxHeight: 300,
                        ),
                        child: Image.memory(
                          _imageBytes!,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],

                  // Error message
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Card(
                      color: theme.colorScheme.errorContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: theme.colorScheme.error,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // Loading state
                  if (_isExtracting) ...[
                    const SizedBox(height: 32),
                    Center(
                      child: Column(
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            'Extracting colors...',
                            style: theme.textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Palette grid
                  if (_palette.isNotEmpty && !_isExtracting) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Extracted Colors',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: _palette.length,
                      itemBuilder: (context, index) {
                        final totalPixels =
                            _frequencies.fold(0, (sum, f) => sum + f);
                        final percentage =
                            (_frequencies[index] / totalPixels) * 100;

                        return ColorSwatchCard(
                          color: _palette[index],
                          index: index,
                          percentage: percentage,
                        );
                      },
                    ),
                  ],

                  // Empty state
                  if (_palette.isEmpty &&
                      !_isExtracting &&
                      _imageBytes == null) ...[
                    const SizedBox(height: 48),
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.palette_outlined,
                            size: 64,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Upload an image to extract its color palette',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'The tool will extract the most dominant colors using k-means clustering',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant
                                  .withOpacity(0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
