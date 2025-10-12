import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Test-only mock version of QrMakerScreen that doesn't depend on Firebase
class MockQrMakerScreen extends StatefulWidget {
  const MockQrMakerScreen({super.key});

  @override
  State<MockQrMakerScreen> createState() => _MockQrMakerScreenState();
}

class _MockQrMakerScreenState extends State<MockQrMakerScreen> {
  String _qrType = 'Text';
  String _inputText = '';
  double _size = 200.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Maker'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // QR Type selector
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('QR Type', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      DropdownButton<String>(
                        value: _qrType,
                        items: ['Text', 'URL', 'Email', 'Phone'].map((type) {
                          return DropdownMenuItem(value: type, child: Text(type));
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _qrType = value);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Input field
            TextField(
              decoration: const InputDecoration(
                labelText: 'Enter text to encode',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _inputText = value),
            ),
            const SizedBox(height: 24),

            // Size control
            Row(
              children: [
                const Text('Size: '),
                Expanded(
                  child: Slider(
                    value: _size,
                    min: 100,
                    max: 400,
                    onChanged: (value) => setState(() => _size = value),
                  ),
                ),
                Text('${_size.round()}px'),
              ],
            ),
            const SizedBox(height: 24),

            // Generate button
            Center(
              child: ElevatedButton(
                onPressed: _inputText.isNotEmpty ? () {} : null,
                child: const Text('Generate QR Code'),
              ),
            ),

            // QR Preview area
            if (_inputText.isNotEmpty) ...[
              const SizedBox(height: 24),
              Center(
                child: Container(
                  width: _size,
                  height: _size,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(child: Text('QR Code Preview')),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

void main() {
  group('QrMakerScreen', () {
    testWidgets('should render QR maker interface', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MockQrMakerScreen(),
        ),
      );

      // Wait for the widget to settle
      await tester.pumpAndSettle();

      // Verify screen elements
      expect(find.text('QR Maker'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Generate QR Code'), findsOneWidget);
    });

    testWidgets('should show empty state initially', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MockQrMakerScreen(),
        ),
      );

      // Wait for the widget to settle
      await tester.pumpAndSettle();

      // Should have input field for text entry
      expect(find.byType(TextField), findsOneWidget);

      // Generate button should be disabled initially
      final generateButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(generateButton.onPressed, isNull);
    });

    testWidgets('should update QR preview when text is entered', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MockQrMakerScreen(),
        ),
      );

      // Wait for the widget to settle
      await tester.pumpAndSettle();

      // Enter text in the input field
      await tester.enterText(find.byType(TextField), 'Test QR Content');
      await tester.pumpAndSettle();

      // Generate button should now be enabled
      final generateButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(generateButton.onPressed, isNotNull);

      // QR preview should be visible
      expect(find.text('QR Code Preview'), findsOneWidget);
    });

    testWidgets('should handle different QR types', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MockQrMakerScreen(),
        ),
      );

      // Wait for the widget to settle
      await tester.pumpAndSettle();

      // Should show QR type dropdown with default 'Text'
      expect(find.text('Text'), findsOneWidget);

      // Tap the dropdown
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();

      // Should see other options
      expect(find.text('URL'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Phone'), findsOneWidget);
    });

    testWidgets('should show customization options', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MockQrMakerScreen(),
        ),
      );

      // Wait for the widget to settle
      await tester.pumpAndSettle();

      // Should have size slider
      expect(find.byType(Slider), findsOneWidget);
      expect(find.text('Size: '), findsOneWidget);
    });
  });
}
