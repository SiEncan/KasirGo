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
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  CategoryState({
    this.categories = const [],
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  CategoryState copyWith({
    List<Map<String, dynamic>>? categories,
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return CategoryState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class CategoryNotifier extends StateNotifier<CategoryState> {
  final CategoryService _service;
  final Ref ref;

  CategoryNotifier(this._service, this.ref) : super(CategoryState());

  Future<void> fetchAllCategories() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final data = await _service.getAllCategories();
      state = state.copyWith(isLoading: false, categories: data);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> addCategory(Map<String, dynamic> payload) async {
    state =
        state.copyWith(isLoading: true, errorMessage: null, isSuccess: false);
    try {
      await _service.createCategory(payload);
      await fetchAllCategories();
      state = state.copyWith(isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> editCategory(
      int categoryId, Map<String, dynamic> payload) async {
    state =
        state.copyWith(isLoading: true, errorMessage: null, isSuccess: false);
    try {
      await _service.editCategory(categoryId, payload);
      await fetchAllCategories();
      state = state.copyWith(isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> deleteCategory(int categoryId) async {
    state =
        state.copyWith(isLoading: true, errorMessage: null, isSuccess: false);
    try {
      await _service.deleteCategory(categoryId);
      await fetchAllCategories();
      await ref.read(productProvider.notifier).fetchAllProducts();
      state = state.copyWith(isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

final categoryProvider =
    StateNotifierProvider<CategoryNotifier, CategoryState>((ref) {
  final service = ref.read(categoryServiceProvider);
  return CategoryNotifier(service, ref);
});
