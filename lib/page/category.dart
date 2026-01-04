import 'package:flutter/material.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  // --- Dummy Data Kategori (Tanpa Tipe) ---
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Makanan & Minuman', 'icon': Icons.lunch_dining},
    {'name': 'Transportasi', 'icon': Icons.directions_car},
    {'name': 'Gaji & Tunjangan', 'icon': Icons.attach_money},
    {'name': 'Belanja Bulanan', 'icon': Icons.shopping_cart},
    {'name': 'Investasi', 'icon': Icons.trending_up},
    {'name': 'Freelance', 'icon': Icons.laptop_mac},
    {'name': 'Hiburan', 'icon': Icons.movie},
    {'name': 'Tagihan', 'icon': Icons.receipt_long},
  ];

  // --- Fungsi Menampilkan Popup Tambah Kategori (Simpel) ---
  void _showAddCategoryDialog() {
    TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Tambah Kategori", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Input Nama Kategori Saja
              TextField(
                controller: nameController,
                autofocus: true, // Langsung fokus keyboard muncul
                decoration: InputDecoration(
                  labelText: "Nama Kategori",
                  hintText: "Contoh: Pulsa",
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
                  setState(() {
                    _categories.add({
                      'name': nameController.text,
                      'icon': Icons.category, // Icon default untuk kategori baru
                    });
                  });
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Simpan", style: TextStyle(color: Colors.white)),
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
                // --- HEADER APP BAR ---
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Daftar Kategori",
                        style: TextStyle(
                          fontSize: 24, 
                          fontWeight: FontWeight.bold, 
                          color: Colors.white
                        ),
                      ),
                      // Tombol Tambah
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: _showAddCategoryDialog,
                          icon: const Icon(Icons.add, color: Colors.white),
                          tooltip: "Tambah Kategori",
                        ),
                      ),
                    ],
                  ),
                ),

                // --- LIST KATEGORI ---
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
                    child: ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: _categories.length,
                      separatorBuilder: (context, index) => const Divider(height: 1, indent: 60),
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          // Ikon Seragam (Warna Hijau Branding)
                          leading: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E7D32).withOpacity(0.1), // Hijau pudar
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              cat['icon'],
                              color: const Color(0xFF2E7D32), // Hijau pekat
                              size: 24,
                            ),
                          ),
                          title: Text(
                            cat['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w600, 
                              fontSize: 16,
                              color: Colors.black87
                            ),
                          ),
                          // Tombol Aksi
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.delete_outline, size: 20, color: Colors.grey[400]),
                                onPressed: () {
                                  setState(() {
                                    _categories.removeAt(index);
                                  });
                                },
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