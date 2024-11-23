import 'package:flutter/material.dart';
import 'package:new_app/helpers/database_helper_orders.dart';
import 'package:intl/intl.dart';

class OrdersEndScreen extends StatefulWidget {
  @override
  _OrdersEndScreen createState() => _OrdersEndScreen();
}

class _OrdersEndScreen extends State<OrdersEndScreen> {
  final DatabaseHelperOrders dbHelperOrders = DatabaseHelperOrders();
  List<Map<String, dynamic>> items = [];
  DateTime now = DateTime.now();
  String dateNow = '';
  String timeNow = '';
  double totalOrderPrice = 0.0;
  int counter = 0;

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

  Future<void> fetchAndCalculateTotalOrderPrice() async {
    double calculatedTotalPrice = 0.0;
    try {
      // Обновляем состояние и UI
      dateNow = DateFormat('yyyy-MM-dd').format(now);
      timeNow = DateFormat('HH:mm').format(now);
      List<Map<String, dynamic>> orders =
          DatabaseHelperOrders().getItemsStart('end');
      // ignore: prefer_typing_uninitialized_variables
      var item;
      var count = 0;
      for (item in orders) {
        calculatedTotalPrice += item['price'];
        count += 1;
      }

      setState(() {
        totalOrderPrice = calculatedTotalPrice;
        counter = count;
      });
    } catch (e) {
      print('Ошибка при получении данных: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    dateNow = DateFormat('yyyy-MM-dd').format(now);
    dateNow = DateFormat('HH:mm').format(now);
    fetchAndCalculateTotalOrderPrice();
    _loadItems();
  }

  void _loadItems() {
    setState(() {
      dateNow = DateFormat('yyyy-MM-dd').format(now);
      timeNow = DateFormat('HH:mm').format(now);
      items = dbHelperOrders.getItemsStart('end');

      fetchAndCalculateTotalOrderPrice();
    });
  }

  void _clearItems() {
    setState(() {
      dbHelperOrders.clearOrders();
      fetchAndCalculateTotalOrderPrice();
    });
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Бүгүнкү заказдар',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.amberAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                        onPressed: () {
                          _clearItems();
                          _loadItems();
                        },
                        child: const Text('Обнулить')),
                  ],
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
                          print(determineShift('21:10'));
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            tileColor: const Color.fromARGB(255, 183, 253, 223),
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
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  'Жалпы: $counter заказ',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                Text(
                  'Баары $totalOrderPrice сом',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    fontSize: 30,
                  ),
                ),
                const SizedBox(
                  height: 6,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
