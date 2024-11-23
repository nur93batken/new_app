import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:new_app/pages/products.dart';

class CategoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            top: 30,
            right: 16,
            left: 16,
            bottom: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: VeganBowlCard(
                        image: 'assets/shaurma.png',
                        label: 'Шаурма',
                        counter: '20',
                        color: Colors.redAccent,
                        category: 'shaurma',
                      ),
                    ),
                    SizedBox(width: 20),
                    Flexible(
                      child: VeganBowlCard(
                        image: 'assets/burgers.png',
                        label: 'Бургер',
                        counter: '6',
                        color: Colors.green,
                        category: 'burgers',
                      ),
                    ),
                    SizedBox(width: 20),
                    Flexible(
                      child: VeganBowlCard(
                        image: 'assets/pizzas.png',
                        label: 'Писса',
                        counter: '10',
                        color: Colors.blueAccent,
                        category: 'pizzas',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: VeganBowlCard(
                        image: 'assets/chickens.png',
                        label: 'Крылышки',
                        counter: '20',
                        color: Colors.brown,
                        category: 'chickens',
                      ),
                    ),
                    SizedBox(width: 20),
                    Flexible(
                      child: VeganBowlCard(
                        image: 'assets/hotdogs.png',
                        label: 'Ход-дог',
                        counter: '6',
                        color: Colors.yellowAccent,
                        category: 'hotdogs',
                      ),
                    ),
                    SizedBox(width: 20),
                    Flexible(
                      child: VeganBowlCard(
                        image: 'assets/juices.png',
                        label: 'Суусундуктар',
                        counter: '10',
                        color: Colors.amberAccent,
                        category: 'juices',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class VeganBowlCard extends StatelessWidget {
  final String image;
  final String label;
  final String counter;
  final Color color;
  final String category;

  const VeganBowlCard({
    Key? key,
    required this.image,
    required this.label,
    required this.counter,
    required this.color,
    required this.category,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ProductScreen(
                    userId: category,
                    categoryimage: 'assets/' + category + '.png',
                  )),
        );
      },
      child: ZoomIn(
        duration: const Duration(seconds: 1),
        child: Stack(
          clipBehavior:
              Clip.none, // Чтобы часть изображения находилась вне контейнера
          children: [
            Container(
              width: 300,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: color.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(width: 8),
                      Text(
                        label,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '🔥',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_right,
                          size: 22,
                          color: Colors.white,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: -35, // Для размещения изображения поверх контейнера
              right: 10,
              child: Image.asset(
                image,
                width: 200,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
