import 'package:iconsax/iconsax.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasir_go/screen/products/components/product_table.dart';
import 'package:kasir_go/screen/products/components/dialogs/add_category_dialog.dart';
import 'package:kasir_go/screen/products/components/dialogs/add_product_dialog.dart';
import 'package:kasir_go/screen/products/components/dialogs/edit_category_dialog.dart';
import 'package:kasir_go/providers/product_provider.dart';
import 'package:kasir_go/providers/category_provider.dart';
import 'package:kasir_go/utils/session_helper.dart';

class ManageProductsScreen extends ConsumerStatefulWidget {
  const ManageProductsScreen({super.key});

  @override
  ConsumerState<ManageProductsScreen> createState() =>
      _ManageProductsScreenState();
}

class _ManageProductsScreenState extends ConsumerState<ManageProductsScreen> {
  String selectedCategoryId = '';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    selectedCategoryId = 'all';

    Future.microtask(() async {
      try {
        await ref.read(categoryProvider.notifier).fetchAllCategories();
        await ref.read(productProvider.notifier).fetchAllProducts();
      } catch (e) {
        // Jika session expired, logout dan redirect ke login
        if (isSessionExpiredError(e)) {
          if (!mounted) return;
          await handleSessionExpired(context, ref);
          return;
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesState = ref.watch(categoryProvider);
    final productsState = ref.watch(productProvider);

    final selectedCategory = selectedCategoryId == 'all'
        ? {'name': 'All Products'}
        : categoriesState.categories.firstWhere(
            (c) => c['id'].toString() == selectedCategoryId,
            orElse: () => {},
          );

    final selectedCategoryName = selectedCategory['name'] ?? '';

    var filteredProducts = selectedCategoryId == 'all'
        ? productsState.products
        : productsState.products
            .where((product) =>
                product['category'].toString() == selectedCategoryId)
            .toList();

    if (_searchQuery.isNotEmpty) {
      filteredProducts = filteredProducts.where((product) {
        final name = product['name'].toString().toLowerCase();
        final description =
            (product['description'] ?? '').toString().toLowerCase();
        final sku = (product['sku'] ?? '').toString().toLowerCase();
        final query = _searchQuery.toLowerCase();
        return name.contains(query) ||
            description.contains(query) ||
            sku.contains(query);
      }).toList();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Container(
              width: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  right: BorderSide(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Iconsax.category5,
                            color: Colors.orange.shade700,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Categories",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: selectedCategoryId == 'all'
                                ? Colors.orange.shade50
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: selectedCategoryId == 'all'
                                ? Border.all(
                                    color: Colors.deepOrange.shade500, width: 1)
                                : null,
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            title: Text(
                              'All Products',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: selectedCategoryId == 'all'
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: selectedCategoryId == 'all'
                                    ? Colors.orange.shade900
                                    : Colors.black87,
                              ),
                            ),
                            selected: selectedCategoryId == 'all',
                            onTap: () =>
                                setState(() => selectedCategoryId = 'all'),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: Divider(
                            color: Colors.grey.shade300,
                            height: 1,
                          ),
                        ),
                        ...categoriesState.categories.map((category) {
                          if (category['id'] == null) return Container();

                          final isSelected =
                              selectedCategoryId == category['id'].toString();

                          return Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.orange.shade50
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: isSelected
                                  ? Border.all(
                                      color: Colors.deepOrange.shade500,
                                      width: 1)
                                  : null,
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              title: Text(
                                category['name'],
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? Colors.orange.shade900
                                      : Colors.black87,
                                ),
                              ),
                              selected: isSelected,
                              onTap: () => setState(() => selectedCategoryId =
                                  category['id'].toString()),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.edit_outlined,
                                  size: 20,
                                  color: isSelected
                                      ? Colors.orange.shade900
                                      : Colors.grey.shade600,
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) =>
                                        EditCategoryDialog(category: category),
                                  );
                                },
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      border: Border(
                        top: BorderSide(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => const AddCategoryDialog(),
                          );
                        },
                        icon: const Icon(Icons.add, size: 20),
                        label: const Text(
                          "Add Category",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade900,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          selectedCategoryName == "All Products"
                              ? "All Products"
                              : "Products in $selectedCategoryName",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: SizedBox(
                            height: 45,
                            child: TextField(
                              controller: _searchController,
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                });
                              },
                              decoration: InputDecoration(
                                hintText:
                                    'Search products by name, SKU, or description...',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                ),
                                prefixIcon: Icon(
                                  Iconsax.search_normal,
                                  color: Colors.grey.shade500,
                                  size: 20,
                                ),
                                suffixIcon: _searchQuery.isNotEmpty
                                    ? IconButton(
                                        icon: Icon(
                                          Icons.clear,
                                          color: Colors.grey.shade500,
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _searchController.clear();
                                            _searchQuery = '';
                                          });
                                        },
                                      )
                                    : null,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.orange.shade600,
                                    width: 1.5,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AddProductDialog(
                                initialCategoryId: selectedCategoryId == 'all'
                                    ? ''
                                    : selectedCategoryId,
                                categories: categoriesState.categories,
                              ),
                            );
                          },
                          icon: const Icon(Icons.add, size: 20),
                          label: const Text(
                            "Add Product",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade900,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                        child: ProductTable(
                      products: filteredProducts,
                      categories: categoriesState.categories,
                    ))
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
