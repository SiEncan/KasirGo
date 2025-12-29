import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasir_go/providers/cart_provider.dart';
import 'package:kasir_go/utils/currency_helper.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PaymentSuccessDialog extends ConsumerWidget {
  final String? trxId;
  final double? total;
  final double? paid;
  final double? change;
  final String paymentMethod;

  const PaymentSuccessDialog({
    super.key,
    this.trxId,
    this.total,
    this.paid,
    this.change,
    this.paymentMethod = 'Cash',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.circleCheckBig500,
                color: Color.fromARGB(255, 86, 197, 90),
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Payment Successful!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Your transaction has been completed',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    'Order ID',
                    trxId ?? '-',
                    valStyle: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  Divider(height: 24, color: Colors.grey.shade300),
                  _buildDetailRow(
                    'Payment Method',
                    paymentMethod,
                    valStyle: const TextStyle(
                        fontWeight: FontWeight.w500, color: Colors.black87),
                  ),
                  Divider(height: 24, color: Colors.grey.shade300),
                  _buildDetailRow(
                    'Total Amount',
                    CurrencyHelper.formatIDR(total ?? 0),
                    valStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                      fontSize: 16,
                    ),
                  ),
                  Divider(height: 24, color: Colors.grey.shade300),
                  _buildDetailRow(
                    'Change',
                    CurrencyHelper.formatIDR(change ?? 0),
                    valStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4CAF50),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implement Print Logic
                    },
                    icon: const Icon(LucideIcons.printer, size: 18),
                    label: const Text('Print Receipt',
                        style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade100,
                      foregroundColor: Colors.black87,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ref.read(cartProvider.notifier).clearCart();
                      Navigator.pop(context);
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label:
                        const Text('New Order', style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {TextStyle? valStyle}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: valStyle ??
              const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
        ),
      ],
    );
  }
}
