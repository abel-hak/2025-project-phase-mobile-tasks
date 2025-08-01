import 'package:flutter/material.dart';

import '../models/product.dart';
import '../routes/route_transitions.dart';
import '../screens/add_edit_product_screen.dart';
import '../screens/product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Product> _products = [];

  void _navigateToAddProduct() async {
    final result = await Navigator.of(
      context,
    ).push(RouteTransitions.createSlideRoute(const AddEditProductScreen()));

    if (result != null && result is Product) {
      setState(() {
        _products.add(result);
      });
    }
  }

  void _navigateToDetails(Product product) {
    Navigator.of(context).push(
      RouteTransitions.createFadeRoute(ProductDetailScreen(product: product)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product List')),
      body: _products.isEmpty
          ? const Center(child: Text('No products yet. Add some!'))
          : ListView.builder(
              itemCount: _products.length,
              itemBuilder: (ctx, index) {
                final product = _products[index];
                return ListTile(
                  title: Text(product.name),
                  subtitle: Text(product.description),
                  onTap: () => _navigateToDetails(product),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddProduct,
        child: const Icon(Icons.add),
      ),
    );
  }
}
