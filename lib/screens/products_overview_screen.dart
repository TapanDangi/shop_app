import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './cart_screen.dart';
import '../widgets/products_grid.dart';
import '../widgets/badge.dart';
import '../provider/cart.dart';
import '../provider/products.dart';
import '../widgets/app_drawer.dart';

enum FilterOptions {
  favorites,
  all,
}

class ProductsOverviewScreen extends StatefulWidget {
  const ProductsOverviewScreen({Key? key}) : super(key: key);

  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _showOnlyFavorites = false;
  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<Products>(context).fetchAndSetProducts().then((_) {
        //then() method is used here because aysnc and await should not be used in
        //initState or didChangeDependencies as they only return void but aysnc return Future.
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    //_isInit is created so that didChangeDependencies runs only once when it is running for the first time.
    //After that it is changed to false so it never runs again.
    super.didChangeDependencies();
  }
  //this is used because provider class cannot be used in initState.

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false).fetchAndSetProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyShop'),
        actions: [
          PopupMenuButton(
            onSelected: (FilterOptions selectedValue) {
              setState(() {
                if (selectedValue == FilterOptions.favorites) {
                  _showOnlyFavorites = true;
                } else {
                  _showOnlyFavorites = false;
                }
              });
            },
            icon: const Icon(Icons.more_vert),
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: FilterOptions.favorites,
                child: Text('Only Favorites!'),
              ),
              PopupMenuItem(
                value: FilterOptions.all,
                child: Text('Show All!'),
              ),
            ],
          ),
          Consumer<Cart>(
            //Consumer class is similar to provider class but it is used on
            //individual widgets when we don't want to affect the entire widget
            //tree of that widget to be re-built everytime the list updates.
            builder: (_, cart, ch) => Badge(
              value: cart.itemCount.toString(),
              child: ch as Widget,
            ),
            child: IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
              icon: const Icon(
                Icons.shopping_cart,
              ),
            ),
            //this IconButton is defined outside of builder function so that it
            //won't be rebuilt when the value parameter in builder function changes.
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _refreshProducts(context),
              child: ProductsGrid(showFavorites: _showOnlyFavorites),
            ),
    );
  }
}
