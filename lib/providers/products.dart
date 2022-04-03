import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shopping_app/providers/product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  List<Product> get getAllProducts {
    return [..._items];
  }

  List<Product> get getFavoriteProducts {
    return _items.where((product) => product.isFavorite).toList();
  }

  Product getProductById(String id) {
    return _items.firstWhere((product) => product.id == id);
  }

  Future<void> fetchAndSetProducts() async {
    if (_items.isNotEmpty) {
      return;
    }
    final url = Uri.parse(
        'https://shopping-app-flutter-ee2b9-default-rtdb.firebaseio.com/products.json');
    try {
      final response = await http.get(url).timeout(
            const Duration(seconds: 10),
          );
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];
      extractedData.forEach((productId, productData) {
        loadedProducts.insert(
            0,
            Product(
              id: productId,
              title: productData['title'],
              description: productData['description'],
              price: productData['price'],
              isFavorite: productData['isFavorite'],
              imageUrl: productData['imageUrl'],
            ));
      });
      _items = loadedProducts;
      notifyListeners();
    } on TimeoutException {
      throw Exception('Slow internet connection, try again later');
    } catch (exception) {
      rethrow;
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.parse(
        'https://shopping-app-flutter-ee2b9-default-rtdb.firebaseio.com/products.json');
    try {
      final response = await http
          .post(url,
              body: json.encode({
                'title': product.title,
                'description': product.description,
                'imageUrl': product.imageUrl,
                'price': product.price,
                'isFavorite': product.isFavorite,
              }))
          .timeout(const Duration(seconds: 10));
      final newProduct = Product(
        id: json.decode(response.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );
      _items.insert(0, newProduct);
      notifyListeners();
    } on TimeoutException {
      throw Exception('Slow internet connection, try again later');
    } catch (exception) {
      rethrow;
    }
    // .catchError((error) {
    //   throw error;
    // }).timeout(const Duration(seconds: 10), onTimeout: () {
    //   throw TimeoutException('Slow internet connection, try again later.');
    // });
  }

  Future<void> updateProduct(String productId, Product newProduct) async {
    final oldProductIndex =
        _items.indexWhere((product) => product.id == productId);

    if (oldProductIndex >= 0) {
      final url = Uri.parse(
          'https://shopping-app-flutter-ee2b9-default-rtdb.firebaseio.com/products/$productId.json');
      try {
        await http
            .patch(url,
                body: json.encode({
                  'title': newProduct.title,
                  'description': newProduct.description,
                  'price': newProduct.price,
                  'imageUrl': newProduct.imageUrl,
                }))
            .timeout(const Duration(seconds: 10));
        _items[oldProductIndex] = newProduct;
        notifyListeners();
      } on TimeoutException {
        throw Exception('Slow internet connection, try again later');
      } catch (exception) {
        rethrow;
      }
    }
  }

  Future<void> deleteProduct(String productId) async {
    final url = Uri.parse(
        'https://shopping-app-flutter-ee2b9-default-rtdb.firebaseio.com/products/$productId.json');

    try {
      final response =
          await http.delete(url).timeout(const Duration(seconds: 10));
      if (response.statusCode >= 400) {
        throw Exception(
            'Something went wrong try again later. Status Code: ${response.statusCode}');
      }
      _items.removeWhere((product) => product.id == productId);
    } on TimeoutException {
      throw Exception('Slow internet connection, try again later.');
    } catch (exception) {
      rethrow;
    }
    notifyListeners();
  }
}
