import 'dart:async';
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
  Timer? _timer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

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
    final isTakeAway = order['order_type'] == 'take_away';
    final orderType = isTakeAway ? 'Take Away' : 'Dine In';

    // Duration Display Logic
    final durationStr = '${duration.inMinutes}m';
    Color durationBgColor;
    Color durationTextColor;
    Color durationBorderColor;

    if (duration.inMinutes > 45) {
      // Merah Tua (Critical)
      durationBgColor = Colors.red.shade700;
      durationTextColor = Colors.white;
      durationBorderColor = Colors.red.shade900;
    } else if (duration.inMinutes > 30) {
      // Merah Muda (Late)
      durationBgColor = Colors.red.shade100;
      durationTextColor = Colors.red.shade900;
      durationBorderColor = Colors.red.shade300;
    } else if (duration.inMinutes > 15) {
      // Oren (Warning)
      durationBgColor = Colors.orange.shade50;
      durationTextColor = Colors.orange.shade900;
      durationBorderColor = Colors.orange.shade300;
    } else {
      // Hijau (Normal)
      durationBgColor = Colors.green.shade100;
      durationTextColor = Colors.green.shade700;
      durationBorderColor = Colors.green.shade200;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isLate ? Colors.red.shade50 : Colors.green.shade50,
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '#${order['transaction_number']?.toString().split('-').last ?? '?'}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order['customer_name'] ?? 'Guest',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: isTakeAway
                              ? Colors.purple.shade50
                              : Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isTakeAway
                                ? Colors.purple.shade200
                                : Colors.teal.shade200,
                          ),
                        ),
                        child: Text(
                          orderType.toUpperCase(),
                          style: TextStyle(
                            color: isTakeAway
                                ? Colors.purple.shade700
                                : Colors.teal.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Duration Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              color: durationBgColor,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: durationBorderColor),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(LucideIcons.timer,
                                    size: 16, color: durationTextColor),
                                const SizedBox(width: 4),
                                Text(
                                  durationStr,
                                  style: TextStyle(
                                    color: durationTextColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Time Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Text(
                              timeStr,
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Items List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (ctx, i) => Divider(
                    height: 24, color: Colors.grey.shade200, thickness: 2),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final hasNote = item['notes'] != null &&
                      item['notes'].toString().isNotEmpty;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.orange.shade200),
                            ),
                            child: Text(
                              '${item['quantity']}x',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item['product_name'] ?? 'Unknown Item',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (hasNote)
                        Padding(
                          padding: const EdgeInsets.only(left: 40, top: 4),
                          child: Text(
                            'Note: ${item['notes']}',
                            style: TextStyle(
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),

            // Transaction Note
            if (order['notes'] != null && order['notes'].toString().isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  border: Border.all(color: Colors.blue.shade200),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(LucideIcons.fileText,
                        size: 16, color: Colors.blue.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${order['notes']}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          setState(() {
                            _isLoading = true;
                          });

                          final result = await ref
                              .read(transactionProvider.notifier)
                              .updateTransaction(
                                  order['id'], {'status': 'completed'});

                          if (context.mounted) {
                            setState(() {
                              _isLoading = false;
                            });

                            if (result['success'] == true) {
                              if (result['kds_sent'] == false) {
                                showWarningSnackBar(context,
                                    'Marked as ready! Tapi gagal lapor Kasir/Display. Harap info manual.',
                                    title: 'Koneksi Terputus');
                              } else {
                                showSuccessSnackBar(
                                    context, 'Order marked as ready');
                              }
                              ref
                                  .read(transactionProvider.notifier)
                                  .fetchKitchenTransactions();
                            }
                          }
                        },
                  icon: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.grey,
                          ))
                      : const Icon(LucideIcons.check, size: 18),
                  label: Text(
                    _isLoading ? 'Processing...' : 'MARK AS READY',
                    style: TextStyle(
                        color: _isLoading ? Colors.grey : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade200,
                    disabledForegroundColor: Colors.grey,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
