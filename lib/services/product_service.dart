import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'dio_client.dart';

class ProductException implements Exception {
  final String message;
  ProductException(this.message);

  @override
  String toString() => message;
}

class ProductService {
  final DioClient dioClient;

  ProductService({required this.dioClient});

  Future<List<Map<String, dynamic>>> getAllProduct() async {
    try {
      final response = await dioClient.dio.get('/products/');
      return List<Map<String, dynamic>>.from(response.data['data']);
    } on DioException catch (e) {
      // Check jika refresh token expired
      if (e.error != null && e.error.toString().contains('REFRESH_TOKEN_EXPIRED')) {
        throw Exception('REFRESH_TOKEN_EXPIRED');
      }
      
      if (e.response != null) {
        final errorMessage = e.response?.data['message'] ?? 'Gagal mengambil data produk';
        throw ProductException(errorMessage);
      } else {
        throw ProductException('Gagal mengambil data produk');
      }
    }
  }

  Future<void> createProduct(Map<String, dynamic> productData) async {
    try {
      final formData = FormData.fromMap({
        'name': productData['name'],
        'description': productData['description'],
        'price': productData['price'].toString(),
        'cost': productData['cost'].toString(),
        'stock': productData['stock'].toString(),
        'sku': productData['sku'],
        'category': productData['category'].toString(),
        'is_available': productData['is_available'] ? 'true' : 'false',
      });

      final XFile? image = productData['image'];
      if (image != null) {
        formData.files.add(
          MapEntry(
            'image',
            await MultipartFile.fromFile(image.path, filename: image.name),
          ),
        );
      }

      await dioClient.dio.post('/product/create/', data: formData);
    } on DioException catch (e) {
      // Check jika refresh token expired
      if (e.error != null && e.error.toString().contains('REFRESH_TOKEN_EXPIRED')) {
        throw Exception('REFRESH_TOKEN_EXPIRED');
      }
      
      if (e.response != null) {
        final errorMessage = e.response?.data['message'] ?? 'Gagal membuat produk';
        throw ProductException(errorMessage);
      } else {
        throw ProductException('Gagal membuat produk');
      }
    }
  }

  Future<void> editProduct(int productId, Map<String, dynamic> productData) async {
    try {
      final formData = FormData.fromMap({
        'name': productData['name'],
        'description': productData['description'],
        'price': productData['price'].toString(),
        'cost': productData['cost'].toString(),
        'stock': productData['stock'].toString(),
        'sku': productData['sku'],
        'category': productData['category'].toString(),
        'is_available': productData['is_available'] ? 'true' : 'false',
      });

      final XFile? image = productData['image'];
      if (image != null) {
        formData.files.add(
          MapEntry(
            'image',
            await MultipartFile.fromFile(image.path, filename: image.name),
          ),
        );
      }

      await dioClient.dio.patch('/product/$productId/', data: formData);
    } on DioException catch (e) {
      // Check jika refresh token expired
      if (e.error != null && e.error.toString().contains('REFRESH_TOKEN_EXPIRED')) {
        throw Exception('REFRESH_TOKEN_EXPIRED');
      }
      
      if (e.response != null) {
        final errorMessage = e.response?.data['message'] ?? 'Gagal mengubah produk';
        throw ProductException(errorMessage);
      } else {
        throw ProductException('Gagal mengubah produk');
      }
    }
  }

  Future<void> deleteProduct(int productId) async {
    try {
      await dioClient.dio.delete('/product/$productId/');
    } on DioException catch (e) {
      // Check jika refresh token expired
      if (e.error != null && e.error.toString().contains('REFRESH_TOKEN_EXPIRED')) {
        throw Exception('REFRESH_TOKEN_EXPIRED');
      }
      
      if (e.response != null) {
        final errorMessage = e.response?.data['message'] ?? 'Gagal menghapus produk';
        throw ProductException(errorMessage);
      } else {
        throw ProductException('Gagal menghapus produk');
      }
    }
  }

}