// =========================================================================
// [SIMULASI MODUL 5: HALAMAN UTAMA PRODUK]
// PERBEDAAN DARI TEMPLATE-01:
// - Judul menu: kategori produk e-commerce (All Products, Beauty, Fragrances)
// - Endpoint menggunakan daftar resep DummyJSON.
//
// CARA ADAPTASI:
// 1. Ganti title dan subtitle tiap menu.
// 2. Ganti string endpoint — perhatikan format DummyJSON: 'recipes/tag/nama'
// =========================================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'list_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  final String username;
  const HomeScreen({super.key, required this.username});

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLogin', false);
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (r) => false,
      );
    }
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: const Color(0xFFFBFBFE),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFECEEFE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF4C6EF5), size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: Text(
          'Hai, $username!',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF4C6EF5),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    // [RESPONSI]: Menu 1 - Ganti title, subtitle, dan endpoint
                    _buildMenuCard(
                      context: context,
                      icon: Icons.local_pizza_outlined,
                      title: 'Classic Margherita Pizza', // <-- Ganti nama menu
                      subtitle: 'Italian Rate 4,6', // <-- Ganti deskripsi
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ListScreen(
                            Title: 'Classic Margherita Pizza',
                            endpoint: 'recipes/tag/Pizza',
                          ),
                        ),
                      ),
                    ),

                    // [RESPONSI]: Menu 2 - Ganti title, subtitle, dan endpoint
                    _buildMenuCard(
                      context: context,
                      icon: Icons.spa_outlined,
                      title: 'Vegetarian Stir-fry', // <-- Ganti nama menu
                      subtitle: 'Asian Rate 4,7', // <-- Ganti deskripsi
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ListScreen(
                            Title: 'Vegetarian Stir-fry',
                            endpoint: 'recipes/tag/Vegetarian',
                          ),
                        ),
                      ),
                    ),

                    // [RESPONSI]: Menu 3 - Ganti title, subtitle, dan endpoint
                    _buildMenuCard(
                      context: context,
                      icon: Icons.local_florist_outlined,
                      title: 'Fragrances', // <-- Ganti nama menu
                      subtitle:
                          'Koleksi wewangian premium.', // <-- Ganti deskripsi
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ListScreen(
                            Title: 'Fragrances',
                            endpoint: 'recipes',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 140,
                height: 42,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  onPressed: () => _logout(context),
                  child: const Text(
                    'Log Out',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
