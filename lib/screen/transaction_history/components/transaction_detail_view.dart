import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:kasir_go/providers/setting_provider.dart';
import 'package:kasir_go/providers/transaction_provider.dart';
import 'package:kasir_go/screen/transaction_history/components/receipt_widgets.dart';
import 'package:kasir_go/utils/currency_helper.dart';
import 'package:kasir_go/utils/dialog_helper.dart';
import 'package:kasir_go/utils/snackbar_helper.dart';

class TransactionDetailView extends ConsumerWidget {
  const TransactionDetailView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transactionProvider);
    final transaction = state.selectedTransaction;
    final settings = ref.read(settingProvider);

    if (state.isLoadingDetail) {
      return Center(
          child: CircularProgressIndicator(color: Colors.orange.shade700));
    }

    if (transaction == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.receipt, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              "Select a transaction based on the list",
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    final customer = transaction['customer_name'] ?? '-';
    final items = (transaction['items'] as List<dynamic>?) ?? [];
    final totalAmount = double.parse((transaction['total'] ?? 0).toString());
    final transNo = transaction['transaction_number'] ?? '-';
    final dateString = transaction['created_at'];
    final cashierName = transaction['cashier_name'] ?? '-';
    final subtotal = double.parse((transaction['subtotal'] ?? 0).toString());
    final tax = double.parse((transaction['tax'] ?? 0).toString());
    final paymentMethod = transaction['payment_method'] ?? '-';
    final discount = double.parse((transaction['discount'] ?? 0).toString());
    final paidAmount =
        double.parse((transaction['paid_amount'] ?? 0).toString());
    final changeAmount =
        double.parse((transaction['change_amount'] ?? 0).toString());
    final takeAwayCharge =
        double.parse((transaction['takeaway_charge'] ?? 0).toString());
    final notes = transaction['notes'] ?? '';
    String orderType = transaction['order_type'] ?? '-';

    final status = transaction['status'] == 'completed'
        ? 'Paid'
        : transaction['status'] == 'pending'
            ? 'Unpaid'
            : transaction['status'] == 'cancelled'
                ? 'Cancelled'
                : 'Failed';

    if (orderType.isNotEmpty && orderType != '-') {
      orderType = orderType
          .replaceAll('_', ' ')
          .split(' ')
          .map((str) =>
              str.isNotEmpty ? str[0].toUpperCase() + str.substring(1) : '')
          .join(' ');
    }

    DateTime? date;
    if (dateString != null) {
      try {
        date = DateTime.parse(dateString);
      } catch (_) {}
    }
    final formattedDate =
        date != null ? DateFormat('HH:mm | dd/MM/yy').format(date) : '-';

    return Column(
      children: [
        Text(
          settings.storeName,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.orange.shade800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          settings.storeAddress,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w300,
            color: Colors.grey.shade900,
          ),
        ),
        Text(
          'Telp: ${settings.storePhone}',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w300,
            color: Colors.grey.shade900,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: DashedDivider(color: Colors.grey.shade700),
        ),
        Row(
          children: [
            Text(
              'Pelanggan',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w300,
                color: Colors.grey.shade900,
              ),
            ),
            const Spacer(),
            Text(
              customer,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text(
              'Transaction No.',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w300,
                color: Colors.grey.shade900,
              ),
            ),
            const Spacer(),
            Text(
              transNo,
              style: const TextStyle(
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text(
              'Tanggal',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w300,
                color: Colors.grey.shade900,
              ),
            ),
            const Spacer(),
            Text(
              formattedDate,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text(
              'Tipe Pesanan',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w300,
                color: Colors.grey.shade900,
              ),
            ),
            const Spacer(),
            Text(
              orderType,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text(
              'Kasir',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w300,
                color: Colors.grey.shade900,
              ),
            ),
            const Spacer(),
            Text(
              cashierName,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text(
              'Pembayaran',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w300,
                color: Colors.grey.shade900,
              ),
            ),
            const Spacer(),
            Text(
              paymentMethod,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text(
              'Status',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w300,
                color: Colors.grey.shade900,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: status == 'Paid'
                    ? Colors.green.shade100
                    : Colors.red.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: status == 'Paid'
                      ? Colors.green.shade500
                      : Colors.red.shade500,
                ),
              ),
            ),
          ],
        ),
        if (notes.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Catatan:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade900,
            ),
          ),
          Text(
            notes,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w300,
              color: Colors.grey.shade800,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: DashedDivider(color: Colors.grey.shade700),
        ),
        Row(
          children: [
            Text(
              'ITEM',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w300,
                color: Colors.grey.shade900,
              ),
            ),
            const Spacer(),
            Text(
              'JUMLAH',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w300,
                color: Colors.grey.shade900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Item List
        ...items.map((item) {
          final productName = item['product_name'] ?? 'Unknown';
          final quantity = item['quantity'] ?? 0;
          final price = double.parse((item['price'] ?? 0).toString());
          final itemSubtotal = double.parse((item['subtotal'] ?? 0).toString());

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                productName,
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade800,
                ),
              ),
              if (item['notes'] != null &&
                  item['notes'].toString().isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  item['notes'],
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '$quantity x ${CurrencyHelper.formatIDR(price)}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w300,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    CurrencyHelper.formatIDR(itemSubtotal),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          );
        }),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: DashedDivider(color: Colors.grey.shade700),
        ),

        // Totals
        Row(
          children: [
            Text(
              'Subtotal',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w300,
                color: Colors.grey.shade900,
              ),
            ),
            const Spacer(),
            Text(
              CurrencyHelper.formatIDR(subtotal),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ],
        ),
        if (discount > 0) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                'Discount',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w300,
                  color: Colors.grey.shade900,
                ),
              ),
              const Spacer(),
              Text(
                '- ${CurrencyHelper.formatIDR(discount)}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 6),
        Row(
          children: [
            Text(
              'Pajak (${(tax / subtotal * 100).toStringAsFixed(0)}%)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w300,
                color: Colors.grey.shade900,
              ),
            ),
            const Spacer(),
            Text(
              CurrencyHelper.formatIDR(tax),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ],
        ),
        if (takeAwayCharge > 0) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                'Take Away Charge',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w300,
                  color: Colors.grey.shade900,
                ),
              ),
              const Spacer(),
              Text(
                CurrencyHelper.formatIDR(takeAwayCharge),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: DashedDivider(color: Colors.grey.shade700),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Text(
              'TOTAL',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const Spacer(),
            Text(
              CurrencyHelper.formatIDR(totalAmount),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              'Bayar',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w300,
                color: Colors.grey.shade900,
              ),
            ),
            const Spacer(),
            Text(
              CurrencyHelper.formatIDR(paidAmount),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              'Kembali',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w300,
                color: Colors.grey.shade900,
              ),
            ),
            const Spacer(),
            Text(
              CurrencyHelper.formatIDR(changeAmount),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: DashedDivider(color: Colors.grey.shade700),
        ),
        Text(
          settings.receiptFooter,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w300,
            color: Colors.grey.shade900,
          ),
        ),
        const SizedBox(height: 16),
        BarcodeWidget(
          barcode: Barcode.code128(),
          data: transNo,
          height: 50,
          drawText: false,
        ),
        const SizedBox(height: 6),
        Text(
          transNo,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w300,
            color: Colors.grey.shade900,
          ),
        ),

        if (transaction['status'] != 'cancelled') ...[
          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () async {
                      final changes = await showEditTransactionDialog(
                        context,
                        currentCustomerName: customer == '-' ? '' : customer,
                        currentNotes: notes,
                      );

                      if (changes != null && context.mounted) {
                        final success = await ref
                            .read(transactionProvider.notifier)
                            .updateTransaction(transaction['id'], changes);

                        if (context.mounted) {
                          if (success) {
                            showSuccessSnackBar(
                                context, 'Transaction updated successfully');
                          } else {
                            showErrorSnackBar(
                                context, 'Failed to update transaction');
                          }
                        }
                      }
                    },
                    icon:
                        const Icon(Iconsax.edit, color: Colors.blue, size: 18),
                    label: const Text(
                      "Edit Info",
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.blue.shade50,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () async {
                      final confirm = await showDeleteConfirmDialog(context,
                          title: 'Delete Transaction?',
                          message:
                              'This will delete the transaction and RESTORE stock. This action cannot be undone.\n\nUse this only for double transactions or errors.');
                      if (confirm == true && context.mounted) {
                        final success = await ref
                            .read(transactionProvider.notifier)
                            .deleteTransaction(transaction['id']);

                        if (context.mounted) {
                          if (success) {
                            showSuccessSnackBar(
                                context, 'Transaction deleted successfully');
                          } else {
                            showErrorSnackBar(
                                context, 'Failed to delete transaction');
                          }
                        }
                      }
                    },
                    icon:
                        const Icon(Iconsax.trash, color: Colors.red, size: 18),
                    label: const Text(
                      "Void / Delete",
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
