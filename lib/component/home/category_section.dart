import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kasir_go/providers/product_provider.dart';

class CategorySection extends SliverPersistentHeaderDelegate {
  final bool isLoading;
  final String selectedCategoryId;
  final List<Map<String, dynamic>> sortedCategories;
  final ProductState productsState;
  final int filteredProductsLength;
  final Function(String) onCategorySelected;
  final Widget categorySkeleton;

  CategorySection({
    required this.isLoading,
    required this.selectedCategoryId,
    required this.sortedCategories,
    required this.productsState,
    required this.filteredProductsLength,
    required this.onCategorySelected,
    required this.categorySkeleton,
  });

  @override
  double get minExtent => 145.0;

  @override
  double get maxExtent => 145.0;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    if (isLoading) {
      return SizedBox(
        height: maxExtent,
        child: Container(
          color: Colors.white,
          child: categorySkeleton,
        ),
      );
    }

    return SizedBox(
      height: maxExtent,
      child: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 8.0),
                  child: Text('Menu',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade900)),
                ),
                Text('($filteredProductsLength items)',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(bottom: 0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    _buildCategoryButton(
                      context,
                      id: 'all',
                      name: 'All Menu',
                      icon: Iconsax.category,
                      itemCount: productsState.products.length,
                    ),
                    const SizedBox(width: 12),
                    ...sortedCategories.map((category) {
                      final categoryId = category['id'];
                      final categoryName =
                          (category['name'] ?? '').toString().toLowerCase();
                      IconData categoryIcon = Icons.restaurant;
                      if (categoryName.contains('dessert') ||
                          categoryName.contains('cake')) {
                        categoryIcon = Icons.cake;
                      } else if (categoryName.contains('beverage') ||
                          categoryName.contains('drink') ||
                          categoryName.contains('coffee')) {
                        categoryIcon = Icons.coffee;
                      }
                      final itemCount = productsState.products
                          .where((product) =>
                              product['category'].toString() ==
                              categoryId.toString())
                          .length;

                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: _buildCategoryButton(
                          context,
                          id: categoryId.toString(),
                          name: category['name'] ?? 'Unknown',
                          icon: categoryIcon,
                          itemCount: itemCount,
                        ),
                      );
                    }),
                    const SizedBox(width: 4),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryButton(
    BuildContext context, {
    required String id,
    required String name,
    required IconData icon,
    required int itemCount,
  }) {
    final isSelected = selectedCategoryId == id;
    return OutlinedButton(
      onPressed: () => onCategorySelected(id),
      style: OutlinedButton.styleFrom(
        padding:
            const EdgeInsets.only(left: 24, right: 48, top: 16, bottom: 16),
        side: BorderSide(
          color:
              isSelected ? Colors.deepOrange.shade400 : Colors.grey.shade300,
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
              icon,
              color: isSelected ? Colors.white : Colors.grey.shade400,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
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
                '($itemCount items)',
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
    );
  }

  @override
  bool shouldRebuild(CategorySection oldDelegate) {
    return isLoading != oldDelegate.isLoading ||
        selectedCategoryId != oldDelegate.selectedCategoryId ||
        sortedCategories.length != oldDelegate.sortedCategories.length ||
        productsState.products.length !=
            oldDelegate.productsState.products.length ||
        filteredProductsLength != oldDelegate.filteredProductsLength;
  }
}
