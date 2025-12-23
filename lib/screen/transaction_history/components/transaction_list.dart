import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:kasir_go/providers/transaction_provider.dart';
import 'package:kasir_go/utils/currency_helper.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class TransactionList extends ConsumerStatefulWidget {
  const TransactionList({super.key});

  @override
  ConsumerState<TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends ConsumerState<TransactionList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(transactionProvider.notifier).fetchTransactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transactionProvider);

    if (state.isLoading && state.transactions.isEmpty) {
      return Center(
          child: CircularProgressIndicator(
        color: Colors.orange.shade700,
      ));
    }

    if (state.errorMessage != null && state.transactions.isEmpty) {
      return Center(child: Text('Error: ${state.errorMessage}'));
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
        itemCount: state.transactions.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.transactions.length) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircularProgressIndicator(color: Colors.orange.shade700),
              ),
            );
          }

          final transaction = state.transactions[index];
          final amount = double.parse(transaction['total'] ?? 0);
          final formattedAmount = CurrencyHelper.formatIDR(amount);
          final dateString = transaction['created_at'] ?? '';
          DateTime? date;
          try {
            date = DateTime.parse(dateString);
          } catch (_) {}
          final formattedTime =
              date != null ? DateFormat('hh:mm a').format(date) : '-';
          final formattedDate = date != null
              ? DateFormat('EEEE, MMMM d, yyyy').format(date)
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

          final selectedTransaction = state.selectedTransaction;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showHeader)
                Padding(
                  padding: const EdgeInsets.only(
                      left: 12.0, right: 12.0, top: 16.0, bottom: 8.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.orange.shade100),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Iconsax.calendar_1,
                              size: 14,
                              color: Colors.orange.shade800,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              formattedDate,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Divider(
                          color: Colors.orange.shade600,
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              InkWell(
                onTap: () {
                  if (transaction['id'] != null) {
                    ref
                        .read(transactionProvider.notifier)
                        .selectTransaction(transaction['id']);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: selectedTransaction?['id'] == transaction['id']
                        ? Colors.orange.shade50
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: selectedTransaction?['id'] == transaction['id']
                        ? Border.all(color: Colors.orange.shade500, width: 1.5)
                        : Border.all(color: Colors.transparent, width: 1.5),
                    boxShadow: selectedTransaction?['id'] == transaction['id']
                        ? [
                            BoxShadow(
                              color: Colors.orange.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : null,
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: selectedTransaction?['id'] == transaction['id']
                              ? Colors.orange.shade100
                              : Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: transaction['payment_method'] == 'cash'
                            ? Icon(
                                LucideIcons.wallet,
                                color: selectedTransaction?['id'] ==
                                        transaction['id']
                                    ? Colors.orange.shade700
                                    : Colors.grey.shade500,
                                size: 24,
                              )
                            : transaction['payment_method'] == 'qris'
                                ? Icon(
                                    LucideIcons.qrCode,
                                    color: selectedTransaction?['id'] ==
                                            transaction['id']
                                        ? Colors.orange.shade700
                                        : Colors.grey.shade500,
                                    size: 24,
                                  )
                                : Icon(
                                    Iconsax.card,
                                    color: selectedTransaction?['id'] ==
                                            transaction['id']
                                        ? Colors.orange.shade700
                                        : Colors.grey.shade600,
                                    size: 24,
                                  ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: selectedTransaction?['id'] ==
                                      transaction['id']
                                  ? Colors.orange.shade900
                                  : Colors.black87,
                            ),
                            child: Text(
                              formattedAmount,
                            ),
                          ),
                          const SizedBox(height: 4),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              fontSize: 12,
                              color: selectedTransaction?['id'] ==
                                      transaction['id']
                                  ? Colors.orange.shade700
                                  : Colors.grey.shade500,
                            ),
                            child: Text(
                              formattedTime,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: selectedTransaction?['id'] == transaction['id']
                              ? Colors.white
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color:
                                selectedTransaction?['id'] == transaction['id']
                                    ? Colors.orange.shade200
                                    : Colors.grey.shade200,
                          ),
                        ),
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color:
                                selectedTransaction?['id'] == transaction['id']
                                    ? Colors.orange.shade700
                                    : Colors.grey.shade600,
                          ),
                          child: Text(
                            "#${transaction['transaction_number'] ?? '-'}",
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              if (showDivider)
                Divider(
                  color: Colors.grey.shade300,
                  thickness: 1,
                  height: 1,
                ),
            ],
          );
        },
      ),
    );
  }
}
