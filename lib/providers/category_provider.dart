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

  CategoryState({this.categories = const [], this.isLoading = false});

  CategoryState copyWith({
    List<Map<String, dynamic>>? categories,
    bool? isLoading,
  }) {
    return CategoryState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class CategoryNotifier extends StateNotifier<CategoryState> {
  final CategoryService service;
  final Ref ref;

  CategoryNotifier(this.service, this.ref) : super(CategoryState());

  Future<void> fetchAllCategories() async {
    final data = await service.getAllCategories();
    state = state.copyWith(categories: data);
  }

  Future<void> addCategory(Map<String, dynamic> payload) async {
    state = state.copyWith(isLoading: true);
    try {
      await service.createCategory(payload);
      await fetchAllCategories();
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> editCategory(int categoryId, Map<String, dynamic> payload) async {
    state = state.copyWith(isLoading: true);
    try {
      await service.editCategory(categoryId, payload);
      await fetchAllCategories();
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> deleteCategory(int categoryId) async {
    state = state.copyWith(isLoading: true);
    try {
      await service.deleteCategory(categoryId);
      await fetchAllCategories();
      await ref.read(productProvider.notifier).fetchAllProducts();
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}

final categoryProvider =
    StateNotifierProvider<CategoryNotifier, CategoryState>((ref) {
  final service = ref.read(categoryServiceProvider);
  return CategoryNotifier(service, ref);
});
