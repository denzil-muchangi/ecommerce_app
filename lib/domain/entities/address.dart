class Address {
  final String id;
  final String userId;
  final String name;
  final String phone;
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final bool isDefault;

  const Address({
    required this.id,
    required this.userId,
    required this.name,
    required this.phone,
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
    this.isDefault = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Address && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
