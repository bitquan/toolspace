import 'invoice_item.dart';

/// Complete invoice with business and client info
class InvoiceLite {
  final String id;
  final DateTime createdAt;

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
  final String invoiceNumber;
  final DateTime invoiceDate;
  final DateTime? dueDate;
  final List<InvoiceItem> items;
  final String currency;
  final double taxRate; // percentage (e.g., 10 for 10%)
  final double discountAmount;
  final double discountPercent; // percentage discount (alternative to fixed amount)
  final String? notes;
  final String? paymentTerms;

  InvoiceLite({
    required this.id,
    required this.createdAt,
    required this.businessName,
    required this.businessEmail,
    this.businessAddress,
    this.businessPhone,
    required this.clientName,
    required this.clientEmail,
    this.clientAddress,
    required this.invoiceNumber,
    required this.invoiceDate,
    this.dueDate,
    required this.items,
    this.currency = 'USD',
    this.taxRate = 0,
    this.discountAmount = 0,
    this.discountPercent = 0,
    this.notes,
    this.paymentTerms,
  });

  /// Calculate subtotal (sum of all items)
  double get subtotal => items.fold(0.0, (sum, item) => sum + item.total);

  /// Calculate total discount (both fixed and percentage)
  double get totalDiscount {
    double discount = discountAmount;
    if (discountPercent > 0) {
      discount += subtotal * (discountPercent / 100);
    }
    return discount;
  }

  /// Calculate tax amount (applied to subtotal after discount)
  double get taxAmount => (subtotal - totalDiscount) * (taxRate / 100);

  /// Calculate grand total after tax and discount
  double get total => subtotal - totalDiscount + taxAmount;

  /// Balance due (same as total for now; could track payments later)
  double get balanceDue => total;

  factory InvoiceLite.fromJson(Map<String, dynamic> json) => InvoiceLite(
        id: json['id'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        businessName: json['businessName'] as String,
        businessEmail: json['businessEmail'] as String,
        businessAddress: json['businessAddress'] as String?,
        businessPhone: json['businessPhone'] as String?,
        clientName: json['clientName'] as String,
        clientEmail: json['clientEmail'] as String,
        clientAddress: json['clientAddress'] as String?,
        invoiceNumber: json['invoiceNumber'] as String,
        invoiceDate: DateTime.parse(json['invoiceDate'] as String),
        dueDate: json['dueDate'] != null
            ? DateTime.parse(json['dueDate'] as String)
            : null,
        items: (json['items'] as List<dynamic>)
            .map((e) => InvoiceItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        currency: json['currency'] as String? ?? 'USD',
        taxRate: (json['taxRate'] as num?)?.toDouble() ?? 0,
        discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0,
        discountPercent: (json['discountPercent'] as num?)?.toDouble() ?? 0,
        notes: json['notes'] as String?,
        paymentTerms: json['paymentTerms'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'businessName': businessName,
        'businessEmail': businessEmail,
        if (businessAddress != null) 'businessAddress': businessAddress,
        if (businessPhone != null) 'businessPhone': businessPhone,
        'clientName': clientName,
        'clientEmail': clientEmail,
        if (clientAddress != null) 'clientAddress': clientAddress,
        'invoiceNumber': invoiceNumber,
        'invoiceDate': invoiceDate.toIso8601String(),
        if (dueDate != null) 'dueDate': dueDate!.toIso8601String(),
        'items': items.map((e) => e.toJson()).toList(),
        'currency': currency,
        'taxRate': taxRate,
        'discountAmount': discountAmount,
        'discountPercent': discountPercent,
        if (notes != null) 'notes': notes,
        if (paymentTerms != null) 'paymentTerms': paymentTerms,
      };

  InvoiceLite copyWith({
    String? id,
    DateTime? createdAt,
    String? businessName,
    String? businessEmail,
    String? businessAddress,
    String? businessPhone,
    String? clientName,
    String? clientEmail,
    String? clientAddress,
    String? invoiceNumber,
    DateTime? invoiceDate,
    DateTime? dueDate,
    List<InvoiceItem>? items,
    String? currency,
    double? taxRate,
    double? discountAmount,
    double? discountPercent,
    String? notes,
    String? paymentTerms,
  }) {
    return InvoiceLite(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      businessName: businessName ?? this.businessName,
      businessEmail: businessEmail ?? this.businessEmail,
      businessAddress: businessAddress ?? this.businessAddress,
      businessPhone: businessPhone ?? this.businessPhone,
      clientName: clientName ?? this.clientName,
      clientEmail: clientEmail ?? this.clientEmail,
      clientAddress: clientAddress ?? this.clientAddress,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      dueDate: dueDate ?? this.dueDate,
      items: items ?? this.items,
      currency: currency ?? this.currency,
      taxRate: taxRate ?? this.taxRate,
      discountAmount: discountAmount ?? this.discountAmount,
      discountPercent: discountPercent ?? this.discountPercent,
      notes: notes ?? this.notes,
      paymentTerms: paymentTerms ?? this.paymentTerms,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvoiceLite &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          invoiceNumber == other.invoiceNumber;

  @override
  int get hashCode => id.hashCode ^ invoiceNumber.hashCode;
}
