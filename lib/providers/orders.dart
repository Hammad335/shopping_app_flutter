import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:shopping_app/providers/cart.dart' as cart;
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderItem {
  final String orderId;
  final double amount;
  final List<cart.CartItem> cartItems;
  final DateTime dateTime;

  OrderItem({
    required this.orderId,
    required this.amount,
    required this.cartItems,
    required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> orders = [];
  final String? authToken;

  Orders({this.authToken, required this.orders});

  List<OrderItem> get getOrderItems {
    return [...orders];
  }

  Future<void> addOrder(List<cart.CartItem> cartItems, double total) async {
    final url = Uri.parse(
        'https://shopping-app-flutter-ee2b9-default-rtdb.firebaseio.com/orders.json?auth=$authToken');
    final timeStamp = DateTime.now();
    final response = await http
        .post(url,
            body: json.encode({
              'amount': total,
              'dateTime': timeStamp.toIso8601String(),
              'products': cartItems.map((cartItem) {
                return {
                  'id': cartItem.id,
                  'title': cartItem.title,
                  'quantity': cartItem.quantity,
                  'price': cartItem.price,
                };
              }).toList()
            }))
        .timeout(const Duration(seconds: 8), onTimeout: () {
      throw Exception('Slow internet connection, try again later');
    });

    orders.insert(
      0,
      OrderItem(
        orderId: json.decode(response.body)['name'],
        amount: total,
        cartItems: cartItems,
        dateTime: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  Future<void> fetchAndSetOrders() async {
    if (orders.isNotEmpty) {
      return;
    }
    final url = Uri.parse(
        'https://shopping-app-flutter-ee2b9-default-rtdb.firebaseio.com/orders.json?auth=$authToken');
    final response =
        await http.get(url).timeout(const Duration(seconds: 8), onTimeout: () {
      throw Exception('Slow internet connection, try again later');
    });
    List<OrderItem> loadedOrders = [];
    var extractedData = json.decode(response.body) as Map<String, dynamic>;
    if (extractedData == null) {
      return;
    }
    extractedData.forEach(
      (orderId, orderData) {
        loadedOrders.add(
          OrderItem(
            orderId: orderId,
            amount: orderData['amount'].toDouble(),
            dateTime: DateTime.parse(orderData['dateTime']),
            cartItems: (orderData['products'] as List<dynamic>)
                .map(
                  (cartItem) => cart.CartItem(
                    id: cartItem['id'],
                    title: cartItem['title'],
                    quantity: cartItem['quantity'],
                    price: cartItem['price'].toDouble(),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
    orders = loadedOrders.reversed.toList();
    notifyListeners();
  }
}
