import 'package:dio/dio.dart';
import '../utils/app_exception.dart';
import 'dio_client.dart';

class PaymentService {
  final DioClient dioClient;

  PaymentService({required this.dioClient});

  Future<Map<String, dynamic>> createPayment(
      Map<String, dynamic> paymentData) async {
    try {
      final response = await dioClient.dio.post(
        '/payment/create/',
        data: paymentData,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to create payment');
    }
  }

  Future<Map<String, dynamic>> getPaymentStatus(int paymentId) async {
    try {
      final response = await dioClient.dio.get('/payment/status/$paymentId/');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to fetch payment status');
    }
  }

  /// Extract AppException from DioException or create fallback
  AppException _handleError(DioException e, String fallback) {
    if (e.error is AppException) return e.error as AppException;
    return AppException(fallback);
  }
}
