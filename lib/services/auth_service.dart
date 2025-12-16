import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decode/jwt_decode.dart';
import '../utils/token_storage.dart';
import 'dio_client.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  
  @override
  String toString() => message; // Tanpa prefix "Exception:"
}

class AuthService {
  final String baseUrl = "http://10.0.2.2:8000/api";
  // final String baseUrl = "http://localhost:8000/api";
  final TokenStorage tokenStorage;
  DioClient? dioClient; // Optional untuk avoid circular dependency

  AuthService({required this.tokenStorage, this.dioClient});

  Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse("$baseUrl/auth/login/");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      try {
        final errorJson = jsonDecode(response.body);
        if (errorJson['detail'] == 'No active account found with the given credentials') {
          throw AuthException('Username or password is wrong');
        }
        throw AuthException(errorJson['detail']);
      } on FormatException {
        throw AuthException('Login gagal');
      }
    }
  }

  Future<String?> getUserId() async {
    final accessToken = await tokenStorage.getAccessToken();
    if (accessToken == null) return null;

    final payload = Jwt.parseJwt(accessToken);
    return payload['user_id'];
  }

  Future<void> refreshAccessToken() async {
    final refreshToken = await tokenStorage.getRefreshToken();
    if (refreshToken == null) {
      await tokenStorage.clear();
      throw AuthException("REFRESH_TOKEN_EXPIRED");
    }

    final url = Uri.parse("$baseUrl/auth/refresh/");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"refresh": refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await tokenStorage.saveTokens(data['access'], data['refresh'] ?? refreshToken);
    } else {
      // refresh gagal maka logout
      print('Refresh token expired or invalid');
      await tokenStorage.clear();
      throw AuthException("REFRESH_TOKEN_EXPIRED");
    }
  }

  Future<Map<String, dynamic>> getProfile(String userId) async {
    try {
      final response = await dioClient!.dio.get('/user/$userId/');
      return response.data['data'];
    } on DioException catch (e) {
      // Preserve REFRESH_TOKEN_EXPIRED error
      if (e.error != null && e.error.toString().contains('REFRESH_TOKEN_EXPIRED')) {
        throw Exception('REFRESH_TOKEN_EXPIRED');
      }
      
      if (e.response != null) {
        throw Exception("Failed to fetch profile: ${e.response?.data}");
      } else {
        throw Exception("Failed to fetch profile");
      }
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String userId,
    String? username,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
  }) async {
    try {
      final response = await dioClient!.dio.patch(
        '/user/$userId/',
        data: {
          if (username != null) 'username': username,
          if (firstName != null) 'first_name': firstName,
          if (lastName != null) 'last_name': lastName,
          if (email != null) 'email': email,
          if (phone != null) 'phone': phone,
        },
      );
      return response.data['data'];
    } on DioException catch (e) {
      throw Exception("Failed to update profile: ${e.response?.data}");
    }
  }

  Future<void> changePassword({
    required String userId,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await dioClient!.dio.post(
        '/user/$userId/change-password/',
        data: {
          'old_password': oldPassword,
          'new_password': newPassword,
        },
      );
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage = e.response?.data['message'] ?? 'Failed to change password';
        throw AuthException(errorMessage);
      } else {
        throw AuthException("Failed to change password");
      }
    }
  }

}