import 'package:cuantrack/services/sale_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  // --- State Variables ---
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;
  
  List<dynamic> _transactions = [];
  double _totalProfit = 0; // Ubah nama variabel biar jelas (Total Keuntungan)

  final SaleService _saleService = SaleService();

  @override
  void initState() {
    super.initState();
    _fetchReport();
  }

  // Fungsi Ambil Data API
  Future<void> _fetchReport() async {
    setState(() => _isLoading = true);
    try {
      final response = await _saleService.getMonthlySales(
        month: _selectedDate.month,
        year: _selectedDate.year,
      );

      if (mounted) {
        setState(() {
          if (response['success'] == true) {
            _transactions = response['data']['transactions'];

            // --- REVISI: HITUNG TOTAL DARI FEE SAJA ---
            // Kita hitung manual di sini agar akurat sesuai data yang tampil
            _totalProfit = _transactions.fold(0.0, (sum, item) {
              return sum + double.parse(item['fee'].toString());
            });
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _changeMonth(int offset) {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + offset);
    });
    _fetchReport();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final monthFormatter = DateFormat('MMMM yyyy', 'id_ID');

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          // --- BACKGROUND HEADER ---
          Container(
            height: 200,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                // Gunakan warna hijau yang lebih "fresh" untuk melambangkan profit
                colors: [Color(0xFF1B5E20), Color(0xFF43A047), Color(0xFF66BB6A)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),

                // --- HEADER: FILTER BULAN ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => _changeMonth(-1),
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                      ),
                      Column(
                        children: [
                          Text(
                            "Laporan Keuntungan (Fee)", // Ubah Judul
                            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            monthFormatter.format(_selectedDate),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => _changeMonth(1),
                        icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 10),

                // --- TOTAL PROFIT (Big Text) ---
                _isLoading 
                  ? const SizedBox(
                      height: 40, 
                      width: 40, 
                      child: CircularProgressIndicator(color: Colors.white)
                    )
                  : Text(
                      currencyFormatter.format(_totalProfit), // Tampilkan Total Fee
                      style: const TextStyle(
                        color: Colors.white, 
                        fontSize: 28, 
                        fontWeight: FontWeight.bold
                      ),
                    ),

                const SizedBox(height: 20),

                // --- TABEL TRANSAKSI ---
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Header Tabel
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(24),
                              topRight: Radius.circular(24),
                            ),
                            border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                          ),
                          child: const Row(
                            children: [
                              Expanded(flex: 2, child: Text('Tanggal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
                              Expanded(flex: 3, child: Text('Kategori', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
                              Expanded(flex: 3, child: Text('Keuntungan', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
                            ],
                          ),
                        ),

                        // Isi Tabel
                        Expanded(
                          child: _isLoading 
                            ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
                            : _transactions.isEmpty
                                ? Center(child: Text("Tidak ada data bulan ini", style: TextStyle(color: Colors.grey[400])))
                                : ListView.separated(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    itemCount: _transactions.length,
                                    separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
                                    itemBuilder: (context, index) {
                                      final data = _transactions[index];
                                      
                                      // Parsing Data
                                      DateTime date = DateTime.parse(data['date']);
                                      // --- REVISI: AMBIL DARI KOLOM FEE ---
                                      double profit = double.parse(data['fee'].toString()); 
                                      String category = data['product'] ?? '-';

                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                        child: Row(
                                          children: [
                                            // Kolom 1: Tanggal
                                            Expanded(
                                              flex: 2,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    DateFormat('dd MMM').format(date),
                                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                                  ),
                                                  Text(
                                                    DateFormat('yyyy').format(date),
                                                    style: TextStyle(color: Colors.grey[400], fontSize: 10),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // Kolom 2: Kategori
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                category,
                                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),

                                            // Kolom 3: Keuntungan (Fee)
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                currencyFormatter.format(profit),
                                                textAlign: TextAlign.right,
                                                style: const TextStyle(
                                                  color: Color(0xFF2E7D32), // Hijau
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}