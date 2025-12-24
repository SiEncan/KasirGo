import 'package:dio/dio.dart';
import 'package:jwt_decode/jwt_decode.dart';
import '../utils/app_exception.dart';
import '../utils/token_storage.dart';
import 'auth_service.dart';

class DioClient {
  static const String baseUrl = "https://kasir-go-backend.vercel.app/api";
  // static const String baseUrl = "http://10.0.2.2:8000/api";
  // static const String baseUrl = "http://localhost:8000/api";

  final Dio _dio;
  final TokenStorage tokenStorage;
  final AuthService authService;

  DioClient({
    required this.tokenStorage,
    required this.authService,
  }) : _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 10),
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
          String? accessToken = await tokenStorage.getAccessToken();

          // Token null = session expired
          if (accessToken == null) {
            return handler.reject(
              DioException(
                requestOptions: options,
                error: AppException.sessionExpired(),
                type: DioExceptionType.cancel,
              ),
            );
          }

          // Refresh token if expiring soon
          if (_isTokenExpiringSoon(accessToken)) {
            try {
              await authService.refreshAccessToken();
              accessToken = await tokenStorage.getAccessToken();
            } catch (e) {
              final error =
                  e is AppException ? e : AppException.sessionExpired();
              return handler.reject(
                DioException(
                  requestOptions: options,
                  error: error,
                  type: DioExceptionType.cancel,
                ),
              );
            }
          }

          options.headers['Authorization'] = 'Bearer $accessToken';
          return handler.next(options);
        },
        onError: (error, handler) async {
          // Handle 401: Try refresh and retry
          if (error.response?.statusCode == 401) {
            try {
              await authService.refreshAccessToken();
              final newToken = await tokenStorage.getAccessToken();

              final options = error.requestOptions;
              options.headers['Authorization'] = 'Bearer $newToken';

              final response = await _dio.fetch(options);
              return handler.resolve(response);
            } catch (e) {
              // Propagate the actual error from refreshAccessToken
              final appError =
                  e is AppException ? e : AppException.sessionExpired();
              return handler.reject(
                DioException(
                  requestOptions: error.requestOptions,
                  error: appError,
                  type: DioExceptionType.cancel,
                ),
              );
            }
          }

          // Convert all errors to AppException
          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: _mapToAppException(error),
              type: error.type,
              response: error.response,
            ),
          );
        },
      ),
    );
  }

  /// Convert DioException to user-friendly AppException
  AppException _mapToAppException(DioException error) {
    // Timeout = Server tidak merespon (salah server)
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return AppException.serverTimeout();
    }

    // Connection error = Masalah internet user
    if (error.type == DioExceptionType.connectionError) {
      return AppException.network();
    }

    // Cancelled = session expired
    if (error.type == DioExceptionType.cancel) {
      return AppException.sessionExpired();
    }

    // Server error with message
    if (error.response != null) {
      final data = error.response?.data;
      if (data is Map) {
        final message = data['message'] ?? data['detail'];
        if (message != null) return AppException.server(message.toString());
      }
    }

    return AppException('Something went wrong. Please try again.');
  }

  bool _isTokenExpiringSoon(String token, {int gracePeriodSeconds = 60}) {
    try {
      final payload = Jwt.parseJwt(token);
      final exp = payload['exp'];
      if (exp == null) return true;

      final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      final timeUntilExpiry = expiryDate.difference(DateTime.now());

      return timeUntilExpiry.inSeconds < gracePeriodSeconds;
    } catch (e) {
      return true;
    }
  }
}
