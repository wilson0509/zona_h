import 'package:flutter/material.dart';

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
          // Aquí podrías añadir lógica para crear un nuevo pedido
          // Por ejemplo, navegar a una pantalla de creación de pedidos
        },
        tooltip: 'Nuevo Pedido',
        child: const Icon(Icons.add),
      ),
    );
  }
}