import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/product_service.dart';
import 'category_provider.dart';

final productServiceProvider = Provider<ProductService>((ref) {
  final dioClient = ref.read(dioClientProvider);
  return ProductService(dioClient: dioClient);
});

class ProductState {
  final List<Map<String, dynamic>> products;
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  ProductState({
    this.products = const [],
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  ProductState copyWith({
    List<Map<String, dynamic>>? products,
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return ProductState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class ProductNotifier extends StateNotifier<ProductState> {
  final ProductService _service;

  ProductNotifier(this._service) : super(ProductState());

  Future<void> fetchAllProducts() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final data = await _service.getAllProduct();
      state = state.copyWith(isLoading: false, products: data);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> addProduct(Map<String, dynamic> payload) async {
    state =
        state.copyWith(isLoading: true, errorMessage: null, isSuccess: false);
    try {
      await _service.createProduct(payload);
      await fetchAllProducts();
      state = state.copyWith(isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> editProduct(int productId, Map<String, dynamic> payload) async {
    state =
        state.copyWith(isLoading: true, errorMessage: null, isSuccess: false);
    try {
      await _service.editProduct(productId, payload);
      await fetchAllProducts();
      state = state.copyWith(isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> deleteProduct(int productId) async {
    state =
        state.copyWith(isLoading: true, errorMessage: null, isSuccess: false);
    try {
      await _service.deleteProduct(productId);
      await fetchAllProducts();
      state = state.copyWith(isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

final productProvider =
    StateNotifierProvider<ProductNotifier, ProductState>((ref) {
  return ProductNotifier(ref.read(productServiceProvider));
});
