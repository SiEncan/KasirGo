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

  AuthState({this.isLoading = false});
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService authService;
  final TokenStorage tokenStorage;

  AuthNotifier(this.authService, this.tokenStorage)
      : super(AuthState());

  Future<void> login(String username, String password) async {
    state = AuthState(isLoading: true);
    try {
      final result = await authService.login(username, password);
      await tokenStorage.saveTokens(result['access'], result['refresh']);
    } finally {
      state = AuthState(isLoading: false);
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
    state = AuthState(isLoading: true);
    try {
      final userId = await authService.getUserId();
      if (userId == null) throw AppException.sessionExpired();

      await authService.updateProfile(
        userId: userId,
        username: username,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
      );
    } finally {
      state = AuthState(isLoading: false);
    }
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    state = AuthState(isLoading: true);
    try {
      final userId = await authService.getUserId();
      if (userId == null) throw AppException.sessionExpired();

      await authService.changePassword(
        userId: userId,
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
    } finally {
      state = AuthState(isLoading: false);
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    final userId = await authService.getUserId();
    if (userId == null) throw AppException.sessionExpired();

    return await authService.getProfile(userId);
  }
}

final authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.read(authServiceProvider),
    ref.read(tokenStorageProvider),
  );
});