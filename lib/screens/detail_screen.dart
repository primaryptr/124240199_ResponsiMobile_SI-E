// =========================================================================
// [SIMULASI MODUL 5: HALAMAN DETAIL PRODUK]
// PERBEDAAN DARI TEMPLATE-01:
// - Pakai ProductModel
// - Field tampil: title, brand, category, price, rating, stock, description
// - Url launcher: item.webUrl
// - Tombol Favorite menyimpan ke Hive
// =========================================================================

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

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

  @override
  void initState() {
    super.initState();
    _item = widget.item;
    _box = Hive.box('favorites');
    _isFavorite = _box.containsKey(_item.id.toString());
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    try {
      final item = await ApiService.getSingleProduct(_item.id);
      if (mounted) {
        setState(() => _item = item);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui detail dari API: $e')),
        );
      }
    }
  }

  Future<void> _toggleFavorite() async {
    final key = _item.id.toString();
    if (_isFavorite) {
      await _box.delete(key);
      setState(() => _isFavorite = false);
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dihapus dari favorite'),
            duration: Duration(seconds: 1),
          ),
        );
    } else {
      await _box.put(key, _item.toJson());
      setState(() => _isFavorite = true);
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ditambahkan ke favorite'),
            duration: Duration(seconds: 1),
          ),
        );
    }
  }

  Future<void> _openWeb() async {
    final uri = Uri.parse(_item.webUrl);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
    }
  }

  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Detail Produk',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF4C6EF5),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar Produk
                SizedBox(
                  width: double.infinity,
                  height: 240,
                  child: Image.network(
                    _item.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    loadingBuilder: (c, child, p) => p == null
                        ? child
                        : Container(
                            color: Colors.grey.shade100,
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Judul & Harga
                      Text(
                        _item.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rp ${_item.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4C6EF5),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 16),
                      // Info Produk
                      _infoRow('Brand', _item.brand),
                      _infoRow('Kategori', _item.category),
                      _infoRow('Rating', '${_item.rating} ⭐'),
                      _infoRow('Stok', '${_item.stock} tersisa'),
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 16),
                      // Deskripsi
                      const Text(
                        'Deskripsi',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4C6EF5),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _item.description,
                        textAlign: TextAlign.justify,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton.extended(
              backgroundColor: const Color(0xFFECEEFE),
              foregroundColor: const Color(0xFF4C6EF5),
              elevation: 3,
              icon: const Icon(Icons.open_in_new, size: 20),
              label: const Text(
                'Buka Web',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: _openWeb,
            ),
          ),
        ],
      ),
    );
  }
}
