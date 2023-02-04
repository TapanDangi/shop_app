import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/orders.dart' show Orders;
import '../widgets/order_item.dart';
import '../widgets/app_drawer.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  static const routeName = 'orders-screen';

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late Future _ordersFuture;

  Future _obtainOrdersFuture() {
    return Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
  }

  @override
  void initState() {
    _ordersFuture = _obtainOrdersFuture();
    super.initState();
  }
  //_ordersFuture and _obtainOrdersFuture are created instead of directly calling
  //provider in the widget tree so that the orders are not fetched repeatedly and create
  //unnecessary Futures everytime the widget rebuilds.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders!'),
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder(
        //this is the best alernative to fetch data and show a loading spinner.
        //we don't need to rebuild the widget tree just beacuse loading state changes.
        future: _ordersFuture,
        //future parameter takes a Future as an argument from where it gets its data
        builder: (ctx, dataSnapshot) {
          //builder method takes a snapshot of current state of the function
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (dataSnapshot.error == null) {
              return Consumer<Orders>(builder: (ctx, orderData, child) {
                //we use consumer here because using provider in the whole build method
                //may result in an infinite loop. Everytime fetchAndSetOrders() is called,
                //it rebuilds the screen resulting in another instance of Provider executing.
                return ListView.builder(
                  itemBuilder: (ctx, i) =>
                      OrderItem(order: orderData.orders[i]),
                  itemCount: orderData.orders.length,
                );
              });
            }
            return const Center(
              child: Text('An error occurred!'),
            );
          }
        },
      ),
    );
  }
}
