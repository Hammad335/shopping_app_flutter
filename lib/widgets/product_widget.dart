import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shopping_app/screens/product_details_screen.dart';
import '../providers/auth.dart';
import '../providers/cart.dart';
import '../providers/product.dart';
import 'package:provider/provider.dart';

class ProductWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final authData = Provider.of<Auth>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              ProductDetailsScreen.routeName,
              arguments: product.id,
            );
          },
          child: Hero(
            tag: product.id,
            child: FadeInImage(
              placeholder:
                  const AssetImage('assets/images/product_placeholder.png'),
              image: NetworkImage(product.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          leading: authData.isAdmin()
              ? null
              : Consumer<Product>(
                  builder: (context, product, _) => IconButton(
                    icon: Icon(
                      product.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      product.toggleFavorite(
                          authData.getToken, authData.getUserId);
                    },
                    color: Theme.of(context).accentColor,
                  ),
                ),
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
          trailing: authData.isAdmin()
              ? null
              : IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () {
                    cart.addItem(product.id, product.title, product.price);
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Item added to cart!',
                        ),
                        duration: const Duration(seconds: 2),
                        action: SnackBarAction(
                          onPressed: () {
                            cart.removeSingleItem(product.id);
                          },
                          label: 'UNDO',
                        ),
                      ),
                    );
                  },
                  color: Theme.of(context).accentColor,
                ),
        ),
      ),
    );
  }
}
