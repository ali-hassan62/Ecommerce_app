import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/sources/supabase_service.dart';
import '../../data/models/product_model.dart';

// 1. Create a provider for the service
final supabaseServiceProvider = Provider((ref) => SupabaseService());

// 2. NEW: Provider to manage the current category selection
// Default is 'All'
final selectedCategoryProvider = StateProvider<String>((ref) => 'All');

// 3. UPDATED: FutureProvider that reacts to the selected category
final productsProvider = FutureProvider<List<ProductModel>>((ref) async {
  final service = ref.watch(supabaseServiceProvider);
  final category = ref.watch(selectedCategoryProvider); // Listen to category changes

  if (category == 'All') {
    return service.fetchProducts();
  } else {
    // This calls the new filtering method we will add to the service
    return service.fetchProductsByCategory(category);
  }
});

// 4. NEW: Provider for search query
final searchQueryProvider = StateProvider<String>((ref) => '');
