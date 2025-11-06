import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_ecommerce_app/screens/admin_order_screen.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final _formKey = GlobalKey<FormState>();

  // Existing Controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();

  final _genreController = TextEditingController();
  final _formatController = TextEditingController();

  bool _isLoading = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _genreController.dispose();
    _formatController.dispose();
    super.dispose();
  }

  Future<void> _uploadProduct() async {
    if (!_formKey.currentState!.validate()) { return; }

    setState(() { _isLoading = true; });

    try {
      String imageUrl = _imageUrlController.text.trim();

      await _firestore.collection('products').add({
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
        'imageUrl': imageUrl,

        'genre': _genreController.text.trim(),
        'format': _formatController.text.trim(),

        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product uploaded successfully!')),
      );

      _formKey.currentState!.reset();
      _nameController.clear();
      _descriptionController.clear();
      _priceController.clear();
      _imageUrlController.clear();
      // Clear NEW Controllers
      _genreController.clear();
      _formatController.clear();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload product: $e')),
      );
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 2. Change title to be more general
        title: const Text('Admin Panel'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 3. ADD THE NEW BUTTON HERE
              ElevatedButton.icon(
                icon: const Icon(Icons.list_alt),
                label: const Text('Manage All Orders'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreen, // A different color
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                onPressed: () {
                  // 4. Navigate to our new screen
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AdminOrderScreen(),
                    ),
                  );
                },
              ),
              // 5. A divider to separate it
              const Divider(height: 30, thickness: 1),

              // Add New Product Header (For cleaner UI)
              const Text(
                'Add New Product',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              // 6. The rest of your form starts here
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Image URL
                    TextFormField(
                      controller: _imageUrlController,
                      decoration: const InputDecoration(labelText: 'Image URL'),
                      keyboardType: TextInputType.url,
                      validator: (value) {
                        if (value == null || value.isEmpty) { return 'Please enter an image URL'; }
                        if (!value.startsWith('http')) { return 'Please enter a valid URL (e.g., http://...)'; }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Product Name
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Product Name'),
                      validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
                    ),
                    const SizedBox(height: 16),

                    // NEW: Genre Field
                    TextFormField(
                      controller: _genreController,
                      decoration: const InputDecoration(labelText: 'Genre'),
                      validator: (value) => value!.isEmpty ? 'Please enter the product genre' : null,
                    ),
                    const SizedBox(height: 16),

                    // NEW: Format Field
                    TextFormField(
                      controller: _formatController,
                      decoration: const InputDecoration(labelText: 'Format '),
                      validator: (value) => value!.isEmpty ? 'Please enter the product format' : null,
                    ),
                    const SizedBox(height: 16),


                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                      validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
                    ),
                    const SizedBox(height: 16),

                    // Price
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration (labelText: 'Price'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) { return 'Please enter a price'; }
                        if (double.tryParse(value) == null) { return 'Please enter a valid number'; }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Upload Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      onPressed: _isLoading ? null : _uploadProduct,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white,)
                          : const Text('Upload Product'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}