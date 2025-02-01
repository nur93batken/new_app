import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:sqlite3/sqlite3.dart';

class DatabaseAllReportHelper {
  late final Database db;

  DatabaseAllReportHelper() {
    // Укажите путь к файлу базы данных
    final dbPath = path.join(Directory.current.path, 'crud_example.db');

    // Открываем базу данных
    db = sqlite3.open(dbPath);

    // Создаем таблицу, если ее еще нет
    db.execute('''
      CREATE TABLE IF NOT EXISTS allreports (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        text TEXT,
        count INTEGER
      )
    ''');
  }

  // Вставка записи
  void insertItem(
    String title,
    String text,
    int count,
  ) {
    final stmt = db.prepare(
        'INSERT INTO allreports (title, text, count) VALUES (?, ?, ?)');
    stmt.execute([title, text, count]);
    stmt.dispose();
  }

  // Получение всех записей
  List<Map<String, dynamic>> getItems() {
    final result = db.select('SELECT * FROM allreports');
    return result
        .map((row) => {
              'id': row['id'],
              'title': row['title'],
              'text': row['text'],
              'count': row['count'],
            })
        .toList();
  }

  // Получение всех записей
  List<Map<String, dynamic>> getAllItems() {
    final result = db.select('SELECT * FROM allreports');
    return result
        .map((row) => {
              'id': row['id'],
              'title': row['title'],
              'text': row['text'],
              'count': row['count'],
            })
        .toList();
  }

  // Обновление записи
  void updateItemPlus(int id_product) {
    final stmt =
        db.prepare('UPDATE allreports SET count = count + 1 WHERE id = ?');
    stmt.execute([id_product]);
    stmt.dispose();
  }

  // Обновление записи
  void updateItemMinus(int id_product) {
    final stmt =
        db.prepare('UPDATE allreports SET count = count - 1 WHERE id = ?');
    stmt.execute([id_product]);
    stmt.dispose();
  }

  // Удаление записи
  void deleteItem(int id) {
    final stmt = db.prepare('DELETE FROM allreports WHERE id = ?');
    stmt.execute([id]);
    stmt.dispose();
  }

  void updateIdProduct(int id_product, String title, String text, int count) {
    print(id_product);
    final result =
        db.select('SELECT * FROM allreports WHERE id = ?', [id_product]);

    if (result.isNotEmpty) {
      updateItemPlus(id_product);
    } else {
      insertItem(title, text, count);
    }
  }

  // Метод для удаления claer
  void clearOrders() {
    db.execute('DELETE FROM allreports; VACUUM;');
  }

  // Закрытие базы данных
  void close() {
    db.dispose();
  }
}
