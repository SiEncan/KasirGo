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
  final String? error;
  final List<Map<String, dynamic>> products;

  ProductState({
    this.isLoading = false,
    this.error,
    this.products = const [],
  });

  ProductState copyWith({
    bool? isLoading,
    String? error,
    List<Map<String, dynamic>>? products,
  }) {
    return ProductState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      products: products ?? this.products,
    );
  }
}

class ProductNotifier extends StateNotifier<ProductState> {
  final ProductService productService;

  ProductNotifier(this.productService) : super(ProductState());

  Future<void> fetchAllProducts() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final data = await productService.getAllProduct();
      state = state.copyWith(isLoading: false, products: data);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addProduct(Map<String, dynamic> payload) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await productService.createProduct(payload);

      // Refresh daftar produk setelah penambahan
      await fetchAllProducts();

    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> editProduct(int productId, Map<String, dynamic> payload) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await productService.editProduct(productId, payload);

      // Refresh daftar produk setelah pengeditan
      await fetchAllProducts();

    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> deleteProduct(int productId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await productService.deleteProduct(productId);
      await fetchAllProducts();

    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

final productProvider =
    StateNotifierProvider<ProductNotifier, ProductState>((ref) {
  return ProductNotifier(ref.read(productServiceProvider));
});