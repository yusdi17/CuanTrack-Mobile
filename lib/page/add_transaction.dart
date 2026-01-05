import 'package:cuantrack/services/product_service.dart';
import 'package:cuantrack/services/sale_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  // --- Services ---
  final ProductService _productService = ProductService();
  final SaleService _saleService = SaleService();

  // --- Controllers ---
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _totalController = TextEditingController();
  final TextEditingController _adminFeeController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  // --- State Variables ---
  List<dynamic> _products = [];
  int? _selectedProductId; // Simpan ID Produk (bukan nama string)
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat(
      'dd MMMM yyyy',
      'id_ID',
    ).format(_selectedDate);
    _fetchProducts(); // Ambil list produk untuk dropdown
  }

  // Ambil Data Produk untuk Dropdown
  Future<void> _fetchProducts() async {
    try {
      final products = await _productService.getProducts();
      if (mounted) {
        setState(() {
          _products = products;
        });
      }
    } catch (e) {
      // Error silent atau tampilkan snackbar
    }
  }

  // Simpan Transaksi
  Future<void> _saveTransaction() async {
    // Validasi Sederhana
    if (_totalController.text.isEmpty) {
      _showError("Total bayar wajib diisi!");
      return;
    }
    if (_selectedProductId == null) {
      _showError("Pilih kategori/produk dulu!");
      return;
    }
    if (_adminFeeController.text.isEmpty) {
      _showError("Biaya admin wajib diisi (isi 0 jika tidak ada)");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Format Tanggal untuk API (YYYY-MM-DD)
      String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);

      double total = double.parse(_totalController.text);
      double fee = double.parse(_adminFeeController.text);

      bool success = await _saleService.createSale(
        productId: _selectedProductId!,
        date: formattedDate,
        totalAmount: total,
        fee: fee,
        note: _noteController.text.isEmpty ? null : _noteController.text,
      );

      if (success && mounted) {
        Navigator.pop(context, true); // Kembali & beri sinyal sukses
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Transaksi Berhasil Disimpan!"),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
      }
    } catch (e) {
      _showError("Gagal: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // Fungsi Helper Date Picker
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
              primary: Color(0xFF2E7D32),
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
        _dateController.text = DateFormat(
          'dd MMMM yyyy',
          'id_ID',
        ).format(picked);
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
          // HEADER HIJAU
          Container(
            height: 220,
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
                // NAVBAR
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                        ),
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
                          setState(() => _selectedProductId = null);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // FORM CARD
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
                          // INPUT NOMINAL BESAR
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF2E7D32),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF2E7D32,
                                  ).withOpacity(0.1),
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

                          // INPUT TANGGAL
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

                          // INPUT KATEGORI (DROPDOWN DARI API)
                          _buildLabel("Kategori / Produk"),
                          _products.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Center(
                                    child: Text(
                                      "Memuat produk...",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                )
                              : DropdownButtonFormField<int>(
                                  value: _selectedProductId,
                                  hint: const Text("Pilih Produk"),
                                  items: _products.map((dynamic item) {
                                    return DropdownMenuItem<int>(
                                      value: item['id'], // Kirim ID ke backend
                                      child: Text(item['name']),
                                    );
                                  }).toList(),
                                  onChanged: (int? newValue) {
                                    setState(
                                      () => _selectedProductId = newValue,
                                    );
                                  },
                                  decoration: _inputDecoration(
                                    hint: "Pilih Produk",
                                    icon: Icons.category_outlined,
                                  ),
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                  ),
                                ),

                          const SizedBox(height: 20),

                          // INPUT FEE
                          _buildLabel("Biaya Admin / Fee"),
                          TextFormField(
                            controller: _adminFeeController,
                            keyboardType: TextInputType.number,
                            decoration: _inputDecoration(
                              hint: "Rp 0",
                              icon: Icons.monetization_on_outlined,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // INPUT CATATAN
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

                          const SizedBox(height: 80),
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

      // TOMBOL SIMPAN
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          height: 55,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveTransaction,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 4,
              shadowColor: const Color(0xFF2E7D32).withOpacity(0.4),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
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
