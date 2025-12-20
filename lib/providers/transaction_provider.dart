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

  TransactionState({
    this.isLoading = false,
    this.currentTransaction,
    this.errorMessage,
    this.isSuccess = false,
  });

  TransactionState copyWith({
    bool? isLoading,
    Map<String, dynamic>? currentTransaction,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return TransactionState(
      isLoading: isLoading ?? this.isLoading,
      currentTransaction: currentTransaction ?? this.currentTransaction,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class TransactionNotifier extends StateNotifier<TransactionState> {
  final TransactionService _service;

  TransactionNotifier(this._service) : super(TransactionState());

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

  void reset() {
    state = TransactionState();
  }
}

final transactionProvider =
    StateNotifierProvider<TransactionNotifier, TransactionState>((ref) {
  final service = ref.read(transactionServiceProvider);
  return TransactionNotifier(service);
});
