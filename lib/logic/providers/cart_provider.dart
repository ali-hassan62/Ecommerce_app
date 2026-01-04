import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/product_model.dart';
import '../../core/constants.dart';

// We use a Map to track Quantities: { productId : quantity }
final cartQuantityProvider = StateProvider<Map<String, int>>((ref) => {});

final cartProvider = StateNotifierProvider<CartNotifier, List<ProductModel>>((ref) {
  return CartNotifier(ref);
});

class CartNotifier extends StateNotifier<List<ProductModel>> {
  final Ref ref;
  final Box<ProductModel> _cartBox = Hive.box<ProductModel>(AppConstants.cartBox);
  // NEW: Get the quantities box
  final Box<int> _quantitiesBox = Hive.box<int>(AppConstants.cartQuantitiesBox);

  CartNotifier(this.ref) : super([]) {
    // 1. Load data from Hive immediately
    state = _cartBox.values.toList();
    
    // 2. Load quantities from Hive
    Future.microtask(() {
      final savedQuantities = <String, int>{};
      
      // If we have saved quantities in the box, load them
      // Otherwise, default to 1 for existing items (migration)
      for (var item in state) {
         final qty = _quantitiesBox.get(item.id) ?? 1;
         savedQuantities[item.id] = qty;
         // Ensure we save the default if it wasn't there
         if (!_quantitiesBox.containsKey(item.id)) {
           _quantitiesBox.put(item.id, 1);
         }
      }
      
      ref.read(cartQuantityProvider.notifier).state = savedQuantities;
    });
  }

  void addToCart(ProductModel product) {
    if (!_cartBox.containsKey(product.id)) {
      _cartBox.put(product.id, product);
      state = _cartBox.values.toList();
      
      // Update quantities box
      _quantitiesBox.put(product.id, 1); // Default to 1
      
      final quantities = ref.read(cartQuantityProvider);
      ref.read(cartQuantityProvider.notifier).state = {...quantities, product.id: 1};
    } else {
      incrementQuantity(product.id);
    }
  }

  void incrementQuantity(String productId) {
    final quantities = ref.read(cartQuantityProvider);
    final currentQty = quantities[productId] ?? 1;
    final newQty = currentQty + 1;
    
    // Save to Hive
    _quantitiesBox.put(productId, newQty);
    
    ref.read(cartQuantityProvider.notifier).state = {
      ...quantities, 
      productId: newQty
    };
  }

  void decrementQuantity(String productId) {
    final quantities = ref.read(cartQuantityProvider);
    final currentQty = quantities[productId] ?? 1;
    if (currentQty > 1) {
      final newQty = currentQty - 1;
      
      // Save to Hive
      _quantitiesBox.put(productId, newQty);
      
      ref.read(cartQuantityProvider.notifier).state = {
        ...quantities, 
        productId: newQty
      };
    } else {
      removeFromCart(productId);
    }
  }

  void removeFromCart(String productId) {
    _cartBox.delete(productId);
    _quantitiesBox.delete(productId); // Remove quantity too
    
    state = _cartBox.values.toList();
    final quantities = ref.read(cartQuantityProvider);
    final newQuantities = Map<String, int>.from(quantities)..remove(productId);
    ref.read(cartQuantityProvider.notifier).state = newQuantities;
  }

  void clearCart() {
    _cartBox.clear();
    _quantitiesBox.clear();
    state = [];
    ref.read(cartQuantityProvider.notifier).state = {};
  }

  double get totalPrice {
    final quantities = ref.read(cartQuantityProvider);
    return state.fold(0, (sum, item) {
      return sum + (item.price * (quantities[item.id] ?? 1));
    });
  }
}