import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:sqlite3/sqlite3.dart';

class DatabaseHelper {
  late final Database db;

  DatabaseHelper() {
    // Укажите путь к файлу базы данных
    final dbPath = path.join(Directory.current.path, 'crud_example.db');

    // Открываем базу данных
    db = sqlite3.open(dbPath);

    // Создаем таблицу, если ее еще нет
    db.execute('''
      CREATE TABLE IF NOT EXISTS products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        category TEXT,
        price INTEGER
      )
    ''');
  }

  // Вставка записи
  void insertItem(String title, int price, String category) {
    final stmt = db.prepare(
        'INSERT INTO products (title, price, category) VALUES (?, ?, ?)');
    stmt.execute([title, price, category]);
    stmt.dispose();
  }

  // Получение всех записей
  List<Map<String, dynamic>> getItems(String category) {
    final result =
        db.select('SELECT * FROM products WHERE category == ?', [category]);
    return result
        .map((row) => {
              'id': row['id'],
              'title': row['title'],
              'price': row['price'],
              'category': row['category']
            })
        .toList();
  }

  // Получение всех записей
  List<Map<String, dynamic>> getAllItems() {
    final result = db.select('SELECT * FROM products');
    return result
        .map((row) => {
              'id': row['id'],
              'title': row['title'],
              'price': row['price'],
              'category': row['category']
            })
        .toList();
  }

  // Обновление записи
  void updateItem(int id, String newName, int price, String category) {
    final stmt = db.prepare(
        'UPDATE products SET title = ?, price = ?, category = ? WHERE id = ?');
    stmt.execute([newName, price, category, id]);
    stmt.dispose();
  }

  // Удаление записи
  void deleteItem(int id) {
    final stmt = db.prepare('DELETE FROM products WHERE id = ?');
    stmt.execute([id]);
    stmt.dispose();
  }

  // Закрытие базы данных
  void close() {
    db.dispose();
  }
}
