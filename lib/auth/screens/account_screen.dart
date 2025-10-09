import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import '../widgets/auth_glass_panel.dart';
import '../../billing/billing_service.dart';
import '../../billing/billing_types.dart';
import '../../billing/widgets/upgrade_sheet.dart';
import '../../billing/widgets/plan_status_banner.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late AuthService _authService;
  late BillingService _billingService;
  bool _isLoading = false;
  BillingProfile? _billingProfile;
  UsageRecord? _usageRecord;
  Entitlements? _entitlements;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    _billingService = BillingService();
    _loadBillingData();
  }

  @override
  void dispose() {
    _billingService.dispose();
    super.dispose();
  }

  Future<void> _loadBillingData() async {
    try {
      final profile = await _billingService.getBillingProfile();
      final usage = await _billingService.getTodayUsage();
      final entitlements =
          await _billingService.getEntitlements(profile.planId);

      if (mounted) {
        setState(() {
          _billingProfile = profile;
          _usageRecord = usage;
          _entitlements = entitlements;
        });
      }
    } catch (e) {
      // Handle error silently for now
    }
  }

  Future<void> _signOut() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              setState(() => _isLoading = true);

              await _authService.signOut();

              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/auth/signin');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Signed out successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendVerificationEmail() async {
    setState(() => _isLoading = true);

    try {
      await _authService.sendEmailVerification();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email sent!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _openBillingPortal() async {
    setState(() => _isLoading = true);

    try {
      final baseUrl = Uri.base.toString();
      final returnUrl = '$baseUrl#/account';
      final portalUrl = await _billingService.createPortalLink(returnUrl);

      // Copy URL to clipboard and show feedback
      await Clipboard.setData(ClipboardData(text: portalUrl));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Billing portal URL copied to clipboard!'),
            backgroundColor: Colors.blue,
            action: SnackBarAction(
              label: 'Open',
              textColor: Colors.white,
              onPressed: () {
                // In a real app, you'd use url_launcher here
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening billing portal: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showUpgradeSheet() {
    if (_billingProfile != null) {
      UpgradeSheet.show(
        context,
        billingService: _billingService,
        currentPlan: _billingProfile!.planId,
      );
    }
  }

  String _getPlanDisplayName(PlanId planId) {
    switch (planId) {
      case PlanId.free:
        return 'Free Plan';
      case PlanId.pro:
        return 'Pro Plan';
      case PlanId.proPlus:
        return 'Pro+ Plan';
    }
  }

  Color _getPlanColor(PlanId planId) {
    switch (planId) {
      case PlanId.free:
        return Colors.grey;
      case PlanId.pro:
        return Colors.blue;
      case PlanId.proPlus:
        return Colors.purple;
    }
  }

  String _getStatusDisplayName(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.free:
        return 'Free';
      case SubscriptionStatus.active:
        return 'Active';
      case SubscriptionStatus.trialing:
        return 'Trial';
      case SubscriptionStatus.pastDue:
        return 'Past Due';
      case SubscriptionStatus.canceled:
        return 'Canceled';
      case SubscriptionStatus.unpaid:
        return 'Unpaid';
      case SubscriptionStatus.incomplete:
        return 'Incomplete';
      case SubscriptionStatus.incompleteExpired:
        return 'Incomplete Expired';
    }
  }

  Color _getStatusColor(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.free:
      case SubscriptionStatus.active:
      case SubscriptionStatus.trialing:
        return Colors.green;
      case SubscriptionStatus.pastDue:
      case SubscriptionStatus.unpaid:
        return Colors.orange;
      case SubscriptionStatus.canceled:
      case SubscriptionStatus.incomplete:
      case SubscriptionStatus.incompleteExpired:
        return Colors.red;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF1A1A2E),
                    const Color(0xFF16213E),
                    const Color(0xFF0F3460),
                  ]
                : [
                    const Color(0xFFE8F4FD),
                    const Color(0xFFF3E8FF),
                    const Color(0xFFFFE8F3),
                  ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Profile section
                AuthGlassPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  theme.colorScheme.primary,
                                  theme.colorScheme.secondary,
                                ],
                              ),
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 32,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Account Information',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                Text(
                                  'Manage your Toolspace account',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Email
                      _buildInfoRow(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value:
                            _authService.currentUser?.email ?? 'Not available',
                        context: context,
                      ),
                      const SizedBox(height: 16),

                      // Email verification status
                      _buildInfoRow(
                        icon: _authService.isEmailVerified
                            ? Icons.verified_outlined
                            : Icons.warning_outlined,
                        label: 'Email Status',
                        value: _authService.isEmailVerified
                            ? 'Verified'
                            : 'Not Verified',
                        context: context,
                        valueColor: _authService.isEmailVerified
                            ? Colors.green
                            : Colors.orange,
                        trailing: !_authService.isEmailVerified
                            ? TextButton(
                                onPressed:
                                    _isLoading ? null : _sendVerificationEmail,
                                child: const Text('Verify'),
                              )
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Account type
                      _buildInfoRow(
                        icon: Icons.account_circle_outlined,
                        label: 'Account Type',
                        value: _authService.isAnonymous
                            ? 'Anonymous'
                            : 'Registered',
                        context: context,
                      ),
                      const SizedBox(height: 16),

                      // Creation date
                      _buildInfoRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Member Since',
                        value: _authService.currentUser?.metadata.creationTime
                                ?.toString()
                                .split(' ')[0] ??
                            'Unknown',
                        context: context,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Plan Status Banner
                if (_billingProfile != null &&
                    _usageRecord != null &&
                    _entitlements != null)
                  PlanStatusBanner(
                    profile: _billingProfile!,
                    usage: _usageRecord!,
                    entitlements: _entitlements!,
                    billingService: _billingService,
                    onManageBilling: _billingProfile!.planId != PlanId.free
                        ? _openBillingPortal
                        : null,
                    showOnlyWhenLimited: false,
                    dismissible: false,
                  ),

                const SizedBox(height: 24),

                // Billing Management section
                AuthGlassPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.credit_card_outlined,
                            size: 24,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Billing & Subscription',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_billingProfile != null) ...[
                        // Current plan
                        _buildInfoRow(
                          icon: Icons.stars_outlined,
                          label: 'Current Plan',
                          value: _getPlanDisplayName(_billingProfile!.planId),
                          context: context,
                          valueColor: _getPlanColor(_billingProfile!.planId),
                        ),
                        const SizedBox(height: 16),

                        // Subscription status
                        if (_billingProfile!.planId != PlanId.free) ...[
                          _buildInfoRow(
                            icon: Icons.info_outline,
                            label: 'Status',
                            value:
                                _getStatusDisplayName(_billingProfile!.status),
                            context: context,
                            valueColor:
                                _getStatusColor(_billingProfile!.status),
                          ),
                          const SizedBox(height: 16),

                          // Next billing date
                          if (_billingProfile!.currentPeriodEnd != null)
                            _buildInfoRow(
                              icon: Icons.schedule_outlined,
                              label: 'Next Billing',
                              value: _formatDate(
                                  _billingProfile!.currentPeriodEnd!),
                              context: context,
                            ),
                        ],

                        const SizedBox(height: 20),

                        // Action buttons
                        Row(
                          children: [
                            if (_billingProfile!.planId == PlanId.free) ...[
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _showUpgradeSheet,
                                  icon:
                                      const Icon(Icons.rocket_launch, size: 18),
                                  label: const Text('Upgrade Plan'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ] else ...[
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _openBillingPortal,
                                  icon: const Icon(Icons.settings, size: 18),
                                  label: const Text('Manage Billing'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _showUpgradeSheet,
                                  icon: const Icon(Icons.upgrade, size: 18),
                                  label: const Text('Upgrade'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ] else ...[
                        Text(
                          'Loading billing information...',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Security Settings section
                AuthGlassPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.security_outlined,
                            size: 24,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Security Settings',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Password change button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  // TODO: Implement password change with reauth
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Password change coming soon!'),
                                    ),
                                  );
                                },
                          icon: const Icon(Icons.lock_outline, size: 18),
                          label: const Text('Change Password'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Sign out button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _signOut,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Sign Out',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required BuildContext context,
    Color? valueColor,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isDark ? Colors.white70 : Colors.black54,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.white60 : Colors.black45,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: valueColor ?? (isDark ? Colors.white : Colors.black87),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }
}
