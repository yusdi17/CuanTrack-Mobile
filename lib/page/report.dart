import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  // --- State Tanggal (Filter Bulan) ---
  DateTime _selectedDate = DateTime.now();

  // --- Dummy Data Pendapatan ---
  // Fokus ke 'total' (Pendapatan Kotor)
  final List<Map<String, dynamic>> _transactions = [
    {
      'date': DateTime.now(),
      'category': 'Jasa Service',
      'amount': 150000,
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'category': 'Produk Digital',
      'amount': 50000,
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'category': 'E-Commerce',
      'amount': 1200000,
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'category': 'Jasa Service',
      'amount': 75000,
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'category': 'Produk Fisik',
      'amount': 350000,
    },
  ];

  // Fungsi Ganti Bulan
  void _changeMonth(int offset) {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + offset);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Formatter
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final monthFormatter = DateFormat('MMMM yyyy', 'id_ID');

    // Hitung Total Pendapatan Bulan Ini (Opsional, buat pemanis di header)
    double totalRevenue = _transactions.fold(0, (sum, item) => sum + (item['amount'] as int));

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          // --- BACKGROUND HEADER (Hijau Gradasi) ---
          Container(
            height: 200,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF4CAF50)],
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
                            "Laporan Pendapatan",
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

                // --- TOTAL PENDAPATAN (Big Text) ---
                Text(
                  currencyFormatter.format(totalRevenue),
                  style: const TextStyle(
                    color: Colors.white, 
                    fontSize: 28, 
                    fontWeight: FontWeight.bold
                  ),
                ),

                const SizedBox(height: 20),

                // --- TABEL TRANSAKSI (White Container) ---
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
                        // 1. Header Tabel (3 Kolom: Tanggal, Kategori, Pendapatan)
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
                              Expanded(
                                flex: 2, 
                                child: Text('Tanggal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))
                              ),
                              Expanded(
                                flex: 3, 
                                child: Text('Kategori', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))
                              ),
                              Expanded(
                                flex: 3, 
                                child: Text('Pendapatan', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))
                              ),
                            ],
                          ),
                        ),

                        // 2. Isi Tabel (List)
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            itemCount: _transactions.length,
                            separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
                            itemBuilder: (context, index) {
                              final data = _transactions[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                child: Row(
                                  children: [
                                    // Kolom 1: Tanggal (23 Jan)
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            DateFormat('dd MMM').format(data['date']),
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                          ),
                                          Text(
                                            DateFormat('yyyy').format(data['date']), // Tahun kecil
                                            style: TextStyle(color: Colors.grey[400], fontSize: 10),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Kolom 2: Kategori
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        data['category'],
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),

                                    // Kolom 3: Pendapatan (Hijau Tebal)
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        currencyFormatter.format(data['amount']),
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(
                                          color: Color(0xFF2E7D32), // Hijau Uang
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