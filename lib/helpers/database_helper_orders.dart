import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:sqlite3/sqlite3.dart';

class DatabaseHelperOrders {
  late final Database db;

  DatabaseHelperOrders() {
    // Укажите путь к файлу базы данных
    final dbPath = path.join(Directory.current.path, 'crud_example.db');

    // Открываем базу данных
    db = sqlite3.open(dbPath);

    // Создаем таблицу, если ее еще нет
    db.execute('''
      CREATE TABLE IF NOT EXISTS orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        text TEXT,
        status TEXT,
        number TEXT,
        category TEXT,
        create_date TEXT,
        time TEXT,
        price INTEGER,
        endTime INTEGER
      )
    ''');
  }

  // Вставка записи
  void insertItem(String text, String status, String number, String create_date,
      String time, double price, int endTime) {
    final stmt = db.prepare(
        'INSERT INTO orders (text, status, number, create_date, time, price, endTime) VALUES (?, ?, ?, ?, ?, ?, ?)');
    stmt.execute([text, status, number, create_date, time, price, endTime]);
    stmt.dispose();
  }

  // Получение всех записей start
  List<Map<String, dynamic>> getItemsStart(String status) {
    final result =
        db.select('SELECT * FROM orders WHERE status == ?', [status]);

    return result
        .map((row) => {
              'id': row['id'],
              'text': row['text'],
              'number': row['number'],
              'price': row['price'],
              'create_date': row['create_date'],
              'time': row['time'],
              'endTime': row['endTime']
            })
        .toList();
  }

  // Получение всех записей start
  List<Map<String, dynamic>> getItemsOld(int time) {
    final result = db.select('SELECT * FROM orders WHERE endTime == ?', [time]);

    return result
        .map((row) => {
              'id': row['id'],
              'text': row['text'],
              'number': row['number'],
              'price': row['price'],
              'create_date': row['create_date'],
              'time': row['time'],
              'endTime': row['endTime']
            })
        .toList();
  }

  // Получение всех записей start
  List<Map<String, dynamic>> getItems(
    String date,
  ) {
    final result =
        db.select('SELECT * FROM orders WHERE create_date == ?', [date]);

    return result
        .map((row) => {
              'id': row['id'],
              'text': row['text'],
              'number': row['number'],
              'price': row['price'],
              'create_date': row['create_date'],
              'time': row['time']
            })
        .toList();
  }

  // Обновление записи
  void updateItem(int id, String newStatus, int timer) {
    final stmt =
        db.prepare('UPDATE orders SET status = ?, endTime = ? WHERE id = ?');
    stmt.execute([newStatus, timer, id]);
    stmt.dispose();
  }

  // Удаление записи
  void deleteItem(int id) {
    final stmt = db.prepare('DELETE FROM orders WHERE id = ?');
    stmt.execute([id]);
    stmt.dispose();
  }

  // Метод для удаления claer
  void clearProduct() {
    db.execute('DELETE FROM cart; VACUUM;');
  }

  // Метод для удаления claer
  void clearOrders() {
    db.execute('DELETE FROM orders; VACUUM;');
  }

  // Закрытие базы данных
  void close() {
    db.dispose();
  }
}
