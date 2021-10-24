import 'package:flutter/foundation.dart';
// import '../widget/cart_item.dart' as Cart_Item;
import 'cart.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final double total;
  final List<CartItem> productList;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.total,
    @required this.productList,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  List<OrderItem> get orders {
    return [..._orders];
  }

  final String authToken;
  final String userId;

  Orders(this.authToken, this.userId, this._orders);

  Future<void> fetchOrders() async {
    final url =
        'https://my-shop-de7c1.firebaseio.com/orders/$userId.json?auth=$authToken';
    final response = await http.get(url);
    final List<OrderItem> loadedOrder = [];
    final List<CartItem> loadedCart = [];
    var extractedData = json.decode(response.body) as Map<String, dynamic>;
    if (extractedData == null) {
      return;
    }
    //print(extractedData);
    extractedData.forEach((orderId, orderData) {
      loadedOrder.add(
        OrderItem(
          id: orderId,
          total: orderData['total'],
          productList: (orderData['productList'] as Map<String, dynamic>)
              .values
              .map((cartData) => CartItem(
                  id: cartData['id'],
                  title: cartData['title'],
                  price: cartData['price'],
                  quantity: cartData['quantity']))
              .toList(),
          dateTime: DateTime.parse(orderData['dateTime']),
        ),
      );
    });
    _orders = loadedOrder.reversed.toList();

    notifyListeners();
  }

  Future<void> addItem(List<CartItem> products, double total) async {
    final fetchUrl =
        'https://my-shop-de7c1.firebaseio.com/cart/$userId.json?auth=$authToken';
    final response = await http.get(fetchUrl);
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    final url =
        'https://my-shop-de7c1.firebaseio.com/orders/$userId.json?auth=$authToken';
    try {
      final response = await http.post(url,
          body: jsonEncode({
            'total': total,
            'productList': extractedData,
            'dateTime': DateTime.now().toIso8601String(),
          }));

      if (response.statusCode > 400) {
        return;
      }
      http.delete(fetchUrl);
      products = null;

      //products = null;
    } catch (error) {
      throw (error);
    }

    _orders.insert(
      0,
      OrderItem(
          id: DateTime.now().toString(),
          total: total,
          productList: products,
          dateTime: DateTime.now()),
    );
    notifyListeners();
  }
}
