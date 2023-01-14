import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/cart_item.dart';
import '../provider/cart.dart' show Cart;
//this tells flutter that we are only interested in Cart class so others are not imported

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);
  static const routeName = '/cart';

  @override
  Widget build(BuildContext context) {
    final cartData = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  const Text(
                    'Total:',
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 10),
                  Chip(
                    label: Text(
                      'Rs ${cartData.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Theme.of(context)
                            .primaryTextTheme
                            .titleMedium!
                            .color,
                      ),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  const Spacer(),
                  //takes all the available space for itself
                  TextButton(
                    onPressed: () {},
                    child: const Text('ORDER NOW!'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemBuilder: (ctx, i) => CartItem(
                id: cartData.items.values.toList()[i].id,
                productId: cartData.items.keys.toList()[i],
                price: cartData.items.values.toList()[i].price,
                quantity: cartData.items.values.toList()[i].quantity,
                title: cartData.items.values.toList()[i].title,
                //cartData.items is actually a Map but we need values in arguments
                //so, .values.toList() converts the Map into iterable which can be
                //converted into a list.
              ),
              itemCount: cartData.itemCount,
            ),
          ),
        ],
      ),
    );
  }
}
