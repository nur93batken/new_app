import 'package:flutter/material.dart';
import 'package:new_app/helpers/database_helper_expenses.dart';
import 'package:intl/intl.dart';

class ExpensesScreen extends StatefulWidget {
  @override
  _ExpensesScreen createState() => _ExpensesScreen();
}

class _ExpensesScreen extends State<ExpensesScreen> {
  final DatabaseHelperExpenses dbHelper = DatabaseHelperExpenses();
  final TextEditingController textController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController textProductController = TextEditingController();
  final TextEditingController priceProductController = TextEditingController();
  final TextEditingController countController = TextEditingController();
  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> prihod = [];
  DateTime now = DateTime.now();
  String dateNow = '';
  int allprice = 0;

  Future<void> fetchAndCalculateTotalOrderPrice() async {
    int calculatedTotalPrice = 0;
    try {
      // ignore: prefer_typing_uninitialized_variables
      var item;
      for (item in items) {
        calculatedTotalPrice += int.parse(item['create_date']);
      }

      setState(() {
        allprice = calculatedTotalPrice;
      });
    } catch (e) {
      print('Ошибка при получении данных: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadItems();
    fetchAndCalculateTotalOrderPrice();
  }

  void _loadItems() {
    setState(() {
      items = dbHelper.getNowItems();
      fetchAndCalculateTotalOrderPrice();
    });
  }

  void _addItem(String name, String dateNow, int price) {
    dbHelper.insertItem(name, dateNow, price);
    _loadItems();
    textController.clear();
    priceController.clear();
  }

  void _deleteItem(int id) {
    dbHelper.deleteItem(id);
    _loadItems();
  }

  @override
  void dispose() {
    dbHelper.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 400,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text('Чыгашалар'),
                TextField(
                  controller: textController,
                  decoration:
                      const InputDecoration(labelText: 'Чыгашанын аталышы'),
                ),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Баасы'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    String name = textController.text;
                    dateNow = DateFormat('yyyy-MM-dd').format(now);
                    int price = int.parse(priceController.text);
                    if (name.isNotEmpty) {
                      _addItem(name, 'new', price);
                    }
                  },
                  child: Text('Сактоо'),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Divider(
                  color: Colors.black, // Цвет линии
                  thickness: 1,
                ),
                const SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: ListTile(
                          tileColor: const Color.fromARGB(255, 183, 242, 253),
                          title: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['title']),
                              Text('${item['create_date']} сом'),
                            ],
                          ),
                          subtitle: Text('Статус: ${item['price']}'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ));
  }
}
