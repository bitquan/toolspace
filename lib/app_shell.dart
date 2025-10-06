import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'theme/playful_theme.dart';

class ToolspaceApp extends StatelessWidget {
  const ToolspaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Toolspace - Playful Tools Hub',
      theme: PlayfulTheme.lightTheme,
      darkTheme: PlayfulTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
