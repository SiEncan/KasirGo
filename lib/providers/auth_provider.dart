import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/dio_client.dart';
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
      await tokenStorage.saveTokens(
        result['access'],
        result['refresh'],
      );

      state = AuthState(isLoading: false);
    } catch (e) {
      state = AuthState(isLoading: false);
      rethrow; // Re-throw agar bisa di-catch di UI
    }
  }

  Future<void> logout() async {
    await tokenStorage.clear();
    state = AuthState(); // reset state
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
      if (userId == null) throw Exception("User not logged in");

      await authService.updateProfile(
        userId: userId,
        username: username,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
      );

      state = AuthState(isLoading: false);
    } catch (e) {
      state = AuthState(isLoading: false);
      rethrow; // Re-throw agar bisa di-catch di UI
    }
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    state = AuthState(isLoading: true);

    try {
      final userId = await authService.getUserId();
      if (userId == null) throw Exception("User not logged in");

      await authService.changePassword(userId: userId, oldPassword: oldPassword, newPassword: newPassword);
      state = AuthState(isLoading: false);
    } catch (e) {
      state = AuthState(isLoading: false);
      rethrow; // Re-throw agar bisa di-catch di UI
    }
  }

  /// Get current user profile
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final userId = await authService.getUserId();
      if (userId == null) throw Exception("User not logged in");

      return await authService.getProfile(userId);
    } catch (e) {
      rethrow;
    }
  }
}

final authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.read(authServiceProvider),
    ref.read(tokenStorageProvider),
  );
});

final userProfileProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final authService = ref.read(authServiceProvider);
  final tokenStorage = ref.read(tokenStorageProvider);

  try {
    final accessToken = await tokenStorage.getAccessToken();
    if (accessToken == null) throw Exception("User not logged in");

    final userId = await authService.getUserId();
    if (userId == null) throw Exception("User ID not found in token");

    // Add timeout to prevent infinite loading
    final profile = await authService.getProfile(userId).timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        throw Exception("Request timeout - Please check your connection");
      },
    );
    
    return profile;
  } catch (e) {
    rethrow;
  }
});