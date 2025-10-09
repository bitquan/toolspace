import 'package:flutter/material.dart';
import 'core/ui/neo_playground_theme.dart';
import 'core/routes.dart';

class ToolspaceApp extends StatelessWidget {
  const ToolspaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Toolspace ⚙️ - Neo Playground',
      theme: NeoPlaygroundTheme.lightTheme(),
      darkTheme: NeoPlaygroundTheme.darkTheme(),
      themeMode: ThemeMode.system,
      onGenerateRoute: ToolspaceRouter.generateRoute,
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
    );
  }
}
