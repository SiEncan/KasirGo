import 'package:iconsax/iconsax.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasir_go/component/products/product_table.dart';
import 'package:kasir_go/component/products/dialogs/add_category_dialog.dart';
import 'package:kasir_go/component/products/dialogs/add_product_dialog.dart';
import 'package:kasir_go/component/products/dialogs/edit_category_dialog.dart';
import 'package:kasir_go/providers/product_provider.dart';
import 'package:kasir_go/providers/category_provider.dart';

class ManageProductsScreen extends ConsumerStatefulWidget {
  const ManageProductsScreen({super.key});

  @override
  ConsumerState<ManageProductsScreen> createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends ConsumerState<ManageProductsScreen> {
  String selectedCategoryId = '';
  bool _initialized = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(categoryProvider.notifier).fetchAllCategories();
      ref.read(productProvider.notifier).fetchAllProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoriesState = ref.watch(categoryProvider);
    final productsState = ref.watch(productProvider);

    final selectedCategory = categoriesState.categories.firstWhere(
      (c) => c['id'].toString() == selectedCategoryId,
      orElse: () => {},
    );

    final selectedCategoryName = selectedCategory['name'] ?? '';

    if (productsState.isLoading || categoriesState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_initialized && categoriesState.categories.isNotEmpty) {
      selectedCategoryId =
          categoriesState.categories.first['id'].toString();
      _initialized = true;
    }
    
    final filteredProducts = productsState.products
                            .where((product) => product['category'].toString() == selectedCategoryId)
                            .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Row(
          children: [
            // Sidebar kategori
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
                  // Header
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

                  // Category List
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      children: [
                        ...categoriesState.categories.map((category) {
                          if (category['id'] == null) return Container();
                          
                          final isSelected = selectedCategoryId == category['id'].toString();
                          
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.orange.shade50 : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: isSelected
                                  ? Border.all(color: Colors.deepOrange.shade500, width: 1)
                                  : null,
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              title: Text(
                                category['name'],
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? Colors.orange.shade900 : Colors.black87,
                                ),
                              ),
                              selected: isSelected,
                              onTap: () => setState(() => selectedCategoryId = category['id'].toString()),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.edit_outlined,
                                  size: 20,
                                  color: isSelected ? Colors.orange.shade900 : Colors.grey.shade600,
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => EditCategoryDialog(category: category),
                                  );
                                },
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  // Add Category Button
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
                          backgroundColor: Colors.orange.shade600,
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
        
            // Produk
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Products in ${selectedCategoryName ?? "all categories"}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.deepOrange.shade600,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8),
                          )
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AddProductDialog(
                                initialCategoryId: selectedCategoryId,
                                categories: categoriesState.categories,
                              ),
                            );
                          },
                          child: const Text("+ Add Product", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child:
                      ProductTable(
                        products: filteredProducts,
                        categories: categoriesState.categories,
                      )
                    )
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