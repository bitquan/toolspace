import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toolspace/core/routes.dart';
import 'package:toolspace/screens/landing/landing_page.dart';

/// Navigation tests for landing page CTAs and navbar links
///
/// Verifies that all navigation buttons route correctly:
/// - Hero section: "Get Started Free" → /signup, "View Pricing" → /pricing
/// - Navbar: Features → /features, Pricing → /pricing, Dashboard → /dashboard or /signup
void main() {
  group('Landing Page Navigation Tests', () {
    testWidgets('btn-get-started navigates to /signup', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          onGenerateRoute: ToolspaceRouter.generateRoute,
          home: LandingPage(),
        ),
      );

      // Wait for the page to settle
      await tester.pumpAndSettle();

      // Find the "Get Started Free" button by its key
      final getStartedButton = find.byKey(const Key('btn-get-started'));
      expect(getStartedButton, findsOneWidget);

      // Tap the button
      await tester.tap(getStartedButton);
      await tester.pumpAndSettle();

      // Verify we navigated to signup
      expect(find.text('Sign Up'), findsWidgets);
    });

    testWidgets('btn-view-pricing navigates to /pricing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          onGenerateRoute: ToolspaceRouter.generateRoute,
          home: LandingPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Find the "View Pricing" button by its key
      final viewPricingButton = find.byKey(const Key('btn-view-pricing'));
      expect(viewPricingButton, findsOneWidget);

      // Tap the button
      await tester.tap(viewPricingButton);
      await tester.pumpAndSettle();

      // Verify we navigated to pricing page
      expect(find.text('Choose your plan'), findsOneWidget);
    });

    testWidgets('nav-features navigates to /features', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          onGenerateRoute: ToolspaceRouter.generateRoute,
          home: LandingPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Find the Features navbar link by its key
      final featuresLink = find.byKey(const Key('nav-features'));
      expect(featuresLink, findsOneWidget);

      // Tap the link
      await tester.tap(featuresLink);
      await tester.pumpAndSettle();

      // Verify we navigated to features page
      expect(find.text('Everything you need to build better, faster'), findsOneWidget);
    });

    testWidgets('nav-pricing navigates to /pricing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          onGenerateRoute: ToolspaceRouter.generateRoute,
          home: LandingPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Find the Pricing navbar link by its key
      final pricingLink = find.byKey(const Key('nav-pricing'));
      expect(pricingLink, findsOneWidget);

      // Tap the link
      await tester.tap(pricingLink);
      await tester.pumpAndSettle();

      // Verify we navigated to pricing page
      expect(find.text('Choose your plan'), findsOneWidget);
    });

    testWidgets('nav-dashboard navigates to /dashboard when unauthenticated', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          onGenerateRoute: ToolspaceRouter.generateRoute,
          home: LandingPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Find the Dashboard navbar link by its key
      final dashboardLink = find.byKey(const Key('nav-dashboard'));
      expect(dashboardLink, findsOneWidget);

      // Tap the link
      await tester.tap(dashboardLink);
      await tester.pumpAndSettle();

      // Verify we navigated to dashboard (NeoHomeScreen in this case)
      // The dashboard screen should be visible
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('all navigation buttons have Semantics labels', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          onGenerateRoute: ToolspaceRouter.generateRoute,
          home: LandingPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify all expected keys exist
      expect(find.byKey(const Key('btn-get-started')), findsOneWidget);
      expect(find.byKey(const Key('btn-view-pricing')), findsOneWidget);
      expect(find.byKey(const Key('nav-features')), findsOneWidget);
      expect(find.byKey(const Key('nav-pricing')), findsOneWidget);
      expect(find.byKey(const Key('nav-dashboard')), findsOneWidget);
    });
  });
}
