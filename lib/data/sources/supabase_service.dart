import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';

class SupabaseService {
  final _client = Supabase.instance.client;

  // Fetches every product in the table
  Future<List<ProductModel>> fetchProducts() async {
    final response = await _client.from('products').select();
    return (response as List).map((json) => ProductModel.fromJson(json)).toList();
  }

  // NEW: Fetches products based on their category column
  Future<List<ProductModel>> fetchProductsByCategory(String category) async {
    // .eq() filters the 'category' column for the value passed from the UI
    final response = await _client
        .from('products')
        .select()
        .eq('category', category); 
        
    return (response as List).map((json) => ProductModel.fromJson(json)).toList();
  }

  // --- Admin Methods ---

  Future<void> addProduct(ProductModel product) async {
    await _client.from('products').insert({
      'title': product.title,
      'price': product.price,
      'image_url': product.imageUrl,
      'category': product.category,
    });
  }

  Future<void> updateProduct(ProductModel product) async {
    await _client.from('products').update({
      'title': product.title,
      'price': product.price,
      'image_url': product.imageUrl,
      'category': product.category,
    }).eq('id', product.id);
  }

  Future<void> deleteProduct(String id) async {
    await _client.from('products').delete().eq('id', id);
  }
}