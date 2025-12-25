import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kasir_go/providers/product_provider.dart';
import 'package:kasir_go/utils/snackbar_helper.dart';
import 'package:kasir_go/utils/dialog_helper.dart';
import 'package:kasir_go/utils/session_helper.dart';

class EditProductDialog extends ConsumerStatefulWidget {
  final Map<String, dynamic> product;
  final List<Map<String, dynamic>> categories;

  const EditProductDialog({
    super.key,
    required this.product,
    required this.categories,
  });

  @override
  ConsumerState<EditProductDialog> createState() => _EditProductDialogState();
}

class _EditProductDialogState extends ConsumerState<EditProductDialog> {
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;

  late final TextEditingController nameController;
  late final TextEditingController skuController;
  late final TextEditingController descController;
  late final TextEditingController priceController;
  late final TextEditingController costController;
  late final TextEditingController stockController;

  late bool _productIsAvailable;
  late String _productCategory;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.product['name']);
    skuController = TextEditingController(text: widget.product['sku']);
    descController =
        TextEditingController(text: widget.product['description'] ?? '');
    priceController =
        TextEditingController(text: widget.product['price'].toString());
    costController =
        TextEditingController(text: widget.product['cost'].toString());
    stockController =
        TextEditingController(text: widget.product['stock'].toString());
    _productIsAvailable = widget.product['is_available'] ?? true;
    _productCategory = widget.product['category']?.toString() ?? '';
  }

  @override
  void dispose() {
    nameController.dispose();
    skuController.dispose();
    descController.dispose();
    priceController.dispose();
    costController.dispose();
    stockController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _pickedImage = image;
      });
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.orange.shade700),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.orange.shade700, width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(productProvider).isLoading;

    return PopScope(
      canPop: !isLoading,
      child: Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: 700,
          constraints: const BoxConstraints(maxHeight: 700),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
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
                        Icons.edit_note,
                        color: Colors.orange.shade700,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Edit Product",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed:
                          isLoading ? null : () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            if (_pickedImage != null)
                              Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 2,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    File(_pickedImage!.path),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            else if (widget.product['image'] != null)
                              Container(
                                  width: 200,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                      width: 2,
                                    ),
                                  ),
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: CachedNetworkImage(
                                        imageUrl: widget.product['image'],
                                        memCacheWidth: 500,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            Container(
                                          color: Colors.grey.shade200,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.orange.shade300,
                                            ),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) {
                                          return Icon(
                                            Icons.image_not_supported,
                                            size: 48,
                                            color: Colors.grey.shade400,
                                          );
                                        },
                                      )))
                            else
                              Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  Icons.restaurant,
                                  size: 96,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: _pickImage,
                              icon: const Icon(Icons.upload),
                              label: const Text("Change Image"),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                side: BorderSide(color: Colors.orange.shade700),
                                foregroundColor: Colors.orange.shade700,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 24),
                      const Text(
                        "Product Information",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: nameController,
                              decoration: _inputDecoration(
                                  "Product Name", Icons.shopping_bag),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: skuController,
                              decoration:
                                  _inputDecoration("SKU", Icons.qr_code),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: descController,
                        decoration:
                            _inputDecoration("Description", Icons.description),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Pricing & Stock",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: priceController,
                              decoration: _inputDecoration(
                                  "Price (Rp)", Icons.payments),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: costController,
                              decoration: _inputDecoration(
                                  "Cost (Rp)", Icons.money_off),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: stockController,
                        decoration:
                            _inputDecoration("Stock Quantity", Icons.inventory),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue:
                            _productCategory.isEmpty ? '' : _productCategory,
                        decoration:
                            _inputDecoration("Category", Icons.category),
                        items: [
                          const DropdownMenuItem<String>(
                            value: '',
                            child: Text('No Category'),
                          ),
                          ...widget.categories
                              .map<DropdownMenuItem<String>>((category) {
                            return DropdownMenuItem<String>(
                              value: category['id'].toString(),
                              child: Text(category['name']),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _productCategory = value ?? '';
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.orange.shade200,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.orange.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                "Product Availability",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Switch(
                              value: _productIsAvailable,
                              onChanged: (value) {
                                setState(() {
                                  _productIsAvailable = value;
                                });
                              },
                              activeThumbColor: Colors.green.shade700,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _productIsAvailable ? "Available" : "Unavailable",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: _productIsAvailable
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  border: Border(
                    top: BorderSide(
                      color: Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed:
                          isLoading ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        side: BorderSide(color: Colors.grey.shade400),
                        foregroundColor: Colors.grey.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text("Cancel"),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () async {
                              if (nameController.text.trim().isEmpty) {
                                showErrorDialog(
                                    context, 'Product name is required',
                                    title: 'Validation Error');
                                return;
                              }
                              if (skuController.text.trim().isEmpty) {
                                showErrorDialog(context, 'SKU is required',
                                    title: 'Validation Error');
                                return;
                              }

                              final price =
                                  double.tryParse(priceController.text) ?? 0.0;
                              final cost =
                                  double.tryParse(costController.text) ?? 0.0;
                              final stock =
                                  int.tryParse(stockController.text) ?? 0;

                              if (price <= 0) {
                                showErrorDialog(
                                    context, 'Price must be greater than 0',
                                    title: 'Validation Error');
                                return;
                              }
                              if (cost < 0) {
                                showErrorDialog(
                                    context, 'Cost cannot be negative',
                                    title: 'Validation Error');
                                return;
                              }
                              if (stock < 0) {
                                showErrorDialog(
                                    context, 'Stock cannot be negative',
                                    title: 'Validation Error');
                                return;
                              }

                              final payload = {
                                "name": nameController.text,
                                "description": descController.text,
                                "price": price.toDouble(),
                                "cost": cost.toDouble(),
                                "stock": stock,
                                "image": _pickedImage,
                                "is_available": _productIsAvailable,
                                "sku": skuController.text,
                                "category": _productCategory,
                              };

                              try {
                                await ref
                                    .read(productProvider.notifier)
                                    .editProduct(widget.product['id'], payload);
                                if (!context.mounted) return;
                                Navigator.pop(context);
                                showSuccessSnackBar(
                                    context, 'Product updated successfully');
                              } catch (e) {
                                if (!context.mounted) return;

                                if (isSessionExpiredError(e)) {
                                  await handleSessionExpired(context, ref);
                                  return;
                                }

                                showErrorDialog(context, e.toString(),
                                    title: 'Update Failed');
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              "Save Changes",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
