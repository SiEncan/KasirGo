import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decode/jwt_decode.dart';
import '../utils/token_storage.dart';
import 'auth_service.dart';

class CategoryService {
  final String baseUrl = "http://10.0.2.2:8000/api";
  // final String baseUrl = "http://localhost:8000/api";

  final TokenStorage tokenStorage;
  final AuthService authService;

  CategoryService({required this.tokenStorage, required this.authService});

  Future<List<Map<String, dynamic>>> getAllCategories() async {
    String? accessToken = await tokenStorage.getAccessToken();

    if (accessToken == null || Jwt.isExpired(accessToken)) {
      try {
        await authService.refreshAccessToken();
        accessToken = await tokenStorage.getAccessToken();
      } catch (e) {
        throw Exception("Token expired, user harus login lagi");
      }
    }

    final url = Uri.parse("$baseUrl/categories/");
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    final jsonBody = jsonDecode(response.body);
    
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonBody['data']);
    } else {
      throw Exception("Failed to fetch profile: ${response.body}");
    }
  }

}