import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../logic/providers/product_provider.dart';
import '../../widgets/category_tile.dart';
import 'category_products_screen.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Categories', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Shop by Category', 
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onBackground.withOpacity(0.6),
                    letterSpacing: 0.5,
                  ),
                ),
                Text('Explore Collection', 
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
                const SizedBox(height: 24),
                StaggeredGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    StaggeredGridTile.count(
                      crossAxisCellCount: 1,
                      mainAxisCellCount: 1,
                      child: CategoryTile(
                        title: 'All Products', 
                        icon: Icons.grid_view_rounded, 
                        color: theme.colorScheme.primary, // Make this pop
                        bgColor: theme.colorScheme.primary.withOpacity(0.1),
                        isLarge: true,
                        onTap: () {
                           Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CategoryProductsScreen(categoryName: 'All')),
                          );
                        },
                      ),
                    ),
                    StaggeredGridTile.count(
                      crossAxisCellCount: 1,
                      mainAxisCellCount: 1.2,
                      child: CategoryTile(
                        title: 'Electronics', 
                        icon: Icons.devices_other, 
                        color: theme.colorScheme.secondary,
                        bgColor: theme.colorScheme.secondary.withOpacity(0.1),
                        isLarge: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CategoryProductsScreen(categoryName: 'Electronics')),
                          );
                        },
                      ),
                    ),
                    StaggeredGridTile.count(
                      crossAxisCellCount: 1,
                      mainAxisCellCount: 1.2,
                      child: CategoryTile(
                        title: 'Fashion', 
                        icon: Icons.checkroom, 
                        color: Colors.pinkAccent,
                        bgColor: Colors.pinkAccent.withOpacity(0.1),
                        isLarge: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CategoryProductsScreen(categoryName: 'Fashion')),
                          );
                        },
                      ),
                    ),
                    StaggeredGridTile.count(
                      crossAxisCellCount: 1,
                      mainAxisCellCount: 1,
                      child: CategoryTile(
                        title: 'Home', 
                        icon: Icons.weekend_outlined, 
                        color: Colors.deepOrange,
                        bgColor: Colors.deepOrange.withOpacity(0.1),
                        isLarge: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CategoryProductsScreen(categoryName: 'Home')),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
