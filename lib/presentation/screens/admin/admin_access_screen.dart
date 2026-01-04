import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminAccessScreen extends StatefulWidget {
  const AdminAccessScreen({super.key});

  @override
  State<AdminAccessScreen> createState() => _AdminAccessScreenState();
}

class _AdminAccessScreenState extends State<AdminAccessScreen> {
  final _secretKeyController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _verifyAndPromote() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final secret = _secretKeyController.text.trim();

    // Hardcoded Secret Key for Demonstration
    if (secret == 'admin123') {
      try {
        final user = Supabase.instance.client.auth.currentUser;
        if (user != null) {
          // Update user metadata to give admin role
          await Supabase.instance.client.auth.updateUser(
            UserAttributes(data: {'is_admin': true}),
          );
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Access Granted! You are now an Admin.')),
            );
            Navigator.pop(context); // Go back to profile
          }
        } else {
          setState(() {
            _errorMessage = 'User not logged in.';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Error updating role: $e';
        });
      }
    } else {
      setState(() {
        _errorMessage = 'Invalid Secret Key.';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Access', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.security, size: 80, color: Colors.black),
            const SizedBox(height: 24),
            const Text(
              'Enter Admin Secret Key',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter the secret key to unlock Admin features.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
             const SizedBox(height: 32),
            TextField(
              controller: _secretKeyController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Secret Key',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                errorText: _errorMessage,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verifyAndPromote,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text('Unlock Admin Panel', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
