import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/product_service.dart';
import 'auth_provider.dart';

final productServiceProvider = Provider<ProductService>((ref) {
  final tokenStorage = ref.read(tokenStorageProvider);
  final authService = ref.read(authServiceProvider);

  return ProductService(
    tokenStorage: tokenStorage,
    authService: authService,
  );
});

class ProductState {
  final bool isLoading;
  final List<Map<String, dynamic>> products;

  ProductState({
    this.isLoading = false,
    this.products = const [],
  });

  ProductState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? products,
  }) {
    return ProductState(
      isLoading: isLoading ?? this.isLoading,
      products: products ?? this.products,
    );
  }
}

class ProductNotifier extends StateNotifier<ProductState> {
  final ProductService productService;

  ProductNotifier(this.productService) : super(ProductState());

  Future<void> fetchAllProducts() async {
    state = state.copyWith(isLoading: true);

    try {
      final data = await productService.getAllProduct();
      state = state.copyWith(isLoading: false, products: data);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> addProduct(Map<String, dynamic> payload) async {
    state = state.copyWith(isLoading: true);

    try {
      await productService.createProduct(payload);

      // Refresh daftar produk setelah penambahan
      await fetchAllProducts();

    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> editProduct(int productId, Map<String, dynamic> payload) async {
    state = state.copyWith(isLoading: true);

    try {
      await productService.editProduct(productId, payload);

      // Refresh daftar produk setelah pengeditan
      await fetchAllProducts();

    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> deleteProduct(int productId) async {
    state = state.copyWith(isLoading: true);

    try {
      await productService.deleteProduct(productId);
      await fetchAllProducts();

    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }
}

final productProvider =
    StateNotifierProvider<ProductNotifier, ProductState>((ref) {
  return ProductNotifier(ref.read(productServiceProvider));
});