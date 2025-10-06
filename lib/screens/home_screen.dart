import 'package:flutter/material.dart';
import '../tools/text_tools/text_tools_screen.dart';
import '../tools/file_merger/file_merger_screen.dart';
import '../tools/json_doctor/json_doctor_screen.dart';
import '../tools/text_diff/text_diff_screen.dart';
import '../tools/qr_maker/qr_maker_screen.dart';
import '../tools/time_convert/time_convert_screen.dart';
import '../widgets/animated_tools_grid.dart';
import '../theme/playful_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // Playful App Bar
          SliverAppBar.large(
            backgroundColor: theme.colorScheme.surface,
            foregroundColor: theme.colorScheme.onSurface,
            elevation: 0,
            floating: true,
            snap: true,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.build_circle,
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Toolspace',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Playful Tools Hub',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tools Grid
          SliverFillRemaining(
            child: AnimatedToolsGrid(
              tools: _tools,
              onToolTap: (tool) => _navigateToTool(context, tool),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToTool(BuildContext context, ToolItem tool) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => tool.screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: PlayfulTheme.mediumAnimation,
      ),
    );
  }

  static final List<ToolItem> _tools = [
    ToolItem(
      id: 'text-tools',
      name: 'Text Tools',
      description:
          'Case conversion, cleaning, JSON formatting, and more text utilities',
      icon: Icons.text_fields,
      screen: const TextToolsScreen(),
      color: PlayfulTheme.toolColors[0],
    ),
    ToolItem(
      id: 'file-merger',
      name: 'File Merger',
      description: 'Merge PDFs and images into a single PDF file with ease',
      icon: Icons.merge_type,
      screen: const FileMergerScreen(),
      color: PlayfulTheme.toolColors[1],
    ),
    // T-ToolsPack: Instant-win micro tools
    ToolItem(
      id: 'json-doctor',
      name: 'JSON Doctor',
      description: 'Validate, format, and repair JSON with instant feedback',
      icon: Icons.healing,
      screen: const JsonDoctorScreen(),
      color: PlayfulTheme.toolColors[2],
    ),
    ToolItem(
      id: 'text-diff',
      name: 'Text Diff',
      description: 'Compare texts with highlighted differences line by line',
      icon: Icons.compare_arrows,
      screen: const TextDiffScreen(),
      color: PlayfulTheme.toolColors[3],
    ),
    ToolItem(
      id: 'qr-maker',
      name: 'QR Maker',
      description: 'Generate QR codes instantly with customization options',
      icon: Icons.qr_code,
      screen: const QrMakerScreen(),
      color: PlayfulTheme.toolColors[4],
    ),
    ToolItem(
      id: 'time-convert',
      name: 'Time Converter',
      description: 'Convert timestamps between formats and parse natural language',
      icon: Icons.schedule,
      screen: const TimeConvertScreen(),
      color: const Color(0xFF9C27B0),
    ),
  ];
}
