import 'package:flutter/material.dart';
class OrdersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders'),
      ),
      body: Center(
        child: Text('No orders available'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Aquí podrías añadir lógica para crear un nuevo pedido
          // Por ejemplo, navegar a una pantalla de creación de pedidos
        },
        tooltip: 'Nuevo Pedido',
        child: const Icon(Icons.add), // Mueve el argumento 'child' al final
      ),
    );
  }
}
