import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AllTransactionsPage extends StatefulWidget {
  const AllTransactionsPage({super.key});

  @override
  State<AllTransactionsPage> createState() => _AllTransactionsPageState();
}

class _AllTransactionsPageState extends State<AllTransactionsPage> {
  // --- Dummy Data (Sangat Banyak) ---
  final List<Map<String, dynamic>> _transactions = [
    {
      'date': DateTime.now(),
      'category': 'Jasa Service',
      'total': 150000,
      'admin': 5000,
      'note': 'Service Laptop Asus',
      'type': 'Masuk'
    },
    {
      'date': DateTime.now().subtract(const Duration(hours: 5)),
      'category': 'Makan Siang',
      'total': 25000,
      'admin': 0,
      'note': 'Ayam Bakar Pak Ndut',
      'type': 'Keluar'
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'category': 'Produk Digital',
      'total': 50000,
      'admin': 2000,
      'note': 'Token Listrik 50rb',
      'type': 'Masuk'
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'category': 'Makanan',
      'total': 35000,
      'admin': 0,
      'note': 'Nasi Padang',
      'type': 'Keluar'
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'category': 'Transport',
      'total': 15000,
      'admin': 0,
      'note': 'Ojek ke Stasiun',
      'type': 'Keluar'
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 4)),
      'category': 'E-Commerce',
      'total': 1200000,
      'admin': 10000,
      'note': 'Pencairan Shopee',
      'type': 'Masuk'
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'category': 'Belanja',
      'total': 250000,
      'admin': 0,
      'note': 'Superindo Bulanan',
      'type': 'Keluar'
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 6)),
      'category': 'Tagihan',
      'total': 350000,
      'admin': 2500,
      'note': 'WiFi IndiHome',
      'type': 'Keluar'
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 7)),
      'category': 'Jasa Service',
      'total': 75000,
      'admin': 0,
      'note': 'Install Ulang Windows',
      'type': 'Masuk'
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 8)),
      'category': 'Hiburan',
      'total': 50000,
      'admin': 0,
      'note': 'Nonton Bioskop',
      'type': 'Keluar'
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 9)),
      'category': 'Lainnya',
      'total': 100000,
      'admin': 6500,
      'note': 'Transfer ke Ortu',
      'type': 'Keluar'
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 10)),
      'category': 'Produk Digital',
      'total': 150000,
      'admin': 0,
      'note': 'Topup E-Wallet',
      'type': 'Keluar'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final monthFormatter = DateFormat('MMMM yyyy', 'id_ID');

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Column(
          children: [
            const Text(
              "Semua Transaksi",
              style: TextStyle(
                color: Colors.black87, 
                fontWeight: FontWeight.bold, 
                fontSize: 18
              ),
            ),
            Text(
              monthFormatter.format(DateTime.now()), 
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // --- BODY UTAMA ---
      body: SingleChildScrollView(
        // Scroll Vertikal (Ke Bawah)
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            // Scroll Horizontal (Ke Samping jika layar HP sempit)
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 20,
              headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
              columns: const [
                DataColumn(label: Text('Tanggal', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Kategori', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Admin', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Catatan', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: _transactions.map((data) {
                final isIncome = data['type'] == 'Masuk';
                
                return DataRow(cells: [
                  // 1. Tanggal
                  DataCell(
                    Text(DateFormat('dd/MM/yy').format(data['date'])),
                  ),
                  
                  // 2. Kategori (Ada background warna)
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isIncome ? Colors.green[50] : Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        data['category'],
                        style: TextStyle(
                          color: isIncome ? Colors.green[800] : Colors.red[800],
                          fontSize: 12, 
                          fontWeight: FontWeight.w600
                        ),
                      ),
                    )
                  ),
                  
                  // 3. Total (Warna Hijau/Merah)
                  DataCell(
                    Text(
                      currencyFormatter.format(data['total']),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isIncome ? const Color(0xFF2E7D32) : Colors.black87,
                      ),
                    )
                  ),
                  
                  // 4. Admin
                  DataCell(
                    Text(
                      data['admin'] > 0 ? currencyFormatter.format(data['admin']) : '-',
                      style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                    )
                  ),
                  
                  // 5. Catatan
                  DataCell(
                    Text(
                      data['note'],
                      style: const TextStyle(color: Colors.grey),
                    )
                  ),
                ]);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}