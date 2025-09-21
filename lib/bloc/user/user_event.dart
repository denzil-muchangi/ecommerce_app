import 'package:equatable/equatable.dart';
import '../../domain/entities/address.dart';
import '../../domain/entities/user.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object> get props => [];
}

class LoadUserProfile extends UserEvent {
  final String userId;

  const LoadUserProfile(this.userId);

  @override
  List<Object> get props => [userId];
}

class UpdateUserProfile extends UserEvent {
  final String userId;
  final String name;
  final String email;
  final String? phone;

  const UpdateUserProfile({
    required this.userId,
    required this.name,
    required this.email,
    this.phone,
  });

  @override
  List<Object> get props => [userId, name, email, phone ?? ''];
}

class LoadUserAddresses extends UserEvent {
  final String userId;

  const LoadUserAddresses(this.userId);

  @override
  List<Object> get props => [userId];
}

class AddUserAddress extends UserEvent {
  final String userId;
  final Address address;

  const AddUserAddress(this.userId, this.address);

  @override
  List<Object> get props => [userId, address];
}

class UpdateUserAddress extends UserEvent {
  final String userId;
  final Address address;

  const UpdateUserAddress(this.userId, this.address);

  @override
  List<Object> get props => [userId, address];
}

class DeleteUserAddress extends UserEvent {
  final String userId;
  final String addressId;

  const DeleteUserAddress(this.userId, this.addressId);

  @override
  List<Object> get props => [userId, addressId];
}

class SetDefaultAddress extends UserEvent {
  final String userId;
  final String addressId;

  const SetDefaultAddress(this.userId, this.addressId);

  @override
  List<Object> get props => [userId, addressId];
}

// Admin Events
class LoadAllUsers extends UserEvent {}

class UpdateUserRole extends UserEvent {
  final String userId;
  final UserRole newRole;

  const UpdateUserRole({required this.userId, required this.newRole});

  @override
  List<Object> get props => [userId, newRole];
}
