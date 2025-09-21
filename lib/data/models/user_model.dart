import 'dart:convert';
import '../../domain/entities/user.dart';
import '../../domain/entities/address.dart';
import 'address_model.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    super.phone,
    super.role = UserRole.user,
    super.addresses = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      role: UserRole.fromString(json['role'] as String? ?? 'user'),
      addresses:
          (json['addresses'] as List<dynamic>?)
              ?.map((addressJson) => AddressModel.fromJson(addressJson))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'role': role.name,
      'addresses': addresses
          .map((address) => AddressModel.fromEntity(address).toJson())
          .toList(),
    };
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      name: user.name,
      phone: user.phone,
      role: user.role,
      addresses: user.addresses,
    );
  }
}
