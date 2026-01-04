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
    // Gunakan format Indonesia jika sudah setup locale, atau default Inggris
    _dateController.text = DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate);
  }

  // Fungsi Helper untuk menampilkan Date Picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
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
        _dateController.text = DateFormat('dd MMMM yyyy', 'id_ID').format(picked);
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
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          // --- BACKGROUND HEADER (Hijau Gradasi) ---
          Container(
            height: 220, // Tinggi header
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1B5E20),
                  Color(0xFF2E7D32),
                  Color(0xFF4CAF50),
                ],
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
                // --- CUSTOM HEADER (Back & Title) ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        "Catat Penjualan",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        onPressed: () {
                          _totalController.clear();
                          _adminFeeController.clear();
                          _noteController.clear();
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // --- FORM CONTAINER (Kartu Putih) ---
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- SECTION 1: TOTAL BAYAR ---
                          const Text(
                            "Total Masuk",
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
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF2E7D32),
                                width: 1.5,
                              ),
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
                                fontSize: 28,
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

                          const SizedBox(height: 30),

                          // --- SECTION 2: INPUT FORM ---
                          
                          // 1. INPUT TANGGAL
                          _buildLabel("Tanggal Transaksi"),
                          TextFormField(
                            controller: _dateController,
                            readOnly: true,
                            onTap: () => _selectDate(context),
                            decoration: _inputDecoration(
                              hint: "Pilih Tanggal",
                              icon: Icons.calendar_today_outlined,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // 2. INPUT KATEGORI
                          _buildLabel("Kategori"),
                          DropdownButtonFormField<String>(
                            value: _selectedCategory,
                            hint: const Text("Pilih Kategori"),
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
                            decoration: _inputDecoration(
                              hint: "Pilih Kategori",
                              icon: Icons.category_outlined,
                            ),
                            icon: const Icon(Icons.keyboard_arrow_down_rounded),
                          ),
                          const SizedBox(height: 20),

                          // 3. INPUT BIAYA ADMIN
                          _buildLabel("Biaya Admin"),
                          TextFormField(
                            controller: _adminFeeController,
                            keyboardType: TextInputType.number,
                            decoration: _inputDecoration(
                              hint: "Rp 0",
                              icon: Icons.monetization_on_outlined,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // 4. INPUT CATATAN
                          _buildLabel("Catatan (Opsional)"),
                          TextFormField(
                            controller: _noteController,
                            maxLines: 3,
                            decoration: _inputDecoration(
                              hint: "Contoh: Belum bayar",
                              icon: Icons.edit_note_rounded,
                              isMultiLine: true,
                            ),
                          ),
                          
                          const SizedBox(height: 80), // Spasi bawah agar tidak tertutup tombol
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // --- TOMBOL SIMPAN ---
      bottomNavigationBar: Container(
        color: Colors.white, // Background putih di area tombol
        padding: const EdgeInsets.all(20),
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

              // Simulasi Simpan
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Transaksi Berhasil Disimpan!"),
                  backgroundColor: Color(0xFF2E7D32),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 4,
              shadowColor: const Color(0xFF2E7D32).withOpacity(0.4),
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

  // --- WIDGET HELPER ---
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

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
      fillColor: Colors.grey[50],
      contentPadding: isMultiLine
          ? const EdgeInsets.symmetric(vertical: 16, horizontal: 16)
          : const EdgeInsets.symmetric(horizontal: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 1.5),
      ),
    );
  }
}