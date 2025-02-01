import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:sqlite3/sqlite3.dart';

class DatabaseReportHelper {
  late final Database db;

  DatabaseReportHelper() {
    // Укажите путь к файлу базы данных
    final dbPath = path.join(Directory.current.path, 'crud_example.db');

    // Открываем базу данных
    db = sqlite3.open(dbPath);

    // Создаем таблицу, если ее еще нет
    db.execute('''
      CREATE TABLE IF NOT EXISTS reports (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_product INTEGER, 
        title TEXT,
        price INTEGER,
        count INTEGER
      )
    ''');
  }

  // Вставка записи
  void insertItem(
    int id_product,
    String title,
    int price,
    int count,
  ) {
    final stmt = db.prepare(
        'INSERT INTO reports (id_product, title, price, count) VALUES (?, ?, ?, ?)');
    stmt.execute([id_product, "$title - $priceсом", price, count]);
    stmt.dispose();
  }

  // Получение всех записей
  List<Map<String, dynamic>> getItems() {
    final result = db.select('SELECT * FROM reports');
    return result
        .map((row) => {
              'id': row['id'],
              'title': row['title'],
              'price': row['price'],
              'count': row['count'],
              'id_product': row['id_product']
            })
        .toList();
  }

  // Получение всех записей
  List<Map<String, dynamic>> getAllItems() {
    final result = db.select('SELECT * FROM reports');
    return result
        .map((row) => {
              'id': row['id'],
              'title': row['title'],
              'price': row['price'],
              'count': row['count'],
              'id_product': row['id_product']
            })
        .toList();
  }

  // Обновление записи
  void updateItemPlus(int id_product) {
    final stmt =
        db.prepare('UPDATE reports SET count = count + 1 WHERE id_product = ?');
    stmt.execute([id_product]);
    stmt.dispose();
  }

  // Обновление записи
  void updateItemMinus(String title) {
    final stmt =
        db.prepare('UPDATE reports SET count = count - 1 WHERE title = ?');
    stmt.execute([title]);
    stmt.dispose();
  }

  // Удаление записи
  void deleteItem(int id) {
    final stmt = db.prepare('DELETE FROM reports WHERE id = ?');
    stmt.execute([id]);
    stmt.dispose();
  }

  void updateIdProduct(int id_product, String title, int price, int count) {
    print(id_product);
    final result =
        db.select('SELECT * FROM reports WHERE id_product = ?', [id_product]);

    if (result.isNotEmpty) {
      updateItemPlus(id_product);
    } else {
      insertItem(id_product, title, price, count);
    }
  }

  // Метод для удаления claer
  void clearOrders() {
    db.execute('DELETE FROM reports; VACUUM;');
  }

  // Закрытие базы данных
  void close() {
    db.dispose();
  }
}
