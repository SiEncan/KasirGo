import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../utils/token_storage.dart';

final authServiceProvider = Provider((ref) => AuthService(tokenStorage: TokenStorage()));
final tokenStorageProvider = Provider((ref) => TokenStorage());

class AuthState {
  final bool isLoading;
  final String? error;

  AuthState({this.isLoading = false, this.error});
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService authService;
  final TokenStorage tokenStorage;

  AuthNotifier(this.authService, this.tokenStorage)
      : super(AuthState());

  Future<bool> login(String email, String password) async {
    state = AuthState(isLoading: true);

    try {
      final result = await authService.login(email, password);

      await tokenStorage.saveTokens(
        result['access'],
        result['refresh'],
      );

      state = AuthState(isLoading: false);
      return true;

    } catch (e) {
      state = AuthState(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await tokenStorage.clear();
    state = AuthState(); // reset state
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

  final accessToken = await tokenStorage.getAccessToken();
  if (accessToken == null) throw Exception("User not logged in");

  final userId = await authService.getUserId();
  if (userId == null) throw Exception("User ID not found in token");

  final profile = await authService.getProfile(userId);
  return profile;
});