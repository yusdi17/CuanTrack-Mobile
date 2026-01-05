import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/dio.dart';

class AuthService {
  Future<bool> login(String identity, String password) async {
    try {
      final response = await dio.post(
        '/login',
        data: {'identity': identity, 'password': password},
      );

      final respData = response.data; 
      if (respData['token'] != null) {
        final token = respData['token'];
        final user = respData['data']; 

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        if (user != null && user['name'] != null) {
          await prefs.setString('user_name', user['name']);
        }

        return true;
      }

      return false;
    } on DioException catch (e) {
      throw Exception('Login Gagal');
    }
  }

  // LOGOUT
  Future<void> logout() async {
    try {
      await dio.post('/logout');
    } catch (e) {
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_name');
    }
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('auth_token');
  }
}
