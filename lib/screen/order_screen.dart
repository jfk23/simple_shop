import 'package:flutter/material.dart';
import '../widget/app_drawer.dart';
import 'package:provider/provider.dart';
import '../providers/orders.dart' show Orders;
import '../widget/order_item.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = '/orders';

  @override
  Widget build(BuildContext context) {
    //final orderData = Provider.of<Orders>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text('Your Orders'),
        ),
        drawer: AppDrawer(),
        body: FutureBuilder(
          future: Provider.of<Orders>(context, listen: false).fetchOrders(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              if (snapshot.error != null) {
                return Text('There is error with loading order history');
              }
              return Consumer<Orders>(
                builder: (context, orderData, child) =>
                    orderData.orders.length == 0
                        ? Center(
                            child: Text('No orders yet!'),
                          )
                        : ListView.builder(
                            itemBuilder: (ctx, i) =>
                                OrderItem(orderData.orders[i]),
                            itemCount: orderData.orders.length,
                          ),
              );
            }
          },
        ));
  }
}
