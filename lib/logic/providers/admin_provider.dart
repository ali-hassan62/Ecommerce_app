import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/product_model.dart';
import '../../data/sources/supabase_service.dart';
import 'product_provider.dart';

// Service provider is already defined in product_provider.dart usually, 
// but we can redefine or import. Let's assume we use the one from product_provider.dart
// or create a new reference if needed. For safety/separation, let's just use the service class directly via new provider.
final adminSupabaseServiceProvider = Provider((ref) => SupabaseService());

class AdminNotifier extends StateNotifier<AsyncValue<void>> {
  final SupabaseService _service;
  final Ref _ref;

  AdminNotifier(this._service, this._ref) : super(const AsyncValue.data(null));

  Future<void> addProduct(String title, double price, String imageUrl, String category) async {
    state = const AsyncValue.loading();
    try {
      // Create a temporary model. ID might be ignored by DB insertion.
      final newProduct = ProductModel(
        id: '', // DB will generate
        title: title,
        price: price,
        imageUrl: imageUrl,
        category: category,
      );
      await _service.addProduct(newProduct);
      state = const AsyncValue.data(null);
      // Refresh the product list so the app shows the new product immediately
      _ref.refresh(productsProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateProduct(ProductModel product) async {
    state = const AsyncValue.loading();
    try {
      await _service.updateProduct(product);
      state = const AsyncValue.data(null);
      _ref.refresh(productsProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteProduct(String id) async {
    state = const AsyncValue.loading();
    try {
      await _service.deleteProduct(id);
      state = const AsyncValue.data(null);
      _ref.refresh(productsProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final adminProvider = StateNotifierProvider<AdminNotifier, AsyncValue<void>>((ref) {
  final service = ref.watch(adminSupabaseServiceProvider);
  return AdminNotifier(service, ref);
});
