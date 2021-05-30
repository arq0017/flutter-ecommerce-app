import 'package:flutter/material.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import '../widgets/product_grid.dart';
import '../widgets/badge.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart';
import 'cart_screen.dart';

enum FilterOptions {
  Favourites,
  All,
}

class ProductsOverviewScreen extends StatefulWidget {
  static final routeName = '/ProductOverviewScreen';
  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  bool isFavourites = false;
  bool _isLoading = false;

  void changeIsLoading(bool value) {
    setState(() {
      _isLoading = value;
    });
  }

  @override
  void initState() {
    changeIsLoading(true);
    Provider.of<Products>(context, listen: false)
        .fetchAndSetProduct()
        .then((_) => changeIsLoading(false));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final productsContainer = Provider.of<Products>(context, listen: false);
    // With provider we dont want to rebuild the scaffold , Hence
    var scaffold = Scaffold(
      appBar: AppBar(
        title: Text(
          'My Shop',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: <Widget>[
          PopupMenuButton(
            icon: Icon(Icons.more_vert),
            onSelected: (FilterOptions selectedValue) {
              setState(() {
                if (selectedValue == FilterOptions.Favourites) {
                  isFavourites = true;
                } else {
                  isFavourites = false;
                }
              });
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text('Only Favourites'),
                value: FilterOptions.Favourites,
              ),
              PopupMenuItem(
                child: Text('Show All'),
                value: FilterOptions.All,
              ),
            ],
          ),
          // we used child in builder method such that re run of build method can be avoided . Otherwise IconButton would have been rebuilt
          Consumer<Cart>(
            builder: (ctx, cart, ch) => Badge(
              child: ch,
              color: Colors.lightGreen,
              value: cart.itemCount.toString(),
            ),
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.pushNamed(context, CartScreen.routeName);
              },
            ),
          )
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? Container(
              child: LinearProgressIndicator(
              backgroundColor: Colors.orange[100],
              valueColor: AlwaysStoppedAnimation(Colors.blue[700]),
            ))
          : ProductGrid(isFavourites),
    );
    return scaffold;
  }
}
