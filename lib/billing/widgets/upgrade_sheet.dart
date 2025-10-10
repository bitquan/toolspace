/// Upgrade Sheet - modal with plan comparison cards.
///
/// Neo-Playground style with glassmorphism, gradients, and playful animations.
/// Loads plans from pricing.json and creates Stripe checkout sessions.
library;

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../billing_service.dart';
import '../billing_types.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/widgets/email_verification_dialog.dart';

class UpgradeSheet extends StatefulWidget {
  final BillingService billingService;
  final PlanId currentPlan;
  final String? successUrl;
  final String? cancelUrl;

  const UpgradeSheet({
    super.key,
    required this.billingService,
    required this.currentPlan,
    this.successUrl,
    this.cancelUrl,
  });

  @override
  State<UpgradeSheet> createState() => _UpgradeSheetState();

  static Future<void> show(
    BuildContext context, {
    required BillingService billingService,
    required PlanId currentPlan,
    String? successUrl,
    String? cancelUrl,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UpgradeSheet(
        billingService: billingService,
        currentPlan: currentPlan,
        successUrl: successUrl,
        cancelUrl: cancelUrl,
      ),
    );
  }
}

class _UpgradeSheetState extends State<UpgradeSheet> {
  List<Map<String, dynamic>>? _plans;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    try {
      final plans = await widget.billingService.getAllPlans();
      setState(() {
        _plans = plans;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load plans: $e';
        _loading = false;
      });
    }
  }

  Future<void> _upgradeToPlan(PlanId planId) async {
    if (planId == PlanId.free) return;

    // Check if user is authenticated and email is verified
    final authService = AuthService();
    final currentUser = authService.currentUser;

    if (currentUser == null) {
      _showError('Please sign in to upgrade your plan');
      return;
    }

    // Note: Stripe checkout works in both debug and production modes
    // The debug check has been removed to allow testing with live Stripe keys

    if (!currentUser.emailVerified) {
      // Show email verification dialog
      await EmailVerificationDialog.show(
        context,
        onVerified: () => _proceedToCheckout(planId),
        authService: authService,
      );
      return;
    }

    await _proceedToCheckout(planId);
  }

  Future<void> _proceedToCheckout(PlanId planId) async {
    try {
      final baseUrl = Uri.base.toString();
      final successUrl = widget.successUrl ?? '$baseUrl#/billing/success';
      final cancelUrl = widget.cancelUrl ?? '$baseUrl#/billing/cancel';

      print('DEBUG: Calling createCheckoutSession with planId: ${planId.id}');
      print('DEBUG: successUrl: $successUrl');
      print('DEBUG: cancelUrl: $cancelUrl');

      final result = await widget.billingService.createCheckoutSession(
        planId: planId,
        successUrl: successUrl,
        cancelUrl: cancelUrl,
      );

      print('DEBUG: Got result: $result');
      final checkoutUrl = result['url'] as String;
      print('DEBUG: checkoutUrl: $checkoutUrl');
      final uri = Uri.parse(checkoutUrl);

      if (await canLaunchUrl(uri)) {
        print('DEBUG: Launching URL: $uri');
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (mounted) Navigator.of(context).pop();
      } else {
        print('DEBUG: Cannot launch URL: $uri');
        if (mounted) _showError('Could not open checkout page');
      }
    } catch (e) {
      print('DEBUG: Error in _proceedToCheckout: $e');
      if (mounted) {
        // Handle email verification error specifically
        if (e.toString().contains('Email verification required')) {
          _showError('Please verify your email address before upgrading');
        } else {
          _showError('Failed to create checkout session: $e');
        }
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        constraints: BoxConstraints(maxHeight: size.height * 0.85),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.surface.withValues(alpha: 0.95),
              theme.colorScheme.surface.withValues(alpha: 0.98),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.withValues(alpha: 0.2),
                          Colors.purple.withValues(alpha: 0.2),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.rocket_launch, size: 32),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Unlock More Power',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose a plan that fits your needs',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),

            // Plans
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(48),
                child: CircularProgressIndicator(),
              )
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              )
            else if (_plans != null)
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  shrinkWrap: false,
                  itemCount: _plans!.length,
                  itemBuilder: (context, index) =>
                      _buildPlanCard(_plans![index]),
                ),
              ),

            // Footer
            Padding(
              padding: const EdgeInsets.all(24),
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Maybe later'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan) {
    final theme = Theme.of(context);
    final planId = PlanId.fromString(plan['id'] as String);
    final isCurrent = planId == widget.currentPlan;
    final isPopular = plan['popular'] as bool? ?? false;

    final priceData = plan['price'] as Map<String, dynamic>;
    final amount = priceData['amount'] as int;
    final displayPrice =
        amount == 0 ? 'Free' : '\$${(amount / 100).toStringAsFixed(0)}';
    final interval = priceData['interval'] as String?;

    final features = (plan['features'] as List<dynamic>).cast<String>();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: isCurrent
            ? LinearGradient(
                colors: [
                  Colors.green.withValues(alpha: 0.15),
                  Colors.teal.withValues(alpha: 0.15),
                ],
              )
            : isPopular
                ? LinearGradient(
                    colors: [
                      Colors.blue.withValues(alpha: 0.1),
                      Colors.purple.withValues(alpha: 0.1),
                    ],
                  )
                : null,
        color: isCurrent || isPopular
            ? null
            : theme.colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrent
              ? Colors.green.withValues(alpha: 0.5)
              : isPopular
                  ? Colors.blue.withValues(alpha: 0.5)
                  : theme.colorScheme.outline.withValues(alpha: 0.3),
          width: isCurrent || isPopular ? 2 : 1,
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      plan['displayName'] as String,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isCurrent) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'CURRENT',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      displayPrice,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (interval != null) ...[
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '/$interval',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  plan['description'] as String,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 16),
                ...features.map(
                  (feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            feature,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (!isCurrent && planId != PlanId.free) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _upgradeToPlan(planId),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: isPopular
                            ? theme.colorScheme.primary
                            : theme.colorScheme.secondary,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        'Upgrade to ${plan['displayName']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isPopular && !isCurrent)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.blue, Colors.purple],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'POPULAR',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
