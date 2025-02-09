import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:sqlite3/sqlite3.dart';

class DatabaseHelperMyExpenses {
  late final Database db;

  DatabaseHelperMyExpenses() {
    // Укажите путь к файлу базы данных
    final dbPath = path.join(Directory.current.path, 'crud_example.db');

    // Открываем базу данных
    db = sqlite3.open(dbPath);

    // Создаем таблицу, если ее еще нет
    db.execute('''
      CREATE TABLE IF NOT EXISTS myexpense (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        create_date TEXT,
        price INTEGER
      )
    ''');
  }

  void insertMyItem(String title, String create_date, int price) {
    final stmt = db.prepare(
        'INSERT INTO myexpense (title, create_date, price) VALUES (?, ?, ?)');
    stmt.execute([title, price, create_date]);
    stmt.dispose();
  }

  // Получение всех записей
  List<Map<String, dynamic>> getItems() {
    final result = db.select(
        "SELECT * FROM myexpense WHERE strftime('%Y-%m', create_date) = strftime('%Y-%m', 'now')");
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
    final result = db.select(
        "SELECT * FROM myexpense WHERE date(create_date) = date('now')");
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
    final result = db.select('SELECT * FROM myexpense');
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
  void updateItem(int id, String create_date) {
    final stmt = db.prepare('UPDATE myexpense SET price = ? WHERE id = ?');
    stmt.execute([create_date, id]);
    stmt.dispose();
  }

  // Удаление записи
  void deleteItem(int id) {
    final stmt = db.prepare('DELETE FROM myexpense WHERE id = ?');
    stmt.execute([id]);
    stmt.dispose();
  }

  // Удаление записи
  void clearItem() {
    db.execute("DROP TABLE IF EXISTS myexpense");
    db.execute('''
      CREATE TABLE IF NOT EXISTS myexpense (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        create_date TEXT,
        price INTEGER
      )
    ''');
  }

  // Закрытие базы данных
  void close() {
    db.dispose();
  }
}
