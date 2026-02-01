import 'package:cuantrack/page/add_transaction.dart';
import 'package:cuantrack/services/sale_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AllTransactionsPage extends StatefulWidget {
  const AllTransactionsPage({super.key});

  @override
  State<AllTransactionsPage> createState() => _AllTransactionsPageState();
}

class _AllTransactionsPageState extends State<AllTransactionsPage> {
  // --- State Data ---
  bool _isLoading = true;
  List<dynamic> _transactions = [];
  
  // State Filter Waktu (Default: Hari ini)
  DateTime _selectedDate = DateTime.now();

  // Panggil Service
  final SaleService _saleService = SaleService();

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  // Fungsi Ambil Data dengan Filter
  Future<void> _fetchTransactions() async {
    setState(() => _isLoading = true); // Set loading setiap kali fetch ulang

    try {
      // Kirim parameter bulan dan tahun yang dipilih
      final response = await _saleService.getMonthlySales(
        month: _selectedDate.month,
        year: _selectedDate.year,
      );

      if (mounted) {
        setState(() {
          if (response['success'] == true) {
            _transactions = response['data']['transactions'];
          } else {
            _transactions = [];
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

  // Fungsi Ganti Bulan (Next/Prev)
  void _changeMonth(int offset) {
    setState(() {
      _selectedDate = DateTime(
        _selectedDate.year,
        _selectedDate.month + offset,
        1, // Set ke tanggal 1 agar aman
      );
    });
    _fetchTransactions(); // Ambil data baru
  }

  // Fungsi Pilih Bulan via DatePicker
  Future<void> _pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF2E7D32)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
      _fetchTransactions();
    }
  }

  // Fungsi Konfirmasi Hapus (Sama seperti sebelumnya)
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
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              
              try {
                final success = await _saleService.deleteSale(id);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Transaksi berhasil dihapus"), backgroundColor: Color(0xFF2E7D32))
                  );
                  _fetchTransactions();
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
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final monthFormatter = DateFormat('MMMM yyyy', 'id_ID');

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Semua Transaksi",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      
      // Gunakan Column agar Filter tetap di atas dan tabel yang scroll
      body: Column(
        children: [
          // --- WIDGET FILTER BULAN ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Tombol Mundur
                IconButton(
                  onPressed: () => _changeMonth(-1),
                  icon: const Icon(Icons.chevron_left, color: Colors.grey),
                  tooltip: "Bulan Sebelumnya",
                ),
                
                // Teks Bulan & Tahun (Bisa diklik)
                InkWell(
                  onTap: _pickMonth,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: Color(0xFF2E7D32)),
                        const SizedBox(width: 8),
                        Text(
                          monthFormatter.format(_selectedDate),
                          style: const TextStyle(
                            fontSize: 16, 
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Tombol Maju
                IconButton(
                  onPressed: () => _changeMonth(1),
                  icon: const Icon(Icons.chevron_right, color: Colors.grey),
                  tooltip: "Bulan Selanjutnya",
                ),
              ],
            ),
          ),
          
          const Divider(height: 1, color: Colors.black12),

          // --- CONTENT (TABEL / LOADING / KOSONG) ---
          Expanded(
            child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
              : _transactions.isEmpty
                  ? _buildEmptyState()
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
                              DataColumn(label: Text('Total Bayar', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Admin(Fee)', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Catatan', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Aksi', style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            rows: _transactions.map((data) {
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
                                DataCell(Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                                      onPressed: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => AddTransactionPage(transactionToEdit: data),
                                          ),
                                        );
                                        if (result == true) {
                                          _fetchTransactions();
                                        }
                                      },
                                    ),
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
                        ),
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_view_month_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "Tidak ada transaksi pada bulan ini",
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
                // Reset ke bulan sekarang
                setState(() => _selectedDate = DateTime.now());
                _fetchTransactions();
            },
            child: const Text("Kembali ke Bulan Ini"),
          )
        ],
      ),
    );
  }
}