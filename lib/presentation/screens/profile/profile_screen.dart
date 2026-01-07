import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/theme_provider.dart';
import 'personal_details_screen.dart';
import 'addresses_screen.dart';
import 'payment_methods_screen.dart';
import 'wishlist_screen.dart';
import 'order_history_screen.dart';
import '../admin/admin_layout.dart';
import '../admin/admin_access_screen.dart';
import '../auth/auth_gate.dart';
import '../auth/reset_password_screen.dart';

import 'package:image_cropper/image_cropper.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> with SingleTickerProviderStateMixin {
  String? _avatarUrl;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();
  
  // Animations
  late AnimationController _controller;
  late Animation<double> _headerFadeAnimation;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _listFadeAnimation;
  late Animation<Offset> _listSlideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Header Animation (starts immediately)
    _headerFadeAnimation = CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeOut));
    _headerSlideAnimation = Tween<Offset>(begin: const Offset(0, -0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
    );

    // List Animation (starts slightly later)
    _listFadeAnimation = CurvedAnimation(parent: _controller, curve: const Interval(0.4, 1.0, curve: Curves.easeOut));
    _listSlideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 1.0, curve: Curves.easeOut)),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        _cropImage(pickedFile.path);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _cropImage(String sourcePath) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: sourcePath,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Theme.of(context).primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Crop Image',
          ),
        ],
      );
      
      if (croppedFile != null) {
        await _uploadImage(File(croppedFile.path));
      }
    } catch (e) {
       debugPrint('Error cropping image: $e');
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    setState(() => _isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final fileExt = imageFile.path.split('.').last;
      final fileName = '${DateTime.now().toIso8601String()}.$fileExt';
      final filePath = '${user.id}/$fileName';

      // Upload to Supabase Storage
      await Supabase.instance.client.storage
          .from('avatars')
          .upload(filePath, imageFile, fileOptions: const FileOptions(cacheControl: '3600', upsert: false));

      // Get Public URL
      final imageUrl = Supabase.instance.client.storage
          .from('avatars')
          .getPublicUrl(filePath);

      // Update User Metadata
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {'avatar_url': imageUrl}),
      );

      // Update Public Profile Table
      await Supabase.instance.client.from('profiles').upsert({
        'id': user.id,
        'avatar_url': imageUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'id');

      setState(() {
        _avatarUrl = imageUrl;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated!')),
        );
      }

    } catch (e) {
      debugPrint('Error uploading image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } finally {
       if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final user = Supabase.instance.client.auth.currentUser;
        final theme = Theme.of(context);
        
        // Prefer local state update, then metadata, then default
        final displayImage = _avatarUrl ?? user?.userMetadata?['avatar_url'];

        // If user is null (logged out), show loader/empty to avoid showing Guest profile before redirect
        if (user == null) {
          return Scaffold(body: Center(child: CircularProgressIndicator(color: theme.primaryColor)));
        }

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
                    // Header Section (Animated)
                    FadeTransition(
                      opacity: _headerFadeAnimation,
                      child: SlideTransition(
                        position: _headerSlideAnimation,
                        child: Column(
                          children: [
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: theme.primaryColor.withOpacity(0.5), width: 3),
                                    boxShadow: [
                                      BoxShadow(
                                        color: theme.primaryColor.withOpacity(0.2),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 55,
                                    backgroundColor: theme.colorScheme.surface,
                                    child: _isLoading 
                                      ? const CircularProgressIndicator()
                                      : ClipOval(
                                        child: displayImage != null 
                                          ? Image.network(
                                              displayImage,
                                              width: 110,
                                              height: 110,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => 
                                                Icon(Icons.person, size: 50, color: theme.primaryColor.withOpacity(0.5)),
                                            )
                                          : Image.network(
                                              'https://i.pravatar.cc/150?img=33',
                                              width: 110,
                                              height: 110,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => 
                                                Icon(Icons.person, size: 50, color: theme.primaryColor.withOpacity(0.5)),
                                            ),
                                      ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _pickImage,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: theme.primaryColor,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: theme.scaffoldBackgroundColor, width: 3),
                                    ),
                                    child: const Icon(Icons.edit_rounded, size: 14, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              user?.userMetadata?['full_name'] ?? 'Guest',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onBackground,
                                letterSpacing: -0.5
                              ),
                            ),
                            if (user?.email != null) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: theme.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  user!.email!,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.primaryColor,
                                    fontWeight: FontWeight.w500
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
  
                    // --- Menu Groups (Animated) ---
                    FadeTransition(
                      opacity: _listFadeAnimation,
                      child: SlideTransition(
                        position: _listSlideAnimation,
                        child: Column(
                          children: [
                            const SizedBox(height: 24), // Added spacing here inside animation
                            _buildMenuSection(context, theme, title: 'Account', items: [
                              _MenuItem(theme, icon: Icons.person_outline_rounded, label: 'Personal Details', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PersonalDetailsScreen()))),
                              _MenuItem(theme, icon: Icons.key_rounded, label: 'Change Password', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ResetPasswordScreen()))),
                              _MenuItem(theme, icon: Icons.location_on_outlined, label: 'Addresses', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddressesScreen()))),
                              _MenuItem(theme, icon: Icons.payment_outlined, label: 'Payment Methods', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PaymentMethodsScreen()))),
                              
                              // Dark Mode Switch
                              _SwitchMenuItem(
                                theme,
                                icon: Icons.dark_mode_outlined,
                                label: 'Dark Mode',
                                value: ref.watch(themeProvider) == ThemeMode.dark,
                                onChanged: (val) {
                                  ref.read(themeProvider.notifier).toggleTheme(val);
                                },
                              ),
                              
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
                            
          
                            // --- Logout Button ---
                            SizedBox(
                              width: double.infinity,
                              child: TextButton(
                                onPressed: () async {
                                   try {
                                     await Supabase.instance.client.auth.signOut();
                                   } catch (e) {
                                     // Ignore errors during sign out
                                   }
                                   if (mounted) {
                                     // Navigate to root (AuthGate) which handles the login screen
                                     Navigator.of(context).pushAndRemoveUntil(
                                       MaterialPageRoute(builder: (context) => const AuthGate()), 
                                       (route) => false,
                                     );
                                   }
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  backgroundColor: theme.brightness == Brightness.light 
                                      ? Colors.red.withOpacity(0.1) 
                                      : Colors.red.withOpacity(0.2), // More visible in dark mode
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                child: const Text(
                                  'Log Out', 
                                  style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16)
                                ),
                              ),
                            ),
                          ],
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
          child: Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7))),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.08), 
                blurRadius: 24, 
                offset: const Offset(0, 8)
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
                color: isHighlight 
                    ? theme.primaryColor.withOpacity(0.1) 
                    : theme.colorScheme.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon, 
                color: isHighlight 
                    ? theme.primaryColor 
                    : theme.colorScheme.onSecondaryContainer, 
                size: 20
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: isHighlight ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: theme.iconTheme.color?.withOpacity(0.3) ?? Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _SwitchMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final ThemeData theme;

  const _SwitchMenuItem(this.theme, {required this.icon, required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), // Adjusted vertical padding
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: theme.colorScheme.onSecondaryContainer, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: theme.primaryColor,
          ),
        ],
      ),
    );
  }
}
