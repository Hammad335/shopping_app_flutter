import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/widgets/app_drawer.dart';
import 'package:shopping_app/widgets/order_item.dart';
import '../providers/orders.dart' as provider;

class OrdersScreen extends StatelessWidget {
  static const routeName = '/orders_screen';
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final orderData = Provider.of<provider.Orders>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Orders'),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: Provider.of<provider.Orders>(context, listen: false)
            .fetchAndSetOrders(),
        builder: (context, dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (dataSnapshot.hasError) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(dataSnapshot.error.toString()),
                      duration: const Duration(seconds: 4),
                    ),
                  );
                },
              );
              return Container();
            } else {
              return Consumer<provider.Orders>(
                builder: (context, orderData, child) => ListView.builder(
                  itemCount: orderData.getOrderItems.length,
                  itemBuilder: (context, index) =>
                      OrderItem(order: orderData.getOrderItems[index]),
                ),
              );
            }
          }
        },
      ),
    );
  }
}
