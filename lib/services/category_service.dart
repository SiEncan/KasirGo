import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decode/jwt_decode.dart';
import '../utils/token_storage.dart';
import 'auth_service.dart';

class CategoryException implements Exception {
  final String message;
  CategoryException(this.message);

  @override
  String toString() => message;
}

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

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(jsonBody['data']);
    } else {
      try {
        final errorJson = jsonDecode(response.body);
        throw CategoryException(errorJson['message'] ?? 'Gagal mengambil data kategori');
      } on FormatException {
        throw CategoryException('Gagal mengambil data kategori');
      }
    }
  }

  Future<void> createCategory(Map<String, dynamic> categoryData) async {
    String? accessToken = await tokenStorage.getAccessToken();

    if (accessToken == null || Jwt.isExpired(accessToken)) {
      try {
        await authService.refreshAccessToken();
        accessToken = await tokenStorage.getAccessToken();
      } catch (e) {
        throw Exception("Token expired, user harus login lagi");
      }
    }

    final uri = Uri.parse("$baseUrl/category/create/");
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(categoryData),
    );

    if (response.statusCode != 201) {
      try {
        final errorJson = jsonDecode(response.body);
        throw CategoryException(errorJson['message'] ?? 'Gagal membuat kategori');
      } on FormatException {
        throw CategoryException('Gagal membuat kategori');
      }
    }
  }

  Future<void> editCategory(int categoryId, Map<String, dynamic> categoryData) async {
    String? accessToken = await tokenStorage.getAccessToken();

    if (accessToken == null || Jwt.isExpired(accessToken)) {
      try {
        await authService.refreshAccessToken();
        accessToken = await tokenStorage.getAccessToken();
      } catch (e) {
        throw Exception("Token expired, user harus login lagi");
      }
    }

    final uri = Uri.parse("$baseUrl/category/$categoryId/");
    final response = await http.patch(
      uri,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(categoryData),
    );

    if (response.statusCode != 200) {
      try {
        final errorJson = jsonDecode(response.body);
        throw CategoryException(errorJson['message'] ?? 'Gagal mengubah kategori');
      } on FormatException {
        throw CategoryException('Gagal mengubah kategori');
      }
    }
  }

  Future<void> deleteCategory(int categoryId) async {
    String? accessToken = await tokenStorage.getAccessToken();

    if (accessToken == null || Jwt.isExpired(accessToken)) {
      try {
        await authService.refreshAccessToken();
        accessToken = await tokenStorage.getAccessToken();
      } catch (e) {
        throw Exception("Token expired, user harus login lagi");
      }
    }

    final uri = Uri.parse("$baseUrl/category/$categoryId/");
    final response = await http.delete(
      uri,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      try {
        final errorJson = jsonDecode(response.body);
        throw CategoryException(errorJson['message'] ?? 'Gagal menghapus kategori');
      } on FormatException {
        throw CategoryException('Gagal menghapus kategori');
      }
    }
  }

}