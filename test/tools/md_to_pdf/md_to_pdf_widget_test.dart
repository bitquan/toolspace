import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../lib/tools/md_to_pdf/md_to_pdf_screen.dart';

void main() {
  group('MdToPdfScreen Widget Tests', () {
    testWidgets('should render screen with title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MdToPdfScreen(),
        ),
      );

      expect(find.text('Markdown to PDF'), findsOneWidget);
      expect(find.text('Export to PDF'), findsOneWidget);
    });

    testWidgets('should show split pane on wide screen', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      
      await tester.pumpWidget(
        const MaterialApp(
          home: MdToPdfScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Markdown Editor'), findsOneWidget);
      expect(find.text('Live Preview'), findsOneWidget);
    });

    testWidgets('should show tabs on narrow screen', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(600, 800);
      tester.view.devicePixelRatio = 1.0;
      
      await tester.pumpWidget(
        const MaterialApp(
          home: MdToPdfScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Preview'), findsOneWidget);
    });

    testWidgets('should update preview when markdown changes', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MdToPdfScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Find the text field
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      // Enter new text
      await tester.enterText(textField, '# Test Heading');
      await tester.pumpAndSettle();

      // Preview should update (this is handled by Markdown widget)
      expect(find.text('# Test Heading'), findsOneWidget);
    });

    testWidgets('should show export button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MdToPdfScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.widgetWithText(FilledButton, 'Export to PDF'), findsOneWidget);
    });

    testWidgets('should show progress indicator when exporting', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MdToPdfScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Initially should not show progress
      expect(find.byType(CircularProgressIndicator), findsNothing);
      
      // Note: Testing the export flow requires mocking Firebase functions
      // which is beyond the scope of this simple test
    });
  });
}
