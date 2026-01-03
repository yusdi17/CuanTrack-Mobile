import 'package:cuantrack/page/add_transaction.dart';
import 'package:flutter/material.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentPageIndex = 0;

  // Daftar halaman (Urutan index 0, 1, 2, 3)
  // Perhatikan: Transaksi tidak masuk sini karena dia tombol aksi (FAB)
  final List<Widget> _screens = [
    const Center(child: Text('Halaman Dashboard (Home)')), // Index 0
    const Center(child: Text('Halaman Kategori')), // Index 1
    const Center(child: Text('Halaman Laporan')), // Index 2
    const Center(child: Text('Halaman Profile')), // Index 3
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      // Body sesuai index yang dipilih
      body: _screens[_currentPageIndex],

      // --- TOMBOL TENGAH (FAB) SEPERTI DI GAMBAR ---
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // print("Buka halaman tambah transaksi"); <--- Hapus ini

          // Ganti dengan Navigasi ini:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTransactionPage()),
          );
        },
        backgroundColor: const Color(
          0xFF2E7D32,
        ), // Warna Hijau Tua (Sesuai gambar)
        shape: const CircleBorder(), // Pastikan bulat sempurna
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),

      // Lokasi tombol di tengah dan "menempel" (docked)
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // --- BOTTOM NAVIGATION BAR CUSTOM ---
      bottomNavigationBar: BottomAppBar(
        shape:
            const CircularNotchedRectangle(), // Ini yang bikin LENGKUNGAN (Notch)
        notchMargin: 8.0, // Jarak antara tombol tengah dengan lengkungan putih
        color: Colors.white,
        elevation: 10,
        height: 70, // Tinggi bar
        padding: EdgeInsets.zero, // Hilangkan padding bawaan

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Kiri 1: Home
            _buildNavItem(
              index: 0,
              icon: Icons.dashboard_outlined,
              activeIcon: Icons.dashboard,
              label: 'Home',
            ),

            // Kiri 2: Kategori
            _buildNavItem(
              index: 1,
              icon: Icons.category_outlined,
              activeIcon: Icons.category,
              label: 'Kategori',
            ),

            // SPASI KOSONG UNTUK TOMBOL TENGAH (PENTING!)
            const SizedBox(width: 40),

            // Kanan 1: Laporan (Index di list screens adalah 2)
            _buildNavItem(
              index: 2,
              icon: Icons.pie_chart_outline,
              activeIcon: Icons.pie_chart,
              label: 'Laporan',
            ),

            // Kanan 2: Profile (Index di list screens adalah 3)
            _buildNavItem(
              index: 3,
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  // Widget helper untuk membuat item navigasi agar kodenya rapi
  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final bool isSelected = _currentPageIndex == index;

    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(50), // Efek riak air bulat
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ikon
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? const Color(0xFF2E7D32) : Colors.grey[400],
              size: 26,
            ),

            // Indikator Titik (Dot) seperti di gambar referensi
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 4, bottom: 4),
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: Color(0xFF2E7D32), // Warna hijau
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(height: 9), // Placeholder biar tinggi tetap sama
          ],
        ),
      ),
    );
  }
}
