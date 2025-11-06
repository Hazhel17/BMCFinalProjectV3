import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  Widget _buildFeatureCard(
      BuildContext context,
      IconData icon,
      String label,
      String value,
      Color iconColor,
      Color labelColor,
      ) {
    return Expanded(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Icon(icon, color: iconColor, size: 28),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(fontSize: 12, color: labelColor),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87, // Default color
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cart = Provider.of<CartProvider>(context, listen: false);

    final cardIconColor = theme.primaryColor;
    final cardLabelColor = Colors.grey[600]!;

    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product Image
            Image.network(
              product.imageUrl,
              height: 300,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const SizedBox(height: 300, child: Center(child: CircularProgressIndicator()));
              },
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox(height: 300, child: Center(child: Icon(Icons.broken_image, size: 100)));
              },
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    product.name,
                    style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    product.genre,
                    style: TextStyle(
                        fontSize: 16,
                        color: theme.primaryColor,
                        fontStyle: FontStyle.italic
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Row for Price, Format
                  Row(
                    children: [
                      // 1. Price Card
                      _buildFeatureCard(
                        context,
                        Icons.monetization_on_outlined,
                        'Price',
                        '₱${product.price.toStringAsFixed(2)}',
                        cardIconColor,
                        cardLabelColor,
                      ),

                      // 2. Format Card
                      _buildFeatureCard(
                        context,
                        Icons.menu_book,
                        'Format',
                        product.format,
                        cardIconColor,
                        cardLabelColor,
                      ),

                      _buildFeatureCard(
                        context,
                        Icons.star_half_outlined,
                        'Rating',
                        '4.8',
                        cardIconColor,
                        cardLabelColor,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Divider(thickness: 1),
                  const SizedBox(height: 16),

                  Text(
                    'Synopsis',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),

                  // Full Description
                  Text(
                    product.description,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 30),

                  ElevatedButton.icon(
                    onPressed: () {
                      cart.addItem(
                        product.id,
                        product.name,
                        product.price,
                        product.genre,
                        product.format,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Added to cart!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.shopping_cart),

                    label: Text('Add to Cart - ₱${product.price.toStringAsFixed(2)}'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 18),

                      backgroundColor: theme.primaryColor,
                      foregroundColor: theme.colorScheme.onPrimary,
                      minimumSize: const Size.fromHeight(50),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}