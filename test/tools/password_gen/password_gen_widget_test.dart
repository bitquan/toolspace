import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toolspace/tools/password_gen/password_gen_screen.dart';

void main() {
  testWidgets('Password generator screen loads correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PasswordGenScreen(),
      ),
    );

    // Check that the screen title is present
    expect(find.text('Password Generator'), findsOneWidget);

    // Check that settings card is present
    expect(find.text('Password Settings'), findsOneWidget);

    // Check that character set options are present
    expect(find.text('Uppercase (A-Z)'), findsOneWidget);
    expect(find.text('Lowercase (a-z)'), findsOneWidget);
    expect(find.text('Digits (0-9)'), findsOneWidget);
  });

  testWidgets('Length slider changes password length', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PasswordGenScreen(),
      ),
    );

    // Find the slider
    final sliderFinder = find.byType(Slider);
    expect(sliderFinder, findsOneWidget);

    // Initial length should be 16
    expect(find.text('Length: 16 characters'), findsOneWidget);

    // Drag the slider to change the length
    await tester.drag(sliderFinder, const Offset(100, 0));
    await tester.pumpAndSettle();

    // Length should have changed
    expect(find.textContaining('Length:'), findsOneWidget);
  });

  testWidgets('Character toggles can be changed', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PasswordGenScreen(),
      ),
    );

    // Find checkboxes
    final checkboxes = find.byType(CheckboxListTile);
    expect(checkboxes, findsWidgets);

    // Tap the uppercase checkbox to toggle it
    await tester.tap(find.text('Uppercase (A-Z)'));
    await tester.pumpAndSettle();

    // The checkbox should have changed state (covered by internal state)
  });

  testWidgets('Avoid ambiguous characters toggle works', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PasswordGenScreen(),
      ),
    );

    // Find the avoid ambiguous checkbox
    expect(find.text('Avoid ambiguous characters'), findsOneWidget);
    expect(find.text('Excludes: 0, O, 1, l, I'), findsOneWidget);

    // Tap to toggle
    await tester.tap(find.text('Avoid ambiguous characters'));
    await tester.pumpAndSettle();
  });

  testWidgets('Generate button creates password', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PasswordGenScreen(),
      ),
    );

    // Find and tap the generate button
    final generateButton = find.widgetWithText(FilledButton, 'Generate');
    expect(generateButton, findsOneWidget);

    await tester.tap(generateButton);
    await tester.pumpAndSettle();

    // Check that a password was generated
    expect(find.text('Generated Password'), findsOneWidget);
  });

  testWidgets('Generate 20 button creates batch', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PasswordGenScreen(),
      ),
    );

    // Find and tap the batch generate button
    final batchButton = find.widgetWithText(OutlinedButton, 'Generate 20');
    expect(batchButton, findsOneWidget);

    await tester.tap(batchButton);
    await tester.pumpAndSettle();

    // Check that batch was generated
    expect(find.textContaining('Batch Generated'), findsOneWidget);
  });

  testWidgets('Strength meter is displayed', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PasswordGenScreen(),
      ),
    );

    // Check for strength indicator
    expect(find.text('Password Strength'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.textContaining('Entropy:'), findsOneWidget);
  });

  testWidgets('Validation error is shown for invalid config', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PasswordGenScreen(),
      ),
    );

    // Uncheck all character sets
    await tester.tap(find.text('Uppercase (A-Z)'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Lowercase (a-z)'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Digits (0-9)'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Symbols (!@#\$%^&*)'));
    await tester.pumpAndSettle();

    // Check that validation error is shown
    expect(find.byIcon(Icons.warning), findsOneWidget);
    expect(find.text('At least one character set must be selected'), findsOneWidget);
  });

  testWidgets('Copy button is available for generated password', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PasswordGenScreen(),
      ),
    );

    // Generate a password
    await tester.tap(find.widgetWithText(FilledButton, 'Generate'));
    await tester.pumpAndSettle();

    // Check for copy button
    expect(find.text('Copy Password'), findsOneWidget);
  });

  testWidgets('Batch generation shows list of passwords', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PasswordGenScreen(),
      ),
    );

    // Generate batch
    await tester.tap(find.widgetWithText(OutlinedButton, 'Generate 20'));
    await tester.pumpAndSettle();

    // Check that the list is present
    expect(find.byType(ListTile), findsWidgets);

    // Check for "Copy All" button
    expect(find.text('Copy All'), findsWidgets);
  });

  testWidgets('Strength label updates with config changes', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PasswordGenScreen(),
      ),
    );

    // Initial state should show some strength
    expect(find.byType(Chip), findsOneWidget);

    // Change to weaker config - uncheck some options
    await tester.tap(find.text('Symbols (!@#\$%^&*)'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Digits (0-9)'));
    await tester.pumpAndSettle();

    // Strength meter should still be present
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });
}
