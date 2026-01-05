import 'dart:math'; // Untuk warna random
import 'package:cuantrack/Auth/login.dart';
import 'package:cuantrack/services/auth_service.dart';
import 'package:cuantrack/services/sale_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // --- Services ---
  final AuthService _authService = AuthService();
  final SaleService _saleService = SaleService();

  // --- State Variables ---
  String _userName = "Loading...";
  String _userEmail = "Loading...";
  DateTime _selectedDate = DateTime.now();
  
  // Data Statistik
  List<Map<String, dynamic>> _categoryStats = [];
  double _totalExpense = 0; // Total (Disini konteksnya Total Penjualan/Pemasukan)
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _fetchStats();
  }

  // Info User
  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? "Bos Cuan";
      _userEmail = prefs.getString('user_email') ?? "user@cuantrack.com"; 
    });
  }

  // Load 
  Future<void> _fetchStats() async {
    setState(() => _isLoadingStats = true);
    try {
      final response = await _saleService.getMonthlySales(
        month: _selectedDate.month,
        year: _selectedDate.year,
      );

      if (mounted && response['success'] == true) {
        List<dynamic> transactions = response['data']['transactions'];
        Map<String, double> groupedData = {};
        double grandTotal = 0;

        for (var item in transactions) {
          String category = item['product'] ?? 'Lainnya';
          double amount = double.parse(item['total_amount'].toString());
          
          if (groupedData.containsKey(category)) {
            groupedData[category] = groupedData[category]! + amount;
          } else {
            groupedData[category] = amount;
          }
          grandTotal += amount;
        }

        // Konversi Map ke List Chart
        List<Map<String, dynamic>> finalStats = [];
        List<Color> colors = [Colors.orange, Colors.blue, Colors.purple, Colors.pink, Colors.teal, Colors.redAccent];
        int colorIndex = 0;

        groupedData.forEach((key, value) {
          finalStats.add({
            'category': key,
            'amount': value,
            'color': colors[colorIndex % colors.length],
          });
          colorIndex++;
        });

        // Sort dari yang terbesar
        finalStats.sort((a, b) => (b['amount'] as double).compareTo(a['amount'] as double));

        setState(() {
          _categoryStats = finalStats;
          _totalExpense = grandTotal;
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingStats = false);
    }
  }

  // 3. Fungsi Logout
  Future<void> _handleLogout() async {
    // Tampilkan Dialog Konfirmasi
    bool confirm = await showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Logout"),
        content: const Text("Apakah Anda yakin ingin keluar dari aplikasi?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Keluar", style: TextStyle(color: Colors.red))),
        ],
      )
    ) ?? false;

    if (confirm) {
      await _authService.logout(); // Hapus token
      if (!mounted) return;
      
      // Kembali ke Halaman Login (Hapus semua history route)
      Navigator.pushAndRemoveUntil(
        context, 
        MaterialPageRoute(builder: (context) => const LoginPage()), 
        (route) => false
      );
    }
  }

  void _changeMonth(int offset) {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + offset);
    });
    _fetchStats();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          // BACKGROUND HEADER
          Container(
            height: 320, 
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF4CAF50)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  const Center(
                    child: Text("Profile Saya", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 20),
                  
                  // --- 1. PROFILE INFO ---
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.grey[200],
                          child: const Icon(Icons.person, size: 40, color: Color(0xFF2E7D32)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_userName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 4),
                          Text(_userEmail, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9))),
                        ],
                      ),
                      const Spacer(),
                      // Tombol Edit (Dummy)
                      Container(
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                        child: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                          onPressed: () {
                             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fitur Edit Profile Segera Hadir!")));
                          },
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 30),

                  // --- 2. STATISTIK CARD ---
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))],
                    ),
                    child: Column(
                      children: [
                        // Header Filter Bulan
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Statistik Penjualan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(20)),
                              child: Row(
                                children: [
                                  InkWell(onTap: () => _changeMonth(-1), child: const Icon(Icons.chevron_left, size: 20, color: Colors.grey)),
                                  const SizedBox(width: 4),
                                  Text(DateFormat('MMM yyyy', 'id_ID').format(_selectedDate), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 4),
                                  InkWell(onTap: () => _changeMonth(1), child: const Icon(Icons.chevron_right, size: 20, color: Colors.grey)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),

                        // KONTEN CHART
                        _isLoadingStats 
                          ? const SizedBox(height: 200, child: Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32))))
                          : _categoryStats.isEmpty 
                              ? const SizedBox(height: 100, child: Center(child: Text("Belum ada data")))
                              : Column(
                                  children: [
                                    // PIE CHART
                                    SizedBox(
                                      height: 200,
                                      child: PieChart(
                                        PieChartData(
                                          sectionsSpace: 2, centerSpaceRadius: 40,
                                          sections: _categoryStats.map((data) {
                                            final double val = data['amount'];
                                            return PieChartSectionData(
                                              color: data['color'], value: val,
                                              title: '${(val / _totalExpense * 100).toStringAsFixed(0)}%',
                                              radius: 50,
                                              titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                              showTitle: true,
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    
                                    // LEGEND
                                    Column(
                                      children: _categoryStats.map((data) {
                                        double percent = (data['amount'] / _totalExpense * 100);
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 6),
                                          child: Row(
                                            children: [
                                              Container(width: 12, height: 12, decoration: BoxDecoration(color: data['color'], shape: BoxShape.circle)),
                                              const SizedBox(width: 12),
                                              Expanded(child: Text(data['category'], style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14))),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Text(currencyFormatter.format(data['amount']), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                                  Text("${percent.toStringAsFixed(1)}%", style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                                                ],
                                              )
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // --- 3. MENU OPSI ---
                  Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        _buildMenuOption(Icons.settings_outlined, "Pengaturan Aplikasi", false, () {}),
                        const Divider(height: 1, indent: 20, endIndent: 20),
                        _buildMenuOption(Icons.help_outline, "Bantuan & Dukungan", false, () {}),
                        const Divider(height: 1, indent: 20, endIndent: 20),
                        _buildMenuOption(Icons.logout, "Keluar", true, _handleLogout), // <--- LOGOUT FUNCTION
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuOption(IconData icon, String title, bool isDanger, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: isDanger ? Colors.red[50] : Colors.grey[100], shape: BoxShape.circle),
        child: Icon(icon, color: isDanger ? Colors.red : Colors.grey[700], size: 20),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500, color: isDanger ? Colors.red : Colors.black87)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}