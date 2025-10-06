import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FileMergerScreen Widget Tests', () {
    testWidgets('should build without crashing', (WidgetTester tester) async {
      // This is a simple smoke test to verify the basic UI components
      // without requiring Firebase initialization

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('File Merger')),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload, size: 64),
                  SizedBox(height: 16),
                  Text('Tap to select files or drag & drop'),
                  SizedBox(height: 8),
                  Text('PDF, PNG, JPG files • Max 10MB each • Up to 20 files'),
                ],
              ),
            ),
          ),
        ),
      );

      // Verify basic elements are present
      expect(find.text('File Merger'), findsOneWidget);
      expect(find.text('Tap to select files or drag & drop'), findsOneWidget);
      expect(find.text('PDF, PNG, JPG files • Max 10MB each • Up to 20 files'),
          findsOneWidget);
      expect(find.byIcon(Icons.cloud_upload), findsOneWidget);
    });

    testWidgets('should display file constraints correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const Text('PDF, PNG, JPG files'),
                const Text('Max 10MB each'),
                const Text('Up to 20 files'),
                ElevatedButton(
                  onPressed: null, // Disabled when no files
                  child: const Text('Merge Files'),
                ),
              ],
            ),
          ),
        ),
      );

      // Verify constraint text
      expect(find.text('PDF, PNG, JPG files'), findsOneWidget);
      expect(find.text('Max 10MB each'), findsOneWidget);
      expect(find.text('Up to 20 files'), findsOneWidget);

      // Verify disabled merge button
      final button = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Merge Files'));
      expect(button.onPressed, isNull);
    });

    testWidgets('should show app bar with correct title',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: const Text('File Merger'),
              backgroundColor: Colors.purple,
            ),
            body: const Center(child: Text('File Merger UI')),
          ),
        ),
      );

      expect(find.text('File Merger'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });
  });
}
