import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toolspace/tools/url_short/url_short_screen.dart';

void main() {
  group('UrlShortScreen Widget Tests', () {
    testWidgets('displays dev access badge in app bar',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UrlShortScreen(),
        ),
      );

      expect(find.text('DEV'), findsOneWidget);
      expect(find.byIcon(Icons.code), findsOneWidget);
    });

    testWidgets('displays URL input field', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UrlShortScreen(),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Enter URL to shorten'), findsOneWidget);
      expect(
          find.text('https://example.com/very/long/url'), findsOneWidget);
    });

    testWidgets('displays shorten button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UrlShortScreen(),
        ),
      );

      expect(find.text('Shorten URL'), findsOneWidget);
      expect(find.byIcon(Icons.content_cut), findsOneWidget);
    });

    testWidgets('displays empty state when no URLs', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UrlShortScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.link_off), findsOneWidget);
      expect(find.text('No short URLs yet'), findsOneWidget);
      expect(find.text('Enter a URL above to get started'), findsOneWidget);
    });

    testWidgets('validates URL input', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UrlShortScreen(),
        ),
      );

      // Enter invalid URL
      await tester.enterText(find.byType(TextField), 'not-a-url');
      await tester.pump();

      expect(find.text('Please enter a valid URL'), findsOneWidget);

      // Enter valid URL
      await tester.enterText(
          find.byType(TextField), 'https://example.com');
      await tester.pump();

      expect(find.text('Please enter a valid URL'), findsNothing);
    });

    testWidgets('shorten button creates URL', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UrlShortScreen(),
        ),
      );

      // Enter valid URL
      await tester.enterText(
          find.byType(TextField), 'https://example.com');
      await tester.pump();

      // Tap shorten button
      await tester.tap(find.text('Shorten URL'));
      await tester.pump();

      // Should show loading state
      expect(find.text('Creating...'), findsOneWidget);

      // Wait for completion
      await tester.pumpAndSettle();

      // Should show success message
      expect(find.textContaining('Short URL created'), findsOneWidget);
    });

    testWidgets('displays URL cards after creation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UrlShortScreen(),
        ),
      );

      // Create a URL
      await tester.enterText(
          find.byType(TextField), 'https://example.com');
      await tester.pump();
      await tester.tap(find.text('Shorten URL'));
      await tester.pumpAndSettle();

      // Should display URL card
      expect(find.byType(Card), findsWidgets);
      expect(find.text('Copy'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('copy button copies URL to clipboard',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UrlShortScreen(),
        ),
      );

      // Create a URL
      await tester.enterText(
          find.byType(TextField), 'https://example.com');
      await tester.tap(find.text('Shorten URL'));
      await tester.pumpAndSettle();

      // Tap copy button
      await tester.tap(find.text('Copy'));
      await tester.pumpAndSettle();

      // Should show success message
      expect(
          find.text('Short URL copied to clipboard!'), findsOneWidget);
    });

    testWidgets('delete button shows confirmation dialog',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UrlShortScreen(),
        ),
      );

      // Create a URL
      await tester.enterText(
          find.byType(TextField), 'https://example.com');
      await tester.tap(find.text('Shorten URL'));
      await tester.pumpAndSettle();

      // Tap delete button
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Should show confirmation dialog
      expect(find.text('Delete Short URL'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('delete confirmation removes URL',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UrlShortScreen(),
        ),
      );

      // Create a URL
      await tester.enterText(
          find.byType(TextField), 'https://example.com');
      await tester.tap(find.text('Shorten URL'));
      await tester.pumpAndSettle();

      // Get initial card count
      final initialCards = find.byType(Card).evaluate().length;

      // Delete the URL
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete').last);
      await tester.pumpAndSettle();

      // Should show success message
      expect(find.text('Short URL deleted'), findsOneWidget);

      // Card count should decrease or show empty state
      final finalCards = find.byType(Card).evaluate().length;
      expect(finalCards, lessThan(initialCards));
    });

    testWidgets('validates URL length', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UrlShortScreen(),
        ),
      );

      // Enter very long URL
      final longUrl = 'https://example.com/' + 'a' * 2500;
      await tester.enterText(find.byType(TextField), longUrl);
      await tester.pump();

      expect(
          find.text('URL is too long (max 2048 characters)'),
          findsOneWidget);
    });
  });

  group('UrlShortScreen Dev Access', () {
    testWidgets('shows locked screen for non-dev users',
        (WidgetTester tester) async {
      // Note: This test would need proper state management
      // to actually test non-dev access. For now, it's a placeholder.
      await tester.pumpWidget(
        const MaterialApp(
          home: UrlShortScreen(),
        ),
      );

      // Dev user sees the input form
      expect(find.text('Enter URL to shorten'), findsOneWidget);
    });
  });

  group('URL Card Widget', () {
    testWidgets('displays URL information', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UrlShortScreen(),
        ),
      );

      // Create a URL
      await tester.enterText(
          find.byType(TextField), 'https://example.com/test');
      await tester.tap(find.text('Shorten URL'));
      await tester.pumpAndSettle();

      // Should display original URL
      expect(find.textContaining('https://example.com/test'), findsOneWidget);
      
      // Should display short code
      expect(find.textContaining('/u/'), findsOneWidget);
      
      // Should display time
      expect(find.text('Just now'), findsOneWidget);
    });
  });
}
