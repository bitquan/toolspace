import 'package:flutter/material.dart';
import '../tools/text_tools/text_tools_screen.dart';
import '../tools/file_merger/file_merger_screen.dart';
import '../tools/json_doctor/json_doctor_screen.dart';
import '../tools/text_diff/text_diff_screen.dart';
import '../tools/qr_maker/qr_maker_screen.dart';
import '../tools/md_to_pdf/md_to_pdf_screen.dart';
import '../tools/csv_cleaner/csv_cleaner_screen.dart';
import '../tools/image_resizer/image_resizer_screen.dart';
import '../tools/password_gen/password_gen_screen.dart';
import '../tools/json_flatten/json_flatten_screen.dart';
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
id: 'md-to-pdf',
      name: 'Markdown to PDF',
      description: 'Convert markdown to PDF with themes and custom settings',
      icon: Icons.picture_as_pdf,
      screen: const MdToPdfScreen(),
      color: PlayfulTheme.toolColors[0],
    ),
id: 'csv-cleaner',
      name: 'CSV Cleaner',
      description: 'Trim, dedupe, normalize CSV files with ease',
      icon: Icons.table_rows,
      screen: const CsvCleanerScreen(),
      color: PlayfulTheme.toolColors[0],
    ),
    ToolItem(
      id: 'image-resizer',
      name: 'Image Resizer',
      description: 'Resize and convert images with batch processing support',
      icon: Icons.photo_size_select_large,
      screen: const ImageResizerScreen(),
      color: PlayfulTheme.toolColors[6 % PlayfulTheme.toolColors.length],
    ),
    ToolItem(
      id: 'password-gen',
      name: 'Password Generator',
      description: 'Generate secure passwords with entropy meter and rules',
      icon: Icons.password,
      screen: const PasswordGenScreen(),
      color: PlayfulTheme.toolColors[5 % PlayfulTheme.toolColors.length],
    ),
    ToolItem(
      id: 'json-flatten',
      name: 'JSON Flatten',
      description:
          'Flatten nested JSON to CSV with field selection and preview',
      icon: Icons.table_chart,
      screen: const JsonFlattenScreen(),
      color: const Color(0xFF6A1B9A),
    ),
];
}

