import 'package:flutter/material.dart';
import 'package:new_app/helpers/database_helper.dart';
import 'package:new_app/helpers/database_helper_cart.dart';

class ProductScreen extends StatefulWidget {
  @override
  _ProductScreen createState() => _ProductScreen();

  final String userId;
  final categoryimage;
  ProductScreen({super.key, required this.userId, this.categoryimage});
}

class _ProductScreen extends State<ProductScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  final DatabaseHelperCart cartHelper = DatabaseHelperCart();
  final TextEditingController textController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  List<Map<String, dynamic>> items = [];
  String category = '';

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() {
    setState(() {
      items = dbHelper.getItems(widget.userId);
    });
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
        title: Text('Биздин меню'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5, // количество элементов в строке
                    crossAxisSpacing: 6.0, // отступы по горизонтали
                    mainAxisSpacing: 6.0, // отступы по вертикали
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      title: InkWell(
                        splashColor: Colors.amber,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        onTap: () {
                          cartHelper.insertItem(
                              item['title'], item['price'], item['id']);
                        },
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.asset(
                                  // ignore: prefer_interpolation_to_compose_strings
                                  '${'assets/' + item['category']}.png',
                                  width: 120,
                                ),
                                Text(item['title']),
                                Text(
                                  '${item['price']} сом',
                                  style: const TextStyle(
                                      color: Colors.green,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
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
    );
  }
}
