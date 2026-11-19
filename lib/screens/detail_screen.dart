import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/product_model.dart';
import '../services/api_service.dart';

class DetailScreen extends StatefulWidget {
  final ProductModel item;
  const DetailScreen({super.key, required this.item});
  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Box _box;
  late ProductModel _item;
  bool _isFavorite = false;
  bool _isLoadingDetail = false;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
    _box = Hive.box('favorites');
    _isFavorite = _box.containsKey(_item.id.toString());
    _loadProduct();
  }

  /// Muat ulang detail dari API berdasarkan ID agar ingredients & instructions termuat
  Future<void> _loadProduct() async {
    setState(() => _isLoadingDetail = true);
    try {
      final item = await ApiService.getSingleProduct(_item.id);
      if (mounted) {
        setState(() {
          _item = item;
          _isLoadingDetail = false;
          // Sinkronkan status favorite dengan data fresh
          _isFavorite = _box.containsKey(_item.id.toString());
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingDetail = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui detail dari API: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleFavorite() async {
    final key = _item.id.toString();
    if (_isFavorite) {
      await _box.delete(key);
      setState(() => _isFavorite = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dihapus dari favorite'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } else {
      await _box.put(key, _item.toJson());
      setState(() => _isFavorite = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ditambahkan ke favorite ❤️'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // === SliverAppBar dengan gambar ===
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: const Color(0xFF4CAF50),
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : Colors.white,
                  size: 28,
                ),
                onPressed: _toggleFavorite,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Detail Resep',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Gambar hero
                  _item.imageUrl.isNotEmpty
                      ? Image.network(
                          _item.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                            color: Colors.grey.shade300,
                            child: const Center(
                              child: Icon(
                                Icons.broken_image_outlined,
                                size: 72,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          loadingBuilder: (c, child, p) => p == null
                              ? child
                              : Container(
                                  color: Colors.grey.shade200,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: Color(0xFF4CAF50),
                                    ),
                                  ),
                                ),
                        )
                      : Container(color: Colors.grey.shade200),
                  // Gradient overlay agar teks terbaca
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // === Konten Detail ===
          SliverToBoxAdapter(
            child: _isLoadingDetail
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // === Judul Resep ===
                        Text(
                          _item.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // === Asal & Tingkat Kesulitan ===
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined,
                                size: 15, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              _item.category,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(Icons.bar_chart,
                                size: 15, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              _item.brand, // difficulty
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // === Info Chip (rating, servings, waktu) ===
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            _infoChip(
                              Icons.star_rounded,
                              Colors.amber,
                              '${_item.rating}',
                            ),
                            _infoChip(
                              Icons.people_outline,
                              const Color(0xFF4CAF50),
                              '${_item.stock} porsi',
                            ),
                            if (_item.prepTimeMinutes > 0)
                              _infoChip(
                                Icons.access_time_outlined,
                                Colors.blueGrey,
                                'Prep ${_item.prepTimeMinutes} min',
                              ),
                            if (_item.cookTimeMinutes > 0)
                              _infoChip(
                                Icons.local_fire_department_outlined,
                                Colors.orange,
                                'Masak ${_item.cookTimeMinutes} min',
                              ),
                            if (_item.price > 0)
                              _infoChip(
                                Icons.local_fire_department,
                                Colors.red,
                                '${_item.price.toStringAsFixed(0)} kkal',
                              ),
                          ],
                        ),

                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 12),

                        // ==============================
                        // === BAHAN-BAHAN (Ingredients)
                        // ==============================
                        _sectionHeader(
                          icon: Icons.shopping_basket_outlined,
                          title: 'Bahan-bahan',
                          color: const Color(0xFF4CAF50),
                        ),
                        const SizedBox(height: 10),
                        _item.ingredients.isNotEmpty
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: _item.ingredients.map((ing) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.only(top: 3),
                                          child: Icon(
                                            Icons.fiber_manual_record,
                                            size: 10,
                                            color: Color(0xFF4CAF50),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            ing,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black87,
                                              height: 1.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              )
                            : Text(
                                'Bahan-bahan tidak tersedia.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),

                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 12),

                        // ==============================
                        // === LANGKAH MEMASAK (Instructions)
                        // ==============================
                        _sectionHeader(
                          icon: Icons.format_list_numbered_outlined,
                          title: 'Langkah Memasak',
                          color: const Color(0xFF4CAF50),
                        ),
                        const SizedBox(height: 10),
                        _item.instructions.isNotEmpty
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: _item.instructions
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  final stepNo = entry.key + 1;
                                  final stepText = entry.value;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Nomor langkah
                                        Container(
                                          width: 28,
                                          height: 28,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF4CAF50),
                                            shape: BoxShape.circle,
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            '$stepNo',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        // Teks langkah
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                top: 4),
                                            child: Text(
                                              stepText,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black87,
                                                height: 1.5,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              )
                            : Text(
                                'Langkah memasak tidak tersedia.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),

                        const SizedBox(height: 24),

                        // === Tombol Jadikan Favorit ===
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isFavorite
                                  ? Colors.red.shade100
                                  : const Color(0xFF4CAF50),
                              foregroundColor: _isFavorite
                                  ? Colors.red
                                  : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 2,
                            ),
                            icon: Icon(
                              _isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                            ),
                            label: Text(
                              _isFavorite
                                  ? 'Hapus dari Favorite'
                                  : 'Dijadikan ke favorite',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            onPressed: _toggleFavorite,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // Helper: Section header dengan ikon
  Widget _sectionHeader({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  // Helper: Chip info kecil
  Widget _infoChip(IconData icon, Color color, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
