import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/category_service.dart';
import 'auth_provider.dart';

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
  final String? error;
  final List<Map<String, dynamic>> categories;

  CategoryState({this.isLoading = false, this.error, this.categories = const []});

  CategoryState copyWith({
    bool? isLoading,
    String? error,
    List<Map<String, dynamic>>? categories,
  }) {
    return CategoryState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      categories: categories ?? this.categories,
    );
  }
}

class CategoryNotifier extends StateNotifier<CategoryState> {
  final CategoryService service;

  CategoryNotifier(this.service) : super(CategoryState());

  Future<void> fetchAllCategories() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await service.getAllCategories();
      state = state.copyWith(isLoading: false, categories: data);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addCategory(Map<String, dynamic> payload) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await service.createCategory(payload);
      await fetchAllCategories();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> editCategory(int categoryId, Map<String, dynamic> payload) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await service.editCategory(categoryId, payload);
      await fetchAllCategories();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteCategory(int categoryId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await service.deleteCategory(categoryId);
      await fetchAllCategories();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final categoryProvider =
    StateNotifierProvider<CategoryNotifier, CategoryState>((ref) {
  final service = ref.read(categoryServiceProvider);
  return CategoryNotifier(service);
});
