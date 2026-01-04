import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../logic/providers/profile_provider.dart';
import 'add_payment_method_screen.dart';

class PaymentMethodsScreen extends ConsumerWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);
    final paymentMethods = profileState.paymentMethods;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Payment Methods', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            if (paymentMethods.isEmpty)
              const Expanded(child: Center(child: Text("No payment methods added yet.")))
            else
              Expanded(
                child: ListView.separated(
                  itemCount: paymentMethods.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final method = paymentMethods[index];
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF232526), Color(0xFF414345)]),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Icon(Icons.credit_card, color: Colors.white),
                              Row(
                                children: [
                                  Text(method.cardType, style: TextStyle(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.white70),
                                    onPressed: () {
                                      ref.read(profileProvider.notifier).deletePaymentMethod(method.id);
                                    },
                                  )
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Text(method.cardNumber, style: const TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 2)),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Card Holder', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10)),
                                  Text(method.cardHolderName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Expires', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10)),
                                  Text(method.expiryDate, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 24),
             SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                   Navigator.push(context, MaterialPageRoute(builder: (context) => const AddPaymentMethodScreen()));
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Payment Method'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.black),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
