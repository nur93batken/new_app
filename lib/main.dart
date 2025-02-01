import 'package:flutter/material.dart';
import 'package:new_app/pages/homepage.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  // Инициализируем локаль
  await initializeDateFormatting('ru_RU', null);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shaurmaster 24/7',
      home: Home(),
    );
  }
}
