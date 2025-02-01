import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:sqlite3/sqlite3.dart';

class DatabaseHelperPrihod {
  late final Database db;

  DatabaseHelperPrihod() {
    // Укажите путь к файлу базы данных
    final dbPath = path.join(Directory.current.path, 'crud_example.db');

    // Открываем базу данных
    db = sqlite3.open(dbPath);

    // Создаем таблицу, если ее еще нет
    db.execute('''
      CREATE TABLE IF NOT EXISTS prihod (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        price INTEGER,
        count INTEGER
      )
    ''');
  }

  // Вставка записи
  void insertItem(String title, int price, int count) {
    final stmt =
        db.prepare('INSERT INTO prihod (title, price, count) VALUES (?, ?, ?)');
    stmt.execute([title, price, count]);
    stmt.dispose();
  }

  // Получение всех записей
  List<Map<String, dynamic>> getItems() {
    final result = db.select('SELECT * FROM prihod');
    return result
        .map((row) => {
              'id': row['id'],
              'title': row['title'],
              'price': row['price'],
              'count': row['count'],
            })
        .toList();
  }

  // Обновление записи
  void updateItem(int id, int count) {
    final stmt =
        db.prepare('UPDATE prihod SET count = count + $count WHERE id = ?');
    stmt.execute([id]);
    stmt.dispose();
  }

  // Обновление записи
  void updateMinusItem(int id, int count) {
    final stmt =
        db.prepare('UPDATE prihod SET count = count - $count WHERE id = ?');
    stmt.execute([id]);
    stmt.dispose();
  }

  // Удаление записи
  void deleteItem(int id) {
    final stmt = db.prepare('DELETE FROM prihod WHERE id = ?');
    stmt.execute([id]);
    stmt.dispose();
  }

  // Закрытие базы данных
  void close() {
    db.dispose();
  }
}
