// =========================================================================
// [SIMULASI MODUL 5: MODEL DATA PRODUK]
// SEBELUMNYA: ArticleModel (berisi title, news_site, summary, published_at, dsb)
// SEKARANG: ProductModel (menyesuaikan atribut API DummyJSON: price, rating, stock, brand, dsb)
//
// CARA ADAPTASI KE API LAIN:
// 1. Tentukan atribut yang dimiliki API baru.
// 2. Pada fromJson(), petakan key JSON dengan fallback (??) agar tidak null pointer.
// 3. Pada toJson(), simpan data yang ingin dicatat di Hive Favorite.
// =========================================================================

class ProductModel {
  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final double rating;
  final int stock;
  final String brand;
  final String imageUrl;
  final String webUrl; // URL web untuk url_launcher

  ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.rating,
    required this.stock,
    required this.brand,
    required this.imageUrl,
    required this.webUrl,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    String selectedImage = '';
    if (json['imageUrl'] != null && json['imageUrl'].toString().isNotEmpty) {
      selectedImage = json['imageUrl'].toString();
    } else if (json['image'] != null && json['image'].toString().isNotEmpty) {
      selectedImage = json['image'].toString();
    } else if (json['thumbnail'] != null &&
        json['thumbnail'].toString().isNotEmpty) {
      selectedImage = json['thumbnail'].toString();
    } else if (json['images'] is List && (json['images'] as List).isNotEmpty) {
      selectedImage = json['images'][0].toString();
    }

    final instructions = json['instructions'];
    final description = instructions is List
        ? instructions.map((step) => step.toString()).join('\n')
        : instructions?.toString() ??
              json['description']?.toString() ??
              'Tidak ada deskripsi tersedia.';
    final id = json['id'] is int
        ? json['id'] as int
        : int.tryParse(json['id']?.toString() ?? '0') ?? 0;

    return ProductModel(
      id: id,
      title:
          json['name']?.toString() ?? json['title']?.toString() ?? 'Tanpa Nama',
      description: description,
      category:
          json['cuisine']?.toString() ?? json['category']?.toString() ?? 'Umum',
      price: _number(json['price'] ?? json['caloriesPerServing']),
      rating: _number(json['rating']),
      stock: _integer(json['servings'] ?? json['stock']),
      brand:
          json['brand']?.toString() ??
          json['difficulty']?.toString() ??
          'No Brand',
      imageUrl: selectedImage,
      webUrl: 'https://dummyjson.com/recipes/$id',
    );
  }

  static double _number(dynamic value) => value is num
      ? value.toDouble()
      : double.tryParse(value?.toString() ?? '') ?? 0;

  static int _integer(dynamic value) =>
      value is int ? value : int.tryParse(value?.toString() ?? '') ?? 0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      'rating': rating,
      'stock': stock,
      'brand': brand,
      'imageUrl': imageUrl,
      'webUrl': webUrl,
    };
  }
}
