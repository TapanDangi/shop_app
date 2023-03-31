import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/products.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({Key? key}) : super(key: key);

  static const routeName = '/product-detail-screen';

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context)!.settings.arguments as String;
    final loadedProduct =
        Provider.of<Products>(context, listen: false).findById(productId);
    //the listen: false argument makes sure that when notifylistener() is
    //called, this widget does not rebuild.
    //this is done because we only have to change it once when it is first
    //created, and not when any new Products are added.
    return Scaffold(
      body: CustomScrollView(
        //CustomScrollView is similar to SinglChildScrollView with more control given to developer.
        slivers: [
          //slivers are the scrollable parts on a screen.
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              //flexibleSpace argument shows the content of the appBar.
              title: Text(
                loadedProduct.title,
              ),
              background: Hero(
                //background argument shows what should be on the screen when appbar is expanded.
                tag: loadedProduct.id,
                child: Image.network(
                  loadedProduct.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
              collapseMode: CollapseMode.parallax,
            ),
          ),
          SliverList(
            //SliverList is basically ListView as a part of multiple slivers. We use it in case our ListView
            //is part of multiple scrollable things on the screen which should scroll independently and
            //we want to have some special tricks when they scroll.
            delegate: SliverChildListDelegate(
              [
                const SizedBox(height: 10),
                Text(
                  'Rs ${loadedProduct.price}',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    loadedProduct.description,
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                ),
                const SizedBox(height: 1000)
              ],
            ),
          ),
        ],
      ),
    );
  }
}
