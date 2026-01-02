import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jwt_decode/jwt_decode.dart';
import '../utils/app_exception.dart';
import '../utils/token_storage.dart';
import 'dio_client.dart';

class AuthService {
  // final String baseUrl = "https://kasir-go-backend.vercel.app/api";
  final String baseUrl = "http://10.0.2.2:8000/api";
  // final String baseUrl = "http://localhost:8000/api";
  final TokenStorage tokenStorage;
  DioClient? dioClient;

  AuthService({required this.tokenStorage, this.dioClient});

  /// Login using http package (no Dio to avoid circular dependency)
  Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse("$baseUrl/auth/login/");

    try {
      final response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "username": username,
              "password": password,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Hybrid Auth: Login to Firebase using Custom Token
        try {
          final accessToken = data['access'];
          final payload = Jwt.parseJwt(accessToken);
          final userId = payload['user_id'];
          await authenticateFirebase(userId, accessToken);
        } catch (e) {
          debugPrint("Firebase Login Warning: $e");
        }

        return data;
      } else {
        try {
          final errorJson = jsonDecode(response.body);
          if (errorJson['detail'] ==
              'No active account found with the given credentials') {
            throw AppException.server('Username or password is wrong');
          }
          throw AppException.server(errorJson['detail'] ?? 'Login failed');
        } on FormatException {
          throw AppException.server('Login failed');
        }
      }
    } on TimeoutException {
      throw AppException.serverTimeout(); // Server tidak merespon
    } on http.ClientException {
      throw AppException.network(); // Masalah internet user
    }
  }

  Future<String?> getUserId() async {
    final accessToken = await tokenStorage.getAccessToken();
    if (accessToken == null) return null;

    final payload = Jwt.parseJwt(accessToken);
    return payload['user_id'];
  }

  /// Refresh token using http package (no Dio to avoid circular dependency)
  Future<void> refreshAccessToken() async {
    final refreshToken = await tokenStorage.getRefreshToken();
    if (refreshToken == null) {
      await tokenStorage.clear();
      throw AppException.sessionExpired();
    }

    final url = Uri.parse("$baseUrl/auth/refresh/");

    try {
      final response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"refresh": refreshToken}),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await tokenStorage.saveTokens(
            data['access'], data['refresh'] ?? refreshToken);
      } else {
        await tokenStorage.clear();
        throw AppException.sessionExpired();
      }
    } on TimeoutException {
      throw AppException.serverTimeout(); // Server tidak merespon
    } on http.ClientException {
      throw AppException.network(); // Masalah internet user
    }
  }

  Future<Map<String, dynamic>> getProfile(String userId) async {
    try {
      final response = await dioClient!.dio.get('/user/$userId/');
      return response.data['data'];
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to fetch profile');
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
      throw _handleError(e, 'Failed to update profile');
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
      throw _handleError(e, 'Failed to change password');
    }
  }

  /// Get Custom Token from Backend and sign in to Firebase
  Future<void> authenticateFirebase(String userId, String accessToken) async {
    final url = Uri.parse("$baseUrl/auth/firebase-token/");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken"
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final String customToken = data['token'];

      await FirebaseAuth.instance.signInWithCustomToken(customToken);
      debugPrint("Firebase Custom Auth Success: User $userId");
    } else {
      // We log warning but don't crash standard login if Firebase fails
      debugPrint("Firebase Token Failed: ${response.body}");
    }
  }

  /// Extract AppException from DioException or create fallback
  AppException _handleError(DioException e, String fallback) {
    if (e.error is AppException) return e.error as AppException;
    return AppException(fallback);
  }
}
