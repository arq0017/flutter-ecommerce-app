import 'package:flutter/foundation.dart';

// cart model - to be used in Cart class
class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;

  CartItem({
    // cart own id - not same as product id , product id is used as key
    @required this.id,
    @required this.title,
    @required this.quantity,
    @required this.price,
  });
}

class Cart with ChangeNotifier {
  // map uses productIds as key and cart id in CartItem
  Map<String, CartItem> _cartItems = {};

  Map<String, CartItem> get item {
    return {..._cartItems};
  }

  // function to return amount of products . not quantities
  int get itemCount {
    return _cartItems.length;
  }

  double get totalAmount {
    double total = 0;
    _cartItems.forEach((key, value) {
      total += value.price * value.quantity;
    });
    return total;
  }

  void addItem(String productId, double price, String title) {
    // logic - if element exist increase quantity
    // else add the item to map
    if (_cartItems.containsKey(productId)) {
      // increase quantity
      _cartItems.update(
          productId,
          (existingCartItem) => CartItem(
                id: existingCartItem.id,
                title: existingCartItem.title,
                price: existingCartItem.price,
                quantity: existingCartItem.quantity + 1,
              ));
    } else {
      // add the item to the Map <String id , CartItem>
      _cartItems.putIfAbsent(
          productId,
          () => CartItem(
              id: DateTime.now().toString(),
              title: title,
              price: price,
              quantity: 1));
    }
    notifyListeners();
  }

  void removeRecentItem(String productId) {
    // logic - if item available reduce the size , else remove the item
    if (!_cartItems.containsKey(productId)) return;
    if (_cartItems[productId].quantity > 1) {
      _cartItems.update(
        productId,
        (existingValue) => CartItem(
          id: existingValue.id,
          title: existingValue.title,
          quantity: existingValue.quantity - 1,
          price: existingValue.price,
        ),
      );
    } else {
      _cartItems.remove(productId);
    }
    notifyListeners();
  }

  void removeItem(String id) {
    _cartItems.remove(id);
    notifyListeners();
  }

  void clear() {
    _cartItems = {};
    notifyListeners();
  }
}
