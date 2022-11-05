import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/providers/auth.dart';
import 'package:shopping_app/providers/products.dart';

import '../providers/cart.dart';

class ProductDetailsScreen extends StatelessWidget {
  static const routeName = '/product_details_screen';

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context)?.settings.arguments as String;
    final loadedProduct =
        Provider.of<Products>(context, listen: false).getProductById(productId);
    final cart = Provider.of<Cart>(context, listen: false);
    final bool isAdmin = Provider.of<Auth>(context, listen: false).isAdmin();
    return Scaffold(
      floatingActionButton: isAdmin
          ? null
          : FloatingActionButton(
              onPressed: () {
                cart.addItem(
                  loadedProduct.id,
                  loadedProduct.title,
                  loadedProduct.price,
                );
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Item added to cart!',
                    ),
                    duration: const Duration(seconds: 2),
                    action: SnackBarAction(
                      onPressed: () {
                        cart.removeSingleItem(loadedProduct.id);
                      },
                      label: 'UNDO',
                    ),
                  ),
                );
              },
              child: const Icon(Icons.shopping_cart),
            ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverLayoutBuilder(
            builder: (BuildContext context, constraints) {
              final bool scrolled = constraints.scrollOffset > 0;
              return SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                leading: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(top: 5),
                    decoration: scrolled
                        ? null
                        : const BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(15),
                              bottomRight: Radius.circular(15),
                            ),
                          ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  title: Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    decoration: BoxDecoration(
                      color: scrolled ? null : Colors.black45,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                      ),
                    ),
                    child: Text(
                      loadedProduct.title,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  background: Hero(
                    tag: loadedProduct.id,
                    child: Image.network(
                      loadedProduct.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Container(
                width: double.infinity,
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 30),
                color: Colors.black,
              ),
              const SizedBox(height: 20),
              Text(
                '\$${loadedProduct.price}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                width: double.infinity,
                child: Text(
                  loadedProduct.description,
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
              ),
              const SizedBox(height: 800),
            ]),
          ),
        ],
      ),
    );
  }
}
