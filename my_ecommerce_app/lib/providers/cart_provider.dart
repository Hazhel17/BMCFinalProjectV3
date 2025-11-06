import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final String id;
  final String title;
  final String genre;
  final String format;
  final double price;
  int quantity;

  CartItem({
    required this.id,
    required this.title,
    required this.price,
    required this.genre,
    required this.format,
    this.quantity = 1,
  });

  // 1. A method to convert our CartItem object into a Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': title,
      'price': price,
      'quantity': quantity,
      'genre': genre,
      'format': format,
    };
  }

  // 2. A factory constructor to create a CartItem from a Map
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      title: json['name'],
      price: json['price'],
      quantity: json['quantity'],
      genre: json['genre'],
      format: json['format'],
    );
  }
}

class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];
  String? _userId;
  StreamSubscription? _authSubscription;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Existing Getters (Unchanged)
  List<CartItem> get items => _items;

  int get itemCount {
    int total = 0;
    for (var item in _items) {
      total += item.quantity;
    }
    return total;
  }

  double get totalPrice {
    double total = 0.0;
    for (var item in _items) {
      total += (item.price * item.quantity);
    }
    return total;
  }

  // 7. Constructor
  CartProvider() {
    print('CartProvider initialized');

    _authSubscription = _auth.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User logged out, clearing cart.');
        _userId = null;
        _items = [];
      } else {
        print('User logged in: ${user.uid}. Fetching cart...');
        _userId = user.uid;
        _fetchCart();
      }
      notifyListeners();
    });
  }

  // 8. Fetches the cart from Firestore
  Future<void> _fetchCart() async {
    if (_userId == null) return;
    try {
      final doc = await _firestore.collection('userCarts').doc(_userId).get();

      if (doc.exists && doc.data()!['cartItems'] != null) {
        final List<dynamic> cartData = doc.data()!['cartItems'];
        _items = cartData.map((item) => CartItem.fromJson(item)).toList();
        print('Cart fetched successfully: ${_items.length} items');
      } else {
        _items = [];
      }
    } catch (e) {
      print('Error fetching cart: $e');
      _items = [];
    }
    notifyListeners();
  }

  // 9. Saves the current local cart to Firestore
  Future<void> _saveCart() async {
    if (_userId == null) return;
    try {
      final List<Map<String, dynamic>> cartData =
      _items.map((item) => item.toJson()).toList();

      await _firestore.collection('userCarts').doc(_userId).set({
        'cartItems': cartData,
      });
      print('Cart saved to Firestore');
    } catch (e) {
      print('Error saving cart: $e');
    }
  }

 // 1. ADD THIS: Creates an order in the 'orders' collection [cite: 88]
  Future<void> placeOrder() async {
  // 2. Check if we have a user and items [cite: 90, 119]
    if (_userId == null || _items.isEmpty) {
      // Don't place an order if cart is empty or user is logged out
      throw Exception('Cart is empty or user is not logged in.');
    }

    try {
     // 3. Convert our List<CartItem> to a List<Map> using toJson() [cite: 96, 120]
      final List<Map<String, dynamic>> cartData =
      _items.map((item) => item.toJson()).toList();

      // 4. Get total price and item count from our getters [cite: 98]
      final double total = totalPrice;
      final int count = itemCount;

     // 5. Create a new document in the 'orders' collection [cite: 101, 121]
      await _firestore.collection('orders').add({
        'userId': _userId,
       'items': cartData, // Our list of item maps [cite: 104]
        'totalPrice': total,
        'itemCount': count,
        'status': 'Pending', // 6. IMPORTANT: For admin verification [cite: 107, 122]
        'createdAt': FieldValue.serverTimestamp(), // For sorting [cite: 108]
      });
     // 7. Note: We DO NOT clear the cart here. [cite: 110]
    } catch (e) {
      print('Error placing order: \$e');
      // 8. Re-throw the error so the UI can catch it [cite: 114, 124]
      throw e;
    }
  }

  // 9. ADD THIS: Clears the cart locally AND in Firestore [cite: 129]
  Future<void> clearCart() async {
   // 10. Clear the local list [cite: 131, 150]
    _items = [];

    // 11. If logged in, clear the Firestore cart as well [cite: 133]
    if (_userId != null) {
      try {
       // 12. Set the 'cartItems' field in their cart doc to an empty list [cite: 136, 151]
        await _firestore.collection('userCarts').doc(_userId).set({
          'cartItems': [],
        });
        print('Firestore cart cleared.');
      } catch (e) {
        print('Error clearing Firestore cart: \$e');
      }
    }

    // 13. Notify all listeners (this will clear the UI) [cite: 146, 153]
    notifyListeners();
  }

  // Updated addItem function
  void addItem(
      String id,
      String title,
      double price,
      String genre,
      String format,
      ) {
    var index = _items.indexWhere((item) => item.id == id);

    if (index != -1) {
      _items[index].quantity++;
    } else {
      _items.add(
        CartItem(
          id: id,
          title: title,
          price: price,
          genre: genre,
          format: format,
        ),
      );
    }
    _saveCart();
    notifyListeners();
  }

  // Updated removeItem function
  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);

    _saveCart();
    notifyListeners();
  }

  // 12. Dispose method
  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}