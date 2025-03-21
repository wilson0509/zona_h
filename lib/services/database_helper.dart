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

  Future<List<Order>> getOrdersByDate(DateTime date) async {
    final db = await database;
    final startDate = DateTime(date.year, date.month, date.day);
    final endDate = startDate.add(const Duration(days: 1));

    final List<Map<String, dynamic>> orderMaps = await db.query(
      'orders',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
    );

    return Future.wait(orderMaps.map((orderMap) async {
      final List<Map<String, dynamic>> itemMaps = await db.rawQuery('''
        SELECT oi.quantity, p.* 
        FROM order_items oi 
        JOIN products p ON oi.product_id = p.id 
        WHERE oi.order_id = ?
      ''', [orderMap['id']]));

      final items = itemMaps.map((itemMap) => OrderItem(
        product: Product.fromMap({
          'id': itemMap['id'],
          'name': itemMap['name'],
          'price': itemMap['price'],
        }),
        quantity: itemMap['quantity'],
      )).toList();

      return Order(
        id: orderMap['id'],
        customerName: orderMap['customerName'],
        items: items,
        date: DateTime.parse(orderMap['date']),
        total: orderMap['total'],
      );
    }));
  }
}
