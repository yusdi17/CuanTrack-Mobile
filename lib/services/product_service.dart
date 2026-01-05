import 'package:dio/dio.dart';
import '../utils/dio.dart';

class ProductService {
  
  // 1. GET ALL
  Future<List<dynamic>> getProducts() async {
    try {
      final response = await dio.get('/products');
      if (response.data['success'] == true) {
        return response.data['data'];
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal mengambil data produk');
    }
  }

  // CREATE
  Future<bool> createProduct(String name) async {
    try {
      final response = await dio.post('/products', data: {
        'name': name,
      });
      return response.data['success'] == true;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal menambah produk');
    }
  }

  // DELETE
  Future<bool> deleteProduct(int id) async {
    try {
      final response = await dio.delete('/products/$id');
      return response.data['success'] == true;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal menghapus produk');
    }
  }

  // UPDATE
  Future<bool> updateProduct(int id, String name) async {
    try {
      final response = await dio.put('/products/$id', data: {
        'name': name,
      });
      return response.data['success'] == true;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal update produk');
    }
  }
}