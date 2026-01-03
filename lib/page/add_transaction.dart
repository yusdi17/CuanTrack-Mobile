import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  // --- Controllers ---
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _totalController = TextEditingController();
  final TextEditingController _adminFeeController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  // --- State Variables ---
  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();

  // --- Dummy Data Kategori ---
  final List<String> _categories = [
    'Makanan & Minuman',
    'Produk Digital',
    'Jasa Service',
    'E-Commerce',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('dd MMMM yyyy').format(_selectedDate);
  }

  // Fungsi Helper untuk menampilkan Date Picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        // Kustomisasi tema DatePicker agar sesuai warna aplikasi
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2E7D32), // Warna Hijau
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd MMMM yyyy').format(picked);
      });
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _totalController.dispose();
    _adminFeeController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Catat Penjualan",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black54),
            onPressed: () {
              _totalController.clear();
              _adminFeeController.clear();
              _noteController.clear();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Total Bayar",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF2E7D32),
                  width: 1.5,
                ), // Border Hijau
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2E7D32).withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextFormField(
                controller: _totalController,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
                decoration: const InputDecoration(
                  icon: Text(
                    "Rp",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  border: InputBorder.none,
                  hintText: "0",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // --- SECTION 2: DETAIL TRANSAKSI ---
            Container(
              padding: const EdgeInsets.all(20),
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
              child: Column(
                children: [
                  // 1. INPUT TANGGAL
                  _buildLabel("Tanggal Transaksi"),
                  TextFormField(
                    controller: _dateController,
                    readOnly: true, // Tidak bisa diketik manual
                    onTap: () => _selectDate(context),
                    decoration: _inputDecoration(
                      hint: "Pilih Tanggal",
                      icon: Icons.calendar_today_outlined,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. INPUT KATEGORI (DROPDOWN)
                  _buildLabel("Kategori"),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    hint: const Text("Pilih Kategori"), // Hint milik Dropdown
                    items: _categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    },

                    // --- BAGIAN INI YANG HARUS DIPERBAIKI ---
                    decoration: _inputDecoration(
                      hint: "Pilih Kategori", // <--- TAMBAHKAN BARIS INI
                      icon: Icons.category_outlined,
                    ),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  ),
                  const SizedBox(height: 16),

                  // 3. INPUT BIAYA ADMIN
                  _buildLabel("Biaya Admin (Opsional)"),
                  TextFormField(
                    controller: _adminFeeController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(
                      hint: "Rp 0",
                      icon: Icons.monetization_on_outlined,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 4. INPUT CATATAN
                  _buildLabel("Catatan"),
                  TextFormField(
                    controller: _noteController,
                    maxLines: 3,
                    decoration: _inputDecoration(
                      hint: "Contoh: Pembayaran invoice #001",
                      icon: Icons.edit_note_rounded,
                      isMultiLine: true,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // --- TOMBOL SIMPAN (Sticky di Bawah) ---
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.black12)),
        ),
        child: SizedBox(
          height: 55,
          child: ElevatedButton(
            onPressed: () {
              // Validasi Sederhana
              if (_totalController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Total bayar wajib diisi!"),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              if (_selectedCategory == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Pilih kategori dulu!"),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // TODO: Simpan ke Database
              Navigator.pop(context); // Tutup halaman
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Data Penjualan Tersimpan!"),
                  backgroundColor: Color(0xFF2E7D32),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32), // Warna Hijau Branding
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: const Text(
              "Simpan Transaksi",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPER AGAR KODE RAPI ---

  // Widget untuk Label di atas input
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  // Style Input Field yang Konsisten
  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    bool isMultiLine = false,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.grey[600], size: 22),
      filled: true,
      fillColor: Colors.grey[50], // Background input sedikit abu
      contentPadding: isMultiLine
          ? const EdgeInsets.symmetric(vertical: 16, horizontal: 16)
          : const EdgeInsets.symmetric(horizontal: 16),

      // Border saat tidak aktif
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),

      // Border saat diklik (Focus)
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 1.5),
      ),

      // Border saat error
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }
}
