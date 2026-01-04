
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../logic/providers/product_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/category_tile.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the providers
    final productsAsync = ref.watch(productsProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: productsAsync.when(
          data: (products) {
            // Filter products based on search query AND selected category
            final filteredProducts = products.where((p) {
              final matchesSearch = p.title.toLowerCase().contains(searchQuery.toLowerCase());
              final matchesCategory = selectedCategory == 'All' || p.category == selectedCategory;
              return matchesSearch && matchesCategory;
            }).toList();

          return Scrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // 1. Custom Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Good Morning,', 
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: Colors.grey[600],
                                )
                              ),
                              const SizedBox(height: 4),
                              Text(
                                Supabase.instance.client.auth.currentUser?.userMetadata?['full_name'] ?? 'Guest', 
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold, 
                                  color: theme.textTheme.titleLarge?.color
                                )
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(2), // Border width
                            decoration: BoxDecoration(
                              color: theme.primaryColor, // Border color
                              shape: BoxShape.circle,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const CircleAvatar(
                                radius: 22,
                                backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 2. Search Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05), 
                              blurRadius: 20, 
                              offset: const Offset(0, 5)
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) => ref.read(searchQueryProvider.notifier).state = val,
                          decoration: InputDecoration(
                            hintText: 'Search for clothes, shoes...',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            prefixIcon: Icon(Icons.search, color: theme.primaryColor.withOpacity(0.6)),
                            suffixIcon: searchQuery.isNotEmpty 
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    ref.read(searchQueryProvider.notifier).state = '';
                                  },
                                )
                              : Container(
                                  margin: const EdgeInsets.all(8),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: theme.primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(Icons.tune, color: theme.primaryColor, size: 20),
                                ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ),

                    // 3. Hero Banner
                    if (searchQuery.isEmpty && selectedCategory == 'All')
                      Container(
                        height: 200,
                        margin: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                        child: PageView(
                          physics: const BouncingScrollPhysics(),
                          children: [
                            _buildBanner(
                              'Summer Sale', 
                              'Up to 50% OFF', 
                              const Color(0xFF1A237E), 
                              'https://images.unsplash.com/photo-1483985988355-763728e1935b?ixlib=rb-4.0.3&auto=format&fit=crop&w=1470&q=80'
                            ),
                            _buildBanner(
                              'New Arrivals', 
                              'Fresh Looks', 
                              const Color(0xFF00695C), 
                              'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80'
                            ),
                          ],
                        ),
                      ),

                    // 4. Categories Title
                    if (searchQuery.isEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Categories', 
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: const Text('See All'),
                            ),
                          ],
                        ),
                      ),

                    // 5. Category List
                    if (searchQuery.isEmpty)
                      SizedBox(
                        height: 110,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          physics: const BouncingScrollPhysics(),
                          children: [
                            _buildCategoryItem('All', Icons.grid_view_rounded, theme.primaryColor),
                            const SizedBox(width: 16),
                            _buildCategoryItem('Electronics', Icons.devices_other, theme.colorScheme.secondary),
                            const SizedBox(width: 16),
                            _buildCategoryItem('Fashion', Icons.checkroom, Colors.pinkAccent),
                            const SizedBox(width: 16),
                            _buildCategoryItem('Home', Icons.weekend_outlined, Colors.orange),
                            const SizedBox(width: 16),
                            _buildCategoryItem('Sports', Icons.fitness_center, Colors.blue),
                          ],
                        ),
                      ),

                    // 6. Popular Products Title
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            searchQuery.isNotEmpty ? 'Search Results' : 
                            selectedCategory != 'All' ? '$selectedCategory Products' : 'Popular Products', 
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (searchQuery.isEmpty && selectedCategory == 'All')
                            TextButton(
                              onPressed: () {},
                              child: const Text('See All'),
                            ),
                        ],
                      ),
                    ),

                    // 7. Product Grid
                    filteredProducts.isEmpty 
                      ? Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[300]),
                                const SizedBox(height: 16),
                                Text(
                                  'No products found',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                                ),
                                if (selectedCategory != 'All')
                                  TextButton(
                                    onPressed: () => ref.read(selectedCategoryProvider.notifier).state = 'All',
                                    child: const Text('Clear Category Logic'),
                                  ),
                              ],
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.7, 
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: filteredProducts.length,
                            itemBuilder: (context, index) {
                              return ProductCard(product: filteredProducts[index]);
                            },
                          ),
                        ),
                    
                    const SizedBox(height: 100), // Bottom padding
                  ],
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(String title, IconData icon, Color color) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final isSelected = selectedCategory == title;
    
    return CategoryTile(
      title: title, 
      icon: icon, 
      color: color, 
      bgColor: color.withOpacity(0.1),
      isSelected: isSelected,
      onTap: () => ref.read(selectedCategoryProvider.notifier).state = title,
    );
  }

  Widget _buildBanner(String title, String subtitle, Color color, String imageUrl) {
    return Container(
      margin: const EdgeInsets.only(right: 16), // Spacing for pageview
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [color.withOpacity(0.8), Colors.transparent],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.5)),
                  ),
                  child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),
                Text(subtitle, 
                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, height: 1.1),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: color,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Shop Now'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
