import 'package:flutter/material.dart';
import '../providers/cart.dart' show Cart;
import 'package:provider/provider.dart';
import '../widgets/cart_item.dart';
import '../providers/orders.dart' show Orders;

class CartScreen extends StatefulWidget {
  static const routeName = '/cart';
  static const String text1 = 'place  order';

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text('Your Cart'),
        ),
        body: Column(
          children: [
            Card(
                margin: EdgeInsets.all(15),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(15, 8, 15, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(fontSize: 20),
                      ),
                      Spacer(),
                      Chip(
                        label: Text('\$ ${cart.totalAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .primaryTextTheme
                                  .bodyText1
                                  .color,
                              fontWeight: FontWeight.bold,
                            )),
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
                        child: OrderButton(cart: cart),
                      )
                    ],
                  ),
                )),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: cart.item.length,
                itemBuilder: (BuildContext context, int index) {
                  final item = cart.item.values.toList()[index];
                  return CartItem(
                    id: item.id,
                    productId: cart.item.keys.toList()[index],
                    title: item.title,
                    price: item.price,
                    quantity: item.quantity,
                  );
                },
              ),
            ),
          ],
        ));
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key key,
    @required this.cart,
  }) : super(key: key);

  final Cart cart;

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  bool _isLoading = false;
  void changeIsLoading(bool value) {
    setState(() {
      _isLoading = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: _isLoading
          ? CircularProgressIndicator()
          : Text(CartScreen.text1.toUpperCase(),
              style: TextStyle(
                color: Colors.orange,
              )),
      onPressed: (widget.cart.item.length <= 0 || _isLoading)
          ? null
          : () async {
              changeIsLoading(true);
              await Provider.of<Orders>(context, listen: false).addOrder(
                  widget.cart.item.values.toList(), widget.cart.totalAmount);
              widget.cart.clear();
              changeIsLoading(false);
            },
    );
  }
}
