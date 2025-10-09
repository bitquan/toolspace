/// Business information that persists across invoices
class BusinessInfo {
  final String name;
  final String email;
  final String? address;
  final String? phone;

  BusinessInfo({
    required this.name,
    required this.email,
    this.address,
    this.phone,
  });

  factory BusinessInfo.fromJson(Map<String, dynamic> json) => BusinessInfo(
        name: json['name'] as String,
        email: json['email'] as String,
        address: json['address'] as String?,
        phone: json['phone'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        if (address != null) 'address': address,
        if (phone != null) 'phone': phone,
      };

  BusinessInfo copyWith({
    String? name,
    String? email,
    String? address,
    String? phone,
  }) {
    return BusinessInfo(
      name: name ?? this.name,
      email: email ?? this.email,
      address: address ?? this.address,
      phone: phone ?? this.phone,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BusinessInfo &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          email == other.email &&
          address == other.address &&
          phone == other.phone;

  @override
  int get hashCode =>
      name.hashCode ^ email.hashCode ^ address.hashCode ^ phone.hashCode;
}
