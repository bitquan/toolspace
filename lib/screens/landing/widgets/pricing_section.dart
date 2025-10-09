/// Pricing Section - Display plans with CTAs
library;

import 'package:flutter/material.dart';
import '../../../billing/billing_service.dart';
import '../../../billing/billing_types.dart';

class PricingSection extends StatelessWidget {
  const PricingSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'Simple, Transparent Pricing',
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Start free, upgrade when you need more power',
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: BillingService().getAllPlans(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (snapshot.hasError || !snapshot.hasData) {
                  return const Text('Failed to load pricing');
                }

                final plans = snapshot.data!;
                return Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  alignment: WrapAlignment.center,
                  children: plans
                      .map((plan) => _buildPlanCard(context, plan))
                      .toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, Map<String, dynamic> plan) {
    return _AnimatedPricingCard(plan: plan);
  }
}

/// Animated pricing card with hover effects and popular badge
class _AnimatedPricingCard extends StatefulWidget {
  final Map<String, dynamic> plan;

  const _AnimatedPricingCard({required this.plan});

  @override
  State<_AnimatedPricingCard> createState() => _AnimatedPricingCardState();
}

class _AnimatedPricingCardState extends State<_AnimatedPricingCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final planId = PlanId.fromString(widget.plan['id'] as String);
    final priceData = widget.plan['price'] as Map<String, dynamic>;
    final amount = priceData['amount'] as int;
    final displayPrice =
        amount == 0 ? 'Free' : '\$${(amount / 100).toStringAsFixed(0)}';
    final interval = priceData['interval'] as String?;
    final features = (widget.plan['features'] as List<dynamic>).cast<String>();
    final isPopular = planId == PlanId.pro; // Pro plan is popular

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, _isHovered ? -8 : 0, 0),
        child: SizedBox(
          width: 320,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Card(
                elevation: _isHovered ? 16 : (isPopular ? 12 : 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isPopular
                        ? Colors.blue.withValues(alpha: 0.5)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: isPopular
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.blue.withValues(alpha: 0.05),
                              Colors.purple.withValues(alpha: 0.05),
                            ],
                          )
                        : null,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Text(
                          widget.plan['name'] as String,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayPrice,
                              style: theme.textTheme.displayMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isPopular ? Colors.blue : null,
                              ),
                            ),
                            if (interval != null) ...[
                              const SizedBox(width: 4),
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  '/$interval',
                                  style: theme.textTheme.bodyLarge,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (amount > 0)
                          Text(
                            '7-day free trial',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        const SizedBox(height: 24),
                        ...features.map((feature) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color:
                                        isPopular ? Colors.blue : Colors.green,
                                    size: 20,
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
                          child: ElevatedButton(
                            onPressed: () {
                              if (planId == PlanId.free) {
                                Navigator.of(context).pushNamed('/auth/signup');
                              } else {
                                Navigator.of(context).pushNamed(
                                  '/auth/signup',
                                  arguments: planId,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: isPopular ? Colors.blue : null,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              planId == PlanId.free
                                  ? 'Get Started Free'
                                  : 'Start Free Trial',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isPopular ? Colors.white : null,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (isPopular)
                Positioned(
                  top: -12,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.blue, Colors.purple],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '🔥 MOST POPULAR',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
