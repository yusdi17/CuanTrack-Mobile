import 'dart:async';
import 'dart:convert';
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

  @override
  void initState() {
    super.initState();
    _startApp();
  }

  Future<void> _startApp() async {
    try {
      final info = await PackageInfo.fromPlatform();
      setState(() {
        _version = info.version;
      });
    } catch (e) {
      debugPrint("Gagal ambil versi: $e");
    }

    bool isMaintenance = false;
    String maintenanceMsg = "Aplikasi sedang dalam perbaikan sistem.";

    try {
      final response = await http.get(Uri.parse('https://cuantrack.web.id/api/config'))
          .timeout(const Duration(seconds: 5)); 
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        isMaintenance = data['is_maintenance'] ?? false;
        maintenanceMsg = data['message'] ?? maintenanceMsg;
      }
    } catch (e) {
      debugPrint("Gagal cek maintenance (mungkin offline): $e");
      isMaintenance = false; 
    }

    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    if (isMaintenance) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MaintenancePage(message: maintenanceMsg),
        ),
      );
    } else {
      // JIKA NORMAL: Cek Token Login
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      Widget nextPage = token != null ? const MainLayout() : const LoginPage();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => nextPage),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // BAGIAN TENGAH: LOGO
          Center(
            child: Image.asset('assets/logo.png', width: 250, height: 250),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Developed by Yusdi",
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Versi $_version",
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//  HALAMAN MAINTENANCE ---
class MaintenancePage extends StatelessWidget {
  final String message;

  const MaintenancePage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    // PopScope (atau WillPopScope) mencegah tombol back berfungsi
    return PopScope(
      canPop: false, 
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.engineering_rounded, size: 80, color: Colors.orange[800]),
                const SizedBox(height: 20),
                const Text(
                  "Under Maintenance",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}