import 'package:flutter/material.dart';
import 'package:new_app/helpers/database_helper_expenses.dart';
import 'package:intl/intl.dart';
import 'package:new_app/helpers/database_helper_my_expenses.dart';
import 'package:new_app/helpers/database_helper_prihod.dart';

class AdminExpensesScreen extends StatefulWidget {
  @override
  _AdminExpensesScreen createState() => _AdminExpensesScreen();
}

class _AdminExpensesScreen extends State<AdminExpensesScreen> {
  final DatabaseHelperExpenses dbHelper = DatabaseHelperExpenses();
  final DatabaseHelperMyExpenses dbExpensesHelper = DatabaseHelperMyExpenses();
  final DatabaseHelperPrihod dbPrihodHelper = DatabaseHelperPrihod();
  final TextEditingController textController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController textProductController = TextEditingController();
  final TextEditingController priceProductController = TextEditingController();
  final TextEditingController countController = TextEditingController();
  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> myitems = [];
  List<Map<String, dynamic>> prihod = [];
  DateTime now = DateTime.now();
  String dateNow = '';
  int allprice = 0;

  Future<void> fetchAndCalculateTotalOrderPrice() async {
    int calculatedTotalPrice = 0;
    try {
      // ignore: prefer_typing_uninitialized_variables
      var item;
      for (item in myitems) {
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
    _loadMyItems();
    fetchAndCalculateTotalOrderPrice();
  }

  void clearTabel() {
    setState(() {
      if (allprice > 0) {
        dbExpensesHelper.clearItem();
        _loadItems();
        _loadMyItems();
        fetchAndCalculateTotalOrderPrice();
      }
    });
  }

  void _loadItems() {
    setState(() {
      items = dbHelper.getAllItems();
      prihod = dbPrihodHelper.getItems();
      fetchAndCalculateTotalOrderPrice();
    });
  }

  void _loadMyItems() {
    setState(() {
      myitems = dbExpensesHelper.getAllItems();
      fetchAndCalculateTotalOrderPrice();
    });
  }

  void _addItem(String name, String dateNow, int price) {
    dbHelper.insertItem(name, dateNow, price);
    _loadItems();
    textController.clear();
    priceController.clear();
  }

  void _addMyItem(String name, String dateNow, int price) {
    dbExpensesHelper.insertMyItem(name, dateNow, price);
    _loadMyItems();
  }

  void _addItemPrihod(String title, int price, int count) {
    dbPrihodHelper.insertItem(title, price, count);
    _loadItems();
    textProductController.clear();
    priceProductController.clear();
    countController.clear();
  }

  void _updateItem(int id, String newName, String create_date, int price) {
    dbHelper.updateItem(id, newName, create_date, price);
    _loadItems();
  }

  void _deleteItem(int id) {
    dbHelper.deleteItem(id);
    _loadItems();
  }

  void _deleteMyItem(int id) {
    dbExpensesHelper.deleteItem(id);
    _loadMyItems();
  }

  @override
  void dispose() {
    dbHelper.close();
    dbExpensesHelper.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Товарлар'),
        ),
        body: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 400,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: textProductController,
                      decoration:
                          const InputDecoration(labelText: 'Товардын аталышы'),
                    ),
                    TextField(
                      controller: priceProductController,
                      decoration: const InputDecoration(labelText: 'Баасы'),
                    ),
                    TextField(
                      controller: countController,
                      decoration: const InputDecoration(labelText: 'Саны'),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        String title = textProductController.text;
                        int price = int.parse(priceProductController.text);
                        int count = int.parse(countController.text);
                        if (title.isNotEmpty) {
                          _addItemPrihod(title, price, count);
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
                        itemCount: prihod.length,
                        itemBuilder: (context, index) {
                          final item = prihod[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: ListTile(
                              tileColor:
                                  const Color.fromARGB(255, 183, 242, 253),
                              title: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      '${item['title']} - ${item['price']} сом'),
                                ],
                              ),
                              subtitle: Text('${item['count']} штук'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      dbPrihodHelper.deleteItem(item['id']);
                                      _loadItems();
                                      _loadMyItems();
                                      fetchAndCalculateTotalOrderPrice();
                                    },
                                  ),
                                ],
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
          ],
        ));
  }

  void _showUpdateDialog(int id, String currentName, int price) {
    final updateController = TextEditingController(text: currentName);
    final updatePriceController = TextEditingController(text: price.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Чыгашаны өзгөртүү'),
          content: Column(
            children: [
              TextField(
                controller: updateController,
                decoration: const InputDecoration(labelText: 'Enter new title'),
              ),
              TextField(
                controller: updatePriceController,
                decoration: const InputDecoration(labelText: 'Enter new price'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                String newName = updateController.text;
                dateNow = DateFormat('yyyy-MM-dd').format(now);
                int price = int.parse(updatePriceController.text);
                if (newName.isNotEmpty) {
                  _updateItem(id, newName, dateNow, price);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Өзгөртүү'),
            ),
          ],
        );
      },
    );
  }
}
