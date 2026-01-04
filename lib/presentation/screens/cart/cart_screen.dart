import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../logic/providers/cart_provider.dart';
import '../checkout/checkout_screen.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final quantities = ref.watch(cartQuantityProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('My Cart', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: cartItems.isEmpty
          ? _buildEmptyState(context, theme)
          : Scrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    ListView.separated(
                      padding: const EdgeInsets.all(24),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: cartItems.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final product = cartItems[index];
                        final qty = quantities[product.id] ?? 1;
                        return _buildCartItem(context, theme, product, qty, cartNotifier);
                      },
                    ),
                    _buildPriceSummary(context, theme, cartNotifier),
                    const SizedBox(height: 80), // Extra padding for bottom navigation
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCartItem(BuildContext context, ThemeData theme, product, int qty, cartNotifier) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.grey[100],
            ),
            clipBehavior: Clip.hardEdge,
            child: Image.network(
              product.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${product.price}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _qtyBtn(theme, Icons.remove, () => cartNotifier.decrementQuantity(product.id)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('$qty', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    _qtyBtn(theme, Icons.add, () => cartNotifier.incrementQuantity(product.id)),
                  ],
                )
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
            onPressed: () => cartNotifier.removeFromCart(product.id),
          )
        ],
      ),
    );
  }

  Widget _qtyBtn(ThemeData theme, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: theme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: theme.primaryColor),
      ),
    );
  }

  Widget _buildPriceSummary(BuildContext context, ThemeData theme, cartNotifier) {
    final subtotal = cartNotifier.totalPrice;
    const delivery = 5.00;
    final total = subtotal + delivery;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _summaryRow(theme, 'Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
            const SizedBox(height: 12),
            _summaryRow(theme, 'Delivery', '\$${delivery.toStringAsFixed(2)}'),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(),
            ),
            _summaryRow(theme, 'Total', '\$${total.toStringAsFixed(2)}', isTotal: true),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  shadowColor: theme.primaryColor.withOpacity(0.4),
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                   Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen()));
                },
                child: const Text('Checkout', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(ThemeData theme, String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label, 
          style: theme.textTheme.bodyLarge?.copyWith(
            color: isTotal ? theme.textTheme.titleLarge?.color : Colors.grey[600],
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          )
        ),
        Text(
          value, 
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: isTotal ? theme.primaryColor : theme.textTheme.titleLarge?.color,
            fontSize: isTotal ? 24 : 16,
          )
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.shopping_bag_outlined, size: 64, color: theme.primaryColor.withOpacity(0.5)),
          ),
          const SizedBox(height: 24),
          Text(
            'Your cart is empty', 
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)
          ),
          const SizedBox(height: 8),
          Text(
            'Looks like you haven\'t added any items yet.',
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
               // Navigate to home logic if possible, or just pop
               // Usually switching tab via provider or key is better
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.cardTheme.color,
              foregroundColor: theme.primaryColor,
              elevation: 0,
              side: BorderSide(color: theme.primaryColor),
            ),
            child: const Text('Start Shopping'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardTheme.color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: Colors.green, size: 48),
            ),
            const SizedBox(height: 24),
            Text('Payment Successful!', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Your order has been placed successfully.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Continue Shopping'),
              )
            ),
          ],
        ),
      ),
    );
  }
}
