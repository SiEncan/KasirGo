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
  final List<Map<String, dynamic>>? categories;

  CategoryState({this.isLoading = false, this.error, this.categories});
}

class CategoryNotifier extends StateNotifier<CategoryState> {
  final CategoryService service;

  CategoryNotifier(this.service) : super(CategoryState());

  Future<void> fetchCategories() async {
    state = CategoryState(isLoading: true);
    try {
      final response = await service.getAllCategories();
      final List<Map<String, dynamic>> categories = List<Map<String, dynamic>>.from(response['data']);
      state = CategoryState(categories: categories, isLoading: false);
    } catch (e) {
      state = CategoryState(isLoading: false, error: e.toString());
    }
  }
}

final categoryProvider =
    StateNotifierProvider<CategoryNotifier, CategoryState>((ref) {
  final service = ref.read(categoryServiceProvider);
  return CategoryNotifier(service);
});
