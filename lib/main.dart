import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './provider/products.dart';
import './provider/cart.dart';
import './provider/orders.dart';
import './provider/auth.dart';
import './screens/orders_screen.dart';
import './screens/cart_screen.dart';
import './screens/products_overview_screen.dart';
import './screens/product_detail_screen.dart';
import './screens/user_products_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/auth_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      //allows us to register multiple providers for a single widget.
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Auth(),
        ),
        //allows us to register a class to which we can listen in child widgets and
        //whenever that class updates, only the widgets that are listening are rebuilt
        //Use this approach whenever a new object based on the class is created.
        ChangeNotifierProxyProvider<Auth, Products>(
          //first generic argument is the type it depends on i.e. Auth()
          //second generic argument is the type it provides i.e. Products()
          create: (ctx) => Products('', '', []),
          update: (ctx, auth, previousProducts) => Products(
            auth.token!,
            auth.userId!,
            previousProducts == null ? [] : previousProducts.items,
            //when it is first loaded, we have no items. So, previousProducts is null at that time.
            //so, if we have no previousProducts then we initialise it with an empty array
            //otherwise, we will access the previousProducts if it is not empty.
          ),
          //this statement takes a look at the Provider tree and sees if there is a Auth()
          //provider in the tree before the current ProxyProvider and then takes
          //the Auth object and gives it to the update argument.
          //last argument defines the previous state of the object useful for maintaining our state.
        ),
        //this allows us to set up a Provider which itself depends on another provider
        //which was defined before this one.
        //whenever Auth changes, this Provider will be rebuilt as it is dependent on Auth.
        ChangeNotifierProvider(
          create: (ctx) => Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (ctx) => Orders('', []),
          update: (ctx, auth, previousOrders) => Orders(
            auth.token!,
            previousOrders == null ? [] : previousOrders.orders,
          ),
        ),
      ],
      child: Consumer<Auth>(
        //MaterialApp is rebuilt whenever Auth() changes and whenever we call notifylisteners() in there.
        builder: (ctx, auth, _) => MaterialApp(
          title: 'MyShop',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSwatch(
              primarySwatch: Colors.purple,
              accentColor: Colors.amber,
            ),
            fontFamily: 'Lato',
          ),
          home:
              auth.isAuth ? const ProductsOverviewScreen() : const AuthScreen(),
          routes: {
            ProductDetailScreen.routeName: (ctx) => const ProductDetailScreen(),
            CartScreen.routeName: (ctx) => const CartScreen(),
            OrdersScreen.routeName: (ctx) => const OrdersScreen(),
            UserProductsScreen.routeName: (ctx) => const UserProductsScreen(),
            EditProductScreen.routeName: (ctx) => const EditProductScreen(),
            AuthScreen.routeName: (ctx) => const AuthScreen(),
          },
        ),
      ),
    );
  }
}
