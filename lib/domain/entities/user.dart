import 'address.dart';

class User {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final List<Address> addresses;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.addresses = const [],
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
