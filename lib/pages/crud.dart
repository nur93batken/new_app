import 'package:flutter/material.dart';
import 'package:new_app/helpers/database_helper.dart';
import 'package:new_app/pages/admin_expenses.dart';
import 'package:new_app/pages/expenses_admin.dart';

class ItemScreen extends StatefulWidget {
  @override
  _ItemScreenState createState() => _ItemScreenState();
}

class _ItemScreenState extends State<ItemScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  final TextEditingController textController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  List<Map<String, dynamic>> items = [];
  String? selectedValue; // Выбранное значение
  final List<String> itemsCategories = [
    'shaurma',
    'burgers',
    'hotdogs',
    'chickens',
    'juices',
    'pizzas'
  ]; // Варианты меню

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() {
    setState(() {
      items = dbHelper.getAllItems();
    });
  }

  void _addItem(String name, int price, String category) {
    dbHelper.insertItem(name, price, category);
    _loadItems();
    textController.clear();
  }

  void _updateItem(int id, String newName, int price, String category) {
    dbHelper.updateItem(id, newName, price, category);
    _loadItems();
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
      appBar: AppBar(
        title: Text('Shaurmaster 24/7'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(
              right: 0,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.ad_units,
                size: 22,
                color: Colors.blue,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AdminExpensesScreen()),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              right: 0,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.money,
                size: 22,
                color: Colors.red,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ExpensesAdminScreen()),
                );
              },
            ),
          ),
        ],
      ),
      body: Center(
        child: Container(
          width: 600,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                DropdownButton<String>(
                  hint: Text("Выберите Категория"),
                  value: selectedValue,
                  items: itemsCategories.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedValue = newValue;
                    });
                  },
                ),
                TextField(
                  controller: textController,
                  decoration: InputDecoration(labelText: 'Продуктанын аталышы'),
                ),
                TextField(
                  controller: priceController,
                  decoration: InputDecoration(labelText: 'Баасы'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    String name = textController.text;
                    int price = int.parse(priceController.text);
                    String? category = selectedValue;
                    if (name.isNotEmpty) {
                      _addItem(name, price, category!);
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
                              Text(
                                item['category'].toString(),
                                style: const TextStyle(color: Colors.red),
                              ),
                              Text(item['title']),
                              Text('${item['price']} сом'),
                            ],
                          ),
                          subtitle: Text('ID: ${item['id']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.green,
                                ),
                                onPressed: () {
                                  _showUpdateDialog(item['id'], item['title'],
                                      item['price'], item['category']);
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  _deleteItem(item['id']);
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
      ),
    );
  }

  void _showUpdateDialog(
      int id, String currentName, int price, String category) {
    final updateController = TextEditingController(text: currentName);
    final updatePriceController = TextEditingController(text: price.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Өзгөртүү'),
          content: Column(
            children: [
              TextField(
                controller: updateController,
                decoration: const InputDecoration(labelText: 'Enter new name'),
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
                int price = int.parse(updatePriceController.text);
                if (newName.isNotEmpty) {
                  _updateItem(id, newName, price, category);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Сактоо'),
            ),
          ],
        );
      },
    );
  }
}
