import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/transaction_service.dart';
import 'category_provider.dart';

final transactionServiceProvider = Provider<TransactionService>((ref) {
  final dioClient = ref.read(dioClientProvider);
  return TransactionService(dioClient: dioClient);
});

class TransactionState {
  final bool isLoading;
  final Map<String, dynamic>? currentTransaction;
  final String? errorMessage;
  final bool isSuccess;

  // Pagination State
  final List<Map<String, dynamic>> transactions;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;

  // Detail State
  final Map<String, dynamic>? selectedTransaction;
  final bool isLoadingDetail;

  TransactionState({
    this.isLoading = false,
    this.currentTransaction,
    this.errorMessage,
    this.isSuccess = false,
    this.transactions = const [],
    this.page = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.selectedTransaction,
    this.isLoadingDetail = false,
  });

  TransactionState copyWith({
    bool? isLoading,
    Map<String, dynamic>? currentTransaction,
    String? errorMessage,
    bool? isSuccess,
    List<Map<String, dynamic>>? transactions,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
    Map<String, dynamic>? selectedTransaction,
    bool? isLoadingDetail,
  }) {
    return TransactionState(
      isLoading: isLoading ?? this.isLoading,
      currentTransaction: currentTransaction ?? this.currentTransaction,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
      transactions: transactions ?? this.transactions,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      selectedTransaction: selectedTransaction ?? this.selectedTransaction,
      isLoadingDetail: isLoadingDetail ?? this.isLoadingDetail,
    );
  }
}

class TransactionNotifier extends StateNotifier<TransactionState> {
  final TransactionService _service;

  TransactionNotifier(this._service) : super(TransactionState());

  void selectTransaction(int id) {
    try {
      final transaction = state.transactions.firstWhere((t) => t['id'] == id);
      state = state.copyWith(
        selectedTransaction: transaction,
        isLoadingDetail: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Transaction not found in local list',
        isLoadingDetail: false,
      );
    }
  }

  Future<void> fetchTransactions({bool refresh = false}) async {
    if (state.isLoadingMore) return;

    if (refresh) {
      state = state.copyWith(
        page: 1,
        hasMore: true,
        transactions: [],
        isLoading: true, // Show main loading only on refresh/initial
      );
    } else {
      if (!state.hasMore) return;
      state = state.copyWith(isLoadingMore: true);
    }

    try {
      final result = await _service.getTransactions(page: state.page);
      final List<Map<String, dynamic>> newTransactions =
          List<Map<String, dynamic>>.from(result['data'] ?? []);

      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        transactions: [...state.transactions, ...newTransactions],
        page: state.page + 1,
        hasMore: newTransactions.isNotEmpty, // Assuming empty means end
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<Map<String, dynamic>?> createTransaction(
      Map<String, dynamic> data) async {
    state =
        state.copyWith(isLoading: true, isSuccess: false, errorMessage: null);
    try {
      final result = await _service.createTransaction(data);
      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        currentTransaction: result['data'],
      );
      return result['data'];
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getTransactions() async {
    state =
        state.copyWith(isLoading: true, isSuccess: false, errorMessage: null);
    try {
      final result = await _service.getTransactions();
      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        currentTransaction: result['data'],
      );
      return result['data'];
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return null;
    }
  }

  void reset() {
    state = TransactionState();
  }
}

final transactionProvider =
    StateNotifierProvider<TransactionNotifier, TransactionState>((ref) {
  final service = ref.read(transactionServiceProvider);
  return TransactionNotifier(service);
});
