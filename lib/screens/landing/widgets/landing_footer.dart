/// Landing Footer - Footer with links and legal
library;

import 'package:flutter/material.dart';

class LandingFooter extends StatelessWidget {
  const LandingFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF8F9FA),
      ),
      child: Column(
        children: [
          // Footer links
          Wrap(
            spacing: 48,
            runSpacing: 32,
            alignment: WrapAlignment.center,
            children: [
              _buildFooterColumn(
                'Product',
                ['Features', 'Pricing', 'Roadmap', 'Changelog'],
              ),
              _buildFooterColumn(
                'Company',
                ['About', 'Blog', 'Careers', 'Contact'],
              ),
              _buildFooterColumn(
                'Legal',
                ['Privacy', 'Terms', 'Security', 'Cookies'],
              ),
              _buildFooterColumn(
                'Connect',
                ['Twitter', 'GitHub', 'Discord', 'Email'],
              ),
            ],
          ),

          const SizedBox(height: 48),

          // Copyright
          Text(
            '© ${DateTime.now().year} Neo-Playground Toolspace. All rights reserved.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterColumn(String title, List<String> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        ...links.map((link) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: TextButton(
                onPressed: () {}, // TODO: Implement navigation
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(link),
              ),
            )),
      ],
    );
  }
}
