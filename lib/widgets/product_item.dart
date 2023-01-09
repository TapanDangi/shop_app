import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/product_detail_screen.dart';
import '../provider/product.dart';

class ProductItem extends StatelessWidget {
  const ProductItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productData = Provider.of<Product>(context);
    return ClipRRect(
      //forces the child widget to wrap into a certain shape
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        footer: GridTileBar(
          title: Text(
            '${productData.price}',
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.black54,
          leading: IconButton(
            icon: Icon(
              productData.isFavorite ? Icons.favorite : Icons.favorite_outline,
            ),
            onPressed: () {
              productData.toggleFavorite();
            },
            color: Theme.of(context).colorScheme.secondary,
          ),
          trailing: IconButton(
            icon: const Icon(
              Icons.shopping_cart,
            ),
            onPressed: () {},
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
          child: Image.network(
            productData.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
