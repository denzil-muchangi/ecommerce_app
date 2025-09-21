import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/address.dart';
import '../models/user_model.dart';
import '../models/address_model.dart';
import '../firestore_collections.dart';

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

  // Admin methods
  Future<List<UserModel>> getAllUsers();
  Future<UserModel> updateUserRole(String userId, String role);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<UserModel> getUserProfile(String userId) async {
    try {
      final docSnapshot = await _firestore
          .collection(FirestoreCollections.users)
          .doc(userId)
          .get();

      if (!docSnapshot.exists) {
        throw Exception('User not found');
      }

      return UserModel.fromJson({...docSnapshot.data()!, 'id': docSnapshot.id});
    } catch (e) {
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  @override
  Future<UserModel> updateUserProfile(
    String userId,
    String name,
    String email,
    String? phone,
  ) async {
    try {
      final updateData = {
        'name': name,
        'email': email,
        'phone': phone,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection(FirestoreCollections.users)
          .doc(userId)
          .update(updateData);

      // Return updated user
      return await getUserProfile(userId);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  @override
  Future<List<AddressModel>> getUserAddresses(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(FirestoreCollections.users)
          .doc(userId)
          .collection('addresses')
          .orderBy('isDefault', descending: true)
          .orderBy('name')
          .get();

      return querySnapshot.docs.map((doc) {
        return AddressModel.fromJson({
          ...doc.data(),
          'id': doc.id,
          'userId': userId,
        });
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch user addresses: $e');
    }
  }

  @override
  Future<AddressModel> addUserAddress(String userId, Address address) async {
    try {
      final addressData = AddressModel.fromEntity(address).toJson()
        ..remove('id') // Remove id as Firestore will generate it
        ..['createdAt'] = FieldValue.serverTimestamp()
        ..['updatedAt'] = FieldValue.serverTimestamp();

      final docRef = await _firestore
          .collection(FirestoreCollections.users)
          .doc(userId)
          .collection('addresses')
          .add(addressData);

      // Return the created address with the generated ID
      final docSnapshot = await docRef.get();
      return AddressModel.fromJson({
        ...docSnapshot.data()!,
        'id': docSnapshot.id,
        'userId': userId,
      });
    } catch (e) {
      throw Exception('Failed to add user address: $e');
    }
  }

  @override
  Future<AddressModel> updateUserAddress(String userId, Address address) async {
    try {
      final updateData = AddressModel.fromEntity(address).toJson()
        ..remove('id')
        ..remove('userId')
        ..['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection(FirestoreCollections.users)
          .doc(userId)
          .collection('addresses')
          .doc(address.id)
          .update(updateData);

      // Return updated address
      final docSnapshot = await _firestore
          .collection(FirestoreCollections.users)
          .doc(userId)
          .collection('addresses')
          .doc(address.id)
          .get();

      return AddressModel.fromJson({
        ...docSnapshot.data()!,
        'id': docSnapshot.id,
        'userId': userId,
      });
    } catch (e) {
      throw Exception('Failed to update user address: $e');
    }
  }

  @override
  Future<void> deleteUserAddress(String userId, String addressId) async {
    try {
      await _firestore
          .collection(FirestoreCollections.users)
          .doc(userId)
          .collection('addresses')
          .doc(addressId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete user address: $e');
    }
  }

  @override
  Future<void> setDefaultAddress(String userId, String addressId) async {
    try {
      final batch = _firestore.batch();

      // First, unset all default addresses
      final addressesRef = _firestore
          .collection(FirestoreCollections.users)
          .doc(userId)
          .collection('addresses');

      final querySnapshot = await addressesRef.get();
      for (final doc in querySnapshot.docs) {
        batch.update(doc.reference, {'isDefault': false});
      }

      // Then set the new default address
      batch.update(addressesRef.doc(addressId), {'isDefault': true});

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to set default address: $e');
    }
  }

  @override
  Future<List<UserModel>> getAllUsers() async {
    try {
      final querySnapshot = await _firestore
          .collection(FirestoreCollections.users)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return UserModel.fromJson({...doc.data(), 'id': doc.id});
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch all users: $e');
    }
  }

  @override
  Future<UserModel> updateUserRole(String userId, String role) async {
    try {
      final updateData = {
        'role': role,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection(FirestoreCollections.users)
          .doc(userId)
          .update(updateData);

      // Return updated user
      return await getUserProfile(userId);
    } catch (e) {
      throw Exception('Failed to update user role: $e');
    }
  }
}
