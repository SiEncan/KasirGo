import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasir_go/providers/product_provider.dart';
import 'package:kasir_go/providers/category_provider.dart';

class ManageProductsScreen extends ConsumerStatefulWidget {
  const ManageProductsScreen({super.key});

  @override
  ConsumerState<ManageProductsScreen> createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends ConsumerState<ManageProductsScreen> {
  String selectedCategory = '';

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

    if (productsState.isLoading || categoriesState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (selectedCategory.isEmpty && categoriesState.categories.isNotEmpty) {
      selectedCategory = categoriesState.categories.first['name'];
    }
    
    final filteredProducts = productsState.products
                            .where((product) => product['category_name'] == selectedCategory)
                            .toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Manage Products & Categories")),
      body: Row(
        children: [
          // Sidebar kategori
          Container(
            width: 200,
            color: Colors.grey[200],
            child: ListView(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("Categories", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                ...categoriesState.categories.map((category) {
                  if (category['name'] == null) return Container();
                  return ListTile(
                    title: Text(category['name']),
                    selected: selectedCategory == category['name'],
                    onTap: () => setState(() => selectedCategory = category['name']),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        // TODO: edit kategori
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Edit Category"),
                            content: TextFormField(
                              initialValue: category['name'],
                            ),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                              TextButton(onPressed: () {}, child: const Text("Save")),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                }).toList(),
                ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text("Add Category"),
                  onTap: () {
                    // TODO: tambah kategori
                  },
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
                      Text("Products in $selectedCategory", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ElevatedButton(
                        onPressed: () {
                          // TODO: tambah produk
                        },
                        child: const Text("Add Product"),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];

                        return Card(
                          child: ListTile(
                            title: Text(product['name']),
                            subtitle: Text("Price: ${product['price']}"),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                // TODO: edit produk
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
