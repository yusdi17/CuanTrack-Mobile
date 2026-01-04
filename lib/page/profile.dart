import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  DateTime _selectedDate = DateTime.now();

  // --- Dummy Data Statistik Kategori ---
  final List<Map<String, dynamic>> _categoryStats = [
    {'category': 'Makanan', 'amount': 1500000, 'color': Colors.orange},
    {'category': 'Transport', 'amount': 600000, 'color': Colors.blue},
    {'category': 'Belanja', 'amount': 1200000, 'color': Colors.purple},
    {'category': 'Hiburan', 'amount': 450000, 'color': Colors.pink},
    {'category': 'Lainnya', 'amount': 250000, 'color': Colors.grey},
  ];

  void _changeMonth(int offset) {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + offset);
    });
  }

  @override
  Widget build(BuildContext context) {
    final monthFormatter = DateFormat('MMMM yyyy', 'id_ID');
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    
    // Hitung total untuk persentase chart
    double totalExpense = _categoryStats.fold(0, (sum, item) => sum + (item['amount'] as int));

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          // --- BACKGROUND HEADER (Hijau Gradasi) ---
          Container(
            height: 320, 
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF4CAF50)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  // --- 1. PROFILE INFO ---
                  const Center(
                    child: Text(
                      "Profile Saya",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // REVISI: Menggunakan Icon Profile, bukan Foto
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        // Ganti CircleAvatar gambar dengan Icon
                        child: CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.grey[200], // Background abu muda
                          child: const Icon(
                            Icons.person, 
                            size: 40, 
                            color: Color(0xFF2E7D32), // Warna Hijau Branding
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Bos Cuan",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "boscuan@gmail.com",
                            style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9)),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Tombol Edit Kecil
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                          onPressed: () {},
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 30),

                  // --- 2. STATISTIK CARD (Chart Section) ---
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5)),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Header Filter Bulan di dalam Card
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Statistik Pengeluaran",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: () => _changeMonth(-1),
                                    child: const Icon(Icons.chevron_left, size: 20, color: Colors.grey),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateFormat('MMM yyyy', 'id_ID').format(_selectedDate),
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 4),
                                  InkWell(
                                    onTap: () => _changeMonth(1),
                                    child: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),

                        // PIE CHART
                        SizedBox(
                          height: 200,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                              sections: _categoryStats.map((data) {
                                final isTouched = false; 
                                final double radius = isTouched ? 60 : 50;
                                
                                return PieChartSectionData(
                                  color: data['color'],
                                  value: (data['amount'] as int).toDouble(),
                                  title: '${((data['amount'] as int) / totalExpense * 100).toStringAsFixed(0)}%',
                                  radius: radius,
                                  titleStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  showTitle: false, 
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // LEGEND / KETERANGAN
                        Column(
                          children: _categoryStats.map((data) {
                            double percent = ((data['amount'] as int) / totalExpense * 100);
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  // Indikator Warna
                                  Container(
                                    width: 12, height: 12,
                                    decoration: BoxDecoration(color: data['color'], shape: BoxShape.circle),
                                  ),
                                  const SizedBox(width: 12),
                                  
                                  // Nama Kategori
                                  Expanded(
                                    child: Text(
                                      data['category'],
                                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                                    ),
                                  ),

                                  // Nominal & Persen
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        currencyFormatter.format(data['amount']),
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                      Text(
                                        "${percent.toStringAsFixed(1)}%",
                                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // --- 3. MENU OPSI (Settings, Logout) ---
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _buildMenuOption(Icons.settings_outlined, "Pengaturan Aplikasi", false),
                        const Divider(height: 1, indent: 20, endIndent: 20),
                        _buildMenuOption(Icons.help_outline, "Bantuan & Dukungan", false),
                        const Divider(height: 1, indent: 20, endIndent: 20),
                        _buildMenuOption(Icons.logout, "Keluar", true),
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

  // Widget Helper untuk Menu
  Widget _buildMenuOption(IconData icon, String title, bool isDanger) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDanger ? Colors.red[50] : Colors.grey[100],
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: isDanger ? Colors.red : Colors.grey[700], size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isDanger ? Colors.red : Colors.black87,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {
        // Aksi logout atau pindah halaman
      },
    );
  }
}