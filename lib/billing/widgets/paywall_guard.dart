/// Paywall Guard - protects heavy tools with quota and plan checks.
///
/// Wraps tool UI and shows UpgradeSheet if:
/// - User plan doesn't allow tool access
/// - Daily heavy ops quota exceeded
/// - File size or batch size exceeds plan limits
///
/// Shows QuotaBanner when approaching limits.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../billing_service.dart';
import '../billing_types.dart';
import 'upgrade_sheet.dart';
import 'quota_banner.dart';

/// Tool permission configuration
class ToolPermission {
  final String toolId;
  final bool requiresHeavyOp;
  final int? fileSize;
  final int? batchSize;

  const ToolPermission({
    required this.toolId,
    this.requiresHeavyOp = false,
    this.fileSize,
    this.batchSize,
  });
}

class PaywallGuard extends StatefulWidget {
  final ToolPermission permission;
  final BillingService billingService;
  final Widget child;
  final Widget? blockedWidget;

  const PaywallGuard({
    super.key,
    required this.permission,
    required this.billingService,
    required this.child,
    this.blockedWidget,
  });

  @override
  State<PaywallGuard> createState() => _PaywallGuardState();
}

class _PaywallGuardState extends State<PaywallGuard> {
  bool _checking = true;
  bool _allowed = false;
  String? _blockReason;
  BillingProfile? _profile;
  UsageRecord? _usage;
  Entitlements? _entitlements;

  @override
  void initState() {
    super.initState();
    _checkAccess();
    _listenToChanges();
  }

  void _listenToChanges() {
    // Re-check when billing profile changes
    widget.billingService.billingProfileStream.listen((_) {
      if (mounted) _checkAccess();
    });

    // Re-check when usage changes
    widget.billingService.usageStream.listen((_) {
      if (mounted) _checkAccess();
    });
  }

  Future<void> _checkAccess() async {
    setState(() => _checking = true);

    try {
      // In debug mode, allow all access (emulator testing)
      if (kDebugMode) {
        // Free access for development/testing
        final profile = BillingProfile.free();
        final today = DateTime.now().toIso8601String().split('T')[0];
        final usage = UsageRecord.empty(today);
        final entitlements =
            await widget.billingService.getEntitlements(profile.planId);

        setState(() {
          _profile = profile;
          _usage = usage;
          _entitlements = entitlements;
          _allowed = true; // Always allow in debug mode
          _blockReason = null;
          _checking = false;
        });
        return;
      }

      // Get current state
      final profile = await widget.billingService.getBillingProfile();
      final usage = await widget.billingService.getTodayUsage();
      final entitlements =
          await widget.billingService.getEntitlements(profile.planId);

      setState(() {
        _profile = profile;
        _usage = usage;
        _entitlements = entitlements;
      });

      // Check tool access
      final toolCheck =
          await widget.billingService.canAccessTool(widget.permission.toolId);
      if (!toolCheck.allowed) {
        setState(() {
          _allowed = false;
          _blockReason = toolCheck.reason;
          _checking = false;
        });
        return;
      }

      // Check heavy op quota if required
      if (widget.permission.requiresHeavyOp) {
        final quotaCheck = await widget.billingService.canPerformHeavyOp();
        if (!quotaCheck.allowed) {
          setState(() {
            _allowed = false;
            _blockReason = quotaCheck.reason;
            _checking = false;
          });
          return;
        }
      }

      // Check file size if specified
      if (widget.permission.fileSize != null) {
        final fileSizeCheck = await widget.billingService
            .canProcessFileSize(widget.permission.fileSize!);
        if (!fileSizeCheck.allowed) {
          setState(() {
            _allowed = false;
            _blockReason = fileSizeCheck.reason;
            _checking = false;
          });
          return;
        }
      }

      // Check batch size if specified
      if (widget.permission.batchSize != null) {
        final batchCheck = await widget.billingService
            .canProcessBatchSize(widget.permission.batchSize!);
        if (!batchCheck.allowed) {
          setState(() {
            _allowed = false;
            _blockReason = batchCheck.reason;
            _checking = false;
          });
          return;
        }
      }

      // All checks passed
      setState(() {
        _allowed = true;
        _blockReason = null;
        _checking = false;
      });
    } catch (e) {
      setState(() {
        _allowed = false;
        _blockReason = 'Error checking permissions: $e';
        _checking = false;
      });
    }
  }

  void _showUpgradeSheet() {
    if (_profile == null) return;

    UpgradeSheet.show(
      context,
      billingService: widget.billingService,
      currentPlan: _profile!.planId,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (!_allowed) {
      return widget.blockedWidget ?? _buildBlockedUI();
    }

    // Show quota banner if approaching limits
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_shouldShowQuotaBanner())
          QuotaBanner(
            remaining: _getRemainingOps(),
            limit: _entitlements!.heavyOpsPerDay,
            currentPlan: _profile!.planId,
            onUpgrade: _showUpgradeSheet,
          ),
        Flexible(child: widget.child),
      ],
    );
  }

  bool _shouldShowQuotaBanner() {
    if (_profile == null || _usage == null || _entitlements == null) {
      return false;
    }

    if (!widget.permission.requiresHeavyOp) {
      return false;
    }

    final remaining = _getRemainingOps();
    final threshold = (_entitlements!.heavyOpsPerDay * 0.2).ceil();
    return remaining <= threshold;
  }

  int _getRemainingOps() {
    if (_usage == null || _entitlements == null) return 0;
    return (_entitlements!.heavyOpsPerDay - _usage!.heavyOps)
        .clamp(0, _entitlements!.heavyOpsPerDay);
  }

  Widget _buildBlockedUI() {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.orange.withValues(alpha: 0.2),
                    Colors.deepOrange.withValues(alpha: 0.2),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline,
                size: 64,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Upgrade Required',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _blockReason ?? 'This feature requires a higher plan',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _showUpgradeSheet,
              icon: const Icon(Icons.rocket_launch),
              label: const Text('View Plans'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
