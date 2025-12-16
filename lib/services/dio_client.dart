import 'package:dio/dio.dart';
import 'package:jwt_decode/jwt_decode.dart';
import '../utils/token_storage.dart';
import 'auth_service.dart';

class DioClient {
  static const String baseUrl = "http://10.0.2.2:8000/api";
  // static const String baseUrl = "http://localhost:8000/api";

  final Dio _dio;
  final TokenStorage tokenStorage;
  final AuthService authService;

  DioClient({
    required this.tokenStorage,
    required this.authService,
  }) : _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
          },
        )) {
    _setupInterceptors();
  }

  Dio get dio => _dio;

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // PREVENTIVE: Check token expired & refresh sebelum request
          String? accessToken = await tokenStorage.getAccessToken();
          
          // Jika token null (sudah di-clear karena refresh expired), reject request
          if (accessToken == null) {
            return handler.reject(
              DioException(
                requestOptions: options,
                error: 'REFRESH_TOKEN_EXPIRED',
                type: DioExceptionType.cancel,
              ),
            );
          }
          
          if (_isTokenExpiringSoon(accessToken)) {
            try {
              // Refresh token preventively (sebelum request)
              await authService.refreshAccessToken();
              accessToken = await tokenStorage.getAccessToken();
            } catch (e) {
              // Jika refresh token expired, cancel request dan throw error
              if (e.toString().contains('REFRESH_TOKEN_EXPIRED')) {
                return handler.reject(
                  DioException(
                    requestOptions: options,
                    error: 'REFRESH_TOKEN_EXPIRED',
                    type: DioExceptionType.cancel,
                  ),
                );
              }
            }
          }
          
          // Auto inject token ke setiap request
          options.headers['Authorization'] = 'Bearer $accessToken';
          return handler.next(options);
        },
        onError: (error, handler) async {
          // REACTIVE: Auto refresh token dan retry jika dapat 401 (safety net)
          if (error.response?.statusCode == 401) {
            try {
              // Refresh token
              await authService.refreshAccessToken();
              final newToken = await tokenStorage.getAccessToken();

              // Retry request dengan token baru
              final options = error.requestOptions;
              options.headers['Authorization'] = 'Bearer $newToken';

              // Resolve dengan response baru (no throw, langsung return success)
              final response = await _dio.fetch(options);
              return handler.resolve(response);
            } catch (e) {
              // Jika refresh token expired, reject dengan error yang jelas
              if (e.toString().contains('REFRESH_TOKEN_EXPIRED')) {
                return handler.reject(
                  DioException(
                    requestOptions: error.requestOptions,
                    error: 'REFRESH_TOKEN_EXPIRED',
                    type: DioExceptionType.cancel,
                  ),
                );
              }
              // Jika error lain, lempar error original
              return handler.next(error);
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  // Helper: cek token akan expired dalam 60 detik (grace period untuk clock skew)
  bool _isTokenExpiringSoon(String token, {int gracePeriodSeconds = 60}) {
    try {
      final payload = Jwt.parseJwt(token);
      final exp = payload['exp'];
      if (exp == null) return true;
      
      final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      final now = DateTime.now();
      final timeUntilExpiry = expiryDate.difference(now);
      
      // Refresh jika kurang dari grace period
      return timeUntilExpiry.inSeconds < gracePeriodSeconds;
    } catch (e) {
      return true; // Jika error parsing, anggap expired
    }
  }
}
