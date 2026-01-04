import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../logic/providers/product_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dashboard Overview', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildStatCard(
                theme,
                title: 'Total Products',
                value: productsAsync.when(
                  data: (products) => products.length.toString(),
                  loading: () => '...',
                  error: (_, __) => 'Error',
                ),
                icon: Icons.inventory_2_rounded,
                color: Colors.blue,
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                theme,
                title: 'Total Users',
                value: '12', // Mock value for now
                icon: Icons.people_alt_rounded,
                color: Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
               _buildStatCard(
                theme,
                title: 'Total Orders',
                value: '45', // Mock value for now
                icon: Icons.shopping_bag_rounded,
                color: Colors.orange,
              ),
              const SizedBox(width: 16),
               _buildStatCard(
                theme,
                title: 'Revenue',
                value: '\$12k', // Mock value for now
                icon: Icons.attach_money_rounded,
                color: Colors.purple,
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatCard(ThemeData theme, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 24),
            Text(value, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}
