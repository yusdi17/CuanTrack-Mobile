import 'package:cuantrack/services/product_service.dart';
import 'package:cuantrack/services/sale_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddTransactionPage extends StatefulWidget {
  // Parameter opsional: Jika diisi, berarti mode EDIT
  final Map<String, dynamic>? transactionToEdit; 

  const AddTransactionPage({super.key, this.transactionToEdit});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final ProductService _productService = ProductService();
  final SaleService _saleService = SaleService();

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _totalController = TextEditingController();
  final TextEditingController _adminFeeController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  List<dynamic> _products = [];
  int? _selectedProductId;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  bool _isEditMode = false; // Penanda mode

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    
    // Cek apakah ini mode Edit?
    if (widget.transactionToEdit != null) {
      _isEditMode = true;
      _initEditData();
    } else {
      _dateController.text = DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate);
    }
  }

  // Isi form dengan data lama jika mode edit
  void _initEditData() {
    final data = widget.transactionToEdit!;
    
    // 1. Set Tanggal
    _selectedDate = DateTime.parse(data['date']);
    _dateController.text = DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate);

    // 2. Set Nominal (Parse ke string integer biar rapi)
    double total = double.parse(data['total_amount'].toString());
    double fee = double.parse(data['fee'].toString());
    
    _totalController.text = total.toInt().toString(); 
    _adminFeeController.text = fee.toInt().toString();
    
    // 3. Set Catatan
    _noteController.text = data['note'] ?? '';

    // 4. Set Produk ID (Akan otomatis terpilih di dropdown jika data produk sudah load)
    if (data['product_id'] != null) {
      _selectedProductId = int.parse(data['product_id'].toString());
    }
  }

  Future<void> _fetchProducts() async {
    try {
      final products = await _productService.getProducts();
      if (mounted) setState(() => _products = products);
    } catch (_) {}
  }

  Future<void> _saveTransaction() async {
    if (_totalController.text.isEmpty) return _showError("Total bayar wajib diisi!");
    if (_selectedProductId == null) return _showError("Pilih kategori/produk dulu!");
    if (_adminFeeController.text.isEmpty) return _showError("Biaya admin wajib diisi");

    setState(() => _isLoading = true);

    try {
      String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
      double total = double.parse(_totalController.text);
      double fee = double.parse(_adminFeeController.text);
      String? note = _noteController.text.isEmpty ? null : _noteController.text;

      bool success;
      
      if (_isEditMode) {
        // Panggil API Update
        success = await _saleService.updateSale(
          id: widget.transactionToEdit!['id'], // Ambil ID transaksi
          productId: _selectedProductId!,
          date: formattedDate,
          totalAmount: total,
          fee: fee,
          note: note,
        );
      } else {
        // Panggil API Create
        success = await _saleService.createSale(
          productId: _selectedProductId!,
          date: formattedDate,
          totalAmount: total,
          fee: fee,
          note: note,
        );
      }

      if (success && mounted) {
        Navigator.pop(context, true); // Kembali dengan sukses
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditMode ? "Data Berhasil Diupdate!" : "Transaksi Berhasil Disimpan!"),
            backgroundColor: const Color(0xFF2E7D32)
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: Color(0xFF2E7D32))),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd MMMM yyyy', 'id_ID').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          Container(
            height: 220,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF4CAF50)],
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white), onPressed: () => Navigator.pop(context)),
                      Text(_isEditMode ? "Edit Penjualan" : "Catat Penjualan", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(width: 40), // Placeholder biar tengah
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Total Masuk", style: TextStyle(fontSize: 14, color: Colors.grey)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50], borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFF2E7D32), width: 1.5),
                            ),
                            child: TextFormField(
                              controller: _totalController, keyboardType: TextInputType.number,
                              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                              decoration: const InputDecoration(icon: Text("Rp", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)), border: InputBorder.none, hintText: "0"),
                            ),
                          ),
                          const SizedBox(height: 30),
                          _buildLabel("Tanggal"),
                          TextFormField(
                            controller: _dateController, readOnly: true, onTap: () => _selectDate(context),
                            decoration: _inputDecoration(Icons.calendar_today),
                          ),
                          const SizedBox(height: 20),
                          _buildLabel("Produk"),
                          DropdownButtonFormField<int>(
                            value: _selectedProductId,
                            hint: const Text("Pilih Produk"),
                            items: _products.map((dynamic item) => DropdownMenuItem<int>(value: item['id'], child: Text(item['name']))).toList(),
                            onChanged: (val) => setState(() => _selectedProductId = val),
                            decoration: _inputDecoration(Icons.category_outlined),
                          ),
                          const SizedBox(height: 20),
                          _buildLabel("Fee / Keuntungan"),
                          TextFormField(controller: _adminFeeController, keyboardType: TextInputType.number, decoration: _inputDecoration(Icons.monetization_on_outlined)),
                          const SizedBox(height: 20),
                          _buildLabel("Catatan"),
                          TextFormField(controller: _noteController, maxLines: 3, decoration: _inputDecoration(Icons.edit_note)),
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
      bottomNavigationBar: Container(
        color: Colors.white, padding: const EdgeInsets.all(20),
        child: SizedBox(
          height: 55,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveTransaction,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: _isLoading 
              ? const CircularProgressIndicator(color: Colors.white) 
              : Text(_isEditMode ? "Update Transaksi" : "Simpan Transaksi", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 8, left: 4), child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)));
  
  InputDecoration _inputDecoration(IconData icon) => InputDecoration(
    prefixIcon: Icon(icon, color: Colors.grey[600]), filled: true, fillColor: Colors.grey[50],
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 1.5)),
  );
}