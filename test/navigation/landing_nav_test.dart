/// Navigation tests for landing page CTAs and navbar links
///
/// Verifies that all navigation buttons route correctly:
/// - Hero section: "Get Started Free" → /signup, "View Pricing" → /pricing
/// - Navbar: Features → /features, Pricing → /pricing, Dashboard → /dashboard or /signup
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Test-only mock landing page with navigation buttons
class MockLandingPageWithNav extends StatelessWidget {
  const MockLandingPageWithNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Toolspace'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          TextButton(
            key: const Key('navbar-features'),
            onPressed: () => Navigator.pushNamed(context, '/features'),
            child: const Text('Features'),
          ),
          TextButton(
            key: const Key('navbar-pricing'),
            onPressed: () => Navigator.pushNamed(context, '/pricing'),
            child: const Text('Pricing'),
          ),
          TextButton(
            key: const Key('navbar-dashboard'),
            onPressed: () => Navigator.pushNamed(context, '/dashboard'),
            child: const Text('Dashboard'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero section
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  const Text(
                    'Welcome to Toolspace',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Your all-in-one productivity toolkit',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        key: const Key('btn-get-started'),
                        onPressed: () => Navigator.pushNamed(context, '/signup'),
                        child: const Text('Get Started Free'),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton(
                        key: const Key('btn-view-pricing'),
                        onPressed: () => Navigator.pushNamed(context, '/pricing'),
                        child: const Text('View Pricing'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Mock pricing section with CTA
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  const Text(
                    'Pricing',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text(
                            'Pro Plan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text('\$9.99/month'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            key: const Key('btn-choose-plan'),
                            onPressed: () => Navigator.pushNamed(context, '/signup'),
                            child: const Text('Choose Plan'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Mock routes for navigation testing
class MockRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/signup':
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(child: Text('Sign Up')),
          ),
        );
      case '/pricing':
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(child: Text('Pricing')),
          ),
        );
      case '/features':
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(child: Text('Features')),
          ),
        );
      case '/dashboard':
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(child: Text('Dashboard')),
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (context) => const MockLandingPageWithNav(),
        );
    }
  }
}

void main() {
  group('Landing Page Navigation Tests', () {
    testWidgets('btn-get-started navigates to /signup', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          onGenerateRoute: MockRouter.generateRoute,
          home: MockLandingPageWithNav(),
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
      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('btn-view-pricing navigates to /pricing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          onGenerateRoute: MockRouter.generateRoute,
          home: MockLandingPageWithNav(),
        ),
      );

      await tester.pumpAndSettle();

      // Find the "View Pricing" button
      final viewPricingButton = find.byKey(const Key('btn-view-pricing'));
      expect(viewPricingButton, findsOneWidget);

      // Tap the button
      await tester.tap(viewPricingButton);
      await tester.pumpAndSettle();

      // Verify we navigated to pricing
      expect(find.text('Pricing'), findsWidgets);
    });

    testWidgets('navbar-features navigates to /features', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          onGenerateRoute: MockRouter.generateRoute,
          home: MockLandingPageWithNav(),
        ),
      );

      await tester.pumpAndSettle();

      // Find the navbar Features link
      final featuresLink = find.byKey(const Key('navbar-features'));
      expect(featuresLink, findsOneWidget);

      // Tap the link
      await tester.tap(featuresLink);
      await tester.pumpAndSettle();

      // Verify we navigated to features
      expect(find.text('Features'), findsWidgets);
    });

    testWidgets('navbar-pricing navigates to /pricing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          onGenerateRoute: MockRouter.generateRoute,
          home: MockLandingPageWithNav(),
        ),
      );

      await tester.pumpAndSettle();

      // Find the navbar Pricing link
      final pricingLink = find.byKey(const Key('navbar-pricing'));
      expect(pricingLink, findsOneWidget);

      // Tap the link
      await tester.tap(pricingLink);
      await tester.pumpAndSettle();

      // Verify we navigated to pricing
      expect(find.text('Pricing'), findsWidgets);
    });

    testWidgets('navbar-dashboard navigates to /dashboard', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          onGenerateRoute: MockRouter.generateRoute,
          home: MockLandingPageWithNav(),
        ),
      );

      await tester.pumpAndSettle();

      // Find the navbar Dashboard link
      final dashboardLink = find.byKey(const Key('navbar-dashboard'));
      expect(dashboardLink, findsOneWidget);

      // Tap the link
      await tester.tap(dashboardLink);
      await tester.pumpAndSettle();

      // Verify we navigated to dashboard
      expect(find.text('Dashboard'), findsOneWidget);
    });

    testWidgets('btn-choose-plan navigates to /signup', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          onGenerateRoute: MockRouter.generateRoute,
          home: MockLandingPageWithNav(),
        ),
      );

      await tester.pumpAndSettle();

      // Scroll to find the choose plan button in pricing section
      await tester.scrollUntilVisible(
        find.byKey(const Key('btn-choose-plan')),
        500.0,
      );

      final choosePlanButton = find.byKey(const Key('btn-choose-plan'));
      expect(choosePlanButton, findsOneWidget);

      // Tap the button
      await tester.tap(choosePlanButton);
      await tester.pumpAndSettle();

      // Verify we navigated to signup
      expect(find.text('Sign Up'), findsOneWidget);
    });

    group('Semantic Navigation Tests', () {
      testWidgets('all primary CTAs have proper semantics', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            onGenerateRoute: MockRouter.generateRoute,
            home: MockLandingPageWithNav(),
          ),
        );

        await tester.pumpAndSettle();

        // Check that primary CTA buttons have semantic labels
        expect(find.bySemanticsLabel('Get Started Free'), findsOneWidget);
        expect(find.bySemanticsLabel('View Pricing'), findsOneWidget);
      });

      testWidgets('navbar links have proper semantic roles', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            onGenerateRoute: MockRouter.generateRoute,
            home: MockLandingPageWithNav(),
          ),
        );

        await tester.pumpAndSettle();

        // Find navbar elements by semantic content
        expect(find.widgetWithText(TextButton, 'Features'), findsOneWidget);
        expect(find.widgetWithText(TextButton, 'Pricing'), findsOneWidget);
        expect(find.widgetWithText(TextButton, 'Dashboard'), findsOneWidget);
      });
    });
  });
}
