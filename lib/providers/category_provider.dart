import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/category_service.dart';
import 'auth_provider.dart';
import 'product_provider.dart';

final categoryServiceProvider = Provider<CategoryService>((ref) {
  final tokenStorage = ref.read(tokenStorageProvider);
  final authService = ref.read(authServiceProvider);

  return CategoryService(
    tokenStorage: tokenStorage,
    authService: authService,
  );
});

class CategoryState {
  final bool isLoading;
  final List<Map<String, dynamic>> categories;

  CategoryState({this.isLoading = false, this.categories = const []});

  CategoryState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? categories,
  }) {
    return CategoryState(
      isLoading: isLoading ?? this.isLoading,
      categories: categories ?? this.categories,
    );
  }
}

class CategoryNotifier extends StateNotifier<CategoryState> {
  final CategoryService service;
  final Ref ref;

  CategoryNotifier(this.service, this.ref) : super(CategoryState());

  Future<void> fetchAllCategories() async {
    state = state.copyWith(isLoading: true);
    try {
      final data = await service.getAllCategories();
      state = state.copyWith(isLoading: false, categories: data);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> addCategory(Map<String, dynamic> payload) async {
    state = state.copyWith(isLoading: true);
    try {
      await service.createCategory(payload);
      await fetchAllCategories();
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> editCategory(int categoryId, Map<String, dynamic> payload) async {
    state = state.copyWith(isLoading: true);
    try {
      await service.editCategory(categoryId, payload);
      await fetchAllCategories();
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> deleteCategory(int categoryId) async {
    state = state.copyWith(isLoading: true);
    try {
      await service.deleteCategory(categoryId);
      await fetchAllCategories();

      // Refresh product list setelah delete category agar data 
      // dengan category yang dihapus jadi null
      await ref.read(productProvider.notifier).fetchAllProducts();
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }
}

final categoryProvider =
    StateNotifierProvider<CategoryNotifier, CategoryState>((ref) {
  final service = ref.read(categoryServiceProvider);
  return CategoryNotifier(service, ref);
});
