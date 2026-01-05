import 'package:cuantrack/Auth/forgotPassword.dart'; // Sesuaikan path
import 'package:cuantrack/Auth/register.dart';       // Sesuaikan path
import 'package:cuantrack/layout/main_layout.dart';  // Sesuaikan path
import 'package:cuantrack/services/auth_service.dart'; // <--- Import Service
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  // Gunakan nama controller yang lebih umum
  final TextEditingController _identityController = TextEditingController(); 
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  // Panggil Service
  final AuthService _authService = AuthService();

  // --- FUNGSI LOGIN UTAMA ---
  Future<void> _handleLogin() async {
    // 1. Validasi Form UI
    if (!_formKey.currentState!.validate()) return;

    // 2. Tutup Keyboard
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      // 3. Panggil API Lewat Service
      // Controller dikirim sebagai 'identity' (bisa email atau username)
      bool success = await _authService.login(
        _identityController.text, 
        _passwordController.text
      );

      if (success) {
        if (!mounted) return;
        
        // 4. Sukses: Tampilkan Pesan & Pindah Halaman
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login Berhasil! Selamat Datang.'),
            backgroundColor: Color(0xFF2E7D32), // Hijau CuanTrack
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainLayout()),
        );
      }
    } catch (e) {
      // 5. Gagal: Tampilkan Error dari Backend
      if (!mounted) return;
      
      // Bersihkan pesan error (hapus kata "Exception:")
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isGoogleLoading = true);
    await Future.delayed(const Duration(seconds: 2)); // Simulasi
    if (mounted) {
      setState(() => _isGoogleLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fitur Google Login Segera Hadir!')),
      );
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
      backgroundColor: Colors.white,
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
                  // --- LOGO ---
                  const Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 80,
                    color: Colors.blueAccent, // Bisa diganti Color(0xFF2E7D32) biar senada
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Selamat Datang',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Masuk untuk mengelola keuangan Anda',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 40),

                  // --- INPUT EMAIL / USERNAME ---
                  TextFormField(
                    controller: _identityController,
                    keyboardType: TextInputType.emailAddress, // Tetap emailAddress agar keyboard ada '@'
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Email / Username', // Label diubah
                      prefixIcon: const Icon(Icons.person_outline), // Icon diganti lebih umum
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email atau Username tidak boleh kosong';
                      }
                      // HAPUS validasi '@' agar username bisa masuk
                      return null; 
                    },
                  ),
                  const SizedBox(height: 20),

                  // --- INPUT PASSWORD ---
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
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
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password tidak boleh kosong';
                      }
                      return null;
                    },
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
                      child: const Text('Lupa Password?'),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- TOMBOL LOGIN ---
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent, // Sesuaikan warna tema
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
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

                  const SizedBox(height: 24),
                  
                  // --- DIVIDER ATAU ---
                  // Row(
                  //   children: [
                  //     Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
                  //     Padding(
                  //       padding: const EdgeInsets.symmetric(horizontal: 16),
                  //       child: Text(
                  //         'ATAU',
                  //         style: TextStyle(
                  //           color: Colors.grey[500],
                  //           fontSize: 12,
                  //           fontWeight: FontWeight.bold,
                  //         ),
                  //       ),
                  //     ),
                  //     Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
                  //   ],
                  // ),

                  const SizedBox(height: 24),

                  // --- GOOGLE LOGIN (UI Saja) ---
                  // SizedBox(
                  //   height: 50,
                  //   child: OutlinedButton(
                  //     onPressed: _isGoogleLoading ? null : _handleGoogleLogin,
                  //     style: OutlinedButton.styleFrom(
                  //       side: BorderSide(color: Colors.grey[300]!),
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(12),
                  //       ),
                  //       backgroundColor: Colors.white,
                  //     ),
                  //     child: _isGoogleLoading
                  //         ? const SizedBox(
                  //             height: 20,
                  //             width: 20,
                  //             child: CircularProgressIndicator(
                  //               color: Colors.blueAccent,
                  //               strokeWidth: 2,
                  //             ),
                  //           )
                  //         : Row(
                  //             mainAxisAlignment: MainAxisAlignment.center,
                  //             children: [
                  //               // Placeholder Icon Google
                  //               const Icon(Icons.g_mobiledata, size: 32, color: Colors.red), 
                  //               const SizedBox(width: 8),
                  //               const Text(
                  //                 'Masuk dengan Google',
                  //                 style: TextStyle(
                  //                   fontSize: 16,
                  //                   fontWeight: FontWeight.bold,
                  //                   color: Colors.black87,
                  //                 ),
                  //               ),
                  //             ],
                  //           ),
                  //   ),
                  // ),

                  const SizedBox(height: 30),

                  // --- DAFTAR SEKARANG ---
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     Text(
                  //       'Belum punya akun? ',
                  //       style: TextStyle(color: Colors.grey[700]),
                  //     ),
                  //     GestureDetector(
                  //       onTap: () {
                  //         Navigator.push(
                  //           context,
                  //           MaterialPageRoute(
                  //             builder: (context) => const RegisterPage(),
                  //           ),
                  //         );
                  //       },
                  //       child: const Text(
                  //         'Daftar Sekarang',
                  //         style: TextStyle(
                  //           color: Colors.blueAccent,
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