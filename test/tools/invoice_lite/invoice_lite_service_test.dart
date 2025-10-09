/// Comprehensive tests for Invoice Lite Service
/// Coverage target: ≥90%
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:toolspace/billing/billing_types.dart';
import 'package:toolspace/shared/cross_tool/share_envelope.dart';
import 'package:toolspace/tools/invoice_lite/backend_adapter.dart';
import 'package:toolspace/tools/invoice_lite/exceptions.dart';
import 'package:toolspace/tools/invoice_lite/invoice_lite_service.dart';
import 'package:toolspace/tools/invoice_lite/models/models.dart';
import 'package:toolspace/tools/invoice_lite/money_fmt.dart';

// Mock billing service for testing (duck-typed, not extending real BillingService)
class MockBillingService {
  bool _allowToolAccess = true;
  bool _allowHeavyOp = true;
  int trackHeavyOpCalls = 0;
  PlanId currentPlan = PlanId.free;

  void setToolAccess(bool allow, {PlanId? plan}) {
    _allowToolAccess = allow;
    if (plan != null) currentPlan = plan;
  }

  void setHeavyOpAccess(bool allow) {
    _allowHeavyOp = allow;
  }

  Future<EntitlementCheckResult> canAccessTool(String toolId) async {
    return EntitlementCheckResult(
      allowed: _allowToolAccess,
      reason: _allowToolAccess ? null : 'Tool access denied',
      planId: currentPlan,
      requiresUpgrade: !_allowToolAccess,
      suggestedPlan: PlanId.pro,
    );
  }

  Future<EntitlementCheckResult> canPerformHeavyOp() async {
    return EntitlementCheckResult(
      allowed: _allowHeavyOp,
      reason: _allowHeavyOp ? null : 'Daily limit reached',
      planId: currentPlan,
      requiresUpgrade: !_allowHeavyOp,
      suggestedPlan: PlanId.pro,
      currentUsage: _allowHeavyOp ? 0 : 10,
      limit: 10,
    );
  }

  Future<void> trackHeavyOp() async {
    trackHeavyOpCalls++;
  }
}

// Test backend adapter with instant responses
class TestBackendAdapter implements InvoiceBackendAdapter {
  @override
  Future<Uri> generatePdf(InvoiceLite invoice) async {
    return Uri.parse('https://test.com/pdfs/${invoice.id}.pdf');
  }

  @override
  Future<Uri> createPaymentLink(InvoiceLite invoice) async {
    return Uri.parse('https://checkout.test.com/pay/${invoice.id}');
  }
}

void main() {
  late InvoiceLiteService service;
  late MockBillingService mockBilling;
  late TestBackendAdapter testBackend;

  setUp(() {
    mockBilling = MockBillingService();
    testBackend = TestBackendAdapter();
    service = InvoiceLiteService(
      backend: testBackend,
      billing: mockBilling,
    );
  });

  group('Core API - CRUD Operations', () {
    test('draft() creates empty invoice with defaults', () {
      final invoice = service.draft();

      expect(invoice.id, isNotEmpty);
      expect(invoice.invoiceNumber, startsWith('INV-'));
      expect(invoice.items, isEmpty);
      expect(invoice.currency, 'USD');
      expect(invoice.taxRate, 0);
      expect(invoice.discountAmount, 0);
      expect(invoice.dueDate, isNotNull);
    });

    test('draft() prefills business and client info', () {
      final business = BusinessInfo(
        name: 'Test Corp',
        email: 'billing@test.com',
        address: '123 Test St',
      );
      final client = ClientInfo(
        name: 'Client Co',
        email: 'client@example.com',
      );

      final invoice = service.draft(business: business, client: client);

      expect(invoice.businessName, 'Test Corp');
      expect(invoice.businessEmail, 'billing@test.com');
      expect(invoice.businessAddress, '123 Test St');
      expect(invoice.clientName, 'Client Co');
      expect(invoice.clientEmail, 'client@example.com');
    });

    test('addItem() adds item to invoice', () {
      var invoice = service.draft();
      final item = InvoiceItem(
        description: 'Web Development',
        quantity: 10,
        unitPrice: 100,
      );

      invoice = service.addItem(invoice, item);

      expect(invoice.items.length, 1);
      expect(invoice.items.first.description, 'Web Development');
      expect(invoice.items.first.total, 1000);
    });

    test('addItem() validates item', () {
      final invoice = service.draft();
      final invalidItem = InvoiceItem(
        description: '',
        quantity: -1,
        unitPrice: -50,
      );

      expect(
        () => service.addItem(invoice, invalidItem),
        throwsA(isA<InvoiceValidationError>()),
      );
    });

    test('updateItem() updates item at index', () {
      var invoice = service.draft();
      invoice = service.addItem(
        invoice,
        InvoiceItem(description: 'Item 1', quantity: 1, unitPrice: 100),
      );

      final updated = InvoiceItem(
        description: 'Updated Item',
        quantity: 2,
        unitPrice: 150,
      );
      invoice = service.updateItem(invoice, 0, updated);

      expect(invoice.items.first.description, 'Updated Item');
      expect(invoice.items.first.quantity, 2);
      expect(invoice.items.first.total, 300);
    });

    test('updateItem() throws on invalid index', () {
      final invoice = service.draft();

      expect(
        () => service.updateItem(
          invoice,
          99,
          InvoiceItem(description: 'Test', quantity: 1, unitPrice: 1),
        ),
        throwsA(isA<InvoiceValidationError>()),
      );
    });

    test('removeItem() removes item at index', () {
      var invoice = service.draft();
      invoice = service.addItem(
        invoice,
        InvoiceItem(description: 'Item 1', quantity: 1, unitPrice: 100),
      );
      invoice = service.addItem(
        invoice,
        InvoiceItem(description: 'Item 2', quantity: 1, unitPrice: 200),
      );

      invoice = service.removeItem(invoice, 0);

      expect(invoice.items.length, 1);
      expect(invoice.items.first.description, 'Item 2');
    });

    test('removeItem() throws on invalid index', () {
      final invoice = service.draft();

      expect(
        () => service.removeItem(invoice, 0),
        throwsA(isA<InvoiceValidationError>()),
      );
    });
  });

  group('Calculations - Totals, Tax, Discount', () {
    test('calculates subtotal correctly', () {
      var invoice = service.draft();
      invoice = service.addItem(
        invoice,
        InvoiceItem(description: 'Item 1', quantity: 2, unitPrice: 50),
      );
      invoice = service.addItem(
        invoice,
        InvoiceItem(description: 'Item 2', quantity: 3, unitPrice: 100),
      );

      expect(invoice.subtotal, 400); // (2*50) + (3*100)
    });

    test('applyDiscount() with fixed amount', () {
      var invoice = service.draft();
      invoice = service.addItem(
        invoice,
        InvoiceItem(description: 'Item', quantity: 1, unitPrice: 100),
      );

      invoice = service.applyDiscount(invoice, fixed: 25);

      expect(invoice.discountAmount, 25);
      expect(invoice.totalDiscount, 25);
      expect(invoice.total, 75);
    });

    test('applyDiscount() with percentage', () {
      var invoice = service.draft();
      invoice = service.addItem(
        invoice,
        InvoiceItem(description: 'Item', quantity: 1, unitPrice: 100),
      );

      invoice = service.applyDiscount(invoice, percent: 10);

      expect(invoice.discountPercent, 10);
      expect(invoice.totalDiscount, 10); // 10% of 100
      expect(invoice.total, 90);
    });

    test('applyDiscount() validates negative values', () {
      final invoice = service.draft();

      expect(
        () => service.applyDiscount(invoice, fixed: -10),
        throwsA(isA<InvoiceValidationError>()),
      );

      expect(
        () => service.applyDiscount(invoice, percent: -5),
        throwsA(isA<InvoiceValidationError>()),
      );

      expect(
        () => service.applyDiscount(invoice, percent: 150),
        throwsA(isA<InvoiceValidationError>()),
      );
    });

    test('applyTax() applies tax rate', () {
      var invoice = service.draft();
      invoice = service.addItem(
        invoice,
        InvoiceItem(description: 'Item', quantity: 1, unitPrice: 100),
      );

      invoice = service.applyTax(invoice, percent: 10);

      expect(invoice.taxRate, 10);
      expect(invoice.taxAmount, 10); // 10% of 100
      expect(invoice.total, 110);
    });

    test('applyTax() validates rate range', () {
      final invoice = service.draft();

      expect(
        () => service.applyTax(invoice, percent: -5),
        throwsA(isA<InvoiceValidationError>()),
      );

      expect(
        () => service.applyTax(invoice, percent: 150),
        throwsA(isA<InvoiceValidationError>()),
      );
    });

    test('complex calculation: subtotal, discount, tax', () {
      var invoice = service.draft();

      // Add items: 200 + 300 = 500 subtotal
      invoice = service.addItem(
        invoice,
        InvoiceItem(description: 'Item 1', quantity: 2, unitPrice: 100),
      );
      invoice = service.addItem(
        invoice,
        InvoiceItem(description: 'Item 2', quantity: 3, unitPrice: 100),
      );

      // Apply 10% discount: 500 * 0.10 = 50
      invoice = service.applyDiscount(invoice, percent: 10);

      // Apply 8% tax on discounted amount: (500 - 50) * 0.08 = 36
      invoice = service.applyTax(invoice, percent: 8);

      expect(invoice.subtotal, 500);
      expect(invoice.totalDiscount, 50);
      expect(invoice.taxAmount, 36);
      expect(invoice.total, 486); // 500 - 50 + 36
      expect(invoice.balanceDue, 486);
    });

    test('high precision calculation edge case', () {
      var invoice = service.draft();
      invoice = service.addItem(
        invoice,
        InvoiceItem(description: 'Item', quantity: 3, unitPrice: 33.33),
      );

      invoice = service.applyTax(invoice, percent: 7.5);

      expect(invoice.subtotal, closeTo(99.99, 0.01));
      expect(invoice.taxAmount, closeTo(7.50, 0.01));
      expect(invoice.total, closeTo(107.49, 0.01));
    });

    test('zero quantity edge case', () {
      var invoice = service.draft();
      invoice = service.addItem(
        invoice,
        InvoiceItem(description: 'Free Item', quantity: 0, unitPrice: 100),
      );

      expect(invoice.subtotal, 0);
      expect(invoice.total, 0);
    });
  });

  group('Validation', () {
    test('calculateTotals() validates complete invoice', () {
      final business = BusinessInfo(
        name: 'Test Corp',
        email: 'test@test.com',
      );
      final client = ClientInfo(
        name: 'Client Co',
        email: 'client@test.com',
      );

      var invoice = service.draft(business: business, client: client);
      invoice = service.addItem(
        invoice,
        InvoiceItem(description: 'Item', quantity: 1, unitPrice: 100),
      );

      // Should not throw
      expect(() => service.calculateTotals(invoice), returnsNormally);
    });

    test('calculateTotals() fails on missing business info', () {
      var invoice = service.draft();
      invoice = service.addItem(
        invoice,
        InvoiceItem(description: 'Item', quantity: 1, unitPrice: 100),
      );

      expect(
        () => service.calculateTotals(invoice),
        throwsA(isA<InvoiceValidationError>()),
      );
    });

    test('calculateTotals() fails on missing items', () {
      final business = BusinessInfo(name: 'Test', email: 'test@test.com');
      final client = ClientInfo(name: 'Client', email: 'client@test.com');
      final invoice = service.draft(business: business, client: client);

      expect(
        () => service.calculateTotals(invoice),
        throwsA(isA<InvoiceValidationError>()),
      );
    });

    test('validates currency code format', () {
      final business = BusinessInfo(name: 'Test', email: 'test@test.com');
      final client = ClientInfo(name: 'Client', email: 'client@test.com');
      var invoice = service.draft(business: business, client: client);
      invoice = service.addItem(
        invoice,
        InvoiceItem(description: 'Item', quantity: 1, unitPrice: 100),
      );

      invoice = invoice.copyWith(currency: 'INVALID');

      expect(
        () => service.calculateTotals(invoice),
        throwsA(isA<InvoiceValidationError>()),
      );
    });
  });

  group('Backend Operations - PDF & Payment', () {
    test('getInvoicePdfUrl() returns PDF URL', () async {
      mockBilling.setToolAccess(true);
      mockBilling.setHeavyOpAccess(true);

      final business = BusinessInfo(name: 'Test', email: 'test@test.com');
      final client = ClientInfo(name: 'Client', email: 'client@test.com');
      var invoice = service.draft(business: business, client: client);
      invoice = service.addItem(
        invoice,
        InvoiceItem(description: 'Item', quantity: 1, unitPrice: 100),
      );

      final pdfUrl = await service.getInvoicePdfUrl(invoice);

      expect(pdfUrl.toString(), contains('pdf'));
      expect(mockBilling.trackHeavyOpCalls, 1);
    });

    test('createPayLink() returns payment URL', () async {
      mockBilling.setToolAccess(true);
      mockBilling.setHeavyOpAccess(true);

      final business = BusinessInfo(name: 'Test', email: 'test@test.com');
      final client = ClientInfo(name: 'Client', email: 'client@test.com');
      var invoice = service.draft(business: business, client: client);
      invoice = service.addItem(
        invoice,
        InvoiceItem(description: 'Item', quantity: 1, unitPrice: 100),
      );

      final payLink = await service.createPayLink(invoice);

      expect(payLink.toString(), contains('checkout'));
      expect(mockBilling.trackHeavyOpCalls, 1);
    });

    test('createPayLink() fails on zero total', () async {
      mockBilling.setToolAccess(true);
      mockBilling.setHeavyOpAccess(true);

      final business = BusinessInfo(name: 'Test', email: 'test@test.com');
      final client = ClientInfo(name: 'Client', email: 'client@test.com');
      var invoice = service.draft(business: business, client: client);
      invoice = service.addItem(
        invoice,
        InvoiceItem(description: 'Free', quantity: 0, unitPrice: 100),
      );

      expect(
        () => service.createPayLink(invoice),
        throwsA(isA<InvoiceValidationError>()),
      );
    });
  });

  group('Billing Integration - Paywall', () {
    test('PDF blocked by tool access', () async {
      mockBilling.setToolAccess(false);

      final business = BusinessInfo(name: 'Test', email: 'test@test.com');
      final client = ClientInfo(name: 'Client', email: 'client@test.com');
      var invoice = service.draft(business: business, client: client);
      invoice = service.addItem(
        invoice,
        InvoiceItem(description: 'Item', quantity: 1, unitPrice: 100),
      );

      expect(
        () => service.getInvoicePdfUrl(invoice),
        throwsA(isA<PaywallRequiredError>()),
      );
    });

    test('PDF blocked by heavy op quota', () async {
      mockBilling.setToolAccess(true);
      mockBilling.setHeavyOpAccess(false);

      final business = BusinessInfo(name: 'Test', email: 'test@test.com');
      final client = ClientInfo(name: 'Client', email: 'client@test.com');
      var invoice = service.draft(business: business, client: client);
      invoice = service.addItem(
        invoice,
        InvoiceItem(description: 'Item', quantity: 1, unitPrice: 100),
      );

      expect(
        () => service.getInvoicePdfUrl(invoice),
        throwsA(isA<PaywallRequiredError>()),
      );
    });

    test('PaywallRequiredError includes plan info', () async {
      mockBilling.setToolAccess(false, plan: PlanId.free);

      final business = BusinessInfo(name: 'Test', email: 'test@test.com');
      final client = ClientInfo(name: 'Client', email: 'client@test.com');
      var invoice = service.draft(business: business, client: client);
      invoice = service.addItem(
        invoice,
        InvoiceItem(description: 'Item', quantity: 1, unitPrice: 100),
      );

      try {
        await service.getInvoicePdfUrl(invoice);
        fail('Should throw PaywallRequiredError');
      } catch (e) {
        expect(e, isA<PaywallRequiredError>());
        final error = e as PaywallRequiredError;
        expect(error.requiredPlan, 'pro');
        expect(error.currentPlan, 'free');
      }
    });
  });

  group('Cross-Tool ShareEnvelope Integration', () {
    test('exportAsJson() creates JSON envelope', () {
      final business = BusinessInfo(name: 'Test', email: 'test@test.com');
      final client = ClientInfo(name: 'Client', email: 'client@test.com');
      var invoice = service.draft(business: business, client: client);
      invoice = service.addItem(
        invoice,
        InvoiceItem(description: 'Item', quantity: 1, unitPrice: 100),
      );

      final envelope = service.exportAsJson(invoice);

      expect(envelope.kind, ShareKind.json);
      expect(envelope.meta['tool'], 'invoice_lite');
      expect(envelope.meta['invoiceNumber'], invoice.invoiceNumber);
      expect(envelope.meta['total'], 100);
    });

    test('exportPayLink() creates text envelope', () {
      final business = BusinessInfo(name: 'Test', email: 'test@test.com');
      final client = ClientInfo(name: 'Client', email: 'client@test.com');
      final invoice = service.draft(business: business, client: client);
      final payLink = Uri.parse('https://checkout.stripe.com/test');

      final envelope = service.exportPayLink(payLink, invoice);

      expect(envelope.kind, ShareKind.text);
      expect(envelope.value, 'https://checkout.stripe.com/test');
      expect(envelope.meta['type'], 'payment_link');
    });

    test('exportPdfUrl() creates fileUrl envelope', () {
      final business = BusinessInfo(name: 'Test', email: 'test@test.com');
      final client = ClientInfo(name: 'Client', email: 'client@test.com');
      final invoice = service.draft(business: business, client: client);
      final pdfUrl = Uri.parse('https://storage.com/invoice.pdf');

      final envelope = service.exportPdfUrl(pdfUrl, invoice);

      expect(envelope.kind, ShareKind.fileUrl);
      expect(envelope.value, 'https://storage.com/invoice.pdf');
      expect(envelope.meta['mimeType'], 'application/pdf');
    });

    test('importFromEnvelope() parses text with email', () {
      final draft = service.draft();
      final envelope = ShareEnvelope(
        kind: ShareKind.text,
        value: 'John Doe john@example.com',
      );

      final updated = service.importFromEnvelope(draft, envelope);

      expect(updated.clientEmail, 'john@example.com');
      expect(updated.clientName, 'John Doe');
    });

    test('importFromEnvelope() parses JSON partial data', () {
      final draft = service.draft();
      final envelope = ShareEnvelope(
        kind: ShareKind.json,
        value: {
          'clientName': 'Test Client',
          'clientEmail': 'client@test.com',
          'notes': 'Payment due on delivery',
        },
      );

      final updated = service.importFromEnvelope(draft, envelope);

      expect(updated.clientName, 'Test Client');
      expect(updated.clientEmail, 'client@test.com');
      expect(updated.notes, 'Payment due on delivery');
    });

    test('importFromEnvelope() round-trip with full invoice', () {
      final business = BusinessInfo(name: 'Test', email: 'test@test.com');
      final client = ClientInfo(name: 'Client', email: 'client@test.com');
      var original = service.draft(business: business, client: client);
      original = service.addItem(
        original,
        InvoiceItem(description: 'Item', quantity: 1, unitPrice: 100),
      );

      final exported = service.exportAsJson(original);
      final imported = service.importFromEnvelope(service.draft(), exported);

      expect(imported.invoiceNumber, original.invoiceNumber);
      expect(imported.businessName, original.businessName);
      expect(imported.clientName, original.clientName);
      expect(imported.items.length, 1);
      expect(imported.total, 100);
    });

    test('importFromEnvelope() throws on unsupported kind', () {
      final draft = service.draft();
      final envelope = ShareEnvelope(
        kind: ShareKind.image,
        value: 'base64data',
      );

      expect(
        () => service.importFromEnvelope(draft, envelope),
        throwsA(isA<InvoiceValidationError>()),
      );
    });
  });

  group('Money Formatting', () {
    test('formatMoney() formats USD correctly', () {
      final formatted = service.formatMoney(1234.56, 'USD');
      expect(formatted, '\$1,234.56');
    });

    test('formatMoney() formats EUR correctly', () {
      final formatted = service.formatMoney(1234.56, 'EUR');
      expect(formatted, '€1,234.56');
    });

    test('formatMoney() formats JPY without decimals', () {
      final formatted = service.formatMoney(1234, 'JPY');
      expect(formatted, '¥1,234');
    });

    test('getInvoiceSummary() produces formatted summary', () {
      final business = BusinessInfo(name: 'Test Corp', email: 'test@test.com');
      final client = ClientInfo(name: 'Client Co', email: 'client@test.com');
      var invoice = service.draft(business: business, client: client);
      invoice = service.addItem(
        invoice,
        InvoiceItem(description: 'Service', quantity: 1, unitPrice: 100),
      );
      invoice = service.applyTax(invoice, percent: 10);

      final summary = service.getInvoiceSummary(invoice);

      expect(summary, contains('Test Corp'));
      expect(summary, contains('Client Co'));
      expect(summary, contains('\$100.00')); // subtotal
      expect(summary, contains('\$10.00')); // tax
      expect(summary, contains('\$110.00')); // total
    });
  });

  group('MoneyFmt Utility', () {
    test('validates currency codes', () {
      expect(MoneyFmt.isValidCurrency('USD'), isTrue);
      expect(MoneyFmt.isValidCurrency('EUR'), isTrue);
      expect(MoneyFmt.isValidCurrency('JPY'), isTrue);

      expect(MoneyFmt.isValidCurrency('US'), isFalse); // too short
      expect(MoneyFmt.isValidCurrency('USDA'), isFalse); // too long
      expect(MoneyFmt.isValidCurrency('us1'), isFalse); // invalid chars
      expect(MoneyFmt.isValidCurrency('usd'), isFalse); // lowercase
    });

    test('formatPlain() formats without symbol', () {
      expect(MoneyFmt.formatPlain(1234.56, 'USD'), '1,234.56');
      expect(MoneyFmt.formatPlain(1234, 'JPY'), '1,234');
    });

    test('getSymbol() returns correct symbols', () {
      expect(MoneyFmt.getSymbol('USD'), '\$');
      expect(MoneyFmt.getSymbol('EUR'), '€');
      expect(MoneyFmt.getSymbol('GBP'), '£');
      expect(MoneyFmt.getSymbol('UNKNOWN'), 'UNKNOWN');
    });
  });

  group('Backend Adapter Selection', () {
    test('MockInvoiceBackendAdapter generates mock URLs', () async {
      final adapter = MockInvoiceBackendAdapter(delay: Duration.zero);
      final business = BusinessInfo(name: 'Test', email: 'test@test.com');
      final client = ClientInfo(name: 'Client', email: 'client@test.com');
      var invoice = service.draft(business: business, client: client);
      invoice = service.addItem(
        invoice,
        InvoiceItem(description: 'Item', quantity: 1, unitPrice: 100),
      );

      final pdfUrl = await adapter.generatePdf(invoice);
      final payLink = await adapter.createPaymentLink(invoice);

      expect(pdfUrl.toString(), contains('toolspace-mock'));
      expect(pdfUrl.toString(), contains('.pdf'));
      expect(payLink.toString(), contains('checkout.stripe.com'));
    });

    test('FunctionsInvoiceBackendAdapter throws unimplemented', () {
      final adapter = FunctionsInvoiceBackendAdapter();
      final business = BusinessInfo(name: 'Test', email: 'test@test.com');
      final client = ClientInfo(name: 'Client', email: 'client@test.com');
      var invoice = service.draft(business: business, client: client);
      invoice = service.addItem(
        invoice,
        InvoiceItem(description: 'Item', quantity: 1, unitPrice: 100),
      );

      expect(
        () => adapter.generatePdf(invoice),
        throwsA(isA<UnimplementedError>()),
      );
      expect(
        () => adapter.createPaymentLink(invoice),
        throwsA(isA<UnimplementedError>()),
      );
    });

    test('createInvoiceBackend() returns mock when flag is true', () {
      // kUseMockInvoiceBackend is set to true at module level
      final adapter = createInvoiceBackend();

      expect(adapter, isA<MockInvoiceBackendAdapter>());
    });
  });
}
