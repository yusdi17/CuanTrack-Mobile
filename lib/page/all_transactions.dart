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
                    child: DataTable(
                      columnSpacing: 20,
                      headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
                      columns: const [
                        DataColumn(label: Text('Tanggal', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Kategori', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Fee', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Catatan', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: _transactions.map((data) {
                        // Parsing Data
                        DateTime date = DateTime.parse(data['date']);
                        double total = double.parse(data['total_amount'].toString());
                        double fee = double.parse(data['fee'].toString());
                        String category = data['product'] ?? '-'; // Menggunakan nama produk sebagai kategori
                        
                        // Karena API ini SalesController, diasumsikan semua adalah Pemasukan (Income)
                        // Jika nanti ada ExpenseController, bisa tambah logika cek tipe.
                        bool isIncome = true; 

                        return DataRow(cells: [
                          // 1. Tanggal
                          DataCell(Text(DateFormat('dd/MM/yy').format(date))),
                          
                          // 2. Kategori / Produk
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isIncome ? Colors.green[50] : Colors.red[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                category,
                                style: TextStyle(
                                  color: isIncome ? Colors.green[800] : Colors.red[800],
                                  fontSize: 12, 
                                  fontWeight: FontWeight.w600
                                ),
                              ),
                            )
                          ),
                          
                          // 3. Total (Pendapatan Kotor)
                          DataCell(Text(
                            currencyFormatter.format(total),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2E7D32), // Hijau Uang
                            ),
                          )),
                          
                          // 4. Fee (Pendapatan Bersih)
                          DataCell(Text(
                            currencyFormatter.format(fee),
                            style: const TextStyle(color: Colors.black87),
                          )),
                          
                          // 5. Catatan
                          DataCell(
                            SizedBox(
                              width: 150,
                              child: Text(
                                data['note'] ?? '-',
                                style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                                overflow: TextOverflow.ellipsis,
                              ),
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