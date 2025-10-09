import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:toolspace/screens/landing/landing_page.dart';
import 'package:toolspace/core/routes.dart';

import '../test_helpers/firebase_test_helper.dart';

/// Golden visual regression tests for landing page
///
/// Tests the landing page at two critical breakpoints:
/// - Phone: 360×800 (mobile viewport)
/// - Desktop: 1440×900 (desktop viewport)
///
/// Run with:
/// - Generate goldens: flutter test --update-goldens test/golden/landing_golden_test.dart
/// - Verify goldens: flutter test test/golden/landing_golden_test.dart
void main() {
  setUpAll(() async {
    setupFirebaseAuthMocks();
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
                brightness: Brightness.light,
              ),
            ),
            onGenerateRoute: ToolspaceRouter.generateRoute,
            home: const LandingPage(),
          ),
          name: 'landing_phone',
        );

      await tester.pumpDeviceBuilder(builder);

      await screenMatchesGolden(tester, 'landing_phone');
    });

    testGoldens('landing page renders correctly at desktop size',
        (tester) async {
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
                brightness: Brightness.light,
              ),
            ),
            onGenerateRoute: ToolspaceRouter.generateRoute,
            home: const LandingPage(),
          ),
          name: 'landing_desktop',
        );

      await tester.pumpDeviceBuilder(builder);

      await screenMatchesGolden(tester, 'landing_desktop');
    });
  });
}
