import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasir_go/component/home/category_section.dart';
import 'package:kasir_go/component/home/header_section.dart';
import 'package:kasir_go/component/home/order_detail.dart';
import 'package:kasir_go/component/home/product_view.dart';
import 'package:kasir_go/component/home/skeleton_widgets.dart';
import 'package:kasir_go/providers/category_provider.dart';
import 'package:kasir_go/providers/product_provider.dart';
import 'package:kasir_go/utils/session_helper.dart';
import 'package:kasir_go/utils/snackbar_helper.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  String selectedCategoryId = '';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = true;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    selectedCategoryId = 'all';
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
      lowerBound: 0.3,
      upperBound: 0.8,
    )..repeat(reverse: true);

    // Load initial data
    Future.microtask(() => _refreshData());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  int _getCategoryOrder(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('main') || name.contains('course')) return 1;
    if (name.contains('beverage') ||
        name.contains('drink') ||
        name.contains('coffee')) {
      return 2;
    }
    if (name.contains('dessert') || name.contains('cake')) return 3;
    return 999; // other categories at the end
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(categoryProvider.notifier).fetchAllCategories();
      await ref.read(productProvider.notifier).fetchAllProducts();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      // Jika session expired, logout dan redirect ke login
      if (isSessionExpiredError(e)) {
        if (!mounted) return;
        await handleSessionExpired(context, ref);
        return;
      }

      // Show error snackbar
      if (mounted) {
        showErrorSnackBar(context, e.toString(),
            title: 'Failed to refresh data: ');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesState = ref.watch(categoryProvider);
    final productsState = ref.watch(productProvider);

    // Check if data is actually loaded
    final hasData = categoriesState.categories.isNotEmpty ||
        productsState.products.isNotEmpty;
    final isActuallyLoading = _isLoading && !hasData;

    // Sort categories by custom order
    final sortedCategories =
        List<Map<String, dynamic>>.from(categoriesState.categories)
          ..sort((a, b) {
            final orderA = _getCategoryOrder(a['name'] ?? '');
            final orderB = _getCategoryOrder(b['name'] ?? '');
            return orderA.compareTo(orderB);
          });

    var filteredProducts = selectedCategoryId == 'all'
        ? productsState.products.where((product) => product['is_available'] == true).toList()
        : productsState.products
            .where((product) =>
                product['category'].toString() == selectedCategoryId && product['is_available'] == true)
            .toList();

    if (_searchQuery.isNotEmpty) {
      filteredProducts = filteredProducts.where((product) {
        final name = product['name'].toString().toLowerCase();
        final description =
            (product['description'] ?? '').toString().toLowerCase();
        final query = _searchQuery.toLowerCase();
        return name.contains(query) || description.contains(query);
      }).toList();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: RefreshIndicator(
                onRefresh: _refreshData,
                color: Colors.deepOrange.shade400,
                child: CustomScrollView(
                  slivers: [
                    // Fixed Header
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: HeaderSection(
                        searchController: _searchController,
                        searchQuery: _searchQuery,
                        onSearchChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        onClearSearch: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      ),
                    ),
                    // Fixed Menu Text & Categories
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: CategorySection(
                        isLoading: isActuallyLoading,
                        selectedCategoryId: selectedCategoryId,
                        sortedCategories: sortedCategories,
                        productsState: productsState,
                        filteredProductsLength: filteredProducts.length,
                        onCategorySelected: (categoryId) {
                          setState(() {
                            selectedCategoryId = categoryId;
                          });
                        },
                        categorySkeleton: SkeletonWidgets.buildCategorySkeleton(
                            _shimmerController),
                      ),
                    ),
                    // Scrollable Products
                    isActuallyLoading
                        ? SliverToBoxAdapter(
                            child: SkeletonWidgets.buildProductGridSkeleton(
                                _shimmerController, context),
                          )
                        : ProductView(products: filteredProducts),
                  ],
                ),
              ),
            ),
            VerticalDivider(
              color: Colors.grey.shade300,
              thickness: 1,
              width: 5,
            ),
            const OrderDetails()
          ],
        ),
      ),
    );
  }
}
