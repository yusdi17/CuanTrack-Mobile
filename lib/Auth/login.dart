import 'package:cuantrack/Auth/forgotPassword.dart';
import 'package:cuantrack/Auth/register.dart';
import 'package:cuantrack/layout/main_layout.dart';
import 'package:cuantrack/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:cuantrack/services/biometric_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _identityController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final AuthService _authService = AuthService();

  // WARNA TEMA (Hijau CuanTrack)
  final Color _primaryColor = const Color(0xFF2E7D32);

  final BiometricService _biometricService = BiometricService();

  Future<void> _handleBiometricLogin() async {
    bool isAvailable = await _biometricService.isBiometricAvailable();

    if (!isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('HP ini tidak support Biometric / Belum disetting'),
        ),
      );
      return;
    }
    bool isAuthenticated = await _biometricService.authenticate();

    if (isAuthenticated) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainLayout()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login Biometric Berhasil!')),
      );
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);

    try {
      bool success = await _authService.login(
        _identityController.text,
        _passwordController.text,
      );

      if (success) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Login Berhasil!'),
            backgroundColor: _primaryColor, // Hijau
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainLayout()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _identityController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Latar bersih
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- LOGO (Gunakan Asset agar selaras dengan Splash) ---
                  Center(
                    child: Image.asset(
                      'assets/splash.png', // Pastikan nama file sesuai (logo.png/splash.png)
                      width: 150,
                      height: 150,
                    ),
                  ),
                  Text(
                    'Kelola keuanganmu dengan bijak',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 40),

                  // --- INPUT EMAIL / USERNAME ---
                  TextFormField(
                    controller: _identityController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    cursorColor: _primaryColor,
                    decoration: InputDecoration(
                      labelText: 'Email / Username',
                      labelStyle: TextStyle(color: Colors.grey[700]),
                      prefixIcon: Icon(
                        Icons.person_outline,
                        color: _primaryColor,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      // Saat diklik warnanya hijau
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: _primaryColor, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email atau Username wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // --- INPUT PASSWORD ---
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    textInputAction: TextInputAction.done,
                    cursorColor: _primaryColor,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.grey[700]),
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: _primaryColor,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: _primaryColor, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Password wajib diisi' : null,
                  ),

                  // --- LUPA PASSWORD ---
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordPage(),
                          ),
                        );
                      },
                      child: Text(
                        'Lupa Password?',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ), // Warna netral
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  // --- TOMBOL LOGIN ---
                  Row(
                    children: [
                      // 1. TOMBOL MASUK (Gunakan Expanded agar memenuhi ruang)
                      Expanded(
                        child: SizedBox(
                          height: 50, // Tinggi disamakan
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(
                                0xFF2E7D32,
                              ), // Hijau CuanTrack
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                              shadowColor: const Color(
                                0xFF2E7D32,
                              ).withOpacity(0.4),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Masuk',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 16), // Jarak antar tombol
                      // 2. TOMBOL FINGERPRINT (Kotak di samping)
                      Container(
                        height: 50, // Tinggi disamakan dengan tombol Masuk
                        width: 50, // Lebar disamakan agar jadi kotak
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            12,
                          ), // Radius sama
                          border: Border.all(
                            color: const Color(0xFF2E7D32), // Border Hijau
                            width: 2,
                          ),
                        ),
                        child: IconButton(
                          padding: EdgeInsets
                              .zero, // Hilangkan padding bawaan agar pas
                          icon: const Icon(
                            Icons.fingerprint,
                            size:
                                30, // Ukuran icon diperkecil sedikit agar muat di kotak
                            color: Color(0xFF2E7D32),
                          ),
                          onPressed: _handleBiometricLogin,
                          tooltip: "Login dengan Sidik Jari",
                        ),
                      ),
                    ],
                  ),

                  // const SizedBox(height: 30),

                  // --- DAFTAR SEKARANG (Diaktifkan & Dirapikan) ---
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     Text(
                  //       'Belum punya akun? ',
                  //       style: TextStyle(color: Colors.grey[600]),
                  //     ),
                  //     GestureDetector(
                  //       onTap: () {
                  //         Navigator.push(
                  //           context,
                  //           MaterialPageRoute(builder: (context) => const RegisterPage()),
                  //         );
                  //       },
                  //       child: Text(
                  //         'Daftar Sekarang',
                  //         style: TextStyle(
                  //           color: _primaryColor, // Hijau
                  //           fontWeight: FontWeight.bold,
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
