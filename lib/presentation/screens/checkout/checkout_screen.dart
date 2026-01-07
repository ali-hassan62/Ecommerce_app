import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../logic/providers/cart_provider.dart';
import '../../../logic/providers/profile_provider.dart';
import '../profile/add_edit_address_screen.dart';
import '../profile/add_payment_method_screen.dart'; // Assuming this exists or will be created? Wait, plan said reuse existing.
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/email_service.dart';
import '../home/home_screen.dart';
import '../main_screen.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String? _selectedAddressId;
  String? _selectedPaymentId; // If null, maybe COD or nothing selected
  bool _isCod = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cartItems = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final profileState = ref.watch(profileProvider);
    final addresses = profileState.addresses;
    final paymentMethods = profileState.paymentMethods;

    // Calculate totals
    final subtotal = cartNotifier.totalPrice;
    const delivery = 5.00;
    final total = subtotal + delivery;

    // Default selection logic (run only once if needed, or keep reactive)
    if (_selectedAddressId == null && addresses.isNotEmpty) {
      _selectedAddressId = addresses.first.id;
    }
    
    // Auto-select first payment or COD logic could go here

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Checkout', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: cartItems.isEmpty
          ? const Center(child: Text("Cart is empty"))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   // --- Section: Shipping Address ---
                  _buildSectionHeader(theme, 'Shipping Address', Icons.location_on_outlined, () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditAddressScreen()));
                  }),
                  const SizedBox(height: 16),
                  if (addresses.isEmpty)
                     _buildAddAction(theme, 'Add Address', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditAddressScreen())))
                  else
                    ...addresses.map((addr) => _buildAddressOption(theme, addr)).toList(),

                  const SizedBox(height: 32),

                  // --- Section: Payment Method ---
                  _buildSectionHeader(theme, 'Payment Method', Icons.payment, () {
                    // Navigate to add payment method if exists, or just show dialog
                    // For now, let's assume reuse of Profile screens logic or just mock adding
                  }),
                  const SizedBox(height: 16),
                  _buildPaymentOption(theme, id: 'cod', label: 'Cash on Delivery', icon: Icons.money, isCod: true),
                  ...paymentMethods.map((pm) => _buildPaymentOption(theme, id: pm.id, label: '**** ${pm.cardNumber.substring(pm.cardNumber.length - 4)}', icon: Icons.credit_card)).toList(),
                  
                  const SizedBox(height: 32),

                  // --- Section: Order Summary ---
                  Text('Order Summary', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                    ),
                    child: Column(
                      children: [
                        _startEndRow(theme, 'Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
                        const SizedBox(height: 12),
                        _startEndRow(theme, 'Delivery', '\$${delivery.toStringAsFixed(2)}'),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider()),
                        _startEndRow(theme, 'Total', '\$${total.toStringAsFixed(2)}', isBold: true, color: theme.primaryColor),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: (cartItems.isEmpty) ? null : () => _handlePlaceOrder(context, theme, ref),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              shadowColor: theme.primaryColor.withOpacity(0.4),
              elevation: 8,
            ),
            child: const Text('Place Order', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title, IconData icon, VoidCallback onAdd) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: theme.primaryColor),
            const SizedBox(width: 8),
            Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        // Simple Add button
        TextButton(onPressed: onAdd, child: const Text("Add New")),
      ],
    );
  }

  Widget _buildAddAction(ThemeData theme, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, size: 20),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressOption(ThemeData theme, Address address) {
    final isSelected = _selectedAddressId == address.id;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAddressId = address.id;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: isSelected ? theme.primaryColor : Colors.transparent, width: 2),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Radio<String>(
              value: address.id,
              groupValue: _selectedAddressId,
              onChanged: (val) => setState(() => _selectedAddressId = val),
              activeColor: theme.primaryColor,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(address.label, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    '${address.street}, ${address.city}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(ThemeData theme, {required String id, required String label, required IconData icon, bool isCod = false}) {
    // Logic: if isCod is true, we check _isCod bool. If false, we check _selectedPaymentId matching id.
    // Ideally we want one single selection state. Let's simpler: use _selectedPaymentId. 'cod' is just a special ID.
    
    final isSelected = _selectedPaymentId == id || (_selectedPaymentId == null && isCod && _isCod); 
    // Wait, simpler:
    // We'll use _selectedPaymentId for everything. 'cod' = COD.
    final bool selected = _selectedPaymentId == id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentId = id;
          _isCod = isCod;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: selected ? theme.primaryColor : Colors.transparent, width: 2),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Radio<String>(
              value: id,
              groupValue: _selectedPaymentId,
              onChanged: (val) => setState(() {
                _selectedPaymentId = val;
                _isCod = isCod;
              }),
              activeColor: theme.primaryColor,
            ),
             Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: Colors.black87, size: 20),
            ),
            const SizedBox(width: 16),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _startEndRow(ThemeData theme, String start, String end, {bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(start, style: TextStyle(color: Colors.grey[600], fontSize: isBold ? 16 : 14)),
        Text(end, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: isBold ? 20 : 16, color: color ?? Colors.black)),
      ],
    );
  }

  Future<void> _handlePlaceOrder(BuildContext context, ThemeData theme, WidgetRef ref) async {
    if (_selectedAddressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a shipping address")));
      return;
    }
    if (_selectedPaymentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a payment method")));
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    // 1. Send Email (Try fire-and-forget or await? Let's await for demo)
    final user = Supabase.instance.client.auth.currentUser;
    final cartItems = ref.read(cartProvider);
    final total = ref.read(cartProvider.notifier).totalPrice + 5.0; // + Delivery

    bool emailSent = false;
    if (user?.email != null) {
       emailSent = await EmailService.sendOrderConfirmation(
        recipientEmail: user!.email!,
        customerName: "Valued Customer",
        items: cartItems,
        totalAmount: total,
      );
    }

    // Close loading
    Navigator.of(context).pop();

    // 2. Clear Cart
    ref.read(cartProvider.notifier).clearCart();

    // 3. Show Success
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.green[50], shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded, color: Colors.green, size: 48),
            ),
            const SizedBox(height: 24),
            const Text('Order Placed!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Your order has been successfully placed.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
             if (emailSent)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Confirmation email sent to ${user?.email}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold),
                ),
              ),
            if (!emailSent && user?.email != null)
               Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Note: Could not send confirmation email (Check API Key)',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.orange, fontSize: 12),
                ),
              ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const MainScreen()), 
                    (route) => false
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 14)
                ),
                child: const Text("Back to Home", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
