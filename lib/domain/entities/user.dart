import 'address.dart';

enum UserRole {
  user,
  admin;

  String get displayName {
    switch (this) {
      case UserRole.user:
        return 'User';
      case UserRole.admin:
        return 'Admin';
    }
  }

  static UserRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'user':
      default:
        return UserRole.user;
    }
  }
}

class User {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final UserRole role;
  final List<Address> addresses;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.role = UserRole.user,
    this.addresses = const [],
  });

  bool get isAdmin => role == UserRole.admin;
  bool get isUser => role == UserRole.user;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
