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

  Future<Map<String, String>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('user_name') ?? 'Pengguna',
      'email':
          prefs.getString('user_email') ??
          'user@cuantrack.com',
    };
  }

  // LOGOUT
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token != null) {
        await dio.post('/logout',
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          ),
        );
      }
    } catch (e) {
      print("Logout API error: $e");
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_name');
      await prefs.remove('user_email');
    }
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('auth_token');
  }
}
