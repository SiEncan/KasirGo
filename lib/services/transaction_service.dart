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

  Future<Map<String, dynamic>> getTransactions(
      {int page = 1, int pageSize = 10, String? search}) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'page_size': pageSize,
      };
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await dioClient.dio.get(
        '/transaction/',
        queryParameters: queryParams,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to get transactions');
    }
  }

  Future<Map<String, dynamic>> getTransaction(int transactionId) async {
    try {
      final response = await dioClient.dio.get(
        '/transaction/$transactionId/',
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to get transaction');
    }
  }

  Future<void> deleteTransaction(int transactionId) async {
    try {
      await dioClient.dio.delete(
        '/transaction/$transactionId/',
      );
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to delete transaction');
    }
  }

  Future<Map<String, dynamic>> updateTransaction(
      int transactionId, Map<String, dynamic> data) async {
    try {
      final response = await dioClient.dio.patch(
        '/transaction/$transactionId/',
        data: data,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to update transaction');
    }
  }

  /// Extract AppException from DioException or create fallback
  AppException _handleError(DioException e, String fallback) {
    if (e.error is AppException) return e.error as AppException;
    return AppException(fallback);
  }
}
