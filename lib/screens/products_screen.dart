import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../models/product.dart';
class ProductsScreen extends StatefulWidget {
  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<Product> _products = [];
  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      // Show loading indicator or similar UI changes for loading state
    });
    
    try {
      final products = await DatabaseHelper.instance.getAllProducts();
      setState(() {
        _products.clear();
        _products.addAll(products);
      });
    } catch (e) {
      // Handle errors accordingly
    } finally {
      setState(() {
        // Hide loading indicator or update UI
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
      ),
      body: ListView.builder(
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final product = _products[index];
          return ListTile(
            title: Text(product.name),
            subtitle: Text('Price: \$${product.price}'),
            // More UI for each product
                        );
                      },
                          ),
                                    );
                                  }
}
