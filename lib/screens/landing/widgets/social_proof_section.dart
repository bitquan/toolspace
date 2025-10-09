/// Social Proof Section - Trust badges, stats, and testimonials
library;

import 'package:flutter/material.dart';

class SocialProofSection extends StatelessWidget {
  const SocialProofSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          children: [
            // Stats Section
            _buildStatsSection(theme),
            const SizedBox(height: 80),

            // Testimonials Section
            _buildTestimonialsSection(theme),
            const SizedBox(height: 80),

            // Trust Badges
            _buildTrustBadges(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(ThemeData theme) {
    return Column(
      children: [
        Text(
          'Trusted by Developers Worldwide',
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),
        const Wrap(
          spacing: 48,
          runSpacing: 32,
          alignment: WrapAlignment.center,
          children: [
            _StatCard(
              value: '10K+',
              label: 'Active Users',
              icon: Icons.people,
              color: Colors.blue,
            ),
            _StatCard(
              value: '50K+',
              label: 'Tools Generated',
              icon: Icons.build_circle,
              color: Colors.purple,
            ),
            _StatCard(
              value: '4.8/5',
              label: 'User Rating',
              icon: Icons.star,
              color: Colors.orange,
            ),
            _StatCard(
              value: '99.9%',
              label: 'Uptime',
              icon: Icons.check_circle,
              color: Colors.green,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTestimonialsSection(ThemeData theme) {
    return Column(
      children: [
        Text(
          'What Developers Say',
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),
        const Wrap(
          spacing: 24,
          runSpacing: 24,
          alignment: WrapAlignment.center,
          children: [
            _TestimonialCard(
              quote:
                  'Toolspace has saved me hours every week. The palette extractor alone is worth it!',
              author: 'Sarah Chen',
              role: 'Frontend Developer',
              rating: 5,
            ),
            _TestimonialCard(
              quote:
                  'Best developer toolkit I\'ve used. Clean interface and powerful features.',
              author: 'Marcus Johnson',
              role: 'Full Stack Engineer',
              rating: 5,
            ),
            _TestimonialCard(
              quote:
                  'The file merger saved our project. Quick, reliable, and easy to use.',
              author: 'Priya Patel',
              role: 'DevOps Lead',
              rating: 5,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTrustBadges(ThemeData theme) {
    return Column(
      children: [
        Text(
          'Security & Reliability',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        const Wrap(
          spacing: 32,
          runSpacing: 24,
          alignment: WrapAlignment.center,
          children: [
            _TrustBadge(
              icon: Icons.security,
              label: 'SOC 2 Compliant',
              color: Colors.blue,
            ),
            _TrustBadge(
              icon: Icons.verified_user,
              label: 'SSL Encrypted',
              color: Colors.green,
            ),
            _TrustBadge(
              icon: Icons.cloud_done,
              label: '99.9% Uptime',
              color: Colors.purple,
            ),
            _TrustBadge(
              icon: Icons.support_agent,
              label: '24/7 Support',
              color: Colors.orange,
            ),
          ],
        ),
      ],
    );
  }
}

/// Stat card widget
class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 200,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 40, color: color),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: theme.textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Testimonial card widget
class _TestimonialCard extends StatelessWidget {
  final String quote;
  final String author;
  final String role;
  final int rating;

  const _TestimonialCard({
    required this.quote,
    required this.author,
    required this.role,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      width: 350,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: List.generate(
                  rating,
                  (index) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '"$quote"',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors
                        .primaries[author.hashCode % Colors.primaries.length],
                    child: Text(
                      author[0],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        author,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        role,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Trust badge widget
class _TrustBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _TrustBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Text(
            label,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
