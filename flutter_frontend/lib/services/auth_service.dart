import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_models.dart';

class AuthService {
  static const String _userKey = 'user_data';

  Future<void> saveUser(User user) async {
    print("AuthService: Saving user to SharedPreferences - ID: ${user.id}, Name: ${user.name}, Email: ${user.email}"); // Debug log
    final prefs = await SharedPreferences.getInstance();
    final userData = {
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'token': user.token,
    };
    await prefs.setString(_userKey, jsonEncode(userData));
    print("AuthService: User data saved successfully"); // Debug log
  }

  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataJson = prefs.getString(_userKey);
    
    if (userDataJson != null) {
      final userData = jsonDecode(userDataJson);
      return User(
        id: int.tryParse(userData['id'].toString()) ?? 0,
        name: userData['name'],
        email: userData['email'],
        token: userData['token'],
      );
    }
    return null;
  }

  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }


}