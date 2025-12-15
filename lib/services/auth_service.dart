import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decode/jwt_decode.dart';
import '../utils/token_storage.dart';

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
      throw Exception("Login failed: ${response.body}");
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

}