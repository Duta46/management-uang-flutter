import 'package:flutter/foundation.dart';
import '../repositories/api_repository.dart';
import '../models/api_models.dart';
import '../models/api_response.dart' as Response;
import '../services/auth_service.dart';
import 'global_providers.dart';

class AuthProvider extends ChangeNotifier {
  final ApiRepository _apiRepository = sharedApiRepository;
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String _message = '';
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String get message => _message;
  String? get errorMessage => _errorMessage;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setMessage(String message) {
    _message = message;
    notifyListeners();
  }

  void setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    print("AuthProvider: Attempting login with email: $email"); // Debug log
    setLoading(true);
    setErrorMessage(null);

    try {
      final Response.ApiResponse response = await _apiRepository.login(email, password);

      print("AuthProvider: Login response - success: ${response.success}"); // Debug log
      print("AuthProvider: Login response data: ${response.data}"); // Debug log

      if (response.success && response.data != null) {
        print("AuthProvider: Full response received: ${response}"); // Debug log
        print("AuthProvider: Response data: ${response.data}"); // Debug log
        print("AuthProvider: Response message: ${response.message}"); // Debug log

        final userData = response.data!['user'];
        final token = response.data!['token'];

        print("AuthProvider: Extracted user data: $userData"); // Debug log
        print("AuthProvider: Extracted token: $token"); // Debug log

        if (userData != null && token != null) {
          final user = User(
            id: int.tryParse(userData['id'].toString()) ?? 0,
            name: userData['name'],
            email: userData['email'],
            token: token,
          );

          await _authService.saveUser(user);
          _apiRepository.setAuthToken(user.token);
          print("AuthProvider: Token set to API Repository: ${user.token}"); // Debug log
          _currentUser = user; // Update current user
          notifyListeners(); // Notify to rebuild UI

          setMessage('Login berhasil');
          setLoading(false);
          print("AuthProvider: Login successful for user: ${user.name}"); // Debug log
          return true;
        } else {
          String errorMsg = 'User data or token is null';
          print("AuthProvider: $errorMsg"); // Debug log
          setErrorMessage(errorMsg);
          setLoading(false);
          return false;
        }
      } else {
        String errorMsg = response.message ?? 'Login gagal';
        print("AuthProvider: Login gagal - $errorMsg"); // Debug log
        setErrorMessage(errorMsg);
        setLoading(false);
        return false;
      }
    } catch (e) {
      print("AuthProvider: Login error occurred: $e"); // Debug log
      setErrorMessage(e.toString());
      setLoading(false);
      return false;
    }
  }

  Future<bool> register(String name, String email, String password, [String? confirmPassword]) async {
    setLoading(true);
    setErrorMessage(null);

    try {
      // The confirmPassword parameter is not sent to the API in this implementation
      // It's validated in the UI before calling this method
      final Response.ApiResponse response = await _apiRepository.register(name, email, password);

      if (response.success && response.data != null) {
        final responseData = response.data!;

        // Check if the API returns user and token (some APIs return auto-login after registration)
        if (responseData.containsKey('user') && responseData.containsKey('token')) {
          final userData = responseData['user'];
          final token = responseData['token'];

          final user = User(
            id: int.tryParse(userData['id'].toString()) ?? 0,
            name: userData['name'],
            email: userData['email'],
            token: token,
          );

          await _authService.saveUser(user);
          _apiRepository.setAuthToken(user.token);
          _currentUser = user; // Update current user
          notifyListeners();
        }

        setMessage('Pendaftaran berhasil');
        setLoading(false);
        return true;
      } else {
        setErrorMessage(response.message ?? 'Pendaftaran gagal');
        setLoading(false);
        return false;
      }
    } catch (e) {
      setErrorMessage(e.toString());
      setLoading(false);
      return false;
    }
  }


  Future<bool> logout() async {
    try {
      _apiRepository.setAuthToken(null);
      await _authService.clearUser();
      _currentUser = null; // Clear current user
      notifyListeners(); // Notify to rebuild UI
      setMessage('Berhasil logout');
      return true;
    } catch (e) {
      setErrorMessage(e.toString());
      return false;
    }
  }

  User? _currentUser;

  User? get currentUser => _currentUser;

  Future<User?> getCurrentUser() async {
    _currentUser = await _authService.getCurrentUser();
    notifyListeners();
    return _currentUser;
  }

  Future<void> loadCurrentUser() async {
    _currentUser = await _authService.getCurrentUser();
    if (_currentUser != null && _currentUser?.token != null) {
      _apiRepository.setAuthToken(_currentUser!.token);
      print("AuthProvider: Loaded user token from storage and set to API repository: ${_currentUser!.token}"); // Debug log
    } else {
      print("AuthProvider: No user token found in storage"); // Debug log
    }
    notifyListeners();
  }
}