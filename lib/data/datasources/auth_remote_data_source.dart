import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String email, String password, String name);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  // Mock authentication - accepts any valid email/password combination
  @override
  Future<UserModel> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Basic email validation
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      throw Exception('Invalid email format');
    }

    if (password.isEmpty) {
      throw Exception('Password cannot be empty');
    }

    // For demo purposes, accept any valid email/password
    // In real app, this would validate against server
    return UserModel(
      id: 'user_${email.hashCode}',
      email: email,
      name: 'User ${email.split('@').first}',
    );
  }

  @override
  Future<UserModel> register(String email, String password, String name) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Basic validation
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      throw Exception('Invalid email format');
    }

    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }

    if (name.trim().isEmpty) {
      throw Exception('Name cannot be empty');
    }

    // For demo purposes, accept any valid input
    // In real app, this would create user on server
    return UserModel(
      id: 'user_${email.hashCode}',
      email: email,
      name: name.trim(),
    );
  }
}
