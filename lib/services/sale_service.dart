import 'package:dio/dio.dart';
import '../utils/dio.dart';

class SaleService {
  Future<Map<String, dynamic>> getMonthlySales({int? month, int? year}) async {
    try {
      final response = await dio.get('/transactions', queryParameters: {
        'month': month,
        'year': year,
      });
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal mengambil data bulanan');
    }
  }

  Future<Map<String, dynamic>> getTodayIncome() async {
    try {
      final response = await dio.get('/fee-today');
      return response.data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Gagal mengambil data pendapatan',
      );
    }
  }

  Future<bool> createSale({
    required int productId,
    required String date, // Format: YYYY-MM-DD
    required double totalAmount,
    required double fee,
    String? note,
  }) async {
    try {
      final response = await dio.post(
        '/transactions',
        data: {
          'product_id': productId,
          'date': date,
          'total_amount': totalAmount,
          'fee': fee,
          'note': note,
        },
      );
      return response.data['success'] == true;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Gagal menyimpan transaksi',
      );
    }
  }

  // UPDATE
  Future<bool> updateSale({
    required int id,
    required int productId,
    required String date,
    required double totalAmount,
    required double fee,
    String? note,
  }) async {
    try {
      final response = await dio.put('/transactions/$id', data: {
        'product_id': productId,
        'date': date,
        'total_amount': totalAmount,
        'fee': fee,
        'note': note,
      });
      return response.data['success'] == true;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal update transaksi');
    }
  }

  // HAPUS
  Future<bool> deleteSale(int id) async {
    try {
      final response = await dio.delete('/transactions/$id');
      return response.data['success'] == true;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal menghapus transaksi');
    }
  }
}
