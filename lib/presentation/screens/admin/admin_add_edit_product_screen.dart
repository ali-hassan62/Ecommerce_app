import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/product_model.dart';
import '../../../logic/providers/admin_provider.dart';

class AdminAddEditProductScreen extends ConsumerStatefulWidget {
  final ProductModel? product; // If null, we are adding

  const AdminAddEditProductScreen({super.key, this.product});

  @override
  ConsumerState<AdminAddEditProductScreen> createState() => _AdminAddEditProductScreenState();
}

class _AdminAddEditProductScreenState extends ConsumerState<AdminAddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _priceController;
  late TextEditingController _categoryController;
  
  // We keep this to store the final URL (either from existing product or new upload)
  String? _finalImageUrl;
  
  File? _pickedImageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.product?.title ?? '');
    _priceController = TextEditingController(text: widget.product?.price.toString() ?? '');
    _categoryController = TextEditingController(text: widget.product?.category ?? 'Electronics');
    _finalImageUrl = widget.product?.imageUrl;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _pickedImageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      final fileExt = imageFile.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = fileName; // storing in root of 'products' bucket

      await Supabase.instance.client.storage
          .from('products')
          .upload(filePath, imageFile, fileOptions: const FileOptions(cacheControl: '3600', upsert: false));

      final imageUrl = Supabase.instance.client.storage
          .from('products')
          .getPublicUrl(filePath);

      return imageUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      throw 'Image upload failed: $e';
    }
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      if (_pickedImageFile == null && (_finalImageUrl == null || _finalImageUrl!.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload an image for the product.')),
        );
        return;
      }

      setState(() => _isSaving = true);

      try {
        // Upload image if a new one is picked
        if (_pickedImageFile != null) {
          final uploadedUrl = await _uploadImage(_pickedImageFile!);
          if (uploadedUrl != null) {
            _finalImageUrl = uploadedUrl;
          }
        }

        if (widget.product != null) {
          // Edit
          final updatedProduct = ProductModel(
            id: widget.product!.id,
            title: _titleController.text,
            price: double.parse(_priceController.text),
            imageUrl: _finalImageUrl!,
            category: _categoryController.text,
          );
          await ref.read(adminProvider.notifier).updateProduct(updatedProduct);
        } else {
          // Add
          await ref.read(adminProvider.notifier).addProduct(
            _titleController.text,
            double.parse(_priceController.text),
            _finalImageUrl!,
            _categoryController.text,
          );
        }
        
        final state = ref.read(adminProvider);
        if (state.hasError) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.error}'), backgroundColor: Colors.red),
            );
          }
        } else {
          if (mounted) Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product', style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _pickedImageFile != null
                        ? Image.file(_pickedImageFile!, fit: BoxFit.cover)
                        : (_finalImageUrl != null && _finalImageUrl!.isNotEmpty)
                            ? Image.network(
                                _finalImageUrl!, 
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => 
                                  const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo_outlined, size: 50, color: Colors.grey[400]),
                                  const SizedBox(height: 8),
                                  Text('Tap to upload image', style: TextStyle(color: Colors.grey[600])),
                                ],
                              ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              _buildTextField(controller: _titleController, label: 'Title'),
              const SizedBox(height: 16),
              _buildTextField(controller: _priceController, label: 'Price', keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _buildTextField(controller: _categoryController, label: 'Category'),
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSaving 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Save Product', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }
}
