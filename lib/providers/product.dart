import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });

  Future<void> toggleFavorite(String authToken, String userId) async {
    final url = Uri.parse(
        'https://shopping-app-flutter-ee2b9-default-rtdb.firebaseio.com/userFavorites/$userId/$id.json?auth=$authToken');
    final oldFavoriteStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    try {
      final response = await http.put(
        url,
        body: json.encode(isFavorite),
      );
      if (response.statusCode >= 400) {
        isFavorite = oldFavoriteStatus;
      }
    } catch (exception) {
      print(exception.toString());
      isFavorite = oldFavoriteStatus;
    }
  }
}
