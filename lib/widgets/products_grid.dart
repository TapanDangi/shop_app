import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/product_item.dart';
import '../provider/products.dart';

class ProductsGrid extends StatelessWidget {
  const ProductsGrid({Key? key, required this.showFavorites}) : super(key: key);

  final bool showFavorites;

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    final products = showFavorites ? productsData.favItems : productsData.items;
    //Provider class allows us to set up a connection to one of the provided classes.
    //It can only be used in a widget which has some direct or indirect parent
    //widget which set up a provider.
    //With this class, we can listen to the changes in the provided object.
    //Only the build method of the widget where we are using Provider.of() is rebuilt
    //whenever the object we are listening to changes.
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2 / 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (ctx, i) {
        return ChangeNotifierProvider.value(
          //this is an alternative syntax of the ChangeNotifierProvider class
          //if the returned object does not depend on context.
          //Use this approach whenever we reuse an existing object.
          value: products[i],
          child: const ProductItem(),
        );
      },
      itemCount: products.length,
    );
  }
}
