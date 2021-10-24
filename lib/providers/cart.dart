import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CartItem {
  final String id;
  final String title;
  final double price;
  final int quantity;

  CartItem({
    @required this.id,
    @required this.title,
    @required this.price,
    @required this.quantity,
  });
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {};
  Map<String, CartItem> get items {
    return {..._items};
  }

  final String authToken;
  final String userId;

  Cart(this.authToken, this.userId, this._items);

  int get itemsCount {
    var count = 0;
    if (_items.length == 0) {
      return count;
    } else {
      var itemList = _items.values.toList();
      for (var item in itemList) {
        count += item.quantity;
      }
      return count;
    }
  }

  int get itemCount {
    return _items.length;
  }

  double get itemTotal {
    var total = 0.0;
    _items.forEach((key, value) {
      total += value.price * value.quantity;
    });

    return total;
  }

  void removeItem(String id) {
    _items.remove(id);
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) {
      return;
    }
    if (_items[productId].quantity > 1) {
      _items.update(
          productId,
          (value) => CartItem(
              id: value.id,
              title: value.title,
              price: value.price,
              quantity: value.quantity - 1));
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  Future<void> fetchCartItem() async {
    Map<String, CartItem> cartList = {};
    final url =
        'https://my-shop-de7c1.firebaseio.com/cart/$userId.json?auth=$authToken';
    final response = await http.get(url);
    //print(response.body);
    var extractedData = json.decode(response.body) as Map<String, dynamic>;
    if (extractedData == null) {
      return;
    }

    extractedData.forEach((cartId, cartData) {
      cartList.putIfAbsent(
        cartId,
        () => CartItem(
            id: cartData['id'],
            title: cartData['title'],
            price: cartData['price'],
            quantity: cartData['quantity']),
      );
    });
    _items = cartList;
    notifyListeners();
  }

  Future<void> addItem(String productId, String title, double price) async {
    final url =
        'https://my-shop-de7c1.firebaseio.com/cart/$userId.json?auth=$authToken';

    if (_items.containsKey(productId)) {
      //final urlId = _items[productId].id;
      final editUrl =
          'https://my-shop-de7c1.firebaseio.com/cart/$userId/${_items[productId].id}.json?auth=$authToken';

      try {
        await http.patch(editUrl,
            body: jsonEncode({
              'id': productId,
              'title': title,
              'price': price,
              'quantity': _items[productId].quantity + 1,
            }));
      } catch (error) {
        print(error);
        throw (error);
      }
      _items.update(
          productId,
          (value) => CartItem(
                id: value.id,
                title: value.title,
                price: value.price,
                quantity: value.quantity + 1,
              ));
      //
    } else {
      try {
        final response = await http.post(url,
            body: jsonEncode({
              'id': productId,
              'title': title,
              'price': price,
              'quantity': 1,
            }));

        _items.putIfAbsent(
            productId,
            () => CartItem(
                id: json.decode(response.body)['name'],
                title: title,
                price: price,
                quantity: 1));
      } catch (error) {
        throw (error);
      }
    }
    notifyListeners();
  }
}
