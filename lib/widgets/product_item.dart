import 'package:flutter/material.dart';
import 'package:shop_app/screens/product_detail_screen.dart';

class ProductItem extends StatelessWidget {
  const ProductItem({
    Key? key,
    required this.id,
    required this.price,
    required this.imageUrl,
  }) : super(key: key);

  final String id;
  final double price;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      //forces the child widget to wrap into a certain shape
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        footer: GridTileBar(
          title: Text(
            '$price',
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.black54,
          leading: IconButton(
            icon: const Icon(
              Icons.favorite,
            ),
            onPressed: () {},
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
              arguments: id,
            );
          },
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
