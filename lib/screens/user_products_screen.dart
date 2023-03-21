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
    await Provider.of<Products>(context, listen: false)
        .fetchAndSetProducts(true);
    //true is passed to filter the products by user.
  }

  @override
  Widget build(BuildContext context) {
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
      body: FutureBuilder(
        //FutureBuilder is used to fetch products when we first visit the Manage Products page.
        //since it should fetch products differently than the home screen.
        future: _refreshProducts(context),
        //future is the data FutureBuilder listen to or waits for. It takes a Future method as argument.
        //we execute refreshProducts right away because we want to call it when
        //it first gets parsed or page is first loaded.
        builder: (ctx, snapshot) =>
            //snapshot is the current state of our product.
            snapshot.connectionState == ConnectionState.waiting
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    //RefreshIndicator implements Pull-to-refresh function.
                    onRefresh: () => _refreshProducts(context),
                    child: Consumer<Products>(
                      builder: (ctx, productsData, _) => Padding(
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
                  ),
      ),
    );
  }
}
