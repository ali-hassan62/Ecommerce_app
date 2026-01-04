import 'package:hive/hive.dart';

// 1. THIS NAME MUST MATCH YOUR FILE NAME EXACTLY
part 'product_model.g.dart'; 

@HiveType(typeId: 0) // 2. Must have a unique typeId
class ProductModel extends HiveObject {
  @HiveField(0) // 3. Every field needs a number
  final String id;
  
  @HiveField(1)
  final String title;

  @HiveField(2)
  final double price;

  @HiveField(3)
  final String imageUrl;

  @HiveField(4)
  final String category;

  ProductModel({
    required this.id, 
    required this.title, 
    required this.price, 
    required this.imageUrl,
    required this.category,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image_url'] ?? '',
      category: json['category'] ?? 'Electronics', // Default category if missing
    );
  }
}