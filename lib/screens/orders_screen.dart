import 'package:flutter/material.dart';
import 'package:zona_h/screens/create_order_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
      ),
      body: const Center(
        child: Text('No orders available'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
        Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateOrderScreen()),
    ).then((value) {
      if (value == true) {
        // Actualizar datos de pedidos si es necesario
      }
    });
  },
  tooltip: 'Nuevo Pedido',
  child: const Icon(Icons.add),
),
    );
  }
}