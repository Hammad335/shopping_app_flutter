import 'package:flutter/material.dart';
import 'package:shopping_app/screens/orders_screen.dart';
import 'package:shopping_app/screens/user_products_Screen.dart';
import '../providers/auth.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = Provider.of<Auth>(context, listen: false).isAdmin();
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: const Text('Online Shopping'),
            automaticallyImplyLeading: false,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.shop),
            title: const Text('Shop'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
          if (!isAdmin) _showOrdersWidget(context),
          if (isAdmin) _showManageProductsWidget(context),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Logout'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/');
              Provider.of<Auth>(context, listen: false).logout();
            },
          ),
        ],
      ),
    );
  }

  Widget _showOrdersWidget(BuildContext context) {
    return Column(
      children: [
        const Divider(),
        ListTile(
          leading: const Icon(Icons.payment),
          title: const Text('Orders'),
          onTap: () {
            Navigator.of(context).pushReplacementNamed(OrdersScreen.routeName);
          },
        ),
      ],
    );
  }

  Widget _showManageProductsWidget(BuildContext context) {
    return Column(
      children: [
        const Divider(),
        ListTile(
          leading: const Icon(Icons.edit),
          title: const Text('Manage Products'),
          onTap: () {
            Navigator.of(context)
                .pushReplacementNamed(UserProductScreen.routeName);
          },
        ),
      ],
    );
  }
}
