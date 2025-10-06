import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../lib/tools/time_convert/time_convert_screen.dart';

void main() {
  group('TimeConvertScreen Widget Tests', () {
    testWidgets('renders screen with title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TimeConvertScreen(),
        ),
      );

      expect(find.text('Time Converter'), findsOneWidget);
    });

    testWidgets('shows input field and result sections', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TimeConvertScreen(),
        ),
      );

      expect(find.text('Input'), findsOneWidget);
      expect(find.text('Result'), findsOneWidget);
    });

    testWidgets('has "Now" button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TimeConvertScreen(),
        ),
      );

      expect(find.text('Now'), findsOneWidget);
      expect(find.widgetWithIcon(ElevatedButton, Icons.access_time), findsOneWidget);
    });

    testWidgets('clicking "Now" button sets input', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TimeConvertScreen(),
        ),
      );

      // Click the Now button
      await tester.tap(find.text('Now'));
      await tester.pump();

      // Check that input field contains "now"
      final textField = tester.widget<TextField>(find.byType(TextField).first);
      expect(textField.controller?.text, 'now');
    });

    testWidgets('displays quick example templates', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TimeConvertScreen(),
        ),
      );

      expect(find.text('Quick Examples'), findsOneWidget);
      expect(find.text('yesterday'), findsOneWidget);
      expect(find.text('5 minutes ago'), findsOneWidget);
    });

    testWidgets('has timezone selector', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TimeConvertScreen(),
        ),
      );

      expect(find.text('Timezone'), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    });

    testWidgets('has output format selector', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TimeConvertScreen(),
        ),
      );

      expect(find.text('Output Format'), findsOneWidget);
      expect(find.text('ISO 8601'), findsOneWidget);
      expect(find.text('RFC 3339'), findsOneWidget);
      expect(find.text('Unix (seconds)'), findsOneWidget);
    });

    testWidgets('entering text triggers parsing', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TimeConvertScreen(),
        ),
      );

      // Enter "now" in the text field
      await tester.enterText(find.byType(TextField).first, 'now');
      await tester.pump();

      // Should show some result (the actual formatted output)
      // We just verify that parsing happened by checking error doesn't show
      expect(find.text('Unable to parse input'), findsNothing);
    });

    testWidgets('shows error for invalid input', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TimeConvertScreen(),
        ),
      );

      // Enter invalid text
      await tester.enterText(find.byType(TextField).first, 'invalid input xyz');
      await tester.pump();

      // Should show error message
      expect(find.textContaining('Unable to parse'), findsOneWidget);
    });

    testWidgets('clicking quick template sets input', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TimeConvertScreen(),
        ),
      );

      // Find and tap the "yesterday" template
      await tester.tap(find.text('yesterday'));
      await tester.pump();

      // Check that input field contains "yesterday"
      final textField = tester.widget<TextField>(find.byType(TextField).first);
      expect(textField.controller?.text, 'yesterday');
    });

    testWidgets('selecting format updates result', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TimeConvertScreen(),
        ),
      );

      // Set input first
      await tester.enterText(find.byType(TextField).first, 'now');
      await tester.pump();

      // Tap on a different format chip
      await tester.tap(find.text('Unix (seconds)'));
      await tester.pump();

      // The result should be displayed (we don't check exact value, just that it changed)
      // This is a simple check that format selection works
      expect(find.byType(SelectableText), findsWidgets);
    });

    testWidgets('clear button clears input', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TimeConvertScreen(),
        ),
      );

      // Set input
      await tester.enterText(find.byType(TextField).first, 'now');
      await tester.pump();

      // Find and tap clear button
      await tester.tap(find.byIcon(Icons.clear_all));
      await tester.pump();

      // Input should be empty
      final textField = tester.widget<TextField>(find.byType(TextField).first);
      expect(textField.controller?.text, '');
    });

    testWidgets('shows empty state when no input', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TimeConvertScreen(),
        ),
      );

      expect(find.text('Enter a time to convert'), findsOneWidget);
      expect(find.byIcon(Icons.schedule), findsWidgets);
    });

    testWidgets('result section shows multiple formats', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TimeConvertScreen(),
        ),
      );

      // Set input
      await tester.enterText(find.byType(TextField).first, 'now');
      await tester.pump();

      // Should show "Other Formats" section
      expect(find.text('Other Formats'), findsOneWidget);
      expect(find.text('Relative Time'), findsOneWidget);
    });
  });
}
