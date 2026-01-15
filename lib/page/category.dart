import 'package:cuantrack/services/product_service.dart'; // Import Service
import 'package:flutter/material.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  // --- State Variables ---
  bool _isLoading = true;
  List<dynamic> _products = [];
  
  // Panggil Service
  final ProductService _productService = ProductService();

  @override
  void initState() {
    super.initState();
    _fetchProducts(); // Ambil data saat halaman dibuka
  }

  // --- FUNGSI API ---
  
  // 1. Ambil Data
  Future<void> _fetchProducts() async {
    try {
      final data = await _productService.getProducts();
      if (mounted) {
        setState(() {
          _products = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  // 2. Tambah / Edit Data
  Future<void> _saveProduct(String name, {int? id}) async {
    try {
      bool success;
      if (id == null) {
        // Mode Tambah
        success = await _productService.createProduct(name);
      } else {
        // Mode Edit
        success = await _productService.updateProduct(id, name);
      }

      if (success && mounted) {
        Navigator.pop(context); // Tutup Dialog
        _fetchProducts(); // Refresh List
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(id == null ? "Produk Berhasil Ditambah" : "Produk Berhasil Diupdate"), 
            backgroundColor: const Color(0xFF2E7D32)
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red),
      );
    }
  }

  // 3. Hapus Data
  Future<void> _deleteProduct(int id) async {
    try {
      // Tampilkan Konfirmasi Dulu
      bool confirm = await showDialog(
        context: context, 
        builder: (ctx) => AlertDialog(
          title: const Text("Hapus Produk?"),
          content: const Text("Data yang dihapus tidak bisa dikembalikan."),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Batal")),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Hapus", style: TextStyle(color: Colors.red))),
          ],
        )
      ) ?? false;

      if (!confirm) return;

      final success = await _productService.deleteProduct(id);
      if (success && mounted) {
        _fetchProducts(); // Refresh List
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Produk Berhasil Dihapus"), backgroundColor: Color(0xFF2E7D32)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menghapus: $e"), backgroundColor: Colors.red),
      );
    }
  }

  // --- UI DIALOG (Popup Form) ---
  void _showProductDialog({Map<String, dynamic>? product}) {
    final isEdit = product != null;
    final TextEditingController nameController = TextEditingController(
      text: isEdit ? product['name'] : ''
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(isEdit ? "Edit Produk" : "Tambah Produk", style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: "Nama Produk",
                  hintText: "Contoh: Token Listrik",
                  prefixIcon: const Icon(Icons.label_outline, color: Color(0xFF2E7D32)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  _saveProduct(nameController.text, id: isEdit ? product['id'] : null);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(isEdit ? "Update" : "Simpan", style: const TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF4CAF50)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // --- HEADER APP BAR ---
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Daftar Kategori", // Ubah judul jadi Produk
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: () => _showProductDialog(),
                          icon: const Icon(Icons.add, color: Colors.white),
                          tooltip: "Tambah Produk",
                        ),
                      ),
                    ],
                  ),
                ),

                // --- LIST DATA ---
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24), topRight: Radius.circular(24),
                      ),
                    ),
                    child: _isLoading 
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
                      : _products.isEmpty
                          ? const Center(child: Text("Belum ada produk"))
                          : ListView.separated(
                              padding: const EdgeInsets.all(20),
                              itemCount: _products.length,
                              separatorBuilder: (context, index) => const Divider(height: 1, indent: 60),
                              itemBuilder: (context, index) {
                                final product = _products[index];
                                
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                  leading: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2E7D32).withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.inventory_2_outlined, color: Color(0xFF2E7D32), size: 24),
                                  ),
                                  title: Text(
                                    product['name'], // Nama dari API
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black87),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Tombol Edit
                                      IconButton(
                                        icon: Icon(Icons.edit, size: 20, color: Colors.blue[300]),
                                        onPressed: () => _showProductDialog(product: product),
                                      ),
                                      // Tombol Hapus
                                      IconButton(
                                        icon: Icon(Icons.delete_outline, size: 20, color: Colors.grey[400]),
                                        onPressed: () => _deleteProduct(product['id']),
                                      ),
                                    ],
                                  ),
                                );
                              },
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