import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

abstract class AuthRepository {
  Future<User> login(String email, String password);
  Future<User> register(String email, String password, String name);
  Future<void> logout();
  Future<User?> getCurrentUser();
  Future<bool> isAuthenticated();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SharedPreferences sharedPreferences;

  static const String _userKey = 'current_user';

  AuthRepositoryImpl(this.remoteDataSource, this.sharedPreferences);

  @override
  Future<User> login(String email, String password) async {
    final userModel = await remoteDataSource.login(email, password);
    await _saveUser(userModel);
    return userModel;
  }

  @override
  Future<User> register(String email, String password, String name) async {
    final userModel = await remoteDataSource.register(email, password, name);
    await _saveUser(userModel);
    return userModel;
  }

  @override
  Future<void> logout() async {
    await sharedPreferences.remove(_userKey);
  }

  @override
  Future<User?> getCurrentUser() async {
    final userJson = sharedPreferences.getString(_userKey);
    if (userJson != null) {
      final userMap = json.decode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(userMap);
    }
    return null;
  }

  @override
  Future<bool> isAuthenticated() async {
    return sharedPreferences.containsKey(_userKey);
  }

  Future<void> _saveUser(UserModel user) async {
    final userJson = json.encode(user.toJson());
    await sharedPreferences.setString(_userKey, userJson);
  }
}
