import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:sqlite3/sqlite3.dart';

class DatabaseHelperCart {
  late final Database db;

  DatabaseHelperCart() {
    // Укажите путь к файлу базы данных
    final dbPath = path.join(Directory.current.path, 'crud_example.db');

    // Открываем базу данных
    db = sqlite3.open(dbPath);

    // Создаем таблицу, если ее еще нет
    db.execute('''
      CREATE TABLE IF NOT EXISTS cart (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        price INTEGER
      )
    ''');
  }

  // Вставка записи
  void insertItem(String title, int price) {
    final stmt = db.prepare('INSERT INTO cart (title, price) VALUES (?, ?)');
    stmt.execute([title, price]);
    stmt.dispose();
  }

  // Получение всех записей
  List<Map<String, dynamic>> getItems() {
    final result = db.select('SELECT * FROM cart');
    return result
        .map((row) => {
              'id': row['id'],
              'title': row['title'],
              'price': row['price'],
            })
        .toList();
  }

  // Обновление записи
  void updateItem(int id, String newName, int price) {
    final stmt =
        db.prepare('UPDATE cart SET title = ?, price = ?, WHERE id = ?');
    stmt.execute([newName, price, id]);
    stmt.dispose();
  }

  // Удаление записи
  void deleteItem(int id) {
    final stmt = db.prepare('DELETE FROM cart WHERE id = ?');
    stmt.execute([id]);
    stmt.dispose();
  }

  // Закрытие базы данных
  void close() {
    db.dispose();
  }
}
