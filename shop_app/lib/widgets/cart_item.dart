import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart';

class CartItem extends StatelessWidget {
  final String id;
  final String productId;
  final String title;
  final int quantity;
  final double price;

  const CartItem({
    @required this.id,
    @required this.productId,
    @required this.title,
    @required this.quantity,
    @required this.price,
  });

  @override
  Widget build(BuildContext context) {
    double num = price * quantity;
    return Dismissible(
      key: Key(id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Theme.of(context).accentColor,
        child: Padding(
            padding: EdgeInsets.all(5),
            child: Icon(Icons.delete, color: Colors.white, size: 40)),
        alignment: Alignment.centerRight,
        margin: EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
      ),
      child: Card(
        margin: EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
        child: ListTile(
          leading: CircleAvatar(
            child: Padding(
              padding: EdgeInsets.all(1),
              child: FittedBox(
                  child: Text("\$${price.toInt()} ",
                      style: TextStyle(fontWeight: FontWeight.bold))),
            ),
            backgroundColor: Theme.of(context).accentColor,
          ),
          title: Text(title),
          subtitle: Text("Total : \$ ${num.toStringAsFixed(2)} "),
          trailing: Text("$quantity x"),
        ),
      ),
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: Text('Are you sure ?'),
            content: Text('your current item will be removed from the cart .'),
            actions: [
              CupertinoButton(
                child: Text("Yes"),
                onPressed: () {
                  Navigator.of(ctx).pop(true);
                },
              ),
              CupertinoButton(
                child: Text("No"),
                onPressed: () {
                  Navigator.of(ctx).pop(false);
                },
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        Provider.of<Cart>(context, listen: false).removeItem(productId);
      },
    );
  }
}
