import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/product_service.dart';
import 'category_provider.dart'; // Import for dioClientProvider

final productServiceProvider = Provider<ProductService>((ref) {
  final dioClient = ref.read(dioClientProvider);
  return ProductService(dioClient: dioClient);
});

class ProductState {
  final List<Map<String, dynamic>> products;

  ProductState({this.products = const []});
}

class ProductNotifier extends StateNotifier<ProductState> {
  final ProductService productService;

  ProductNotifier(this.productService) : super(ProductState());

  Future<void> fetchAllProducts() async {
    try {
      final data = await productService.getAllProduct();
      state = ProductState(products: data);
    } catch (e) {
      // Auto logout jika refresh token expired
      if (e.toString().contains('REFRESH_TOKEN_EXPIRED')) {
        // Token sudah di-clear di auth_service, throw error untuk UI handle
        throw Exception('Session expired. Please login again.');
      }
      
      rethrow;
    }
  }

  Future<void> addProduct(Map<String, dynamic> payload) async {
    try {
      await productService.createProduct(payload);

      // Refresh daftar produk setelah penambahan
      await fetchAllProducts();

    } catch (e) {
      rethrow;
    }
  }

  Future<void> editProduct(int productId, Map<String, dynamic> payload) async {
    try {
      await productService.editProduct(productId, payload);

      // Refresh daftar produk setelah pengeditan
      await fetchAllProducts();

    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteProduct(int productId) async {
    try {
      await productService.deleteProduct(productId);
      await fetchAllProducts();

    } catch (e) {
      rethrow;
    }
  }
}

final productProvider =
    StateNotifierProvider<ProductNotifier, ProductState>((ref) {
  return ProductNotifier(ref.read(productServiceProvider));
});