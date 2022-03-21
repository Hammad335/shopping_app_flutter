import 'package:flutter/foundation.dart';
import 'package:shopping_app/providers/cart.dart';

class OrderItem {
  final String orderId;
  final double amount;
  final List<CartItem> cartItems;
  final DateTime dateTime;

  OrderItem({
    required this.orderId,
    required this.amount,
    required this.cartItems,
    required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get getOrderItems {
    return [..._orders];
  }

  void addOrder(List<CartItem> cartItems, double total) {
    _orders.insert(
      0,
      OrderItem(
        orderId: DateTime.now().toString(),
        amount: total,
        cartItems: cartItems,
        dateTime: DateTime.now(),
      ),
    );
    notifyListeners();
  }
}
