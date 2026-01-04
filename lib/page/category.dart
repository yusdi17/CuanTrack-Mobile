import 'package:flutter/material.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  // --- Dummy Data Kategori ---
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Makanan & Minuman', 'type': 'Pengeluaran', 'icon': Icons.lunch_dining},
    {'name': 'Transportasi', 'type': 'Pengeluaran', 'icon': Icons.directions_car},
    {'name': 'Gaji & Tunjangan', 'type': 'Pemasukan', 'icon': Icons.attach_money},
    {'name': 'Belanja Bulanan', 'type': 'Pengeluaran', 'icon': Icons.shopping_cart},
    {'name': 'Investasi', 'type': 'Pengeluaran', 'icon': Icons.trending_up},
    {'name': 'Freelance', 'type': 'Pemasukan', 'icon': Icons.laptop_mac},
  ];

  // --- Fungsi Menampilkan Popup Tambah Kategori ---
  void _showAddCategoryDialog() {
    bool isExpense = true; // Default Pengeluaran
    TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          // StatefulBuilder agar Switch bisa berubah warna saat diklik di dalam Dialog
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text("Tambah Kategori", style: TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. Switch Pemasukan / Pengeluaran
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setStateDialog(() => isExpense = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isExpense ? Colors.redAccent : Colors.transparent,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Center(
                                child: Text(
                                  "Pengeluaran",
                                  style: TextStyle(
                                    color: isExpense ? Colors.white : Colors.grey[600],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setStateDialog(() => isExpense = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: !isExpense ? Colors.green : Colors.transparent,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Center(
                                child: Text(
                                  "Pemasukan",
                                  style: TextStyle(
                                    color: !isExpense ? Colors.white : Colors.grey[600],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 2. Input Nama Kategori
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: "Nama Kategori",
                      hintText: "Contoh: Jajan, Sewa, dll",
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
                    // Logika Simpan Dummy
                    if (nameController.text.isNotEmpty) {
                      setState(() {
                        _categories.add({
                          'name': nameController.text,
                          'type': isExpense ? 'Pengeluaran' : 'Pemasukan',
                          'icon': Icons.category, // Icon default
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          // --- BACKGROUND HEADER (Sama seperti Dashboard) ---
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
                // --- CUSTOM APP BAR ---
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Atur Kategori",
                        style: TextStyle(
                          fontSize: 24, 
                          fontWeight: FontWeight.bold, 
                          color: Colors.white
                        ),
                      ),
                      // Tombol Tambah di Pojok Kanan Atas
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2), // Glass effect
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

                // --- LIST KATEGORI (Floating List) ---
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
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        final bool isExpense = cat['type'] == 'Pengeluaran';
                        
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          // Ikon di kiri dengan Background Lingkaran
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isExpense ? Colors.red[50] : Colors.green[50],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              cat['icon'],
                              color: isExpense ? Colors.redAccent : Colors.green,
                              size: 24,
                            ),
                          ),
                          title: Text(
                            cat['name'],
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Text(
                            cat['type'],
                            style: TextStyle(
                              color: isExpense ? Colors.redAccent : Colors.green,
                              fontSize: 12,
                            ),
                          ),
                          // Tombol Edit & Hapus (Opsional)
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
                                onPressed: () {},
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20, color: Colors.grey),
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