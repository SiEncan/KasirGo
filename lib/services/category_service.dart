import 'package:dio/dio.dart';
import 'dio_client.dart';

class CategoryException implements Exception {
  final String message;
  CategoryException(this.message);

  @override
  String toString() => message;
}

class CategoryService {
  final DioClient dioClient;

  CategoryService({required this.dioClient});

  Future<List<Map<String, dynamic>>> getAllCategories() async {
    try {
      final response = await dioClient.dio.get('/categories/');
      return List<Map<String, dynamic>>.from(response.data['data']);
    } on DioException catch (e) {
      // Check jika refresh token expired
      if (e.error != null && e.error.toString().contains('REFRESH_TOKEN_EXPIRED')) {
        throw Exception('REFRESH_TOKEN_EXPIRED');
      }
      
      if (e.response != null) {
        final errorMessage = e.response?.data['message'] ?? 'Gagal mengambil data kategori';
        throw CategoryException(errorMessage);
      } else {
        throw CategoryException('Gagal mengambil data kategori');
      }
    }
  }

  Future<void> createCategory(Map<String, dynamic> categoryData) async {
    try {
      await dioClient.dio.post('/category/create/', data: categoryData);
    } on DioException catch (e) {
      // Check jika refresh token expired
      if (e.error != null && e.error.toString().contains('REFRESH_TOKEN_EXPIRED')) {
        throw Exception('REFRESH_TOKEN_EXPIRED');
      }
      
      if (e.response != null) {
        final errorMessage = e.response?.data['message'] ?? 'Gagal membuat kategori';
        throw CategoryException(errorMessage);
      } else {
        throw CategoryException('Gagal membuat kategori');
      }
    }
  }

  Future<void> editCategory(int categoryId, Map<String, dynamic> categoryData) async {
    try {
      await dioClient.dio.patch('/category/$categoryId/', data: categoryData);
    } on DioException catch (e) {
      // Check jika refresh token expired
      if (e.error != null && e.error.toString().contains('REFRESH_TOKEN_EXPIRED')) {
        throw Exception('REFRESH_TOKEN_EXPIRED');
      }
      
      if (e.response != null) {
        final errorMessage = e.response?.data['message'] ?? 'Gagal mengubah kategori';
        throw CategoryException(errorMessage);
      } else {
        throw CategoryException('Gagal mengubah kategori');
      }
    }
  }

  Future<void> deleteCategory(int categoryId) async {
    try {
      await dioClient.dio.delete('/category/$categoryId/');
    } on DioException catch (e) {
      // Check jika refresh token expired
      if (e.error != null && e.error.toString().contains('REFRESH_TOKEN_EXPIRED')) {
        throw Exception('REFRESH_TOKEN_EXPIRED');
      }
      
      if (e.response != null) {
        final errorMessage = e.response?.data['message'] ?? 'Gagal menghapus kategori';
        throw CategoryException(errorMessage);
      } else {
        throw CategoryException('Gagal menghapus kategori');
      }
    }
  }
}