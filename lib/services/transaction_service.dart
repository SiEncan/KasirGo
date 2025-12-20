import 'package:dio/dio.dart';
import '../utils/app_exception.dart';
import 'dio_client.dart';

class TransactionService {
  final DioClient dioClient;

  TransactionService({required this.dioClient});

  Future<Map<String, dynamic>> createTransaction(
      Map<String, dynamic> transactionData) async {
    try {
      final response = await dioClient.dio.post(
        '/transaction/create/',
        data: transactionData,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to create transaction');
    }
  }

  /// Extract AppException from DioException or create fallback
  AppException _handleError(DioException e, String fallback) {
    if (e.error is AppException) return e.error as AppException;
    return AppException(fallback);
  }
}
