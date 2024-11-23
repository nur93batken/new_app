import 'package:flutter/material.dart';
import 'package:new_app/helpers/database_helper_orders.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';

class OrdersStartScreen extends StatefulWidget {
  @override
  _OrdersStartScreen createState() => _OrdersStartScreen();
}

class _OrdersStartScreen extends State<OrdersStartScreen> {
  final DatabaseHelperOrders dbHelperOrders = DatabaseHelperOrders();
  List<Map<String, dynamic>> items = [];
  FlutterTts flutterTts = FlutterTts();
  DateTime now = DateTime.now();
  String dateNow = '';
  String timeNow = '';

  Future<void> _speak(String text) async {
    await flutterTts.setLanguage("ru-RU"); // Установка русского языка
    await flutterTts.setPitch(1.2); // Установка высоты голоса
    await flutterTts.speak(text); // Озвучка текста
  }

  @override
  void initState() {
    super.initState();
    dateNow = DateFormat('yyyy-MM-dd').format(now);
    _loadItems();
  }

  String determineShift(String time) {
    // Преобразуем строку времени в объект DateTime для сравнения
    final timeParts = time.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    // Создаем объект DateTime для сравнения
    final currentTime = DateTime(0, 1, 1, hour, minute);

    // Определяем временные рамки для смен
    final startOfDayShift = DateTime(0, 1, 1, 8, 0); // 8:00
    final endOfDayShift = DateTime(0, 1, 1, 20, 0); // 20:00
    final startOfNightShift = DateTime(0, 1, 1, 20, 0); // 20:00
    final endOfNightShift = DateTime(0, 1, 1, 8, 0); // 8:00 следующего дня
    final ofNightShift = DateTime(0, 1, 1, 0, 0); // 0:00 следующего дня

    // Проверяем, в какую смену попадает текущее время
    if (currentTime.isAfter(startOfDayShift) &&
        currentTime.isBefore(endOfDayShift)) {
      return 'Дневная смена';
    } else if (currentTime.isAfter(startOfNightShift) ||
        currentTime.isBefore(ofNightShift)) {
      return 'Ночная смена 1';
    } else if (currentTime.isAfter(ofNightShift) ||
        currentTime.isBefore(endOfNightShift)) {
      return 'Ночная смена 2';
    } else {
      return 'Неизвестная смена';
    }
  }

  void _loadItems() {
    setState(() {
      dateNow = DateFormat('yyyy-MM-dd').format(now);
      timeNow = DateFormat('HH:mm').format(now);
      items = dbHelperOrders.getItemsStart(
        'start',
      );
    });
  }

  void _updateItem(int id, String status) {
    dbHelperOrders.updateItem(id, status);
    _loadItems();
  }

  @override
  void dispose() {
    dbHelperOrders.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 500,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  'Алынган заказдар',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.amberAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return InkWell(
                        onTap: () {
                          String text =
                              "   ,  Клиент №${item['number']}, ваш заказ готов!";
                          if (text.isNotEmpty) {
                            _speak(text); // Озвучить введённый текст
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            tileColor: const Color.fromARGB(255, 253, 190, 183),
                            title: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '№ - ${item['number']} заказ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  item['text'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Жалпы сумма: ${item['price']} сом',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  'Заказа убактысы: ${item['create_date']} - ${item['time']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.check,
                                    color: Colors.green,
                                  ),
                                  onPressed: () {
                                    _updateItem(item['id'], 'end');
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
