import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/auth.dart';
import 'package:shop_app/screens/manage_product_screen.dart';
import '../screens/orders_screen.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Column(
      children: <Widget>[
        AppBar(
          title: Text('Hello User'),
          automaticallyImplyLeading: false,
        ),
        ListTile(
          leading: Icon(Icons.shop),
          title: Text('Shop'),
          onTap: () {
            Navigator.of(context).pushReplacementNamed('/');
          },
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.payment),
          title: Text('Orders'),
          onTap: () {
            Navigator.of(context).pushReplacementNamed(OrdersScreen.routeName);
          },
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.edit),
          title: Text('Manage Products'),
          onTap: () {
            Navigator.of(context)
                .pushReplacementNamed(UserProductsScreen.routeName);
          },
        ),
        Divider(),
        Spacer(),
        Divider(),
        Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: ListTile(
            leading: Icon(Icons.logout_rounded),
            title: Text(
              'Log Out',
            ),
            onTap: () {
              Navigator.of(context).pop();
              showCupertinoDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                          title: Text('Do you want to log out ?'),
                          actions: [
                            TextButton(
                                child: Text("Yes"),
                                onPressed: () {
                                  Navigator.of(ctx).pop() ; 
                                  Provider.of<Auth>(ctx, listen: false)
                                      .logout();
                                  Navigator.of(ctx).pushReplacementNamed('/');
                                }),
                            TextButton(
                                child: Text("No"),
                                onPressed: () {
                                  Navigator.of(ctx).pop();
                                })
                          ]));
            },
          ),
        ),
      ],
    ));
  }
}
