import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:kasir_go/providers/transaction_provider.dart';

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
          final formattedAmount = NumberFormat.currency(
                  locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
              .format(amount);
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
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
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
                        .selectTransaction(transaction['id']);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.wallet,
                        color: Colors.grey.shade800,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                        style: TextStyle(color: Colors.grey.shade600),
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
  }
}
