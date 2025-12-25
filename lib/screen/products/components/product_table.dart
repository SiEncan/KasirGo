import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kasir_go/screen/products/components/dialogs/edit_product_dialog.dart';
import 'package:kasir_go/providers/product_provider.dart';
import 'package:kasir_go/utils/currency_helper.dart';
import 'package:kasir_go/utils/snackbar_helper.dart';
import 'package:kasir_go/utils/dialog_helper.dart';
import 'package:kasir_go/utils/session_helper.dart';

class ProductTable extends ConsumerWidget {
  final List<Map<String, dynamic>> products;
  final List<Map<String, dynamic>> categories;

  const ProductTable({
    super.key,
    required this.products,
    required this.categories,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(productProvider).isLoading;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildHeaderCell('Product', flex: 3),
              _buildHeaderCell('Status', flex: 2),
              _buildHeaderCell('Stock', flex: 1),
              _buildHeaderCell('Price', flex: 2),
              _buildHeaderCell('Cost', flex: 2),
              _buildHeaderCell('Action', flex: 3, isLast: true),
            ],
          ),
          products.isEmpty
              ? Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Iconsax.box_remove,
                        size: 80,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No products found',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                        ),
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildProductCell(product, flex: 3),
                              _buildStatusCell(product, flex: 2),
                              _buildStockCell(product, flex: 1),
                              _buildPriceCell(product, flex: 2),
                              _buildCostCell(product, flex: 2),
                              _buildActionCell(context, ref, product,
                                  isLoading: isLoading, flex: 3),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, {int flex = 1, bool isLast = false}) {
    return Expanded(
      flex: flex,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          border: Border(
            right: isLast
                ? BorderSide.none
                : BorderSide(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
            bottom: BorderSide(
              color: Colors.grey.shade300,
              width: 1,
            ),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildProductCell(Map<String, dynamic> product, {int flex = 3}) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              color: Colors.grey.shade200,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            product['image'] != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: product['image'],
                      width: 48,
                      height: 48,
                      memCacheWidth: 500,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey.shade200,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.orange.shade300,
                          ),
                        ),
                      ),
                    ))
                : Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade200,
                    ),
                    child: Icon(
                      Icons.restaurant,
                      size: 24,
                      color: Colors.grey.shade400,
                    ),
                  ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product['name'],
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (product['description'] != null &&
                      product['description'].toString().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      product['description'],
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCell(Map<String, dynamic> product, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              color: Colors.grey.shade200,
              width: 1,
            ),
          ),
        ),
        child: Center(
          child: Text(
            product['is_available'] ? 'In Stock' : 'Out of Stock',
            style: TextStyle(
              color: product['is_available']
                  ? const Color.fromARGB(255, 31, 170, 35)
                  : Colors.red[700],
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStockCell(Map<String, dynamic> product, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              color: Colors.grey.shade200,
              width: 1,
            ),
          ),
        ),
        child: Center(
          child: Text(
            '${product['stock']}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceCell(Map<String, dynamic> product, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              color: Colors.grey.shade200,
              width: 1,
            ),
          ),
        ),
        child: Center(
          child: Text(
            CurrencyHelper.formatIDR(product['price']),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCostCell(Map<String, dynamic> product, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              color: Colors.grey.shade200,
              width: 1,
            ),
          ),
        ),
        child: Center(
          child: Text(
            CurrencyHelper.formatIDR(product['cost']),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionCell(
      BuildContext context, WidgetRef ref, Map<String, dynamic> product,
      {required bool isLoading, int flex = 3}) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                side: BorderSide.none,
                foregroundColor: Colors.green.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => EditProductDialog(
                    product: product,
                    categories: categories,
                  ),
                );
              },
              child: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                    )
                  : Row(
                      children: [
                        Icon(Icons.mode_edit,
                            size: 18, color: Colors.green[600]),
                        const SizedBox(width: 4),
                        Text(
                          'Edit',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Colors.green[600],
                          ),
                        ),
                      ],
                    ),
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                side: BorderSide.none,
                foregroundColor: Colors.red.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: isLoading
                  ? null
                  : () async {
                      final confirm = await showDeleteConfirmDialog(
                        context,
                        message:
                            'Are you sure you want to delete "${product['name']}"? This action cannot be undone.',
                        title: 'Delete Product',
                      );

                      if (confirm == true && context.mounted) {
                        try {
                          await ref
                              .read(productProvider.notifier)
                              .deleteProduct(product['id']);
                          if (context.mounted) {
                            showSuccessSnackBar(
                                context, 'Product deleted successfully');
                          }
                        } catch (e) {
                          if (context.mounted) {
                            if (isSessionExpiredError(e)) {
                              await handleSessionExpired(context, ref);
                              return;
                            }

                            showErrorDialog(context, e.toString(),
                                title: 'Delete Failed');
                          }
                        }
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                      ),
                    )
                  : Row(
                      children: [
                        Icon(Icons.delete, size: 18, color: Colors.red[600]),
                        const SizedBox(width: 4),
                        Text(
                          'Delete',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[600],
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
