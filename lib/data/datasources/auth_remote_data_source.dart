import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../firestore_collections.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String email, String password, String name);
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get user data from Firestore
      final userDoc = await _firestore
          .collection(FirestoreCollections.users)
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception('User data not found');
      }

      return UserModel.fromJson({
        ...userDoc.data()!,
        'id': userCredential.user!.uid,
      });
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception('No user found with this email');
        case 'wrong-password':
          throw Exception('Wrong password provided');
        case 'invalid-email':
          throw Exception('Invalid email format');
        case 'user-disabled':
          throw Exception('User account has been disabled');
        default:
          throw Exception('Login failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  @override
  Future<UserModel> register(String email, String password, String name) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      final userData = {
        'email': email,
        'name': name.trim(),
        'phone': null,
        'addresses': [],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection(FirestoreCollections.users)
          .doc(userCredential.user!.uid)
          .set(userData);

      return UserModel(
        id: userCredential.user!.uid,
        email: email,
        name: name.trim(),
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          throw Exception('Password is too weak');
        case 'email-already-in-use':
          throw Exception('An account already exists with this email');
        case 'invalid-email':
          throw Exception('Invalid email format');
        default:
          throw Exception('Registration failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }
}
