/// Single line item in an invoice
class InvoiceItem {
  final String description;
  final double quantity;
  final double unitPrice;
  final String? notes;

  InvoiceItem({
    required this.description,
    required this.quantity,
    required this.unitPrice,
    this.notes,
  });

  double get total => quantity * unitPrice;

  factory InvoiceItem.fromJson(Map<String, dynamic> json) => InvoiceItem(
        description: json['description'] as String,
        quantity: (json['quantity'] as num).toDouble(),
        unitPrice: (json['unitPrice'] as num).toDouble(),
        notes: json['notes'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'description': description,
        'quantity': quantity,
        'unitPrice': unitPrice,
        if (notes != null) 'notes': notes,
      };

  InvoiceItem copyWith({
    String? description,
    double? quantity,
    double? unitPrice,
    String? notes,
  }) {
    return InvoiceItem(
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      notes: notes ?? this.notes,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvoiceItem &&
          runtimeType == other.runtimeType &&
          description == other.description &&
          quantity == other.quantity &&
          unitPrice == other.unitPrice &&
          notes == other.notes;

  @override
  int get hashCode =>
      description.hashCode ^
      quantity.hashCode ^
      unitPrice.hashCode ^
      notes.hashCode;
}
