import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './product.dart';
import '../models/http_exception.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    //when anywhere in the code _items is accessed through the Products class,
    //then we get the direct access to the _items list and we can modify it
    //from anywhere else. So it is put as a private object.

    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  List<Product> get items {
    return [..._items];
    //a copy of _items class is returned because we don't want to change the
    //original list whenever another entry is added in the _items list.
  }
  //since _items is a private object, getter method is used if we have to use
  //the _items list in another file.

  List<Product> get favItems {
    return _items.where((element) => element.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  Future<void> fetchAndSetProducts() async {
    final url = Uri.https(
        'flutter-shop-app-566b5-default-rtdb.firebaseio.com', '/products.json');
    try {
      final response = await http.get(url);
      //http.get() is used to fetch data from the server.
      final List<Product> loadedProducts = [];
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      //The extracted data is type casted so that we can use various methods on
      //it which are only available on Maps.
      extractedData.forEach((prodId, prodData) {
        //forEach method runs for every entry in the map.
        loadedProducts.add(Product(
          //every entry in the map is added to the loadedProducts List with their
          //different fields specified below.
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          price: prodData['price'],
          imageUrl: prodData['imageUrl'],
          isFavorite: prodData['isFavorite'],
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> addProduct(Product product) async {
    //adding async to a method automatically wraps all the encapsulated code in a Future.
    //All the code is wrapped in the future and the future is returned automatically.
    final url = Uri.https(
        'flutter-shop-app-566b5-default-rtdb.firebaseio.com', '/products.json');
    //the first part is the authority which is basically the firebase project link.
    //the second part is the unencoded path we want to create.
    try {
      final response = await http.post(
        //await keyword tells dart that we want to wait for this operation to finish
        //before moving to the next line in the code.
        //It simply wraps the code that comes into the next line in a then() block.
        url,
        //http.post sends a post request to the specified url.
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'isFavorite': product.isFavorite,
        }),
        //body argument allows us to define the request body which is the data that
        //gets attached to the request.
        //We need to encode the data into json format to pass it to the body argument.
      );

      final newProduct = Product(
        id: json.decode(response.body)['name'],
        //this returns a unique cryptic id stored in firebase server by decoding
        //json file into dart readable code often a map.
        title: product.title,
        description: product.description,
        imageUrl: product.imageUrl,
        price: product.price,
      );
      _items.insert(0, newProduct);
      //the index 0 adds the item to the beginning of the list.
      notifyListeners();
      //this method is given by ChangeNotifier mixin.
      //this establishes a communication channel between this class and widgets
      //that are interested in the updates we did.
      //The widgets that are listening to this class are then rebuilt to get the latest data.
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateProduct(String id, Product updatedProducted) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url = Uri.https(
          'flutter-shop-app-566b5-default-rtdb.firebaseio.com',
          '/products/$id.json');
      await http.patch(
        url,
        body: json.encode({
          'title': updatedProducted.title,
          'description': updatedProducted.description,
          'price': updatedProducted.price,
          'imageUrl': updatedProducted.imageUrl,
        }),
        //'isFavorite' is not sent in the patch request because we don't want to reset
        //Favorite status everytime upDateProduct is called.
      );
      //sending a path request tells firebase to merge the existing data with the incoming data
      //at the address we are sending it to.
      _items[prodIndex] = updatedProducted;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.https('flutter-shop-app-566b5-default-rtdb.firebaseio.com',
        '/products/$id.json');
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    //this gives us the index of the product we want to remove.
    Product? existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);
    //http.delete is used to delete the object at that address url.
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product!');
    }
    existingProduct = null;
  }
}
