import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'admin_dashboard_screen.dart';
import 'admin_products_screen.dart';
import '../../screens/profile/profile_screen.dart'; // To go back

class AdminLayout extends ConsumerStatefulWidget {
  const AdminLayout({super.key});

  @override
  ConsumerState<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends ConsumerState<AdminLayout> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const AdminDashboardScreen(),
    const AdminProductsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Admin Panel', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true, 
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app, color: theme.colorScheme.error),
            onPressed: () {
               Navigator.pop(context); // Return to main app
            },
            tooltip: 'Exit Admin',
          )
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            backgroundColor: theme.cardTheme.color,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            selectedLabelTextStyle: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold),
            unselectedLabelTextStyle: TextStyle(color: Colors.grey[600]),
            selectedIconTheme: IconThemeData(color: theme.primaryColor),
            unselectedIconTheme: IconThemeData(color: Colors.grey[600]),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard_rounded),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.inventory_2_outlined),
                selectedIcon: Icon(Icons.inventory_2_rounded),
                label: Text('Products'),
              ),
              // Can add Users later
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
    );
  }
}
