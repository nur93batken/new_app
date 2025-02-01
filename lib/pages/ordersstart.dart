import 'dart:async';

import 'package:flutter/material.dart';
import 'package:new_app/helpers/database_helper_orders.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';
import 'package:new_app/helpers/database_helper_repotrs.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:new_app/models/Orders.dart';

class OrdersStartScreen extends StatefulWidget {
  @override
  _OrdersStartScreen createState() => _OrdersStartScreen();
}

class _OrdersStartScreen extends State<OrdersStartScreen> {
  final DatabaseHelperOrders dbHelperOrders = DatabaseHelperOrders();
  final DatabaseReportHelper dbHelperReport = DatabaseReportHelper();
  FlutterTts flutterTts = FlutterTts();
  List<Order> items = [];
  DateTime now = DateTime.now();
  String dateNow = '';
  String timeNow = '';
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    dateNow = DateFormat('yyyy-MM-dd').format(now);
    _loadItems();

    // Подписка на событие завершения воспроизведения
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _isPlaying = false; // Обновляем состояние
      });
    });
  }

  Timer? _timer; // Таймер, который будет обновлять оставшееся время

  void _startTimer() {
    // Останавливаем предыдущий таймер, если он есть
    _timer?.cancel();

    // Создаем новый таймер
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        for (var item in items) {
          item.remainingTime -= 1000; // Уменьшаем время на 1 секунду (1000 мс)

          if (item.remainingTime <= 0) {
            item.remainingTime = 0; // Если время истекло, устанавливаем 0
          }
        }
      });
    });
  }

  void _loadItems() async {
    // Получение данных из базы
    final rawItems = await dbHelperOrders.getItemsStart('start');

    setState(() {
      items = rawItems.map((item) {
        int endTime =
            item['endTime']; // Время завершения заказа (в миллисекундах)
        int remainingTime = endTime - DateTime.now().millisecondsSinceEpoch;

        // Преобразуем данные в объект Order
        return Order(
          id: item['id'],
          text: item['text'],
          number: int.parse(item['number']),
          createDate: item['create_date'],
          time: item['time'],
          price: double.parse(item['price'].toString()),
          remainingTime: remainingTime > 0
              ? remainingTime
              : 0, // Если время истекло, устанавливаем 0
        );
      }).toList();
    });

    // Запускаем таймер для обновления времени
    _startTimer();
  }

  void _deleteItem(String text) {
    setState(() {
      var items = text.split('\n');
      var i;
      for (i in items) {
        dbHelperReport.updateItemMinus(i);
      }
    });
  }

  void _updateItem(int id, String status, int time) {
    dbHelperOrders.updateItem(id, status, time);
    _loadItems();
  }

  void _playMusic(String path) async {
    _stopMusic();
    if (!_isPlaying) {
      _audioPlayer.seek(const Duration(seconds: 1));
      await _audioPlayer.play(AssetSource(path));

      setState(() {
        _isPlaying = true;
      });
    }
  }

  void _stopMusic() async {
    if (_isPlaying) {
      await _audioPlayer.stop();
      setState(() {
        _isPlaying = false;
      });
    }
  }

  String _formatRemainingTime(int remainingTime) {
    if (remainingTime <= 0) return "Время истекло"; // Если время истекло

    Duration duration = Duration(milliseconds: remainingTime);

    // Преобразуем в формат: "минуты:секунды"
    String minutes = duration.inMinutes.toString();
    String seconds = (duration.inSeconds % 60)
        .toString()
        .padLeft(2, '0'); // Дополняем нулями до двух символов

    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    dbHelperOrders.close();
    _audioPlayer.dispose();
    _timer?.cancel(); // Отменяем таймер
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
                      final Order item = items[index];
                      return InkWell(
                        onTap: () {
                          String path = item.number.toString();
                          if (path.length == 1) {
                            path = '00$path';
                          } else if (path.length == 2) {
                            path = '0$path';
                          } else {
                            path = path;
                          }
                          _isPlaying ? null : _playMusic('music/$path.mp3');
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
                                  '№ - ${item.number} заказ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  item.text,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Жалпы сумма: ${item.price} сом',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  'Заказа убактысы: ${item.createDate} - ${item.time}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '${_formatRemainingTime(item.remainingTime)} мүнөттө даяр болуусу шарт!',
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
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    _deleteItem(item.text);
                                    dbHelperOrders.deleteItem(item.id);
                                    _loadItems();
                                  },
                                ),
                                const SizedBox(
                                  width: 24,
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.check,
                                    color: Colors.green,
                                  ),
                                  onPressed: () {
                                    _updateItem(
                                        item.id, 'end', item.remainingTime);
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
