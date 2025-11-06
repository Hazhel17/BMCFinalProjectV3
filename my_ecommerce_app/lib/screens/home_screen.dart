import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'cart_screen.dart';
import 'admin_panel_screen.dart';
import '../models/product_model.dart';
import '../widgets/product_card.dart';
import '../screens/product_detail_screen.dart';
import 'order_history_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 1. STATE VARIABLES
  String _userRole = 'user';
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Manga', 'Comics'];

  // 2. LIFECYCLE METHOD
  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  // 3. HELPER METHODS

  Future<void> _fetchUserRole() async {
    if (_currentUser == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        setState(() {
          _userRole = doc.data()!['role'];
        });
      }
    } catch (e) {
      print("Error fetching user role: $e");
    }
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }


  Stream<QuerySnapshot> _getProductStream() {
    Query query = FirebaseFirestore.instance.collection('products');

    if (_selectedCategory == 'Manga') {
      query = query.where('format', isEqualTo: 'Manga');
    } else if (_selectedCategory == 'Comics') {
      query = query.where('format', isEqualTo: 'Comics');
    }

    return query.snapshots();
  }


  Widget _buildCategoryButton(String category) {
    final isSelected = _selectedCategory == category;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        label: Text(category),
        selected: isSelected,
        selectedColor: theme.primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? theme.colorScheme.onPrimary : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _selectedCategory = category;
            });
          }
        },
      ),
    );
  }

  // 4. BUILD METHOD
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        //using the user's email if logged in
        title: const Text('Manga & Comics Shop'),
        centerTitle: true,
        actions: [
          // 1. Cart Icon: Hide if user is admin
          if (_userRole != 'admin')
            Consumer<CartProvider>(
              builder: (context, cart, child) {
                return Badge(
                  label: Text(cart.itemCount.toString()),
                  isLabelVisible: cart.itemCount > 0,
                  child: IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const CartScreen()),
                      );
                      setState(() {});
                    },
                  ),
                );
              },
            ),

          // 2. Orders Icon: Hide if user is admin
          if (_userRole != 'admin')
            IconButton(
              icon: const Icon(Icons.receipt_long), // A "receipt" icon
              tooltip: 'My Orders',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const OrderHistoryScreen(),
                  ),
                );
              },
            ),

          // 3. Admin Icon: Show only if user is admin (existing logic)
          if (_userRole == 'admin')
            IconButton(
              icon: Icon(Icons.admin_panel_settings, color: theme.colorScheme.onSurface,),
              tooltip: 'Admin Panel',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AdminPanelScreen()),
                );
              },
            ),

          // 4. Logout Icon (Visible for all)
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _signOut,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _categories.map((category) {
                return _buildCategoryButton(category);
              }).toList(),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getProductStream(),
              builder: (context, snapshot) {

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final documents = snapshot.data!.docs;
                if (documents.isEmpty) {
                  return Center(
                    child: Text('No $_selectedCategory products found.', textAlign: TextAlign.center),
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: documents.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 7,
                    mainAxisSpacing:7,
                    childAspectRatio: 0.90,
                  ),
                  itemBuilder: (context, index) {
                    final productDoc = documents[index];
                    final productData = productDoc.data() as Map<String, dynamic>;
                    final product = Product.fromMap(productData, productDoc.id);

                    return ProductCard(
                      name: product.name,
                      price: product.price,
                      imageUrl: product.imageUrl,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ProductDetailScreen(product: product),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}