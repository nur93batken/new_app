import 'package:flutter/material.dart';
import 'package:new_app/pages/crud.dart';
import 'package:new_app/pages/homepage.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreen createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {
  bool _isObscured = true; // начальное состояние для скрытия пароля
  final TextEditingController _controllerLogin = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.greenAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Image.asset(
                      'assets/burgers.png',
                      width: 200,
                    ),
                    const Text(
                      "Тиркемеге кирүү",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      width: 500,
                      child: TextField(
                        controller: _controllerLogin,
                        decoration: InputDecoration(
                          hintText: 'Логин',
                          filled: true,
                          fillColor: Colors.white70,
                          prefixIcon: const Icon(
                            Icons.person,
                            size: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: 500,
                      child: TextField(
                        controller: _controllerPassword,
                        obscureText:
                            _isObscured, // управление показом/скрытием пароля
                        decoration: InputDecoration(
                          hintText: 'Сыр сөзүңүз',
                          filled: true,
                          fillColor: const Color.fromRGBO(255, 255, 255, 0.702),
                          prefixIcon: const Icon(
                            Icons.lock,
                            size: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isObscured
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              size: 18,
                            ),
                            onPressed: () {
                              setState(() {
                                _isObscured =
                                    !_isObscured; // переключение состояния
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (_controllerLogin.text == 'shaurma' &&
                            _controllerPassword.text == '123456') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ItemScreen()),
                          );
                        } else {
                          _controllerLogin.clear();
                          _controllerPassword.clear();
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Логин же пароль туура эмес!')));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: const Size(500, 55), // Button color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                      ),
                      child: const Text(
                        'Кирүү',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextButton(
                        onPressed: () {
                          Navigator.pop(
                            context,
                            MaterialPageRoute(builder: (context) => Home()),
                          );
                        },
                        child: Text('Артка'))
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
