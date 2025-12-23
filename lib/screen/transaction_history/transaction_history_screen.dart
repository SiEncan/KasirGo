import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:barcode_widget/barcode_widget.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/transaction_provider.dart';
import 'package:intl/intl.dart';

class TransactionHistoryScreen extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState
    extends ConsumerState<TransactionHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Initial fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(transactionProvider.notifier).fetchTransactions(refresh: true);
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(transactionProvider.notifier).fetchTransactions();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Container(
              width: 400,
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
                            Iconsax.receipt,
                            color: Colors.orange.shade700,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Receipts",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: TextEditingController(),
                      decoration: InputDecoration(
                        hintText: 'Search',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                        prefixIcon: Icon(
                          Iconsax.search_normal,
                          color: Colors.grey.shade500,
                          size: 20,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: Colors.grey.shade500,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.orange.shade600,
                            width: 1.5,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Consumer(
                      builder: (context, ref, child) {
                        final state = ref.watch(transactionProvider);

                        if (state.isLoading && state.transactions.isEmpty) {
                          return Center(
                              child: CircularProgressIndicator(
                            color: Colors.orange.shade700,
                          ));
                        }

                        if (state.errorMessage != null &&
                            state.transactions.isEmpty) {
                          return Center(
                              child: Text('Error: ${state.errorMessage}'));
                        }

                        if (state.transactions.isEmpty) {
                          return const Center(child: Text('No transactions'));
                        }

                        return RefreshIndicator(
                          color: Colors.orange,
                          onRefresh: () async {
                            await ref
                                .read(transactionProvider.notifier)
                                .fetchTransactions(refresh: true);
                          },
                          child: ListView.builder(
                            controller: _scrollController,
                            itemCount: state.transactions.length +
                                (state.isLoadingMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == state.transactions.length) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: CircularProgressIndicator(
                                        color: Colors.orange.shade700),
                                  ),
                                );
                              }

                              final transaction = state.transactions[index];
                              final amount =
                                  double.parse(transaction['total'] ?? 0);
                              final formattedAmount = NumberFormat.currency(
                                      locale: 'id_ID',
                                      symbol: 'Rp ',
                                      decimalDigits: 0)
                                  .format(amount);
                              final dateString =
                                  transaction['created_at'] ?? '';
                              DateTime? date;
                              try {
                                date = DateTime.parse(dateString);
                              } catch (_) {}
                              final formattedTime = date != null
                                  ? DateFormat('hh:mm a').format(date)
                                  : '-';
                              final formattedDate = date != null
                                  ? DateFormat('EEEE, MMMM d, yyyy')
                                      .format(date)
                                  : '-';

                              // Check if we need a date header
                              bool showHeader = true;
                              if (index > 0) {
                                final prevTx = state.transactions[index - 1];
                                final prevDateString = prevTx['created_at'];
                                DateTime? prevDate;
                                try {
                                  prevDate = DateTime.parse(prevDateString);
                                } catch (_) {}

                                if (date != null && prevDate != null) {
                                  if (DateUtils.isSameDay(date, prevDate)) {
                                    showHeader = false;
                                  }
                                }
                              }

                              // Divider Logic: Hide if last item OR next item is different day
                              bool showDivider = true;
                              if (index == state.transactions.length - 1) {
                                showDivider = false;
                              } else {
                                final nextTx = state.transactions[index + 1];
                                final nextDateString = nextTx['created_at'];
                                DateTime? nextDate;
                                try {
                                  nextDate = DateTime.parse(nextDateString);
                                } catch (_) {}

                                if (date != null && nextDate != null) {
                                  if (!DateUtils.isSameDay(date, nextDate)) {
                                    showDivider = false;
                                  }
                                }
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (showHeader) ...[
                                    if (index != 0)
                                      Divider(
                                        color: Colors.grey.shade200,
                                        thickness: 2,
                                        height: 5,
                                      ),
                                    Container(
                                      width: double.infinity,
                                      padding:
                                          const EdgeInsets.fromLTRB(8, 8, 8, 8),
                                      child: Text(
                                        formattedDate,
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.orange.shade700,
                                        ),
                                      ),
                                    ),
                                    Divider(
                                      color: Colors.grey.shade200,
                                      thickness: 2,
                                      height: 5,
                                    ),
                                  ],
                                  InkWell(
                                    onTap: () {
                                      if (transaction['id'] != null) {
                                        ref
                                            .read(transactionProvider.notifier)
                                            .selectTransaction(
                                                transaction['id']);
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.fromLTRB(
                                          12, 12, 12, 12),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Iconsax.wallet,
                                            color: Colors.grey.shade800,
                                            size: 32,
                                          ),
                                          const SizedBox(width: 12),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                formattedAmount,
                                                textAlign: TextAlign.left,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                ),
                                              ),
                                              Text(
                                                formattedTime,
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Spacer(),
                                          Text(
                                            "#${transaction['transaction_number'] ?? '-'}",
                                            style: TextStyle(
                                                color: Colors.grey.shade600),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (showDivider)
                                    Divider(
                                      color: Colors.grey.shade200,
                                      thickness: 1,
                                      height: 1,
                                    ),
                                ],
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            VerticalDivider(
              color: Colors.grey.shade200,
              thickness: 1,
              width: 1,
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                color: Colors.grey.shade100,
                child: Center(
                  child: CustomPaint(
                    painter: ZigZagShadowPainter(),
                    child: ClipPath(
                      clipper: ZigZagClipper(),
                      child: Container(
                        width: 400,
                        color: Colors.white,
                        padding: const EdgeInsets.all(48),
                        child: SingleChildScrollView(
                          child: _buildDetailView(ref),
                        ),
                      ),
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

  Widget _buildDetailView(WidgetRef ref) {
    final state = ref.watch(transactionProvider);
    final transaction = state.selectedTransaction;

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

    final status = transaction['status'] == 'completed' ? 'Paid' : 'Unpaid';

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
        date != null ? DateFormat('HH.mm dd MMM yy').format(date) : '-';

    return Column(
      children: [
        Text(
          "KasirGo",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.orange.shade800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Jl. Setiabudhi No. 123, Jakarta',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w300,
            color: Colors.grey.shade900,
          ),
        ),
        Text(
          'Telp: 021-23456789',
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
              'No. Order',
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
                    '$quantity x ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(price)}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w300,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    NumberFormat.currency(
                            locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
                        .format(itemSubtotal),
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
              NumberFormat.currency(
                      locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
                  .format(
                      subtotal), // Assuming subtotal logic if needed, or just use total for now
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
                '- ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(discount)}',
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
              NumberFormat.currency(
                      locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
                  .format(tax),
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
                NumberFormat.currency(
                        locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
                    .format(takeAwayCharge),
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
              NumberFormat.currency(
                      locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
                  .format(totalAmount),
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
              NumberFormat.currency(
                      locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
                  .format(paidAmount),
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
              NumberFormat.currency(
                      locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
                  .format(changeAmount),
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
          'Terima kasih atas kunjungan anda!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w300,
            color: Colors.grey.shade900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Barang yang sudah dibeli tidak dapat',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w300,
            color: Colors.grey.shade900,
          ),
        ),
        Text(
          'dikembalikan',
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
      ],
    );
  }
}

Path getZigZagPath(Size size) {
  Path path = Path();
  // Smaller zig-zag size
  double toothWidth = 10.0;
  double toothHeight = 6.0;

  // Calculate exact tooth width to fit perfectly
  int count = (size.width / toothWidth).ceil();
  double actualToothWidth = size.width / count;

  path.moveTo(0, toothHeight);

  // Top Zigzag (Spikes pointing up)
  for (int i = 0; i < count; i++) {
    double x = i * actualToothWidth;
    path.lineTo(x + actualToothWidth / 2, 0);
    path.lineTo(x + actualToothWidth, toothHeight);
  }

  // Right Side
  path.lineTo(size.width, size.height - toothHeight);

  // Bottom Zigzag (Spikes pointing down)
  for (int i = 0; i < count; i++) {
    double x = size.width - (i * actualToothWidth);
    path.lineTo(x - actualToothWidth / 2, size.height);
    path.lineTo(x - actualToothWidth, size.height - toothHeight);
  }

  // Left Side
  path.lineTo(0, toothHeight);

  path.close();
  return path;
}

class ZigZagShadowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path = getZigZagPath(size);

    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.grey.shade300
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class ZigZagClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => getZigZagPath(size);

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class DashedDivider extends StatelessWidget {
  final double height;
  final Color color;
  final double dashWidth;

  const DashedDivider({
    super.key,
    this.height = 1,
    this.color = Colors.black,
    this.dashWidth = 5.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: height,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
        );
      },
    );
  }
}
