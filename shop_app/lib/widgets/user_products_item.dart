import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shop_app/screens/edit_product_screen.dart';
import 'package:provider/provider.dart';
import '../providers/products.dart';

class UserProductItem extends StatelessWidget {
  final String id;
  final String title;
  final String imageURL;
  final snackBar = (String text) => SnackBar(
        backgroundColor: Colors.grey[300],
        content: Text(
          text,
          style: TextStyle(
            fontSize: 15,
          ),
        ),
        duration: Duration(seconds: 2),
      );

  UserProductItem(
      {@required this.id, @required this.title, @required this.imageURL});
  @override
  Widget build(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    return Column(
      children: [
        ListTile(
          title: Text(title),
          leading: CircleAvatar(
            backgroundImage: NetworkImage(imageURL),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  Navigator.of(context)
                      .pushNamed(EditProductScreen.routeName, arguments: id);
                },
                color: Theme.of(context).primaryColor,
              ),
              IconButton(
                icon: Icon(Icons.cancel),
                onPressed: () async {
                  return showDialog<void>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text("Removing Product "),
                      content: Text('Are you sure ? '),
                      actions: [
                        //! No
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          child: Text('No'),
                        ),
                        //! Yes
                        TextButton(
                          child: Text('Yes'),
                          onPressed: () async {
                            try {
                              await Provider.of<Products>(context,
                                      listen: false)
                                  .removeProduct(id);
                              Navigator.of(context).pop(true);
                            } catch (error) {
                              scaffold.showSnackBar(
                                const SnackBar(
                                    content: Text('Deletion Failed !')),
                              );
                              throw Exception();
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
                color: Theme.of(context).errorColor,
              ),
            ],
          ),
        ),
        Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 0), child: Divider()),
      ],
    );
  }
}
