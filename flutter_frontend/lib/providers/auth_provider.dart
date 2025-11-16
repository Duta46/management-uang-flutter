import 'package:flutter/foundation.dart';
import '../services/data_service.dart';
import '../services/google_sign_in_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  String _message = '';

  bool get isLoading => _isLoading;
  String get message => _message;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _message = '';
    notifyListeners();

    try {
      final response = await DataService.login(
        email: email,
        password: password,
      );

      _isLoading = false;
      _message = response.message;
      notifyListeners();

      return response.success;
    } catch (e) {
      _isLoading = false;
      _message = 'Terjadi kesalahan: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password, String passwordConfirmation) async {
    _isLoading = true;
    _message = '';
    notifyListeners();

    try {
      final response = await DataService.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      _isLoading = false;
      _message = response.message;
      notifyListeners();

      return response.success;
    } catch (e) {
      _isLoading = false;
      _message = 'Terjadi kesalahan: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await DataService.logout();

      _isLoading = false;
      _message = response.message;
      notifyListeners();

      return response.success;
    } catch (e) {
      _isLoading = false;
      _message = 'Terjadi kesalahan: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _message = '';
    notifyListeners();

    try {
      // Sign in with Google
      final googleUser = await GoogleSignInService.signIn();
      if (googleUser == null) {
        _isLoading = false;
        _message = 'Sign in aborted';
        notifyListeners();
        return false;
      }

      // Get the ID token from Google
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        _isLoading = false;
        _message = 'Failed to get ID token from Google';
        notifyListeners();
        return false;
      }

      // Send the ID token to the backend to get a JWT token
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/google'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'id_token': idToken,
        }),
      );

      final data = jsonDecode(response.body);
      final success = data['success'] as bool;

      _isLoading = false;
      _message = data['message'] as String;
      notifyListeners();

      if (success) {
        // Save the token to local storage
        final token = data['data']['token'] as String?;
        final name = data['data']['name'] as String?;
        final email = data['data']['email'] as String?;

        if (token != null) {
          await DataService.saveToken(token);
        }
      }

      return success;
    } catch (e) {
      _isLoading = false;
      _message = 'Sign in with Google failed: $e';
      notifyListeners();
      return false;
    }
  }
}