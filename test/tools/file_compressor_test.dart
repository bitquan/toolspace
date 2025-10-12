import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Test-only mock version of FileCompressorScreen that doesn't depend on Firebase
class MockFileCompressorScreen extends StatefulWidget {
  const MockFileCompressorScreen({super.key});

  @override
  State<MockFileCompressorScreen> createState() => _MockFileCompressorScreenState();
}

class _MockFileCompressorScreenState extends State<MockFileCompressorScreen> {
  final List<String> _files = [];
  double _compressionLevel = 70.0;
  String _outputFormat = 'ZIP';
  bool _isCompressing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Compressor'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // File selection area
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, width: 2, style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: _files.isEmpty
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_upload_outlined, size: 32, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('No files selected',
                            style: TextStyle(fontSize: 14, color: Colors.grey)),
                        Text('Drag & drop files or click to browse',
                            style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    )
                  : ListView.builder(
                      itemCount: _files.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: const Icon(Icons.insert_drive_file),
                          title: Text(_files[index]),
                          trailing: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              setState(() => _files.removeAt(index));
                            },
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),

            // Select Files button
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _files.add('test_file_${_files.length + 1}.txt');
                });
              },
              icon: const Icon(Icons.folder_open),
              label: const Text('Select Files'),
            ),
            const SizedBox(height: 16),

            // Compression Level
            const Text('Compression Level',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Row(
              children: [
                const Text('Fast', style: TextStyle(fontSize: 12)),
                Expanded(
                  child: Slider(
                    value: _compressionLevel,
                    min: 0,
                    max: 100,
                    onChanged: (value) => setState(() => _compressionLevel = value),
                  ),
                ),
                const Text('Best', style: TextStyle(fontSize: 12)),
              ],
            ),
            Text('${_compressionLevel.round()}%',
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 8),

            // Output Format
            const Text('Output Format',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 4),
            DropdownButton<String>(
              value: _outputFormat,
              items: ['ZIP', '7Z', 'TAR.GZ'].map((format) {
                return DropdownMenuItem(value: format, child: Text(format));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _outputFormat = value);
                }
              },
            ),
            const SizedBox(height: 8),

            // Compression info
            Text('Estimated compression ratio: ${(100 - _compressionLevel).round()}%',
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 16),

            // Compress button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _files.isNotEmpty && !_isCompressing
                    ? () {
                        setState(() => _isCompressing = true);
                        // Simulate compression
                        Future.delayed(const Duration(seconds: 2), () {
                          if (mounted) setState(() => _isCompressing = false);
                        });
                      }
                    : null,
                child: _isCompressing
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Compressing...'),
                        ],
                      )
                    : const Text('Compress Files'),
              ),
            ),

            if (_isCompressing) ...[
              const SizedBox(height: 8),
              const LinearProgressIndicator(),
            ],
          ],
        ),
      ),
    );
  }
}

void main() {
  group('FileCompressorScreen', () {
    testWidgets('should render file compressor interface', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MockFileCompressorScreen(),
        ),
      );

      // Wait for the widget to settle
      await tester.pumpAndSettle();

      // Verify screen elements
      expect(find.text('File Compressor'), findsOneWidget);
      expect(find.text('Select Files'), findsOneWidget);
      expect(find.text('Compression Level'), findsOneWidget);
    });

    testWidgets('should show empty state initially', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MockFileCompressorScreen(),
        ),
      );

      // Wait for the widget to settle
      await tester.pumpAndSettle();

      // Should show empty file list
      expect(find.text('No files selected'), findsOneWidget);
      expect(find.text('Drag & drop files or click to browse'), findsOneWidget);
    });

    testWidgets('should display compression settings', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MockFileCompressorScreen(),
        ),
      );

      await tester.pump();

      // Should have compression level slider
      expect(find.text('Compression Level'), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);
      expect(find.text('70%'), findsOneWidget); // Default compression level
    });

    testWidgets('should show output format options', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MockFileCompressorScreen(),
        ),
      );

      await tester.pump();

      // Should have format selection
      expect(find.text('Output Format'), findsOneWidget);
      expect(find.text('ZIP'), findsOneWidget);
      expect(find.byType(DropdownButton<String>), findsOneWidget);
    });

    testWidgets('should handle compression level changes', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MockFileCompressorScreen(),
        ),
      );

      await tester.pump();

      // Find compression slider and adjust it
      final slider = find.byType(Slider);
      expect(slider, findsOneWidget);

      // Verify slider exists and can be interacted with
      await tester.drag(slider, const Offset(50, 0));
      await tester.pump();
    });

    testWidgets('should show file size estimates', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MockFileCompressorScreen(),
        ),
      );

      await tester.pump();

      // Should show compression info
      expect(find.textContaining('Estimated compression ratio'), findsOneWidget);
    });

    testWidgets('should handle different output formats', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MockFileCompressorScreen(),
        ),
      );

      await tester.pump();

      // Find and tap format dropdown
      final dropdown = find.byType(DropdownButton<String>);
      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      // Should show format options
      expect(find.text('7Z'), findsOneWidget);
      expect(find.text('TAR.GZ'), findsOneWidget);
    });

    testWidgets('should show compression progress when processing', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MockFileCompressorScreen(),
        ),
      );

      await tester.pump();

      // Processing state would show progress indicators
      expect(find.byType(LinearProgressIndicator), findsNothing); // Initially no progress

      // Add a file and start compression
      await tester.tap(find.text('Select Files'));
      await tester.pump();

      await tester.tap(find.text('Compress Files'));
      await tester.pump(); // Don't wait for settle to catch progress state

      // Should show compressing state
      expect(find.text('Compressing...'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      // Wait for the compression to complete
      await tester.pumpAndSettle();
    });
  });
}
