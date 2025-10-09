/// Quota banner - shows remaining heavy ops with soft upsell.
///
/// Displays when user has operations remaining but approaching limit.
/// Neo-Playground style with glassmorphism.
library;

import 'package:flutter/material.dart';
import '../billing_types.dart';

class QuotaBanner extends StatefulWidget {
  final int remaining;
  final int limit;
  final PlanId currentPlan;
  final VoidCallback? onUpgrade;
  final bool dismissible;

  const QuotaBanner({
    super.key,
    required this.remaining,
    required this.limit,
    required this.currentPlan,
    this.onUpgrade,
    this.dismissible = true,
  });

  @override
  State<QuotaBanner> createState() => _QuotaBannerState();
}

class _QuotaBannerState extends State<QuotaBanner> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();

    // Only show when < 20% remaining
    final threshold = (widget.limit * 0.2).ceil();
    if (widget.remaining > threshold) return const SizedBox.shrink();

    // Don't show for Pro+ (highest tier)
    if (widget.currentPlan == PlanId.proPlus) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isWarning = widget.remaining <= 1;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isWarning
              ? [
                  Colors.orange.withValues(alpha: 0.15),
                  Colors.deepOrange.withValues(alpha: 0.15),
                ]
              : [
                  Colors.blue.withValues(alpha: 0.1),
                  Colors.purple.withValues(alpha: 0.1),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isWarning
              ? Colors.orange.withValues(alpha: 0.3)
              : Colors.blue.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isWarning
                ? Icons.warning_amber_rounded
                : Icons.info_outline_rounded,
            color: isWarning ? Colors.orange : Colors.blue,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.remaining == 0
                      ? 'Daily limit reached'
                      : '${widget.remaining} operation${widget.remaining == 1 ? '' : 's'} left today',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (widget.currentPlan == PlanId.free) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Upgrade to Pro for ${_getUpgradeLimit()} operations per day',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (widget.onUpgrade != null) ...[
            const SizedBox(width: 12),
            TextButton(
              onPressed: widget.onUpgrade,
              style: TextButton.styleFrom(
                foregroundColor: isWarning ? Colors.orange : Colors.blue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('Upgrade'),
            ),
          ],
          if (widget.dismissible) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: () => setState(() => _dismissed = true),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ],
      ),
    );
  }

  String _getUpgradeLimit() {
    switch (widget.currentPlan) {
      case PlanId.free:
        return '200';
      case PlanId.pro:
        return '2,000';
      case PlanId.proPlus:
        return 'unlimited';
    }
  }
}
