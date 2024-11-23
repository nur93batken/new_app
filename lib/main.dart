import 'package:flutter/material.dart';
import 'package:new_app/pages/homepage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //debugShowCheckedModeBanner: false,
      title: 'Shaurmaster 24/7',
      home: Home(),
    );
  }
}
