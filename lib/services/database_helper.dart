import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product.dart';
import '../models/order.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('restaurant.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        price REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE orders (
        id TEXT PRIMARY KEY,
        customerName TEXT NOT NULL,
        date TEXT NOT NULL,
        total REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id TEXT NOT NULL,
        product_id TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        FOREIGN KEY (order_id) REFERENCES orders (id),
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');
    
    // Insertar datos de prueba
    await db.insert('products', {
      'id': '1',
      'name': 'Hamburguesa',
      'price': 8.99,
    });
    
    await db.insert('products', {
      'id': '2',
      'name': 'Pizza',
      'price': 12.99,
    });
    
    await db.insert('products', {
      'id': '3',
      'name': 'Ensalada',
      'price': 6.50,
    });
    
    await db.insert('products', {
      'id': '4',
      'name': 'Refresco',
      'price': 2.50,
    });
    
    // Crear un pedido de ejemplo
    String orderId = 'ord-001';
    await db.insert('orders', {
      'id': orderId,
      'customerName': 'Cliente Ejemplo',
      'date': DateTime.now().toIso8601String(),
      'total': 24.48,
    });
    
    await db.insert('order_items', {
      'order_id': orderId,
      'product_id': '1',
      'quantity': 2,
    });
    
    await db.insert('order_items', {
      'order_id': orderId,
      'product_id': '4',
      'quantity': 2,
    });
  }

  // Products CRUD
  Future<String> insertProduct(Product product) async {
    final db = await database;
    await db.insert('products', product.toMap());
    return product.id;
  }

  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('products');
    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

  Future<void> deleteProduct(String id) async {
    final db = await database;
    await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateProduct(Product product) async {
    final db = await database;
    await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  // Orders CRUD
  Future<String> insertOrder(Order order) async {
    final db = await database;
    await db.transaction((txn) async {
      // Insert order
      await txn.insert('orders', {
        'id': order.id,
        'customerName': order.customerName,
        'date': order.date.toIso8601String(),
        'total': order.total,
      });

      // Insert order items
      for (var item in order.items) {
        await txn.insert('order_items', {
          'order_id': order.id,
          'product_id': item.product.id,
          'quantity': item.quantity,
        });
      }
    });
    return order.id;
  }

  Future<void> updateOrderStatus(String id, String status) async {
    final db = await database;
    await db.update(
      'orders',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Order>> getOrdersByDate(DateTime date) async {
    final db = await database;
    final startDate = DateTime(date.year, date.month, date.day);
    final endDate = startDate.add(const Duration(days: 1));

    final List<Map<String, dynamic>> orderMaps = await db.query(
      'orders',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
    );

    List<Order> orders = [];
    
    for (var orderMap in orderMaps) {
      final String orderId = orderMap['id'];
      
      // Obtener los items de la orden
      final List<Map<String, dynamic>> itemMaps = await db.rawQuery('''
        SELECT oi.quantity, p.* 
        FROM order_items oi 
        JOIN products p ON oi.product_id = p.id 
        WHERE oi.order_id = ?
      ''', [orderId]);

      final List<OrderItem> items = itemMaps.map((itemMap) => OrderItem(
        product: Product.fromMap({
          'id': itemMap['id'],
          'name': itemMap['name'],
          'price': itemMap['price'],
        }),
        quantity: itemMap['quantity'],
      )).toList();

      orders.add(Order(
        id: orderId,
        customerName: orderMap['customerName'],
        items: items,
        date: DateTime.parse(orderMap['date']),
        total: orderMap['total'],
      ));
    }
    
    return orders;
  }

  Future<List<Order>> getAllOrders() async {
    final db = await database;
    final List<Map<String, dynamic>> orderMaps = await db.query('orders');

    List<Order> orders = [];
    
    for (var orderMap in orderMaps) {
      final String orderId = orderMap['id'];
      
      final List<Map<String, dynamic>> itemMaps = await db.rawQuery('''
        SELECT oi.quantity, p.* 
        FROM order_items oi 
        JOIN products p ON oi.product_id = p.id 
        WHERE oi.order_id = ?
      ''', [orderId]);

      final List<OrderItem> items = itemMaps.map((itemMap) => OrderItem(
        product: Product.fromMap({
          'id': itemMap['id'],
          'name': itemMap['name'],
          'price': itemMap['price'],
        }),
        quantity: itemMap['quantity'],
      )).toList();

      orders.add(Order(
        id: orderId,
        customerName: orderMap['customerName'],
        items: items,
        date: DateTime.parse(orderMap['date']),
        total: orderMap['total'],
      ));
    }
    
    return orders;
  }

  Future<void> deleteOrder(String id) async {
    final db = await database;
    await db.transaction((txn) async {
      // Primero eliminar los items del pedido
      await txn.delete(
        'order_items',
        where: 'order_id = ?',
        whereArgs: [id],
      );
      
      // Luego eliminar el pedido
      await txn.delete(
        'orders',
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }
}