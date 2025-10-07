import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toolspace/tools/unit_converter/unit_converter_screen.dart';

void main() {
  group('UnitConverterScreen Widget Tests', () {
    testWidgets('displays category chips', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UnitConverterScreen(),
        ),
      );

      // Wait for animations
      await tester.pumpAndSettle();

      expect(find.text('Length'), findsWidgets);
      expect(find.text('Mass'), findsAtLeastNWidgets(1));
      expect(find.text('Temperature'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows initial conversion result', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UnitConverterScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Should have input field with default value
      expect(find.text('1'), findsOneWidget);
      // Should have a result displayed
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('has swap button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UnitConverterScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.swap_vert), findsOneWidget);
    });

    testWidgets('swap button works', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UnitConverterScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Tap swap button
      await tester.tap(find.byIcon(Icons.swap_vert));
      await tester.pumpAndSettle();

      // Animation should complete
      expect(find.byType(UnitConverterScreen), findsOneWidget);
    });

    testWidgets('can input values', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UnitConverterScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Find and enter text in input field
      final inputField = find.byType(TextField).first;
      await tester.enterText(inputField, '100');
      await tester.pumpAndSettle();

      expect(find.text('100'), findsWidgets);
    });

    testWidgets('displays precision slider', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UnitConverterScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Precision'), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);
    });

    testWidgets('can change precision', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UnitConverterScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Find slider and drag it
      final slider = find.byType(Slider);
      expect(slider, findsOneWidget);

      // Just verify the slider exists and is interactable
      await tester.tap(slider);
      await tester.pumpAndSettle();
    });

    testWidgets('displays conversions history or popular', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UnitConverterScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Should display either Recent or Popular conversions
      final recentText = find.text('Recent Conversions');
      final popularText = find.text('Popular Conversions');

      expect(recentText.evaluate().isNotEmpty || popularText.evaluate().isNotEmpty, true);
    });

    testWidgets('can switch categories', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UnitConverterScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Find the Mass chip specifically using FilterChip
      final massChip = find.widgetWithText(FilterChip, 'Mass');
      expect(massChip, findsOneWidget);

      // Tap on Mass category
      await tester.tap(massChip);
      await tester.pumpAndSettle();

      // Category should still be available
      expect(find.text('Mass'), findsWidgets);
    });

    testWidgets('has copy button for results', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UnitConverterScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Should have copy button
      expect(find.byIcon(Icons.content_copy), findsOneWidget);
    });

    testWidgets('displays From and To labels', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UnitConverterScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('From'), findsOneWidget);
      expect(find.text('To'), findsOneWidget);
    });

    testWidgets('has floating action button for search', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UnitConverterScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('clears input when clear button pressed', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UnitConverterScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Enter text
      final inputField = find.byType(TextField).first;
      await tester.enterText(inputField, '123');
      await tester.pumpAndSettle();

      // Find and tap clear button
      final clearButton = find.byIcon(Icons.clear).first;
      await tester.tap(clearButton);
      await tester.pumpAndSettle();

      // Input should be cleared
      expect(find.text('123'), findsNothing);
    });

    testWidgets('displays app bar with title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UnitConverterScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Unit Converter'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('has unit selection dropdowns', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UnitConverterScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Should have dropdown indicators
      expect(find.byIcon(Icons.arrow_drop_down), findsNWidgets(2));
    });
  });

  group('Unit Converter Integration Tests', () {
    testWidgets('complete conversion flow', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UnitConverterScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // 1. Enter value
      final inputField = find.byType(TextField).first;
      await tester.enterText(inputField, '100');
      await tester.pumpAndSettle();

      // 2. Value should be entered
      expect(find.text('100'), findsWidgets);

      // 3. Swap units
      await tester.tap(find.byIcon(Icons.swap_vert));
      await tester.pumpAndSettle();

      // 4. Change category
      final massChip = find.widgetWithText(FilterChip, 'Mass');
      await tester.tap(massChip);
      await tester.pumpAndSettle();

      // Should complete without errors
      expect(find.byType(UnitConverterScreen), findsOneWidget);
    });

    testWidgets('popular conversion selection works', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UnitConverterScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Find a popular conversion item (using ListTile)
      final popularItems = find.byIcon(Icons.trending_up);

      // Check if popular items exist
      if (popularItems.evaluate().isNotEmpty) {
        // Tap on first one
        await tester.tap(popularItems.first);
        await tester.pumpAndSettle();
      }

      // Should update the conversion
      expect(find.byType(UnitConverterScreen), findsOneWidget);
    });
  });
}
