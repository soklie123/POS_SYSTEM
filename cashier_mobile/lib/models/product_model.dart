import 'package:cashier_mobile/services/api_service.dart';

class ProductModel {
  final int id;
  final String name;
  final String description;
  final String price;
  final String priceFormatted;
  final String imageUrl;
  final double rating;
  final int stock;
  final String stockStatus; // in_stock, low_stock, out_of_stock
  final String categoryName;
  final String categorySlug;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.priceFormatted,
    required this.imageUrl,
    required this.rating,
    required this.stock,
    required this.stockStatus,
    required this.categoryName,
    required this.categorySlug,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      price: json['price'],
      priceFormatted: json['price_formatted'],
      imageUrl: ApiService.fixImageUrl(json['image_url'] ?? ''),
      rating: double.parse(json['rating'].toString()),
      stock: json['stock'],
      stockStatus: json['stock_status'],
      categoryName: json['category']['name'],
      categorySlug: json['category']['slug'],
    );
  }
}
