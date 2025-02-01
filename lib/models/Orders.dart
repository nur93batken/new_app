class Order {
  final int id;
  final String text;
  final int number;
  final String createDate;
  final String time;
  final double price;
  int remainingTime; // Оставшееся время в миллисекундах

  Order({
    required this.id,
    required this.text,
    required this.number,
    required this.createDate,
    required this.time,
    required this.price,
    required this.remainingTime,
  });
}
