import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  late TextEditingController _imageUrlController;
  late TextEditingController _categoryController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.product?.title ?? '');
    _priceController = TextEditingController(text: widget.product?.price.toString() ?? '');
    _imageUrlController = TextEditingController(text: widget.product?.imageUrl ?? '');
    _categoryController = TextEditingController(text: widget.product?.category ?? 'Electronics');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      if (widget.product != null) {
        // Edit
        final updatedProduct = ProductModel(
          id: widget.product!.id, // Keep existing ID
          title: _titleController.text,
          price: double.parse(_priceController.text),
          imageUrl: _imageUrlController.text,
          category: _categoryController.text,
        );
        await ref.read(adminProvider.notifier).updateProduct(updatedProduct);
      } else {
        // Add
        await ref.read(adminProvider.notifier).addProduct(
          _titleController.text,
          double.parse(_priceController.text),
          _imageUrlController.text,
          _categoryController.text,
        );
      }
      
      // Check for errors
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
            children: [
              _buildTextField(controller: _titleController, label: 'Title'),
              const SizedBox(height: 16),
              _buildTextField(controller: _priceController, label: 'Price', keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _buildTextField(controller: _imageUrlController, label: 'Image URL'),
               const SizedBox(height: 16),
              _buildTextField(controller: _categoryController, label: 'Category'),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Save Product', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
