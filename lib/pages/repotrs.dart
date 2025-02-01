import 'package:flutter/material.dart';
import 'package:new_app/helpers/database_helper_allrepotrs.dart';
import 'package:new_app/helpers/database_helper_expenses.dart';
import 'package:new_app/helpers/database_helper_orders.dart';
import 'package:new_app/helpers/database_helper_prihod.dart';
import 'package:new_app/helpers/database_helper_repotrs.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;

class ReportsScreen extends StatefulWidget {
  @override
  _ReportsScreen createState() => _ReportsScreen();
}

class _ReportsScreen extends State<ReportsScreen> {
  final DatabaseReportHelper dbHelper = DatabaseReportHelper();
  final DatabaseHelperExpenses dbExpenseHelper = DatabaseHelperExpenses();
  final DatabaseHelperPrihod dbPrihodHelper = DatabaseHelperPrihod();
  final DatabaseHelperOrders dbHelperOrders = DatabaseHelperOrders();
  final DatabaseAllReportHelper dbHelperAllReport = DatabaseAllReportHelper();
  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> expense = [];
  List<Map<String, dynamic>> prihod = [];
  List<Map<String, dynamic>> allreport = [];
  List<Map<String, dynamic>> newexpenses = [];
  List<Map<String, dynamic>> oldorders = [];
  DateTime now = DateTime.now();
  String txt = '';
  int allPrice = 0;
  String txtPrint = 'Отчет - ';
  String dateNow = '';
  int sale = 0;
  String txtSale = 'Скидка 0%';

  @override
  void initState() {
    super.initState();
    _loadItems();
    _allPrice();
    // Форматируем дату, чтобы получить название дня недели
    String dayName = DateFormat('EEEE', 'ru_RU').format(now);
    setState(() {
      if (dayName == '12') {
        sale = 10;
        txtSale = 'Скидка 10%';
      }
    });
  }

  void _loadItems() {
    setState(() {
      items = dbHelper.getAllItems();
      expense = dbPrihodHelper.getItems();
      allreport = dbHelperAllReport.getItems();
      newexpenses = dbExpenseHelper.getNowItems();
      oldorders = dbHelperOrders.getItemsOld(0);
    });
  }

  Future<void> printPdf(
    String txtPrint,
  ) async {
    final pdf = pw.Document();

    // Загрузите шрифт
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
                txtPrint,
                style: pw.TextStyle(
                  font: ttf1,
                  fontSize: 10,
                ),
              ),
            ],
          );
        },
      ),
    );

    // Печать PDF
    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  void _printItems() {
    DateTime now = DateTime.now();
    _loadItems();
    dateNow = DateFormat('yyyy-MM-dd').format(now);
    txtPrint += '$dateNow:\n-------------------------------------\n';
    var i;
    for (i in items) {
      txtPrint +=
          '${i['title']}\nЖалпы: ${i['count']} штук сатылды, ${i['price'] * i['count']} сом\n';
    }
    txtPrint +=
        '************************************\nЖалпы сумма: ${allPrice} сом\n************************************\n';
    txtPrint +=
        'Жыйынтык: ${allPrice - ((allPrice / 100) * sale)}\n************************************\n';
    for (i in expense) {
      var j;
      for (j in allreport) {
        if (i['title'] == j['title']) {
          txtPrint += '${j['title']} - ${j['count']} штук - ${j['text']}\n';
        }
      }
      txtPrint +=
          '${i['title']} - ${i['count']} штук калды\n__________________________________\n';
      txtPrint += 'Чыгашалар:\n';
      var sum = 0;
      for (i in newexpenses) {
        txtPrint += "${i['title']} - ${i['create_date']} сом\n";
        sum += int.parse(i['create_date']);
        dbExpenseHelper.updateItemStatus(i['id'], 'end');
      }
      txtPrint +=
          '------------------------------------\nЖалпы чыгаша: $sum сом';
      var old = 0;
      for (i in oldorders) {
        old += 1;
      }
      txtPrint +=
          'Кечиктирилген заказдар: $old\n------------------------------------\n';
    }
    print(txtPrint);
    printPdf(txtPrint);
    _clearItems();
    _clearAllItems();
  }

  void _allPrice() {
    int calculatedTotalPrice = 0;
    items = dbHelper.getAllItems();

    // ignore: unused_local_variable
    var item;
    for (item in items) {
      calculatedTotalPrice = item['price'] * item['count'];
      setState(() {
        allPrice += calculatedTotalPrice;
      });
    }
  }

  void _addItem(String text, String title, int count) {
    dbHelperAllReport.insertItem(title, text, count);
    _loadItems();
  }

  void _deleteItem(int id) {
    dbHelper.deleteItem(id);
    _loadItems();
  }

  void _clearItems() {
    setState(() {
      dbHelperOrders.clearOrders();
      dbHelper.clearOrders();
      _loadItems();
      _allPrice();
      setState(() {
        allPrice = 0;
      });
    });
  }

  void _clearAllItems() {
    setState(() {
      dbHelperAllReport.clearOrders();
      _loadItems();
      _allPrice();
      setState(() {
        allPrice = 0;
      });
    });
  }

  void _updateReport(int id, int count) {
    dbPrihodHelper.updateItem(id, count);
    _loadItems();
  }

  void _updateMinusReport(int id, int count) {
    dbPrihodHelper.updateMinusItem(id, count);
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
        title: const Text('Shaurmaster 24/7'),
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 300,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Жалпы сатылгандар'),
                      TextButton(
                          onPressed: () {
                            _printItems();
                          },
                          child: const Text('Басып чыгаруу')),
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
                                    '${item['title']}',
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                              subtitle: Text(
                                  'Жалпы: ${item['count']} штук, ${item['price'] * item['count']} сом')),
                        );
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Жалпы киреше: $allPrice сом',
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                  Text(
                    oldorders.length.toString(),
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                  Text(
                    'Жыйынтык: ${allPrice - ((allPrice / 100) * sale)} сом',
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 300,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  const Text('Жалпы товарлар'),
                  const SizedBox(
                    height: 20,
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: expense.length,
                      itemBuilder: (context, index) {
                        final item = expense[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: ListTile(
                            tileColor: const Color.fromARGB(255, 202, 253, 183),
                            title: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${item['title']} - ${item['price']} сом',
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                            subtitle: Text('Жалпы: ${item['count']} штук'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.exposure_minus_1,
                                    color: Colors.green,
                                  ),
                                  onPressed: () {
                                    _showUpdateDialogMinus(item['id'],
                                        item['count'], item['title']);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.plus_one,
                                    color: Colors.green,
                                  ),
                                  onPressed: () {
                                    _showUpdateDialog(item['id'], item['count'],
                                        item['title']);
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
          SizedBox(
            width: 300,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Жалпы отчет'),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: allreport.length,
                      itemBuilder: (context, index) {
                        final item = allreport[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: ListTile(
                            tileColor: const Color.fromARGB(255, 232, 232, 232),
                            title: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${item['text']}',
                                  style: const TextStyle(color: Colors.red),
                                ),
                                Text(
                                  '${item['title']}- ${item['count']} штук',
                                  style: const TextStyle(color: Colors.green),
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
      ),
    );
  }

  void _showUpdateDialog(int id, int count, String title) {
    final updateController = TextEditingController(text: count.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Канча товар келди?'),
          content: Column(
            children: [
              TextField(
                controller: updateController,
                decoration:
                    const InputDecoration(labelText: 'Канча товар келди'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                int count = int.parse(updateController.text);
                if (count > 0) {
                  _updateReport(id, count);
                  _addItem('Келди', title, count);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Сактоо'),
            ),
          ],
        );
      },
    );
  }

  void _showUpdateDialogMinus(int id, int count, String title) {
    final updateController = TextEditingController(text: count.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Канча товар сатылды'),
          content: Column(
            children: [
              TextField(
                controller: updateController,
                decoration:
                    const InputDecoration(labelText: 'Канча товар cатылды'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                int count = int.parse(updateController.text);
                if (count > 0) {
                  _updateMinusReport(id, count);
                  _addItem('Сатылды', title, count);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Сактоо'),
            ),
          ],
        );
      },
    );
  }
}
