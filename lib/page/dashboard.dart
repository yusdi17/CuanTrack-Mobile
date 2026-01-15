import 'package:cuantrack/page/all_transactions.dart';
import 'package:cuantrack/services/sale_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // --- State Data ---
  String _userName = "Bos Cuan";
  double _grossIncome = 0;
  double _netIncome = 0;
  bool _isLoading = true;

  // Data List Transaksi dari API
  List<dynamic> _monthlyTransactions = [];
  
  // Data Chart (Default 0 untuk Sen-Ming)
  List<FlSpot> _chartSpots = [
    const FlSpot(0, 0), const FlSpot(1, 0), const FlSpot(2, 0),
    const FlSpot(3, 0), const FlSpot(4, 0), const FlSpot(5, 0), const FlSpot(6, 0),
  ];
  double _maxChartValue = 100000; // Skala default Y-axis

  final SaleService _saleService = SaleService();

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedName = prefs.getString('user_name');

      // Panggil 2 API sekaligus
      final incomeData = await _saleService.getTodayIncome();
      final monthlyData = await _saleService.getMonthlySales();

      if (mounted) {
        setState(() {
          // 1. Update Header & Summary
          if (savedName != null) _userName = savedName;
          
          if (incomeData['success'] == true) {
            _grossIncome = double.parse(incomeData['data']['gross_income'].toString());
            _netIncome = double.parse(incomeData['data']['net_income'].toString());
          }

          // 2. Update Table & Chart
          if (monthlyData['success'] == true) {
            _monthlyTransactions = monthlyData['data']['transactions'];
            
            // Proses data untuk Chart
            _processChartData(_monthlyTransactions);
          }
          
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        print("Error loading dashboard: $e"); // Debugging
      }
    }
  }

  // --- LOGIKA MENGOLAH DATA CHART ---
  void _processChartData(List<dynamic> transactions) {
    // Array untuk menyimpan total per hari (0=Senin, ..., 6=Minggu)
    List<double> weeklyTotals = [0, 0, 0, 0, 0, 0, 0];
    
    DateTime now = DateTime.now();
    // Cari tanggal hari Senin minggu ini
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    startOfWeek = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day); // Reset jam ke 00:00

    DateTime endOfWeek = startOfWeek.add(const Duration(days: 7));

    double highestVal = 0;

    for (var trx in transactions) {
      DateTime trxDate = DateTime.parse(trx['date']);
      
      // Cek apakah transaksi terjadi di minggu ini?
      if (trxDate.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) && 
          trxDate.isBefore(endOfWeek)) {
        
        // Konversi: Senin=1 di Dart -> Senin=0 di array index
        int dayIndex = trxDate.weekday - 1; 
        double amount = double.parse(trx['total_amount'].toString());
        
        weeklyTotals[dayIndex] += amount;
      }
    }

    // Update Spots & Skala Chart
    List<FlSpot> newSpots = [];
    for (int i = 0; i < 7; i++) {
      if (weeklyTotals[i] > highestVal) highestVal = weeklyTotals[i];
      newSpots.add(FlSpot(i.toDouble(), weeklyTotals[i]));
    }

    // Set Max Y Axis sedikit di atas nilai tertinggi agar grafik cantik
    _maxChartValue = highestVal == 0 ? 100000 : highestVal * 1.2;
    _chartSpots = newSpots;
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0
    );

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          // Background Header
          Container(
            height: 280,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF4CAF50)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)
              ),
            ),
          ),

          SafeArea(
            child: RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Halo, $_userName! 👋", 
                              style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16)
                            ),
                            const SizedBox(height: 4),
                            const Text("Dashboard", 
                              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)
                            ),
                          ],
                        ),
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.white,
                          child: const Icon(Icons.person, color: Color(0xFF2E7D32)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Summary Cards
                    Row(
                      children: [
                        Expanded(child: _buildSummaryCard(
                          title: "Pendapatan Kotor",
                          amount: _isLoading ? "..." : currencyFormatter.format(_grossIncome),
                          icon: Icons.arrow_downward_rounded, color: Colors.blueAccent, textColor: Colors.blue[900]!
                        )),
                        const SizedBox(width: 16),
                        Expanded(child: _buildSummaryCard(
                          title: "Pendapatan Bersih",
                          amount: _isLoading ? "..." : currencyFormatter.format(_netIncome),
                          icon: Icons.wallet, color: const Color(0xFF2E7D32), textColor: Colors.green[900]!
                        )),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // --- CHART SECTION (REAL DATA) ---
                    const Text("Statistik Minggu Ini", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Container(
                      height: 240,
                      padding: const EdgeInsets.fromLTRB(10, 20, 20, 10),
                      decoration: BoxDecoration(
                        color: Colors.white, borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))],
                      ),
                      child: _isLoading 
                        ? const Center(child: CircularProgressIndicator()) 
                        : LineChart(_mainData()),
                    ),
                    const SizedBox(height: 30),

                    // --- TABLE TRANSAKSI (REAL DATA) ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Transaksi Terbaru", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const AllTransactionsPage()));
                          },
                          child: const Text("Lihat Semua"),
                        ),
                      ],
                    ),
                    
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: _isLoading 
                        ? const Padding(
                            padding: EdgeInsets.all(20),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columnSpacing: 20,
                            headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
                            // 1. Definisikan 5 Kolom (Termasuk Catatan)
                            columns: const [
                              DataColumn(label: Text('Tanggal', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Kategori', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Total Bayar', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Admin(Fee)', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Catatan', style: TextStyle(fontWeight: FontWeight.bold))), // <--- TAMBAHAN
                            ],
                            // 2. Mapping Data Rows
                            rows: _monthlyTransactions.take(5).map((data) {
                              return DataRow(
                                cells: [
                                  // Cell 1: Tanggal
                                  DataCell(Text(DateFormat('dd/MM').format(DateTime.parse(data['date'])))),
                                  
                                  // Cell 2: Produk
                                  DataCell(
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.blue[50], borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        data['product'] ?? '-', 
                                        style: TextStyle(color: Colors.blue[800], fontSize: 12, fontWeight: FontWeight.w600),
                                      ),
                                    )
                                  ),
                                  
                                  // Cell 3: Total Amount
                                  DataCell(Text(
                                    currencyFormatter.format(double.parse(data['total_amount'])), 
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  )),
                                  
                                  // Cell 4: Fee
                                  DataCell(Text(
                                    currencyFormatter.format(double.parse(data['fee'])), 
                                    style: const TextStyle(color: Colors.green),
                                  )),

                                  // Cell 5: Catatan (Handle Null)
                                  DataCell(
                                    SizedBox(
                                      width: 150, // Batasi lebar agar tidak merusak layout
                                      child: Text(
                                        data['note'] ?? '-', // Jika null tampilkan '-'
                                        style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                                        overflow: TextOverflow.ellipsis, // Potong jika kepanjangan
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({required String title, required String amount, required IconData icon, required Color color, required Color textColor}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(amount, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
        ],
      ),
    );
  }

  // --- CONFIG CHART ---
  LineChartData _mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true, drawVerticalLine: false,
        getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey[100], strokeWidth: 1),
      ),
      titlesData: FlTitlesData(
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true, reservedSize: 22, interval: 1,
            getTitlesWidget: (value, meta) {
              const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
              if (value.toInt() >= 0 && value.toInt() < days.length) {
                return Text(days[value.toInt()], style: TextStyle(color: Colors.grey[400], fontSize: 11));
              }
              return const Text('');
            },
          ),
        ),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      minX: 0, maxX: 6, 
      minY: 0, maxY: _maxChartValue, // Skala Y Dinamis
      lineBarsData: [
        LineChartBarData(
          spots: _chartSpots, // DATA DINAMIS DARI API
          isCurved: true,
          gradient: const LinearGradient(colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)]),
          barWidth: 4, isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [const Color(0xFF4CAF50).withOpacity(0.3), const Color(0xFF4CAF50).withOpacity(0.0)],
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }
}