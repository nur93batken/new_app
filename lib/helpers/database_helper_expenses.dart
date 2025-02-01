import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:sqlite3/sqlite3.dart';

class DatabaseHelperExpenses {
  late final Database db;

  DatabaseHelperExpenses() {
    // Укажите путь к файлу базы данных
    final dbPath = path.join(Directory.current.path, 'crud_example.db');

    // Открываем базу данных
    db = sqlite3.open(dbPath);

    // Создаем таблицу, если ее еще нет
    db.execute('''
      CREATE TABLE IF NOT EXISTS expense (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        create_date TEXT,
        price INTEGER
      )
    ''');
  }

  // Вставка записи
  void insertItem(String title, String create_date, int price) {
    final stmt = db.prepare(
        'INSERT INTO expense (title, create_date, price) VALUES (?, ?, ?)');
    stmt.execute([title, price, create_date]);
    stmt.dispose();
  }

  // Получение всех записей
  List<Map<String, dynamic>> getItems() {
    final result = db.select(
        "SELECT * FROM expense WHERE strftime('%Y-%m', create_date) = strftime('%Y-%m', 'now')");
    return result
        .map((row) => {
              'id': row['id'],
              'title': row['title'],
              'price': row['price'],
              'create_date': row['create_date']
            })
        .toList();
  }

  // Получение всех записей
  List<Map<String, dynamic>> getNowItems() {
    final result = db.select("SELECT * FROM expense WHERE price = 'new'");
    return result
        .map((row) => {
              'id': row['id'],
              'title': row['title'],
              'price': row['price'],
              'create_date': row['create_date']
            })
        .toList();
  }

  // Получение всех записей
  List<Map<String, dynamic>> getAllItems() {
    final result = db.select('SELECT * FROM expense');
    return result
        .map((row) => {
              'id': row['id'],
              'title': row['title'],
              'price': row['price'],
              'create_date': row['create_date']
            })
        .toList();
  }

  // Обновление записи
  void updateItem(int id, String newName, String create_date, int price) {
    final stmt = db.prepare(
        'UPDATE expense SET title = ?, create_date= ?, price = ? WHERE id = ?');
    stmt.execute([newName, price, create_date, id]);
    stmt.dispose();
  }

  // Обновление записи
  void updateItemStatus(int id, String create_date) {
    final stmt = db.prepare('UPDATE expense SET price= ? WHERE id = ?');
    stmt.execute([create_date, id]);
    stmt.dispose();
  }

  // Удаление записи
  void deleteItem(int id) {
    final stmt = db.prepare('DELETE FROM expense WHERE id = ?');
    stmt.execute([id]);
    stmt.dispose();
  }

  // Метод для удаления claer
  void clearOrders() {
    db.execute('DELETE FROM expense; VACUUM;');
  }

  // Закрытие базы данных
  void close() {
    db.dispose();
  }
}
