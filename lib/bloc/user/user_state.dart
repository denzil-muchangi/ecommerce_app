import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/address.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserProfileLoaded extends UserState {
  final User user;

  const UserProfileLoaded(this.user);

  @override
  List<Object> get props => [user];
}

class UserAddressesLoaded extends UserState {
  final List<Address> addresses;

  const UserAddressesLoaded(this.addresses);

  @override
  List<Object> get props => [addresses];
}

class UserProfileUpdated extends UserState {
  final User user;

  const UserProfileUpdated(this.user);

  @override
  List<Object> get props => [user];
}

class UserAddressAdded extends UserState {
  final Address address;

  const UserAddressAdded(this.address);

  @override
  List<Object> get props => [address];
}

class UserAddressUpdated extends UserState {
  final Address address;

  const UserAddressUpdated(this.address);

  @override
  List<Object> get props => [address];
}

class UserAddressDeleted extends UserState {
  final String addressId;

  const UserAddressDeleted(this.addressId);

  @override
  List<Object> get props => [addressId];
}

class UserError extends UserState {
  final String message;

  const UserError(this.message);

  @override
  List<Object> get props => [message];
}
