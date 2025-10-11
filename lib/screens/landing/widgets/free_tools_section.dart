import 'package:flutter/material.dart';

class FreeToolsSection extends StatelessWidget {
  const FreeToolsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: Column(
        children: [
          // Section Header
          Text(
            'Powerful Tools for Everyday Tasks',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            'Use these professional tools 5 times per month without signing up. No credit card required.',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white70,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),

          // Free Tools Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 1200
                  ? 4
                  : constraints.maxWidth > 800
                      ? 3
                      : constraints.maxWidth > 600
                          ? 2
                          : 1;

              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                childAspectRatio: 1.1,
                children: [
                  _buildFreeToolCard(
                    context,
                    title: 'Text Tools',
                    description: 'Case conversion, cleaning, formatting, word count',
                    icon: Icons.text_fields,
                    color: const Color(0xFF3B82F6),
                    route: '/tools/text-tools',
                    badgeText: '5/month',
                  ),
                  _buildFreeToolCard(
                    context,
                    title: 'JSON Doctor',
                    description: 'Validate, format, and repair JSON instantly',
                    icon: Icons.healing,
                    color: const Color(0xFF10B981),
                    route: '/tools/json-doctor',
                    badgeText: '5/month',
                  ),
                  _buildFreeToolCard(
                    context,
                    title: 'QR Code Generator',
                    description: 'Create QR codes for URLs, text, WiFi, and more',
                    icon: Icons.qr_code,
                    color: const Color(0xFFEC4899),
                    route: '/tools/qr-maker',
                    badgeText: '5/month',
                  ),
                  _buildFreeToolCard(
                    context,
                    title: 'Password Generator',
                    description: 'Generate secure passwords with custom rules',
                    icon: Icons.password,
                    color: const Color(0xFFF59E0B),
                    route: '/tools/password-gen',
                    badgeText: '5/month',
                  ),
                  _buildFreeToolCard(
                    context,
                    title: 'Text Diff Checker',
                    description: 'Compare documents and highlight differences',
                    icon: Icons.compare_arrows,
                    color: const Color(0xFF8B5CF6),
                    route: '/tools/text-diff',
                    badgeText: '5/month',
                  ),
                  _buildFreeToolCard(
                    context,
                    title: 'Unit Converter',
                    description: 'Convert between all measurement units instantly',
                    icon: Icons.straighten,
                    color: const Color(0xFF06B6D4),
                    route: '/tools/unit-converter',
                    badgeText: '5/month',
                  ),
                  _buildFreeToolCard(
                    context,
                    title: 'Time Zone Converter',
                    description: 'Convert timestamps and time zones worldwide',
                    icon: Icons.schedule,
                    color: const Color(0xFFF97316),
                    route: '/tools/time-convert',
                    badgeText: '5/month',
                  ),
                  _buildFreeToolCard(
                    context,
                    title: 'Regex Tester',
                    description: 'Test regular expressions with live matching',
                    icon: Icons.pattern,
                    color: const Color(0xFFA855F7),
                    route: '/tools/regex-tester',
                    badgeText: '5/month',
                  ),
                  _buildFreeToolCard(
                    context,
                    title: 'ID Generator',
                    description: 'Generate UUIDs, NanoIDs, and custom identifiers',
                    icon: Icons.fingerprint,
                    color: const Color(0xFF14B8A6),
                    route: '/tools/id-gen',
                    badgeText: '5/month',
                  ),
                  _buildFreeToolCard(
                    context,
                    title: 'Codec Lab',
                    description: 'Encode/decode Base64, URL, HTML, and more',
                    icon: Icons.code,
                    color: const Color(0xFF6366F1),
                    route: '/tools/codec-lab',
                    badgeText: '5/month',
                  ),
                  _buildFreeToolCard(
                    context,
                    title: 'CSV Cleaner',
                    description: 'Clean, format, and validate CSV files',
                    icon: Icons.table_rows,
                    color: const Color(0xFF0EA5E9),
                    route: '/tools/csv-cleaner',
                    badgeText: '5/month',
                  ),
                  _buildFreeToolCard(
                    context,
                    title: 'Color Palette Extractor',
                    description: 'Extract dominant colors from any image',
                    icon: Icons.palette,
                    color: const Color(0xFFEF4444),
                    route: '/tools/palette-extractor',
                    badgeText: '5/month',
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 48),

          // CTA for More Tools
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purple.withValues(alpha: 0.1),
                  Colors.blue.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.workspace_premium,
                  size: 48,
                  color: Colors.amber,
                ),
                const SizedBox(height: 16),
                Text(
                  'Ready for More?',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Access 24+ professional tools with advanced features, file processing, and unlimited usage.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pushNamed('/dashboard'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      ),
                      child: const Text('View All Tools'),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pushNamed('/auth/signup'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      ),
                      child: const Text('Sign Up Free'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFreeToolCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required String route,
    String? badgeText,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.of(context).pushNamed(route),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.1),
                color.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 28,
                      ),
                    ),
                    if (badgeText != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: color.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          badgeText,
                          style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'Try Now',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward,
                      color: color,
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
