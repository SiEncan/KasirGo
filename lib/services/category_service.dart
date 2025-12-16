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
        final errorMessage = e.response?.data['message'] ?? 'Failed to fetch categories';
        throw CategoryException(errorMessage);
      } else {
        throw CategoryException('Failed to fetch categories');
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
        final errorMessage = e.response?.data['message'] ?? 'Failed to create category';
        throw CategoryException(errorMessage);
      } else {
        throw CategoryException('Failed to create category');
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
        final errorMessage = e.response?.data['message'] ?? 'Failed to edit category';
        throw CategoryException(errorMessage);
      } else {
        throw CategoryException('Failed to edit category');
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
        final errorMessage = e.response?.data['message'] ?? 'Failed to delete category';
        throw CategoryException(errorMessage);
      } else {
        throw CategoryException('Failed to delete category');
      }
    }
  }
}