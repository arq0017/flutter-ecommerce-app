import 'package:flutter/material.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;
  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  String authToken, authUserId;
  List<OrderItem> _orders = [];
  Orders(this.authToken, this.authUserId, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url = Uri.parse(
        'https://shopappflutter-d8463-default-rtdb.firebaseio.com/orders/$authUserId.json?auth=$authToken');
    List<OrderItem> newList = [];
    try {
      final response = await http.get(url);
      final serverOrders = json.decode(response.body) as Map<String, dynamic>;
      if (serverOrders == null) {
        _orders = [];
        notifyListeners();
        return;
      }
      serverOrders.forEach((key, value) {
        newList.add(OrderItem(
            id: key,
            amount: value['amount'].toDouble(),
            //! obtained data is of list <dynamic> .
            //? converting list<dynamic> to list of CartItem
            products: (value['products'] as List<dynamic>)
                .map((item) => CartItem(
                      id: item['id'],
                      title: item['title'],
                      price: item['price'].toDouble(),
                      quantity: item['quantity'],
                    ))
                .toList(),
            //! DateTime is in ISO
            dateTime: DateTime.parse(value['dateTime'])));
      });
    } catch (error) {
      throw error;
    }
    _orders = newList.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.parse(
        'https://shopappflutter-d8463-default-rtdb.firebaseio.com/orders/$authUserId.json?auth=$authToken');
    final timeStamp = DateTime.now();
    final response = await http.post(
      url,
      body: json.encode({
        'amount': total,
        'dateTime': timeStamp.toIso8601String(),
        'products': cartProducts
            .map((cp) => {
                  'id': cp.id,
                  'title': cp.title,
                  'quantity': cp.quantity,
                  'price': cp.price,
                })
            .toList(),
      }),
    );
    _orders.insert(
      0,
      OrderItem(
          id: json.decode(response.body)['name'],
          amount: total,
          products: cartProducts,
          dateTime: timeStamp),
    );
    notifyListeners();
  }
}
