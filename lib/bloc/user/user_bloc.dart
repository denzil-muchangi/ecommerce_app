import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/user_repository.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository repository;

  UserBloc(this.repository) : super(UserInitial()) {
    on<LoadUserProfile>(_onLoadUserProfile);
    on<UpdateUserProfile>(_onUpdateUserProfile);
    on<LoadUserAddresses>(_onLoadUserAddresses);
    on<AddUserAddress>(_onAddUserAddress);
    on<UpdateUserAddress>(_onUpdateUserAddress);
    on<DeleteUserAddress>(_onDeleteUserAddress);
    on<SetDefaultAddress>(_onSetDefaultAddress);
    on<LoadAllUsers>(_onLoadAllUsers);
    on<UpdateUserRole>(_onUpdateUserRole);
  }

  Future<void> _onLoadUserProfile(
    LoadUserProfile event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      final user = await repository.getUserProfile(event.userId);
      emit(UserProfileLoaded(user));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onUpdateUserProfile(
    UpdateUserProfile event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      final user = await repository.updateUserProfile(
        event.userId,
        event.name,
        event.email,
        event.phone,
      );
      emit(UserProfileUpdated(user));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onLoadUserAddresses(
    LoadUserAddresses event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      final addresses = await repository.getUserAddresses(event.userId);
      emit(UserAddressesLoaded(addresses));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onAddUserAddress(
    AddUserAddress event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      final address = await repository.addUserAddress(
        event.userId,
        event.address,
      );
      emit(UserAddressAdded(address));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onUpdateUserAddress(
    UpdateUserAddress event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      final address = await repository.updateUserAddress(
        event.userId,
        event.address,
      );
      emit(UserAddressUpdated(address));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onDeleteUserAddress(
    DeleteUserAddress event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      await repository.deleteUserAddress(event.userId, event.addressId);
      emit(UserAddressDeleted(event.addressId));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onSetDefaultAddress(
    SetDefaultAddress event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      await repository.setDefaultAddress(event.userId, event.addressId);
      // Reload addresses to reflect the change
      final addresses = await repository.getUserAddresses(event.userId);
      emit(UserAddressesLoaded(addresses));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onLoadAllUsers(
    LoadAllUsers event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      final users = await repository.getAllUsers();
      emit(AllUsersLoaded(users));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onUpdateUserRole(
    UpdateUserRole event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      final user = await repository.updateUserRole(
        event.userId,
        event.newRole.name,
      );
      emit(UserRoleUpdated(user));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
}
