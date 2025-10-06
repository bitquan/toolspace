import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../lib/tools/csv_cleaner/csv_cleaner_screen.dart';

void main() {
  group('CsvCleanerScreen Widget Tests', () {
    testWidgets('displays empty state initially', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CsvCleanerScreen(),
        ),
      );

      expect(find.text('No CSV file loaded'), findsOneWidget);
      expect(find.text('Upload a CSV file to get started'), findsOneWidget);
      expect(find.byIcon(Icons.upload_file), findsOneWidget);
    });

    testWidgets('shows upload button in empty state', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CsvCleanerScreen(),
        ),
      );

      expect(find.widgetWithText(FilledButton, 'Upload CSV File'), findsOneWidget);
    });

    testWidgets('app bar displays correct title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CsvCleanerScreen(),
        ),
      );

      expect(find.text('CSV Cleaner'), findsOneWidget);
    });
  });
}
