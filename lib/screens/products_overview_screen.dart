import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shopping_app/providers/products.dart';
import 'package:shopping_app/screens/cart_screen.dart';
import 'package:shopping_app/widgets/app_drawer.dart';
import 'package:shopping_app/widgets/cart_badge.dart';
import 'package:shopping_app/widgets/product_widget.dart';
import 'package:provider/provider.dart';
import '../providers/auth.dart';
import '../providers/cart.dart';

enum FilterOption {
  Favorites,
  All,
}

class ProductsOverviewScreen extends StatefulWidget {
  static const routeName = '/products_overview_screen';

  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _showFavorites = false;
  var _isLoading = true;

  @override
  void initState() {
    Future.delayed(Duration.zero);
    _fetchAndSetData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Shop'),
        actions: Provider.of<Auth>(context, listen: false).isAdmin()
            ? null
            : [
                Consumer<Cart>(
                  builder: (_, cart, excludedChild) => CartBadge(
                    child: excludedChild!,
                    value: cart.itemCount.toString(),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.of(context).pushNamed(CartScreen.routeName);
                    },
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      child: Text('Only Favorites'),
                      value: FilterOption.Favorites,
                    ),
                    const PopupMenuItem(
                      child: Text('Show All'),
                      value: FilterOption.All,
                    ),
                  ],
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    setState(() {
                      if (value == FilterOption.Favorites) {
                        _showFavorites = true;
                      } else {
                        _showFavorites = false;
                      }
                    });
                  },
                ),
              ],
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ProductsWidget(showFavorites: _showFavorites),
    );
  }

  void _fetchAndSetData() {
    setState(() {
      _isLoading = true;
    });
    Provider.of<Products>(context, listen: false)
        .fetchAndSetProducts()
        .then((_) {
      setState(() {
        _isLoading = false;
      });
    }).catchError((exception) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(exception.toString()),
          duration: const Duration(minutes: Duration.minutesPerDay),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () {
              _fetchAndSetData();
            },
          ),
        ),
      );
    });
  }
}

class ProductsWidget extends StatelessWidget {
  final bool showFavorites;
  ProductsWidget({required this.showFavorites});

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    final products = showFavorites
        ? productsData.getFavoriteProducts
        : productsData.getAllProducts;
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: products.length,
      itemBuilder: (context, index) => ChangeNotifierProvider.value(
        value: products[index],
        child: ProductWidget(),
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2.5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
    );
  }
}
