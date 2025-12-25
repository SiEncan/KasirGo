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

  // Search State
  final String searchQuery;

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
    this.searchQuery = '',
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
    String? searchQuery,
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
      searchQuery: searchQuery ?? this.searchQuery,
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
      final result = await _service.getTransactions(
        page: state.page,
        search: state.searchQuery,
      );
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

  Future<void> searchTransactions(String query) async {
    state = state.copyWith(
      searchQuery: query,
      page: 1,
      hasMore: true,
      transactions: [],
      isLoading: true,
    );
    await fetchTransactions();
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

  Future<bool> deleteTransaction(int id) async {
    try {
      await _service.deleteTransaction(id);

      // Remove from local list if exists
      final updatedTransactions =
          state.transactions.where((t) => t['id'] != id).toList();

      state = state.copyWith(
        transactions: updatedTransactions,
        selectedTransaction: state.selectedTransaction?['id'] == id
            ? null
            : state.selectedTransaction,
      );

      // Optionally re-fetch to be sure
      await fetchTransactions(refresh: true);

      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> updateTransaction(int id, Map<String, dynamic> data) async {
    try {
      final result = await _service.updateTransaction(id, data);
      final updatedData = result['data'];

      // Update local list
      final updatedTransactions = state.transactions.map((t) {
        return t['id'] == id ? updatedData : t;
      }).toList();

      state = state.copyWith(
        transactions: List<Map<String, dynamic>>.from(updatedTransactions),
        selectedTransaction: state.selectedTransaction?['id'] == id
            ? updatedData
            : state.selectedTransaction,
      );

      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
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
