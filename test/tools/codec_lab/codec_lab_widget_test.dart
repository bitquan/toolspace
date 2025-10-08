import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toolspace/tools/codec_lab/codec_lab_screen.dart';

void main() {
  group('CodecLabScreen Widget Tests', () {
    testWidgets('renders correctly with all tabs', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CodecLabScreen(),
        ),
      );

      // Check that the screen renders
      expect(find.text('Codec Lab'), findsOneWidget);
      expect(find.text('Text Mode'), findsOneWidget);
      expect(find.text('File Mode'), findsOneWidget);
    });

    testWidgets('switches between Text and File modes',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CodecLabScreen(),
        ),
      );

      // Initially in Text Mode
      expect(find.text('Format'), findsWidgets);

      // Switch to File Mode
      await tester.tap(find.text('File Mode'));
      await tester.pumpAndSettle();

      // Check File Mode is active
      expect(find.text('File Mode'), findsOneWidget);
    });

    testWidgets('displays format selection chips', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CodecLabScreen(),
        ),
      );

      // Check format chips are visible
      expect(find.text('Base64'), findsOneWidget);
      expect(find.text('Hexadecimal'), findsOneWidget);
      expect(find.text('URL Encoding'), findsOneWidget);
    });

    testWidgets('has Encode/Decode toggle', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CodecLabScreen(),
        ),
      );

      // Check encode/decode buttons
      expect(find.text('Encode'), findsOneWidget);
      expect(find.text('Decode'), findsOneWidget);
    });

    testWidgets('has input and output fields in Text Mode',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CodecLabScreen(),
        ),
      );

      // Check input/output sections
      expect(find.text('Input'), findsOneWidget);
      expect(find.text('Output'), findsOneWidget);
    });

    testWidgets('encodes text to Base64', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CodecLabScreen(),
        ),
      );

      // Find input field and enter text
      final inputField =
          find.widgetWithText(TextField, 'Enter text to encode...');
      await tester.enterText(inputField, 'Hello World');
      await tester.pump();

      // Wait for debounce timer (2 seconds)
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Check that output is generated
      final outputField =
          find.widgetWithText(TextField, 'Output will appear here...');
      final outputWidget = tester.widget<TextField>(outputField);
      expect(outputWidget.controller?.text, 'SGVsbG8gV29ybGQ=');
    });

    testWidgets('decodes Base64 to text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CodecLabScreen(),
        ),
      );

      // Switch to decode mode
      await tester.tap(find.text('Decode'));
      await tester.pumpAndSettle();

      // Enter Base64 text
      final inputField =
          find.widgetWithText(TextField, 'Enter encoded text to decode...');
      await tester.enterText(inputField, 'SGVsbG8gV29ybGQ=');
      await tester.pump();

      // Wait for debounce timer (2 seconds)
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Check output
      final outputField =
          find.widgetWithText(TextField, 'Output will appear here...');
      final outputWidget = tester.widget<TextField>(outputField);
      expect(outputWidget.controller?.text, 'Hello World');
    });

    testWidgets('changes format to Hex', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CodecLabScreen(),
        ),
      );

      // Select Hex format
      await tester.tap(find.text('Hexadecimal'));
      await tester.pumpAndSettle();

      // Enter text
      final inputField =
          find.widgetWithText(TextField, 'Enter text to encode...');
      await tester.enterText(inputField, 'Hello');
      await tester.pump();

      // Wait for debounce timer (2 seconds)
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Check hex output
      final outputField =
          find.widgetWithText(TextField, 'Output will appear here...');
      final outputWidget = tester.widget<TextField>(outputField);
      expect(outputWidget.controller?.text, '48656c6c6f');
    });

    testWidgets('swaps input and output', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CodecLabScreen(),
        ),
      );

      // Enter text
      final inputField =
          find.widgetWithText(TextField, 'Enter text to encode...');
      await tester.enterText(inputField, 'Hello');
      await tester.pump();

      // Find and tap swap button
      await tester.tap(find.byIcon(Icons.swap_vert));
      await tester.pumpAndSettle();

      // Check that values are swapped
      final newInputWidget = tester.widget<TextField>(inputField);
      expect(newInputWidget.controller?.text, 'SGVsbG8=');
    });

    testWidgets('shows error for invalid Base64', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CodecLabScreen(),
        ),
      );

      // Switch to decode mode
      await tester.tap(find.text('Decode'));
      await tester.pumpAndSettle();

      // Enter invalid Base64
      final inputField =
          find.widgetWithText(TextField, 'Enter encoded text to decode...');
      await tester.enterText(inputField, 'Invalid!!!');
      await tester.pump();

      // Check for error banner
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('clears input and output', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CodecLabScreen(),
        ),
      );

      // Enter text
      final inputField =
          find.widgetWithText(TextField, 'Enter text to encode...');
      await tester.enterText(inputField, 'Hello');
      await tester.pump();

      // Tap clear button
      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();

      // Check that fields are cleared
      final inputWidget = tester.widget<TextField>(inputField);
      expect(inputWidget.controller?.text, '');
    });

    testWidgets('auto-detects format', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CodecLabScreen(),
        ),
      );

      // Switch to decode mode
      await tester.tap(find.text('Decode'));
      await tester.pumpAndSettle();

      // Enter Base64 text
      final inputField =
          find.widgetWithText(TextField, 'Enter encoded text to decode...');
      await tester.enterText(inputField, 'SGVsbG8gV29ybGQ=');
      await tester.pump();

      // Wait for debounce timer (2 seconds)
      await tester.pump(const Duration(seconds: 2));

      // Tap auto-detect button
      await tester.tap(find.text('Auto-detect'));
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Format should be detected and decoded
      final outputField =
          find.widgetWithText(TextField, 'Output will appear here...');
      final outputWidget = tester.widget<TextField>(outputField);
      expect(outputWidget.controller?.text, 'Hello World');
    });

    testWidgets('shows success message after encoding',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CodecLabScreen(),
        ),
      );

      // Enter text
      final inputField =
          find.widgetWithText(TextField, 'Enter text to encode...');
      await tester.enterText(inputField, 'Hello');
      await tester.pump();

      // Wait for debounce timer (2 seconds)
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Check for success icon
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });

    testWidgets('File Mode shows file upload interface',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CodecLabScreen(),
        ),
      );

      // Switch to File Mode
      await tester.tap(find.text('File Mode'));
      await tester.pumpAndSettle();

      // Check for file upload UI
      expect(find.byIcon(Icons.cloud_upload), findsOneWidget);
      expect(find.text('Click to select a file'), findsOneWidget);
    });
  });
}
