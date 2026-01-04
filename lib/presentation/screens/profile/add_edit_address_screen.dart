import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../logic/providers/profile_provider.dart';

class AddEditAddressScreen extends ConsumerStatefulWidget {
  final Address? address; // If null, we are adding. If not null, we are editing.

  const AddEditAddressScreen({super.key, this.address});

  @override
  ConsumerState<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends ConsumerState<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _labelController;
  late TextEditingController _fullNameController;
  late TextEditingController _streetController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _zipCodeController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.address?.label ?? 'Home');
    _fullNameController = TextEditingController(text: widget.address?.fullName ?? '');
    _streetController = TextEditingController(text: widget.address?.street ?? '');
    _cityController = TextEditingController(text: widget.address?.city ?? '');
    _stateController = TextEditingController(text: widget.address?.state ?? '');
    _zipCodeController = TextEditingController(text: widget.address?.zipCode ?? '');
    _phoneController = TextEditingController(text: widget.address?.phoneNumber ?? '');
  }

  @override
  void dispose() {
    _labelController.dispose();
    _fullNameController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final newAddress = Address(
        id: widget.address?.id ?? Uuid().v4(),
        label: _labelController.text,
        fullName: _fullNameController.text,
        street: _streetController.text,
        city: _cityController.text,
        state: _stateController.text,
        zipCode: _zipCodeController.text,
        phoneNumber: _phoneController.text,
      );

      if (widget.address != null) {
        ref.read(profileProvider.notifier).updateAddress(newAddress);
      } else {
        ref.read(profileProvider.notifier).addAddress(newAddress);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(widget.address == null ? 'Add Address' : 'Edit Address', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
              _buildTextField(controller: _labelController, label: 'Label (e.g., Home, Work)'),
              const SizedBox(height: 16),
              _buildTextField(controller: _fullNameController, label: 'Full Name'),
              const SizedBox(height: 16),
              _buildTextField(controller: _streetController, label: 'Street Address'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTextField(controller: _cityController, label: 'City')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField(controller: _stateController, label: 'State')),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(controller: _zipCodeController, label: 'Zip Code', keyboardType: TextInputType.number),
               const SizedBox(height: 16),
              _buildTextField(controller: _phoneController, label: 'Phone Number', keyboardType: TextInputType.phone),
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
                  child: const Text('Save Address', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
