import 'package:flutter/material.dart';

/// Pricing page showcasing subscription tiers
class PricingScreen extends StatelessWidget {
  const PricingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pricing'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
              child: Column(
                children: [
                  Text(
                    'Choose your plan',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Start free, upgrade when you need more power',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Pricing cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 900;

                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _PricingCard(
                            key: const Key('pricing-free'),
                            title: 'Free',
                            price: '\$0',
                            period: 'forever',
                            features: const [
                              'Access to all basic tools',
                              'Browser-based processing',
                              'No credit card required',
                              'Community support',
                            ],
                            onSelect: () =>
                                Navigator.pushNamed(context, '/signup'),
                            buttonText: 'Get Started',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _PricingCard(
                            key: const Key('pricing-pro'),
                            title: 'Pro',
                            price: '\$9',
                            period: 'per month',
                            isPopular: true,
                            features: const [
                              'Everything in Free',
                              'Advanced tool features',
                              'Priority processing',
                              'Export to cloud storage',
                              'Priority email support',
                              'No watermarks',
                            ],
                            onSelect: () =>
                                Navigator.pushNamed(context, '/signup'),
                            buttonText: 'Upgrade to Pro',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _PricingCard(
                            key: const Key('pricing-pro-plus'),
                            title: 'Pro+',
                            price: '\$19',
                            period: 'per month',
                            features: const [
                              'Everything in Pro',
                              '2,000 heavy operations/day',
                              '100MB max file size',
                              'Batch processing (up to 100)',
                              'Priority queue processing',
                              'Priority email support',
                            ],
                            onSelect: () =>
                                Navigator.pushNamed(context, '/signup'),
                            buttonText: 'Upgrade to Pro+',
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        _PricingCard(
                          key: const Key('pricing-free'),
                          title: 'Free',
                          price: '\$0',
                          period: 'forever',
                          features: const [
                            'Access to all basic tools',
                            'Browser-based processing',
                            'No credit card required',
                            'Community support',
                          ],
                          onSelect: () =>
                              Navigator.pushNamed(context, '/signup'),
                          buttonText: 'Get Started',
                        ),
                        const SizedBox(height: 16),
                        _PricingCard(
                          key: const Key('pricing-pro'),
                          title: 'Pro',
                          price: '\$9',
                          period: 'per month',
                          isPopular: true,
                          features: const [
                            'Everything in Free',
                            'Advanced tool features',
                            'Priority processing',
                            'Export to cloud storage',
                            'Priority email support',
                            'No watermarks',
                          ],
                          onSelect: () =>
                              Navigator.pushNamed(context, '/signup'),
                          buttonText: 'Upgrade to Pro',
                        ),
                        const SizedBox(height: 16),
                        _PricingCard(
                          key: const Key('pricing-pro-plus'),
                          title: 'Pro+',
                          price: '\$19',
                          period: 'per month',
                          features: const [
                            'Everything in Pro',
                            '2,000 heavy operations/day',
                            '100MB max file size',
                            'Batch processing (up to 100)',
                            'Priority queue processing',
                            'Priority email support',
                          ],
                          onSelect: () =>
                              Navigator.pushNamed(context, '/signup'),
                          buttonText: 'Upgrade to Pro+',
                        ),
                      ],
                    );
                  }
                },
              ),
            ),

            const SizedBox(height: 48),

            // FAQ hint
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    'Have questions?',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'All plans include 30-day money-back guarantee',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
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

class _PricingCard extends StatelessWidget {
  final String title;
  final String price;
  final String period;
  final List<String> features;
  final VoidCallback onSelect;
  final String buttonText;
  final bool isPopular;

  const _PricingCard({
    super.key,
    required this.title,
    required this.price,
    required this.period,
    required this.features,
    required this.onSelect,
    required this.buttonText,
    this.isPopular = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: isPopular ? 8 : 2,
      color: isPopular ? colorScheme.primaryContainer : null,
      child: Stack(
        children: [
          if (isPopular)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: Text(
                  'POPULAR',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      price,
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        period,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ...features.map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 20,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              feature,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onSelect,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(buttonText),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
