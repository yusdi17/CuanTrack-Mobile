import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:cuantrack/layout/main_layout.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cuantrack/Auth/login.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  String _version = '';
  final String _apiUrl = 'https://ccuantrack.web.id/api/config'; 

  @override
  void initState() {
    super.initState();
    _checkServerAndStart();
  }

  Future<void> _checkServerAndStart() async {
    try {
      final info = await PackageInfo.fromPlatform();
      setState(() {
        _version = info.version;
      });
    } catch (e) {
      debugPrint("Gagal ambil versi: $e");
    }

    //HEALTH CHECK SERVER
    try {
      final response = await http.get(Uri.parse(_apiUrl)).timeout(
        const Duration(seconds: 8), 
        onTimeout: () {
          throw TimeoutException("Koneksi timeout");
        },
      );

      if (response.statusCode == 200) {
        // --- SERVER HIDUP ---
        final data = jsonDecode(response.body);
        bool isMaintenance = data['is_maintenance'] ?? false;
        String msg = data['message'] ?? "Sistem sedang maintenance.";

        await Future.delayed(const Duration(seconds: 2));
        if (!mounted) return;

        if (isMaintenance) {
          _showMaintenanceDialog(msg);
        } else {
          _checkLoginStatus();
        }

      } else {
        if (!mounted) return;
        _showErrorDialog("Terjadi kesalahan pada server (Code: ${response.statusCode}).");
      }

    } catch (e) {
      if (!mounted) return;
      String errorMsg = "Tidak dapat terhubung ke server.";
      
      if (e is TimeoutException) {
        errorMsg = "Coba beberapa saat lagi";
      } else if (e is SocketException) {
        errorMsg = "Terjadi kesalahan server. Coba beberapa saat lagi.";
      }

      _showErrorDialog(errorMsg);
    }
  }

  void _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    Widget nextPage = token != null ? const MainLayout() : const LoginPage();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextPage),
    );
  }

  // DIALOG ERROR & TUTUP APLIKASI
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red),
              SizedBox(width: 10),
              Text("Gagal Terhubung"),
            ],
          ),
          content: Text("$message\n\nAplikasi akan ditutup."),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                SystemNavigator.pop(); 
              },
              child: const Text("OK, Tutup", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // MAINTENANCE PAGE
  void _showMaintenanceDialog(String msg) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MaintenancePage(message: msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(child: Image.asset('assets/logo.png', width: 250, height: 250)),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Text("Versi $_version", style: TextStyle(color: Colors.grey[500])),
            ),
          ),
        ],
      ),
    );
  }
}

class MaintenancePage extends StatelessWidget {
  final String message;
  const MaintenancePage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.warning_amber_rounded, size: 80, color: Colors.orange),
                const SizedBox(height: 20),
                const Text("Under Maintenance", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(message, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}