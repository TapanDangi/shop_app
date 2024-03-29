import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/product_detail_screen.dart';
import '../provider/product.dart';
import '../provider/cart.dart';
import '../provider/auth.dart';

class ProductItem extends StatelessWidget {
  const ProductItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productData = Provider.of<Product>(context);
    final cartData = Provider.of<Cart>(context, listen: false);
    final authData = Provider.of<Auth>(context, listen: false);
    return ClipRRect(
      //forces the child widget to wrap into a certain shape
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        footer: GridTileBar(
          title: Text(
            productData.title,
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.black54,
          leading: IconButton(
            icon: Icon(
              productData.isFavorite ? Icons.favorite : Icons.favorite_border,
            ),
            onPressed: () {
              productData.toggleFavorite(
                authData.token!,
                authData.userId!,
              );
            },
            color: Theme.of(context).colorScheme.secondary,
          ),
          trailing: IconButton(
            icon: const Icon(
              Icons.shopping_cart,
            ),
            onPressed: () {
              cartData.addItem(
                  productData.id, productData.title, productData.price);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              //this hides the current snackbar if another one is about to pop-up.
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    'Added item to cart',
                  ),
                  duration: const Duration(seconds: 2),
                  action: SnackBarAction(
                    label: 'UNDO',
                    onPressed: () {
                      cartData.removeSingleItem(productData.id);
                    },
                  ),
                ),
              );
              //Scaffold.of() method establishes connection to the nearest Scaffold widget.
              //Snackbar is a info pop-up that comes at the bottom of the screen.
            },
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              ProductDetailScreen.routeName,
              arguments: productData.id,
            );
          },
          child: Hero(
            //Hero widget is used between two screens to know which image on the old screen
            //is to be animated in the new screen using unique tag argument.
            tag: productData.id,
            child: FadeInImage(
              //FadeInImage displays a placeholder while the image is loading with the fading effects.
              placeholder:
                  const AssetImage('assets/images/product-placeholder.png'),
              image: NetworkImage(productData.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
