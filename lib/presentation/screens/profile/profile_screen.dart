import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'personal_details_screen.dart';
import 'addresses_screen.dart';
import 'payment_methods_screen.dart';
import 'wishlist_screen.dart';
import 'order_history_screen.dart';
import '../admin/admin_layout.dart';
import '../admin/admin_access_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final user = Supabase.instance.client.auth.currentUser;
        final fullName = user?.userMetadata?['full_name'] ?? 'Alex Doe';
        final theme = Theme.of(context);

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text('Profile', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            centerTitle: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            scrolledUnderElevation: 0,
          ),
          body: Scrollbar(
            thumbVisibility: true,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                     Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.primaryColor, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: theme.colorScheme.surface,
                        child: ClipOval(
                          child: Image.network(
                            'https://i.pravatar.cc/150?img=33',
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => 
                              Icon(Icons.person, size: 50, color: theme.primaryColor.withOpacity(0.5)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      fullName,
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? 'alex.doe@example.com',
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 32),
  
                    // --- Menu Groups ---
                    _buildMenuSection(context, theme, title: 'Account', items: [
                      _MenuItem(theme, icon: Icons.person_outline_rounded, label: 'Personal Details', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PersonalDetailsScreen()))),
                      _MenuItem(theme, icon: Icons.location_on_outlined, label: 'Addresses', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddressesScreen()))),
                      _MenuItem(theme, icon: Icons.payment_outlined, label: 'Payment Methods', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PaymentMethodsScreen()))),
                      
                      // Admin Section
                      if (user?.userMetadata?['is_admin'] == true)
                        _MenuItem(
                          theme,
                          icon: Icons.admin_panel_settings_outlined,
                          label: 'Admin Panel',
                          isHighlight: true,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminLayout())),
                        )
                      else
                        _MenuItem(
                          theme,
                          icon: Icons.verified_user_outlined, 
                          label: 'Become a Seller', 
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminAccessScreen())),
                        ),
                    ]),
                    const SizedBox(height: 24),
                    
                    _buildMenuSection(context, theme, title: 'Content', items: [
                      _MenuItem(
                        theme, 
                        icon: Icons.favorite_border_rounded, 
                        label: 'Wishlist', 
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const WishlistScreen())),
                      ),
                      _MenuItem(
                        theme, 
                        icon: Icons.history_rounded, 
                        label: 'Order History', 
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const OrderHistoryScreen())),
                      ),
                    ]),
                    const SizedBox(height: 24),
  
                    // --- Logout Button ---
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () async {
                           await Supabase.instance.client.auth.signOut();
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.red.withOpacity(0.1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text(
                          'Log Out', 
                          style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16)
                        ),
                      ),
                    ),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuSection(BuildContext context, ThemeData theme, {required String title, required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey[600])),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.05), 
                blurRadius: 15, 
                offset: const Offset(0, 5)
              ),
            ],
          ),
          child: Column(children: items),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final ThemeData theme;
  final bool isHighlight;

  const _MenuItem(this.theme, {required this.icon, required this.label, required this.onTap, this.isHighlight = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24), // Match container radius for ripple
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isHighlight ? theme.primaryColor.withOpacity(0.1) : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: isHighlight ? theme.primaryColor : Colors.grey[700], size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: isHighlight ? theme.primaryColor : theme.textTheme.bodyLarge?.color,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
