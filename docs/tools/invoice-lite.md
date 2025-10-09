# Invoice Lite Tool

> **Status**: Service Layer Complete (Phase-3, Iteration 1)  
> **Tool ID**: `invoice_lite`  
> **Min Plan**: Pro  
> **Quota**: Heavy Ops (PDF generation, payment links)

## Overview

Invoice Lite is a professional invoicing tool that enables users to create, customize, and share invoices with clients. It provides PDF export, Stripe payment link generation, and cross-tool data sharing capabilities.

**Key Features:**
- ✨ Create professional invoices with business and client info
- 📄 Generate PDF invoices (requires Pro plan)
- 💳 Create Stripe payment links (requires Pro plan)
- 🔄 Cross-tool integration via ShareEnvelope
- 💰 Multi-currency support (ISO-4217)
- 🧮 Automatic tax and discount calculations
- ✅ Comprehensive validation

## Data Models

### InvoiceLite

Complete invoice with business info, client info, line items, and calculations.

```dart
class InvoiceLite {
  final String id;                    // Unique ID (nanoid)
  final DateTime createdAt;           // Creation timestamp
  
  // Business info
  final String businessName;
  final String businessEmail;
  final String? businessAddress;
  final String? businessPhone;
  
  // Client info
  final String clientName;
  final String clientEmail;
  final String? clientAddress;
  
  // Invoice details
  final String invoiceNumber;         // e.g., "INV-A1B2C3D4"
  final DateTime invoiceDate;
  final DateTime? dueDate;
  final List<InvoiceItem> items;
  final String currency;              // ISO-4217 (USD, EUR, etc.)
  final double taxRate;               // Percentage (e.g., 10 for 10%)
  final double discountAmount;        // Fixed discount
  final double discountPercent;       // Percentage discount
  final String? notes;
  final String? paymentTerms;
  
  // Computed getters
  double get subtotal;                // Sum of all items
  double get totalDiscount;           // Fixed + percentage discount
  double get taxAmount;               // Tax on discounted subtotal
  double get total;                   // Final amount
  double get balanceDue;              // Amount due (same as total)
}
```

### InvoiceItem

Individual line item on an invoice.

```dart
class InvoiceItem {
  final String description;
  final double quantity;
  final double unitPrice;
  final String? notes;
  
  double get total => quantity * unitPrice;
}
```

### BusinessInfo

Reusable business information.

```dart
class BusinessInfo {
  final String name;
  final String email;
  final String? address;
  final String? phone;
}
```

### ClientInfo

Client/customer information.

```dart
class ClientInfo {
  final String name;
  final String email;
  final String? address;
}
```

## Service API

### InvoiceLiteService

Main service class for invoice operations.

```dart
final service = InvoiceLiteService(
  billing: billingService,
  backend: createInvoiceBackend(), // Mock or Functions adapter
);
```

#### Core CRUD Operations

**Create a draft invoice:**
```dart
final invoice = service.draft(
  business: BusinessInfo(
    name: 'Acme Corp',
    email: 'billing@acme.com',
    address: '123 Main St',
  ),
  client: ClientInfo(
    name: 'Client Co',
    email: 'client@example.com',
  ),
);
```

**Add items:**
```dart
invoice = service.addItem(
  invoice,
  InvoiceItem(
    description: 'Web Development Services',
    quantity: 10,
    unitPrice: 150.0,
  ),
);
```

**Update an item:**
```dart
invoice = service.updateItem(invoice, 0, updatedItem);
```

**Remove an item:**
```dart
invoice = service.removeItem(invoice, 0);
```

#### Tax & Discount

**Apply tax:**
```dart
invoice = service.applyTax(invoice, percent: 10); // 10% tax
```

**Apply fixed discount:**
```dart
invoice = service.applyDiscount(invoice, fixed: 50.0);
```

**Apply percentage discount:**
```dart
invoice = service.applyDiscount(invoice, percent: 15); // 15% off
```

**Calculate totals:**
```dart
invoice = service.calculateTotals(invoice); // Validates and returns
```

#### Backend Operations (Heavy Ops)

**Generate PDF:**
```dart
try {
  final pdfUrl = await service.getInvoicePdfUrl(invoice);
  print('PDF ready: $pdfUrl');
} on PaywallRequiredError catch (e) {
  // User needs to upgrade to Pro plan
  print('Upgrade required: ${e.requiredPlan}');
} on InvoiceValidationError catch (e) {
  // Invalid invoice data
  print('Validation failed: ${e.message}');
}
```

**Create payment link:**
```dart
try {
  final payLink = await service.createPayLink(invoice);
  print('Pay here: $payLink');
} on PaywallRequiredError catch (e) {
  print('Daily quota exhausted or plan upgrade needed');
}
```

#### Cross-Tool Integration

**Export as JSON:**
```dart
final envelope = service.exportAsJson(invoice);
// Share with other tools (e.g., JSON Doctor)
shareBus.publish(envelope);
```

**Export payment link:**
```dart
final payLink = Uri.parse('https://checkout.stripe.com/...');
final envelope = service.exportPayLink(payLink, invoice);
// Share with QR Maker, Link Shortener, etc.
```

**Export PDF URL:**
```dart
final pdfUrl = Uri.parse('https://storage.com/invoice.pdf');
final envelope = service.exportPdfUrl(pdfUrl, invoice);
```

**Import from text:**
```dart
final clientEnvelope = ShareEnvelope(
  kind: ShareKind.text,
  value: 'John Doe john@example.com',
);
invoice = service.importFromEnvelope(invoice, clientEnvelope);
// Parses email and name automatically
```

**Import from JSON:**
```dart
final dataEnvelope = ShareEnvelope(
  kind: ShareKind.json,
  value: {
    'clientName': 'Acme Inc',
    'clientEmail': 'billing@acme.com',
    'notes': 'Net 30 terms',
  },
);
invoice = service.importFromEnvelope(invoice, dataEnvelope);
// Merges partial data into draft
```

#### Formatting

**Format money:**
```dart
service.formatMoney(1234.56, 'USD'); // "$1,234.56"
service.formatMoney(1234.56, 'EUR'); // "€1,234.56"
service.formatMoney(1234, 'JPY');    // "¥1,234"
```

**Get invoice summary:**
```dart
final summary = service.getInvoiceSummary(invoice);
print(summary);
// Output:
// Invoice INV-A1B2C3D4
// From: Acme Corp
// To: Client Co
// 
// Items: 3
// Subtotal: $1,500.00
// Tax: $135.00
// Discount: $150.00
// Total: $1,485.00
```

## Money Formatting Utility

### MoneyFmt

Pure Dart utility for currency formatting.

```dart
MoneyFmt.format(1234.56, 'USD');       // "$1,234.56"
MoneyFmt.formatPlain(1234.56, 'USD');  // "1,234.56"
MoneyFmt.getSymbol('EUR');             // "€"
MoneyFmt.isValidCurrency('USD');       // true
MoneyFmt.isValidCurrency('INVALID');   // false
```

**Supported currencies:** USD, EUR, GBP, JPY, CNY, INR, AUD, CAD, CHF, SEK, NZD, KRW, SGD, HKD, NOK, MXN, BRL, ZAR, RUB, TRY, and more.

## Validation & Errors

### InvoiceValidationError

Thrown when invoice data is invalid.

```dart
try {
  service.addItem(invoice, invalidItem);
} on InvoiceValidationError catch (e) {
  print(e.message);
  print(e.fieldErrors); // Map<String, String>
}
```

**Common validation failures:**
- Empty description, business name, or client email
- Negative quantity or price
- Invalid currency code (must be 3-letter ISO-4217)
- Missing required fields
- No invoice items

### PaywallRequiredError

Thrown when billing prevents an operation.

```dart
try {
  await service.createPayLink(invoice);
} on PaywallRequiredError catch (e) {
  print(e.message);         // "Daily operation limit reached"
  print(e.requiredPlan);    // "pro"
  print(e.currentPlan);     // "free"
}
```

**Paywall triggers:**
- Tool access (`canAccessTool('invoice_lite')` fails)
- Heavy operation quota (`canPerformHeavyOp()` fails)

## Backend Adapters

The service uses pluggable backend adapters for PDF generation and payment links.

### Mock Adapter (Default)

```dart
const kUseMockInvoiceBackend = true; // Default in backend_adapter.dart

final adapter = MockInvoiceBackendAdapter();
// Returns mock URLs instantly for development
```

### Functions Adapter (Future)

```dart
const kUseMockInvoiceBackend = false;

final adapter = FunctionsInvoiceBackendAdapter();
// Calls Firebase Functions: generateInvoicePdf, createInvoicePaymentLink
// Currently throws UnimplementedError (scaffold only)
```

## Billing & Quotas

### Tool Access

- **Min Plan**: Pro
- **Check**: `billingService.canAccessTool('invoice_lite')`
- **Free users**: Blocked at all operations

### Heavy Operations

**What counts as heavy op:**
- PDF generation (`getInvoicePdfUrl`)
- Payment link creation (`createPayLink`)

**Quota limits:**
- **Free**: 0/day (tool access blocked)
- **Pro**: 10/day
- **Pro+**: 50/day

**Tracking:**
```dart
await billingService.trackHeavyOp();
```

Service automatically checks quotas and tracks usage on successful operations.

## Example: Build an Invoice in 12 Lines

```dart
import 'package:toolspace/tools/invoice_lite/invoice_lite_service.dart';
import 'package:toolspace/tools/invoice_lite/models/models.dart';

void main() async {
  final service = InvoiceLiteService(billing: billingService);
  
  // Create draft
  var invoice = service.draft(
    business: BusinessInfo(name: 'My Business', email: 'me@biz.com'),
    client: ClientInfo(name: 'Client Inc', email: 'client@inc.com'),
  );
  
  // Add items
  invoice = service.addItem(invoice, InvoiceItem(
    description: 'Consulting',
    quantity: 5,
    unitPrice: 200,
  ));
  
  // Apply tax and discount
  invoice = service.applyTax(invoice, percent: 8);
  invoice = service.applyDiscount(invoice, percent: 10);
  
  print('Total: ${service.formatMoney(invoice.total, invoice.currency)}');
  // Total: $972.00
  
  // Generate PDF
  final pdfUrl = await service.getInvoicePdfUrl(invoice);
  print('Download: $pdfUrl');
}
```

## Testing

### Running Tests

```bash
# Run all Invoice Lite tests
flutter test test/tools/invoice_lite/

# Run with coverage
flutter test test/tools/invoice_lite/ --coverage

# Run analyzer
flutter analyze lib/tools/invoice_lite/
```

### Mock Billing Service

```dart
class MockBillingService {
  bool _allowToolAccess = true;
  bool _allowHeavyOp = true;

  void setToolAccess(bool allow) => _allowToolAccess = allow;
  void setHeavyOpAccess(bool allow) => _allowHeavyOp = allow;

  Future<EntitlementCheckResult> canAccessTool(String toolId) async {
    return EntitlementCheckResult(
      allowed: _allowToolAccess,
      planId: PlanId.pro,
    );
  }
  
  Future<EntitlementCheckResult> canPerformHeavyOp() async {
    return EntitlementCheckResult(
      allowed: _allowHeavyOp,
      planId: PlanId.pro,
    );
  }
  
  Future<void> trackHeavyOp() async {}
}
```

## Roadmap

### Phase 3A (Current - Service Layer) ✅
- [x] Complete data models
- [x] Service API implementation
- [x] Mock backend adapter
- [x] Validation & error handling
- [x] Billing integration
- [x] Cross-tool ShareEnvelope support
- [x] Comprehensive unit tests (44 tests, 100% pass)

### Phase 3B (Next - UI & Backend)
- [ ] Invoice Lite screen (UI)
- [ ] Firebase Functions for PDF generation
- [ ] Firebase Functions for Stripe payment links
- [ ] Functions backend adapter implementation
- [ ] Widget tests
- [ ] Integration with routes and home grid

### Phase 3C (Future - Enhancements)
- [ ] Invoice templates
- [ ] Recurring invoices
- [ ] Payment tracking
- [ ] Client management
- [ ] Invoice history
- [ ] Email sending

## Related Documentation

- [Phase-3 Implementation Summary](../roadmap/phase-3-implementation-summary.md)
- [Billing System](../billing/README.md)
- [Cross-Tool Architecture](../architecture/cross-tool-sharing.md)
- [ShareEnvelope Specification](../architecture/share-envelope.md)

## Support

For issues or questions:
- GitHub Issues: [toolspace#109](https://github.com/bitquan/toolspace/issues/109)
- Dev Log: `dev-log/phase-3-*.md`
