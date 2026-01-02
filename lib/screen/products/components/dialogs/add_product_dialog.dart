import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kasir_go/providers/product_provider.dart';
import 'package:kasir_go/utils/snackbar_helper.dart';
import 'package:kasir_go/utils/dialog_helper.dart';
import 'package:kasir_go/utils/session_helper.dart';

class AddProductDialog extends ConsumerStatefulWidget {
  final String initialCategoryId;
  final List<Map<String, dynamic>> categories;

  const AddProductDialog({
    super.key,
    required this.initialCategoryId,
    required this.categories,
  });

  @override
  ConsumerState<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends ConsumerState<AddProductDialog> {
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;

  String _productName = '';
  String _productDescription = '';
  int _productPrice = 0;
  int _productCost = 0;
  int _productStock = 0;
  bool _productIsAvailable = true;
  bool _needsPreparation = true;
  String _productSKU = '';
  late String _productCategory;

  @override
  void initState() {
    super.initState();
    _productCategory = widget.initialCategoryId;
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
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return PopScope(
      canPop: !isLoading,
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(viewInsets: EdgeInsets.zero),
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
                          Icons.add_shopping_cart,
                          color: Colors.orange.shade700,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Add New Product",
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
                    padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
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
                                      style: BorderStyle.solid,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image_outlined,
                                        size: 48,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "No image selected",
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 16),
                              OutlinedButton.icon(
                                onPressed: _pickImage,
                                icon: const Icon(Icons.upload),
                                label: Text(_pickedImage != null
                                    ? "Change Image"
                                    : "Upload Image"),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  side:
                                      BorderSide(color: Colors.orange.shade700),
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
                                decoration: _inputDecoration(
                                    "Product Name", Icons.shopping_bag),
                                onChanged: (value) => _productName = value,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                decoration:
                                    _inputDecoration("SKU", Icons.qr_code),
                                onChanged: (value) => _productSKU = value,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          decoration: _inputDecoration(
                              "Description", Icons.description),
                          maxLines: 2,
                          onChanged: (value) => _productDescription = value,
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
                                decoration: _inputDecoration(
                                    "Price (Rp)", Icons.payments),
                                keyboardType: TextInputType.number,
                                onChanged: (value) =>
                                    _productPrice = int.tryParse(value) ?? 0,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                decoration: _inputDecoration(
                                    "Cost (Rp)", Icons.money_off),
                                keyboardType: TextInputType.number,
                                onChanged: (value) =>
                                    _productCost = int.tryParse(value) ?? 0,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          decoration: _inputDecoration(
                              "Stock Quantity", Icons.inventory),
                          keyboardType: TextInputType.number,
                          onChanged: (value) =>
                              _productStock = int.tryParse(value) ?? 0,
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
                              Text(
                                _productIsAvailable
                                    ? "Available"
                                    : "Unavailable",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: _productIsAvailable
                                      ? Colors.green.shade700
                                      : Colors.red.shade700,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Switch(
                                value: _productIsAvailable,
                                onChanged: (value) {
                                  setState(() {
                                    _productIsAvailable = value;
                                  });
                                },
                                activeThumbColor: Colors.green.shade700,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: _needsPreparation
                                ? Colors.blue.shade50
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _needsPreparation
                                  ? Colors.blue.shade200
                                  : Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.soup_kitchen,
                                color: _needsPreparation
                                    ? Colors.blue.shade700
                                    : Colors.grey.shade600,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Requires Preparation",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: _needsPreparation
                                            ? Colors.blue.shade900
                                            : Colors.grey.shade800,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      _needsPreparation
                                          ? "Order will be sent to Kitchen Display"
                                          : "Direct fulfillment (Skip Kitchen)",
                                      style: TextStyle(
                                        color: _needsPreparation
                                            ? Colors.blue.shade600
                                            : Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _needsPreparation,
                                onChanged: (value) {
                                  setState(() {
                                    _needsPreparation = value;
                                  });
                                },
                                activeThumbColor: Colors.blue.shade700,
                                activeTrackColor: Colors.blue.shade200,
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
                                if (_productName.trim().isEmpty) {
                                  showErrorDialog(
                                      context, 'Product name is required',
                                      title: 'Validation Error');
                                  return;
                                }
                                if (_productSKU.trim().isEmpty) {
                                  showErrorDialog(context, 'SKU is required',
                                      title: 'Validation Error');
                                  return;
                                }
                                if (_productPrice <= 0) {
                                  showErrorDialog(
                                      context, 'Price must be greater than 0',
                                      title: 'Validation Error');
                                  return;
                                }
                                if (_productCost < 0) {
                                  showErrorDialog(
                                      context, 'Cost cannot be negative',
                                      title: 'Validation Error');
                                  return;
                                }
                                if (_productStock < 0) {
                                  showErrorDialog(
                                      context, 'Stock cannot be negative',
                                      title: 'Validation Error');
                                  return;
                                }

                                final payload = {
                                  "name": _productName,
                                  "description": _productDescription,
                                  "price": _productPrice.toDouble(),
                                  "cost": _productCost.toDouble(),
                                  "stock": _productStock,
                                  "image": _pickedImage,
                                  "is_available": _productIsAvailable,
                                  "needs_preparation": _needsPreparation,
                                  "sku": _productSKU,
                                  "category": _productCategory,
                                };

                                await ref
                                    .read(productProvider.notifier)
                                    .addProduct(payload);

                                if (context.mounted) {
                                  final errorMessage =
                                      ref.read(productProvider).errorMessage;
                                  if (errorMessage != null) {
                                    if (isSessionExpiredError(errorMessage)) {
                                      await handleSessionExpired(context, ref);
                                      return;
                                    }
                                    showErrorDialog(context, errorMessage,
                                        title: 'Failed to Add Product');
                                  } else {
                                    Navigator.pop(context);
                                    showSuccessSnackBar(
                                        context, 'Product added successfully');
                                  }
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
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text(
                                "Save Product",
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
      ),
    );
  }
}
