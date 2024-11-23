import 'package:flutter/material.dart';
import 'package:new_app/helpers/database_helper_expenses.dart';
import 'package:intl/intl.dart';
import 'package:new_app/helpers/database_helper_my_expenses.dart';

class ExpensesAdminScreen extends StatefulWidget {
  @override
  _ExpensesAdminScreen createState() => _ExpensesAdminScreen();
}

class _ExpensesAdminScreen extends State<ExpensesAdminScreen> {
  final DatabaseHelperExpenses dbHelper = DatabaseHelperExpenses();
  final DatabaseHelperMyExpenses dbExpensesHelper = DatabaseHelperMyExpenses();
  final TextEditingController textController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> myitems = [];
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
  }

  void _addMyItem(String name, String dateNow, int price) {
    dbExpensesHelper.insertMyItem(name, dateNow, price);
    _loadMyItems();
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
          title: Text('Чыгаша'),
        ),
        body: Row(
          children: [
            Container(
              width: 400,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
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
                          _addItem(name, dateNow, price);
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
                              tileColor:
                                  const Color.fromARGB(255, 183, 242, 253),
                              title: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item['title']),
                                  Text('${item['create_date']} сом'),
                                ],
                              ),
                              subtitle: Text('Дата: ${item['price']}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.check_box_outlined,
                                      color: Colors.green,
                                    ),
                                    onPressed: () {
                                      _addMyItem(item['title'], item['price'],
                                          int.parse(item['create_date']));
                                      _deleteItem(item['id']);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.green,
                                    ),
                                    onPressed: () {
                                      _showUpdateDialog(
                                          item['id'],
                                          item['title'],
                                          int.parse(item['create_date']));
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
            Container(
              width: 400,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Чыгашаларды эсептөө',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                            onPressed: () {
                              clearTabel();
                            },
                            child: Text('Өчүрүү')),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: myitems.length,
                        itemBuilder: (context, index) {
                          final item = myitems[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: ListTile(
                              tileColor:
                                  const Color.fromARGB(255, 239, 253, 183),
                              title: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item['title']),
                                  Text('${item['create_date']} сом'),
                                ],
                              ),
                              subtitle: Text('Дата: ${item['price']}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      _addItem(item['title'], item['price'],
                                          int.parse(item['create_date']));
                                      _deleteMyItem(item['id']);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Text(
                      'Жалпы чыгаша: $allprice сом',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.red),
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
