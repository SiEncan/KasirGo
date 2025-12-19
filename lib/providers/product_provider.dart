import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/product_service.dart';
import 'category_provider.dart'; // Import for dioClientProvider

final productServiceProvider = Provider<ProductService>((ref) {
  final dioClient = ref.read(dioClientProvider);
  return ProductService(dioClient: dioClient);
});

class ProductState {
  final List<Map<String, dynamic>> products;
  final bool isLoading;

  ProductState({this.products = const [], this.isLoading = false});

  ProductState copyWith({
    List<Map<String, dynamic>>? products,
    bool? isLoading,
  }) {
    return ProductState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ProductNotifier extends StateNotifier<ProductState> {
  final ProductService productService;

  ProductNotifier(this.productService) : super(ProductState());

  Future<void> fetchAllProducts() async {
    final data = await productService.getAllProduct();
    state = state.copyWith(products: data);
  }

  Future<void> addProduct(Map<String, dynamic> payload) async {
    state = state.copyWith(isLoading: true);
    try {
      await productService.createProduct(payload);
      await fetchAllProducts();
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> editProduct(int productId, Map<String, dynamic> payload) async {
    state = state.copyWith(isLoading: true);
    try {
      await productService.editProduct(productId, payload);
      await fetchAllProducts();
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> deleteProduct(int productId) async {
    state = state.copyWith(isLoading: true);
    try {
      await productService.deleteProduct(productId);
      await fetchAllProducts();
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}

final productProvider =
    StateNotifierProvider<ProductNotifier, ProductState>((ref) {
  return ProductNotifier(ref.read(productServiceProvider));
});