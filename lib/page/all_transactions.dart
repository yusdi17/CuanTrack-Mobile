import 'package:cuantrack/page/add_transaction.dart';
import 'package:cuantrack/services/sale_service.dart'; // Pastikan path import benar
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AllTransactionsPage extends StatefulWidget {
  const AllTransactionsPage({super.key});

  @override
  State<AllTransactionsPage> createState() => _AllTransactionsPageState();
}

class _AllTransactionsPageState extends State<AllTransactionsPage> {
  // --- State Data Real ---
  bool _isLoading = true;
  List<dynamic> _transactions = [];
  
  // Panggil Service
  final SaleService _saleService = SaleService();

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  // Fungsi Ambil Data dari API
  Future<void> _fetchTransactions() async {
    try {
      // Kita gunakan endpoint bulanan. 
      // Jika nanti Anda buat endpoint khusus "Get All History", tinggal ganti fungsi ini.
      final response = await _saleService.getMonthlySales();

      if (mounted) {
        setState(() {
          if (response['success'] == true) {
            _transactions = response['data']['transactions'];
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal memuat data: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Fungsi Konfirmasi Hapus
  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Transaksi?"),
        content: const Text("Data yang dihapus tidak dapat dikembalikan."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx); // Tutup dialog
              setState(() => _isLoading = true);
              
              try {
                final success = await _saleService.deleteSale(id);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Transaksi berhasil dihapus"), backgroundColor: Color(0xFF2E7D32))
                  );
                  _fetchTransactions(); // Refresh data
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red)
                );
                setState(() => _isLoading = false);
              }
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Formatter
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final monthFormatter = DateFormat('MMMM yyyy', 'id_ID');

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Column(
          children: [
            const Text(
              "Semua Transaksi",
              style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              // Menampilkan Bulan Ini (Karena pakai API Monthly)
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
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
        : _transactions.isEmpty
            ? _buildEmptyState() // Tampilan jika tidak ada data
            : SingleChildScrollView(
                scrollDirection: Axis.vertical,
                padding: const EdgeInsets.all(20),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    // ... kode sebelumnya ...
                    child: DataTable(
                      columnSpacing: 20,
                      headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
                      columns: const [
                        DataColumn(label: Text('Tanggal', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Kategori', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Total Bayar', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Admin(Fee)', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Catatan', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Aksi', style: TextStyle(fontWeight: FontWeight.bold))), // <--- KOLOM BARU
                      ],
                      rows: _transactions.map((data) {
                        // ... parsing variable (date, total, fee, dll) sama seperti sebelumnya ...
                        DateTime date = DateTime.parse(data['date']);
                        double total = double.parse(data['total_amount'].toString());
                        double fee = double.parse(data['fee'].toString());
                        String category = data['product'] ?? '-';

                        return DataRow(cells: [
                          DataCell(Text(DateFormat('dd/MM/yy').format(date))),
                          DataCell(Text(category)),
                          DataCell(Text(currencyFormatter.format(total), style: const TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold))),
                          DataCell(Text(currencyFormatter.format(fee))),
                          DataCell(SizedBox(width: 100, child: Text(data['note'] ?? '-', overflow: TextOverflow.ellipsis))),
                          
                          // --- KOLOM AKSI (Edit & Hapus) ---
                          DataCell(Row(
                            children: [
                              // TOMBOL EDIT
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                                onPressed: () async {
                                  // Navigasi ke Halaman Form dengan membawa data transaksi
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddTransactionPage(transactionToEdit: data), // Kirim data
                                    ),
                                  );
                                  // Jika sukses update, refresh list
                                  if (result == true) {
                                    _fetchTransactions();
                                  }
                                },
                              ),
                              // TOMBOL HAPUS
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                onPressed: () {
                                  _confirmDelete(data['id']);
                                },
                              ),
                            ],
                          )),
                        ]);
                      }).toList(),
                    ),
                    // ... kode setelahnya ...
                  ),
                ),
              ),
    );
  }

  // Widget Tampilan Kosong (Opsional, pemanis UI)
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "Belum ada transaksi bulan ini",
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
        ],
      ),
    );
  }
}