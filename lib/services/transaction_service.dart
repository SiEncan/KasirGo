import 'package:dio/dio.dart';
import '../utils/app_exception.dart';
import 'dio_client.dart';

class TransactionService {
  final DioClient dioClient;

  TransactionService({required this.dioClient});

  Future<Map<String, dynamic>> createTransaction(
      Map<String, dynamic> transactionData) async {
    print(transactionData);
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

  Future<Map<String, dynamic>> getTransactions(
      {int page = 1, int pageSize = 10}) async {
    try {
      final response = await dioClient.dio.get(
        '/transaction/',
        queryParameters: {
          'page': page,
          'page_size': pageSize,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to get transactions');
    }
  }

  Future<Map<String, dynamic>> getTransaction(int transactionId) async {
    try {
      final response = await dioClient.dio.get(
        '/transaction/$transactionId',
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to get transaction');
    }
  }

  /// Extract AppException from DioException or create fallback
  AppException _handleError(DioException e, String fallback) {
    if (e.error is AppException) return e.error as AppException;
    return AppException(fallback);
  }
}
