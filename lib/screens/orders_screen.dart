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
  List<Order> _filteredOrders = [];
  String _filter = '';
  
  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    List<Order> orders = await DatabaseHelper.instance.getOrdersByDate(DateTime.now());
    setState(() {
      _orders = orders;
      _applyFilters();
    });
  }

  void _applyFilters() {
    if (_filter.isEmpty) {
      _filteredOrders = List.from(_orders);
    } else {
      _filteredOrders = _orders
          .where((order) => order.customerName.toLowerCase().contains(_filter.toLowerCase()))
          .toList();
    }
  }

  void _showFilterDialog() async {
    String tempFilter = _filter;
    
    // Show filter options to the user
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filtrar Pedidos'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Nombre del Cliente'),
                  controller: TextEditingController(text: _filter),
                  onChanged: (value) {
                    tempFilter = value;
                  },
                ),
                // Add date picker or other filters as needed
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Cerrar diálogo sin aplicar filtros
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                // Apply filters here
                setState(() {
                  _filter = tempFilter;
                  _applyFilters();
                });
                Navigator.of(context).pop();
              },
              child: const Text('Aplicar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmOrder(Order order) async {
    bool confirmed = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar Pedido'),
          content: const Text('¿Estás seguro de que deseas confirmar este pedido?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );

    if (confirmed) {
      await _saveOrder(order);
    }
  }

  Future<void> _saveOrder(Order order) async {
    try {
      // Aquí implementarías la lógica para guardar/actualizar la orden
      // Por ejemplo:
      // await DatabaseHelper.instance.updateOrderStatus(order.id, 'confirmed');
      
      // Muestra un mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pedido confirmado con éxito')),
      );
      
      // Recarga las órdenes
      _loadOrders();
    } catch (e) {
      // Manejo de errores
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar el pedido: $e')),
      );
    }
  }

  Future<void> _showOrderDetails(Order order) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Detalles del Pedido #${order.id}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Cliente: ${order.customerName}', 
                  style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Fecha: ${_formatDate(order.date)}'),
                const SizedBox(height: 16),
                const Text('Productos:', 
                  style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${item.quantity}x ${item.product.name}'),
                      Text('\$${item.total.toStringAsFixed(2)}'),
                    ],
                  ),
                )),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total:', 
                      style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('\$${order.total.toStringAsFixed(2)}', 
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      )),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _confirmOrder(order);
              },
              child: const Text('Confirmar Pedido'),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog();
            },
          ),
        ],
      ),
      body: _filteredOrders.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              itemCount: _filteredOrders.length,
              itemBuilder: (context, index) {
                final order = _filteredOrders[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 3,
                  child: ListTile(
                    title: Text(
                      'Pedido: ${order.id}',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cliente: ${order.customerName}'),
                        Text('Total: \$${order.total.toStringAsFixed(2)}'),
                        Text('Items: ${order.items.length}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.info_outline),
                          onPressed: () {
                            _showOrderDetails(order);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.check_circle_outline),
                          color: Colors.green,
                          onPressed: () {
                            _confirmOrder(order);
                          },
                        ),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Aquí podrías añadir lógica para crear un nuevo pedido
          // Por ejemplo, navegar a una pantalla de creación de pedidos
        },
        child: const Icon(Icons.add),
        tooltip: 'Nuevo Pedido',
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _orders.isEmpty 
                ? 'No hay pedidos disponibles'
                : 'No se encontraron pedidos con el filtro actual',
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          if (_filter.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  _filter = '';
                  _applyFilters();
                });
              },
              child: const Text('Limpiar filtro'),
            ),
        ],
      ),
    );
  }
}