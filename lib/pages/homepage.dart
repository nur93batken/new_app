import 'package:flutter/material.dart';
import 'package:new_app/pages/categories.dart';
import 'package:new_app/pages/expenses.dart';
import 'package:new_app/pages/login.dart';
import 'package:new_app/pages/orders.dart';
import 'package:new_app/pages/ordersend.dart';
import 'package:new_app/pages/ordersstart.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _GroceryMarketScreenState();
}

class Product {
  int price;
  Product({required this.price});
}

class _GroceryMarketScreenState extends State<Home> {
  int _selectedIndex = 0;

  // Список экранов для отображения
  final List<Widget> _screens = [
    Screen1(),
    Screen2(),
    Screen3(),
    Screen4(),
  ];

  // Метод для обработки смены экрана
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Shaurmaster 24/7",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.blue,
          ),
        ),
        actions: [
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
                  MaterialPageRoute(builder: (context) => OrdersScreen()),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              right: 16,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.person,
                size: 22,
                color: Colors.blue,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
            ),
          ),
        ],
      ),

      //end
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/homepage.png',
              width: 32,
            ),
            label: 'Башкы бет',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/money.png',
              width: 32,
            ),
            label: 'Алынган заказдар',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/moneyyours.png',
              width: 32,
            ),
            label: 'Бүгүнкү заказдар',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/moneyyours.png',
              width: 32,
            ),
            label: 'Бүгүнкү чыгымдар',
          ),
        ],
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String image;
  final String label;
  final Color color;

  const CategoryCard({
    Key? key,
    required this.image,
    required this.label,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {},
          child: Container(
            width: 100,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Positioned(
                  top: -35,
                  child: Image.asset(
                    image,
                    width: 60,
                  ),
                ),
                Text(label,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ProductCard extends StatelessWidget {
  final String name;
  final String description;
  final String imageUrl;
  final String price;

  const ProductCard({
    Key? key,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.white,
      customBorder: Border.all(color: Colors.white),
      borderRadius: BorderRadius.circular(22),
      onTap: () {},
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        shadowColor: Colors.blueAccent,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Image.asset(
                  imageUrl, // Здесь можно вставить URL вашего изображения
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.add,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Screen4 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ExpensesScreen();
  }
}

class Screen2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OrdersStartScreen();
  }
}

class Screen1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CategoryScreen();
  }
}

class Screen3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OrdersEndScreen();
  }
}
