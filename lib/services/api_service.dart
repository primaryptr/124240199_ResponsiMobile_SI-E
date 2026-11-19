import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product_model.dart';

class ApiService {
  static const String baseUrl = 'https://dummyjson.com';

  static Future<List<ProductModel>> getProducts(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl/$endpoint'));

    if (response.statusCode != 200) {
      throw Exception(
        'Gagal memuat resep dari API (Status: ${response.statusCode})',
      );
    }

    final data = jsonDecode(response.body);
    final List<dynamic> results;
    if (data is Map<String, dynamic> && data['recipes'] is List) {
      results = data['recipes'] as List<dynamic>;
    } else if (data is Map<String, dynamic> && data['products'] is List) {
      results = data['products'] as List<dynamic>;
    } else if (data is List) {
      results = data;
    } else {
      throw const FormatException('Format daftar resep dari API tidak valid.');
    }

    return results
        .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<ProductModel> getSingleProduct(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/recipes/$id'));

    if (response.statusCode != 200) {
      throw Exception(
        'Gagal memuat detail resep (id: $id, status: ${response.statusCode})',
      );
    }

    final data = jsonDecode(response.body);
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Format detail resep dari API tidak valid.');
    }
    return ProductModel.fromJson(data);
  }
}
