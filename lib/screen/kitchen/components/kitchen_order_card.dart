import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasir_go/providers/transaction_provider.dart';
import 'package:kasir_go/utils/snackbar_helper.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';

class KitchenOrderCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> order;

  const KitchenOrderCard({super.key, required this.order});

  @override
  ConsumerState<KitchenOrderCard> createState() => _KitchenOrderCardState();
}

class _KitchenOrderCardState extends ConsumerState<KitchenOrderCard> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final items = order['items'] as List<dynamic>? ?? [];
    final timestamp = DateTime.tryParse(order['created_at'] ?? '')?.toLocal() ??
        DateTime.now().toLocal();
    final timeStr = DateFormat('HH:mm').format(timestamp);

    // Calculate duration since order
    final duration = DateTime.now().difference(timestamp);
    final isLate = duration.inMinutes > 15;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isLate ? Colors.red.shade50 : Colors.blue.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${order['transaction_number']?.toString().split('-').last ?? '?'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order['customer_name'] ?? 'Guest',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isLate ? Colors.red : Colors.blue,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    timeStr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Items List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              separatorBuilder: (ctx, i) => const Divider(height: 12),
              itemBuilder: (context, index) {
                final item = items[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${item['quantity']}x',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item['product_name'] ?? 'Unknown Item',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Footer Actions
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading
                    ? null
                    : () async {
                        setState(() {
                          _isLoading = true;
                        });

                        final success = await ref
                            .read(transactionProvider.notifier)
                            .updateTransaction(
                                order['id'], {'status': 'completed'});

                        if (context.mounted) {
                          setState(() {
                            _isLoading = false;
                          });

                          if (success) {
                            showSuccessSnackBar(
                                context, 'Order marked as served');
                            ref
                                .read(transactionProvider.notifier)
                                .fetchKitchenTransactions();
                          }
                        }
                      },
                icon: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.grey,
                        ))
                    : const Icon(LucideIcons.check, size: 16),
                label: Text(
                  _isLoading ? 'Processing...' : 'Mark Served',
                  style: TextStyle(
                      color: _isLoading ? Colors.grey : Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade200,
                  disabledForegroundColor: Colors.grey,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
