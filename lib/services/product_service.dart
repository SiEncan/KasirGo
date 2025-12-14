import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:jwt_decode/jwt_decode.dart';
import '../utils/token_storage.dart';
import 'auth_service.dart';

class ProductService {
  final String baseUrl = "http://10.0.2.2:8000/api";
  // final String baseUrl = "http://localhost:8000/api";
  final TokenStorage tokenStorage;
  final AuthService authService;

  ProductService({required this.tokenStorage, required this.authService});

  Future<List<Map<String, dynamic>>> getAllProduct() async {
    String? accessToken = await tokenStorage.getAccessToken();

    if (accessToken == null || Jwt.isExpired(accessToken)) {
      try {
        await authService.refreshAccessToken();
        accessToken = await tokenStorage.getAccessToken();
      } catch (e) {
        throw Exception("Token expired, user harus login lagi");
      }
    }

    final url = Uri.parse("$baseUrl/products/");
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

  Future<void> createProduct(Map<String, dynamic> productData) async {
    String? accessToken = await tokenStorage.getAccessToken();

    if (accessToken == null || Jwt.isExpired(accessToken)) {
      try {
        await authService.refreshAccessToken();
        accessToken = await tokenStorage.getAccessToken();
      } catch (e) {
        throw Exception("Token expired, user harus login lagi");
      }
    }

    final uri = Uri.parse("$baseUrl/product/create/");
    final request = http.MultipartRequest("POST", uri);

    request.headers['Authorization'] = 'Bearer $accessToken';

    request.fields['name'] = productData['name'];
    request.fields['description'] = productData['description'];
    request.fields['price'] = productData['price'].toString();
    request.fields['cost'] = productData['cost'].toString();
    request.fields['stock'] = productData['stock'].toString();
    request.fields['sku'] = productData['sku'];
    request.fields['category'] = productData['category'].toString();
    request.fields['is_available'] = productData['is_available'] ? 'true' : 'false';

    final XFile? image = productData['image'];

    if (image != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          image.path,
        ),
      );
    }

    final response = await request.send();

    if (response.statusCode != 201) {
      final body = await response.stream.bytesToString();
      throw Exception("Failed to create product: $body");
    }
  }

  Future<void> editProduct(int productId, Map<String, dynamic> productData) async {
    String? accessToken = await tokenStorage.getAccessToken();

    if (accessToken == null || Jwt.isExpired(accessToken)) {
      try {
        await authService.refreshAccessToken();
        accessToken = await tokenStorage.getAccessToken();
      } catch (e) {
        throw Exception("Token expired, You must log in again");
      }
    }

    final uri = Uri.parse("$baseUrl/product/$productId/");
    final request = http.MultipartRequest("PATCH", uri);

    request.headers['Authorization'] = 'Bearer $accessToken';

    request.fields['name'] = productData['name'];
    request.fields['description'] = productData['description'];
    request.fields['price'] = productData['price'].toString();
    request.fields['cost'] = productData['cost'].toString();
    request.fields['stock'] = productData['stock'].toString();
    request.fields['sku'] = productData['sku'];
    request.fields['category'] = productData['category'].toString();
    request.fields['is_available'] = productData['is_available'] ? 'true' : 'false';

    final XFile? image = productData['image'];

    if (image != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          image.path,
        ),
      );
    }

    final response = await request.send();

    if (response.statusCode != 200) {
      final body = await response.stream.bytesToString();
      throw Exception("Failed to edit product: $body");
    }
  }

  Future<void> deleteProduct(int productId) async {
    String? accessToken = await tokenStorage.getAccessToken();

    if (accessToken == null || Jwt.isExpired(accessToken)) {
      try {
        await authService.refreshAccessToken();
        accessToken = await tokenStorage.getAccessToken();
      } catch (e) {
        throw Exception("Token expired, You must log in again");
      }
    }

    final uri = Uri.parse("$baseUrl/product/$productId/");
    final response = await http.delete(
      uri,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to delete product: ${response.body}");
    }
  }

}