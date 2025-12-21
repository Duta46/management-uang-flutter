import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/api_repository.dart';
import '../models/api_models.dart' hide ApiResponse;
import '../models/api_response.dart' show ApiResponse;
import 'global_providers.dart';

final authStateProvider = StateProvider<User?>((ref) {
  return null;
});

final authProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
  return AuthNotifier(ref);
});

class AuthNotifier extends StateNotifier<User?> {
  Ref ref;

  AuthNotifier(this.ref) : super(null);

  Future<ApiResponse> login(String email, String password) async {
    final response = await ref.read(apiRepositoryProvider).login(email, password);

    if (response.success && response.data != null) {
      final userData = response.data['data'];
      final user = User(
        id: userData['user']['id'],
        name: userData['user']['name'],
        email: userData['user']['email'],
        token: userData['token'],
      );

      ref.read(apiRepositoryProvider).setAuthToken(user.token);
      state = user;

      return response;
    }

    return response;
  }

  Future<ApiResponse> register(String name, String email, String password) async {
    final response = await ref.read(apiRepositoryProvider).register(name, email, password);
    return response;
  }

  void logout() {
    ref.read(apiRepositoryProvider).setAuthToken(null);
    state = null;
  }
}