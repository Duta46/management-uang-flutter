import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/api_models.dart';

class AuthService {
  static const String _userKey = 'user_data';
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );

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

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User cancelled sign-in
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // In a real app, you would send the ID token to your backend
      // For now, we'll create a dummy user based on Google account info
      final user = User(
        id: int.tryParse(googleUser.id.toString()) ?? 0,
        name: googleUser.displayName ?? 'Google User',
        email: googleUser.email,
        token: googleAuth.idToken ?? '',
      );
      
      await saveUser(user);
      return user;
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }

  Future<void> signOutWithGoogle() async {
    await _googleSignIn.signOut();
    await clearUser();
  }
}