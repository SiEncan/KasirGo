import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
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
                  if (category['id'] == null) return Container();
                  return ListTile(
                    title: Text(category['name']),
                    selected: selectedCategoryId == category['id'].toString(),
                    onTap: () => setState(() => selectedCategoryId = category['id'].toString()),
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
                      Text("Products in ${selectedCategoryName ?? "all categories"}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ElevatedButton(
                        onPressed: () {
                          // TODO: tambah produk
                          _showAddProductDialog(categoriesState);
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

  // add product dialog

  void _showAddProductDialog(CategoryState categoriesState) {
    showDialog(
      context: context,
      builder: (context) {
        final ImagePicker picker = ImagePicker();
        XFile? pickedImage;

        String productName = '';
        String productDescription = '';
        int productPrice = 0;
        int productCost = 0;
        int productStock = 0;
        bool productIsAvailable = true;
        String productSKU = '';
        String productCategory = selectedCategoryId;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> pickImage() async {
              final XFile? image = await picker.pickImage(
                source: ImageSource.gallery,
                imageQuality: 80,
              );

              if (image != null) {
                setDialogState(() {
                  pickedImage = image;
                });
              }
            }

            return AlertDialog(
              title: const Text("Add Product"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // PREVIEW IMAGE
                    if (pickedImage != null)
                      Image.file(
                        File(pickedImage!.path),
                        height: 120,
                      ),

                    TextButton.icon(
                      onPressed: pickImage,
                      icon: const Icon(Icons.image),
                      label: const Text("Choose Image"),
                    ),

                    const SizedBox(height: 8),

                    TextFormField(
                      decoration: const InputDecoration(labelText: "Product Name"),
                      onChanged: (value) => productName = value,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: "Product Description"),
                      onChanged: (value) => productDescription = value,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: "Product Price"),
                      keyboardType: TextInputType.number,
                      onChanged: (value) =>  productPrice = int.tryParse(value) ?? 0,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: "Product Cost"),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => productCost = int.tryParse(value) ?? 0,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: "Product Stock"),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => productStock = int.tryParse(value) ?? 0,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: "Product SKU"),
                      onChanged: (value) => productSKU = value,
                    ),
                    DropdownButtonFormField<String>(
                      value: productCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: categoriesState.categories
                          .map<DropdownMenuItem<String>>((category) {
                        return DropdownMenuItem<String>(
                          value: category['id'].toString(),
                          child: Text(category['name']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          productCategory = value;
                        };
                      },
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final payload = {
                      "name": productName,
                      "description": productDescription,
                      "price": productPrice.toDouble(),
                      "cost": productCost.toDouble(),
                      "stock": productStock,
                      "image": pickedImage,
                      "is_available": productIsAvailable,
                      "sku": productSKU,
                      "category": productCategory,
                    };
                    await ref.read(productProvider.notifier).addProduct(payload).then((_) {
                      Navigator.pop(context);
                    });
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}