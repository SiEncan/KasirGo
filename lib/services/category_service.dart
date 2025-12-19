import 'package:dio/dio.dart';
import '../utils/app_exception.dart';
import 'dio_client.dart';

class CategoryService {
  final DioClient dioClient;

  CategoryService({required this.dioClient});

  Future<List<Map<String, dynamic>>> getAllCategories() async {
    try {
      final response = await dioClient.dio.get('/categories/');
      return List<Map<String, dynamic>>.from(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to fetch categories');
    }
  }

  Future<void> createCategory(Map<String, dynamic> categoryData) async {
    try {
      await dioClient.dio.post('/category/create/', data: categoryData);
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to create category');
    }
  }

  Future<void> editCategory(int categoryId, Map<String, dynamic> categoryData) async {
    try {
      await dioClient.dio.patch('/category/$categoryId/', data: categoryData);
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to edit category');
    }
  }

  Future<void> deleteCategory(int categoryId) async {
    try {
      await dioClient.dio.delete('/category/$categoryId/');
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to delete category');
    }
  }

  /// Extract AppException from DioException or create fallback
  AppException _handleError(DioException e, String fallback) {
    if (e.error is AppException) return e.error as AppException;
    return AppException(fallback);
  }
}