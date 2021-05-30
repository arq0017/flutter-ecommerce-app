import 'package:flutter/material.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/screens/product_detail_screen.dart';
import 'package:provider/provider.dart';
import '../providers/product.dart';
import '../providers/cart.dart';

class ProductItem extends StatelessWidget {
  // final String id;
  // final String title;
  // final String imageUrl;
  // // positional arguments constructor
  // ProductItem(this.id, this.title, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    final item = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(13),
      child: GridTile(

// image
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(
                ProductDetailScreen.routeName,
                arguments: item.id,
              );
            },
            child: Hero(
              tag : item.id , 
                          child: FadeInImage(
                  placeholder: AssetImage('assets/images/shopping-cart.png'),
                  image: NetworkImage(item.imageUrl),
                  fit: BoxFit.cover),
            ),
          ),

// footer
          footer: GridTileBar(
            backgroundColor: Colors.black87,
            // favourite
            leading: Consumer<Product>(
              builder: (ctx, product, child) => IconButton(
                icon: Icon((item.isFavourite)
                    ? Icons.favorite
                    : Icons.favorite_outline_rounded),
                color: Colors.blue[400],
                onPressed: () async {
                  try {
                    await Provider.of<Products>(context, listen: false)
                        .toggleFavourite(item.id);
                  } catch (error) {
                    scaffold.showSnackBar(
                      SnackBar(
                        content: Text('Failed to make Favourite !'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    throw Exception();
                  }
                },
              ),
            ),
            // text
            title: Text(item.title,
                softWrap: true,
                overflow: TextOverflow.fade,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                )),
            // shopping_cart
            trailing: IconButton(
              icon: Icon(Icons.shopping_cart),
              color: Colors.blue[100],
              onPressed: () {
                cart.addItem(item.id, item.price, item.title);
                ScaffoldMessenger.of(context).removeCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Item Added ...',
                        style: TextStyle(color: Theme.of(context).accentColor)),
                    duration: Duration(seconds: 3),
                    action: SnackBarAction(
                      label: 'REMOVE',
                      onPressed: () {
                        cart.removeRecentItem(item.id);
                      },
                    ),
                  ),
                );
              },
            ),
          )),
    );
  }
}
