/// Plan Status Banner - shows current plan limits and usage with upgrade prompts.
///
/// Displays plan information, usage progress, and clear upgrade paths.
/// Neo-Playground style with glassmorphism and interactive elements.
library;

import 'package:flutter/material.dart';
import '../billing_types.dart';
import '../billing_service.dart';
import 'upgrade_sheet.dart';

class PlanStatusBanner extends StatefulWidget {
  final BillingProfile profile;
  final UsageRecord usage;
  final Entitlements entitlements;
  final BillingService billingService;
  final VoidCallback? onManageBilling;
  final bool showOnlyWhenLimited;
  final bool dismissible;

  const PlanStatusBanner({
    super.key,
    required this.profile,
    required this.usage,
    required this.entitlements,
    required this.billingService,
    this.onManageBilling,
    this.showOnlyWhenLimited = true,
    this.dismissible = false,
  });

  @override
  State<PlanStatusBanner> createState() => _PlanStatusBannerState();
}

class _PlanStatusBannerState extends State<PlanStatusBanner>
    with TickerProviderStateMixin {
  bool _dismissed = false;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
    _progressController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();

    // For free plan, always show. For paid plans, only show when approaching limits
    if (widget.showOnlyWhenLimited && widget.profile.planId != PlanId.free) {
      final heavyOpsUsed = widget.usage.heavyOps;
      final heavyOpsLimit = widget.entitlements.heavyOpsPerDay;
      final threshold = (heavyOpsLimit * 0.8).ceil(); // Show at 80% usage

      if (heavyOpsUsed < threshold) {
        return const SizedBox.shrink();
      }
    }

    final theme = Theme.of(context);
    final planColor = _getPlanColor();
    final heavyOpsUsed = widget.usage.heavyOps;
    final heavyOpsLimit = widget.entitlements.heavyOpsPerDay;
    final heavyOpsProgress = heavyOpsLimit > 0 ? heavyOpsUsed / heavyOpsLimit : 0.0;

    final isLimitReached = heavyOpsUsed >= heavyOpsLimit;
    final isApproachingLimit = heavyOpsProgress >= 0.8;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            planColor.withOpacity(0.1),
            planColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: planColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: planColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: planColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getPlanIcon(),
                        size: 16,
                        color: planColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _getPlanDisplayName(),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: planColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (widget.dismissible)
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      size: 20,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                    onPressed: () => setState(() => _dismissed = true),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Usage information
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Heavy Operations Today',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '$heavyOpsUsed / $heavyOpsLimit',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: isLimitReached
                            ? Colors.red
                            : isApproachingLimit
                                ? Colors.orange
                                : planColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Progress bar
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return LinearProgressIndicator(
                      value: heavyOpsProgress * _progressAnimation.value,
                      backgroundColor: theme.colorScheme.outline.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isLimitReached
                            ? Colors.red
                            : isApproachingLimit
                                ? Colors.orange
                                : planColor,
                      ),
                      borderRadius: BorderRadius.circular(4),
                      minHeight: 8,
                    );
                  },
                ),

                const SizedBox(height: 12),

                // Status message
                Text(
                  _getStatusMessage(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),

            // Action buttons
            if (_shouldShowUpgradeAction()) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _showUpgradeSheet,
                      icon: const Icon(Icons.rocket_launch, size: 18),
                      label: Text(_getUpgradeButtonText()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: planColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  if (widget.profile.planId != PlanId.free &&
                      widget.onManageBilling != null) ...[
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: widget.onManageBilling,
                      icon: const Icon(Icons.settings, size: 18),
                      label: const Text('Manage'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: planColor,
                        side: BorderSide(color: planColor),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getPlanColor() {
    switch (widget.profile.planId) {
      case PlanId.free:
        return Colors.grey;
      case PlanId.pro:
        return Colors.blue;
      case PlanId.proPlus:
        return Colors.purple;
    }
  }

  IconData _getPlanIcon() {
    switch (widget.profile.planId) {
      case PlanId.free:
        return Icons.free_breakfast;
      case PlanId.pro:
        return Icons.star;
      case PlanId.proPlus:
        return Icons.diamond;
    }
  }

  String _getPlanDisplayName() {
    switch (widget.profile.planId) {
      case PlanId.free:
        return 'Free Plan';
      case PlanId.pro:
        return 'Pro Plan';
      case PlanId.proPlus:
        return 'Pro+ Plan';
    }
  }

  String _getStatusMessage() {
    final heavyOpsUsed = widget.usage.heavyOps;
    final heavyOpsLimit = widget.entitlements.heavyOpsPerDay;
    final remaining = heavyOpsLimit - heavyOpsUsed;

    if (remaining <= 0) {
      return 'Daily limit reached. Operations will reset tomorrow.';
    } else if (remaining == 1) {
      return '1 operation remaining today.';
    } else if (remaining <= 3) {
      return '$remaining operations remaining today.';
    } else {
      return 'You have $remaining operations available today.';
    }
  }

  bool _shouldShowUpgradeAction() {
    if (widget.profile.planId == PlanId.proPlus) return false;

    final heavyOpsUsed = widget.usage.heavyOps;
    final heavyOpsLimit = widget.entitlements.heavyOpsPerDay;

    // Always show for free users, show for pro users when approaching limit
    return widget.profile.planId == PlanId.free ||
        (heavyOpsUsed / heavyOpsLimit) >= 0.8;
  }

  String _getUpgradeButtonText() {
    switch (widget.profile.planId) {
      case PlanId.free:
        return 'Upgrade to Pro';
      case PlanId.pro:
        return 'Upgrade to Pro+';
      case PlanId.proPlus:
        return 'Manage Plan';
    }
  }

  void _showUpgradeSheet() {
    UpgradeSheet.show(
      context,
      billingService: widget.billingService,
      currentPlan: widget.profile.planId,
    );
  }
}