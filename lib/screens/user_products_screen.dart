import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './edit_product_screen.dart';
import '../widgets/app_drawer.dart';
import '../provider/products.dart';
import '../widgets/user_product_item.dart';

class UserProductsScreen extends StatelessWidget {
  const UserProductsScreen({Key? key}) : super(key: key);

  static const routeName = 'user-products-screen';

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false).fetchAndSetProducts();
  }

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        //RefreshIndicator implements Pull-to-refresh function.
        onRefresh: () => _refreshProducts(context),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ListView.builder(
            itemBuilder: (_, i) => UserProductItem(
              id: productsData.items[i].id,
              title: productsData.items[i].title,
              imageUrl: productsData.items[i].imageUrl,
            ),
            itemCount: productsData.items.length,
          ),
        ),
      ),
    );
  }
}
