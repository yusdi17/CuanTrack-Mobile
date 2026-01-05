import 'package:dio/dio.dart';
import '../utils/dio.dart';

class SaleService {
  Future<Map<String, dynamic>> getMonthlySales() async {
    try {
      final response = await dio.get('/transactions');
      return response.data; 
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Terjadi kesalahan koneksi');
    }
  }

  Future<Map<String, dynamic>> getTodayIncome() async {
    try {
      final response = await dio.get('/fee-today');
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal mengambil data pendapatan');
    }
  }
}