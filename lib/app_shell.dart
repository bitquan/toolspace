import 'package:flutter/material.dart';
import 'screens/neo_home_screen.dart';
import 'screens/billing/billing_success_screen.dart';
import 'screens/billing/billing_cancel_screen.dart';
import 'core/ui/neo_playground_theme.dart';

class ToolspaceApp extends StatelessWidget {
  const ToolspaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Toolspace ⚙️ - Neo Playground',
      theme: NeoPlaygroundTheme.lightTheme(),
      darkTheme: NeoPlaygroundTheme.darkTheme(),
      themeMode: ThemeMode.system,
      home: const NeoHomeScreen(),
      routes: {
        '/billing/success': (context) => const BillingSuccessScreen(),
        '/billing/cancel': (context) => const BillingCancelScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
