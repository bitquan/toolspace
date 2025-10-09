/// Client information for invoice billing
class ClientInfo {
  final String name;
  final String email;
  final String? address;

  ClientInfo({
    required this.name,
    required this.email,
    this.address,
  });

  factory ClientInfo.fromJson(Map<String, dynamic> json) => ClientInfo(
        name: json['name'] as String,
        email: json['email'] as String,
        address: json['address'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        if (address != null) 'address': address,
      };

  ClientInfo copyWith({
    String? name,
    String? email,
    String? address,
  }) {
    return ClientInfo(
      name: name ?? this.name,
      email: email ?? this.email,
      address: address ?? this.address,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClientInfo &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          email == other.email &&
          address == other.address;

  @override
  int get hashCode => name.hashCode ^ email.hashCode ^ address.hashCode;
}
