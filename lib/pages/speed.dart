import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class SpeechScreen extends StatefulWidget {
  @override
  _SpeechScreenState createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  FlutterTts flutterTts = FlutterTts();

  Future<void> _speak(String text) async {
    await flutterTts.setLanguage("ru-RU"); // Установка русского языка
    await flutterTts.setPitch(1.0); // Установка высоты голоса
    await flutterTts.speak(text); // Озвучка текста
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController textController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('Озвучить текст'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: textController,
              decoration: InputDecoration(
                labelText: 'Введите текст для озвучки',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String text = textController.text;
                if (text.isNotEmpty) {
                  _speak(
                      "Клиент №$text, ваш заказ готов!"); // Озвучить введённый текст
                }
              },
              child: Text('Озвучить'),
            ),
          ],
        ),
      ),
    );
  }
}
