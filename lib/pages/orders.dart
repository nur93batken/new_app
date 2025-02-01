import 'package:flutter/material.dart';
import 'package:new_app/helpers/database_helper_cart.dart';
import 'package:intl/intl.dart';
import 'package:new_app/helpers/database_helper_orders.dart';
import 'package:new_app/helpers/database_helper_repotrs.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreen createState() => _OrdersScreen();
}

class _OrdersScreen extends State<OrdersScreen> {
  final DatabaseHelperCart dbHelper = DatabaseHelperCart();
  final DatabaseHelperOrders dbHelperOrders = DatabaseHelperOrders();
  final DatabaseReportHelper dbHelperReports = DatabaseReportHelper();
  List<Map<String, dynamic>> items = [];
  DateTime now = DateTime.now();
  double totalOrderPrice = 0.0;
  String textOrder = '';
  String dateNow = '';
  String timeNow = '';
  int counter = 0;
  String txtPrint = '';
  String txtPrice = '';
  String txtDade = '';
  int sale = 0;
  String txtSale = 'Скидка 0%';

  Future<void> updateID() async {
    try {
      items = dbHelper.getItems();
      var item;
      for (item in items) {
        dbHelperReports.updateIdProduct(
            item['id_product'], item['title'], item['price'], 1);
      }
    } catch (e) {
      print('Ошибка при получении данных: $e');
    }
  }

  Future<void> fetchAndCalculateTotalOrderPrice() async {
    double calculatedTotalPrice = 0.0;
    String txt = '';
    dateNow = DateFormat('yyyy-MM-dd').format(now);
    try {
      // Обновляем состояние и UI
      List<Map<String, dynamic>> orders = DatabaseHelperCart().getItems();
      List<Map<String, dynamic>> allOrders =
          DatabaseHelperOrders().getItems(dateNow);
      // ignore: prefer_typing_uninitialized_variables
      var item;
      // ignore: unused_local_variable
      var itemO;
      var count = 1;
      for (item in orders) {
        calculatedTotalPrice += item['price'];
        txt += item['title'] + ' - ' + item['price'].toString() + 'сом' + '\n';
      }
      for (itemO in allOrders) {
        count += 1;
      }

      setState(() {
        totalOrderPrice =
            calculatedTotalPrice - ((calculatedTotalPrice / 100) * sale);
        textOrder = txt;
        timeNow = DateFormat('kk:mm').format(now);
        dateNow = DateFormat('yyyy-MM-dd').format(now);
        txtPrint = 'Shaurmaster 24/7 \n\n$txt\n';
        txtPrice = 'Итог: $totalOrderPrice сом\n';
        txtDade = '$dateNow - $timeNow';
        if (count > 400) {
          counter = count - 400;
        } else if (count > 300) {
          counter = count - 300;
        } else if (count > 200) {
          counter = count - 200;
        } else if (count > 100) {
          counter = count - 100;
        } else {
          counter = count;
        }
      });
      print(totalOrderPrice);
    } catch (e) {
      print('Ошибка при получении данных: $e');
    }
  }

  Future<void> printPdfToTwoPrinters(String txtPrint, String txtPrice,
      String txtDate, int number, String txtSale) async {
    final pdf = pw.Document();
    fetchAndCalculateTotalOrderPrice();

    // Загрузите шрифты
    final fontData =
        await rootBundle.load('assets/fonts/RobotoSerif_Black.ttf');
    final ttf = pw.Font.ttf(fontData.buffer.asByteData());
    final fontData1 =
        await rootBundle.load('assets/fonts/RobotoSerif_Regular.ttf');
    final ttf1 = pw.Font.ttf(fontData1.buffer.asByteData());

    // Добавляем страницу с текстом
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text(
                '№ заказа - $number',
                style: pw.TextStyle(
                  font: ttf,
                  fontSize: 14,
                ),
              ),
              pw.Text(
                txtPrint,
                style: pw.TextStyle(
                  font: ttf1,
                  fontSize: 8,
                ),
              ),
              pw.Text(
                txtSale,
                style: pw.TextStyle(
                  font: ttf,
                  fontSize: 14,
                ),
              ),
              pw.Text(
                txtPrice,
                style: pw.TextStyle(
                  font: ttf,
                  fontSize: 14,
                ),
              ),
              pw.Text(
                txtDate,
                style: pw.TextStyle(
                  font: ttf1,
                  fontSize: 8,
                ),
              ),
            ],
          );
        },
      ),
    );

    // Печать PDF на два принтера
    await Future.wait([
      Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
      ),
      Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
      ),
    ]);
  }

  @override
  void initState() {
    super.initState();
    _loadItems();
    // Форматируем дату, чтобы получить название дня недели
    String dayName = DateFormat('EEEE', 'ru_RU').format(now);
    setState(() {
      if (dayName == '12') {
        sale = 10;
        txtSale = 'Скидка 10%';
        fetchAndCalculateTotalOrderPrice();
      }
    });
  }

  void _loadItems() {
    setState(() {
      items = dbHelper.getItems();
      fetchAndCalculateTotalOrderPrice();
    });
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
        title: const Text('Алынган товарлар'),
      ),
      body: Center(
        child: SizedBox(
          width: 500,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ListTile(
                        title: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['title']),
                            Text('${item['price']} сом'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
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
                      );
                    },
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'Жалпы сумма',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                Text(
                  '$totalOrderPrice сом',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    fontSize: 30,
                  ),
                ),
                const SizedBox(
                  height: 6,
                ),
                Center(
                  child: SizedBox(
                    width: 500,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          minimumSize: const Size(220, 55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        onPressed: () {
                          int currentTime =
                              DateTime.now().millisecondsSinceEpoch;
                          int timerDuration = 900 * 1000;
                          int endTime = currentTime + timerDuration;
                          fetchAndCalculateTotalOrderPrice();
                          printPdfToTwoPrinters(
                              txtPrint, txtPrice, txtDade, counter, txtSale);
                          dbHelperOrders.insertItem(
                              textOrder,
                              'start',
                              counter.toString(),
                              dateNow,
                              timeNow,
                              totalOrderPrice,
                              endTime);
                          updateID();
                          dbHelperOrders.clearProduct();
                          _loadItems();
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                            SizedBox(width: 20),
                            Text(
                              "Заказды алуу",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
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
