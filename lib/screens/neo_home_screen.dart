import 'package:flutter/material.dart';
import '../tools/text_tools/text_tools_screen.dart' deferred as text_tools;
import '../tools/file_merger/file_merger_screen.dart' deferred as file_merger;
import '../tools/json_doctor/json_doctor_screen.dart' deferred as json_doctor;
import '../tools/text_diff/text_diff_screen.dart' deferred as text_diff;
import '../tools/qr_maker/qr_maker_screen.dart' deferred as qr_maker;
import '../tools/url_short/url_short_screen.dart' deferred as url_short;
import '../tools/codec_lab/codec_lab_screen.dart' deferred as codec_lab;
import '../tools/time_convert/time_convert_screen.dart'
    deferred as time_convert;
import '../tools/regex_tester/regex_tester_screen.dart'
    deferred as regex_tester;
import '../tools/id_gen/id_gen_screen.dart' deferred as id_gen;
import '../tools/palette_extractor/palette_extractor_screen.dart'
    deferred as palette_extractor;
import '../tools/md_to_pdf/md_to_pdf_screen.dart' deferred as md_to_pdf;
import '../tools/csv_cleaner/csv_cleaner_screen.dart' deferred as csv_cleaner;
import '../tools/image_resizer/image_resizer_screen.dart'
    deferred as image_resizer;
import '../tools/password_gen/password_gen_screen.dart'
    deferred as password_gen;
import '../tools/json_flatten/json_flatten_screen.dart'
    deferred as json_flatten;
import '../tools/unit_converter/unit_converter_screen.dart'
    deferred as unit_converter;
import '../core/ui/neo_playground_theme.dart';
import '../core/ui/animated_background.dart';
import '../core/ui/states.dart';
import '../core/widgets/tool_card.dart';
import '../core/services/perf_monitor.dart';
import '../billing/billing_service.dart';
import '../billing/billing_types.dart';
import '../billing/widgets/upgrade_sheet.dart';
import '../billing/widgets/manage_billing_button.dart';

class NeoHomeScreen extends StatefulWidget {
  const NeoHomeScreen({super.key});

  @override
  State<NeoHomeScreen> createState() => _NeoHomeScreenState();
}

class _NeoHomeScreenState extends State<NeoHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final BillingService _billingService = BillingService();
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Text',
    'Data',
    'Media',
    'Dev Tools',
  ];

  @override
  void initState() {
    super.initState();
    _billingService.startListening();
  }

  @override
  void dispose() {
    _billingService.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<_Tool> get _filteredTools {
    var tools = _tools;

    // Filter by search
    if (_searchQuery.isNotEmpty) {
      tools = tools.where((tool) {
        final query = _searchQuery.toLowerCase();
        return tool.title.toLowerCase().contains(query) ||
            tool.description.toLowerCase().contains(query);
      }).toList();
    }

    // Filter by category
    if (_selectedCategory != 'All') {
      tools =
          tools.where((tool) => tool.category == _selectedCategory).toList();
    }

    return tools;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Animated background
          const Positioned.fill(
            child: AnimatedBackground(),
          ),

          // Content
          SafeArea(
            child: CustomScrollView(
              slivers: [
                // App bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            // Logo
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: NeoPlaygroundTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: NeoPlaygroundTheme.glassShadow,
                              ),
                              child: const Icon(
                                Icons.apps_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Toolspace ⚙️',
                                    style: NeoPlaygroundTheme.headingLarge
                                        .copyWith(
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    'Your Playground for Creative Tools',
                                    style:
                                        NeoPlaygroundTheme.bodyMedium.copyWith(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.6)
                                          : Colors.black.withValues(alpha: 0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Navigation buttons
                            IconButton(
                              icon: const Icon(Icons.home_outlined),
                              tooltip: 'Landing Page',
                              onPressed: () =>
                                  Navigator.of(context).pushNamed('/'),
                              style: IconButton.styleFrom(
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.1),
                                foregroundColor:
                                    isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              icon: const Icon(Icons.login, size: 18),
                              label: const Text('Sign In'),
                              onPressed: () => Navigator.of(context)
                                  .pushNamed('/auth/signin'),
                              style: TextButton.styleFrom(
                                foregroundColor:
                                    NeoPlaygroundTheme.primaryPurple,
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Billing button
                            const _BillingButton(),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Search bar
                        GlassContainer(
                          borderRadius: 16,
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Search tools...',
                              hintStyle: TextStyle(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.4)
                                    : Colors.black.withValues(alpha: 0.4),
                              ),
                              prefixIcon: const Icon(
                                Icons.search_rounded,
                                color: NeoPlaygroundTheme.primaryPurple,
                              ),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear_rounded),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {
                                          _searchQuery = '';
                                        });
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Category filters
                        SizedBox(
                          height: 48,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _categories.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final category = _categories[index];
                              return CategoryChip(
                                label: category,
                                isSelected: _selectedCategory == category,
                                onTap: () {
                                  setState(() {
                                    _selectedCategory = category;
                                  });
                                },
                                color: _getCategoryColor(category),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Tools grid
                SliverPadding(
                  padding: const EdgeInsets.all(24.0),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 350,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      childAspectRatio: 0.85,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final tool = _filteredTools[index];
                        return TweenAnimationBuilder<double>(
                          duration: Duration(
                            milliseconds: 300 + (index * 50),
                          ),
                          tween: Tween(begin: 0.0, end: 1.0),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(0, 50 * (1 - value)),
                              child: Opacity(
                                opacity: value,
                                child: child,
                              ),
                            );
                          },
                          child: ToolCard(
                            id: tool.id,
                            title: tool.title,
                            description: tool.description,
                            icon: tool.icon,
                            accentColor: tool.color,
                            onTap: () => _navigateToTool(context, tool),
                          ),
                        );
                      },
                      childCount: _filteredTools.length,
                    ),
                  ),
                ),

                // Footer
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Center(
                      child: Text(
                        '${_filteredTools.length} tools available',
                        style: NeoPlaygroundTheme.caption.copyWith(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.4)
                              : Colors.black.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Text':
        return NeoPlaygroundTheme.primaryBlue;
      case 'Data':
        return NeoPlaygroundTheme.primaryPurple;
      case 'Media':
        return NeoPlaygroundTheme.accentPink;
      case 'Dev Tools':
        return NeoPlaygroundTheme.accentOrange;
      default:
        return NeoPlaygroundTheme.primaryPurple;
    }
  }

  Future<void> _navigateToTool(BuildContext context, _Tool tool) async {
    PerfMonitor.startRouteTimer(tool.id);

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const LoadingState(message: 'Loading tool...'),
    );

    try {
      // Load the deferred library
      final screen = await tool.loader();

      PerfMonitor.stopRouteTimer(tool.id);

      if (context.mounted) {
        // Remove loading indicator
        Navigator.of(context).pop();

        // Navigate to tool
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => screen,
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeOutCubic;

              var tween = Tween(begin: begin, end: end).chain(
                CurveTween(curve: curve),
              );

              var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: curve),
              );

              return FadeTransition(
                opacity: fadeAnimation,
                child: SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                ),
              );
            },
            transitionDuration: NeoPlaygroundTheme.normalAnimation,
          ),
        );
      }
    } catch (e) {
      PerfMonitor.logMetric('Route load error', e.toString());
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load ${tool.title}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// Tool data model
class _Tool {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final Future<Widget> Function() loader;
  final String category;

  _Tool({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.loader,
    required this.category,
  });
}

// Tools list
final List<_Tool> _tools = [
  _Tool(
    id: 'text-tools',
    title: 'Text Tools',
    description:
        'Case conversion, cleaning, JSON formatting, and more text utilities',
    icon: Icons.text_fields,
    loader: () async {
      await text_tools.loadLibrary();
      return text_tools.TextToolsScreen();
    },
    color: const Color(0xFF3B82F6),
    category: 'Text',
  ),
  _Tool(
    id: 'file-merger',
    title: 'File Merger',
    description: 'Merge PDFs and images into a single PDF file with ease',
    icon: Icons.merge_type,
    loader: () async {
      await file_merger.loadLibrary();
      return file_merger.FileMergerScreen();
    },
    color: const Color(0xFF8B5CF6),
    category: 'Data',
  ),
  _Tool(
    id: 'json-doctor',
    title: 'JSON Doctor',
    description: 'Validate, format, and repair JSON with instant feedback',
    icon: Icons.healing,
    loader: () async {
      await json_doctor.loadLibrary();
      return json_doctor.JsonDoctorScreen();
    },
    color: const Color(0xFF10B981),
    category: 'Dev Tools',
  ),
  _Tool(
    id: 'text-diff',
    title: 'Text Diff',
    description: 'Compare texts with highlighted differences line by line',
    icon: Icons.compare_arrows,
    loader: () async {
      await text_diff.loadLibrary();
      return text_diff.TextDiffScreen();
    },
    color: const Color(0xFFF59E0B),
    category: 'Text',
  ),
  _Tool(
    id: 'qr-maker',
    title: 'QR Maker',
    description: 'Generate QR codes instantly with customization options',
    icon: Icons.qr_code,
    loader: () async {
      await qr_maker.loadLibrary();
      return qr_maker.QrMakerScreen();
    },
    color: const Color(0xFFEC4899),
    category: 'Media',
  ),
  _Tool(
    id: 'url-short',
    title: 'URL Shortener',
    description: 'Create and manage short URLs with unique codes (dev-only)',
    icon: Icons.link,
    loader: () async {
      await url_short.loadLibrary();
      return url_short.UrlShortScreen();
    },
    color: const Color(0xFF06B6D4),
    category: 'Dev Tools',
  ),
  _Tool(
    id: 'codec-lab',
    title: 'Codec Lab',
    description: 'Base64, Hex, and URL encoding/decoding for text and files',
    icon: Icons.code,
    loader: () async {
      await codec_lab.loadLibrary();
      return codec_lab.CodecLabScreen();
    },
    color: const Color(0xFF6366F1),
    category: 'Dev Tools',
  ),
  _Tool(
    id: 'time-convert',
    title: 'Time Converter',
    description:
        'Convert timestamps between formats and parse natural language',
    icon: Icons.schedule,
    loader: () async {
      await time_convert.loadLibrary();
      return time_convert.TimeConvertScreen();
    },
    color: const Color(0xFFF97316),
    category: 'Data',
  ),
  _Tool(
    id: 'regex-tester',
    title: 'Regex Tester',
    description:
        'Test regex patterns with live match highlighting and capture groups',
    icon: Icons.pattern,
    loader: () async {
      await regex_tester.loadLibrary();
      return regex_tester.RegexTesterScreen();
    },
    color: const Color(0xFFA855F7),
    category: 'Dev Tools',
  ),
  _Tool(
    id: 'id-gen',
    title: 'ID Generator',
    description: 'Generate UUIDs (v4, v7) and NanoIDs with batch support',
    icon: Icons.fingerprint,
    loader: () async {
      await id_gen.loadLibrary();
      return id_gen.IdGenScreen();
    },
    color: const Color(0xFF14B8A6),
    category: 'Dev Tools',
  ),
  _Tool(
    id: 'palette-extractor',
    title: 'Palette Extractor',
    description: 'Extract dominant colors from images using k-means clustering',
    icon: Icons.palette,
    loader: () async {
      await palette_extractor.loadLibrary();
      return palette_extractor.PaletteExtractorScreen();
    },
    color: const Color(0xFFEF4444),
    category: 'Media',
  ),
  _Tool(
    id: 'md-to-pdf',
    title: 'Markdown to PDF',
    description: 'Convert markdown to PDF with themes and custom settings',
    icon: Icons.picture_as_pdf,
    loader: () async {
      await md_to_pdf.loadLibrary();
      return md_to_pdf.MdToPdfScreen();
    },
    color: const Color(0xFF8B5CF6),
    category: 'Data',
  ),
  _Tool(
    id: 'csv-cleaner',
    title: 'CSV Cleaner',
    description: 'Trim, dedupe, normalize CSV files with ease',
    icon: Icons.table_rows,
    loader: () async {
      await csv_cleaner.loadLibrary();
      return csv_cleaner.CsvCleanerScreen();
    },
    color: const Color(0xFF0EA5E9),
    category: 'Data',
  ),
  _Tool(
    id: 'image-resizer',
    title: 'Image Resizer',
    description: 'Resize and convert images with batch processing support',
    icon: Icons.photo_size_select_large,
    loader: () async {
      await image_resizer.loadLibrary();
      return image_resizer.ImageResizerScreen();
    },
    color: const Color(0xFFEC4899),
    category: 'Media',
  ),
  _Tool(
    id: 'password-gen',
    title: 'Password Generator',
    description: 'Generate secure passwords with entropy meter and rules',
    icon: Icons.password,
    loader: () async {
      await password_gen.loadLibrary();
      return password_gen.PasswordGenScreen();
    },
    color: const Color(0xFFF59E0B),
    category: 'Dev Tools',
  ),
  _Tool(
    id: 'json-flatten',
    title: 'JSON Flatten',
    description: 'Flatten nested JSON to CSV with field selection and preview',
    icon: Icons.table_chart,
    loader: () async {
      await json_flatten.loadLibrary();
      return json_flatten.JsonFlattenScreen();
    },
    color: const Color(0xFF6A1B9A),
    category: 'Data',
  ),
  _Tool(
    id: 'unit-converter',
    title: 'Unit Converter',
    description: 'Universal unit conversion with 8 categories and history',
    icon: Icons.straighten,
    loader: () async {
      await unit_converter.loadLibrary();
      return unit_converter.UnitConverterScreen();
    },
    color: const Color(0xFF10B981),
    category: 'Data',
  ),
];

/// Billing button widget - shows Upgrade or Manage Billing based on plan
class _BillingButton extends StatefulWidget {
  const _BillingButton();

  @override
  State<_BillingButton> createState() => _BillingButtonState();
}

class _BillingButtonState extends State<_BillingButton> {
  final BillingService _billingService = BillingService();

  @override
  void initState() {
    super.initState();
    _billingService.startListening();
  }

  @override
  void dispose() {
    _billingService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BillingProfile>(
      stream: _billingService.billingProfileStream,
      initialData: BillingProfile.free(),
      builder: (context, snapshot) {
        final profile = snapshot.data ?? BillingProfile.free();

        if (profile.planId == PlanId.free) {
          // Show Upgrade button for free users
          return TextButton.icon(
            onPressed: () {
              UpgradeSheet.show(
                context,
                billingService: _billingService,
                currentPlan: profile.planId,
              );
            },
            icon: const Icon(Icons.star_rounded, size: 20),
            label: const Text('Upgrade'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.amber,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          );
        } else {
          // Show Manage Billing for Pro/Pro+ users
          return ManageBillingButton(
            billingService: _billingService,
          );
        }
      },
    );
  }
}
