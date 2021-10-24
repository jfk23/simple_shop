import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_shop/model/http_exception.dart';
import 'product.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class Products with ChangeNotifier {
  List<Product> _items = [
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

  final String authToken;
  final String userId;

  Products(this.authToken, this.userId, this._items);

  List<Product> get items {
    return [..._items];
  }

  Product findById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  List<Product> get getFavorites {
    return _items.where((element) => element.isFavorite).toList();
  }

  Future<void> fetchItems([bool filter = false]) async {
    final filterUrl = filter ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    try {
      var url =
          'https://my-shop-de7c1.firebaseio.com/products.json?auth=$authToken&$filterUrl';
      final response = await http.get(url);
      //print(json.decode(response.body));
      List<Product> productList = [];
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      url =
          'https://my-shop-de7c1.firebaseio.com/userfavorites/$userId.json?auth=$authToken';
      final favResponse = await http.get(url);
      final favoriteData = json.decode(favResponse.body);
  
      extractedData.forEach((prodId, prodData) {
        productList.add(Product(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            price: prodData['price'],
            isFavorite:
                favoriteData == null ? false : favoriteData[prodId] ?? false,
            imageUrl: prodData['imageUrl']));
      });
      _items = productList;
    } catch (error) {
      //print(error);
      throw (error);
    }
    notifyListeners();
  }

  // var favoriteSelected = false;

  // void selectFavorite() {
  //   favoriteSelected = true;
  //   notifyListeners();
  // }

  // void selectShowAll() {
  //   favoriteSelected = false;
  //   notifyListeners();
  // }

  Future<void> addItem(Product product) async {
    final url =
        'https://my-shop-de7c1.firebaseio.com/products.json?auth=$authToken';
    try {
      final response = await http.post(url,
          body: jsonEncode({
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'creatorId': userId,
          }));

      final newProduct = Product(
        title: product.title,
        description: product.description,
        imageUrl: product.imageUrl,
        price: product.price,
        id: json.decode(response.body)['name'],
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateItem(Product product) async {
    final url =
        'https://my-shop-de7c1.firebaseio.com/products/${product.id}.json?auth=$authToken';
    await http.patch(
      url,
      body: json.encode({
        'title': product.title,
        'description': product.description,
        'price': product.price,
        'imageUrl': product.imageUrl,
      }),
    );

    final productIndex =
        _items.indexWhere((element) => element.id == product.id);
    _items[productIndex] = product;
    notifyListeners();
  }

  Future<void> deleteProduct(String id) async {
    final url =
        'https://my-shop-de7c1.firebaseio.com/products/$id.json?auth=$authToken';
    final existingIndex = _items.indexWhere((element) => element.id == id);
    var existingProduct = _items[existingIndex];
    _items.removeWhere((element) => element.id == id);
    notifyListeners();

    final response = await http.delete(url);
    if (response.statusCode > 400) {
      _items.insert(existingIndex, existingProduct);
      notifyListeners();
      throw HttpException('deleting selected product failed!');
    }

    existingProduct = null;
    //print(response.statusCode);
  }
}
