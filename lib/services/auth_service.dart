import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decode/jwt_decode.dart';
import '../utils/token_storage.dart';

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

  AuthService({required this.tokenStorage});

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
    if (refreshToken == null) throw Exception("No refresh token");

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
      await tokenStorage.clear();
      throw Exception("Refresh token failed");
    }
  }

  Future<Map<String, dynamic>> getProfile(String userId) async {
    String? accessToken = await tokenStorage.getAccessToken();

    if (accessToken == null || Jwt.isExpired(accessToken)) {
      try {
        await refreshAccessToken();
        accessToken = await tokenStorage.getAccessToken();
      } catch (e) {
        throw Exception("Token expired, user harus login lagi");
      }
    }

    final url = Uri.parse("$baseUrl/user/$userId/");
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    final Map<String, dynamic> jsonBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return jsonBody['data'];
    } else {
      throw Exception("Failed to fetch profile: ${response.body}");
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
    String? accessToken = await tokenStorage.getAccessToken();

    if (accessToken == null || Jwt.isExpired(accessToken)) {
      try {
        await refreshAccessToken();
        accessToken = await tokenStorage.getAccessToken();
      } catch (e) {
        throw Exception("Token expired, user harus login lagi");
      }
    }

    final url = Uri.parse("$baseUrl/user/$userId/");
    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        if (username != null) 'username': username,
        if (firstName != null) 'first_name': firstName,
        if (lastName != null) 'last_name': lastName,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
      }),
    );

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      return jsonBody['data'];
    } else {
      throw Exception("Failed to update profile: ${response.body}");
    }
  }

  Future<void> changePassword({
    required String userId,
    required String oldPassword,
    required String newPassword,
  }) async {
    String? accessToken = await tokenStorage.getAccessToken();

    if (accessToken == null || Jwt.isExpired(accessToken)) {
      try {
        await refreshAccessToken();
        accessToken = await tokenStorage.getAccessToken();
      } catch (e) {
        throw Exception("Token expired, user harus login lagi");
      }
    }

    final url = Uri.parse("$baseUrl/user/$userId/change-password/");
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'old_password': oldPassword,
        'new_password': newPassword,
      }),
    );

    if (response.statusCode != 200) {
      // Debug: Print response untuk lihat format sebenarnya
      print('=== Change Password Error Debug ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('Response Body Type: ${response.body.runtimeType}');
      
      try {
        final errorData = jsonDecode(response.body);
        print('Parsed JSON successfully: $errorData');
        final errorMessage = errorData['message'] ?? 'Failed to change password';
        print('Error message extracted: $errorMessage');
        throw AuthException(errorMessage);
      } on FormatException catch (e) {
        // Jika JSON parse gagal
        print('JSON parse failed with FormatException: $e');
        throw AuthException("Failed to change password: ${response.body}");
      }
      // Exception dari throw AuthException(errorMessage) akan langsung propagate ke caller
    }
  }

}