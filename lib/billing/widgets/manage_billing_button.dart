/// Manage Billing Button - opens Stripe Customer Portal.
///
/// For Pro/Pro+ users to manage subscription, payment methods, invoices.

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../billing_service.dart';

class ManageBillingButton extends StatefulWidget {
  final BillingService billingService;
  final String? returnUrl;

  const ManageBillingButton({
    super.key,
    required this.billingService,
    this.returnUrl,
  });

  @override
  State<ManageBillingButton> createState() => _ManageBillingButtonState();
}

class _ManageBillingButtonState extends State<ManageBillingButton> {
  bool _loading = false;

  Future<void> _openPortal() async {
    setState(() => _loading = true);

    try {
      final returnUrl = widget.returnUrl ?? Uri.base.toString();
      final portalUrl = await widget.billingService.createPortalLink(returnUrl);

      if (!mounted) return;

      final uri = Uri.parse(portalUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (!mounted) return;
        _showError('Could not open billing portal');
      }
    } catch (e) {
      if (!mounted) return;
      _showError('Failed to open billing portal: $e');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
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
    return TextButton.icon(
      onPressed: _loading ? null : _openPortal,
      icon: _loading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.account_balance_wallet_outlined, size: 20),
      label: const Text('Manage Billing'),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
