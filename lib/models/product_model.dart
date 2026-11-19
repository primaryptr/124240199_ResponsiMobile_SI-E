class ProductModel {
  final int id;
  final String title;
  final String description; // instructions sebagai teks gabungan (fallback)
  final String category; // cuisine
  final double price; // caloriesPerServing
  final double rating;
  final int stock; // servings
  final String brand; // difficulty
  final String imageUrl;
  final String webUrl;
  final List<String> ingredients; // bahan-bahan
  final List<String> instructions; // langkah memasak
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final String mealType;

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
    this.ingredients = const [],
    this.instructions = const [],
    this.prepTimeMinutes = 0,
    this.cookTimeMinutes = 0,
    this.mealType = '',
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // ----- Gambar -----
    String selectedImage = '';
    if (json['image'] != null && json['image'].toString().isNotEmpty) {
      selectedImage = json['image'].toString();
    } else if (json['imageUrl'] != null &&
        json['imageUrl'].toString().isNotEmpty) {
      selectedImage = json['imageUrl'].toString();
    } else if (json['thumbnail'] != null &&
        json['thumbnail'].toString().isNotEmpty) {
      selectedImage = json['thumbnail'].toString();
    } else if (json['images'] is List && (json['images'] as List).isNotEmpty) {
      selectedImage = json['images'][0].toString();
    }

    // ----- ID -----
    final id = json['id'] is int
        ? json['id'] as int
        : int.tryParse(json['id']?.toString() ?? '0') ?? 0;

    // ----- Ingredients -----
    List<String> ingredients = [];
    if (json['ingredients'] is List) {
      ingredients = (json['ingredients'] as List)
          .map((e) => e.toString())
          .toList();
    }

    // ----- Instructions -----
    List<String> instructionList = [];
    if (json['instructions'] is List) {
      instructionList = (json['instructions'] as List)
          .map((e) => e.toString())
          .toList();
    }

    // ----- Description (fallback teks) -----
    final description = instructionList.isNotEmpty
        ? instructionList.asMap().entries
              .map((e) => '${e.key + 1}. ${e.value}')
              .join('\n')
        : json['description']?.toString() ?? 'Tidak ada deskripsi tersedia.';

    // ----- MealType -----
    String mealType = '';
    if (json['mealType'] is List) {
      mealType = (json['mealType'] as List).join(', ');
    } else if (json['mealType'] != null) {
      mealType = json['mealType'].toString();
    }

    return ProductModel(
      id: id,
      title:
          json['name']?.toString() ?? json['title']?.toString() ?? 'Tanpa Nama',
      description: description,
      category:
          json['cuisine']?.toString() ?? json['category']?.toString() ?? 'Umum',
      price: _number(json['caloriesPerServing'] ?? json['price']),
      rating: _number(json['rating']),
      stock: _integer(json['servings'] ?? json['stock']),
      brand:
          json['difficulty']?.toString() ??
          json['brand']?.toString() ??
          'Unknown',
      imageUrl: selectedImage,
      webUrl: 'https://dummyjson.com/recipes/$id',
      ingredients: ingredients,
      instructions: instructionList,
      prepTimeMinutes: _integer(json['prepTimeMinutes']),
      cookTimeMinutes: _integer(json['cookTimeMinutes']),
      mealType: mealType,
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
      'ingredients': ingredients,
      'instructions': instructions,
      'prepTimeMinutes': prepTimeMinutes,
      'cookTimeMinutes': cookTimeMinutes,
      'mealType': mealType,
    };
  }
}
