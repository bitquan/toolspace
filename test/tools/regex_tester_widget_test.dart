import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/tools/regex_tester/regex_tester_screen.dart';

void main() {
  group('RegexTesterScreen Widget Tests', () {
    testWidgets('renders initial UI correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RegexTesterScreen(),
        ),
      );

      // Check for main elements
      expect(find.text('Regex Tester'), findsOneWidget);
      expect(find.text('Ready'), findsOneWidget);
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('displays pattern input field', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RegexTesterScreen(),
        ),
      );

      expect(find.text('Regex Pattern'), findsOneWidget);
      expect(
        find.widgetWithText(TextField, 'Regex Pattern'),
        findsOneWidget,
      );
    });

    testWidgets('displays test text input field', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RegexTesterScreen(),
        ),
      );

      expect(find.text('Test Text'), findsOneWidget);
    });

    testWidgets('displays flag chips', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RegexTesterScreen(),
        ),
      );

      expect(find.text('Case sensitive'), findsOneWidget);
      expect(find.text('Multiline'), findsOneWidget);
      expect(find.text('Dot all'), findsOneWidget);
      expect(find.text('Unicode'), findsOneWidget);
    });

    testWidgets('can toggle flags', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RegexTesterScreen(),
        ),
      );

      // Find and tap the multiline chip
      final multilineChip = find.widgetWithText(FilterChip, 'Multiline');
      expect(multilineChip, findsOneWidget);

      await tester.tap(multilineChip);
      await tester.pump();

      // Chip should be selected after tap
      final chip = tester.widget<FilterChip>(multilineChip);
      expect(chip.selected, true);
    });

    testWidgets('can enter pattern text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RegexTesterScreen(),
        ),
      );

      final patternField = find.widgetWithText(TextField, 'Regex Pattern');
      await tester.enterText(patternField, r'\d+');
      await tester.pump();

      expect(find.text(r'\d+'), findsOneWidget);
    });

    testWidgets('can enter test text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RegexTesterScreen(),
        ),
      );

      // Find the test text field (the one with multiline)
      final testFields = find.byType(TextField);
      expect(testFields, findsWidgets);

      // Enter text in the last TextField (the test text area)
      await tester.enterText(testFields.last, 'test 123');
      await tester.pump();

      expect(find.text('test 123'), findsOneWidget);
    });

    testWidgets('displays results panel', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RegexTesterScreen(),
        ),
      );

      expect(find.text('Matches & Groups'), findsOneWidget);
    });

    testWidgets('shows info message when no input', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RegexTesterScreen(),
        ),
      );

      expect(
        find.text('Enter a pattern and text to see matches'),
        findsOneWidget,
      );
    });

    testWidgets('can toggle presets panel', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RegexTesterScreen(),
        ),
      );

      // Initially presets should not be visible
      expect(find.text('Pattern Library'), findsNothing);

      // Find and tap the library icon button
      final libraryButton = find.byIcon(Icons.library_books);
      expect(libraryButton, findsOneWidget);

      await tester.tap(libraryButton);
      await tester.pumpAndSettle();

      // Now presets panel should be visible
      expect(find.text('Pattern Library'), findsOneWidget);
    });

    testWidgets('presets panel shows categories', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RegexTesterScreen(),
        ),
      );

      // Open presets panel
      await tester.tap(find.byIcon(Icons.library_books));
      await tester.pumpAndSettle();

      // Check for category names
      expect(find.text('Basic'), findsOneWidget);
      expect(find.text('Numbers'), findsOneWidget);
      expect(find.text('Text'), findsOneWidget);
      expect(find.text('Programming'), findsOneWidget);
    });

    testWidgets('updates status on pattern input', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RegexTesterScreen(),
        ),
      );

      // Enter a pattern
      final patternField = find.widgetWithText(TextField, 'Regex Pattern');
      await tester.enterText(patternField, r'\d+');
      
      // Enter test text
      final testFields = find.byType(TextField);
      await tester.enterText(testFields.last, 'test 123');
      
      await tester.pumpAndSettle();

      // Status should update to show success
      expect(find.text('Success'), findsOneWidget);
    });

    testWidgets('shows error for invalid pattern', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RegexTesterScreen(),
        ),
      );

      // Enter an invalid pattern
      final patternField = find.widgetWithText(TextField, 'Regex Pattern');
      await tester.enterText(patternField, r'[unclosed');
      
      // Enter test text
      final testFields = find.byType(TextField);
      await tester.enterText(testFields.last, 'test');
      
      await tester.pumpAndSettle();

      // Status should show error
      expect(find.text('Error'), findsOneWidget);
    });

    testWidgets('can clear pattern', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RegexTesterScreen(),
        ),
      );

      // Enter a pattern
      final patternField = find.widgetWithText(TextField, 'Regex Pattern');
      await tester.enterText(patternField, r'\d+');
      await tester.pump();

      // Find and tap the clear button
      final clearButton = find.byIcon(Icons.clear);
      expect(clearButton, findsOneWidget);

      await tester.tap(clearButton);
      await tester.pump();

      // Pattern field should be empty
      final textField = tester.widget<TextField>(patternField);
      expect(textField.controller?.text, isEmpty);
    });

    testWidgets('displays copy button when pattern exists', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RegexTesterScreen(),
        ),
      );

      // Initially no copy button
      expect(find.byIcon(Icons.copy), findsNothing);

      // Enter a pattern
      final patternField = find.widgetWithText(TextField, 'Regex Pattern');
      await tester.enterText(patternField, r'\d+');
      await tester.pump();

      // Now copy button should appear
      expect(find.byIcon(Icons.copy), findsOneWidget);
    });

    testWidgets('shows no matches message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RegexTesterScreen(),
        ),
      );

      // Enter pattern that won't match
      final patternField = find.widgetWithText(TextField, 'Regex Pattern');
      await tester.enterText(patternField, r'\d+');
      
      // Enter text without numbers
      final testFields = find.byType(TextField);
      await tester.enterText(testFields.last, 'no numbers');
      
      await tester.pumpAndSettle();

      // Should show no matches message
      expect(find.text('No matches found'), findsOneWidget);
    });
  });
}
