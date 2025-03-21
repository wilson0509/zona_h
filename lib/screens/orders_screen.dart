import 'package:flutter/material.dart';
import 'package:zona_h/models/order.dart';
import 'package:zona_h/services/database_helper.dart';
import 'package:google_fonts/google_fonts.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<Order> _orders = [];
  String _filter = '';
  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() async {
    List<Order> orders = await DatabaseHelper.instance.getOrdersByDate(DateTime.now());
    setState(() {
      _orders = orders;
    });
  }

  void _showFilterDialog() async {
    // Show filter options to the user
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter Orders'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Customer Name'),
                  onChanged: (value) {
                    _filter = value;
                  },
                ),
                // Add date picker or other filters as needed
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                // Apply filters here
                Navigator.of(context).pop();
                },
              child: const Text('Apply'),
              ),
          ],
          );
        },
    );
  }

  Future<void> _confirmOrder() async {
    bool confirmed = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Order'),
          content: const Text('Are you sure you want to confirm this order?'),
        actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirm'),
          ),
        ],
        );
                },
          );

    if (confirmed) {
      await _saveOrder();
}
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog();
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];
          return Card(
            child: ListTile(
              title: Text('Pedido: ${order.id}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cliente: ${order.customerName}'),
                  Text('Total: \$${order.total.toStringAsFixed(2)}'),
                  Text('Items: ${order.items.length}'),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  // Show order details or actions
                },
              ),
            ),
          );
        },
      ),
    );
  }
}