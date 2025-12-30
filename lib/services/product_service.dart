import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/app_exception.dart';
import 'dio_client.dart';

class ProductService {
  final DioClient dioClient;

  ProductService({required this.dioClient});

  Future<List<Map<String, dynamic>>> getAllProduct() async {
    try {
      final response = await dioClient.dio.get('/products/');
      return List<Map<String, dynamic>>.from(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to fetch products');
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
        'needs_preparation':
            productData['needs_preparation'] ? 'true' : 'false',
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
      throw _handleError(e, 'Failed to create product');
    }
  }

  Future<void> editProduct(
      int productId, Map<String, dynamic> productData) async {
    try {
      final formData = FormData.fromMap({
        'name': productData['name'],
        'description': productData['description'],
        'price': productData['price'].toString(),
        'cost': productData['cost'].toString(),
        'stock': productData['stock'].toString(),
        'sku': productData['sku'],
        'category': productData['category'].toString(),
        'needs_preparation':
            productData['needs_preparation'] ? 'true' : 'false',
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
      throw _handleError(e, 'Failed to edit product');
    }
  }

  Future<void> deleteProduct(int productId) async {
    try {
      await dioClient.dio.delete('/product/$productId/');
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to delete product');
    }
  }

  /// Extract AppException from DioException or create fallback
  AppException _handleError(DioException e, String fallback) {
    if (e.error is AppException) return e.error as AppException;
    return AppException(fallback);
  }
}
