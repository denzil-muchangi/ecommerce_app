import '../../domain/entities/user.dart';
import '../../domain/entities/address.dart';
import '../datasources/user_remote_data_source.dart';

abstract class UserRepository {
  Future<User> getUserProfile(String userId);
  Future<User> updateUserProfile(
    String userId,
    String name,
    String email,
    String? phone,
  );
  Future<List<Address>> getUserAddresses(String userId);
  Future<Address> addUserAddress(String userId, Address address);
  Future<Address> updateUserAddress(String userId, Address address);
  Future<void> deleteUserAddress(String userId, String addressId);
  Future<void> setDefaultAddress(String userId, String addressId);
}

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepositoryImpl(this.remoteDataSource);

  @override
  Future<User> getUserProfile(String userId) async {
    final userModel = await remoteDataSource.getUserProfile(userId);
    return userModel;
  }

  @override
  Future<User> updateUserProfile(
    String userId,
    String name,
    String email,
    String? phone,
  ) async {
    final userModel = await remoteDataSource.updateUserProfile(
      userId,
      name,
      email,
      phone,
    );
    return userModel;
  }

  @override
  Future<List<Address>> getUserAddresses(String userId) async {
    final addressModels = await remoteDataSource.getUserAddresses(userId);
    return addressModels;
  }

  @override
  Future<Address> addUserAddress(String userId, Address address) async {
    final addressModel = await remoteDataSource.addUserAddress(userId, address);
    return addressModel;
  }

  @override
  Future<Address> updateUserAddress(String userId, Address address) async {
    final addressModel = await remoteDataSource.updateUserAddress(
      userId,
      address,
    );
    return addressModel;
  }

  @override
  Future<void> deleteUserAddress(String userId, String addressId) async {
    await remoteDataSource.deleteUserAddress(userId, addressId);
  }

  @override
  Future<void> setDefaultAddress(String userId, String addressId) async {
    await remoteDataSource.setDefaultAddress(userId, addressId);
  }
}
