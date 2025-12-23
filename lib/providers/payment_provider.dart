import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/payment_service.dart';
import 'category_provider.dart';

final paymentServiceProvider = Provider<PaymentService>((ref) {
  final dioClient = ref.read(dioClientProvider);
  return PaymentService(dioClient: dioClient);
});

class PaymentState {
  final bool isLoading;
  final Map<String, dynamic>? currentPayment;
  final String? errorMessage;
  final bool isPaymentSuccess;

  PaymentState({
    this.isLoading = false,
    this.currentPayment,
    this.errorMessage,
    this.isPaymentSuccess = false,
  });

  PaymentState copyWith({
    bool? isLoading,
    Map<String, dynamic>? currentPayment,
    String? errorMessage,
    bool? isPaymentSuccess,
  }) {
    return PaymentState(
      isLoading: isLoading ?? this.isLoading,
      currentPayment: currentPayment ?? this.currentPayment,
      errorMessage: errorMessage, // Reset error message if not provided
      isPaymentSuccess: isPaymentSuccess ?? this.isPaymentSuccess,
    );
  }
}

class PaymentNotifier extends StateNotifier<PaymentState> {
  final PaymentService _service;
  Timer? _pollingTimer;

  PaymentNotifier(this._service) : super(PaymentState());

  Future<bool> createPayment(Map<String, dynamic> paymentData) async {
    state = state.copyWith(isLoading: true, isPaymentSuccess: false);
    try {
      final result = await _service.createPayment(paymentData);
      state = state.copyWith(
        isLoading: false,
        currentPayment: result['data'],
      );

      // If QRIS or Virtual Account, start polling
      if (paymentData['payment_method'] == 'SP' ||
          paymentData['payment_method'] == 'BC') {
        _startPolling(result['data']['payment_id']);
      }

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  void _startPolling(int paymentId) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      await checkPaymentStatus(paymentId);
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> checkPaymentStatus(int paymentId) async {
    try {
      final result = await _service.getPaymentStatus(paymentId);
      final statusData = result['data'];

      print(
          "PAYMENT POLLING STATUS: ${statusData['status']} for ID: $paymentId");

      if (statusData['status'] == 'success') {
        state = state.copyWith(
          isPaymentSuccess: true,
          currentPayment: statusData,
        );
        stopPolling();
      } else if (statusData['status'] == 'failed' ||
          statusData['status'] == 'cancelled' ||
          statusData['status'] == 'expired') {
        state = state.copyWith(
          errorMessage: 'Payment ${statusData['status']}',
        );
        stopPolling();
      }
    } catch (e) {
      print("Polling error: $e");
    }
  }

  void reset() {
    stopPolling();
    state = PaymentState();
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}

final paymentProvider =
    StateNotifierProvider<PaymentNotifier, PaymentState>((ref) {
  final service = ref.read(paymentServiceProvider);
  return PaymentNotifier(service);
});
