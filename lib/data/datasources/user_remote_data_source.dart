import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/address.dart';
import '../models/user_model.dart';
import '../models/address_model.dart';

abstract class UserRemoteDataSource {
  Future<UserModel> getUserProfile(String userId);
  Future<UserModel> updateUserProfile(
    String userId,
    String name,
    String email,
    String? phone,
  );
  Future<List<AddressModel>> getUserAddresses(String userId);
  Future<AddressModel> addUserAddress(String userId, Address address);
  Future<AddressModel> updateUserAddress(String userId, Address address);
  Future<void> deleteUserAddress(String userId, String addressId);
  Future<void> setDefaultAddress(String userId, String addressId);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  static const String userKey = 'user_profile';
  static const String addressesKey = 'user_addresses';

  // Mock user data
  final Map<String, UserModel> _mockUsers = {
    '1': const UserModel(
      id: '1',
      email: 'john.doe@example.com',
      name: 'John Doe',
      phone: '+1234567890',
      addresses: [],
    ),
  };

  // Mock addresses data
  final Map<String, List<AddressModel>> _mockAddresses = {
    '1': [
      const AddressModel(
        id: 'addr1',
        userId: '1',
        name: 'John Doe',
        phone: '+1234567890',
        street: '123 Main St',
        city: 'New York',
        state: 'NY',
        zipCode: '10001',
        country: 'USA',
        isDefault: true,
      ),
      const AddressModel(
        id: 'addr2',
        userId: '1',
        name: 'John Doe',
        phone: '+1234567890',
        street: '456 Oak Ave',
        city: 'Los Angeles',
        state: 'CA',
        zipCode: '90210',
        country: 'USA',
        isDefault: false,
      ),
    ],
  };

  @override
  Future<UserModel> getUserProfile(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('${userKey}_$userId');

    if (userJson != null) {
      return UserModel.fromJson(json.decode(userJson));
    }

    // Return mock data if not in shared preferences
    return _mockUsers[userId] ?? _mockUsers['1']!;
  }

  @override
  Future<UserModel> updateUserProfile(
    String userId,
    String name,
    String email,
    String? phone,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final currentUser = await getUserProfile(userId);

    final updatedUser = UserModel(
      id: currentUser.id,
      email: email,
      name: name,
      phone: phone,
      addresses: currentUser.addresses,
    );

    await prefs.setString(
      '$userKey\_$userId',
      json.encode(updatedUser.toJson()),
    );
    return updatedUser;
  }

  @override
  Future<List<AddressModel>> getUserAddresses(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final addressesJson = prefs.getString('$addressesKey\_$userId');

    if (addressesJson != null) {
      final List<dynamic> addressesList = json.decode(addressesJson);
      return addressesList.map((json) => AddressModel.fromJson(json)).toList();
    }

    // Return mock data if not in shared preferences
    return _mockAddresses[userId] ?? [];
  }

  @override
  Future<AddressModel> addUserAddress(String userId, Address address) async {
    final prefs = await SharedPreferences.getInstance();
    final currentAddresses = await getUserAddresses(userId);

    final newAddress = AddressModel.fromEntity(address);
    final updatedAddresses = [...currentAddresses, newAddress];

    await prefs.setString(
      '$addressesKey\_$userId',
      json.encode(updatedAddresses.map((a) => a.toJson()).toList()),
    );
    return newAddress;
  }

  @override
  Future<AddressModel> updateUserAddress(String userId, Address address) async {
    final prefs = await SharedPreferences.getInstance();
    final currentAddresses = await getUserAddresses(userId);

    final updatedAddresses = currentAddresses.map((a) {
      return a.id == address.id ? AddressModel.fromEntity(address) : a;
    }).toList();

    await prefs.setString(
      '$addressesKey\_$userId',
      json.encode(updatedAddresses.map((a) => a.toJson()).toList()),
    );
    return AddressModel.fromEntity(address);
  }

  @override
  Future<void> deleteUserAddress(String userId, String addressId) async {
    final prefs = await SharedPreferences.getInstance();
    final currentAddresses = await getUserAddresses(userId);

    final updatedAddresses = currentAddresses
        .where((a) => a.id != addressId)
        .toList();

    await prefs.setString(
      '$addressesKey\_$userId',
      json.encode(updatedAddresses.map((a) => a.toJson()).toList()),
    );
  }

  @override
  Future<void> setDefaultAddress(String userId, String addressId) async {
    final prefs = await SharedPreferences.getInstance();
    final currentAddresses = await getUserAddresses(userId);

    final updatedAddresses = currentAddresses.map((a) {
      return AddressModel(
        id: a.id,
        userId: a.userId,
        name: a.name,
        phone: a.phone,
        street: a.street,
        city: a.city,
        state: a.state,
        zipCode: a.zipCode,
        country: a.country,
        isDefault: a.id == addressId,
      );
    }).toList();

    await prefs.setString(
      '$addressesKey\_$userId',
      json.encode(updatedAddresses.map((a) => a.toJson()).toList()),
    );
  }
}
