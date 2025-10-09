import 'package:flutter/material.dart';

/// Features marketing page showcasing Toolspace capabilities
class FeaturesScreen extends StatelessWidget {
  const FeaturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Features'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primaryContainer,
                    colorScheme.secondaryContainer,
                  ],
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Powerful Tools for Developers',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Everything you need to boost productivity, all in one place',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color:
                          colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Features grid
            Padding(
              padding: const EdgeInsets.all(24),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 900
                      ? 3
                      : constraints.maxWidth > 600
                          ? 2
                          : 1;

                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                    children: const [
                      _FeatureCard(
                        icon: Icons.code,
                        title: 'Developer Tools',
                        description:
                            'JSON formatting, regex testing, UUID generation, and more',
                      ),
                      _FeatureCard(
                        icon: Icons.merge_type,
                        title: 'File Operations',
                        description:
                            'Merge PDFs, convert formats, resize images effortlessly',
                      ),
                      _FeatureCard(
                        icon: Icons.security,
                        title: 'Secure & Private',
                        description:
                            'All processing happens in your browser. Your data never leaves',
                      ),
                      _FeatureCard(
                        icon: Icons.speed,
                        title: 'Lightning Fast',
                        description:
                            'Instant results with optimized performance',
                      ),
                      _FeatureCard(
                        icon: Icons.palette,
                        title: 'Design Tools',
                        description:
                            'Color palette extraction, QR codes, and visual utilities',
                      ),
                      _FeatureCard(
                        icon: Icons.cloud_off,
                        title: 'Works Offline',
                        description:
                            'Progressive Web App works without internet connection',
                      ),
                      _FeatureCard(
                        icon: Icons.dashboard_customize,
                        title: 'Clean Interface',
                        description:
                            'Modern Material Design 3 with intuitive navigation',
                      ),
                      _FeatureCard(
                        icon: Icons.update,
                        title: 'Always Fresh',
                        description:
                            'Regular updates with new tools and improvements',
                      ),
                      _FeatureCard(
                        icon: Icons.workspace_premium,
                        title: 'Pro Features',
                        description:
                            'Unlock advanced capabilities with premium plans',
                      ),
                    ],
                  );
                },
              ),
            ),

            // CTA section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(48),
              color: colorScheme.surfaceContainerHighest,
              child: Column(
                children: [
                  Text(
                    'Ready to boost your productivity?',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    key: const Key('features-cta-get-started'),
                    onPressed: () => Navigator.pushNamed(context, '/signup'),
                    icon: const Icon(Icons.rocket_launch),
                    label: const Text('Get Started Free'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
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

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
