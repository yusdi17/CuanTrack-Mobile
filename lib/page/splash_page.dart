import 'dart:async';
import 'package:cuantrack/layout/main_layout.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cuantrack/Auth/login.dart';
import 'package:cuantrack/page/dashboard.dart';

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

    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    Widget nextPage = token != null ? const MainLayout() : const LoginPage();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
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

          // BAGIAN BAWAH: TEKS VERSI
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  Text(
                    "Developed by Yusdi", 
                    style: TextStyle(
                      color:
                          Colors.grey[700],
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
