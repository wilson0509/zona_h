import 'product.dart';

class OrderItem {
  final Product product;
  final int quantity;

  OrderItem({
    required this.product,
    required this.quantity,
  });

  double get total => product.price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'product': product.toMap(),
      'quantity': quantity,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      product: Product.fromMap(map['product']),
      quantity: map['quantity'],
    );
  }
}

class Order {
  final String id;
  final String customerName;
  final List<OrderItem> items;
  final DateTime date;
  final double total;

  Order({
    required this.id,
    required this.customerName,
    required this.items,
    required this.date,
    required this.total,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerName': customerName,
      'items': items.map((item) => item.toMap()).toList(),
      'date': date.toIso8601String(),
      'total': total,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      customerName: map['customerName'],
      items: (map['items'] as List)
          .map((item) => OrderItem.fromMap(item))
          .toList(),
      date: DateTime.parse(map['date']),
      total: map['total'],
    );
  }
}