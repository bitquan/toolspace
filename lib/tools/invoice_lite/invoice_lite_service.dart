/// Invoice Lite Service - Complete service layer for invoice operations
///
/// Provides CRUD operations, calculations, validation, billing integration,
/// and cross-tool data sharing for the Invoice Lite tool.
library;

import 'package:nanoid2/nanoid2.dart';
// ignore: unused_import
import '../../billing/billing_service.dart'; // Used for documentation
import '../../shared/cross_tool/share_envelope.dart';
import 'backend_adapter.dart';
import 'exceptions.dart';
import 'models/models.dart';
import 'money_fmt.dart';

/// Main service for Invoice Lite operations
class InvoiceLiteService {
  final InvoiceBackendAdapter _backend;
  final dynamic _billing; // BillingService or mock

  InvoiceLiteService({
    InvoiceBackendAdapter? backend,
    required dynamic billing,
  })  : _backend = backend ?? createInvoiceBackend(),
        _billing = billing;

  // =========================================================================
  // CORE API - Invoice CRUD & Calculations
  // =========================================================================

  /// Create a new draft invoice with optional prefilled business/client info
  InvoiceLite draft({
    BusinessInfo? business,
    ClientInfo? client,
  }) {
    final now = DateTime.now();
    final invoiceNumber = 'INV-${nanoid(length: 8).toUpperCase()}';

    return InvoiceLite(
      id: nanoid(),
      createdAt: now,
      businessName: business?.name ?? '',
      businessEmail: business?.email ?? '',
      businessAddress: business?.address,
      businessPhone: business?.phone,
      clientName: client?.name ?? '',
      clientEmail: client?.email ?? '',
      clientAddress: client?.address,
      invoiceNumber: invoiceNumber,
      invoiceDate: now,
      dueDate: now.add(const Duration(days: 30)), // Default: 30 days
      items: [],
      currency: 'USD',
      taxRate: 0,
      discountAmount: 0,
      discountPercent: 0,
    );
  }

  /// Add an item to the invoice
  InvoiceLite addItem(InvoiceLite invoice, InvoiceItem item) {
    _validateItem(item);

    final newItems = List<InvoiceItem>.from(invoice.items)..add(item);
    return invoice.copyWith(items: newItems);
  }

  /// Update an item at the specified index
  InvoiceLite updateItem(InvoiceLite invoice, int index, InvoiceItem item) {
    if (index < 0 || index >= invoice.items.length) {
      throw InvoiceValidationError(
        'Invalid item index',
        fieldErrors: {'index': 'Index $index out of range'},
      );
    }

    _validateItem(item);

    final newItems = List<InvoiceItem>.from(invoice.items);
    newItems[index] = item;
    return invoice.copyWith(items: newItems);
  }

  /// Remove an item at the specified index
  InvoiceLite removeItem(InvoiceLite invoice, int index) {
    if (index < 0 || index >= invoice.items.length) {
      throw InvoiceValidationError(
        'Invalid item index',
        fieldErrors: {'index': 'Index $index out of range'},
      );
    }

    final newItems = List<InvoiceItem>.from(invoice.items)..removeAt(index);
    return invoice.copyWith(items: newItems);
  }

  /// Apply discount to invoice (fixed amount or percentage)
  InvoiceLite applyDiscount(
    InvoiceLite invoice, {
    double fixed = 0,
    double percent = 0,
  }) {
    if (fixed < 0) {
      throw InvoiceValidationError(
        'Discount amount cannot be negative',
        fieldErrors: {'discountAmount': 'Must be >= 0'},
      );
    }

    if (percent < 0 || percent > 100) {
      throw InvoiceValidationError(
        'Discount percentage must be between 0 and 100',
        fieldErrors: {'discountPercent': 'Must be 0-100'},
      );
    }

    return invoice.copyWith(
      discountAmount: fixed,
      discountPercent: percent,
    );
  }

  /// Apply tax rate to invoice
  InvoiceLite applyTax(InvoiceLite invoice, {required double percent}) {
    if (percent < 0 || percent > 100) {
      throw InvoiceValidationError(
        'Tax rate must be between 0 and 100',
        fieldErrors: {'taxRate': 'Must be 0-100'},
      );
    }

    return invoice.copyWith(taxRate: percent);
  }

  /// Calculate all totals (subtotal, tax, discount, grand total)
  /// Note: This is primarily for explicit recalculation; getters handle this automatically
  InvoiceLite calculateTotals(InvoiceLite invoice) {
    // Totals are computed via getters, so this just validates and returns
    _validateInvoice(invoice);
    return invoice;
  }

  // =========================================================================
  // BACKEND OPERATIONS - PDF & Payment Links
  // =========================================================================

  /// Generate PDF and return its URL
  /// Requires billing entitlements (heavy op)
  Future<Uri> getInvoicePdfUrl(InvoiceLite invoice) async {
    // Check tool access
    await _checkToolAccess();

    // Check heavy op quota
    await _checkHeavyOpQuota();

    // Validate before generating
    _validateInvoice(invoice);

    try {
      final pdfUrl = await _backend.generatePdf(invoice);

      // Track usage
      await _billing.trackHeavyOp();

      return pdfUrl;
    } catch (e) {
      throw InvoiceValidationError('Failed to generate PDF: $e');
    }
  }

  /// Create a payment link for the invoice
  /// Requires billing entitlements (heavy op)
  Future<Uri> createPayLink(InvoiceLite invoice) async {
    // Check tool access
    await _checkToolAccess();

    // Check heavy op quota
    await _checkHeavyOpQuota();

    // Validate before creating payment link
    _validateInvoice(invoice);

    if (invoice.total <= 0) {
      throw InvoiceValidationError(
        'Cannot create payment link for zero or negative amount',
        fieldErrors: {'total': 'Must be > 0'},
      );
    }

    try {
      final payLink = await _backend.createPaymentLink(invoice);

      // Track usage
      await _billing.trackHeavyOp();

      return payLink;
    } catch (e) {
      throw InvoiceValidationError('Failed to create payment link: $e');
    }
  }

  // =========================================================================
  // CROSS-TOOL INTEGRATION - ShareEnvelope Import/Export
  // =========================================================================

  /// Import invoice data from a ShareEnvelope
  /// Supports: text/plain (client email/name), application/json (full invoice data)
  InvoiceLite importFromEnvelope(
    InvoiceLite draft,
    ShareEnvelope envelope,
  ) {
    switch (envelope.kind) {
      case ShareKind.text:
        // Import as client info
        final text = envelope.value as String;
        final lines =
            text.split('\n').where((l) => l.trim().isNotEmpty).toList();

        if (lines.isEmpty) return draft;

        // Try to parse email from first line
        final firstLine = lines.first.trim();
        final emailRegex = RegExp(r'[\w\.-]+@[\w\.-]+\.\w+');
        final emailMatch = emailRegex.firstMatch(firstLine);

        if (emailMatch != null) {
          return draft.copyWith(
            clientEmail: emailMatch.group(0)!,
            clientName: firstLine.replaceAll(emailMatch.group(0)!, '').trim(),
          );
        } else {
          return draft.copyWith(clientName: firstLine);
        }

      case ShareKind.json:
        // Import full or partial invoice data
        try {
          final data = envelope.value as Map<String, dynamic>;

          // If it's a full invoice, parse it
          if (data.containsKey('id') && data.containsKey('invoiceNumber')) {
            return InvoiceLite.fromJson(data);
          }

          // Otherwise, merge selected fields into draft
          return draft.copyWith(
            clientName: data['clientName'] as String? ?? draft.clientName,
            clientEmail: data['clientEmail'] as String? ?? draft.clientEmail,
            clientAddress:
                data['clientAddress'] as String? ?? draft.clientAddress,
            notes: data['notes'] as String? ?? draft.notes,
          );
        } catch (e) {
          throw InvoiceValidationError('Failed to parse JSON envelope: $e');
        }

      default:
        // Unsupported envelope kind
        throw InvoiceValidationError(
          'Unsupported envelope kind for import: ${envelope.kind}',
        );
    }
  }

  /// Export invoice as ShareEnvelope for cross-tool sharing
  /// Supports multiple export formats
  ShareEnvelope exportAsJson(InvoiceLite invoice) {
    return ShareEnvelope(
      kind: ShareKind.json,
      value: invoice.toJson(),
      meta: {
        'tool': 'invoice_lite',
        'invoiceNumber': invoice.invoiceNumber,
        'total': invoice.total,
        'currency': invoice.currency,
      },
    );
  }

  /// Export invoice payment link as text
  ShareEnvelope exportPayLink(Uri payLink, InvoiceLite invoice) {
    return ShareEnvelope(
      kind: ShareKind.text,
      value: payLink.toString(),
      meta: {
        'tool': 'invoice_lite',
        'type': 'payment_link',
        'invoiceNumber': invoice.invoiceNumber,
        'total': invoice.total,
        'currency': invoice.currency,
      },
    );
  }

  /// Export invoice PDF URL
  ShareEnvelope exportPdfUrl(Uri pdfUrl, InvoiceLite invoice) {
    return ShareEnvelope(
      kind: ShareKind.fileUrl,
      value: pdfUrl.toString(),
      meta: {
        'tool': 'invoice_lite',
        'type': 'pdf',
        'invoiceNumber': invoice.invoiceNumber,
        'mimeType': 'application/pdf',
      },
    );
  }

  // =========================================================================
  // FORMATTING & DISPLAY
  // =========================================================================

  /// Format a money amount with currency
  String formatMoney(double amount, String currency) {
    return MoneyFmt.format(amount, currency);
  }

  /// Get invoice summary text
  String getInvoiceSummary(InvoiceLite invoice) {
    final subtotal = MoneyFmt.format(invoice.subtotal, invoice.currency);
    final tax = MoneyFmt.format(invoice.taxAmount, invoice.currency);
    final discount = MoneyFmt.format(invoice.totalDiscount, invoice.currency);
    final total = MoneyFmt.format(invoice.total, invoice.currency);

    return '''
Invoice ${invoice.invoiceNumber}
From: ${invoice.businessName}
To: ${invoice.clientName}

Items: ${invoice.items.length}
Subtotal: $subtotal
Tax: $tax
Discount: $discount
Total: $total
''';
  }

  // =========================================================================
  // VALIDATION - Internal Helpers
  // =========================================================================

  void _validateItem(InvoiceItem item) {
    final errors = <String, String>{};

    if (item.description.trim().isEmpty) {
      errors['description'] = 'Description is required';
    }

    if (item.quantity < 0) {
      errors['quantity'] = 'Quantity must be non-negative';
    }

    if (item.unitPrice < 0) {
      errors['unitPrice'] = 'Unit price must be non-negative';
    }

    if (errors.isNotEmpty) {
      throw InvoiceValidationError('Invalid invoice item', fieldErrors: errors);
    }
  }

  void _validateInvoice(InvoiceLite invoice) {
    final errors = <String, String>{};

    if (invoice.businessName.trim().isEmpty) {
      errors['businessName'] = 'Business name is required';
    }

    if (invoice.businessEmail.trim().isEmpty) {
      errors['businessEmail'] = 'Business email is required';
    }

    if (invoice.clientName.trim().isEmpty) {
      errors['clientName'] = 'Client name is required';
    }

    if (invoice.clientEmail.trim().isEmpty) {
      errors['clientEmail'] = 'Client email is required';
    }

    if (!MoneyFmt.isValidCurrency(invoice.currency)) {
      errors['currency'] = 'Invalid currency code (must be 3-letter ISO-4217)';
    }

    if (invoice.items.isEmpty) {
      errors['items'] = 'Invoice must have at least one item';
    }

    if (errors.isNotEmpty) {
      throw InvoiceValidationError('Invalid invoice', fieldErrors: errors);
    }

    // Validate all items
    for (var i = 0; i < invoice.items.length; i++) {
      try {
        _validateItem(invoice.items[i]);
      } catch (e) {
        errors['items[$i]'] = e.toString();
      }
    }

    if (errors.isNotEmpty) {
      throw InvoiceValidationError('Invalid invoice', fieldErrors: errors);
    }
  }

  // =========================================================================
  // BILLING INTEGRATION - Internal Helpers
  // =========================================================================

  Future<void> _checkToolAccess() async {
    final result = await _billing.canAccessTool('invoice_lite');

    if (!result.allowed) {
      throw PaywallRequiredError(
        result.reason ?? 'Invoice Lite requires a paid plan',
        requiredPlan: result.suggestedPlan?.id ?? 'pro',
        currentPlan: result.planId?.id,
      );
    }
  }

  Future<void> _checkHeavyOpQuota() async {
    final result = await _billing.canPerformHeavyOp();

    if (!result.allowed) {
      throw PaywallRequiredError(
        result.reason ?? 'Daily operation limit reached',
        requiredPlan: result.suggestedPlan?.id ?? 'pro',
        currentPlan: result.planId?.id,
      );
    }
  }
}
