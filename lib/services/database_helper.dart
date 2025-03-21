import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product.dart';
import '../models/order.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('zona_h.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        price REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE orders(
        id TEXT PRIMARY KEY,
        customer_name TEXT NOT NULL,
        date TEXT NOT NULL,
        total REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE order_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id TEXT,
        product_id TEXT,
        quantity INTEGER,
        FOREIGN KEY (order_id) REFERENCES orders(id),
        FOREIGN KEY (product_id) REFERENCES products(id)
      )
    ''');
  }
    
  void _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // Implementa lógica de migración si es necesario
  }

  Future<int> insertProduct(Product product) async {
    final db = await database;
    return await db.insert('products', product.toMap());
  }

  Future<int> updateProduct(Product product) async {
    final db = await database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final result = await db.query('products');
    return result.map((json) => Product.fromMap(json)).toList();
  }

  Future<int> insertOrder(Order order) async {
    final db = await database;
    
    // Iniciar transacción
    return await db.transaction((txn) async {
      // Insertar la orden
      final orderId = await txn.insert('orders', {
        'id': order.id,
        'customer_name': order.customerName,
        'date': order.date.toIso8601String(),
        'total': order.total,
      });
      
      // Insertar los items de la orden
      for (var item in order.items) {
        await txn.insert('order_items', {
          'order_id': order.id,
          'product_id': item.product.id,
          'quantity': item.quantity,
        });
      }
      
      return orderId;
    });
  }
  
  Future<List<Order>> getOrdersByDate(DateTime date) async {
    final db = await database;
    final dateString = DateTime(date.year, date.month, date.day).toIso8601String().split('T')[0];
    
    // Obtener todas las órdenes de la fecha específica
    final List<Map<String, dynamic>> orderMaps = await db.query(
      'orders',
      where: 'date LIKE ?',
      whereArgs: ['$dateString%'],
    );
    
    // Convertir a lista de órdenes con sus items
    List<Order> orders = [];
    
    for (var orderMap in orderMaps) {
      final orderId = orderMap['id'];
      
      // Obtener los items de esta orden
      final List<Map<String, dynamic>> itemMaps = await db.rawQuery('''
        SELECT oi.quantity, p.id, p.name, p.price
        FROM order_items oi
        JOIN products p ON oi.product_id = p.id
        WHERE oi.order_id = ?
      ''', [orderId]);
      
      // Convertir los items
      List<OrderItem> items = itemMaps.map((itemMap) {
        return OrderItem(
          product: Product(
            id: itemMap['id'],
            name: itemMap['name'],
            price: itemMap['price'],
          ),
          quantity: itemMap['quantity'],
        );
      }).toList();
      
      // Crear la orden con sus items
      orders.add(Order(
        id: orderMap['id'],
        customerName: orderMap['customer_name'],
        date: DateTime.parse(orderMap['date']),
        items: items,
        total: orderMap['total'],
      ));
    }
    
    return orders;
  }
  
  Future close() async {
    final db = await database;
    db.close();
  }
}