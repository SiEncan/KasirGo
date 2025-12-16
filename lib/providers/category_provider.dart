import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/category_service.dart';
import '../services/dio_client.dart';
import 'auth_provider.dart';
import 'product_provider.dart';

final dioClientProvider = Provider<DioClient>((ref) {
  final tokenStorage = ref.read(tokenStorageProvider);
  final authService = ref.read(authServiceProvider);

  return DioClient(
    tokenStorage: tokenStorage,
    authService: authService,
  );
});

final categoryServiceProvider = Provider<CategoryService>((ref) {
  final dioClient = ref.read(dioClientProvider);
  return CategoryService(dioClient: dioClient);
});

class CategoryState {
  final List<Map<String, dynamic>> categories;

  CategoryState({this.categories = const []});
}

class CategoryNotifier extends StateNotifier<CategoryState> {
  final CategoryService service;
  final Ref ref;

  CategoryNotifier(this.service, this.ref) : super(CategoryState());

  Future<void> fetchAllCategories() async {
    try {
      final data = await service.getAllCategories();
      state = CategoryState(categories: data);
    } catch (e) {
      // Auto logout jika refresh token expired
      if (e.toString().contains('REFRESH_TOKEN_EXPIRED')) {
        // Token sudah di-clear di auth_service, throw error untuk UI handle
        throw Exception('Session expired. Please login again.');
      }
      
      rethrow;
    }
  }

  Future<void> addCategory(Map<String, dynamic> payload) async {
    try {
      await service.createCategory(payload);
      await fetchAllCategories();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> editCategory(int categoryId, Map<String, dynamic> payload) async {
    try {
      await service.editCategory(categoryId, payload);
      await fetchAllCategories();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteCategory(int categoryId) async {
    try {
      await service.deleteCategory(categoryId);
      await fetchAllCategories();

      // Refresh product list setelah delete category agar data 
      // dengan category yang dihapus jadi null
      await ref.read(productProvider.notifier).fetchAllProducts();
    } catch (e) {
      rethrow;
    }
  }
}

final categoryProvider =
    StateNotifierProvider<CategoryNotifier, CategoryState>((ref) {
  final service = ref.read(categoryServiceProvider);
  return CategoryNotifier(service, ref);
});
