import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kasir_go/component/home/order_detail.dart';
import 'package:kasir_go/component/home/product_view.dart';
import 'package:kasir_go/providers/category_provider.dart';
import 'package:kasir_go/providers/product_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String selectedCategoryId = '';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    selectedCategoryId = 'all';

    Future.microtask(() {
      ref.read(categoryProvider.notifier).fetchAllCategories();
      ref.read(productProvider.notifier).fetchAllProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _getCategoryOrder(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('main') || name.contains('course')) return 1;
    if (name.contains('beverage') || name.contains('drink') || name.contains('coffee')) return 2;
    if (name.contains('dessert') || name.contains('cake')) return 3;
    return 999; // other categories at the end
  }

  @override
  Widget build(BuildContext context) {
    final categoriesState = ref.watch(categoryProvider);
    final productsState = ref.watch(productProvider);

    // Sort categories by custom order
    final sortedCategories = List<Map<String, dynamic>>.from(categoriesState.categories)
      ..sort((a, b) {
        final orderA = _getCategoryOrder(a['name'] ?? '');
        final orderB = _getCategoryOrder(b['name'] ?? '');
        return orderA.compareTo(orderB);
      });

    var filteredProducts = selectedCategoryId == 'all'
      ? productsState.products
      : productsState.products
        .where((product) => product['category'].toString() == selectedCategoryId)
        .toList();

    if (_searchQuery.isNotEmpty) {
      filteredProducts = filteredProducts.where((product) {
        final name = product['name'].toString().toLowerCase();
        final description = (product['description'] ?? '').toString().toLowerCase();
        final query = _searchQuery.toLowerCase();
        return name.contains(query) || description.contains(query);
      }).toList();
    }
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 24, right: 24),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Kasir',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepOrange.shade400,
                                  ),
                                ),
                                const TextSpan(
                                  text: 'Go',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: '   Search Anything Here',
                              hintStyle: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal),
                              suffixIcon: _searchQuery.isEmpty
                                  ? const Padding(
                                      padding: EdgeInsets.only(right: 12),
                                      child: Icon(Iconsax.search_normal),
                                    )
                                  : IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        setState(() {
                                          _searchController.clear();
                                          _searchQuery = '';
                                        });
                                      },
                                    ),
                              suffixIconColor: Colors.grey,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(32),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(32),
                                borderSide: BorderSide(
                                  color: Colors.deepOrange.shade400,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.deepOrange.shade300,
                              borderRadius: BorderRadius.circular(132),
                            ),
                            child: const Icon(
                              Iconsax.notification5,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, right: 8.0),
                        child: Text('Menu',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey.shade900)),
                      ),
                      Text('(${filteredProducts.length} items)',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            const SizedBox(width: 16),
                            OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  selectedCategoryId = 'all';
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.only(left: 24, right: 48, top: 16, bottom: 16),
                                side: BorderSide(
                                  color: selectedCategoryId == 'all' 
                                      ? Colors.deepOrange.shade400 
                                      : Colors.grey.shade300,
                                  width: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: selectedCategoryId == 'all'
                                          ? Colors.deepOrange.shade500
                                          : Colors.grey.shade400,
                                      borderRadius: BorderRadius.circular(36),
                                    ),
                                    child: const Icon(
                                      Iconsax.category,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('All Menu',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: selectedCategoryId == 'all'
                                            ? Colors.orange.shade900
                                            : Colors.grey.shade500)),
                                      const SizedBox(height: 4),
                                      Text('(${productsState.products.length} items)',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.normal,
                                          color: selectedCategoryId == 'all'
                                            ? Colors.orange.shade800
                                            : Colors.grey.shade500)),
                                ])
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            ...sortedCategories.map((category) {
                              final categoryId = category['id'];
                              final categoryName = (category['name'] ?? '').toString().toLowerCase();
                              final isSelected = selectedCategoryId == categoryId.toString();
                              
                              IconData categoryIcon = Icons.restaurant;
                              if (categoryName.contains('dessert') || categoryName.contains('cake')) {
                                categoryIcon = Icons.cake;
                              } else if (categoryName.contains('beverage') || categoryName.contains('drink') || categoryName.contains('coffee')) {
                                categoryIcon = Icons.coffee;
                              }
                              
                              return Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: OutlinedButton(
                                  onPressed: () {
                                    setState(() {
                                      selectedCategoryId = categoryId.toString();
                                    });
                                  },
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.only(left: 24, right: 48, top: 16, bottom: 16),
                                    side: BorderSide(
                                      color: isSelected 
                                        ? Colors.deepOrange.shade400 
                                        : Colors.grey.shade300,
                                          
                                    width: 2,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                            ? Colors.deepOrange.shade500
                                            : Colors.grey.shade200,
                                          borderRadius: BorderRadius.circular(36),
                                        ),
                                        child: Icon(
                                          categoryIcon,
                                          color: isSelected 
                                            ? Colors.white 
                                            : Colors.grey.shade400,
                                          size: 28,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            category['name'] ?? 'Unknown',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: isSelected
                                                ? Colors.orange.shade900
                                                : Colors.grey.shade700,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '(${productsState.products.where((product) => product['category'].toString() == categoryId.toString()).length} items)',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.normal,
                                              color: isSelected
                                                ? Colors.orange.shade800
                                                : Colors.grey.shade500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(width: 4),
                          ],
                        ),
                      ),
                  ),
                  Expanded(
                    child: ProductView(products: filteredProducts),
                  ),
                ],
              ),
            ),
            VerticalDivider(
              color: Colors.grey.shade300,
              thickness: 1,
            ),
            const OrderDetails()
          ],
        ),
      ),
    );
  }
}