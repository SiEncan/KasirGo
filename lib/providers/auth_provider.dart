import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/dio_client.dart';
import '../utils/app_exception.dart';
import '../utils/token_storage.dart';

final tokenStorageProvider = Provider((ref) => TokenStorage());

final authServiceProvider = Provider((ref) {
  final tokenStorage = ref.read(tokenStorageProvider);
  final authService = AuthService(tokenStorage: tokenStorage);

  // Inject DioClient setelah AuthService created (avoid circular dependency)
  final dioClient = DioClient(
    tokenStorage: tokenStorage,
    authService: authService,
  );
  authService.dioClient = dioClient;

  return authService;
});

class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _service;
  final TokenStorage tokenStorage;

  AuthNotifier(this._service, this.tokenStorage) : super(AuthState());

  Future<void> login(String username, String password) async {
    state = AuthState(isLoading: true);
    try {
      final result = await _service.login(username, password);
      await tokenStorage.saveTokens(result['access'], result['refresh']);

      // Fetch profile to get Cafe ID
      final userId = await _service.getUserId();
      if (userId != null) {
        final profile = await _service.getProfile(userId);
        if (profile['cafe_id'] != null) {
          await tokenStorage.saveCafeId(profile['cafe_id']);
        }
      }
      state = AuthState(isLoading: false, isSuccess: true);
    } catch (e) {
      state = AuthState(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> logout() async {
    await tokenStorage.clear();
    state = AuthState();
  }

  Future<void> updateProfile({
    String? username,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
  }) async {
    state = AuthState(isLoading: true, isSuccess: false, errorMessage: null);
    try {
      final userId = await _service.getUserId();
      if (userId == null) throw AppException.sessionExpired();

      await _service.updateProfile(
        userId: userId,
        username: username,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
      );
      state = AuthState(isLoading: false, isSuccess: true);
    } catch (e) {
      state = AuthState(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    state = AuthState(isLoading: true, isSuccess: false, errorMessage: null);
    try {
      final userId = await _service.getUserId();
      if (userId == null) throw AppException.sessionExpired();

      await _service.changePassword(
        userId: userId,
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      state = AuthState(isLoading: false, isSuccess: true);
    } catch (e) {
      state = AuthState(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<Map<String, dynamic>?> getProfile() async {
    state = AuthState(isLoading: true, isSuccess: false, errorMessage: null);
    try {
      final userId = await _service.getUserId();
      if (userId == null) throw AppException.sessionExpired();

      state = AuthState(isLoading: false, isSuccess: true);
      return await _service.getProfile(userId);
    } catch (e) {
      state = AuthState(isLoading: false, errorMessage: e.toString());
      return null;
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.read(authServiceProvider),
    ref.read(tokenStorageProvider),
  );
});
