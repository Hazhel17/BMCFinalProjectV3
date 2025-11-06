import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'package:my_ecommerce_app/screens/order_success_screen.dart'; // 1. ADD THIS [cite: 160]

// 2. Change this to a StatefulWidget [cite: 161, 162]
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  // 3. Create the State [cite: 166, 167]
  State<CartScreen> createState() => _CartScreenState();
}

// 4. Rename the class to CartScreenState [cite: 168, 169]
class _CartScreenState extends State<CartScreen> {
  // 5. Add our loading state variable [cite: 170, 171]
  bool _isLoading = false;

  // 6. Move the build method inside here [cite: 173]
  @override
  Widget build(BuildContext context) {
 // 1. This line is the same [cite: 183]
  final cart = Provider.of<CartProvider>(context);
  final theme = Theme.of(context);

  return Scaffold(
  appBar: AppBar(
  title: const Text('Your Cart'), // Updated title [cite: 188]
  ),
  body: Column(
  children: [
  // 2. The ListView is the same (Expanded) [cite: 191]
  Expanded(
  // If cart is empty, show a message
  child: cart.items.isEmpty
  ? const Center(child: Text('Your cart is empty. Add some Comics & Manga!'))
      : ListView.builder(
  itemCount: cart.items.length,
  itemBuilder: (context, index) {
  final cartItem = cart.items[index];

  // A ListTile to show item details
  return ListTile(
  leading: CircleAvatar(
  backgroundColor: theme.primaryColor,
  child: Text(cartItem.title[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
  ),
  title: Text(cartItem.title),
  subtitle: Text('Qty: ${cartItem.quantity}'),
  trailing: Row(
  mainAxisSize: MainAxisSize.min,
  children: [
  // Total for this item
  Text(
  '₱${(cartItem.price * cartItem.quantity).toStringAsFixed(2)}',
  style: const TextStyle(fontWeight: FontWeight.bold),
  ),
  // Remove button
  IconButton(
  icon: const Icon(Icons.delete, color: Colors.red),
  onPressed: () {
  // Call the removeItem function
  cart.removeItem(cartItem.id);
  },
  ),
  ],
  ),
  );
  },
  ),
  ),

  // 3. The "Total" Card is the same [cite: 195]
  Card(
  margin: const EdgeInsets.all(16),
  child: Padding(
  padding: const EdgeInsets.all(16),
  child: Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
  const Text(
  'Total:',
  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  ),
  Text(
  '₱${cart.totalPrice.toStringAsFixed(2)}',
  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.primaryColor),
  ),
  ],
  ),
  ),
  ),
 // 4. --- ADD THIS NEW BUTTON [cite: 199]
  Padding(
  padding: const EdgeInsets.all(16.0),
  child: ElevatedButton(
  style: ElevatedButton.styleFrom(
  minimumSize: const Size.fromHeight(50), // Wide button [cite: 205]
  ),
 // 5. Disable button if loading OR if cart is empty [cite: 206, 250]
  onPressed: (_isLoading || cart.items.isEmpty)
  ? null
      : () async {
 // 6. Start the loading spinner [cite: 208, 251]
  setState(() {
  _isLoading = true;
  });

  try {
  // 7. Get provider (listen: false is for functions) [cite: 213, 252]
  final cartProvider =
  Provider.of<CartProvider>(context, listen: false);

  // 8. Call our new methods [cite: 215, 253, 254]
  await cartProvider.placeOrder();
  await cartProvider.clearCart();

 // 9. Navigate to success screen [cite: 218, 255]
  Navigator.of(context).pushAndRemoveUntil(
  MaterialPageRoute(
  builder: (context) => const OrderSuccessScreen()),
  (route) => false,
  );
  } catch (e) {
  // 10. Show error if placeOrder() fails [cite: 227, 257]
  ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
  content:
  Text('Failed to place order: \$e')),
  );
  } finally {
  // 11. ALWAYS stop the spinner [cite: 233, 257]
  if (mounted) {
  setState(() {
  _isLoading = false;
  });
  }
  }
  },
  // 12. Show spinner or text based on loading state [cite: 241, 258]
  child: _isLoading
  ? const CircularProgressIndicator(
  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
  )
      : const Text('Place Order'),
  ),
  ),
  ],
  ),
  );
  }
}