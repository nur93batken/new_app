import 'package:flutter/material.dart';
import 'package:new_app/helpers/database_helper_orders.dart';
import 'package:intl/intl.dart';
import 'package:new_app/pages/repotrs.dart';

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
  int old = 0;

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

      List<Map<String, dynamic>> olders = DatabaseHelperOrders().getItemsOld(0);

      setState(() {
        totalOrderPrice = calculatedTotalPrice;
        counter = count;
        old = olders.length;
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

  String _formatRemainingTime(int remainingTime) {
    if (remainingTime <= 0) return "Время истекло"; // Если время истекло

    Duration duration = Duration(milliseconds: remainingTime);

    // Преобразуем в формат: "минуты:секунды"
    String minutes = duration.inMinutes.toString();
    String seconds = (duration.inSeconds % 60)
        .toString()
        .padLeft(2, '0'); // Дополняем нулями до двух символов
    int minutes1 = 15 - int.parse(minutes);
    int minutes2 = 60 - int.parse(seconds);
    return "$minutes1 мүнөт : $minutes2 секунд";
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
        child: SizedBox(
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
                          //_clearItems();
                          //_loadItems();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ReportsScreen()),
                          );
                        },
                        child: const Text('Отчет түзүү')),
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
                        onTap: () {},
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
                                Text(
                                  'Даяр болгон убактысы: ${_formatRemainingTime(item['endTime'])}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
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
