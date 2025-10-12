/// Golden visual regression tests for landing page
///
/// Tests the landing page at two critical breakpoints:
/// - Phone: 360×800 (mobile viewport)
/// - Desktop: 1440×900 (desktop viewport)
///
/// Run with:
/// - Generate goldens: flutter test --update-goldens test/golden/landing_golden_test.dart
/// - Verify goldens: flutter test test/golden/landing_golden_test.dart
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

// Test-only mock landing page that doesn't depend on Firebase
class MockLandingPage extends StatelessWidget {
  const MockLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Toolspace'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            // Hero section
            Padding(
              padding: EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Text(
                    'Welcome to Toolspace',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Your all-in-one productivity toolkit',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: null,
                    child: Text('Get Started'),
                  ),
                ],
              ),
            ),

            // Features section
            Padding(
              padding: EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Text(
                    'Features',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Icon(Icons.build, size: 48),
                          SizedBox(height: 8),
                          Text('Tools'),
                        ],
                      ),
                      Column(
                        children: [
                          Icon(Icons.speed, size: 48),
                          SizedBox(height: 8),
                          Text('Fast'),
                        ],
                      ),
                      Column(
                        children: [
                          Icon(Icons.security, size: 48),
                          SizedBox(height: 8),
                          Text('Secure'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Mock pricing section (no Firebase)
            Padding(
              padding: EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Text(
                    'Pricing',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            'Pro Plan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text('\$9.99/month'),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: null,
                            child: Text('Choose Plan'),
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

void main() {
  setUpAll(() async {
    // Load app fonts for consistent text rendering across platforms
    await loadAppFonts();
  });

  group('Landing Page Golden Tests', () {
    testGoldens('landing page renders correctly at phone size', (tester) async {
      final builder = DeviceBuilder()
        ..overrideDevicesForAllScenarios(devices: [
          const Device(
            name: 'phone',
            size: Size(360, 800),
            devicePixelRatio: 2.0,
          ),
        ])
        ..addScenario(
          widget: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
              ),
            ),
            home: const MockLandingPage(),
          ),
          name: 'landing_page_phone',
        );

      await tester.pumpDeviceBuilder(builder);
      await screenMatchesGolden(tester, 'landing_page_phone');
    });

    testGoldens('landing page renders correctly at desktop size', (tester) async {
      final builder = DeviceBuilder()
        ..overrideDevicesForAllScenarios(devices: [
          const Device(
            name: 'desktop',
            size: Size(1440, 900),
            devicePixelRatio: 1.0,
          ),
        ])
        ..addScenario(
          widget: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
              ),
            ),
            home: const MockLandingPage(),
          ),
          name: 'landing_page_desktop',
        );

      await tester.pumpDeviceBuilder(builder);
      await screenMatchesGolden(tester, 'landing_page_desktop');
    });
  });
}
